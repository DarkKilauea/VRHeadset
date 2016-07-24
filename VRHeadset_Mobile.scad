/****************************************
 * Generate VR Headset for Mobile Phone *
 ****************************************/

// TODO: Add mechanism to press against the phone screen for the primary trigger.
// TODO: Lengthen the face guard to fully block out light from the sides.
// TODO: Lens flange slots don't actually allow the lenses to rotate into them.
// TODO: Lenses snap into the lens flange openings, maybe the opening should be wider?
// TODO: Make the exterior of the case rounder.

/*******************************
 *   Adjustable Measurements   *
 *                             *
 * All measurements are in mm. *
 *******************************/

// Overall case size
// Width, Depth, Height
CaseSize = [140, 42, 75];

// Interpupillary Distance
IPD = 75;

// Diameter of the lenses at the eyes
LensDiameter = 34;

// Diameter of the area of the screen 
// that will be viewed
ViewDiameterAtPhone = 60;

// Width, Thickness, and Height of the 
// protrusions on the lens that latch onto the frame.
LensFlangeDimensions = [10, 2, 3];

// Distance the lens is inset into the frame
LensFlangeInset = 1;

// Number of flanges around the edges of the lens
NumberOfLensFlanges = 3;

// Phone measurements
// Height, Thickness, Width
Phone = [140, 11, 75]; 

// Thickness of the border that holds in the phone.
PhoneHolderThickness = 1.5;

// Nose Opening measurements
// Width, depth, height
NoseOpening = [45, 40, 40]; 

// Face Guard measurements
FaceGuardDepth = 50;
FaceGuardThickness = 1;

///////////////////////////
// Internal Measurements //
//     DO NOT CHANGE     //
///////////////////////////

// Derived lens measurements
HalfIPD = IPD / 2;
LensRadius = LensDiameter / 2;

// Distance from the bottom of the case 
// that indicates where the center of the lenses should be.
LensVerticalDistance = Phone.z / 2;

CenterLeftLens = [
    CaseSize.x / 2 - HalfIPD, 
    LensVerticalDistance];
CenterRightLens = [
    CaseSize.x / 2 + HalfIPD, 
    LensVerticalDistance];
   
LensFlangeOpeningDimensions = [
    LensFlangeDimensions.x,
    LensFlangeDimensions.y + LensFlangeInset,
    LensFlangeDimensions.z
];
    
// Derived nose opening measurements
NoseOpeningRatio = NoseOpening.y/NoseOpening.x;

// Derived phone holder measurements
PhoneHolder = [
    CaseSize.x, 
    Phone.y + PhoneHolderThickness, 
    CaseSize.z];
PhoneHolderInterior = [
    Phone.x, 
    Phone.y, 
    PhoneHolder.z - PhoneHolderThickness];
PhoneWidthOffset = (CaseSize.x - Phone.x) / 2;

// Derived face guard measurements
FaceGuard = [CaseSize.x, FaceGuardDepth, CaseSize.z];
FaceGuardInterior = [
    CaseSize.x - FaceGuardThickness * 2, 
    FaceGuardDepth, 
    CaseSize.z - FaceGuardThickness * 2];
FaceGuardArcRadius = FaceGuardInterior.x / 2;

// Dump key measurements to console for generating Cardboard profile
echo("Key Measurements for Cardboard Profile:");
echo(ScreenToLensDistance=CaseSize.y - 2);
echo(InterLensDistance=IPD); 
echo(TrayToLensCenterDistance=LensVerticalDistance);

// Modules
module lens() {
    rotate ([-90, 0, 0]) {
        cylinder(h=CaseSize.y+0.01, 
                 d1=LensDiameter, 
                 d2=ViewDiameterAtPhone);
    }

    for (i = [0:360/NumberOfLensFlanges:360]) {
        rotate([0, i, 0]) {
            // Flange opening
            translate([-(LensFlangeOpeningDimensions.x / 2), 0, LensRadius - LensFlangeOpeningDimensions.z]) {
                cube([
                    LensFlangeOpeningDimensions.x,
                    LensFlangeOpeningDimensions.y,
                    LensFlangeOpeningDimensions.z * 2]);
            }
            // Flange slot
            slotRotation = atan((LensFlangeDimensions.x / 2) / (LensRadius + LensFlangeDimensions.z)) * 2;
            rotate([0, -slotRotation, 0]) {
                translate([-(LensFlangeDimensions.x / 2), LensFlangeInset, (LensRadius) - LensFlangeOpeningDimensions.z]) {
                
                    cube([
                        LensFlangeDimensions.x,
                        LensFlangeDimensions.y,
                        LensFlangeDimensions.z * 2]);
                }
            }
        }
    }
}

// Case
union() {
    // Lens Holder
    difference() {
        cube(CaseSize);

        // Left Lens
        translate([CenterLeftLens.x, 0, CenterLeftLens.y]) {
            lens();
        }
        
        // Right Lens
        translate([CenterRightLens.x, 0, CenterRightLens.y]) {
            lens();
        }
        
        // Nose hole
        translate([CaseSize.x / 2, 0, 0]) {
            scale([1, NoseOpeningRatio, 1]) {
                 union() {
                    cylinder(h=NoseOpening.z - 5, 
                             d1=NoseOpening.x, 
                             d2=10);
                }
                translate([0, 0, NoseOpening.z - 7.1]) {
                    sphere(d=11);
                }
            }
        }
    }

    // Phone Holder
    translate([0, CaseSize.y, 0]) {
        difference() {
            cube(PhoneHolder);
            translate([PhoneWidthOffset, 0, PhoneHolderThickness]) {
                cube(PhoneHolderInterior);
            }
        }
    }
    
    // Face Guard
    translate([0, -FaceGuard.y, 0]) {
        difference() {
            cube(FaceGuard);
            // Hollow out the inside of the face guard
            translate([FaceGuardThickness, 0, FaceGuardThickness]) {
                cube(FaceGuardInterior);
            }
            // Arc at the top and bottom
            translate([FaceGuardArcRadius + FaceGuardThickness, -FaceGuardArcRadius + FaceGuard.y, 0]) {
                cylinder(h=FaceGuard.z, r=FaceGuardArcRadius);
            }
            // Nose Opening Cutout
            translate([(FaceGuard.x / 2) - (NoseOpening.x / 2), 0, 0]) {
                cube([NoseOpening.x, FaceGuard.y, FaceGuardThickness]);
            }
        }
    }
}
