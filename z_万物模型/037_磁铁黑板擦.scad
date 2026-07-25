
$fn=64;

// ================= 参数定义 =================
length = 107;
width  = 60;
height = 8;
thick  = 1;
d_1    = 24.5;
d_2    = 10;      // 上下小孔的直径

// 两个孔位的 X 轴坐标
hole_x_offset = 38; 
hole_y_offset = 15; 

offset_1 = 8;

// ================= 模块定义 =================

/**
 * 模块1：带孔圆柱（用于底部的支撑柱）
 * 参数：
 *   d: 圆柱外径
 *   h: 圆柱高度
 *   hole_d: 内部孔的直径
 */
module hole_cylinder(d, h, hole_d) {
    difference() {
        cylinder(d=d, h=h, $fn=64);
        // 孔的高度设为 h+1，确保完全穿透且不留残面
        translate([0, 0, -0.5]) 
            cylinder(d=hole_d, h=h+1);
    }
}

/**
 * 模块2：主板挖孔逻辑
 * 将原本散落在 difference() 里的圆柱和内部掏空逻辑封装
 */
module board_cutouts() {
    // 左右两侧的圆柱孔
    translate([-hole_x_offset, 0, -(thick + 5)])
        cylinder(d=d_1, h=10, $fn=64);

    translate([hole_x_offset, 0, -(thick + 5)])
        cylinder(d=d_1, h=10, $fn=64);
    
    translate([0, hole_y_offset, -(thick + 5)])
        cylinder(d=d_2, h=10, $fn=64);  
    
    translate([0, -hole_y_offset, -(thick + 5)])
        cylinder(d=d_2, h=10, $fn=64);  
          
    // 内部掏空（向上偏移 thick）
    translate([0, 0, thick])
        cube([length - 2*thick, width - 2*thick, height], center=true);
}

// ================= 模型组装 =================

// 1. 主板实体（减去孔和内部空间）
difference() {
    cube([length, width, height], center=true);
    board_cutouts();
}

// 2. 底部左右两侧的带孔圆柱（大孔）
translate([-hole_x_offset, 0, -height/2])
    hole_cylinder(d=d_1 + thick *2, h=4, hole_d=d_1);

translate([hole_x_offset, 0, -height/2])
    hole_cylinder(d=d_1 + thick *2, h=4, hole_d=d_1);

// 3. 底部左右两侧的带孔圆柱（小孔 d_2 = 10）

translate([0, hole_y_offset, -height/2])
    hole_cylinder(d=d_2 + thick * 2, h=3, hole_d=d_2);
    
translate([0, -hole_y_offset, -height/2])
    hole_cylinder(d=d_2 + thick * 2, h=3, hole_d=d_2);

 

difference(){
    cube([40, 6, height], center=true);
    cube([40 - thick*2, 6 - thick * 2, height-thick], center=true);
}

translate([length/2 - offset_1, width/2 -offset_1, 0])
    difference(){
        cylinder(r=5/2, h=height, center=true);
        cylinder(r=2.7/2, h=height, center=true);
    }

translate([-(length/2 - offset_1), (width/2 -offset_1), 0])
    difference(){
        cylinder(r=5/2, h=height, center=true);
        cylinder(r=2.7/2, h=height, center=true);
    }

translate([-(length/2 - offset_1), -(width/2 -offset_1), 0])
    difference(){
        cylinder(r=5/2, h=height, center=true);
        cylinder(r=2.7/2, h=height, center=true);
    }
    
translate([(length/2 - offset_1), -(width/2 -offset_1), 0])
    difference(){
        cylinder(r=5/2, h=height, center=true);
        cylinder(r=2.7/2, h=height, center=true);
    }




 
