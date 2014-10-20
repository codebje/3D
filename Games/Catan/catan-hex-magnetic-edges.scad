//All units measured in mm 
tile_s = 			45.90; 	//edge length of catan hex is 45.89935
tile_play =			0.5;	//adds to incircle radius, not edge length (-0.3 for snap)
tile_room = 			2.5;	//catan tile height is 1.22 mm without warping

support_height =		3;	//was 1
support_width = 		3;

corner_lip =			2;
corner_wall =			1;

nook_depth =			1.5;
corner_nook =			10.5; 	//catan city/settlement width 10+-0.5mm
road_x_nook = 			25.5;	//catan road length 25+-0.5mm
road_y_nook =			5.5;	//catan road width 5+-0.5mm
ship_x_nook = 			17;	//catan ship length (at 1mm depth) ~16
ship_y_nook =			8.5;	//catan ship width 8+-0.5mm
nook_wall =			1;

border_width = 			nook_wall+ship_y_nook/2+0.125;	//was 3 units = 2.598

pieces = 			2;	// was 1
spacing =			0;	// was 0
edged =				true;
tester =				false;

///// constant calculations /////

tile_ri = (tile_s/2*sqrt(3))+tile_play;
edge_height = support_height + tile_room;// - nook_depth;
apothem = tile_ri + border_width + corner_lip;
outer_edge = 2*apothem * tan(30);

// position for 2 pieces
rotate([0, 0, 90]) translate([0,-tile_ri-border_width,0])

main();

// a ship tile, for testering, kept here for measurements
//translate([tile_ri*2+border_width*2+ship_x_nook*2/1.8+12, 0, 0])
//	linear_extrude(support_height) circle(ship_x_nook/1.8-0.5);


///// main render /////

module main() {
	intersection() {
		union() {
			for (t = [ 1 : pieces]) {
				if (t == 1) {
					tile();
				} else if (t < 8) {
					// rotate around the outside
					rotate([0, 0, (t - 2) * 60])
					// translate out along the y axis
					// the tiny subtraction prevents OpenSCAD getting confused by adjoining surfaces
						translate([0, (tile_ri + border_width)*2 - 0.0001 + spacing, 0])
						tile();
				} else if (t == 8) {
					echo("Cannot combine more than 7 pieces together");
				}
			}
		}

		if (tester) translate([0, apothem, 0]) cube([outer_edge+20, 20.5, 10], true);
	}

	// Show a ship for sizing guide
	//rotate([0, 0, 60])
	//translate([
	//	0,
	//	tile_ri+nook_wall+(ship_y_nook)/2+0.25,
	//	support_height+tile_room-nook_depth
	//]) ship();

	// if edged is set, and the number of pieces is two, provide outer edges
	if (edged && pieces == 2 && spacing == 0) {
		bay(tile_ri,border_width,support_height+tile_room);
	}
}

///// module definitions /////

module outer_containers(ri,w,h) {
	s = ri*2/sqrt(3);
	s2 = (ri+w)*2/sqrt(3);

	// Add an outer container for a road and ship
	// this is the union of the inverse of the corner nook cubes
	// less the road/ship dips
	difference() {
		border(ri+w,w,h);

		// a 60 degree triangle nomped out of each side, corner_nook wide at the
		// inner radius
		for (r = [-150,-90,-30,30,90,150]) rotate([0,0,r]) translate([0,0,h/2+h-nook_depth]) union() {
			translate([0,s2,0]) cube([corner_nook, 50, h], true);
			translate([0,s2,0]) rotate([0,0,60]) translate([0,25,0]) cube([corner_nook, 50, h], true);
			translate([0,s2,0]) rotate([0,0,-60]) translate([0,25,0]) cube([corner_nook, 50, h], true);
		}

		for (r = [-60,0,60]) rotate([0,0,r]) translate([0,0,h+5-nook_depth])
			cube([road_x_nook, (ri+w)*2+road_y_nook, 10],true);	

		for (r = [-60,0,60]) rotate([0,0,r]) translate([0,0,h+5-nook_depth])
			cube([ship_x_nook, (ri+w)*2+ship_y_nook, 10],true);	
	}
}

module bay(ri,w,h) {
	s = ri*2/sqrt(3);
	s2 = (ri+w)*2/sqrt(3);

