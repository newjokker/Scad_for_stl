/*
  TICK / 摆锤擒纵走时样机 — 机械钟第一阶段，单位mm
  重锤 -> 绕线鼓 -> 15齿擒纵轮 -> 擒纵叉 -> 金属摆杆及可调摆锤。
  每完整摆动释放1齿；校准完整周期到1秒时，每转15秒，刻度读0~15秒。
  此阶段没有时分针齿轮组/上弦棘轮，不是完整时分机械钟，也不是陀飞轮。
  rewind: 托住重锤，取下擒纵叉或松开叉的轴锁紧螺丝后回绕；勿逆向强拧锁住的轮。
  原始擒纵几何来自 syvwlch Printable Clock Project，CC Attribution-ShareAlike。
  详见 046_机械钟库/escapement_core.scad 及 046_打印件/装配与调试.md。
  本次重新设计承架、双轴承支撑、绕线轮毂、摆锤连接、计秒盘与分盘打印。
  机械装配可校验；未经过实物走时验证，锁止/冲量、摩擦和摆长仍需要试调。
*/
use <046_机械钟库/escapement_core.scad>
include <046_机械钟库/demo_motion.scad>
$fn = 96;
part = "assembly"; // [assembly,escapement_test,layout_structure,layout_motion,rear_frame,front_frame,rotor,anchor,hanger,bob,bob_lid,pointer,post,collar,wall_spacer,weight_cup,thrust_short,thrust_long]
show_hardware = true;
preview_angle = 0; // 静态检查擒纵叉；动画只示意，不是动力学求解
animate_demo = false;
escape_phase = -11.9; // 初始锁止前相位
wheel_r = 36;
teeth = 15;
tooth_span = 3.5;
core_scale = wheel_r/(0.5*80*3.2/3-3.5); // 与上游 Escapement-Animation 等比
tooth_len = 15*core_scale;
tooth_lean = 30;
club_angle = 22.5;
face_angle = 8;
arm_angle = 24;
spacing_trim = 0; // 中心距几何试配，修改后要重新打印前后承架
axis_gap = 2*wheel_r*cos(180/teeth*tooth_span)+spacing_trim;
plate_t = 6;
front_z = 32;
rotor_z = 12;
axle_d = 3;
axle_hole = 3.1;
bearing_od = 10;
bearing_fit = 0.1; // 623轴承，3x10x4；按打印机调整外圈配合
bearing_t = 4;
pendulum_L = 265; // 轴心到摆锤中心，实际调整约230~300mm
rod_length = 330; // 下端距轴心330mm；M3牙条截长320mm，上端插到轴心下10mm
post_points = [[-50,0],[50,0],[0,-50],[0,80]];
wall_points = [[0,95],[0,-66]];
demo_cycle = floor($t*teeth);
demo_fraction = $t*teeth-demo_cycle;
rock = animate_demo ? lookup(demo_fraction,demo_rock) : preview_angle;
wheel_angle = animate_demo ? lookup(demo_fraction,demo_wheel)-24*demo_cycle : escape_phase;
assert(axis_gap>48 && axis_gap<60);
assert(pendulum_L>200 && pendulum_L<310);
echo(anchor_axis_spacing=axis_gap, point_mass_1s_length_mm=9810/(4*PI*PI));
echo(tick_period_s=0.5, calibrated_seconds_per_wheel_turn=15,
     theoretical_runtime_s_for_500mm_line=500/(2*PI*8)*15);

