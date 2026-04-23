
thick = 4;

module blade_base() {

    // 外圈
    translate([0, 0, 90 -6])
        difference() {
            cylinder(h=6, r=165, center=false);  
            translate([0, 0, -0.05])
                cylinder(h=6.1, r=161, center=false);  
        }

    // 穿铁棒的结构
    translate([0, 0, 67])
        difference() {
            cylinder(h=15, r=18, center=false);  
            cylinder(h=15, r=11.8/2, center=false);  
        }

    // 底盘
    difference(){
        union() {
            cylinder(h=75, r=80, center=false); 
            cylinder(h=2.3, r=162, center=false); 
        }
        cylinder(h=75-thick, r=80 -thick, center=false); 
        cylinder(h=150, r=11.8/2, center=false);
    }
}