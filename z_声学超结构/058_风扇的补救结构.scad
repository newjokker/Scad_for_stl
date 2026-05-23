include <BOSL2/std.scad>

$fn = 500;


// ===== 参数 =====
start_h = 10;
end_h   = 15;

spacing = 45;   // 每个模型之间的间距


// ===== 模型 =====
module A(h=5){

    difference() {
        cylinder(r=18, h=h, center=false);
        cylinder(r=12.2/2, h=h+0.1, center=false);
    }
}


// ===== 排列 =====
for(i = [start_h:end_h]) {

    translate([(i - start_h) * spacing, 0, 0])
        A(h=i);
}