/* 双曲面水果篮 / HYPERBOLOID FRUIT BOWL — OpenSCAD 参数化直纹面
   双曲面看似曲面，实际上可由两组直线生成；改变 twist 或 ribs 会立刻重建。
   直径约 170 mm，高 63 mm。竖放打印，肋条从底圈直达上圈，通常无需支撑。 */
$fn=48;
part="full"; // [full,small,flat_reference]
ribs=30;              // 两组各 ribs 条，建议偶数 24~40
twist=57;              // 顶圈相对于底圈的扭角
bottom_r=30;
top_r=82;
height=58;
rod_r=2.25;
rim_r=3.1;

module torus(R,r){ rotate_extrude(convexity=6) translate([R,0]) circle(r=r); }
module rod(a,b,r=rod_r){
 d=[b[0]-a[0],b[1]-a[1],b[2]-a[2]];
 l=sqrt(d[0]*d[0]+d[1]*d[1]+d[2]*d[2]);
 translate(a) rotate([0,acos(d[2]/l),atan2(d[1],d[0])]) cylinder(r=r,h=l);
}
module lattice(scale_all=1){
 br=bottom_r*scale_all; tr=top_r*scale_all; h=height*scale_all; rr=rod_r*scale_all;
 union(){
  translate([0,0,rr]) torus(br,rr*1.18);
  translate([0,0,h]) torus(tr,rim_r*scale_all);
  // 双曲面的两族母线：每一根都是直线，但整体呈连续的扭曲曲面。
  for(i=[0:ribs-1]) let(a=i*360/ribs)
   rod([br*cos(a),br*sin(a),rr],[tr*cos(a+twist),tr*sin(a+twist),h],rr);
  for(i=[0:ribs-1]) let(a=i*360/ribs)
   rod([br*cos(a),br*sin(a),rr],[tr*cos(a-twist),tr*sin(a-twist),h],rr);
  // 三个脚点，让果篮底面稳定且显得像悬浮的网格。
  for(a=[0:120:359]) rotate(a) translate([br,0,0]) cylinder(r=5*scale_all,h=rr*1.2);
 }
}
module flat_reference(){
 linear_extrude(2) for(i=[0:ribs-1]) rotate(i*360/ribs) translate([bottom_r,0]) square([top_r-bottom_r,1],center=true);
}
if(part=="full") lattice();
else if(part=="small") lattice(.62);
else if(part=="flat_reference") flat_reference();
else assert(false,"Unknown part");
