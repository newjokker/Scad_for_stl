

include <BOSL2/std.scad>

$fn = 60;

// diff() {
//     rect_tube(isize=[7.2, 18.2], wall=1, h=11){

//         // tag("remove") move([1.5,0,0]) position(FRONT+TOP) cuboid([2,3,9], anchor=TOP);
//         position(FRONT+TOP) cuboid([2,13,9], anchor=TOP);

//         // tag("remove") position(RIGHT+TOP) cuboid([3,6,9], rounding=1);

//     }
// }

diff() {
cuboid([13,16,19], rounding=1){

    tag("remove") position(FRONT+TOP) cuboid([2,3,9], anchor=TOP);

}
}