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
ship_x_nook = 			16.5;	//catan ship length (at 1mm depth) ~16
ship_y_nook =			8.5;	//catan ship width 8+-0.5mm
nook_wall =			1;

border_width = 			nook_wall+ship_y_nook/2+0.125;	//was 3 units = 2.598

pieces = 			1;	// was 1
tester =				false;

///// constant calculations /////

tile_ri = (tile_s/2*sqrt(3))+tile_play;
edge_height = support_height + tile_room;// - nook_depth;
apothem = tile_ri + border_width + corner_lip;
outer_edge = 2*apothem * tan(30);

///// main render /////
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
		translate([0, (tile_ri + border_width)*2 - 0.0001, 0])
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

///// module definitions /////

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