	difference() {
		outer_containers(ri,w,h);
		rotate([0,0,30])
			translate([0,-(ri+w)*1.5,-1])
			cube([ri*2,(ri+w)*3,h+2]);
		rotate([0,0,60])
			translate([-ri,-ri-10-w,-1])
			cube([ri*2,10,h+2]);
	}
	translate([0, (ri + w)*2 - 0.0001 + spacing, 0]) {
		difference() {
			outer_containers(ri,w,h);
			rotate([0,0,30])
				translate([0,-(ri+w)*1.5,-1])
				cube([ri*2,(ri+w)*3,h+2]);
			rotate([0,0,180])
				translate([-ri,-ri-10-w,-1])
				cube([ri*2,10,h+2]);
		}
	}

	// 3xports
	for (r = [0,-60,-120]) rotate([0,0,r])
		translate([0,-ri-w*2+0.0001,0]) port();

	// 2x ports
	for (r = [-60, -120]) translate([0, (ri+w)*2, 0]) rotate([0,0,r])
		translate([0, -ri-w*2+0.0001, 0]) port();
}

module port() {
	s = ship_x_nook;
	difference() {
		linear_extrude(support_height) polygon([
			[0.8*s,-sin(60)*s],
			[s,0],
			[-s,0],
			[-0.8*s,-sin(60)*s]
		]);
		translate([0, -s/2-2, -1]) linear_extrude(support_height+2) circle(s/1.8);
	}
}

module tub(l, h) {
	a = l;
	b = a+2;
	hull() {
		cube([a, 8, 0.1], true);
		translate([0, 0, h]) cube([b, 8, 0.1], true);
	}
}

module ship() {
	intersection() {
		minkowski() {
			translate([0,0,0.5]) tub(13,5);
			sphere(0.55,$fn=25);
		}
		tub(14,5);
	}
}

module road() {
	translate([0, 2.5, 2.5]) cube([25, 5, 5], true);
}

//edge length, height
module hexagon(s, h) {
	hexagon_points = [
		[0.5*s,-sin(60)*s],
		[s,0],
		[0.5*s,sin(60)*s],
		[-0.5*s,sin(60)*s],
		[-s,0],
		[-0.5*s,-sin(60)*s]
	];
	linear_extrude(height = h) polygon(points = hexagon_points);
}

//incircle radius,width,height
module border(ri,width,height) {
	s1 = ri*2/sqrt(3);
	s2 = (ri+width)*2/sqrt(3);
	difference() {
		hexagon(s2,height); 
		translate( [0,0,-1]) hexagon(s1,height+2);
	}
}

module tile() {	
	//border + nooks
	difference() {
		// main frame and base
		union() {
			border(tile_ri,border_width,support_height+tile_room);
			//supports
			//hex-style
			rotate([0,0,30])
				border(((tile_ri+2)/2*sqrt(3))-support_width,support_width,support_height);
			//spoke-style
			intersection() {
				hexagon((tile_ri+2)/2*sqrt(3),support_height); 
				for (r = [-30,30,90]) rotate([0,0,r])
					cube([support_width, 100, 25],true);
			}
		}
		
		// magnet holes
		for (r = [-120, -60, 0, 60, 120, 180]) rotate([0, 0, r]) translate([0, tile_ri+border_width + 8.5, 2.0]) rotate([90, 0, 0]) cylinder(h=10, r=1.75, $fn=100);
	
		//settlement/city
		for (r = [-90,-30,30,90]) rotate([0,0,r]) translate([0,0,support_height+tile_room+10/2-nook_depth]) cube([corner_nook, 150, 10],true);
			
		//road
		intersection() {
			translate([0,0,support_height+tile_room-nook_depth])
				border(tile_ri+nook_wall+(ship_y_nook-road_y_nook)/2,road_y_nook,10);
			union() {
				for (r = [-60,0,60]) rotate([0,0,r]) translate([0,25,0]) cube([road_x_nook, 75, 25],true);	
				for (r = [-60,0,60]) rotate([0,0,r]) translate([0,-25,0]) cube([road_x_nook, 75, 25],true);
			}
		}
		//ship
		intersection() {
			translate([0,0,support_height+tile_room-nook_depth])
				border(tile_ri+nook_wall,ship_y_nook,10);
			union() {
				for (r = [-60,0,60]) rotate([0,0,r]) translate([0,25,0]) cube([ship_x_nook, 75, 25],true);	
				for (r = [-60,0,60]) rotate([0,0,r]) translate([0,-25,0]) cube([ship_x_nook, 75, 25],true);
			}
		}
	
	}
}	






