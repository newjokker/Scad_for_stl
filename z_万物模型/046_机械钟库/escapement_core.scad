/* Derived from Printable Clock Project / clockworkLibrary.scad, by syvwlch.
   Upstream: https://github.com/syvwlch/Printable-Clock-Project
   Commit: d40f9e8a7607e4c04abbb06b3c42a60aa71f212d
   License stated upstream: Creative Commons Attribution-ShareAlike (CC-A-SA).
   Retained core modules only; child() modernized to children(); stray comma fixed.
   Tooth/pallet geometry retained. No MCAD/BOSL2 dependency in this excerpt.
*/
module ring(
	outerRadius,
	innerRadius,
	thickness,
	outerSegment=30,
	innerSegment=30)
{
	difference() // hollows out the center of one cylinder with another, smaller one
	{
		cylinder(thickness,outerRadius,outerRadius,$fn=outerSegment);
		translate([0,0,-1])
		cylinder(thickness+2,innerRadius,innerRadius,$fn=innerSegment);
	}
}

module spokes(
	number_spokes,
	spoke_length,
	spoke_thickness,
	spoke_width,
	bore_radius,
	spoke_rotate=0) 
{
	for ( j=[0:number_spokes-1]) // adds the spokes
	{
		rotate(spoke_rotate+360/number_spokes*j,[0,0,1]) 
		translate([bore_radius,-spoke_width/2,0]) 
		cube([spoke_length-bore_radius,spoke_width,spoke_thickness]);
	}
}

module tooth(
	toothLength,
	thickness,
	toothLean,
	toothSharpness,
	clubSize=0,
	clubAngle=0)
{
	rotate(-toothLean,[0,0,1])
	rotate(180,[0,0,1])
	linear_extrude(height=thickness,center=false,twist=0)
	polygon(
		points=	[ 	
				[0,0],
				[clubSize*toothLength*cos(45+toothLean+clubAngle),-clubSize*toothLength*sin(45+toothLean+clubAngle)],
				[clubSize*toothLength*(0.2+cos(45+toothLean+clubAngle)),-clubSize*toothLength*sin(45+toothLean+clubAngle)],
				[clubSize*toothLength*0.5,-clubSize*toothLength*0.5],
				[toothLength,0],
				[toothLength*cos(toothSharpness),toothLength*sin(toothSharpness)]
				],
		paths=	[
				[0,1,2,3,4,5]
				] );
}

module ringTooth(
	outerRadius,
	innerRadius,
	thickness,
	numberTeeth,
	toothLength)
{
	difference() // makes the center hollow while shaving off any parts of the teeth which might otherwise extend into the center
	 {
		union() // unites the teeth and the ring
		{
			cylinder(thickness,outerRadius,outerRadius,$fn=30);
			for ( i=[0:numberTeeth])
			{
				rotate(i*360/numberTeeth,[0,0,1])
				translate([innerRadius+toothLength,0,0]) 
				children(0);
			}
		}

		translate([0,0,-1])
		cylinder(thickness+2,innerRadius,innerRadius,$fn=30);
	}
}

module drum(
	radius,
	rimWidth,
	drumHeight,
	numberHoles=0,
	holeRadius=0,
	holeRotate=0)
{
	flangeWidth=min(drumHeight/3,rimWidth/2);

	difference()		// makes the center hollow & includes holes to attach string
	 {
		union() 	// builds the drum with flanges
		{
			cylinder(flangeWidth,radius,radius-flangeWidth,$fn=30);
	
			translate([0,0,flangeWidth])
			cylinder(drumHeight-2*flangeWidth,radius-flangeWidth,radius-flangeWidth);
	
			translate([0,0,drumHeight-flangeWidth])
			cylinder(flangeWidth,radius-flangeWidth,radius,$fn=30);
		}

		translate([0,0,-1])
		cylinder(drumHeight+2,radius-rimWidth,radius-rimWidth,$fn=30);

	for ( j=[0:numberHoles-1]) // adds the holes
	{
		translate([0,0,drumHeight/2])
		rotate(holeRotate+360/numberHoles*j,[0,0,1]) 
		rotate(90,[0,1,0])
		cylinder(r=holeRadius,h=radius+1);
	}

	}
}

