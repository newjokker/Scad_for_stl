// =============================================================================
// 矩形拼正方形排列算法 (Bottom-Left Algorithm)
// =============================================================================

// 定义 9 个矩形的参数 [宽度, 高度]
rect_params = [
    [24.1, 10.8],
    [10.0, 10.8],
    [11.7, 10.8],
    [17.7, 14.8],
    [11.9, 14.8],
    [16.1, 14.8],
    [15.8, 20.0],
    [8.8, 20.0],
    [21.2, 20.0]
];

// 预定义 9 种不同的颜色
colors = [
    [1, 0, 0],       // 红
    [0, 1, 0],       // 绿
    [0, 0, 1],       // 蓝
    [1, 1, 0],       // 黄
    [1, 0, 1],       // 品红
    [0, 1, 1],       // 青
    [1, 0.5, 0],     // 橙
    [0.5, 0, 1],     // 紫
    [0, 0.5, 1]      // 浅蓝
];

// --- 算法参数 ---
// 计算理论最小正方形边长
total_area = 0;
for (r = rect_params) {
    total_area += r[0] * r[1];
}
side_length = ceil(sqrt(total_area)) + 1; // 取整数边长，留一点余量

echo(str("理论正方形边长: ", sqrt(total_area), " mm"));
echo(str("实际绘图边长: ", side_length, " mm"));

// 存储已放置矩形的位置信息 [x, y, w, h]
placed_rects = [];

// 排序：先放大的，再放小的（提高装箱效率）
sorted_indices = [for (i = [0:8]) i];
sorted_indices = [for (i = sort_indices([for (j = [0:8]) rect_params[j][0] * rect_params[j][1]], -1)) i];

// 主循环：放置矩形
for (i = sorted_indices) {
    w = rect_params[i][0];
    h = rect_params[i][1];
    
    // 初始候选位置 (0,0)
    best_x = 0;
    best_y = 0;
    min_height_above = side_length; // 初始化为一个很大的数
    
    // 遍历所有可能的放置点，寻找最适合的 (底部优先)
    for (j = [0:len(placed_rects)-1]) {
        // 情况1：尝试放在某个矩形的右边
        x_candidate1 = placed_rects[j][0] + placed_rects[j][2];
        y_candidate1 = placed_rects[j][1];
        
        // 检查这个位置是否合法（不重叠且在边界内）
        is_valid1 = x_candidate1 + w <= side_length;
        
        // 检查高度冲突
        height_above1 = side_length;
        for (k = [0:len(placed_rects)-1]) {
            if (k == j) continue;
            
            // 检查是否与当前候选位置下方的矩形重叠
            if (x_candidate1 < placed_rects[k][0] + placed_rects[k][2] &&
                x_candidate1 + w > placed_rects[k][0] &&
                y_candidate1 < placed_rects[k][1] + placed_rects[k][3] &&
                y_candidate1 + h > placed_rects[k][1]) {
                is_valid1 = false;
                break;
            }
            
            // 计算上方的高度
            if (placed_rects[k][0] < x_candidate1 + w && placed_rects[k][0] + placed_rects[k][2] > x_candidate1) {
                if (placed_rects[k][1] >= y_candidate1 + h) {
                    height_above1 = min(height_above1, placed_rects[k][1] - (y_candidate1 + h));
                }
            }
        }
        
        // 情况2：尝试放在某个矩形的上边
        x_candidate2 = placed_rects[j][0];
        y_candidate2 = placed_rects[j][1] + placed_rects[j][3];
        
        is_valid2 = y_candidate2 + h <= side_length;
        
        // 检查宽度冲突
        width_right2 = side_length;
        for (k = [0:len(placed_rects)-1]) {
            if (k == j) continue;
            
            if (x_candidate2 < placed_rects[k][0] + placed_rects[k][2] &&
                x_candidate2 + w > placed_rects[k][0] &&
                y_candidate2 < placed_rects[k][1] + placed_rects[k][3] &&
                y_candidate2 + h > placed_rects[k][1]) {
                is_valid2 = false;
                break;
            }
            
            // 计算右方的宽度
            if (placed_rects[k][1] < y_candidate2 + h && placed_rects[k][1] + placed_rects[k][3] > y_candidate2) {
                if (placed_rects[k][0] >= x_candidate2 + w) {
                    width_right2 = min(width_right2, placed_rects[k][0] - (x_candidate2 + w));
                }
            }
        }
        
        // 更新最佳位置
        if (is_valid1 && height_above1 < min_height_above) {
            best_x = x_candidate1;
            best_y = y_candidate1;
            min_height_above = height_above1;
        }
        if (is_valid2 && width_right2 < min_height_above) {
            best_x = x_candidate2;
            best_y = y_candidate2;
            min_height_above = width_right2;
        }
    }
    
    // 如果没找到合适位置，尝试放在(0,0)
    if (best_x + w > side_length || best_y + h > side_length) {
        best_x = 0;
        best_y = 0;
    }
    
    // 记录放置位置
    placed_rects = concat(placed_rects, [[best_x, best_y, w, h]]);
}

// 绘制所有矩形
for (i = [0:len(placed_rects)-1]) {
    rect = placed_rects[i];
    color(colors[i % len(colors)])
    translate([rect[0] + 1, rect[1] + 1, 0]) // 稍微偏移1mm，方便看清边界
    cube([rect[2] - 2, rect[3] - 2, 1]); // 稍微缩小1mm，防止完全贴合看不出轮廓
}

// 绘制参考正方形边框
%translate([0, 0, 0.1])
cube([side_length, side_length, 0.1], center = false);