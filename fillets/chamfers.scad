// Uncomment to render examples:
// test_chamfers();

module test_chamfers ($fn=32)
{
    // cylinder with a (external) 1x45º chamfer
    let(D = 12, H = 8) {
        difference() {
            cylinder(d=D, h=H);
            mcad_chamfer_cylinder(diameter=d, length=1);
        }
    }

    // cube with a cylindrical hole chamfered at both ends:
    //  - near end with a lead-in chamfer of 30º
    //  - far end with a chamfer defined by two lenghts
    translate ([20, 0, 0]) {
        let(S = 12, D = 8) {
            difference() {
                translate([0,0,S/2]) cube(S-0.002, center=true);
                mcad_chamfered_cylinder(S, internal=true) {
                    cylinder(d=D, h=S);
                    mcad_chamfer_cylinder(diameter=D, length=1, angle=30,
                                          internal=true);
                    mcad_chamfer_cylinder(diameter=D, length=1.5, depth=1,
                                          internal=true);
                }
            }
        }
    }

}

/**
 * Applies chamfers to a cylindrical object.
 *
 * Expects 2 or 3 children in the following order:
 *   1. Cylindrical object.
 *   2. Chamfer object at near end (z = 0).
 *   3. (optional) Chamfer object at far end (z = length).
 *
 * @param length Axial length of the cylindrical object.
 * @param internal (optional) True when the cylinder is internal.
 */
module mcad_chamfered_cylinder (length, internal = false)
{
    if (internal) {
        union() {
            children(0);
            children(1);
            if ($children == 3) {
                translate([0,0,length]) rotate([180,0,0]) children(2);
            }
        }
    }
    else {
        difference() {
            children(0);
            children(1);
            if ($children == 3) {
                translate([0,0,length]) rotate([180,0,0]) children(2);
            }
        }
    }
}

/*
 * Generates a revolved chamfer for a cylinder end face. for external
 * cylinders this object can be subtracted from the cylinder. for
 * internal cylinders, this object can be subtracted along with the
 * cylinder from the original solid.
 *
 * Chamfer definition is allowed by specifying either a length and an
 * angle; or a length and a depth/height.
 *
 * @param diameter Diameter of the cylinder to generate a chamfer for.
 * @param length Chamfer length measured on the cylinder's end face.
 * @param angle (optional) Chamfer's lead-in angle in degrees. angle
 *      between the chamfer surface and the cylinder's axis.
 * @param depth (optional) Depth/height of the chamfer measured along
 *     the z axis from the cylinder's end face. if specified, the
 *     'angle' parameter will be ignored.
 * @param internal (optional) True when the cylinder is internal.
 */
module mcad_chamfer_cylinder (
     diameter,
     length,
     angle = 45,
     depth,
     internal = false)
{
    // lead-in angle (alpha):
    // external:            internal:
    //              |         |
    //   |          .a      a .    |          |
    //   |\ alpha   |x      x |    |\ alpha   |
    //  d| \        .i      i .   d| \        |
    //   |__\_______|s      s |    |__\_______|
    //    l         .         .      l

    assert (diameter > 0, "'diameter' must be a positive number");
    assert (length > 0, "'length' must be a positive number");

    alpha = depth
        ? atan(depth/length)
        : angle;
    d = depth
        ? depth
        : length / tan(angle);
    chamfer_diameter = internal
        ? diameter + 2 * length
        : diameter - 2 * length;

    chamfer_profile = [
        [chamfer_diameter / 2,                     -0.001],
        [diameter / 2 + (internal ? -1 : 1)*0.001, -0.001],
        [diameter / 2 + (internal ? -1 : 1)*0.001,      d]
    ];
    rotate_extrude() polygon(chamfer_profile);
}
