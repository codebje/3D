
// 15cm tall, golden ratio gives 9.27cm wide

$fn = 10;

module stand() {
	cylinder(r=92.7, h=10);
	cylinder(r=15, h=50);
}

module plain() {
	for (tier = [ 1 : 5]) {
		translate([0, 0, 45+30*(5-tier)])
			cylinder(r1=30*tier/1.618, r2=(tier-1)*10+1, h=30);
	}
}

module flute(r = 92.7) {
	for (a = [0 : 45 : 360 ]) {
		hull() {
			rotate([0, 0, a]) translate([r, 0, 0])
				sphere(3);
			rotate([0, 0, a]) translate([0.1, 0, 30])
				sphere(2);
			rotate([0, 0, a]) translate([0.1, 0, 5])
				cylinder(r1=r*0.85, r2=(1-log(r,15))*r, h=25);
		}
	}
}

module fluted() {
	stand();
	for (tier = [ 1 : 5]) {
		translate([0, 0, 45+30*(5-tier)])
			flute(30*tier/1.618);
	}
}

scale(0.5) difference() {
	fluted();
	translate([0, -52.5, 7.5]) cube([92, 12, 8], true);
}

//translate([0, -52.5, 7.5]) cube([90, 10, 5], true);
//translate([0, -50, 10]) rotate([90, 0, 0]) linear_extrude(5) text("2014", halign="center", font="Arial Black", size=20);
