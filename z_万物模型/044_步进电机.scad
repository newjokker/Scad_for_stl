/*
  NEMA17 + GT2 (2mm pitch, 6mm belt): 20T -> 60T belt test.
  单位 mm。F5 看装配；修改 part 后 F6 / 导出 STL。
  part: print_layout / assembly / base / big_pulley / axle_mount / axle_cap / stand
  print_layout 平铺打印，所有打印件底面均为 Z=0。assembly 查看装配。
  20T -> 60T，3:1 减速；电机在板下。电机端仍用成品 20T/5mm 锁轴轮。
  大轮改为 8mm 打印轴，孔径 8.35mm；不改变电机端的 5mm 孔径。
  圆形轴座用一颗 M3x25 贯穿螺丝固定：底板下方穿入，顶部用普通 M3 螺母锁紧。
  上下各一片约 0.5mm 厚 M3 平垫片；无需打印螺纹。
  装配：螺丝穿底板中心长孔 -> 圆形轴座 -> 套大轮 -> 顶盖 -> 垫片和螺母。
  顶盖压在轴端，给大轮留 0.4mm 轴向间隙；转动卡滞时修整孔壁。
  打印轴用于低速空载试验，螺丝/螺母、皮带、电机和主动轮使用实物。
  单长孔调节张紧：中心距默认 83mm，可调 ±14mm。松开螺母、移动轴座、再锁紧。
  底板下方必须使用 M3 平垫片跨过长孔；保留单螺丝圆形轴座。
  下方支撑底座 stand：四角立柱+16mm宽/10mm厚底框+中央横梁+四角加强块，板下净高59mm。
  板与底座连接：4 颗 ST4.2x16 盘头自攻螺丝，从板上方直接拧入立柱。
  顶部导孔默认直径 3.4mm、深 13mm；按实际螺丝牙底与打印收缩试配调整 stand_pilot_d。
  电机长度参数 motor_length 默认 40mm；更长电机需增加 stand_h。
  stand 正放打印，立柱顶部盲孔朝上；底部封闭，无螺母窝。手动慢拧避免滑牙。
  GT2 tooth coordinates: droftarts, January 2012, GT2_2mm profile:
  https://github.com/prizos/openscad/blob/master/Pulley_T-MXL-XL-HTD-GT2_N-tooth.scad
*/
$fn = 96;
part = "print_layout"; // [print_layout,assembly,base,big_pulley,axle_mount,axle_cap,stand]
drive_teeth = 20;
driven_teeth = 60;
pitch = 2;
belt_width = 6;
belt_clearance = 0.8;
bore_d = 5;
bore_clearance = 0.25; // 大轮滑动孔直径补偿；按打印机调整
flange_t = 1;
flange_extra = 3;
tooth_width_extra = 0.10;
plate_len = 160;
plate_w = 76;
plate_t = 6;
motor_length = 40;
stand_h = 59; // 底板下表面到桌面的高度
stand_rail = 16; // 底框边梁宽度，原 6mm
stand_floor_t = 10; // 底框厚度，原 5mm
stand_cross_w = 12; // 中间横梁宽度
stand_corner_brace = 10; // 内角三角加强块边长
stand_post_d = 14;
stand_pilot_d = 3.4; // 自攻导孔试配值，按实物和打印机调整
stand_pilot_depth = 13;
stand_screw_d = 4.2;
stand_screw_len = 16;
motor_x = 32;
axis_y = plate_w/2;
center_distance = 83; // 长孔中点对应的中心距
slot_travel = 28; // 螺丝中心可移动总行程，长孔总长为 31.5mm
shaft_offset = 0; // 装配预览位置：-14 到 +14mm
shaft_x = motor_x + center_distance + shaft_offset;
mount_t = 3;
thrust_h = 1; // 轴座自带下止推面，无需额外垫片
printed_axle_d = 8;
axle_clearance = 0.35;
axial_gap = 0.4;
mount_d = 18; // 圆形压紧底座
cap_t = 2;
pulley_z = plate_t + mount_t + thrust_h;
track_h = belt_width + belt_clearance;
pulley_h = 2*flange_t + track_h;
axle_top = mount_t + thrust_h + pulley_h + axial_gap;
belt_z = pulley_z + flange_t + belt_clearance/2;
function pd(n) = n*pitch/PI;
function od(n) = pd(n)-2*0.254;
function belt_length(c) = let(a=pd(drive_teeth)/2,b=pd(driven_teeth)/2,
    theta=asin((b-a)/c)) 2*sqrt(c*c-(b-a)*(b-a)) + PI*(a+b)+2*(b-a)*theta*PI/180;
