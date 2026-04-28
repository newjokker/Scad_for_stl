include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

// 参数配置
length = 12;      // 卡扣总长度 (mm)
width = 8;        // 卡扣宽度 (mm)
snap = 1.2;       // 卡扣耳朵深度，越大卡得越紧
thickness = 1.2;  // 卡扣壁厚 (mm)
depth = 5;        // 卡扣挤出深度 (mm)
compression = 0.2; // 耳朵过盈量，让连接更紧

// 在左侧生成卡扣公头 (pin)
left(15)
    rabbit_clip(
        type = "pin",
        length = length,
        width = width,
        snap = snap,
        thickness = thickness,
        depth = depth,
        compression = compression
    );

// 在右侧生成卡扣母座 (socket)
right(15)
    rabbit_clip(
        type = "socket",
        length = length,
        width = width,
        snap = snap,
        thickness = thickness,
        depth = depth + 0.4,  // 比公头深0.4mm，留出插入空间
        compression = 0        // 母座通常设为0，靠clearance提供间隙
    );