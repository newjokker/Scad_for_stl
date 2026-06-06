// 纸箱自取提示牌 - 批量生成版
// 双层结构：白色底板 + 黑色上层（边框+文字）
// 自动根据字符数调整宽度，并排列成网格

include <BOSL2/std.scad>
include <BOSL2/threading.scad>

$fn = 200;

/* [尺寸参数] */
sign_height = 12;           // 牌子高度 (mm)
border_width = 1;           // 边框厚度 (mm)
corner_radius = 2;          // 外圆角半径 (mm)
white_base_thickness = 2; // 白色底板厚度 (mm)
black_top_thickness = 0.5;    // 黑色上层厚度 (mm)

/* [颜色] */
frame_color = "black";      // 上层边框/文字颜色（黑色）
base_color = "white";       // 底板颜色（白色）

/* [文字参数] */
text_size = 6;              // 文字大小
font_name = "Heiti SC:style=Regular";  // 字体

/* [磁吸孔参数] */
magnet_hole = true;         // 是否启用磁吸孔
magnet_radius = 2.6;        // 磁吸孔半径 (mm)
magnet_depth = 2.2;         // 磁吸孔深度 (mm)

/* [批量排列参数] */
cols = 3;                   // 每行几个牌子
spacing = 5;                // 牌子之间的净间距 (mm)  ← 增大到5mm

// 汤
text_list = [
    "排骨汤",
    "鱼汤",
    "蚕豆蛋花汤",
    "丝瓜蛋汤",
    "青菜豆腐汤",
    "番茄蛋汤",
];

// // 素菜
// text_list = [
//     "番茄炒鸡蛋",
//     "豆瓣酱豆腐",
//     "丝瓜炒蛋",
//     "茼蒿",
//     "红苋菜",
//     "土豆丝",
//     "黄瓜",
//     "藕",
//     "豆芽",
//     "青菜",
//     "空心菜",
//     "面筋",
//     "茄子",
//     "豆角",
//     "韭菜",
//     "西兰花",
//     "花菜",
//     "什锦菜",
//     "时令蔬菜",
//     "时令蔬菜",
//     "时令蔬菜",
// ];

// 半荤
text_list = [
    "芹菜炒肉丝",
    "炒鸡胸肉",
    "炒牛肉",
    "茭白炒肉丝",
    "青椒炒香干",
];

// // 荤菜
// text_list = [
//     "红烧肉",
//     "红烧鸡爪",
//     "虾仁",
//     "红烧鱼",
//     "牛肉",
// ];



// ============================================
// 函数：根据文字长度计算宽度
// ============================================
function get_sign_width(str) = 
    let(len = len(str))
    len <= 2 ? 23 :
    len == 3 ? 30 :
    len == 4 ? 38 :
    len == 5 ? 45 :
    len == 6 ? 52 :  
    len == 7 ? 59 :  
    len == 8 ? 66 :
    len == 9 ? 73 :
    len == 10 ? 80 :
    80;  // 超过10个字的最大宽度

// ============================================
// 模块定义
// ============================================

// 标准圆角矩形拉伸
module rounded_rect(w, h, r, thickness) {
    linear_extrude(thickness)
        offset(r=r, $fn=64)
            square([w - 2*r, h - 2*r], center=true);
}

// 等宽边框的圆角矩形框架
module rounded_rect_frame(outer_w, outer_h, outer_r, frame_w, thickness) {
    linear_extrude(thickness)
        difference() {
            offset(r=outer_r, $fn=64)
                square([outer_w - 2*outer_r, outer_h - 2*outer_r], center=true);
            offset(r=outer_r - frame_w, $fn=64)
                square([outer_w - 2*outer_r, outer_h - 2*outer_r], center=true);
        }
}

