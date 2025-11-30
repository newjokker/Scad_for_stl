
use <lib/simple_box.scad>;
use <lib/corner_clips.scad>;
use <lib/bolt_post.scad>;
use <lib/lid.scad>;
use <lib/TERMINAL_BLOCK.scad>;
use <lib/port.scad>;
include <BOSL2/std.scad>;

wall_thickness = 2;
battery_width = 19 + 2*wall_thickness;
battery_length = 73 + 2*wall_thickness;
battery_height = 1.5 + 16.5;

box_size = [];

// cuboid([battery_length, battery_width, battery_height], anchor=[-1, -1, -1]);

simple_box(box_size=[battery_length, battery_width, battery_height], wall_thickness=2, rounding=3);


