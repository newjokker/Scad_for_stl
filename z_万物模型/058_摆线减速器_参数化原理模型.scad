/*
  摆线减速器 / CYCLOIDAL REDUCER — 参数化可视原理模型
  用离散数学曲线生成摆线转子、销针环与输出孔阵列；换针数、偏心量后，所有零件同步改形。
  本文件是低速手转演示版：输出 pin / rotor / housing 单独导出，建议 PETG 或 PLA+。
*/
$fn=64;
part="assembly"; // [assembly,print_layout,housing,rotor,output_disc,pin]
fit=.28;
pins=11;                 // 销针数；转子拥有 pins-1 个波瓣，理论减速比为 pins-1
pin_circle=38;
pin_d=5.6;
ecc=2.15;
rotor_t=7;
housing_t=8;
phase=22;

function cyc_pt(t) = [
 (pin_circle-pin_d/2-fit)*cos(t)-ecc*cos(pins*t),
 (pin_circle-pin_d/2-fit)*sin(t)-ecc*sin(pins*t)
];
module cyc_profile(){ polygon([for(k=[0:360]) cyc_pt(k)]); }
module rr(w,h,r){ hull() for(x=[-w/2+r,w/2-r],y=[-h/2+r,h/2-r]) translate([x,y]) circle(r=r); }
module slot(d,l){ hull(){translate([-l/2,0])circle(d=d);translate([l/2,0])circle(d=d);} }

module housing(){
 difference(){
  union(){
   linear_extrude(housing_t) difference(){ circle(r=55); circle(r=48); }
   // 三个腿耳，方便用螺丝固定在展示底板上
   for(a=[0:120:359]) rotate(a) translate([61,0]) linear_extrude(housing_t) rr(16,13,4);
  }
  for(a=[0:360/pins:359]) rotate(a) translate([pin_circle,0,-.1]) cylinder(d=pin_d+2*fit,h=housing_t+1);
  for(a=[0:120:359]) rotate(a) translate([61,0,-.1]) cylinder(d=3.4,h=housing_t+1);
 }
}
module rotor(){
 difference(){
  linear_extrude(rotor_t) cyc_profile();
  // 偏心输入孔；不用花键，直接用 M4 螺栓或 4 mm 打印轴即可。
  translate([ecc,0,-.1]) cylinder(d=4.4+2*fit,h=rotor_t+1);
  // 六个输出孔：随转子绕行时带动输出盘。
  for(a=[0:60:359]) rotate(a) translate([22,0,-.1]) cylinder(d=4.2+2*fit,h=rotor_t+1);
  // 观察窗把摆线波瓣的相对运动露出来
  for(a=[30:60:359]) rotate(a) translate([32,0,-.1]) linear_extrude(rotor_t+1) slot(2.1,8);
 }
}
module output_disc(){
 difference(){
  linear_extrude(5) difference(){circle(r=32);circle(r=8);}
  for(a=[0:60:359]) rotate(a) translate([22,0,-.1]) cylinder(d=3.9+2*fit,h=6);
  // 6 mm 六角轴孔，方便外接手柄或其他打印机构
  translate([0,0,-.1]) cylinder(r=4.1,h=6,$fn=6);
 }
}
module pin(){ union(){ cylinder(d=pin_d,h=14); cylinder(d=8,h=1.2); translate([0,0,12.8]) cylinder(d1=pin_d,d2=7.2,h=1.2); } }
module assembly(){
 color("#28313f") housing();
 for(a=[0:360/pins:359]) color("#e6b24e") rotate(a) translate([pin_circle,0,0]) pin();
 color("#4b9ec4") translate([0,0,3]) rotate([0,0,phase]) rotor();
 color("#db6b54") translate([0,0,11]) rotate([0,0,-phase/(pins-1)]) output_disc();
 color("#ddd") translate([ecc,0,-3]) cylinder(d=4,h=20);
}
module print_layout(){
 translate([-61,0,0]) housing();
 translate([47,-30,0]) rotor();
 translate([47,38,0]) output_disc();
 for(x=[-18,-9,0,9,18]) translate([x,-64,0]) pin();
}
if(part=="assembly") assembly();
else if(part=="print_layout") print_layout();
else if(part=="housing") housing();
else if(part=="rotor") rotor();
else if(part=="output_disc") output_disc();
else if(part=="pin") pin();
else assert(false,"Unknown part");
