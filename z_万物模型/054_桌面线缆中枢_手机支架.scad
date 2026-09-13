/*
  桌面线缆中枢 / DESK CABLE HUB — 原创实用 3D 打印件，mm

  用途：一个手机充电支架 + 线缆停靠位 + SD/microSD/U 盘收纳盘。
  所有件均无需支撑：base、phone_back、front_lip、cable_clip 都平放打印。
  组装：phone_back 的两个榫舌压入 base 后槽，front_lip 压入前槽；
        cable_clip 可直接粘在底座上，或压入上方的 T 槽。
  part: assembly / print_layout / base / phone_back / front_lip / cable_clip
*/

$fn = 48;
part = "assembly"; // [assembly,print_layout,base,phone_back,front_lip,cable_clip]
fit = 0.28;         // FDM 推荐 0.25~0.35；树脂改 0.12
phone_w = 86;       // 最大手机宽度（含壳）
back_h = 116;
plate_t = 4.4;
base_w = 168;
base_d = 96;
base_t = 5.2;
show_phone = true;

module rr(w,h,r){ hull() for(x=[-w/2+r,w/2-r], y=[-h/2+r,h/2-r]) translate([x,y]) circle(r=r); }
module slot2d(w,l){ hull(){ translate([-l/2,0]) circle(d=w); translate([l/2,0]) circle(d=w); } }
module t_slot_2d(){ union(){ square([8+2*fit,10],center=true); translate([0,5]) square([14+2*fit,4],center=true); } }
module t_male_2d(){ union(){ square([7.4,9.4],center=true); translate([0,4.7]) square([13.2,3.4],center=true); } }
module dovetail_male(){ polygon([[-8,0],[8,0],[5,10],[-5,10]]); }
module dovetail_female(){ offset(delta=fit) dovetail_male(); }

// 底座：前为收纳盘，后为手机板榫槽；圆角、倒角和镂空同时节省耗材。
module base(){
 difference(){
  union(){
   linear_extrude(base_t) rr(base_w,base_d,15);
   // 两条用于收纳卡片的低矮分隔筋
   for(x=[-23,23]) translate([x,-19,base_t]) cube([2.6,42,4]);
   // 后方横梁提高插接区刚度
   translate([0,31,base_t]) linear_extrude(8) rr(base_w-26,13,4);
  }
  // 底面材料减重口袋：保留四周和中间承力筋
  translate([0,-8,2.2]) linear_extrude(4) difference(){ rr(base_w-20,base_d-22,12); rr(base_w-33,base_d-35,9); }
  // 后方两个燕尾插槽，手机背板可拆装
  for(x=[-phone_w*.34,phone_w*.34])
    translate([x,30,base_t]) rotate([90,0,0]) linear_extrude(10) dovetail_female();
  // 前唇插槽
  translate([0,-37,base_t-.1]) linear_extrude(5) slot2d(4.8+2*fit,phone_w-15);
  // 三个卡片浅槽：SD、microSD、U 盘
  for(x=[-55,-43,-30]) translate([x,-9,base_t-1]) cube([7,17,2.2],center=true);
  translate([54,-9,base_t-1]) cube([22,10,2.2],center=true);
  // 侧边五个 T 槽，插入线夹后可任意调整位置
  for(x=[-60,-30,0,30,60]) translate([x,42,base_t-.1]) linear_extrude(7) t_slot_2d();
  // 防滑脚垫凹位
  for(p=[[-67,-34],[67,-34],[-67,34],[67,34]]) translate([p[0],p[1],-.1]) cylinder(d=10,h=2);
 }
 // 小型浮雕标签，切片时可换色暂停
 translate([0,-24,base_t]) linear_extrude(.65) text("DOCK",size=8,halign="center",valign="center",font="Liberation Sans:style=Bold");
}

// 平放打印的手机背板；装配时竖起。蜂窝孔使其看起来精致，也改善散热。
module phone_back(){
 difference(){
  union(){
   linear_extrude(plate_t) rr(phone_w+12,back_h,13);
   // 两个底部燕尾榫舌，在同一平面打印，不牺牲强度
   for(x=[-phone_w*.34,phone_w*.34]) translate([x,-back_h/2-8]) linear_extrude(plate_t) dovetail_male();
  }
  // 充电线窗口：兼容 USB-C / Lightning 线头并可从后侧走线
  translate([0,-back_h/2+18,-.1]) linear_extrude(plate_t+1) slot2d(14,18);
  // 蜂窝散热阵列，避开中线与边缘
  for(y=[-25:14:34], x=[-34:16:34]) translate([x+(floor((y+25)/14)%2)*8,y, -.1])
    linear_extrude(plate_t+1) circle(r=4.3,$fn=6);
  // 上方提手 / 穿绳孔
  translate([0,back_h/2-13,-.1]) linear_extrude(plate_t+1) slot2d(7,20);
 }
 // 背面两条纵向加强筋，装配后朝后，不影响手机贴合面
 for(x=[-phone_w/2+9,phone_w/2-9]) translate([x,-3,plate_t]) cube([3.2,back_h-30,6],center=true);
}

// 前唇承担手机重量，带线缆槽；平放打印，压入底座即可。
module front_lip(){
 difference(){
  union(){
   linear_extrude(12) rr(phone_w-14,6,2.8);
   translate([0,0,11]) linear_extrude(7) rr(phone_w-14,6,2.8);
  }
  // 中央开口允许充电线在手机底部直插
  translate([0,0,8]) cube([19,12,14],center=true);
  // 左右两条线槽，耳机/手表线也能在此停靠
  for(x=[-28,28]) translate([x,0,14]) rotate([90,0,0]) cylinder(d=5.2,h=12,center=true);
 }
}

// 独立线夹：C 形开口可夹 3~6 mm 常用数据线，底部 T 榫插在 base 后边。
module cable_clip(){
 difference(){
  union(){
   linear_extrude(7) difference(){ circle(r=8); circle(r=4.2); translate([4,-3]) square([6,6]); }
   translate([0,-12]) linear_extrude(7) t_male_2d();
  }
  // 让入口有弹性，线从右侧压入
  translate([4,-2,-.1]) cube([5,4,8]);
 }
}

module assembly(){
 color("#253247") base();
 // 背板旋转到竖直方向；底端与底座后槽定位
 color("#5d9ec7") translate([0,30,base_t+66]) rotate([90,0,0]) phone_back();
 color("#e4a64a") translate([0,-37,base_t]) front_lip();
 for(x=[-60,-30,0,30,60]) color("#e4a64a") translate([x,42,base_t]) cable_clip();
 if(show_phone) color([.08,.1,.13,.55]) translate([0,8,31]) rotate([12,0,0]) cube([phone_w-4,8,154],center=true);
}

module print_layout(){
 translate([-45,-58,0]) base();
 translate([76,-5,plate_t/2]) phone_back();
 translate([0,65,0]) front_lip();
 for(x=[-42,-21,0,21,42]) translate([x,87,0]) cable_clip();
}

if(part=="assembly") assembly();
else if(part=="print_layout") print_layout();
else if(part=="base") base();
else if(part=="phone_back") phone_back();
else if(part=="front_lip") front_lip();
else if(part=="cable_clip") cable_clip();
else assert(false,"Unknown part");