module link2d(a,b,w) { hull() { translate(a) circle(d=w); translate(b) circle(d=w); } }
module annulus(ro,ri,h) { difference() { cylinder(h=h,r=ro); translate([0,0,-0.1]) cylinder(h=h+0.2,r=ri); } }
module bearing_cut(y) {
    translate([0,y,-0.1]) cylinder(h=plate_t+0.2,d=6);
    translate([0,y,plate_t-bearing_t]) cylinder(h=bearing_t+0.1,d=bearing_od+bearing_fit);
}
module frame_outline(front=false) {
    union() {
        difference() { circle(r=53); circle(r=44); }
        for(p=post_points) link2d([0,0],p,8);
        link2d([0,0],[0,80],8);
        translate([0,0]) circle(r=9);
        translate([0,axis_gap]) circle(r=9);
        for(p=post_points) translate(p) circle(r=7);
        if(!front) for(p=wall_points) {
            link2d([0,p[1]>0 ? 80:-50],p,10);
            translate(p) circle(r=8);
        }
    }
}
module frame(front=false) {
    difference() {
        linear_extrude(plate_t) frame_outline(front);
        bearing_cut(0); bearing_cut(axis_gap);
        for(p=post_points) translate([p[0],p[1],-0.1]) cylinder(h=plate_t+0.2,d=3.5);
        if(!front) for(p=wall_points) translate([p[0],p[1],-0.1]) cylinder(h=plate_t+0.2,d=4.5);
        if(front) {
            // Clockwise seconds scale. 15 repeats at zero, so label only 0..14.
            for(i=[0:29]) rotate([0,0,-i*12]) translate([0,49,plate_t-0.65])
                cube([i%2 ? 0.6:1, i%2 ? 3:5,1],center=true);
            for(i=[0:14]) rotate([0,0,-i*24]) translate([0,46.5,plate_t-0.6])
                linear_extrude(0.8) text(str(i),size=2.7,halign="center",valign="center");
        }
    }
}
// 15 original club teeth and circular locking/impulse geometry; drum + hub redesigned.
module rotor() {
    difference() {
        union() {
            ringTooth(wheel_r-tooth_len+4,wheel_r-tooth_len,4,teeth,tooth_len)
                tooth(tooth_len,4,tooth_lean,10,0.2,club_angle);
            spokes(3,wheel_r-tooth_len,4,4,0,0);
            cylinder(h=18,r=6);
            translate([0,0,4]) cylinder(h=1,r=10);
            translate([0,0,5]) cylinder(h=7,r=8);
            // Sloped upper flange, 45 degree maximum overhang.
            translate([0,0,12]) cylinder(h=2,r1=8,r2=10);
        }
        translate([0,0,-0.1]) cylinder(h=18.2,d=axle_hole);
        translate([0,0,15]) rotate([0,90,0]) cylinder(h=8,d=2.6,$fn=40);
        translate([-12,5,8]) rotate([0,90,0]) cylinder(h=24,d=1.8,$fn=32);
    }
}
module anchor() {
    difference() {
        union() {
            escapement(radius=wheel_r,thickness=4,faceAngle=face_angle,armAngle=arm_angle,
              armWidth=4*core_scale,numberTeeth=teeth,toothSpan=tooth_span,hubWidth=8,hubHeight=8,
              bore=axle_hole/2,entryPalletAngle=45-tooth_lean+club_angle,
              exitPalletAngle=45-tooth_lean+club_angle);
        }
        translate([0,0,5.5]) rotate([0,90,0]) cylinder(h=10,d=2.6,$fn=40);
    }
}
module hanger() {
    difference() {
        linear_extrude(8) hull() {
            circle(r=7); translate([0,-22]) circle(r=6);
        }
        translate([0,0,-0.1]) cylinder(h=8.2,d=axle_hole);
        translate([0,0,4]) rotate([0,90,0]) cylinder(h=9,d=2.6,$fn=40);
        // M3 rod pilot: opens downwards, stop before the transverse axle.
        translate([0,-29,4]) rotate([-90,0,0]) cylinder(h=19,d=2.6,$fn=40);
    }
}
module bob() {
    difference() {
        cylinder(h=12,r=23);
        translate([0,-25,6]) rotate([-90,0,0]) cylinder(h=50,d=3.5,$fn=40);
        // Two ordinary M8 nuts provide mass; recesses do not touch the rod tunnel.
        for(x=[-11,11]) translate([x,0,4.8]) cylinder(h=7.3,d=13.4/cos(30),$fn=6);
        for(y=[-16,16]) translate([0,y,6]) cylinder(h=6.1,d=1.7,$fn=32);
    }
}
module bob_lid() {
    difference() {
        cylinder(h=2,r=23);
        for(y=[-16,16]) translate([0,y,-0.1]) cylinder(h=2.2,d=2.3,$fn=32);
    }
}
module pointer() {
    difference() {
        union() {
            cylinder(h=6,r=5);
            linear_extrude(2) polygon([[-1.5,-8],[1.5,-8],[1,37],[0,41],[-1,37]]);
        }
        translate([0,0,-0.1]) cylinder(h=6.2,d=axle_hole);
        translate([0,0,4]) rotate([0,90,0]) cylinder(h=7,d=2.6,$fn=40);
    }
}
module post() { annulus(6,1.75,front_z-plate_t); }
module collar() {
    difference() {
        cylinder(h=5,r=5);
        translate([0,0,-0.1]) cylinder(h=5.2,d=axle_hole);
        translate([0,0,2.5]) rotate([0,90,0]) cylinder(h=7,d=2.6,$fn=40);
    }
}
module thrust(h=2.2) { annulus(2.5,1.6,h); }
module wall_spacer() { annulus(8,2.25,8); }
module weight_cup() {
    difference() {
        cylinder(h=30,r=11);
        translate([0,0,2]) cylinder(h=28.1,r=9);
        translate([-12,0,26]) rotate([0,90,0]) cylinder(h=24,d=2.4,$fn=32);
    }
}
module bearing() { color("silver") annulus(5,1.5,4); }
module line3d(a,b,d=0.7) { hull() { translate(a) sphere(d=d,$fn=12); translate(b) sphere(d=d,$fn=12); } }
module mechanism() {
    color([0.16,0.24,0.28]) frame();
    color([0.85,0.59,0.20]) translate([0,0,rotor_z]) rotate([0,0,wheel_angle]) rotor();
    color([0.76,0.33,0.20]) translate([0,axis_gap,rotor_z]) rotate([0,0,rock]) anchor();
    color([0.20,0.30,0.34]) translate([0,0,front_z]) frame(true);
    for(p=post_points) color([0.25,0.30,0.32]) translate([p[0],p[1],plate_t]) post();
    for(p=wall_points) color("gray") translate([p[0],p[1],-8]) wall_spacer();
    color("ivory") translate([0,0,40.2]) rotate([0,0,wheel_angle]) pointer();
    color("brown") translate([0,axis_gap,50]) rotate([0,0,rock]) {
        hanger();
        translate([0,-pendulum_L,-2]) bob();
        translate([0,-pendulum_L,10]) bob_lid();
        if($preview && show_hardware) color("silver")
            translate([0,-rod_length,4]) rotate([-90,0,0]) cylinder(h=rod_length-10,d=3);
    }
    for(y=[0,axis_gap]) color("gray") translate([0,y,-5.2]) collar();
    for(y=[0,axis_gap]) color("gray") translate([0,y,-0.2]) thrust(2.2);
    color("gray") translate([0,0,38]) thrust(2.2);
    color("gray") translate([0,axis_gap,38]) thrust(12);
    if($preview && show_hardware) {
        for(y=[0,axis_gap]) {
            for(z=[2,front_z+2]) translate([0,y,z]) bearing();
            color("silver") translate([0,y,-6]) cylinder(h=y==0 ? 55:65,d=3);
        }
        for(p=post_points) color("silver") {
            translate([p[0],p[1],-7]) cylinder(h=45,d=3);
            translate([p[0],p[1],38]) cylinder(h=3,d=5.5);
            translate([p[0],p[1],-2.4]) cylinder(h=2.4,d=6.35,$fn=6);
        }
        color("dimgray") {
            line3d([8,0,20],[8,-116,20]);
            line3d([8,-116,20],[-2,-126,20]);
            line3d([8,-116,20],[18,-126,20]);
        }
    }
    color([0.4,0.42,0.44]) translate([8,-152,20]) rotate([-90,0,0]) weight_cup();
}
if(part=="assembly") rotate([90,0,0]) mechanism();
else if(part=="escapement_test") {
    color("gold") rotate([0,0,wheel_angle]) rotor();
    color("tomato") translate([0,axis_gap,0]) rotate([0,0,rock]) anchor();
}
else if(part=="rear_frame") frame();
else if(part=="front_frame") frame(true);
else if(part=="rotor") rotor();
else if(part=="anchor") anchor();
else if(part=="hanger") hanger();
else if(part=="bob") bob();
else if(part=="bob_lid") bob_lid();
else if(part=="pointer") pointer();
else if(part=="post") post();
else if(part=="collar") collar();
else if(part=="wall_spacer") wall_spacer();
else if(part=="weight_cup") weight_cup();
else if(part=="thrust_short") thrust(2.2);
else if(part=="thrust_long") thrust(12);
else if(part=="layout_structure") {
    translate([55,75,0]) frame();
    translate([165,55,0]) frame(true);
    for(i=[0:3]) translate([130+i*17,158,0]) post();
    for(i=[0:1]) translate([134+i*22,181,0]) wall_spacer();
}
else if(part=="layout_motion") {
    translate([42,43,0]) rotor();
    translate([130,52,0]) anchor();
    translate([26,107,0]) bob();
    translate([80,107,0]) bob_lid();
    translate([125,114,0]) hanger();
    translate([151,88,0]) pointer();
    translate([181,107,0]) weight_cup();
    for(i=[0:1]) translate([20+i*15,146,0]) collar();
    for(i=[0:2]) translate([60+i*12,146,0]) thrust(2.2);
    translate([100,146,0]) thrust(12);
}
else assert(false,"Unknown part");