module escapementWheel(
	radius,
	rimWidth,
	drumHeight,
	toothThickness,
	numberTeeth,
	toothLength,
	toothLean,
	toothSharpness,
	numberSpokes,
	spokeWidth,
	hubWidth,
	bore,
	clubSize=0,
	clubAngle=0)
{
	flangeWidth=min(drumHeight/3,rimWidth/2);

	union() // unites the wheel, the spokes and the hub
		{
		ringTooth(radius-toothLength+rimWidth,radius-toothLength,toothThickness,numberTeeth,toothLength)
		tooth(toothLength,toothThickness,toothLean,toothSharpness,clubSize,clubAngle);

		spokes(numberSpokes,radius-toothLength,drumHeight+toothThickness,spokeWidth,bore,0);

		ring(hubWidth,bore,toothThickness+drumHeight);

		ring(radius-toothLength+rimWidth,radius-toothLength,toothThickness);

		translate([0,0,toothThickness])
		drum(radius-toothLength+rimWidth,rimWidth,drumHeight);
	}
}

module escapement(
	radius,
	thickness,
	faceAngle,
	armAngle,
	armWidth,
	numberTeeth,
	toothSpan,
	hubWidth,
	hubHeight,
	bore,
	negative_space=false,
	space=0.1,
	max_swing=6,
	entryPalletAngle=45,
	exitPalletAngle=45)
{
	faceWidth=2*3.1415*radius*faceAngle/360; // calculate once
	escapementAngle=180/numberTeeth*toothSpan; // calculate once
	
	rotate(90,[0,0,1]) // rotates escapement so pendulum is along y axis
	
	if (negative_space==false)
	{
		union()
		{
			// this is the hub
			ring(hubWidth,bore,hubHeight);
			
			// this is the exit pallet

		// this is the arm of the pallet
			rotate(-90-armAngle,[0,0,1]) 
			translate([bore,-armWidth/2,0]) 
			cube([radius+faceWidth/2-bore,armWidth,thickness]);
			
			// this is the pallet itself
			intersection()
			{
				// this is the ring from which the "dead" faces are made
				// it is important that the arcs be smooth, i.e. $fn high
				// otherwise, there would be some recoil
				ring(radius+faceWidth/2,radius-faceWidth/2,thickness,180,180);
				
				// this is the cube which cuts the pallet where it meets the arm
				rotate(-90-armAngle,[0,0,1])
				translate([radius,0,0])
				rotate(180,[0,0,1]) 
				translate([-0.5*radius,0,-radius])
				cube(2.1*radius);
				
				// this is the cube which cuts the pallet at the impulse face
				translate([-2*radius*cos(escapementAngle),0,0])
				rotate(-escapementAngle,[0,0,1])
				rotate(0,[0,0,1])
				translate([radius,0,0])
				rotate(-90-exitPalletAngle,[0,0,1]) 
				translate([-0.5*radius,0,-radius])
				cube(2.2*radius);
			}

		// this is the entry  pallet

			// this is the arm of the pallet
			rotate(90+armAngle,[0,0,1]) 
			translate([bore,-armWidth/2,0]) 
			cube([radius+faceWidth/2-bore,armWidth,thickness]);
			
			// this is the pallet itself
			intersection()
			{
				// this is the ring from which the "dead" faces are made
				// it is important that the arcs be smooth, i.e. $fn high
				// otherwise, there would be some recoil
				ring(radius+faceWidth/2,radius-faceWidth/2,thickness,180,180);
				
				// this is the cube which cuts the pallet where it meets the arm
				rotate(90+armAngle,[0,0,1])
				translate([radius,0,0])
				rotate(0,[0,0,1]) 
				translate([-0.5*radius,0,-radius])
				cube(2.1*radius);
				
				// this is the cube which cuts the pallet at the impulse face
				translate([-2*radius*cos(escapementAngle),0,0])
				rotate(-escapementAngle,[0,0,1])
				rotate(2*escapementAngle,[0,0,1])
				translate([radius,0,0])
				rotate(-90-entryPalletAngle,[0,0,1]) 
				translate([-0.5*radius,0,-radius])
				cube(2.2*radius);
			}
		}
	}

	if (negative_space==true)
	{
		translate([0,0,-space])
		union()
		{
			ring(hubWidth+space,0,hubHeight+2*space);

			difference()
			{
				ring(radius+faceWidth/2+space,0,thickness+2*space);

				rotate(max_swing-armAngle,[0,0,1])
				translate([-radius,armWidth/2,-1])
				cube(2*radius+faceWidth+2*space);

				mirror([1,0,0])
				rotate(max_swing-armAngle,[0,0,1])
				translate([-radius,armWidth/2,-1])
				cube(2*radius+faceWidth+2*space);
			}
		}
	}
}

module placeEscapement (
	angle,
	radius,
	numberTeeth,
	toothSpan)
{
	rotate(angle,[0,0,1])
	translate([0,2*radius*cos(180/numberTeeth*toothSpan),0])
	children(0);
}

