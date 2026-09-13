/*
  星盘陀螺仪 / ASTROLABE GYROSCOPE — 原创参数化桌面摆件，单位 mm

  一件“看起来很复杂、实际很好打印”的可动星盘：
  - base / crown / orbit / meridian / sky_disc / pin 是独立零件；都平放打印。
  - 用 4 根 print_pin 作轴，孔径由 fit 控制；FDM 建议 fit=0.25~0.35。
  - assembly 是装配预览，print_layout 是一次平铺预览；导出请选单件。
  - 无需支撑；星环如果要转得顺，销轴请横向穿过孔并用少量蜡或硅脂润滑。
*/

$fn = 72;
part = "assembly"; // [assembly,print_layout,base,crown,orbit,meridian,sky_disc,pin]
fit = 0.30;          // FDM 配合间隙，树脂打印可改为 0.12
wall = 3.2;
pin_d = 4;
pin_hole = pin_d + 2*fit;
show_hardware = true;
spin = 18;           // 装配预览姿态
animate = false;
phase = animate ? 360*$t : spin;

// 只用 2D 轮廓 + 拉伸的基础语汇：打印状态天然无支撑。
module annulus(ro,ri){ difference(){ circle(r=ro); circle(r=ri); } }
module rounded_rect(w,h,r){ hull() for(x=[-w/2+r,w/2-r],y=[-h/2+r,h/2-r]) translate([x,y]) circle(r=r); }
module radial_mark(r,a,w=2.2,l=7){ rotate(a) translate([r,0]) square([l,w],center=true); }
module star(r1=7,r2=3.3,n=5){ polygon([for(i=[0:2*n-1]) let(a=90+i*180/n, r=i%2 ? r2:r1) [r*cos(a),r*sin(a)]]); }
module polar_slot(d=pin_hole){ hull(){ translate([-2,0]) circle(d=d); translate([2,0]) circle(d=d); } }
module upright_y(){ rotate([90,0,0]) children(); } // 2D X/Y becomes X/Z, thickness along Y
module upright_x(){ rotate([90,0,90]) children(); } // 2D X/Y becomes Y/Z, thickness along X

// 螺旋展翼底座：通过 hull 的层叠，展示 OpenSCAD 的参数化造型能力。
module base(){
 difference(){
  union(){
   for(z=[0:3:18]) hull(){
    linear_extrude(3) rotate(z*3.2) rounded_rect(110-z*1.15,82-z*.75,15);
    translate([0,0,3]) linear_extrude(.01) rotate((z+3)*3.2) rounded_rect(110-(z+3)*1.15,82-(z+3)*.75,15);
   }
   translate([0,0,18]) linear_extrude(9) annulus(30,22);
  }
  // 内部留空减料，底面保留 2.2 mm
  translate([0,0,2.2]) linear_extrude(18) scale([.88,.82]) rounded_rect(92,64,13);
  // 环形刻度和脚垫孔
  for(a=[0:30:330]) rotate(a) translate([42,0,-.1]) cylinder(d=2.2,h=4);
  for(p=[[-39,-25],[39,-25],[-39,25],[39,25]]) translate([p[0],p[1],-.1]) cylinder(d=8,h=2.3);
 }
 // 底部之上的三片光翼，全部是垂直薄壁但仍由底座承托
 for(a=[0:120:359]) rotate(a) translate([23,0,18]) rotate([0,90,0]) linear_extrude(wall,center=true)
   polygon([[0,0],[18,5],[23,0],[18,-5]]);
}

// 外星环：带齿状光芒、方位刻度和两侧轴孔。
module crown(){
 difference(){
  linear_extrude(wall,center=true) union(){
   annulus(57,51);
   for(a=[0:10:350]) rotate(a) translate([60,0]) square([5,2.2],center=true);
   for(a=[0:45:315]) radial_mark(53.7,a,1.1,7);
   // 两个轴耳，和 ring 同面打印
   for(x=[-1,1]) translate([x*59,0]) rounded_rect(12,14,3);
  }
  for(x=[-1,1]) translate([x*59,0,-wall]) cylinder(d=pin_hole,h=2*wall);
 }
}

