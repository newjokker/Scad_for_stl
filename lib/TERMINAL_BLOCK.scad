include <BOSL2/std.scad>


$fn = 36;

module TERMINAL_BLOCK_A(pos=[0,0,0], show_chip=false, pin_height=3) {
    size=[31, 12, 1.5];
    hole_diameter = 3;
    
    translate(pos){
        translate([-size[0]/2, -size[1]/2, 0]){
            color("red") # 
            
                if(show_chip){
                    difference() {
                        cuboid(size, anchor = [-1,-1,-1]);
                        
                        // 自动计算中心位置
                        translate([9.3 + hole_diameter/2, size[1]/2, size[2]/2])
                        cylinder(h = size[2] + 1, d = hole_diameter, center = true);
                    }
                }
            

            translate([9.3 + hole_diameter/2, size[1]/2, -0.01])
                cylinder(h = pin_height, d = hole_diameter, anchor=[0,0,-1]);
        }
    }
}

module TERMINAL_BLOCK_B(pos=[0, 0, 0], show_chip=false, show_pins=false, pin_height=3, offset=0.2) {
    size=[22, 8.15, 1.5]; hole_diameter = 3; hole_disstance = 14.2 + hole_diameter; hole_start = 1;
    
    translate(pos){
        translate([-size[0]/2, -size[1]/2, 0]){

            // 芯片
            if(show_chip){
                color("green") # 
                difference() {
                    cuboid(size, anchor = BOTTOM+LEFT+FRONT);
                    
                    // 一个洞
                    translate([hole_start+ hole_diameter/2, size[1]/2, size[2]/2])
                    cylinder(h = size[2] + 1, d = hole_diameter, center = true);
                    
                    // 另外一个洞
                    translate([hole_start + hole_disstance + hole_diameter/2, size[1]/2, size[2]/2])
                        cylinder(h = size[2] + 1, d = hole_diameter, center = true);
                }
            }

            // 对应的两个柱子
            if(show_pins){
                translate([hole_start+ hole_diameter/2, size[1]/2, 0])
                    cylinder(h = pin_height, d = hole_diameter - offset, anchor=DOWN);
                
                translate([hole_start + hole_disstance + hole_diameter/2, size[1]/2, 0])
                    cylinder(h = pin_height, d = hole_diameter - offset, anchor=DOWN);
            }

        }
            
    }

            

}

module TERMINAL_BLOCK_C(pos=[0,0,0]) {
    size=[25, 8.15, 1.5]; hole_diameter = 3; hole_disstance = 17.2 + hole_diameter; hole_start = 1;
    
    translate(pos){
        translate([-size[0]/2, -size[1]/2, 0]){
            difference() {
                cuboid(size, anchor = BOTTOM+LEFT+FRONT);
                
                // 一个洞
                translate([hole_start+ hole_diameter/2, size[1]/2, size[2]/2])
                cylinder(h = size[2] + 1, d = hole_diameter, center = true);
                
                // 另外一个洞
                translate([hole_start + hole_disstance + hole_diameter/2, size[1]/2, size[2]/2])
                    cylinder(h = size[2] + 1, d = hole_diameter, center = true);
            }
        }
    }
}

TP4056_size = [28, 17, 2];

module TP4056(pos=[0,0,0], show_clip=false){

    height = TP4056_size[1];
    width = TP4056_size[0];
    thick = TP4056_size[2];

    translate(pos){
        translate([-width/2, -height/2, 0]){
            cuboid([width, height, thick], anchor = [-1,-1,-1]);
        }
        translate([0,0,thick + 0.01])
        color("black") {
            text("TP4056", size = 3, halign = "center", valign = "center");
        }
    } 
}

LD2401_size = [22, 18, 2];

module LD2401(pos=[0,0,0], show_clip=false){
    height = LD2401_size[1];
    width = LD2401_size[0];
    thick = LD2401_size[2];

