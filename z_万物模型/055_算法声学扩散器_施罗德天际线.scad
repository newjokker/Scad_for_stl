/*
  算法声学扩散器 / SCHROEDER SKYLINE DIFFUSER — 单位 mm

  这是一个适合 OpenSCAD 的“代码即几何”模型：169 个高低不同的扩散井，
  完全由二次剩余序列自动生成。传统 CAD 要逐一建立、标注、改高度；这里
  修改 order / cell / levels 即可立刻得到另一块严格遵循同一数学规则的面板。

  原理：二维 Skyline diffuser 的高度取自 q(i,j)=[i²+3j²] mod P。
  不同深度使反射声产生不同相位，打散高频反射；它也是很好的桌面背景板。
  注意：实际声学效果取决于尺寸、安装面和房间；此模型主要针对中高频散射。

  打印：默认 169 x 169 x 66 mm，一体竖直柱，无需支撑。
  part="full" 全板；"sample" 输出 5x5 小样供试色与校准；"flat_map" 是高度地图。
*/

$fn = 18;
part = "full";                 // [full,sample,flat_map]
prime = 13;                     // 建议素数：7, 11, 13, 17
cell = 12;                      // 单元节距；13 时整板为 193 mm
gap = 1.15;                     // 单元之间的声学缝 / 视觉阴影线
levels = 9;                     // 高度离散级数，通常 5~11
step_h = 6.8;                   // 每一相位台阶高度
base_h = 4.2;
edge = 5.5;
corner_r = 1.35;
show_reference_grid = false;    // 仅预览用的半透明高度标记

// 二次剩余高度场；prime 改为任意素数时，整个结构保持数学自洽。
function residue(i,j) = ((i*i + 3*j*j + 2*i*j) % prime + prime) % prime;
function level(i,j) = residue(i,j) % levels;
function well_h(i,j) = base_h + 3 + level(i,j)*step_h;
function panel_size(n=prime) = n*cell + 2*edge;

module rr2d(w,h,r){ hull() for(x=[-w/2+r,w/2-r],y=[-h/2+r,h/2-r]) translate([x,y]) circle(r=r); }
module bevel_block(w,h,z,bevel=0.7){
 // 三段 taper 形成无需支撑的小倒角；比纯方柱更有“计算地形”质感。
 hull(){
  linear_extrude(.01) rr2d(w-2*bevel,h-2*bevel,corner_r);
  translate([0,0,bevel]) linear_extrude(.01) rr2d(w,h,corner_r);
 }
 translate([0,0,bevel]) linear_extrude(max(.1,z-2*bevel)) rr2d(w,h,corner_r);
 hull(){
  translate([0,0,z-bevel]) linear_extrude(.01) rr2d(w,h,corner_r);
  translate([0,0,z]) linear_extrude(.01) rr2d(w-2*bevel,h-2*bevel,corner_r);
 }
}

module base_plate(n=prime){
 s=panel_size(n);
 difference(){
  linear_extrude(base_h) rr2d(s,s,edge);
  // 四个背面脚垫凹位；不影响平整摆放，且省下少量材料。
  for(x=[-s/2+13,s/2-13],y=[-s/2+13,s/2-13]) translate([x,y,-.1]) cylinder(d=9,h=1.4);
  // 悬挂孔（可选择穿过，适合做墙面声学板）
  for(x=[-s/2+11,s/2-11]) translate([x,s/2-11,-.1]) cylinder(d=3.6,h=base_h+1);
 }
}

module skyline(n=prime, offset_i=0, offset_j=0){
 for(j=[0:n-1]) for(i=[0:n-1])
  let(x=(i-(n-1)/2)*cell, y=(j-(n-1)/2)*cell, z=well_h(i+offset_i,j+offset_j))
   // 0.08 mm 交叠保证导出为单一实体，而不是与底板仅共面的 169 个孤岛。
   translate([x,y,base_h-.08]) bevel_block(cell-gap,cell-gap,z-base_h+.08);
}

// 仅在 F5 预览中使用：高度刻度让算法序列一目了然，不参与 STL 导出。
module reference_grid(n=prime){
 if(show_reference_grid)
  for(j=[0:n-1]) for(i=[0:n-1])
   color([.18,.75,.95,.22]) translate([(i-(n-1)/2)*cell,(j-(n-1)/2)*cell,well_h(i,j)+.1])
     linear_extrude(.12) text(str(level(i,j)),size=3.1,halign="center",valign="center");
}

module full_panel(){
 union(){
  base_plate(); skyline();
  // 正面角标：让成品保留它的算法身份证，切片可在此暂停换色。
  s=panel_size();
  translate([-s/2+13,-s/2+10,base_h-.05]) linear_extrude(.65)
   text(str("QR-",prime," / ",levels," LEVEL"),size=4.3,halign="left",valign="center",font="Liberation Sans:style=Bold");
  reference_grid();
 }
}

module sample(){
 n=5;
 s=panel_size(n);
 union(){
  base_plate(n); skyline(n,4,7);
  translate([0,-s/2+9,base_h-.05]) linear_extrude(.65)
   text("QRD SAMPLE",size=4,halign="center",valign="center",font="Liberation Sans:style=Bold");
 }
}

// 低矮版高度地图：适合先观察图案，或做杯垫 / 墙面装饰。
module flat_map(){
 union(){
  base_plate();
  for(j=[0:prime-1]) for(i=[0:prime-1])
   translate([(i-(prime-1)/2)*cell,(j-(prime-1)/2)*cell,base_h-.08])
     bevel_block(cell-gap,cell-gap,1.28+level(i,j)*1.1,.45);
 }
}

if(part=="full") full_panel();
else if(part=="sample") sample();
else if(part=="flat_map") flat_map();
else assert(false,"Unknown part");
