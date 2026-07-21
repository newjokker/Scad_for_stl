#!/usr/bin/env python3
import argparse
import math
import shutil
import subprocess
import tempfile
import zipfile
from pathlib import Path
from xml.sax.saxutils import escape


PARTS = [
    ("base_gray", "Base Gray", "#B4B4B4FF", "base();"),
    ("red_r", "Red R", "#C12E1FFF", "color_part([-18, -18, 1.5], \"R\");"),
    ("blue_b", "Blue B", "#0066BFFF", "color_part([18, -18, 1.5], \"B\");"),
    ("green_g", "Green G", "#00AF53FF", "color_part([-18, 18, 1.5], \"G\");"),
    ("yellow_y", "Yellow Y", "#FFD700FF", "color_part([18, 18, 1.5], \"Y\");"),
]


SCAD_TEMPLATE = r'''
$fn = 32;

module base() {
    cube([50, 50, 3], center = true);
}

module color_part(pos, label) {
    translate(pos) {
        cube([14, 14, 6]);
    }
    translate([pos[0], pos[1], 8]) {
        linear_extrude(height = 2) {
            text(label, size = 8, valign = "center", halign = "center", font = "Arial:style=Bold");
        }
    }
}

%s
'''


def run(cmd):
    subprocess.run(cmd, check=True)


def parse_ascii_stl(path):
    vertices = []
    triangles = []
    vertex_index = {}
    current = []

    def add_vertex(coords):
        key = tuple(round(float(v), 6) for v in coords)
        if key not in vertex_index:
            vertex_index[key] = len(vertices)
            vertices.append(key)
        return vertex_index[key]

    with path.open("r", encoding="utf-8", errors="ignore") as fh:
        for raw in fh:
            line = raw.strip()
            if line.startswith("vertex "):
                current.append(add_vertex(line.split()[1:4]))
            elif line == "endfacet":
                if len(current) == 3:
                    a, b, c = current
                    va, vb, vc = vertices[a], vertices[b], vertices[c]
                    ab = [vb[i] - va[i] for i in range(3)]
                    ac = [vc[i] - va[i] for i in range(3)]
                    cross = (
                        ab[1] * ac[2] - ab[2] * ac[1],
                        ab[2] * ac[0] - ab[0] * ac[2],
                        ab[0] * ac[1] - ab[1] * ac[0],
                    )
                    if math.sqrt(sum(v * v for v in cross)) > 1e-9:
                        triangles.append((a, b, c))
                current = []
    return vertices, triangles


def shifted_vertices(vertices, offset):
    return [
        (x + offset[0], y + offset[1], z + offset[2])
        for x, y, z in vertices
    ]


def write_ascii_stl(path, name, vertices, triangles):
    with path.open("w", encoding="utf-8") as fh:
        fh.write(f"solid {name}\n")
        for a, b, c in triangles:
            va, vb, vc = vertices[a], vertices[b], vertices[c]
            ab = [vb[i] - va[i] for i in range(3)]
            ac = [vc[i] - va[i] for i in range(3)]
            normal = (
                ab[1] * ac[2] - ab[2] * ac[1],
                ab[2] * ac[0] - ab[0] * ac[2],
                ab[0] * ac[1] - ab[1] * ac[0],
            )
            length = math.sqrt(sum(v * v for v in normal))
            if length > 1e-9:
                normal = tuple(v / length for v in normal)
            fh.write(f"  facet normal {normal[0]:.6g} {normal[1]:.6g} {normal[2]:.6g}\n")
            fh.write("    outer loop\n")
            for idx in (a, b, c):
                x, y, z = vertices[idx]
                fh.write(f"      vertex {x:.6f} {y:.6f} {z:.6f}\n")
            fh.write("    endloop\n")
            fh.write("  endfacet\n")
        fh.write(f"endsolid {name}\n")


def mesh_xml(object_id, name, vertices, triangles, material_group, material_index):
    out = [f'<object id="{object_id}" name="{escape(name)}" type="model">', "<mesh>", "<vertices>"]
    for x, y, z in vertices:
        out.append(f'<vertex x="{x:.6f}" y="{y:.6f}" z="{z:.6f}"/>')
    out.append("</vertices>")
    out.append("<triangles>")
    for a, b, c in triangles:
        out.append(
            f'<triangle v1="{a}" v2="{b}" v3="{c}" pid="{material_group}" p1="{material_index}"/>'
        )
    out.append("</triangles>")
    out.append("</mesh></object>")
    return "\n".join(out)


