/* 模块化参数化波纹声学墙板 / MODULAR WAVE-SLAT WALL TILE — mm
   灵感：参数化木条墙、几何开槽吸音面板和嵌入式氛围灯。
   3D 打印件本身负责立体扩散/装饰；把 9~12 mm PET 吸音毡或泡棉贴到背后，开槽才会让声波进入背衬。
   默认 180 mm 模块可拼成 2x2 或 3x3；variant_x / variant_y 让波纹在相邻砖间连续。
   part: tile 成品；print_layout 打印朝向；key 连接键；felt_template 背衬裁剪轮廓。 */
$fn=32;
part="tile"; // [tile,print_layout,key,felt_template]
tile=180; frame=8; back_t=2.8; slat_w=5.2; pitch=10; rows=17; cols=17;
min_relief=4; relief_range=15; air_slot=4.8; variant_x=0; variant_y=0;
key_fit=.28; led_channel=true;
function wave(i,j)=
 let(x=(i+variant_x*(cols-1))/(cols-1),y=(j+variant_y*(rows-1))/(rows-1))
 min_relief+relief_range*(.5+.25*sin(360*(1.15*x+.38*y))+.25*cos(360*(.28*x-1.05*y)));
module rr2d(w,h,r){hull()for(x=[-w/2+r,w/2-r],y=[-h/2+r,h/2-r])translate([x,y])circle(r=r);}
module keyhole_2d(){hull(){circle(d=4.8);translate([0,8])circle(d=8.4);}}
module join_key(){linear_extrude(2.8)hull(){translate([-7,0])circle(r=3.3);translate([7,0])circle(r=3.3);}}
module panel_base(){
 difference(){
  linear_extrude(back_t)rr2d(tile,tile,13);
  // 4 个沉头壁挂孔；安装后被相邻的可拆连接键遮挡。
  for(x=[-tile/2+12,tile/2-12],y=[-tile/2+12,tile/2-12])
   translate([x,y,-.1]){cylinder(d=4.2,h=back_t+.2);translate([0,0,back_t-1.3])cylinder(d1=4.2,d2=9,h=1.5);}
  // 背面为吸音背衬保留的空气口：不影响外围框架。
  for(y=[-62:31:62])for(x=[-62:31:62])translate([x,y,-.1])linear_extrude(back_t+.2)rr2d(18,18,3);
 }
}
module slat_cell(i,j){
 x=-tile/2+frame+(i+.5)*(tile-2*frame)/cols;
 y=-tile/2+frame+(j+.5)*(tile-2*frame)/rows;
 w=(tile-2*frame)/cols-air_slot;
 h=(tile-2*frame)/rows-air_slot;
 // 每个单元高度由二维 Fourier 波场确定，拼接后形成连续“地形条板”。
 translate([x,y,back_t-.05])linear_extrude(wave(i,j)+.05)rr2d(w,h,1.1);
}
module front_slats(){for(j=[0:rows-1])for(i=[0:cols-1])slat_cell(i,j);}
module led_grooves(){
 // 对角双灯槽：5 mm LED 灯带可从侧面滑入；槽口向外，避免悬空顶面。
 if(led_channel)for(a=[45,135])rotate(a)translate([0,0,back_t+3])
  difference(){linear_extrude(4)rr2d(tile*1.08,7.4,2);translate([0,0,-.1])linear_extrude(5)rr2d(tile*1.08,5.1,1.4);}
}
module tile_full(){union(){panel_base();front_slats();led_grooves();}}
module felt_template(){linear_extrude(.4)rr2d(tile-2*frame-3,tile-2*frame-3,8);}
module print_layout(){tile_full();translate([0,-tile/2-16,0])join_key();translate([0,tile/2+16,0])join_key();}
if(part=="tile")tile_full();else if(part=="print_layout")print_layout();else if(part=="key")join_key();else if(part=="felt_template")felt_template();else assert(false,"Unknown part");
