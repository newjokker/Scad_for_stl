/* 云海偷游 / CLOUD SWIM — 原创单舵机动态桌面摆件，mm
   assembly 装配；print_layout 平铺；base/cloud/frame/whale 单件。
   动画勾选 animate，视图->动画 FPS 30 Steps 180。
   普通180度SG90 + 原装双臂舵盘，不打印花键。所有舵机尺寸需实测。
   四个打印件；螺丝和舵盘连接详见 document/052_云海偷游/说明.md。
   正面为 -Y；二维零件坐标为 X/高度，平铺时厚度沿 Z。
*/
$fn=64;
part="assembly"; // [assembly,print_layout,base,cloud,frame,whale]
animate=false;
pose=24; // [-28:28]
show_hardware=true;
servo_l=23;
servo_w=12.2;
servo_ear_spacing=28;
axis_offset=5.5; // 输出轴相对机身中心向左偏置
servo_clearance=0.6;
fit=0.35;
frame_y=8;
horn_y=-4; // 舵盘与打印鲸鱼的接触面，按实际舵机调整
pivot_z=59;
angle=animate ? 28*sin(360*$t) : pose;
assert(abs(angle)<=28);
assert(horn_y<=-3 && horn_y>=-7,"Keep whale between cloud and frame");
module rr(w,h,r){ hull() for(x=[-w/2+r,w/2-r],y=[-h/2+r,h/2-r]) translate([x,y]) circle(r=r); }
module slot(d,a,b){ hull(){translate(a) circle(d=d);translate(b) circle(d=d);} }
// 2D x/height -> upright, thickness points towards viewer (-Y)
module upright(y=0){translate([0,y,0]) rotate([90,0,0]) children();}
module base(){
 difference(){
  union(){linear_extrude(7) rr(156,80,16);
   translate([0,0,7]) linear_extrude(12) difference(){rr(156,80,16);rr(150,74,13);}
  }
  for(x=[-52,52]) translate([x,-24,2.9]) cube([10+fit,4+fit,4.2],center=false);
  for(x=[-18,18]) translate([x-5,frame_y-4-fit/2,2.9]) cube([10+fit,4+fit,4.2]);
  for(x=[-47,57]) translate([x,-22,-.1]) cylinder(d=3.4,h=8);
  for(x=[-18,18]) translate([x,frame_y-2,-.1]) cylinder(d=3.4,h=8);
  // Rear USB / wire exit
  translate([-7,35,8]) cube([14,8,12]);
  // MCU tie-down slots, compatible with small boards, no fixed PCB hole pattern
  for(x=[-25,25],y=[19,29]) translate([x,y,-.1]) linear_extrude(7.2) rr(3,8,1);
 }
}
module cloud_shape(){
 union(){translate([0,30]) rr(142,46,15);
 for(v=[[-53,48,17],[-30,59,22],[0,56,24],[29,61,22],[54,49,17]]) translate([v[0],v[1]]) circle(r=v[2]);}
}
module cloud(){
 difference(){
 union(){linear_extrude(4) cloud_shape();
  for(x=[-47,57]) translate([x-5,3,0]) cube([10,15,4]);
 }
 for(x=[-47,57]) translate([x,2.9,2]) rotate([-90,0,0]) cylinder(d=2.5,h=13);
 // Shallow cloud curls on front, paint grooves if desired
 for(v=[[-40,49],[16,48],[48,36]]) translate([v[0],v[1],3.2]) linear_extrude(1)
 difference(){circle(r=8);circle(r=6.8);translate([-10,-10]) square([20,10]);}
 }
}
module frame(){
 difference(){
  linear_extrude(4) union(){
   translate([0,32]) rr(48,50,5);
   translate([axis_offset,pivot_z]) rr(44,29,4);
   for(x=[-18,18]) translate([x-5,3]) square([10,16]);
  }
  translate([axis_offset,pivot_z,-.1]) linear_extrude(4.2) square([servo_l+servo_clearance,servo_w+servo_clearance],center=true);
  for(s=[-1,1]) translate([axis_offset+s*servo_ear_spacing/2,pivot_z,-.1]) linear_extrude(4.2) slot(2.3,[0,-1],[0,1]);
  for(x=[-18,18]) translate([x,2.9,2]) rotate([-90,0,0]) cylinder(d=2.5,h=13);
 }
}
module whale_outline(){
 union(){
  scale([1.75,1]) circle(r=13);
  polygon([[-15,-6],[-33,1],[-39,13],[-29,10],[-24,5],[-23,16],[-17,11],[-18,2]]);
  polygon([[-2,-7],[8,-19],[12,-14],[9,-5]]);
 }
}
module whale(){
 difference(){
  linear_extrude(3) union(){
   circle(r=13);
   hull(){circle(r=4);translate([32,31]) circle(r=5);}
   translate([32,31]) whale_outline();
  }
  translate([0,0,-.1]) cylinder(d=5,h=3.2); // 舵盘中心螺丝工具口
  for(s=[-1,1]) translate([0,0,-.1]) linear_extrude(3.2) slot(2.3,[s*7,0],[s*10,0]);
  translate([45,34,2.1]) cylinder(d=2.8,h=1); // eye recessed on visible side
  translate([46,27,2.1]) linear_extrude(1) slot(.9,[-3,0],[1,1]);
 }
}
module hardware(){
 // Non-exported indicative SG90 body; ears on rear face of frame.
 color([.15,.3,.7,.6]) translate([axis_offset-servo_l/2,frame_y,pivot_z-servo_w/2]) cube([servo_l,23,servo_w]);
 color("white") upright(horn_y+2) translate([0,pivot_z]) linear_extrude(2) slot(5,[-11,0],[11,0]);
 color("silver") translate([0,horn_y+2,pivot_z]) rotate([-90,0,0]) cylinder(d=4.5,h=frame_y-horn_y);
 color([.1,.4,.3]) translate([-22,17,8]) cube([44,18,2]);
}
module assembly(){
 color("#d4b48b") base();
 color("#e9edef") upright(-20) cloud();
 color("#738a9a") upright(frame_y) frame();
 color("#388f9e") upright(horn_y) translate([0,pivot_z]) rotate([0,0,angle]) whale();
 if(show_hardware) hardware();
}
if(part=="assembly") assembly();
else if(part=="base") base();
else if(part=="cloud") cloud();
else if(part=="frame") frame();
else if(part=="whale") whale();
else if(part=="print_layout"){
 translate([0,-46,0]) base();
 translate([0,2,0]) cloud();
 translate([-49,99,0]) frame();
 translate([12,117,0]) whale();
}
else assert(false,"Unknown part");
