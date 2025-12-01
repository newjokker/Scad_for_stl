
include <BOSL2/std.scad>

module lid(
    lid_size = [10, 10, 2],
    plug_thickness = 1,
    plug_depth = 1,
    wall_thickness = 1,
    chamfer=0.1,
    hand_width=8,
    hand_height=3,
    hand_direction="right",
    pos=[0,0,0]
){

    translate(pos){

        // 移动到中心点
        translate([-lid_size[0]/2, -lid_size[1]/2, 0])
        {
            // 盖子的主体
            cuboid(lid_size, anchor=[-1, -1, -1], chamfer=chamfer);

            // 盖子的把手
            if(hand_direction == "right"){
                translate([lid_size[0]/2 - hand_width/2, -hand_height+1, 0]){
                    cuboid([hand_width, hand_height, lid_size[2]], chamfer=chamfer, anchor=[-1, -1, -1], edges=[FRONT]);
                }
            }
            else{
                translate([lid_size[0]/2 - hand_width/2, lid_size[1] -1, 0]){
                    cuboid([hand_width, hand_height, lid_size[2]], chamfer=chamfer, anchor=[-1, -1, -1], edges=[BACK]);
                }  
            }

            // 公口部分
            difference(){
                outer_size = [
                    lid_size[0] - 2*wall_thickness,
                    lid_size[1] - 2*wall_thickness, 
                    plug_depth
                ];
                
                inner_size = [
                    lid_size[0] - 2*wall_thickness - 2*plug_thickness,
                    lid_size[1] - 2*wall_thickness - 2*plug_thickness,
                    plug_depth + 0.01  // 高度略大, 为了干净的切割
                ];
                
                // 外圈的矩形
                translate([wall_thickness, wall_thickness, lid_size[2]])
                    cuboid(outer_size, anchor=[-1, -1, -1], chamfer=chamfer, edges=[TOP, LEFT+FRONT, RIGHT+FRONT, LEFT+BACK, RIGHT+BACK]);
                
                // 内圈矩形，让被减去的立方体在高度上略微超出主体，确保完全、干净地切割
                translate([wall_thickness + plug_thickness, wall_thickness + plug_thickness, lid_size[2] - 0.005])
                    cuboid(inner_size, anchor=[-1, -1, -1]);
            }
        }
    }
}


lid(
    lid_size=[50, 30, 1.5],
    plug_thickness=1.5,
    plug_depth=1.5,
    wall_thickness=1,
    chamfer=0.5,
    // hand_direction="right",
    hand_direction="left",
    pos=[0, 0, 5]
    );

