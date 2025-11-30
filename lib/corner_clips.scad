
include <BOSL2/std.scad>

// 芯片的卡扣
module four_corner_clips(
    chip_size = [20, 10, 4],    // 芯片的长宽高
    clip_length=2,              // 卡扣的边长
    clip_thick=1.5,              // 卡扣的厚度
    show_chip = false,          // 
    show_clip = true,          // 
    pos=[0,0,0],                 // 中心点所在的位置
){
    
    if(show_clip)
    {
        // 对中心点进行移动
        translate(pos){
            // 先将中心点移动到原点
            translate([-(chip_size[0]/2 + clip_thick), -(chip_size[1]/2 + clip_thick), 0]){

                color("red") #
                if(show_chip){
                    translate([clip_thick, clip_thick, 0])
                        cuboid(chip_size, anchor=[-1, -1, -1]);
                }

                difference(){
                    // 原始的矩形
                    cuboid([chip_size[0]+2*clip_thick,chip_size[1]+2*clip_thick,chip_size[2]], anchor=[-1, -1, -1]);
                    // 中间部分
                    translate([clip_thick, clip_thick, -0.5])
                        cuboid([chip_size[0], chip_size[1], chip_size[2] + 1], anchor=[-1, -1, -1]);
                    // 使用两个矩形剪切出四个边
                    translate([clip_thick + clip_length, -0.5, -0.5])
                                cuboid([chip_size[0]-2*clip_length, chip_size[1] + clip_thick*2 + 1, chip_size[2] + 1], anchor=[-1, -1, -1]);

                    translate([-0.5, clip_thick + clip_length, -0.5])
                                cuboid([chip_size[0]+2*clip_thick + 1, chip_size[1]-2*clip_length, chip_size[2] + 1], anchor=[-1, -1, -1]);

                }
            }
        }
    }

}




four_corner_clips(clip_thick=1.5, pos=[20,20,0]);