// 单个牌子模块
module sign_board(text_str, col, row, col_widths, row_height) {
    // 计算X偏移：累加之前列的所有宽度 + 间距
    x_offset = (col == 0 ? 0 : sum(col_widths, 0, col)) + (col * spacing);
    // 计算Y偏移
    y_offset = -row * (sign_height + spacing);
    
    sign_width = col_widths[col];
    
    translate([x_offset, y_offset, 0]) {
        difference() {
            union() {
                // 白色底板
                color(base_color)
                    rounded_rect(sign_width, sign_height, corner_radius, white_base_thickness);
                
                // 黑色边框（上层）
                color(frame_color)
                    translate([0, 0, white_base_thickness])
                        rounded_rect_frame(sign_width, sign_height, corner_radius, border_width, black_top_thickness);
                
                // 黑色文字（上层）
                color(frame_color)
                    translate([0, 0, white_base_thickness])
                        linear_extrude(height = black_top_thickness)
                            text(
                                text_str,
                                size = text_size,
                                font = font_name,
                                halign = "center",
                                valign = "center"
                            );
            }
            
            // 磁吸孔（底板底部）
            if (magnet_hole) {
                translate([0, 0, -1])
                    cylinder(r=magnet_radius, h=magnet_depth);
            }
        }
    }
}

// 辅助函数：计算数组部分和
function sum(arr, start=0, end) = 
    let(end = (end==undef?len(arr):end))
    start >= end ? 0 : arr[start] + sum(arr, start+1, end);

// ============================================
// 生成所有牌子（支持不等宽排列）
// ============================================
// 计算每列的最大宽度（因为同一列的不同行宽度可能不同）
// 注意：按行优先排列，同一行的不同列宽度不同
num_items = len(text_list);
num_rows = ceil(num_items / cols);

// 构建一个二维数组，存储每个位置的宽度
// 先填充所有位置的宽度，如果该位置没有牌子，宽度为0
widths_matrix = [
    for (r = [0:num_rows-1]) [
        for (c = [0:cols-1]) 
            let(idx = r * cols + c)
            idx < num_items ? get_sign_width(text_list[idx]) : 0
    ]
];

// 计算每列的最大宽度（用于X偏移）
col_max_widths = [
    for (c = [0:cols-1]) 
        max([for (r = [0:num_rows-1]) widths_matrix[r][c]])
];

// 计算总宽度用于居中
total_width = sum(col_max_widths) + (cols - 1) * spacing;
total_height = num_rows * sign_height + (num_rows - 1) * spacing;

// 居中显示所有牌子
translate([-total_width/2, total_height/2, 0]) {
    for (i = [0 : num_items-1]) {
        row = floor(i / cols);
        col = i % cols;
        // 传入该列的实际宽度（使用该列最大宽度，确保对齐）
        // 但如果这一行这个位置的宽度小于列最大宽度，文字会偏左？不，我们要按实际宽度摆放
        // 使用该列实际牌子的宽度，偏移量通过累加前一列的最大宽度来计算
        sign_width = get_sign_width(text_list[i]);
        // 重新计算X偏移：累加前面所有列的最大宽度
        x_offset = (col == 0 ? 0 : sum(col_max_widths, 0, col)) + (col * spacing);
        y_offset = -row * (sign_height + spacing);
        
        translate([x_offset, y_offset, 0]) {
            difference() {
                union() {
                    color(base_color)
                        rounded_rect(sign_width, sign_height, corner_radius, white_base_thickness);
                    color(frame_color)
                        translate([0, 0, white_base_thickness])
                            rounded_rect_frame(sign_width, sign_height, corner_radius, border_width, black_top_thickness);
                    color(frame_color)
                        translate([0, 0, white_base_thickness])
                            linear_extrude(height = black_top_thickness)
                                text(text_list[i], size=text_size, font=font_name, halign="center", valign="center");
                }
                if (magnet_hole) {
                    translate([0, 0, -1])
                        cylinder(r=magnet_radius, h=magnet_depth);
                }
            }
        }
    }
}