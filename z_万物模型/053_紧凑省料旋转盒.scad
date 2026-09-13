/* 053 / 紧凑省料旋转盒 V2 — 200g 桌面摆件样机，单位 mm
 * 原 stls/turntable: 直径200mm，原文件保留。新版直径120mm，高35.6mm。
 * 默认按28BYJ-48 5V + ULN2003 + ESP32-C3小板设计；打印前确认实物。
 * 依赖 BOSL2。两齿轮成对重做，不与原齿轮混用。
 * part: assembly / exploded / print_layout / base / platter / pinion / cable_clamp
 * 装配顶盘重力落座，可直接取下；不要抓顶盘提起整机。
 * 三点滑动支承承重，中心打印轴定位。200g是设计目标，尚未实物负载验证。
 */
include <BOSL2/std.scad>
include <BOSL2/gears.scad>
$fn=256;
part="exploded"; // [assembly,exploded,print_layout,base,platter,pinion,cable_clamp]
show_hardware=true;
cutaway=false;
animate=false;
rot_angle=0;
outer_d=120;
wall=1.6;
floor_t=1.6;
face_t=1.6;
modulus=1.25;
ring_teeth=80;
pinion_teeth=20;
backlash=0.16; // 各齿轮节圆齿厚减量；总名义侧隙0.32mm
gear_z=25;
gear_h=6;
face_z=34;
shell_top=33.4;
shaft_d=8;
shaft_fit=0.4; // 直径间隙
motor_adjust=0; // [-0.5:0.05:0.5] 径向安装微调，实体位置与预览一致
motor_ear_z=22;
motor_hole_spacing=35;
motor_axis_offset=8;
motor_body_h=19;
shaft_hole_d=5.2;
shaft_flat=3.2; // 双D轴两平面间距，按实物轴调整
cable_d=4.2;
spin_a=rot_angle+(animate?360*$t:0);
ring_r=modulus*ring_teeth/2;
center_dist=modulus*(ring_teeth-pinion_teeth)/2;
motor_x=center_dist+motor_adjust;
body_x=motor_x-motor_axis_offset;
pad_r=56.5;