    translate(pos){
        translate([-width/2, -height/2, 0]){
            cuboid([width, height, thick], anchor = [-1,-1,-1]);
        }
        translate([0,0,thick + 0.01])
        color("black") {
            text("LD2401", size = 3, halign = "center", valign = "center");
        }
    } 
}

DCDC_A_size = [15, 12.6, 2];

module DCDC_A(pos, show_clip=true){
    height = DCDC_A_size[1];
    width = DCDC_A_size[0];
    thick = DCDC_A_size[2];

    translate(pos){
        translate([-width/2, -height/2, 0]){
            cuboid([width, height, thick], anchor = [-1,-1,-1]);
        }
        translate([0,0,thick + 0.01])
        color("black") {
            text("DCDC_A", size = 2.3, halign = "center", valign = "center");
        }
    } 
}

module Battery_18650(pos){
    // 18650 电池
    d = 18.15;
    height = 65;

    translate(pos)
        translate([0, 0, d/2])
            rotate([0, 90, 0])
                cylinder(r=d/2, h=height, anchor=[0,0,0]);
}

module BatteryLevelIndicator(pos){
    // 电池电量指示灯
    
    width = 9.5;
    height = 5;
    thick = 2;

    led_width = 6;      // 4 个 显示的 led 灯的宽度 和 高度 
    led_height = 1.9;    // 


    translate(pos){
        translate([-width/2, -height/2, 0]){
            difference(){
                cuboid([width, height, thick], anchor=[-1,-1,-1]);
                translate([width/2, height/2, -0.01]){
                    cuboid([width - 2, led_height, thick + 5], anchor=[0,0,0]);
                }
            }
        }
    } 
} 

ESP32_C3_supermini_size = [23, 18.5, 2];

module ESP32_C3_supermini(pos=[0, 0, 0]){
    width = ESP32_C3_supermini_size[0];
    height = ESP32_C3_supermini_size[1];
    thick = ESP32_C3_supermini_size[2];
    translate(pos){
        translate([-width/2, -height/2, 0]){
            cuboid([width, height, thick], anchor = [-1,-1,-1]);
        }
        translate([0,0,thick + 0.01])
        color("black") {
            text("ESP_MINI", size = 2.3, halign = "center", valign = "center");
        }
    } 
}



module ESP32_C3_supermini_pro(){
    width = 1;
    height = 1;
    thick = 2;
    translate(pos){
        translate([-width/2, -height/2, 0]){
            cuboid([width, height, thick], anchor = [-1,-1,-1]);
        }
        translate([0,0,thick + 0.01])
        color("black") {
            text("ESP_MINI_PRO", size = 2.3, halign = "center", valign = "center");
        }
    } 
}


// // 展示三个模块
// translate([0, 0, 0]) {
//     color("red", 0.8)  // 红色，80%不透明度
//     TERMINAL_BLOCK_A();
// }

// translate([40, 0, 0]) {  // 向右移动40mm
//     color("green", 0.8)  // 绿色
//     TERMINAL_BLOCK_B();
// }

// translate([70, 0, 0]) {  // 再向右移动30mm
//     color("blue", 0.8)   // 蓝色
//     TERMINAL_BLOCK_C();
// }

// // 添加标签说明（可选）
// translate([0, -5, 0]) linear_extrude(1) text("A", size=3);
// translate([40, -5, 0]) linear_extrude(1) text("B", size=3);
// translate([70, -5, 0]) linear_extrude(1) text("C", size=3);

// TERMINAL_BLOCK_B(pos=[0, 0, 0], show_chip=false, show_pins=true, pin_height=3);

// TP4056();

// LD2401(pos=[30, 0, 0]);

// TERMINAL_BLOCK_A(pos=[60, 0, 0]);

// DCDC_A(pos=[0, 30, 0]);

// BatteryLevelIndicator(pos=[30, 30, 0]);

// Battery_18650(pos = [0, 0, 0]);

// TERMINAL_BLOCK_C(pos=[0, 60, 0]);




// TERMINAL_BLOCK_A(show_chip=true, pin_height=6);
