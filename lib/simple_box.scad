
include <BOSL2/std.scad>

module simple_box(
    box_size=[100, 60, 40],     // 盒子的大小，包括墙的部分
    wall_thickness=2,           // 墙的厚度
    corner_radius=0, 
    chamfer=0.5, 
    pos=[0, 0, 0]){

    // 
    translate(pos)
    {
        // 物体移动到中心
        translate([-box_size[0]/2, -box_size[1]/2, 0])
        {
            difference(){
                // 外边的立方体
                cuboid(box_size, anchor=[-1, -1, -1], chamfer=chamfer);
                // 盒子里面的立方体
                translate([wall_thickness, wall_thickness, wall_thickness])
                    cuboid([box_size[0] - 2*wall_thickness, box_size[1] - 2*wall_thickness, box_size[2] - wall_thickness + 0.01], anchor=[-1, -1, -1]);
            }
        }
    }
}


simple_box(box_size=[80, 50, 20], wall_thickness=1, pos=[0,0, 20]);

