/*
 * 原版 turntable STL 装配预览
 *
 * 这是对 stls/turntable 中四个 STL 的非破坏性引用：
 * Base.stl、Top_plate_.stl、Motor_Gear.stl、Pin_.stl。
 * STL 没有保存原作者的 OpenSCAD 参数或装配约束，所以这里保留每个
 * 文件的原始坐标，不对几何体做缩放；offset_* 只用于在 OpenSCAD 中
 * 试配和制作爆炸图。真实装配应以原 STL 的孔位、齿轮啮合和实物电机为准。
 */
$fn=64;
show_base=true;
show_top=true;
show_motor_gear=true;
show_pin=true;
exploded=false;
top_lift=exploded ? 35 : 0;
gear_lift=exploded ? -8 : 0;
pin_lift=exploded ? 12 : 0;

if (show_base) color("#60666d") import("Base.stl", convexity=10);
if (show_top) color("#ded5c1") translate([0,0,top_lift]) import("Top_plate_.stl", convexity=10);
if (show_motor_gear) color("#dfa83e") translate([0,0,gear_lift]) import("Motor_Gear.stl", convexity=10);
if (show_pin) color("#777777") translate([0,0,pin_lift]) import("Pin_.stl", convexity=10);
