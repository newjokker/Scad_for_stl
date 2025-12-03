
include <BOSL2/std.scad>
include <BOSL2/gears.scad>

$fn = 30;


mod=1; cteeth=40; pteeth=17; backing=3; PA=20; face=5;
cpr = pitch_radius(mod=mod, teeth=cteeth);
ppr = pitch_radius(mod=mod, teeth=pteeth);
crown_gear(mod=mod, teeth=cteeth, backing=backing,
    face_width=face, pressure_angle=PA);
back(cpr+face/2)
  up(ppr)
    spur_gear(mod=mod, teeth=pteeth,
        pressure_angle=PA, thickness=face,
        orient=BACK, gear_spin=180/pteeth,
        profile_shift=0);


        