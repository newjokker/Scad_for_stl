

include <BOSL2/std.scad>
include <BOSL2/std.scad>
include <BOSL2/joiners.scad>


$fn = 148;

// 总宽度 450 mm，单面玻璃的厚度 8mm

module A() {
    thick = 3;
    thick_glass = 8 + 0.5;

    difference() {
        cuboid([100, thick_glass + thick *2, 30], anchor=[0, 0, -1]);

        translate([0, 0, thick]) 
            cuboid([100 + 0.01, thick_glass, 30 + 0.01], anchor=[0, 0, -1]);

        translate([0, 0, thick_glass * 2]) 
            cuboid([100 - 50, 30, 30 + 0.01], anchor=[0, 0, -1]);
    }
}

module B() {
  

    // 3D 打印拼接连接组件。
    // 使用 BOSL2 half_joiner() / half_joiner2() 生成一对可互锁的斜面拼接件，
    // 公母两半通过斜面互锁，可带螺丝孔加强固定。
    // 适用于将大件拆分为多块打印后拼接组装、模块化设计等场景。
    // 可直接复制模块调用到具体模型中使用。

    // ---------------- 可调参数 ----------------
    // 圆弧细分

    // 打印配合间隙
    $slop = 0.18;

    // 单个拼接件长度
    joiner_length = 15;
    // 拼接件宽度
    joiner_width = 7;
    // 背板厚度
    joiner_base = 4;
    // 斜面角度
    joiner_angle = 30;
    // 螺丝孔直径，0 表示无孔
    screw_diam = 3.1;
    // 展示间距
    exploded_gap = 18;

    body_color = [0.78, 0.80, 0.76, 1.00];
    part_a_color = [0.95, 0.55, 0.16, 1.00];
    part_b_color = [0.18, 0.48, 0.78, 1.00];


    simple_joiner_pair();


    module simple_joiner_pair() {
        screw = screw_diam > 0 ? screw_diam : undef;

        color(part_a_color)
        left(exploded_gap / 2)
            half_joiner(
                l=joiner_length,
                w=joiner_width,
                base=joiner_base,
                ang=joiner_angle,
                screwsize=screw
            );

        color(part_b_color)
        right(exploded_gap / 2)
            half_joiner2(
                l=joiner_length,
                w=joiner_width,
                base=joiner_base,
                ang=joiner_angle,
                screwsize=screw
            );
    }

}

module C(){
    // 手机实际尺寸
    phone_length = 152;
    phone_width = 75;
    
    // 盒子参数
    wall_thick = 2;      // 壁厚
    gap = 1;             // 手机与内壁的间隙，方便取放
    hight = 12;          // 盒子高度
    
    // 盒子外尺寸 = 手机尺寸 + 2*壁厚 + 2*间隙
    box_length = phone_length + 2*wall_thick + 2*gap;
    box_width = phone_width + 2*wall_thick + 2*gap;
    
    // 盒子内部尺寸
    inner_length = phone_length + 2*gap;
    inner_width = phone_width + 2*gap;
    
    // 放手机的盒子
    difference(){
        cuboid([box_length, box_width, hight], anchor=[0, 0, -1]);
        
        translate([0, 0, wall_thick])
            cuboid([inner_length, inner_width, hight], anchor=[0, 0, -1]);

        // 取手机用的缺口
        translate([box_length/2 - 20 - 5, 0, -0.01])
            cylinder(h = 30, r = 20);
    }

    // 螺丝连接的板子 - 统一尺寸和孔位
    board_width = 25;
    board_length = 20;
    board_thick = 5/2;
    hole_radius = 3.3/2;
    hole_spacing = 12;
    hole_offset = 6;
    
    // 计算侧板位置（在盒子外壁）
    board_y_offset = box_width/2 + board_length/2;
    
    // 右侧板
    translate([box_length/2 - 30, board_y_offset, 0])
        difference(){
            cuboid([board_width, board_length, board_thick], anchor=[0, 0, -1]);
            translate([hole_offset, 0, 0])
                cylinder(r = hole_radius, h = 3);
            translate([-hole_offset, 0, 0])
                cylinder(r = hole_radius, h = 3);
        }
            
    // 左侧板
    translate([-(box_length/2 - 30), board_y_offset, 0])
        difference(){
            cuboid([board_width, board_length, board_thick], anchor=[0, 0, -1]);
            translate([hole_offset, 0, 0])
                cylinder(r = hole_radius, h = 3);
            translate([-hole_offset, 0, 0])
                cylinder(r = hole_radius, h = 3);
        }
        
    // 左下侧板
    translate([-(box_length/2 - 30), -board_y_offset, 0])
        difference(){
            cuboid([board_width, board_length, board_thick], anchor=[0, 0, -1]);
            translate([hole_offset, 0, 0])
                cylinder(r = hole_radius, h = 3);
            translate([-hole_offset, 0, 0])
                cylinder(r = hole_radius, h = 3);
        }

    // 右下侧板
    translate([box_length/2 - 30, -board_y_offset, 0])
        difference(){
            cuboid([board_width, board_length, board_thick], anchor=[0, 0, -1]);
            translate([hole_offset, 0, 0])
                cylinder(r = hole_radius, h = 3);
            translate([-hole_offset, 0, 0])
                cylinder(r = hole_radius, h = 3);
        }
}

module D(){
    // 参数定义
    board_length = 187;    // 板子总长度
    board_width = 25;      // 板子宽度
    board_thick = 5;       // 板子厚度
    
    cutout_length = 20;    // 凹槽长度（对应C模块侧板宽度）
    cutout_width = 25;     // 凹槽宽度（对应C模块侧板长度）
    cutout_depth = 2;      // 凹槽深度
    
    hole_radius = 3.3/2;   // 螺丝孔半径
    hole_spacing = 12;     // 两孔间距
    hole_offset = 6;       // 单侧偏移
    
    // 计算孔的位置
    hole_y_pos = board_width/2;  // 孔在宽度方向的中心位置
    
    // 主结构
    difference() {
        // 主体
        cuboid([board_length, board_width, board_thick], anchor=[-1, 0, -1]);
        
        // 凹槽 - 用于卡住C模块的侧板
        translate([-0.01, 0, board_thick - cutout_depth]) 
            cuboid([cutout_length + 0.01, cutout_width + 0.01, board_thick], anchor=[-1, 0, -1]);
        
        // 在凹槽位置打两个通孔（对应C模块侧板的孔位）
        // -1 防止孔对不上
        translate([cutout_length/2 -1, - hole_offset, 0])
            cylinder(r = hole_radius, h = board_thick + 1);

        translate([cutout_length/2 -1, hole_offset, 0])
            cylinder(r = hole_radius, h = board_thick + 1);
    }
}

translate([50, 70, 0]) 
    rotate([0, 0, 90]) 
        D();

translate([-50, 70, 0]) 
    rotate([0, 0, 90]) 
        D();

translate([50, -70, 0]) 
    rotate([0, 0, -90]) 
        D();

translate([-50, -70, 0]) 
    rotate([0, 0, -90]) 
        D();

C();









