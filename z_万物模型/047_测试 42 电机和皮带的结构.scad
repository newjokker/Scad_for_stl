/*
  047 / 写字机 X 轴前期测试：NEMA17 + 开口 GT2 2mm/6mm + 20T惰轮
  单位mm。assembly装配；print_layout打印排版；其余part单件导出。
  皮带是一条开口带：左端夹在滑块左压块下 -> 向左绕电机轮 -> 下方回程
  -> 向右绕惰轮 -> 上方返回 -> 右端夹在滑块右压块下。两个端头不接成环。
  默认两个轮均为20T，电机轮孔5mm；惰轮需内置轴承，孔5mm，轮总宽参数idler_width。
  轮、皮带、电机、光轴和螺丝是实物；只导出打印结构件。不要用惰轮代替主动轮。
  两根直径8mm、长250mm光轴；打印滑块8.4mm孔作低速空载滑动配合。
  这不是精密写字机导轨；先检测传动、夹带、张紧和往返，后续可换直线轴承。
  两个端座固定到同一块约360x110mm的平整木板/型材底板，不能只靠两根光轴悬空拼接。
  电机中心与惰轮中心名义距280mm；惰轮轴沿X可调±6mm；导杆孔位不随张紧移动。
  电机每转理论移动20*2=40mm；若电机为1.8度，则200整步/转，对应5整步/mm。
  皮带先留约650mm，装配并张紧后再裁多余端头；模型节线路径长度见控制台。
  圆角夹带纹只用于端部夹持，不是同步轮驱动齿形；旋紧压块时按实物带厚调整。
*/
$fn=80;
part="print_layout"; // [assembly,print_layout,motor_mount,idler_mount,carriage,clamp_cap,idler_spacer,ruler]
show_hardware=true;
animate=false;
slider_x=150; // 65~235mm
idler_adjust=0; // -6~6mm，正值增加张紧
motor_body_length=40;
motor_hole_spacing=31;
motor_shaft_d=5;
motor_teeth=20;
idler_teeth=20;
pitch=2;
belt_width=6;
belt_t=1.4; // 带总厚度示意/压块起始间距，按实物调整
belt_y=-12;
axis_z=40;
center_distance=280;
idler_width=8; // 成品惰轮含挡边的总宽，需测量
fork_gap=14;
rod_d=8;
rod_clearance=0.4;
rod_y=[8,38];
rod_z=25;
rod_start=28;
rod_length=250;
travel_min=65;
travel_max=235;
carriage_w=50;
clamp_x=16;
clamp_length=18;
clamp_width=18;
clamp_t=2.5;
end_gap=2*(clamp_x-clamp_length/2); // 两个端头之间14mm断口
r=pitch*motor_teeth/(2*PI);
idler_x=center_distance+idler_adjust;
car_x=animate ? (travel_min+travel_max)/2+(travel_max-travel_min)/2*sin(360*$t) : slider_x;
belt_top_z=axis_z+r;
clamp_bed_z=belt_top_z-belt_t/2-0.65;
cap_z=belt_top_z+belt_t/2;
spacer_h=(fork_gap-idler_width)/2;
assert(motor_teeth==20 && idler_teeth==20,"This routing uses matching 20T pulleys");
assert(abs(idler_adjust)<=6);
assert(car_x>=travel_min && car_x<=travel_max);
assert(spacer_h>=0.8,"Measure idler width and adjust fork spacing");
assert(motor_body_length<=50,"Extend motor base for longer motor");
assert(rod_start+rod_length==278);
echo(travel_mm=travel_max-travel_min, belt_advance_per_rev=pitch*motor_teeth,
     open_belt_pitch_path_mm=2*idler_x+2*PI*r-end_gap, starter_belt_mm=650,
     idler_spacer_each_mm=spacer_h);