assert(outer_d==120,"This compact layout is validated for diameter 120; redesign supports for other sizes");
assert(abs(motor_adjust)<=0.5);
assert(32.6 > gear_z+gear_h,"Ribs must clear pinion across full revolution");
assert(motor_ear_z-motor_body_h>=floor_t);
assert(shaft_flat<shaft_hole_d);
echo(envelope_mm=[outer_d,outer_d,face_z+face_t],ratio=ring_teeth/pinion_teeth,gear_center_mm=center_dist);
module ring(od,id,h){difference(){cylinder(d=od,h=h);translate([0,0,-.01]) cylinder(d=id,h=h+.02);}}
module slot2(d,l){hull() for(x=[-l/2,l/2]) translate([x,0]) circle(d=d);}
module floor_part(){
 difference(){
  union(){
   cylinder(d=outer_d,h=floor_t);
   // 内侧低筋；不侵入电机底面（电机底部3mm）
   for(a=[60,120,240,300]) rotate(a) translate([8,-.7,floor_t-.01]) cube([45,1.4,1.2]);
   cylinder(d=14,h=24);
   translate([0,0,23.9]) cylinder(d=shaft_d,h=9.6);
   for(y=[-motor_hole_spacing/2,motor_hole_spacing/2])
    translate([body_x,y,0]) cylinder(d=8,h=motor_ear_z);
   // USB线压片座，固定后沿后壁上行到顶缘出线槽
   for(x=[-7,7]) translate([x,-48,0]) cylinder(d=6,h=5);
   // 板底架空2mm，扎带固定，不假定开发板孔距
   for(y=[-26,-8,16,28]) translate([-39,y,floor_t-.01]) cube([26,2,2.01]);
  }
  for(y=[-motor_hole_spacing/2,motor_hole_spacing/2])
   translate([body_x,y,motor_ear_z-10]) cylinder(d=2.6,h=10.1);
  for(x=[-7,7]) translate([x,-48,1]) cylinder(d=2.5,h=4.1);
  for(y=[-17,23],x=[-47,-9]) translate([x,y,-.1]) linear_extrude(2) slot2(2.4,3);
 }
}
module shell_world(){
 difference(){
  union(){
   translate([0,0,floor_t-.05]) ring(outer_d,outer_d-2*wall,shell_top-floor_t+.05);
   // 三个等高小滑台，避免整圈大面积摩擦；底部斜撑免悬空
   for(a=[0,120,240]) rotate(a) hull(){
    translate([58.7,-2,30.2]) cube([1,4,.4]);
    translate([pad_r-1,-2,33.6]) cube([3.2,4,.4]);
   }
  }
  // 顶缘开口，从上方放入线材，顶盘盖住槽口；不用穿Type-C插头。
  translate([0,-57,30]) rotate([90,0,0]) linear_extrude(5)
   union(){translate([-cable_d/2,0]) square([cable_d,6]);circle(d=cable_d);}

 }
}
module base_part(){ union(){floor_part();shell_world();} }
module platter_world(){
 difference(){
  union(){
   translate([0,0,face_z]) cylinder(d=outer_d,h=face_t);
   translate([0,0,gear_z]) ring_gear(mod=modulus,teeth=ring_teeth,thickness=face_z-gear_z+.05,
    backing=2,pressure_angle=20,profile_shift=0,backlash=backlash,anchor=BOTTOM);
   translate([0,0,24.3]) cylinder(d=15,h=face_z-24.3+.05);
   // 八根顶盘背筋：底面32.6，避开32mm高的电机轴端
   for(a=[0:45:315]) rotate(a) translate([5,-.8,32.6]) cube([46,1.6,1.45]);
  }
  translate([0,0,24.2]) cylinder(d=shaft_d+shaft_fit,h=9.8); // 盲孔到34，不穿面板
  translate([0,0,24.2]) cylinder(d1=shaft_d+shaft_fit+1,d2=shaft_d+shaft_fit,h=.6);
 }
}
module pinion_part(){
 difference(){
  spur_gear(mod=modulus,teeth=pinion_teeth,thickness=gear_h,profile_shift=0,
   pressure_angle=20,backlash=backlash,anchor=BOTTOM);
  translate([0,0,-.1]) linear_extrude(gear_h+.2) intersection(){circle(d=shaft_hole_d);square([shaft_flat,10],center=true);}
  // M3x8无头紧定螺丝顶住轴平面，外端必须低于齿根圆。
  translate([0,0,3]) rotate([0,90,0]) cylinder(d=2.6,h=16);
 }
}
module cable_clamp(){
 difference(){
  linear_extrude(2) slot2(6,14);
  for(x=[-7,7]) translate([x,0,-.1]) cylinder(d=2.8,h=2.2);
 }
}
module hardware(){
 color("silver") translate([body_x,0,motor_ear_z-motor_body_h]) cylinder(d=28,h=motor_body_h);
 color("silver") translate([motor_x,0,motor_ear_z]) cylinder(d=5,h=10);
 color("#286caa") translate([body_x-17,-8,4]) cube([6,16,14]);
 color("silver") for(y=[-17.5,17.5]) translate([body_x,y,motor_ear_z]) cylinder(d=7,h=.8);
 color("#226b45") translate([-44,-35,3.6]) cube([32,35,12]);
 color("#293943") translate([-38,12,3.6]) cube([26,20,8]);
 color("#333333") {
  translate([0,-43,floor_t+2.1]) rotate([90,0,0]) cylinder(d=3.5,h=13.2);
  translate([0,-56.2,floor_t+2.1]) cylinder(d=3.5,h=30-floor_t-2.1);
  translate([0,-56.2,30]) rotate([90,0,0]) cylinder(d=3.5,h=19);
 }
}
module assembly(ex=0){
 color("#c5c9ca") difference(){base_part();if(cutaway)translate([-70,-70,10])cube([140,70,40]);}
 color("#e3ad49") translate([motor_x,0,gear_z]) rotate(spin_a*ring_teeth/pinion_teeth) pinion_part();
 color("#ded5c1") translate([0,0,2*ex]) rotate(spin_a) platter_world();
 color("#777777") translate([0,-48,5]) cable_clamp();
 if(show_hardware) hardware();
}
if(part=="assembly") assembly();
else if(part=="exploded") assembly(28);
else if(part=="base") base_part();
else if(part=="platter") translate([0,0,face_z+face_t]) rotate([180,0,0]) platter_world();
else if(part=="pinion") pinion_part();
else if(part=="cable_clamp") cable_clamp();
else if(part=="print_layout"){
 translate([-65,-65]) base_part();
 translate([-65,65,face_z+face_t]) rotate([180,0,0]) platter_world();
 translate([43,45]) pinion_part(); translate([45,72]) cable_clamp();
}
else if(part=="inspection") {}
else assert(false,"Unknown part");
