// Set smoothness of circles
$fn = 50;

// SSD1306 specific variables
ssd1306_base_length = 25.0;
ssd1306_base_width = 17.2;
ssd1306_base_height = 1;
ssd1306_display_length = 25.0;
ssd1306_display_width = 17.2;
ssd1306_display_height = 2.7;
ssd1306_mount_diameter = 4.0;
ssd1306_mount_interior_diameter = 1.6;

// HCSR05 specific variables

// Builds an SSD1306 display mockup to use as a cutout.
module ssd1306() {
  // Create the base layer
  cube([ssd1306_base_length, ssd1306_base_width, ssd1306_base_height], center = true);
  translate([0, 0, ssd1306_display_height / 2 + ssd1306_base_height / 2 ]) {
    cube([ssd1306_display_length, ssd1306_display_width, ssd1306_display_height], center = true);
  }
  // Create the 4 mount extrusions
  for (i = [-1, 1]){
    for (j = [-1, 1]) {
      translate([i * ssd1306_base_length/2 - (i * ssd1306_mount_diameter/2),
                 j * ssd1306_base_width/2 + (j * ssd1306_mount_diameter/2),
                 0]) {
        difference() {
          union() {
            translate([0, -(j * ssd1306_mount_diameter/2), 0]) {
              cube([ssd1306_mount_diameter, ssd1306_mount_diameter, ssd1306_base_height], center = true);
            }
            translate([0, (j * ssd1306_mount_diameter/$fn), 0]) {
              cylinder(ssd1306_base_height, d=ssd1306_mount_diameter, center = true);
            }
          }
          cylinder(ssd1306_base_height + 2, d=ssd1306_mount_interior_diameter, center = true);
        }
      }
    }
  }
}

// SSD1306 specific variables
hcsr05_base_length = 45.5;
hcsr05_base_width = 20.5;
hcsr05_base_height = 1.6;
hcsr05_extrusion_length = 10;
hcsr05_extrusion_width = 3.6;
hcsr05_extrusion_height = 5 - hcsr05_base_height;
hcsr05_echo_height = 14 - hcsr05_base_height;
hcsr05_echo_diameter = 16.5;

// Builds a very basic hcsr05 mockup to use as a cutout.
module hcsr05() {
  // Base plate
  cube([hcsr05_base_length, hcsr05_base_width, hcsr05_base_height], center = true);
  // Little mount on top
  translate([0,
             (hcsr05_base_width/2 - hcsr05_extrusion_width/2 - 0.5),
             hcsr05_base_height/2 + hcsr05_extrusion_height/2]) {
    cube([hcsr05_extrusion_length, hcsr05_extrusion_width, hcsr05_extrusion_height], center = true);
  }
  // Sensors
  for (i = [-1, 1]) {
    translate([i * hcsr05_base_length/2 - (i * hcsr05_echo_diameter/2) - (i * 1.9),
               0,
               hcsr05_base_height/2]) {
      cylinder(d = hcsr05_echo_diameter, h = hcsr05_echo_height);
    }
  }
}

// TODO: Maybe add a small standoff on top of the hcsr05 to keep the esp32 away.
module esp32_standoff() {

}

enclosure_wall_width = 2;
enclosure_table_size = 17;
enclosure_holding_width = 15;
enclosure_length = 46;
enclosure_width = 30;
enclosure_height = 50;

module enclosure() {
  difference() {
    cube([enclosure_length + enclosure_wall_width * 2,
          enclosure_width + enclosure_wall_width * 2,
          enclosure_height + enclosure_wall_width], center = true);
    translate([enclosure_wall_width, 0, enclosure_wall_width]) {
      cube([enclosure_length + 2 * enclosure_wall_width, enclosure_width, enclosure_height], center = true);
    }
    translate([(enclosure_length - hcsr05_base_length)/2 + enclosure_wall_width,
               - (enclosure_width - hcsr05_base_width)/2 + enclosure_wall_width,
               - (enclosure_height/2 - enclosure_wall_width - hcsr05_base_height/2 - 0.1)]) {
      rotate([180, 0, 0]) {
        hcsr05();
      }
    }
    translate([- enclosure_length/2,
               0,
               7]) {
      rotate([0, -90, 0]) {
        rotate([0, 0, 90]) {
          #ssd1306();
        }
      }
    }
  }
  translate([0,
             enclosure_width/2 + enclosure_holding_width/2 + enclosure_wall_width,
             - enclosure_table_size/2]) {
    cube([enclosure_length + enclosure_wall_width * 2, enclosure_holding_width, 2], center = true);
  }
  translate([0,
             enclosure_width/2 + enclosure_holding_width/2 + enclosure_wall_width, enclosure_table_size/2]) {
    cube([enclosure_length + enclosure_wall_width * 2, enclosure_holding_width, 2], center = true);
  }
}

enclosure();