module hole_y(d,h) { rotate([90,0,0]) cylinder(h=h,d=d); }
module hole_x(d,h) { rotate([0,90,0]) cylinder(h=h,d=d); }
module rounded_plate(x0,x1,y0,y1,t,rad=4) {
    linear_extrude(t) hull() for(x=[x0+rad,x1-rad],y=[y0+rad,y1-rad])
        translate([x,y]) circle(r=rad);
}
module rod_supports(left=true) {
    for(y=rod_y) difference() {
        translate([left?22:264,y-7,6]) cube([left?14:18,14,28]);
        translate([left?28:263.9,y,rod_z]) hole_x(rod_d+0.25,left?8.1:14.1);
        translate([left?30:270,y,rod_z]) cylinder(h=10,d=2.6,$fn=36);
    }
}
module motor_mount_raw() {
    difference() {
        union() {
            rounded_plate(-30,40,-28,58,6);
            translate([-27,-6,6]) cube([54,6,62]);
            // Motor body fits between these two side ribs.
            for(x=[-27,23]) translate([x,0,6]) rotate([90,0,90])
                linear_extrude(4) polygon([[0,0],[30,0],[0,48]]);
            rod_supports(true);
        }
        translate([0,1,axis_z]) hole_y(24,8);
        for(x=[-motor_hole_spacing/2,motor_hole_spacing/2],z=[-motor_hole_spacing/2,motor_hole_spacing/2])
            translate([x,1,axis_z+z]) hole_y(3.5,8);
        for(x=[-23,33],y=[-21,51]) translate([x,y,-0.1]) cylinder(h=6.2,d=4.5);
    }
}
module idler_mount_raw() {
    difference() {
        union() {
            rounded_plate(254,308,-28,58,6);
            for(y=[-24,-5]) translate([268,y,6]) cube([26,5,42]);
            rod_supports(false);
        }
        // Both cheeks have aligned slots; only the M5 axle slides.
        for(y=[-18,1]) hull() for(dx=[-6,6])
            translate([center_distance+dx,y,axis_z]) hole_y(5.5,7);
        for(x=[260,302],y=[-21,51]) translate([x,y,-0.1]) cylinder(h=6.2,d=4.5);
    }
}
module carriage_raw() {
    difference() {
        union() {
            translate([-25,0,16]) cube([50,48,17]);
            // High bridge clears the bottom return strand of the belt.
            translate([-25,0,30]) cube([50,6,clamp_bed_z-30]);
            translate([-25,-22,40]) cube([50,28,clamp_bed_z-40]);
            // 2mm-spaced rounded gripping ribs underneath each end.
            for(side=[-1,1],dx=[-7:2:7])
                translate([side*clamp_x+dx,belt_y+belt_width/2,clamp_bed_z+0.2])
                    hole_y(0.9,belt_width);
        }
        for(y=rod_y) translate([-26,y,rod_z]) hole_x(rod_d+rod_clearance,52);
        for(x=[-clamp_x,clamp_x],dy=[-6.5,6.5]) {
            translate([x,belt_y+dy,39.9]) cylinder(h=10,d=3.4,$fn=40);
            translate([x,belt_y+dy,39.9]) cylinder(h=2.7,d=5.7/cos(30),$fn=6);
        }
        // Future pen/tool plate pilot holes: 24 x 16mm pattern.
        for(x=[-12,12],y=[22,38]) translate([x,y,26]) cylinder(h=7.1,d=2.6,$fn=36);
    }
}
module carriage_print() {
    // Guide bores print vertically; broad end section sits on the build plate.
    translate([-16,22,25]) rotate([0,90,0]) carriage_raw();
}
module clamp_cap() {
    difference() {
        linear_extrude(clamp_t) hull()
            for(x=[-clamp_length/2+2,clamp_length/2-2],y=[-clamp_width/2+2,clamp_width/2-2])
                translate([x,y]) circle(r=2);
        for(y=[-6.5,6.5]) translate([0,y,-0.1]) cylinder(h=clamp_t+0.2,d=3.4,$fn=40);
    }
}
module idler_spacer() {
    difference() {
        cylinder(h=spacer_h,d=8);
        translate([0,0,-0.1]) cylinder(h=spacer_h+0.2,d=5.3);
    }
}
module ruler() {
    difference() {
        cube([190,12,3]);
        for(x=[4,186]) translate([x,6,-0.1]) cylinder(h=3.2,d=3.5);
        for(i=[0:5:170]) translate([10+i,0,2.4]) cube([0.6,i%10==0?5:3,0.8]);
        for(i=[0:20:160]) translate([10+i,7,2.4]) linear_extrude(0.8)
            text(str(i),size=3,halign="center",valign="center");
    }
}
// Hardware models are approximate envelopes; purchase actual GT2 pulleys and open belt.
module pulley_preview(teeth=20,w=8) {
    pd=teeth*pitch/PI;
    color("silver") rotate([90,0,0]) translate([0,0,-w/2]) difference() {
        union() {
            cylinder(h=w,d=pd+3);
        }
        translate([0,0,1]) difference() {
            cylinder(h=w-2,d=pd+3.2);
            cylinder(h=w-2,d=pd-0.508);
        }
        translate([0,0,-0.1]) cylinder(h=w+0.2,d=5);
    }
}
module open_belt_preview() {
    // ONE continuous open path: the only break is between the carriage's two clamps.
    color([0.12,0.13,0.15]) translate([0,belt_y+belt_width/2,0]) rotate([90,0,0])
        linear_extrude(belt_width) union() {
            translate([0,axis_z+r-belt_t/2]) square([car_x-end_gap/2,belt_t]);
            translate([car_x+end_gap/2,axis_z+r-belt_t/2]) square([idler_x-car_x-end_gap/2,belt_t]);
            translate([0,axis_z-r-belt_t/2]) square([idler_x,belt_t]);
            for(x=[0,idler_x]) translate([x,axis_z]) intersection() {
                difference() { circle(r=r+belt_t/2); circle(r=r-belt_t/2); }
                translate([x==0 ? -r-belt_t:0,-r-belt_t]) square([r+belt_t,2*(r+belt_t)]);
            }
        }
}
module hardware_preview() {
    color([0.25,0.27,0.30]) translate([-21,0,axis_z-21]) cube([42,motor_body_length,42]);
    color("silver") translate([0,0,axis_z]) hole_y(motor_shaft_d,24);
    translate([0,belt_y,axis_z]) pulley_preview();
    translate([idler_x,belt_y,axis_z]) pulley_preview(idler_teeth,idler_width);
    for(y=rod_y) color("silver") translate([rod_start,y,rod_z]) hole_x(rod_d,rod_length);
    color("silver") translate([idler_x,10,axis_z]) hole_y(5,35);
    color("silver") translate([idler_x,-25,axis_z]) hole_y(8.5,4);
    color("silver") translate([idler_x,5,axis_z]) rotate([90,0,0]) cylinder(h=4,d=9.24,$fn=6);
    for(x=[-clamp_x,clamp_x],dy=[-6.5,6.5]) color("silver") {
        translate([car_x+x,belt_y+dy,cap_z+clamp_t-10]) cylinder(h=10,d=3);
        translate([car_x+x,belt_y+dy,cap_z+clamp_t]) cylinder(h=3,d=5.5);
    }
    open_belt_preview();
}
module assembly() {
    color([0.18,0.30,0.38]) motor_mount_raw();
    color([0.18,0.30,0.38]) idler_mount_raw();
    color([0.92,0.57,0.17]) translate([car_x,0,0]) carriage_raw();
    for(x=[-clamp_x,clamp_x]) color([0.72,0.24,0.17])
        translate([car_x+x,belt_y,cap_z]) clamp_cap();
    // Spacer bears on the idler's inner race; it must not rub the rotating flanges.
    color("gray") translate([idler_x,-5,axis_z]) rotate([90,0,0]) idler_spacer();
    color("gray") translate([idler_x,-19+spacer_h,axis_z]) rotate([90,0,0]) idler_spacer();
    color([0.6,0.67,0.70]) translate([55,-42,0]) ruler();
    if($preview && show_hardware) hardware_preview();
}
if(part=="assembly") assembly();
else if(part=="motor_mount") translate([30,28,0]) motor_mount_raw();
else if(part=="idler_mount") translate([-254,28,0]) idler_mount_raw();
else if(part=="carriage") carriage_print();
else if(part=="clamp_cap") translate([9,9,0]) clamp_cap();
else if(part=="idler_spacer") translate([4,4,0]) idler_spacer();
else if(part=="ruler") ruler();
else if(part=="print_layout") {
    translate([30,28,0]) motor_mount_raw();
    translate([80-254,28,0]) idler_mount_raw();
    translate([145,0,0]) carriage_print();
    for(y=[9,37]) translate([192,y,0]) clamp_cap();
    for(y=[65,80]) translate([190,y,0]) idler_spacer();
    translate([0,100,0]) ruler();
}
else assert(false,"Unknown part");