def build_3mf(output, meshes, center):
    material_group = 1
    resources = [f'<basematerials id="{material_group}">']
    for _, name, color, _ in PARTS:
        resources.append(f'<base name="{escape(name)}" displaycolor="{color}"/>')
    resources.append("</basematerials>")

    build_items = []
    for idx, (part, vertices, triangles) in enumerate(meshes):
        object_id = idx + 2
        vertices = shifted_vertices(vertices, center)
        resources.append(mesh_xml(object_id, part[1], vertices, triangles, material_group, idx))
        build_items.append(f'<item objectid="{object_id}"/>')

    model = f'''<?xml version="1.0" encoding="UTF-8"?>
<model unit="millimeter" xml:lang="en-US"
 xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02"
 xmlns:m="http://schemas.microsoft.com/3dmanufacturing/material/2015/02">
<metadata name="Title">del multicolor model</metadata>
<metadata name="Application">BambuStudio-02.06.00.51</metadata>
<resources>
{chr(10).join(resources)}
</resources>
<build>
{chr(10).join(build_items)}
</build>
</model>
'''

    content_types = '''<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
<Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/>
<Default Extension="config" ContentType="application/octet-stream"/>
</Types>
'''

    rels = '''<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Target="/3D/3dmodel.model" Id="rel0" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>
</Relationships>
'''

    project_settings = '''{
  "filament_type": ["PLA", "PLA", "PLA", "PLA", "PLA"],
  "filament_colour": ["#B4B4B4", "#C12E1F", "#0066BF", "#00AF53", "#FFD700"],
  "filament_diameter": ["1.75", "1.75", "1.75", "1.75", "1.75"],
  "filament_density": ["1.24", "1.24", "1.24", "1.24", "1.24"]
}
'''

    model_settings_objects = []
    for idx, part in enumerate(PARTS):
        object_id = idx + 2
        extruder = idx + 1
        model_settings_objects.append(f'''<object id="{object_id}">
  <metadata key="name" value="{escape(part[1])}"/>
  <metadata key="extruder" value="{extruder}"/>
</object>''')

    model_settings = f'''<?xml version="1.0" encoding="UTF-8"?>
<config>
{chr(10).join(model_settings_objects)}
<plate>
  <metadata key="plater_id" value="1"/>
  <metadata key="plater_name" value=""/>
  <metadata key="filament_map_mode" value="Auto For Flush"/>
  <metadata key="filament_maps" value="1,2,3,4,5"/>
</plate>
</config>
'''

    with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        zf.writestr("[Content_Types].xml", content_types)
        zf.writestr("_rels/.rels", rels)
        zf.writestr("3D/3dmodel.model", model)
        zf.writestr("Metadata/project_settings.config", project_settings)
        zf.writestr("Metadata/model_settings.config", model_settings)


def main():
    parser = argparse.ArgumentParser(description="Export del.scad as a multi-object, colored 3MF.")
    parser.add_argument("-o", "--output", default="exports/del_multicolor.3mf")
    parser.add_argument("--parts-dir", default="exports/del_multicolor_parts")
    parser.add_argument("--center-x", type=float, default=128.0)
    parser.add_argument("--center-y", type=float, default=128.0)
    parser.add_argument("--z-lift", type=float, default=1.5)
    args = parser.parse_args()

    output = Path(args.output).resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    parts_dir = Path(args.parts_dir).resolve()
    parts_dir.mkdir(parents=True, exist_ok=True)

    meshes = []
    with tempfile.TemporaryDirectory(prefix="del_multicolor_") as tmp:
        tmpdir = Path(tmp)
        for part in PARTS:
            scad = tmpdir / f"{part[0]}.scad"
            stl = tmpdir / f"{part[0]}.stl"
            scad.write_text(SCAD_TEMPLATE % part[3], encoding="utf-8")
            run(["openscad", "--export-format", "asciistl", "-o", str(stl), str(scad)])
            vertices, triangles = parse_ascii_stl(stl)
            if not vertices or not triangles:
                raise RuntimeError(f"No mesh generated for {part[0]}")
            centered_vertices = shifted_vertices(vertices, (args.center_x, args.center_y, args.z_lift))
            write_ascii_stl(parts_dir / f"{part[0]}.stl", part[0], centered_vertices, triangles)
            meshes.append((part, vertices, triangles))

    build_3mf(output, meshes, (args.center_x, args.center_y, args.z_lift))
    print(output)
    print(parts_dir)


if __name__ == "__main__":
    main()
