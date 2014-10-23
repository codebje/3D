// All units measured in mm
support_height =		3;	//was 1
ship_x_nook = 			17;	//catan ship length (at 1mm depth) ~16

module ratio(s) {
	rotate([0,0,90]) translate([0, -ship_x_nook/1.8+2, support_height]) linear_extrude(0.5)
		text(s, size=3, halign="center");
}

module sheep() {
	linear_extrude(support_height) circle(ship_x_nook/1.8-0.5, $fn=100);
	translate([0,0,support_height-0.01]) scale(0.2) import("wooly_sheep.stl");
	ratio("2:1");
}

module lumber() {
	linear_extrude(support_height) circle(ship_x_nook/1.8-0.5, $fn=100);

	/* logs */
	s = 1.3;
	hr=1.6;
	logs = [
		[0, 0],
		[2, 0],
		[4, 0],
		[-2, 0],
		[-4, 0],

		[1, 1],
		[3, 1],
		[-1, 1],
		[-3, 1],

		[0, 2],
		[2, 2],
		[-2, 2],

		[1, 3],
		[-1, 3],

		[0, 4]
	];
	for (log = logs) {
		translate([log[0]*(s/2-0.01), 0, support_height+(hr*log[1]+1)*s/2]) rotate([0,90,90]) cylinder(d=s, h=8, center=true, $fn=20);
	}

	/* Add inner structure */
	translate([0, 3.9, 0]) rotate([90,0,0]) linear_extrude(7.8) polygon(points=[
		[-4*s/2, support_height-0.01],
		[4*s/2, support_height-0.01],
		[0, support_height+7.1*s/2]
	], paths=[[0,1,2]]);

	ratio("2:1");
}

module minecart() {
	linear_extrude(support_height) circle(ship_x_nook/1.8-0.5, $fn=100);

	points = [
		// outside points
		[ 3.5,  4.5, support_height],			// 0: bottom front left
		[-3.5,  4.5, support_height],			// 1: bottom front right
		[ 3.5, -4.5, support_height],			// 2: bottom back left
		[-3.5, -4.5, support_height],			// 3: bottom back right
		[ 4.0,  5.0, support_height+6],		// 4: top front left
		[-4.0,  5.0, support_height+6],		// 5: top front right
		[ 4.0, -5.0, support_height+6],		// 6: top back left
		[-4.0, -5.0, support_height+6	],		// 7: top back right

		// inside points
		[ 2.5,  3.5, support_height+1],		// 8: bottom front left
		[-2.5,  3.5, support_height+1],		// 9: bottom front right
		[ 2.5, -3.5, support_height+1],		// 10: bottom back left
		[-2.5, -3.5, support_height+1],		// 11: bottom back right
		[ 3.0,  4.0, support_height+6],		// 12: top front left
		[-3.0,  4.0, support_height+6],		// 13: top front right
		[ 3.0, -4.0, support_height+6],		// 14: top back left
		[-3.0, -4.0, support_height+6	]		// 15: top back right

	];
	faces = [
		[0, 1, 3, 2],				// bottom
		[0, 2, 6, 4],				// left
		[1, 0, 4, 5],				// front
		[3, 1, 5, 7],				// right
		[2, 3, 7, 6],				// back

		[4, 12, 13, 5],				// top front edge
		[5, 13, 15, 7],				// top right edge
		[6, 7, 15, 14],				// top back edge
		[4, 6, 14, 12],				// top left edge

		[8, 10, 11, 9],				// inside bottom
		[8, 12, 14, 10],				// inside left
		[11, 15, 13, 9],				// inside right
		[9, 13, 12, 8],				// inside front
		[10, 14, 15, 11]				// inside back
	];
	polyhedron(points=points, faces=faces, convexivity=10);
	translate([-4.5,  4.1, support_height+1.4999]) rotate([0, 90, 0]) linear_extrude(1)
		circle(1.5, $fn=100);
	translate([ 3.5,  4.1, support_height+1.4999]) rotate([0, 90, 0]) linear_extrude(1)
		circle(1.5, $fn=100);
	translate([-4.5, -4.1, support_height+1.4999]) rotate([0, 90, 0]) linear_extrude(1)
		circle(1.5, $fn=100);
	translate([ 3.5, -4.1, support_height+1.4999]) rotate([0, 90, 0]) linear_extrude(1)
		circle(1.5, $fn=100);
	intersection() {
		translate([0,0,support_height+4.5]) scale([0.5,0.5,0.015]) surface(file="minecart.png", center=true);
		translate([0,0,support_height+3]) cube([6, 8, 5], true);
	}
	ratio("2:1");
}

module bread() {
	linear_extrude(support_height) circle(ship_x_nook/1.8-0.5, $fn=100);

	// loaf core
	translate([0,0,support_height+3]) minkowski() {
		cube([5.5,10,6], true);
		sphere(0.2, $fn=100);
	}

	// loaf top
	translate([0, 0, support_height + 3 + 5]) minkowski() {
		intersection() {
			translate([0,0,-5]) rotate([0,90,90])
				cylinder(d=8.5,h=10, center=true, $fn=100);
			cube([10, 10, 2.8], true);
		}
		sphere(1, $fn=100);
	}
	ratio("2:1");
}

module boat(size=8) {	
	// hull
	translate([0, -size/1.3, size*0.45]) intersection() {
		translate([-size/3,0,0]) scale([1, 3, 0.6]) sphere(size);
		translate([ size/3,0,0]) scale([1, 3, 0.6]) sphere(size);
		translate([0, size*1.3, 0]) cube([size*2.5, size*5, size*3], true);
		translate([0, 0, -size*3]) cube(size*6, true);
	}

	// sail
	rotate([90,0,90]) linear_extrude(size/8) polygon(points=[
		[-size, 0],
		[size/1.3, 0],
		[-size, size*2.5]
	], paths=[[0, 2, 1]]);
}

module generic() {
	linear_extrude(support_height) circle(ship_x_nook/1.8-0.5, $fn=100);

	translate([0, 0, support_height]) boat(3, $fn=100);

	ratio("3:1");	
}

translate([0, ship_x_nook, 0]) minecart();
// translate([ship_x_nook,0,0]) sheep(); // sheep needs to be printed with supports
translate([ship_x_nook,0,0]) generic();
translate([-ship_x_nook,0,0]) lumber();
translate([0, -ship_x_nook, 0]) bread();