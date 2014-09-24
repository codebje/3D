//All units measured in mm 
tile_s = 			45.90; 	//edge length of catan hex is 45.89935
tile_play =			0.05;	//adds to incircle radius, not edge length (-0.3 for snap)
tile_room = 			2.5;	//catan tile height is 1.22 mm without warping

support_height =		3;	//was 1
support_width = 		3;

border_width = 			2;	//was 3 units = 2.598

T_shaft_y = 			3.75;	//was 5 units = 4.33		
T_shaft_x = 			3;	//was 3						
T_top_y =			2.5;	//was 3 units = 2.598		
T_top_x = 			9;	//was 10					

T_top_x_play = 			0.8;	//was 0.8
T_top_y_play = 			0.6;	//was 0.6 units = 0.5196
T_shaft_x_play = 		0.6;
T_holder_y_play = 		0.6; 	//was 1 units = 0.8660		
T_holder_x_wall = 		2;   	//was 15-10.8=4.2/2=2.1

corner_lip =			2;
corner_wall =			1;

nook_depth =			1;
corner_nook =			10.5; 	//catan city/settlement width 10+-0.5mm
road_x_nook = 			25.25;	//catan road length 25+-0.25mm
road_y_nook =			5.25;	//catan road width 5+-0.25mm
ship_x_nook = 			15.5;	//catan ship length (at 1mm depth) ~16
ship_y_nook =			8.25;	//catan ship width 8+-0.25mm

pieces = 			3;	// was 1

///// constant calculations /////

tile_ri = (tile_s/2*sqrt(3))+tile_play;

///// main render /////
for (t = [ 1 : pieces]) {
	if (t == 1) {
		tile();
	} else if (t < 8) {
		// rotate around the outside
		rotate([0, 0, (t - 2) * 60])
		// translate out along the y axis
		translate([0, (tile_ri + border_width + corner_lip)*2, 0])
		tile();
	} else if (t == 8) {
		echo("Cannot combine more than 7 pieces together");
	}
}

///// module definitions /////

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
	//supports
	//hex-style
	rotate([0,0,30]) border(((tile_ri+border_width)/2*sqrt(3))-support_width,support_width,support_height);
	//spoke-style
	intersection() {
		hexagon((tile_ri+border_width)/2*sqrt(3),support_height); 
		for (r = [-30,30,90]) rotate([0,0,r]) cube([support_width, 100, 25],true);
	}
	
	//border + T interconnections w/ nooks
	difference() {
		union() {
			//border
			border(tile_ri,border_width,support_height+tile_room);
			//settlement/city lip
			intersection() {
				border(tile_ri+border_width,corner_lip,support_height+tile_room);
				//for (r = [-90,-30,30,90]) rotate([0,0,r]) cube([corner_nook+(corner_wall*2), 150, 25],true);		
			}
		}
		
		// magnet holes
		for (r = [-120, -60, 0, 60, 120, 180]) rotate([0, 0, r]) translate([0, tile_ri+border_width + corner_lip + 8.75, 2.25]) rotate([90, 0, 0]) cylinder(h=10, r=1.75, $fn=100);
	
		//settlement/city
		for (r = [-90,-30,30,90]) rotate([0,0,r]) translate([0,0,support_height+tile_room+10/2-nook_depth]) cube([corner_nook, 150, 10],true);
		//road
		intersection() {
			translate([0,0,support_height+tile_room-nook_depth]) border(tile_ri+border_width+((border_width*2+T_shaft_y+T_top_y)/2)-border_width-(road_y_nook/2),road_y_nook,10);
			union() {
				for (r = [-60,0,60]) rotate([0,0,r]) translate([0,25,0]) cube([road_x_nook, 75, 25],true);	
				for (r = [-60,0,60]) rotate([0,0,r]) translate([0,-25,0]) cube([road_x_nook, 75, 25],true);
			}
		}
		//ship
		intersection() {
			translate([0,0,support_height+tile_room-nook_depth]) border(tile_ri+border_width+((border_width*2+T_shaft_y+T_top_y)/2)-border_width-(ship_y_nook/2),ship_y_nook,10);
			union() {
				for (r = [-60,0,60]) rotate([0,0,r]) translate([0,25,0]) cube([ship_x_nook, 75, 25],true);	
				for (r = [-60,0,60]) rotate([0,0,r]) translate([0,-25,0]) cube([ship_x_nook, 75, 25],true);
			}
		}
	
	}
}	