// 轨道环：六个“卫星”镂空窗口，图案由旋转阵列生成。
module orbit(){
 difference(){
  linear_extrude(wall,center=true) union(){
   annulus(46,39);
   for(a=[0:60:359]) rotate(a) translate([42.5,0]) circle(r=6.4);
   for(y=[-1,1]) translate([0,y*48]) rounded_rect(14,12,3);
  }
  for(a=[0:60:359]) rotate(a) translate([42.5,0,-wall]) cylinder(d=7.7,h=2*wall);
  for(y=[-1,1]) translate([0,y*48,-wall]) cylinder(d=pin_hole,h=2*wall);
 }
}

// 子午环：四叶镂空与赤道线，轴耳沿 X 方向。
module meridian(){
 difference(){
  linear_extrude(wall,center=true) union(){
   annulus(36,29);
   for(a=[45:90:315]) rotate(a) translate([32.5,0]) circle(r=5.5);
   for(x=[-1,1]) translate([x*38,0]) rounded_rect(12,14,3);
  }
  for(a=[45:90:315]) rotate(a) translate([32.5,0,-wall]) cylinder(d=6.7,h=2*wall);
  for(x=[-1,1]) translate([x*38,0,-wall]) cylinder(d=pin_hole,h=2*wall);
 }
}

// 天空盘：镂空星座、螺旋星点和中心轴；可换双色线材打印。
module sky_disc(){
 difference(){
  linear_extrude(wall,center=true) union(){
   annulus(27,3.2);
   for(a=[0:60:359]) rotate(a) translate([21,0]) star(4.2,1.9,5);
  }
  cylinder(d=pin_hole,h=2*wall);
  for(i=[0:13]) let(a=i*137.508, r=6+i*1.38) translate([r*cos(a),r*sin(a),-wall]) cylinder(d=(i%3==0?2.5:1.45),h=2*wall);
  // 三条星座连线，切成轻盈的负空间
  for(a=[18,138,258]) rotate(a) translate([11,0,-wall]) cube([17,1.35,2*wall]);
 }
}

// 轴销带止退帽；打印时横放会影响强度，因此按图竖放，并通过 brim 增强附着。
module print_pin(){
 union(){
  cylinder(d=pin_d,h=16);
  cylinder(d=8,h=1.6);
  translate([0,0,14.4]) cylinder(d1=pin_d,d2=6.4,h=1.6);
 }
}

// 装配：三个正交转轴形成可以把玩的万向星盘。
module assembly(){
 color("#303948") base();
 // crown: XZ 平面，底部插入基座的中心环，作为视觉主环
 color("#d5a648") translate([0,0,69]) rotate([0,0,phase*.18]) upright_y() crown();
 // orbit: YZ 平面，嵌在 crown 内，以 X 轴为转轴
 color("#4c9ab3") translate([0,0,69]) rotate([0,phase*.42,0]) upright_x() orbit();
 // meridian 回到 XZ 平面，嵌在 orbit 内
 color("#d9644a") translate([0,0,69]) rotate([0,0,-phase*.65]) upright_y() meridian();
 color("#f0e5bf") translate([0,0,69]) rotate([phase*.8,0,0]) sky_disc();
 if(show_hardware){
  color("#1b2028") translate([0,0,69]) rotate([90,0,0]) cylinder(d=pin_d,h=125,center=true);
  color("#1b2028") translate([0,0,69]) rotate([0,90,0]) cylinder(d=pin_d,h=102,center=true);
 }
}

module print_layout(){
 translate([-66,-58,0]) base();
 translate([45,-48,wall/2]) crown();
 translate([-43,56,wall/2]) orbit();
 translate([43,49,wall/2]) meridian();
 translate([0,94,wall/2]) sky_disc();
 for(x=[-14,-7,7,14]) translate([x,120,0]) print_pin();
}

if(part=="assembly") assembly();
else if(part=="print_layout") print_layout();
else if(part=="base") base();
else if(part=="crown") crown();
else if(part=="orbit") orbit();
else if(part=="meridian") meridian();
else if(part=="sky_disc") sky_disc();
else if(part=="pin") print_pin();
else assert(false,"Unknown part");
