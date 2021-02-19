// Uncomment to render examples:
// test_chamfers();

module test_chamfers ($fn=32)
{
    // cylinder with a (external) 1x45º chamfer
    let(D = 12, H = 8) {
        difference() {
            cylinder(d=D, h=H);
            mcad_chamfer_cylinder(diameter=D, length=1);
        }
    }

    // cube with a cylindrical hole chamfered at both ends:
    //  - near end with a lead-in chamfer of 30º and a depth of 1
    //  - far end with a chamfer defined by two lenghts
    translate ([20, 0, 0]) {
        let(S = 12, D = 8) {
            difference() {
                translate([0,0,S/2]) cube(S-0.002, center=true);
                mcad_chamfered_cylinder(S, internal=true) {
                    cylinder(d=D, h=S);
                    mcad_chamfer_cylinder(diameter=D, depth=1, angle=30,
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
 * Chamfer definition is allowed by specifying either just the
 * 'length', or any combination of two out of the three parameters
 * 'length', 'angle' and 'depth'.
 *
 * @param diameter Diameter of the cylinder to generate a chamfer for.
 * @param length Chamfer length measured on the cylinder's end face.
 * @param angle (optional) Chamfer's lead-in angle in degrees. angle
 *     between the chamfer surface and the cylinder's axis. (Default
 *     is 45º)
 * @param depth (optional) Depth/height of the chamfer measured along
 *     the z axis from the cylinder's end face.
 * @param internal (optional) True when the cylinder is internal.
 */
module mcad_chamfer_cylinder (
     diameter,
     length,
     angle,
     depth,
     internal = false)
{
    // lead-in angle ('a'):
    // external:            internal:
    //    |      |            |   |      |
    //  a .      |          a .   |      |
    //  x |   a /|          x |   |\ a   |
    //  i .    / |d         i .  d| \    |
    //  s |___/__|          s |   |__\___|
    //    .    l              .     l

    assert (diameter > 0, "'diameter' must be a positive number");

    // User Defined  | Calculated
    // ------------    ----------
    // length        | a = 45º, d = l
    // length, angle | d = l/tan(a)
    // length, depth | a = atan(l/d)
    // angle,  depth | l = d*tan(a)
    l = ( angle && depth )
        ? depth * tan(angle)
        : length;
    a = angle
        ? angle
        : depth
            ? atan(l/depth)  // Not really useful but calculated anyway
            : 45;
    d = depth
        ? depth
        : length / tan(a);

    chamfer_diameter = internal
        ? diameter + 2 * l
        : diameter - 2 * l;

    chamfer_profile = [
        [chamfer_diameter / 2,                     -0.001],
        [diameter / 2 + (internal ? -1 : 1)*0.001, -0.001],
        [diameter / 2 + (internal ? -1 : 1)*0.001,      d]
    ];
    rotate_extrude() polygon(chamfer_profile);
}
