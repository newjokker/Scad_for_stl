include <BOSL2/std.scad>

$fn = 200;


r_in = 190/2;
r_out = (r_in * 2 + 40)/2;
thick =  2;
thick_cycle = 20; // 突出来的圆的厚度，用于卡住

rect_l = 120 + 3;

// 圆环
difference(){
    cylinder(r=r_in, h=thick_cycle, center=false);
    cylinder(r=r_in - thick, h=thick_cycle, center=false);
}

// 突出来的圆
difference(){
    cylinder(r=r_out, h=thick, center=false);
    cuboid([rect_l, rect_l, thick], anchor = [0, 0, -1]);
}

// 放风扇的方框
difference(){
    cuboid([rect_l + thick * 2, rect_l + thick*2, 20], anchor = [0, 0, -1]);
    cuboid([rect_l, rect_l, 20], anchor = [0, 0, -1]);
}











