/* 斐波那契亥姆霍兹共鸣花墙 / FIBONACCI HELMHOLTZ BLOOM — mm
   21 个空心共鸣腔按黄金角排布，既是壁挂装饰，也是分散调谐的亥姆霍兹共鸣器阵列。
   每个“花瓣”只有一个前向颈口；腔体必须气密（建议 3+ 圈壁、0% 填充）才有共鸣效果。
   适合中高频的局部处理/桌面摆件；实际共振由打印误差、安装墙面和背腔决定。
   part: full 壁挂成品；sample 7 个试打；pod 单个调音腔。 */
$fn=96;
part="full"; // [full,sample,pod]
wall=1.25; back_t=3.6; board_d=210; pod_count=21; golden=137.507764;
show_frequency_labels=false;
function p_radius(i)=i==0 ? 0 : 14+18*sqrt(i);
function p_angle(i)=i*golden;
function p_x(i)=p_radius(i)*cos(p_angle(i));
function p_y(i)=p_radius(i)*sin(p_angle(i));
function body_d(i)=i==0 ? 44 : 19+5*(i%4);
function neck_d(i)=i==0 ? 9 : 4.5+1.15*(i%4);
function body_depth(i)=i==0 ? 31 : 18+3.2*(i%5);
function neck_l(i)=i==0 ? 12 : 7+2.3*(i%4);
// 近似圆锥台腔体体积，用于提示参数化“调音”关系（单位 Hz；非实验标定）。
function cavity_v(d1,d2,h)=PI*h*(d1*d1+d1*d2+d2*d2)/12;
function approx_hz(i)=343000/(2*PI)*sqrt((PI*neck_d(i)*neck_d(i)/4)/(cavity_v(body_d(i)-2*wall,neck_d(i),body_depth(i))* (neck_l(i)+.85*neck_d(i))));
module rr2d(w,h,r){hull()for(x=[-w/2+r,w/2-r],y=[-h/2+r,h/2-r])translate([x,y])circle(r=r);}
module resonator_pod(i=0){
 d=body_d(i); nd=neck_d(i); dep=body_depth(i); nl=neck_l(i);
 difference(){
  union(){
   // 外层由大口向小口渐缩；竖放打印时斜面自支撑。
   cylinder(d1=d,d2=nd+2*wall,h=dep);
   translate([0,0,dep])cylinder(d=nd+2*wall,h=nl);
   // 花瓣底环让每个腔体自然融入花墙，也增加粘接面积。
   linear_extrude(1.1)rr2d(d+4,d*.48,3);
  }
  // 内腔由前方唯一颈口贯通；保留后壁，与面板贴合后形成密闭空气弹簧。
  translate([0,0,wall])cylinder(d1=d-2*wall,d2=nd,h=dep-wall+.15);
  translate([0,0,dep-wall])cylinder(d=nd,h=nl+wall+.2);
 }
}
module board(){
 difference(){
  union(){
   cylinder(d=board_d,h=back_t);
   // 12 条向外生长的花蕊/安装加强筋，参数阵列难以手工维护。
   for(a=[0:30:359])rotate(a)translate([board_d*.34,0,back_t])linear_extrude(1.3)rr2d(board_d*.33,3.1,1.2);
  }
  // 三个隐藏式挂孔，使用沉头螺钉或无痕钉。
  for(a=[90,210,330])rotate(a)translate([board_d*.405,0,-.1])cylinder(d=4.2,h=back_t+2);
  // 背面轻量化同心槽，外圈保留连续强度。
  for(r=[34,58,82])translate([0,0,-.1])difference(){cylinder(r=r+2,h=1.4);cylinder(r=r-2,h=1.6);}
 }
}
module full(){
 union(){
  board();
  for(i=[0:pod_count-1])
   translate([p_x(i),p_y(i),back_t-.08])rotate([0,0,p_angle(i)+90])resonator_pod(i);
  if(show_frequency_labels)
   for(i=[0:pod_count-1])color([.1,.8,1,.28])translate([p_x(i),p_y(i),back_t+body_depth(i)+neck_l(i)+.1])linear_extrude(.1)text(str(round(approx_hz(i))),size=3,halign="center",valign="center");
 }
}
module sample(){
 union(){
  linear_extrude(back_t)rr2d(116,92,12);
  for(i=[0:6])translate([-42+(i%4)*28,-18+floor(i/4)*34,back_t-.08])resonator_pod(i+2);
 }
}
if(part=="full")full();else if(part=="sample")sample();else if(part=="pod")resonator_pod(0);else assert(false,"Unknown part");
