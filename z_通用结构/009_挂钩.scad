// MakerWorld-friendly standalone version.
// This file keeps the small BOSL2 API subset used by the model inline, so it
// does not need external BOSL2 library files.

TOP = [0, 0, 1];
BOTTOM = [0, 0, -1];
CENTER = [0, 0, 0];

/* [整体缩放] */
model_scale = 0.5;   // [0.1:0.05:2]

/* [挂钩参数] */
base_w = 50;         // [10:1:100]
base_t = 10;         // [2:1:30]
hole_z = 25;         // [5:1:80]
outer_r = 25;        // [5:1:80]
inner_r = 15;        // [2:1:70]
rounding = 2;        // [0:0.5:10]
fillet = 2;          // [0:0.5:10]
hole_rounding = 1;   // [0:0.5:10]

/* [底板参数] */
show_plate = true;   // [true,false]
plate_w = 50;        // [10:1:150]
plate_d = 30;        // [10:1:100]
plate_h = 2;         // [1:0.5:20]

/* [显示精度] */
fn_val = 64;         // [16:8:128]

$fn = fn_val;


// Minimal replacement for BOSL2 cuboid(size, anchor=...).
module cuboid(size, anchor = CENTER) {
    translate([
        -anchor[0] * size[0] / 2,
        -anchor[1] * size[1] / 2,
        -anchor[2] * size[2] / 2
    ])
    cube(size, center = true);
}


function _defined(v) = !is_undef(v);
function _radius(r, d) = _defined(r) ? r : (_defined(d) ? d / 2 : undef);
function _clamp(v, lo, hi) = min(max(v, lo), hi);

// Tangent point from [base_size.x/2, 0] to the outer circle centered at
// [0, hole_z]. The point with the higher Z value gives the hook side.
function _right_tangent_point(base_size, hole_z, r) =
    let(
        px = base_size[0] / 2,
        py = -hole_z,
        d2 = px * px + py * py,
        root = sqrt(max(d2 - r * r, 0)),
        x1 = (r * r * px + r * py * root) / d2,
        y1 = (r * r * py - r * px * root) / d2,
        x2 = (r * r * px - r * py * root) / d2,
        y2 = (r * r * py + r * px * root) / d2,
        p1 = [x1, y1 + hole_z],
        p2 = [x2, y2 + hole_z]
    )
    p1[1] > p2[1] ? p1 : p2;


module _rounded_2d(r) {
    if (r > 0) {
        offset(r = r)
            offset(delta = -r)
                children();
    } else {
        children();
    }
}


module _ring_hook_profile(base_size, hole_z, outer_r, inner_r, rounding, fillet) {
    tangent = _right_tangent_point(base_size, hole_z, outer_r);
    bw = base_size[0];
    side_rounding = _clamp(rounding, 0, min(bw, outer_r) / 3);
    base_fillet = _clamp(abs(fillet), 0, min(bw, hole_z) / 4);

    difference() {
        _rounded_2d(side_rounding)
        union() {
            circle(r = outer_r);

            polygon(points = [
                [-bw / 2 + base_fillet, -hole_z],
                [ bw / 2 - base_fillet, -hole_z],
                [ tangent[0], tangent[1] - hole_z],
                [-tangent[0], tangent[1] - hole_z]
            ]);

            if (base_fillet > 0) {
                translate([-bw / 2 + base_fillet, -hole_z + base_fillet])
                    square([base_fillet * 2, base_fillet * 2], center = true);
                translate([ bw / 2 - base_fillet, -hole_z + base_fillet])
                    square([base_fillet * 2, base_fillet * 2], center = true);
            }
        }

        if (inner_r > 0)
            circle(r = inner_r);
    }
}


// Standalone replacement for the BOSL2 ring_hook() usage in this model.
// Supported parameters: base_size, hole_z, or/od, ir/id/wall, rounding, fillet,
// hole_rounding. hole_rounding is accepted for MakerWorld parameter
// compatibility; this compact implementation keeps the through hole straight.
module ring_hook(
    base_size,
    hole_z,
    or,
    ir,
    od,
    id,
    wall,
    hole = "circle",
    rounding = 0,
    fillet = 0,
    hole_rounding = 0,
    outside_segments,
    anchor = BOTTOM,
    spin = 0,
    orient = TOP
) {
    outer_r_tmp = _radius(or, od);
    inner_r_tmp = _radius(ir, id);
    outer_r = _defined(outer_r_tmp) ? outer_r_tmp
            : (_defined(inner_r_tmp) && _defined(wall) ? inner_r_tmp + wall : undef);
    inner_r = _defined(inner_r_tmp) ? inner_r_tmp
            : (_defined(wall) ? outer_r - wall : 0);

    assert(outer_r > 0, "outer radius must be greater than 0");
    assert(inner_r >= 0 && inner_r < outer_r, "inner radius must be >= 0 and smaller than outer radius");
    assert(hole == "circle", "This standalone MakerWorld version supports circle holes");
    assert(sqrt(pow(base_size[0] / 2, 2) + pow(hole_z, 2)) >= outer_r,
           "Base corners must be outside the outer circle");

    h = hole_z + outer_r;
    anchor_shift = anchor == BOTTOM ? [0, 0, hole_z]
                 : anchor == CENTER ? [0, 0, (hole_z - outer_r) / 2]
                 : anchor == TOP ? [0, 0, -outer_r]
                 : [0, 0, hole_z];

    translate(anchor_shift)
    rotate([0, 0, spin])
    rotate([90, 0, 0])
    linear_extrude(height = base_size[1], center = true, convexity = 10)
        _ring_hook_profile(base_size, hole_z, outer_r, inner_r, rounding, fillet);
}


hook_bottom_z = show_plate ? plate_h : 0;

// 挂钩
translate([0, 0, hook_bottom_z])
scale([model_scale, model_scale, model_scale])
ring_hook(
    base_size = [base_w, base_t],
    hole_z = hole_z,
    or = outer_r,
    ir = inner_r,
    rounding = rounding,
    fillet = fillet,
    hole_rounding = hole_rounding
);


// 底板
if (show_plate) {
    translate([0, 0, plate_h])
    cuboid(
        [plate_w, plate_d, plate_h],
        anchor = TOP
    );
}
