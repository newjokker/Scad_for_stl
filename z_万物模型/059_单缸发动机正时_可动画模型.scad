/* 单缸四冲程发动机正时演示 / FOUR-STROKE TIMING DEMO — mm
   “延时”按“正时”理解。曲轴 720° 一循环，凸轮轴 360° 一循环。
   animate=true 后：OpenSCAD View > Animate，Steps=144，FPS=24。
   part 可切换装配、平铺和各零件；这是低速手摇运动学展示模型。 */
$fn=48;
part="assembly"; // [assembly,print_layout,block,crank,piston,conrod,camshaft,valve,pulley_small,pulley_large]
animate=false;
frame=animate ? 720*$t : 136;
fit=.30; crank_r=22; rod_l=66; crank_z=38; cyl_r=27; deck_z=122; shaft_d=5;
show_cutaway=true;
function wrap(a)=((a%360)+360)%360;
function pulse(a,start,width)=let(t=wrap(a-start)) t<width ? (1-cos(360*t/width))/2 : 0;
function intake_lift(a)=7*pulse(a,350,205);
function exhaust_lift(a)=7*pulse(a,145,190);
function cy(a)=crank_r*sin(a);
function cpz(a)=crank_z+crank_r*cos(a);
function pz(a)=cpz(a)+sqrt(rod_l*rod_l-cy(a)*cy(a));
function cam(a)=a/2;
module axle_x(d,l){rotate([0,90,0])cylinder(d=d,h=l,center=true);}
module rr(w,h,r){hull()for(x=[-w/2+r,w/2-r],y=[-h/2+r,h/2-r])translate([x,y])circle(r=r);}
module rod(a,b,r=3){
 d=[b[0]-a[0],b[1]-a[1],b[2]-a[2]];l=sqrt(d[0]*d[0]+d[1]*d[1]+d[2]*d[2]);
 translate(a)rotate([0,acos(d[2]/l),atan2(d[1],d[0])])cylinder(r=r,h=l);
}
module gear(teeth,r,t){union(){cylinder(r=r-2,h=t,center=true);for(i=[0:teeth-1])rotate(i*360/teeth)translate([r-1,0])cube([5,4.6,t],center=true);}}
module pulley(teeth,r,t){difference(){gear(teeth,r,t);cylinder(d=shaft_d+2*fit,h=t+1,center=true);}}
module block(){
 difference(){
  union(){translate([0,0,80])cube([62,58,88],center=true);translate([0,0,crank_z])cylinder(r=39,h=62,center=true);translate([0,0,deck_z+14])cube([62,58,14],center=true);}
  translate([0,0,92])cylinder(r=cyl_r,h=75,center=true);
  if(show_cutaway)translate([-35,-34,20])cube([70,34,125]);
  axle_x(shaft_d+2*fit,70);
  for(x=[-14,14])translate([x,0,deck_z+8])cylinder(d=5.4+2*fit,h=32,center=true);
  translate([0,0,deck_z+12])cylinder(d=7,h=30);
 }
 for(x=[-24,24],y=[-21,21])translate([x,y,deck_z+21])cylinder(d=6,h=6);
}
module crank(a=frame){
 union(){axle_x(shaft_d,76);
  for(x=[-13,13])hull(){translate([x,0,crank_z])rotate([0,90,0])cylinder(r=7,h=5,center=true);translate([x,cy(a),cpz(a)])rotate([0,90,0])cylinder(r=6,h=5,center=true);}
  translate([0,cy(a),cpz(a)])axle_x(7,34);
  translate([39,0,crank_z])rotate([0,90,0])cylinder(r=17,h=5,center=true);
 }}
module piston(a=frame){z=pz(a);union(){translate([0,0,z])cylinder(r=cyl_r-1.3,h=16,center=true);for(dz=[-5,0,5])translate([0,0,z+dz])cylinder(r=cyl_r-.4,h=1.1,center=true);translate([0,0,z-6])axle_x(7,49);}}
module conrod(a=frame){p1=[0,cy(a),cpz(a)];p2=[0,0,pz(a)-6];union(){rod(p1,p2,4);translate(p1)axle_x(11,9);translate(p2)axle_x(12,9);}}
module camshaft(a=frame){ca=cam(a);union(){translate([0,0,deck_z+27])axle_x(shaft_d,80);for(x=[-14,14])translate([x,0,deck_z+27])rotate([0,90,ca+(x<0?0:180)])rotate_extrude()polygon([[4,0],[9,0],[12,3],[9,6],[4,6]]);}}
module valve(x,lift=0){union(){translate([x,0,deck_z+4-lift])cylinder(d=4.8,h=35);translate([x,0,deck_z-lift])cylinder(d1=13,d2=8,h=4);translate([x,0,deck_z+28-lift])difference(){cylinder(d=12,h=3);cylinder(d=5.3,h=4);}}}
module timing_belt(a=frame){
 translate([-37,0,crank_z])rotate([0,90,0])pulley(18,15,6);
 translate([-37,0,deck_z+27])rotate([0,90,0])rotate([0,0,-cam(a)])pulley(36,30,6);
 for(y=[-15,15])translate([-37,y,(crank_z+deck_z+27)/2])cube([6,3,deck_z+27-crank_z],center=true);
}
module assembly(){
 color([.18,.22,.28,.72])block(); color("#565e68")crank();color("#d6a747")conrod();color("#aab6c2")piston();color("#4b91af")camshaft();
 color("#df7254")valve(-14,intake_lift(cam(frame)));color("#c64f4c")valve(14,exhaust_lift(cam(frame)));color("#22262b")timing_belt();
 color("#f3f0e6")translate([0,0,deck_z+25])cylinder(d=8,h=14);
}
module print_layout(){
 translate([-80,0,39])block();translate([22,-40,0])crank(0);translate([28,28,0])piston(0);translate([72,28,0])conrod(0);
 translate([75,-28,0])camshaft(0);translate([110,0,0])pulley(18,15,6);translate([110,42,0])pulley(36,30,6);
 for(x=[90,102])translate([x,70,0])valve(0,0);
}
if(part=="assembly")assembly();else if(part=="print_layout")print_layout();else if(part=="block")block();else if(part=="crank")crank(0);else if(part=="piston")piston(0);else if(part=="conrod")conrod(0);else if(part=="camshaft")camshaft(0);else if(part=="valve")valve(0,0);else if(part=="pulley_small")pulley(18,15,6);else if(part=="pulley_large")pulley(36,30,6);else assert(false,"Unknown part");
