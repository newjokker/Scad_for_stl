# 原版 STL 的 SCAD 几何转换版

这里的四个 `.scad` 是由 `stls/turntable` 的原始 STL 自动转换得到的 `polyhedron()` 网格。它们不再依赖 STL 文件，打开后可以继续使用 `difference()`、`union()`、`intersection()`，也可以修改文件末尾的 `scale_factor` 和 `translate_offset`。

每个文件都保留原始三角网格的顶点和面，因此外形应与对应 STL 一致。由于 STL 只保存三角面，不保存原作者的草图、齿轮参数、圆角半径、孔径命名或装配约束，这不是“恢复原始参数化源码”；要进行真正的结构优化，建议把这些网格作为基准，在外面重新建模关键部分。

示例：

```scad
// 在 Base 网格上开一个贯穿孔
 difference() {
     original_mesh();
     translate([0,0,-40]) cylinder(d=10,h=100);
 }
```

如果要在同一个装配文件中组合多个转换文件，请先把各文件中的 `original_mesh()` 重命名为不同名称，例如 `base_mesh()`、`top_plate_mesh()`、`motor_gear_mesh()`、`pin_mesh()`，再用 `use <...scad>` 引用。四个转换文件各自都使用 `original_mesh()`，单独打开没有问题，但组合时同名模块会冲突。