assert(stand_h > motor_length+stand_floor_t+5, "Increase stand_h for motor / frame clearance");
assert(stand_screw_len > plate_t+5 && stand_screw_len-plate_t < stand_pilot_depth);
assert(stand_pilot_depth < stand_h && stand_pilot_d < stand_screw_d);
assert(2*stand_rail+2*stand_corner_brace < plate_w);
assert(drive_teeth>=16 && driven_teeth>=drive_teeth);
assert(slot_travel >= 0 && abs(shaft_offset) <= slot_travel/2);
assert(center_distance-slot_travel/2 > (pd(drive_teeth)+pd(driven_teeth))/2+3);
assert(motor_x+center_distance+slot_travel/2+(od(driven_teeth)+flange_extra)/2 < plate_len);
assert((od(driven_teeth)+flange_extra)/2 < plate_w/2);
echo(reduction=driven_teeth/drive_teeth, big_pitch_d=pd(driven_teeth),big_tooth_od=od(driven_teeth));
echo(belt_pitch_length=belt_length(center_distance+shaft_offset), center_distance_range=[center_distance-slot_travel/2,center_distance+slot_travel/2]);
echo(belt_length_range=[belt_length(center_distance-slot_travel/2),belt_length(center_distance+slot_travel/2)]);

module base_plate() {
    difference() {
        linear_extrude(plate_t) hull()
            for(x=[6,plate_len-6],y=[6,plate_w-6]) translate([x,y]) circle(r=6);
        translate([motor_x,axis_y,-1]) cylinder(h=plate_t+2,d=24);
        for(x=[-15.5,15.5],y=[-15.5,15.5])
            translate([motor_x+x,axis_y+y,-1]) cylinder(h=plate_t+2,d=3.5);
        // 单长孔沿两轮中心连线延伸；shaft_offset 只移动装配，不改变底板。
        hull() for(dx=[-slot_travel/2,slot_travel/2])
            translate([motor_x+center_distance+dx,axis_y,-1])
                cylinder(h=plate_t+2,d=3.5);
        for(x=[10,plate_len-10],y=[10,plate_w-10])
            translate([x,y,-1]) cylinder(h=plate_t+2,d=4.5);
    }
}
// 底框+四根立柱为一个打印件，中央开口避让电机并方便接线。
module stand() {
    difference() {
        union() {
            linear_extrude(stand_floor_t) difference() {
                hull() for(x=[6,plate_len-6],y=[6,plate_w-6])
                    translate([x,y]) circle(r=6);
                translate([stand_rail,stand_rail])
                    square([plate_len-2*stand_rail,plate_w-2*stand_rail]);
            }
            // 中间横梁缩短长边的无支撑跨度，连接前后边梁。
            translate([(plate_len-stand_cross_w)/2,0,0])
                cube([stand_cross_w,plate_w,stand_floor_t]);
            // 四角内侧实心三角块，加强边梁交接与柱脚区域。
            for(sx=[0,1],sy=[0,1])
                translate([sx ? plate_len-stand_rail : stand_rail,
                           sy ? plate_w-stand_rail : stand_rail,0])
                    scale([sx ? -1 : 1,sy ? -1 : 1,1])
                        linear_extrude(stand_floor_t)
                            polygon([[0,0],[stand_corner_brace,0],[0,stand_corner_brace]]);
            for(x=[10,plate_len-10],y=[10,plate_w-10])
                translate([x,y]) cylinder(h=stand_h,d=stand_post_d);
        }
        for(x=[10,plate_len-10],y=[10,plate_w-10]) {
            translate([x,y,stand_h-stand_pilot_depth])
                cylinder(h=stand_pilot_depth+0.1,d=stand_pilot_d);
            // 入口倒角，便于对准螺丝。
            translate([x,y,stand_h-0.6])
                cylinder(h=0.7,d1=stand_pilot_d,d2=stand_pilot_d+1.4);
        }
    }
}
module stand_hardware_preview() {
    // 仅示意自攻螺丝外形，不生成螺纹。
    for(x=[10,plate_len-10],y=[10,plate_w-10]) color("silver") {
        translate([x,y,plate_t-stand_screw_len])
            cylinder(h=stand_screw_len,d=stand_screw_d);
        translate([x,y,plate_t]) cylinder(h=3,d=8);
    }
}
// Negative belt-tooth shape, tangent along X, depth toward +Y.
module gt2_gap() {
    scale([(1.494+tooth_width_extra)/1.494,1])
    polygon([[0.747183,-0.5],[0.747183,0],[0.647876,0.037218],[0.598311,0.130528],[0.578556,0.238423],[0.547158,0.343077],[0.504649,0.443762],[0.451556,0.53975],[0.358229,0.636924],[0.2484,0.707276],[0.127259,0.750044],[0,0.76447],[-0.127259,0.750044],[-0.2484,0.707276],[-0.358229,0.636924],[-0.451556,0.53975],[-0.504797,0.443762],[-0.547291,0.343077],[-0.578605,0.238423],[-0.598311,0.130528],[-0.648009,0.037218],[-0.747183,0],[-0.747183,-0.5]]);
}
module pulley(n, hole=bore_d+bore_clearance, lightening=false) {
    difference() {
        union() {
            cylinder(h=flange_t,d=od(n)+flange_extra);
            translate([0,0,flange_t]) linear_extrude(track_h)
                difference() {
                    circle(d=od(n),$fn=n*8);
                    for(i=[0:n-1]) rotate(i*360/n)
                        translate([0,-sqrt(pow(od(n)/2,2)-pow((1.494+tooth_width_extra)/2,2))]) gt2_gap();
                }
            translate([0,0,flange_t+track_h]) cylinder(h=flange_t,d=od(n)+flange_extra);
        }
        translate([0,0,-1]) cylinder(h=pulley_h+2,d=hole);
        if(lightening) for(a=[0:60:300]) rotate(a) translate([pd(n)*0.29,0,-1])
            cylinder(h=pulley_h+2,d=pd(n)*0.16);
    }
}
// 平底圆形轴座；中间贯穿孔与底板、顶盖同轴。
module axle_mount() {
    difference() {
        union() {
            cylinder(h=mount_t,d=mount_d);
            cylinder(h=mount_t+thrust_h,d=12);
            cylinder(h=axle_top,d=printed_axle_d);
        }
        translate([0,0,-0.1]) cylinder(h=axle_top+0.2,d=3.4);
    }
}
module axle_cap() {
    difference() {
        cylinder(h=cap_t,d=12);
        translate([0,0,-0.1]) cylinder(h=cap_t+0.2,d=3.4);
    }
}
module big_pulley() { pulley(driven_teeth,printed_axle_d+axle_clearance,true); }
module screw_preview(length) {
    color("silver") {
        translate([0,0,-length]) cylinder(h=length,d=3);
        cylinder(h=3,d=5.5);
    }
}
module belt_preview() {
    // Smooth pitch-path envelope for display; not a printable/toothed belt.
    color([0.12,0.12,0.12,0.65]) translate([0,0,belt_z]) linear_extrude(belt_width)
    difference() {
        hull() {
            translate([motor_x,axis_y]) circle(d=pd(drive_teeth)+1.2);
            translate([shaft_x,axis_y]) circle(d=pd(driven_teeth)+1.2);
        }
        hull() {
            translate([motor_x,axis_y]) circle(d=pd(drive_teeth)-1.2);
            translate([shaft_x,axis_y]) circle(d=pd(driven_teeth)-1.2);
        }
    }
}
module hardware_preview() {
    color("dimgray") translate([motor_x-21,axis_y-21,-motor_length]) cube([42,42,motor_length]);
    color("silver") translate([motor_x,axis_y,0]) cylinder(h=24,d=5);
    // 螺丝由下向上；两片 0.5mm 平垫片和顶部普通螺母。
    translate([shaft_x,axis_y,-0.5]) rotate([180,0,0]) screw_preview(25);
    for(z=[-0.5,plate_t+axle_top+cap_t])
        color("silver") translate([shaft_x,axis_y,z]) difference() {
            cylinder(h=0.5,d=7);
            translate([0,0,-0.1]) cylinder(h=0.7,d=3.4);
        }
    color("silver") translate([shaft_x,axis_y,plate_t+axle_top+cap_t+0.5]) difference() {
        cylinder(h=2.4,d=6.35,$fn=6);
        translate([0,0,-0.1]) cylinder(h=2.6,d=3.2);
    }
    color("silver") translate([motor_x,axis_y,pulley_z]) rotate([0,0,360*$t]) pulley(drive_teeth,5);
    belt_preview();
}
if(part=="stand") stand();
else if(part=="base") base_plate();
else if(part=="big_pulley") big_pulley();
else if(part=="axle_mount") axle_mount();
else if(part=="axle_cap") axle_cap();
else if(part=="motor_pulley") pulley(drive_teeth,5); // 几何参考，无锁轴结构
else if(part=="print_layout") {
    base_plate();
    translate([27,plate_w+27,0]) big_pulley();
    translate([90,plate_w+14,0]) rotate([0,0,90]) axle_mount();
    translate([140,plate_w+14,0]) axle_cap();
    translate([0,plate_w+55,0]) stand();
}
else if(part=="assembly") {
    color("slategray") translate([0,0,-stand_h]) stand();
    if($preview) stand_hardware_preview();
    color("steelblue") base_plate();
    color("orange") translate([shaft_x,axis_y,pulley_z])
        rotate([0,0,360*$t*drive_teeth/driven_teeth]) big_pulley();
    color("gray") translate([shaft_x,axis_y,plate_t]) axle_mount();
    color("gray") translate([shaft_x,axis_y,plate_t+axle_top]) axle_cap();
    if($preview) hardware_preview();
}
else assert(false,"Unknown part selector");
