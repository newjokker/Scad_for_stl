/*
  LUNA / 月相摇摆 — 可打印舵机艺术摆件，单位 mm
  默认 assembly 装配预览；print_layout 三件平铺；base / frame / pendulum 单件。
  OpenSCAD 动画：视图 -> 动画，FPS=30、Steps=120；$t 控制一个完整往复周期。
  这是舵机主动驱动的动态雕塑，不是机械计时钟，也不能直接换成连续旋转电机。

  打印：底座平放；拱架背面朝下；月牙与摆杆一体平放。建议 0.2mm 层高。
  拱架厚 6mm、摆锤厚 3mm；底座底部螺丝头窝短桥接，按切片效果局部支撑。
  print_layout 占地约 200 x 205mm；小平台请使用单件模式。

  实物：一只普通位置舵机（默认 SG90 尺寸级，非360度连续旋转型）、原装双臂舵盘、
  舵机自带中心螺丝、舵机固定用两组 M2x10 螺丝/螺母、舵盘连接用两组 M2x8 螺丝/螺母、
  底座固定用两颗 M3x16 螺丝（拱架脚部先攻M3或慢速自攻）、控制板和舵机电源。
  先把舵机定位到90度，再安装竖直舵盘和摆锤。摆锤中心4.5mm孔用于访问舵盘中心螺丝。
  两侧长孔与双臂舵盘实物孔位对齐；不打印舵机花键。小螺母置于舵盘背面。
  先固定舵盘与摆锤，再一起装到舵机轴，最后通过中心孔拧中心螺丝。
  舵机安装耳贴拱架背面，输出端朝前；如实物输出高度不同，调整 horn_plane。
  先装舵机再把拱架插入底座；插脚下端从底座底部用M3螺丝锁紧。
  默认机身尺寸参考厂家 SG90 23 x 12.2 x 29mm：
  https://torqpro.com/product/sg90-analog/
  耳孔距、输出轴偏置、导孔与配合间隙为可调设计值，打印前测量实物。
*/
$fn = 96;
part = "assembly"; // [assembly,print_layout,base,frame,pendulum]
show_hardware = true;
swing_amplitude = 20; // degrees; start physical test at 10 degrees
manual_angle = 0;
animated = true;

base_w = 150;
base_d = 80;
base_t = 10;
frame_t = 6;
arch_r = 55;
arch_inner_r = 41;
arch_spring_y = 96;
foot_x = 48;
tab_w = 10;
tab_depth = 6; // 留4mm底层，避开底部3.2mm深螺丝头窝
fit = 0.3;
foot_pilot_d = 2.6;
pivot_y = 128;
servo_l = 23;
servo_w = 12.2;
servo_depth = 26; // visual rear projection; measure actual housing
servo_axis_from_end = 6;
servo_mount_spacing = 28; // nominal; measure ear spacing, slots adjust vertically ±1mm
servo_slot_travel = 2;
servo_fit = 0.6;
horn_plane = 13; // pendulum back face, measured forward from frame back face
pendulum_t = 3;
pendulum_length = 86;
moon_r = 24;
moon_cut_r = 21;
moon_cut_shift = 8;
hub_r = 15;
horn_hole_min = 7;
horn_hole_max = 11;
angle = manual_angle + (animated ? swing_amplitude*sin(360*$t) : 0);
servo_cx = servo_l/2-servo_axis_from_end;
assert(horn_plane > frame_t+3, "Need clearance behind moving pendulum");
assert(pivot_y-pendulum_length-moon_r > 3, "Moon too low");
assert(abs(manual_angle)+swing_amplitude <= 35, "Keep the initial motion within +/-35 degrees");
assert(tab_depth < base_t);
echo(parts="base, frame, pendulum", overall_mm=[base_w,base_d,base_t+arch_spring_y+arch_r]);

