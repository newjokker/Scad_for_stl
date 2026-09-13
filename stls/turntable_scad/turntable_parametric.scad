/*
 * 原版旋转盒：参数化重画版
 *
 * 这是根据 stls/turntable 的尺寸和可见结构重新建模，不是原作者源码的恢复。
 * 默认约 200 mm 外径；顶部内齿圈由 BOSL2 生成。先用 F5 检查啮合，再导出 STL。
 * part: assembly / base / top_plate / motor_gear / pin
 */
include <BOSL2/std.scad>
include <BOSL2/gears.scad>

$fn = 96;
part = "top_plate"; // [assembly,base,top_plate,motor_gear,pin]
show_hardware = true;
exploded = false;

// 外壳和顶盘
outer_d = 200;
wall = 3;
base_t = 6;
shell_h = 33;
top_t = 6;
top_z = base_t + shell_h;

// 传动：内齿圈和小齿轮必须使用相同模数、压力角
gear_mod = 1.5;
ring_teeth = 112;
pinion_teeth = 24;
gear_t = 8;
gear_backing = 4;
gear_backlash = 0.25;
pressure_angle = 20;
ring_z = top_z - gear_t;
center_distance = gear_mod * (ring_teeth - pinion_teeth) / 2;
pinion_x = center_distance;

// 中心定位轴和支承点
center_shaft_d = 10;
center_clearance = 0.45;
support_count = 3;
support_r = outer_d/2 - 14;
support_d = 10;
support_h = 3;

// 以常见小减速电机耳孔为默认值；改这里适配实物
motor_body_d = 36;
motor_hole_spacing = 35;
motor_hole_d = 3.2;
motor_axis_z = base_t + 16;
motor_axis_y = 0;

// 侧边仅保留一处 Type-C 线槽
cable_slot_w = 8;
cable_slot_h = 7;
cable_slot_angle = -90;

assert(ring_z > base_t + gear_t, "Gear must be above the base");
assert(center_distance + gear_mod*pinion_teeth/2 < outer_d/2-4, "Pinion is outside the case");
assert(gear_backlash >= 0);

module bolt_hole(d=3.2,h=20) { cylinder(d=d,h=h,center=true); }
module ring_wall() {
    difference() {
        cylinder(d=outer_d,h=base_t+shell_h);
        translate([0,0,base_t]) cylinder(d=outer_d-2*wall,h=shell_h+0.1);
    }
}
module base() {
    difference() {
        union() {
            cylinder(d=outer_d,h=base_t);
            ring_wall();
            // 中心轴座
            cylinder(d=18,h=ring_z-1);
            // 三个低摩擦支承台，顶盘落在这里
            for (a=[0:360/support_count:359])
                rotate(a) translate([support_r,0,base_t]) cylinder(d=support_d,h=support_h);
            // 电机耳座：中心距可调，电机轴位于 pinion_x
            for (y=[-motor_hole_spacing/2,motor_hole_spacing/2])
                translate([pinion_x,y,base_t]) cylinder(d=8,h=motor_axis_z-base_t);
        }
        // 底部电机耳孔
        for (y=[-motor_hole_spacing/2,motor_hole_spacing/2])
            translate([pinion_x,y,motor_axis_z-6]) bolt_hole(motor_hole_d,14);
        // 中心轴通孔只穿底座，不影响上方齿圈
        translate([0,0,-0.1]) cylinder(d=center_shaft_d,h=base_t+0.2);
        // Type-C 线槽：在侧壁开一个窄窗口，线从内侧放入
        rotate(cable_slot_angle) translate([-cable_slot_w/2,outer_d/2-wall-0.1,base_t+3])
            cube([cable_slot_w,wall+0.3,cable_slot_h]);
        // 四个底座安装孔
        for (a=[45,135,225,315]) rotate(a) translate([outer_d/2-10,0,-0.1])
            cylinder(d=3.4,h=base_t+0.2);
    }
}
module top_plate() {
    difference() {
        union() {
            translate([0,0,top_z]) cylinder(d=outer_d,h=top_t);
            // 齿圈背厚和齿形
            translate([0,0,ring_z])
                ring_gear(mod=gear_mod,teeth=ring_teeth,thickness=gear_t,
                    backing=gear_backing,pressure_angle=pressure_angle,
                    backlash=gear_backlash,anchor=BOTTOM);
            // 中心轴套
            translate([0,0,ring_z]) cylinder(d=18,h=top_z-ring_z+top_t);
            // 顶盘背面减重筋，保持承载刚度
            for (a=[0:30:330])
                rotate(a) translate([12,-1.2,top_z-1.2]) cube([outer_d/2-18,2.4,1.2]);
        }
        translate([0,0,ring_z-0.1]) cylinder(d=center_shaft_d+center_clearance,h=top_t+gear_t+1);
    }
}
module motor_gear() {
    difference() {
        spur_gear(mod=gear_mod,teeth=pinion_teeth,thickness=gear_t,
            pressure_angle=pressure_angle,backlash=gear_backlash,anchor=BOTTOM);
        // 默认圆轴孔，适用于带紧定螺丝的小电机齿轮
        translate([0,0,-0.1]) cylinder(d=5.2,h=gear_t+0.2);
        // M3 紧定螺丝横孔
        translate([0,0,gear_t/2]) rotate([0,90,0]) cylinder(d=2.6,h=20);
    }
}
module pin() {
    difference() {
        cylinder(d=8,h=12);
        translate([0,0,-0.1]) cylinder(d=3.2,h=12.2);
    }
}
module hardware() {
    color("#4e5962") translate([pinion_x,-motor_body_d/2,motor_axis_z-motor_body_d/2])
        cube([motor_body_d,motor_body_d,motor_body_d]);
    color("#999999") translate([pinion_x,0,motor_axis_z]) cylinder(d=5,h=12);
    color("#222222") translate([0,outer_d/2-2,base_t+5]) rotate([90,0,0]) cylinder(d=4,h=20);
}
module assembly() {
    color("#5c646b") base();
    color("#ded5c1") top_plate();
    color("#dca83e") translate([pinion_x,0,ring_z])
        rotate([0,0,exploded ? -25 : 0]) motor_gear();
    if (show_hardware) hardware();
}

if (part=="assembly") assembly();
else if (part=="base") base();
else if (part=="top_plate") top_plate();
else if (part=="motor_gear") motor_gear();
else if (part=="pin") pin();
else assert(false,"Unknown part");
