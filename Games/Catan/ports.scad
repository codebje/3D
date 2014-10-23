// All units measured in mm
support_height =		3;	//was 1
ship_x_nook = 			17;	//catan ship length (at 1mm depth) ~16

module ratio(s) {
	rotate([0,0,90]) translate([ship_x_nook, -ship_x_nook*2.5+6, support_height]) linear_extrude(2)
		text(s, size=8, halign="center");
}

module large_base(s="2:1") {
	linear_extrude(support_height) circle(ship_x_nook/1.8-0.5, $fn=100);
	translate([ship_x_nook/1.8+0.5, -ship_x_nook*1.5, 0]) minkowski() {
		cube([ship_x_nook*1.5, ship_x_nook*3, support_height]);
		linear_extrude(0.00001) circle(3, $fn=100);
	}

	ratio(s);
}

module sheep() {
	large_base();
	translate([ship_x_nook*1.3,-11,support_height-0.01]) scale(0.5) import("wooly_sheep.stl");
}

module lumber() {
	large_base();

	/* logs */
	s = 5;
	l = 20;
	hr = 1.6;
	logs = [
/*		[0, 0],
		[2, 0],
		[4, 0],
		[-2, 0],
		[-4, 0],*/

		[1, 0],
		[3, 0],
		[-1, 0],
		[-3, 0],

		[0, 1],
		[2, 1],
		[-2, 1],

		[1, 2],
		[-1, 2],

		[0, 3]
	];

	translate([23,-10,0]) {

		for (log = logs) {
			translate([log[0]*(s/2-0.01), 0, support_height+(hr*log[1]+1)*s/2])
			rotate([0,90,90])
			cylinder(d=s, h=l, center=true, $fn=30);
	}

		/* Add inner structure */
		translate([0, (l-4)/2, 0]) rotate([90,0,0]) linear_extrude(l-4) polygon(points=[
			[-3*s/2, support_height-0.01],
			[3*s/2, support_height-0.01],
			[0, support_height+5.4*s/2]
		], paths=[[0,1,2]]);
	}
}

module minecart() {
	large_base();

	l = 10;		// length/2
	b = 7;		// breadth/2
	c = 1;		// slope
	w = 1;		// hull width
	h = 10;

	ll = l+c;
	bb = b+c;
	il = l-w;
	ill = il+c;
	ib = b-w;
	ibb = ib+c;
	points = [
		// outside points
		[ b,  l, 0],			// 0: bottom front left
		[-b,  l, 0],			// 1: bottom front right
		[ b, -l, 0],			// 2: bottom back left
		[-b, -l, 0],			// 3: bottom back right
		[ bb,  ll, h],		// 4: top front left
		[-bb,  ll, h],		// 5: top front right
		[ bb, -ll, h],		// 6: top back left
		[-bb, -ll, h],		// 7: top back right

		// inside points
		[ ib,  il, w],		// 8: bottom front left
		[-ib,  il, w],		// 9: bottom front right
		[ ib, -il, w],		// 10: bottom back left
		[-ib, -il, w],		// 11: bottom back right
		[ ibb,  ill, h],		// 12: top front left
		[-ibb,  ill, h],		// 13: top front right
		[ ibb, -ill, h],		// 14: top back left
		[-ibb, -ill, h]		// 15: top back right

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
	translate([23,-10,0]) {
		translate([0,0,support_height+2])
			polyhedron(points=points, faces=faces, convexivity=10);

		translate([-b-1,  l-1.25, support_height+2.4999]) rotate([0, 90, 0])
			linear_extrude(1) circle(2.5, $fn=100);
		translate([ b,  l-1.25, support_height+2.4999]) rotate([0, 90, 0])
			linear_extrude(1) circle(2.5, $fn=100);
		translate([-b-1, -l+1.25, support_height+2.4999]) rotate([0, 90, 0])
			linear_extrude(1) circle(2.5, $fn=100);
		translate([ b, -l+1.25, support_height+2.4999]) rotate([0, 90, 0])
			linear_extrude(1) circle(2.5, $fn=100);
		intersection() {
			translate([0,0,support_height+h]) scale([0.7,0.7,0.015])
				surface(file="minecart.png", center=true);
			translate([0,0,support_height+h]) cube([b*2, l*2, h], true);
		}
	}
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

//translate([0, ship_x_nook, 0]) minecart();
// translate([ship_x_nook,0,0]) sheep(); // sheep needs to be printed with supports
//translate([ship_x_nook,0,0]) generic();
//translate([-ship_x_nook,0,0]) lumber();
//translate([0, -ship_x_nook, 0]) bread();

translate([0,30,0]) large_base("3:1");
translate([0,-30,0]) sheep();
translate([-50,30,0]) lumber();
translate([-50,-30,0]) minecart();