module rounded_rect(w,h,r) {
    hull() for(x=[-w/2+r,w/2-r],y=[-h/2+r,h/2-r])
        translate([x,y]) circle(r=r);
}
module slot2d(travel,d) {
    hull() for(x=[-travel/2,travel/2]) translate([x,0]) circle(d=d);
}
module star2d(r=3) {
    polygon([for(i=[0:9]) let(a=90+i*36,rr=i%2 ? r*0.43:r) [rr*cos(a),rr*sin(a)]]);
}
module base() {
    difference() {
        union() {
            linear_extrude(base_t) rounded_rect(base_w,base_d,15);
            // Raised front-side title, printed with the pedestal.
            translate([0,-25,base_t]) linear_extrude(0.6)
                text("L U N A",size=7,halign="center",valign="center");
        }
        for(x=[-foot_x,foot_x]) {
            translate([x,0,base_t-tab_depth-0.1])
                linear_extrude(tab_depth+0.2) square([tab_w+fit,frame_t+fit],center=true);
            translate([x,0,-0.1]) cylinder(h=base_t+0.2,d=3.4);
            translate([x,0,-0.1]) cylinder(h=3.3,d=6.4);
        }
        // Five recessed phase marks on the front lip.
        for(x=[-32,-16,0,16,32]) translate([x,-35,base_t-0.7]) cylinder(h=0.9,d=2);
    }
}
module arch2d() {
    union() {
        for(x=[-foot_x,foot_x]) translate([x,arch_spring_y/2])
            square([arch_r-arch_inner_r,arch_spring_y],center=true);
        translate([0,arch_spring_y]) intersection() {
            difference() { circle(r=arch_r); circle(r=arch_inner_r); }
            translate([-arch_r,0]) square([2*arch_r,arch_r]);
        }
        // Solid crown supports the servo ears and joins the arch over its full top.
        translate([servo_cx,131]) rounded_rect(64,38,10);
        for(x=[-foot_x,foot_x]) translate([x,-tab_depth/2]) square([tab_w,tab_depth],center=true);
    }
}
module frame() {
    difference() {
        linear_extrude(frame_t) arch2d();
        translate([servo_cx,pivot_y,-0.1]) linear_extrude(frame_t+0.2)
            square([servo_l+servo_fit,servo_w+servo_fit],center=true);
        for(x=[servo_cx-servo_mount_spacing/2,servo_cx+servo_mount_spacing/2])
            translate([x,pivot_y,-0.1]) linear_extrude(frame_t+0.2) rotate(90) slot2d(servo_slot_travel,2.3);
        // Blind pilot holes run up each tab; tiny horizontal tunnels in print orientation.
        for(x=[-foot_x,foot_x]) translate([x,-tab_depth-0.1,frame_t/2])
            rotate([-90,0,0]) cylinder(h=19,d=foot_pilot_d,$fn=40);
        // Celestial perforations, outside the screw-bearing crown.
        for(x=[-foot_x,foot_x],y=[36,66,94])
            translate([x,y,-0.1]) linear_extrude(frame_t+0.2) star2d(3.4);
        for(a=[35,55,125,145])
            translate([48*cos(a),arch_spring_y+48*sin(a),-0.1])
                cylinder(h=frame_t+0.2,d=2.2);
    }
}
module pendulum() {
    difference() {
        linear_extrude(pendulum_t) union() {
            circle(r=hub_r);
            hull() {
                translate([0,-9]) circle(r=2.5);
                translate([0,-pendulum_length+moon_r-7]) circle(r=2.5);
            }
            translate([0,-pendulum_length]) difference() {
                circle(r=moon_r);
                translate([moon_cut_shift,0]) circle(r=moon_cut_r);
            }
        }
        translate([0,0,-0.1]) cylinder(h=pendulum_t+0.2,d=4.5);
        for(sign=[-1,1]) translate([0,sign*(horn_hole_min+horn_hole_max)/2,-0.1])
            linear_extrude(pendulum_t+0.2) rotate(90)
                slot2d(horn_hole_max-horn_hole_min,2.3);
        // Small stars pierced in the broad left side of the crescent.
        for(y=[-7,7]) translate([-17,-pendulum_length+y,-0.1])
            linear_extrude(pendulum_t+0.2) star2d(2.1);
    }
}
module servo_preview() {
    color([0.16,0.34,0.62]) translate([servo_cx,pivot_y,-servo_depth/2])
        cube([servo_l,servo_w,servo_depth],center=true);
    color("steelblue") translate([servo_cx,pivot_y,-1])
        cube([servo_mount_spacing+6,servo_w,2],center=true);
    color("silver") translate([0,pivot_y,0]) cylinder(h=horn_plane-2,d=5);
    color("ivory") translate([0,pivot_y,horn_plane-2]) rotate([0,0,angle])
        linear_extrude(2) hull() for(y=[-12,12]) translate([0,y]) circle(r=3);
    // Fasteners are preview-only, so no metal parts are exported.
    for(x=[servo_cx-servo_mount_spacing/2,servo_cx+servo_mount_spacing/2])
        color("silver") translate([x,pivot_y,frame_t]) cylinder(h=1.5,d=4);
}
module assembly() {
    color([0.12,0.22,0.28]) base();
    // Local X/Y are width/height; local Z points toward the viewer.
    translate([0,frame_t/2,base_t]) rotate([90,0,0]) {
        color([0.16,0.32,0.38]) frame();
        color([0.92,0.65,0.24]) translate([0,pivot_y,horn_plane])
            rotate([0,0,angle]) pendulum();
        if($preview && show_hardware) servo_preview();
    }
}
if(part=="assembly") assembly();
else if(part=="base") base();
else if(part=="frame") translate([0,tab_depth,0]) frame();
else if(part=="pendulum") translate([moon_r,pendulum_length+moon_r,0]) pendulum();
else if(part=="print_layout") {
    translate([160,75,0]) rotate([0,0,90]) base();
    translate([55,tab_depth,0]) frame();
    translate([25,190,0]) rotate([0,0,90]) pendulum();
}
else assert(false,"Unknown part");
