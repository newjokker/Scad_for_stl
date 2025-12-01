
include <BOSL2/std.scad>

// 数据进行扩展，可以指定哪些通道进行扩展，增加一个参数
function size_offset(size=[1,1,1], offset=0.3) = 
    let(scaled_result = [
        size[0] + offset,
        size[1] + offset, 
        size[2] + offset
    ])
    scaled_result;


// scaled_size = size_offset([1, 1, 1], 10);
