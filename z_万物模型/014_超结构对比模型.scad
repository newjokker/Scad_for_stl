


// Hollow cylinder (tube)
// OD = 99.3 mm, ID = 44 mm, H = 49.65 mm

OD = 99.3;
ID = 44;
H  = 49.65;

// 圆的分段数：越大越圆（也会更慢）
$fn = 200;

difference() {
    cylinder(h = H, d = OD, center = false);
    translate([0, 0, -0.1])
        cylinder(h = H + 0.2, d = ID, center = false); // +0.2 防止共面残留
}


module std_module(){
   difference() {
    cylinder(h = H, d = OD, center = false);
    translate([0, 0, -0.1])
        cylinder(h = H + 0.2, d = ID, center = false); // +0.2 防止共面残留
    } 
}
