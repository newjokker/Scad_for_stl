import re
import xml.etree.ElementTree as ET
import matplotlib.pyplot as plt


def _to_float(v, default=0.0):
    if v is None:
        return default
    try:
        return float(v)
    except Exception:
        return default


def parse_path_MLZ(d: str):
    """
    仅解析 M/L/Z（绝对坐标为主），返回多个子路径：
    [ [(x,y),...], [(x,y),...], ... ]
    """
    s = d.replace(",", " ")
    tokens = re.findall(r"[MLZmlz]|-?\d+(?:\.\d+)?", s)

    subpaths = []
    cur = []
    cmd = None
    i = 0

    def flush():
        nonlocal cur
        if cur:
            subpaths.append(cur)
            cur = []

    while i < len(tokens):
        t = tokens[i]
        if re.fullmatch(r"[MLZmlz]", t):
            cmd = t
            i += 1
            if cmd in ("Z", "z"):
                if cur:
                    cur.append(cur[0])  # 闭合
                flush()
            continue

        if cmd is None:
            i += 1
            continue

        if cmd in ("M", "L", "m", "l"):
            if i + 1 >= len(tokens):
                break
            x = float(tokens[i])
            y = float(tokens[i + 1])
            i += 2

            # 相对坐标支持（m/l）
            if cmd in ("m", "l") and cur:
                px, py = cur[-1]
                x += px
                y += py

            if cmd in ("M", "m"):
                flush()
                cur.append((x, y))
                # SVG 规则：M 后续坐标对等价于 L
                cmd = "L" if cmd == "M" else "l"
            else:
                cur.append((x, y))
        else:
            # 遇到 C/Q/A 等曲线命令：这里不解析，跳过以免死循环
            i += 1

    flush()
    return subpaths


def plot_each_shape(svg_path: str, invert_y=True):
    tree = ET.parse(svg_path)
    root = tree.getroot()

    # 每个元素单独出一张图（最符合“每一个图形可视化出来”）
    idx = 0

    for elem in root.iter():
        tag = elem.tag.split("}")[-1]
        a = elem.attrib

        if tag not in {"path", "rect", "circle", "ellipse", "line", "polyline", "polygon"}:
            continue

        idx += 1
        fig, ax = plt.subplots()
        ax.set_aspect("equal", adjustable="box")

        title = f"{idx}: {tag}"
        if "id" in a:
            title += f"  id={a['id']}"
        ax.set_title(title)

        all_x, all_y = [], []

        if tag == "path" and "d" in a:
            for pts in parse_path_MLZ(a["d"]):
                if len(pts) < 2:
                    continue
                xs = [p[0] for p in pts]
                ys = [p[1] for p in pts]
                ax.plot(xs, ys)
                all_x += xs
                all_y += ys

        elif tag == "rect":
            x = _to_float(a.get("x"))
            y = _to_float(a.get("y"))
            w = _to_float(a.get("width"))
            h = _to_float(a.get("height"))
            xs = [x, x + w, x + w, x, x]
            ys = [y, y, y + h, y + h, y]
            ax.plot(xs, ys)
            all_x += xs
            all_y += ys

        elif tag == "circle":
            cx = _to_float(a.get("cx"))
            cy = _to_float(a.get("cy"))
            r = _to_float(a.get("r"))
            t = [i * 2 * 3.1415926 / 180 for i in range(361)]
            xs = [cx + r * __import__("math").cos(tt) for tt in t]
            ys = [cy + r * __import__("math").sin(tt) for tt in t]
            ax.plot(xs, ys)
            all_x += xs
            all_y += ys

        elif tag == "ellipse":
            cx = _to_float(a.get("cx"))
            cy = _to_float(a.get("cy"))
            rx = _to_float(a.get("rx"))
            ry = _to_float(a.get("ry"))
            t = [i * 2 * 3.1415926 / 180 for i in range(361)]
            xs = [cx + rx * __import__("math").cos(tt) for tt in t]
            ys = [cy + ry * __import__("math").sin(tt) for tt in t]
            ax.plot(xs, ys)
            all_x += xs
            all_y += ys

        elif tag == "line":
            x1 = _to_float(a.get("x1"))
            y1 = _to_float(a.get("y1"))
            x2 = _to_float(a.get("x2"))
            y2 = _to_float(a.get("y2"))
            ax.plot([x1, x2], [y1, y2])
            all_x += [x1, x2]
            all_y += [y1, y2]

        elif tag in {"polyline", "polygon"}:
            pts_str = a.get("points", "").strip()
            pts = []
            if pts_str:
                # points 可能是 "x,y x,y ..." 或 "x y x y ..."
                nums = re.findall(r"-?\d+(?:\.\d+)?", pts_str)
                nums = list(map(float, nums))
                pts = list(zip(nums[0::2], nums[1::2]))

            if pts:
                xs = [p[0] for p in pts]
                ys = [p[1] for p in pts]
                if tag == "polygon":
                    xs.append(xs[0])
                    ys.append(ys[0])
                ax.plot(xs, ys)
                all_x += xs
                all_y += ys

        if all_x and all_y:
            ax.set_xlim(min(all_x) - 5, max(all_x) + 5)
            ax.set_ylim(min(all_y) - 5, max(all_y) + 5)

        # SVG 默认 y 向下，matplotlib y 向上
        if invert_y:
            ax.invert_yaxis()

        plt.show()


# 使用
plot_each_shape("/Volumes/Jokker/Code/Scad_for_stl/svg/4.svg", invert_y=True)
