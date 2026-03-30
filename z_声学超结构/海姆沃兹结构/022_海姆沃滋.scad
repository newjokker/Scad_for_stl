include <BOSL2/std.scad>

$fn = 200;              // 圆形细分精度

// -------------------- 参数 --------------------
a = 2*12;                 // 腔体内长 mm
b = 2*12;                 // 腔体内宽 mm
c = 2*12;                 // 腔体内高 mm

h = 2*10;                  // neck length mm
r = 2*1.8;                  // neck radius mm
thick = 2*0.5;            // 壁厚 mm

sound_speed = 343;      // m/s

// -------------------- 单位换算 --------------------
function mm_to_m(x) = x / 1000;
function mm3_to_m3(x) = x / 1000000000;

// -------------------- Helmholtz 公式 --------------------
// 腔体体积（内部体积）
V_mm3 = a * b * c;
V_m3  = mm3_to_m3(V_mm3);

// 颈部截面积
A_m2 = PI * pow(mm_to_m(r), 2);

// 有效颈长：L_eff = h + 1.7r
L_eff_m = mm_to_m(h + 1.7 * r);

// 共振频率
freq = (sound_speed / (2 * PI)) * sqrt(A_m2 / (V_m3 * L_eff_m));

// 保留 1 位小数，转成字符串
freq_text = str(round(freq * 10) / 10, " Hz");

// 输出到控制台
echo("Resonance frequency =", freq_text);

// -------------------- 模型 --------------------

module Helm(in_cube=true){

    difference() {

        cuboid([a + 2 * thick, b + 2 * thick, c + 2 * thick], anchor = [0,0,-1]);

        translate([0, 0, thick])
            cuboid([a, b, c], anchor = [0,0,-1]);

        translate([0, 0, thick + 0.01])
            cylinder(h = 200, d = 2 * r, center = false);
    }

    if (in_cube == true)
    {
        translate([0, 0, c-h+thick])
            difference(){
                cylinder(h = h, d = 2 * (r + thick), center = false);
                translate([0, 0, -thick - 0.01])
                    cylinder(h = h + thick + 0.02, d = 2 * r, center = false);
            }
    }
    else{
        translate([0, 0, c+2*thick])
            difference(){
                cylinder(h = h, d = 2 * (r + thick), center = false);
                translate([0, 0, -thick - 0.01])
                    cylinder(h = h + thick + 0.02, d = 2 * r, center = false);
            } 
    }

}

module Helm_in(){

    cuboid([a, b, c], anchor = [0,0,1]);
    cylinder(h = h + thick + 0.02, d = 2 * r, center = false);
    
}



// // -------------------- 频率文字 --------------------
// // text() 是 2D，配合 linear_extrude 变成 3D
// translate([12, 12, h + 10])
//     linear_extrude(height = 0.8)
//         text(
//             freq_text,
//             size = 3,
//             font = "Heiti SC:style=Regular",
//             halign = "center",
//             valign = "center"
//         );


// difference(){
//     Helm(in_cube=false);
//     cuboid([100, 100, 100], anchor=[-1, 0, 0]);
// }


Helm(in_cube=false);

translate([40, 0, 0])
    Helm(in_cube=true);


// Helm_in();

// scale([0.6, 0.6, 0.6]){
//     std_module();
// }