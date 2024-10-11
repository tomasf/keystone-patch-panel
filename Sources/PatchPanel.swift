import Foundation
import SwiftSCAD
import Keystone

struct PatchPanel: Shape3D {
    let width: Double
    let slotWidth: Double
    let useStrainRelief: Bool

    let mountWidth = 15.875 // Width of areas on the sides where screw holes go
    let mountHoleInset = Vector2D(8.74, 6.35) // Distance from edges to center of mount holes
    let unitHeight = 44.5 // 1U
    let mountHoleDiameter = 6.0
    let mountHoleElongation = 2.5

    let cornerRadius = 2.0
    let faceThickness = 3.0
    let floorThickness = 3.0

    let braceThickness = 2.0
    let braceLength = 45.0
    let braceHeight = 30.0

    let slotSpaceLength = 55.0

    let cableDiameter = 8.0
    let strainReliefHeight = 14.0
    let strainReliefLength = 14.0
    let strainReliefHoleSize = Vector3D(12.0, 8.0, 8.0)
    let strainReliefHoleOffset = -2.0

    var body: any Geometry3D {
        EnvironmentReader { e in
            let generousTolerance = e.tolerance * 2
            let size = Vector2D(width + generousTolerance, unitHeight - generousTolerance)
            let effectiveHoleDiameter = mountHoleDiameter + e.tolerance

            let keystoneLength = KeystoneSlot.Metrics(environment: e).baseSize.z
            let bodySize = Vector3D(x: width - 2 * mountWidth - generousTolerance, y: size.y, z: keystoneLength)

            let bodyFullSlotSpaceLength = bodySize.x - slotWidth - 2 * braceThickness

            Rectangle(size)
                .roundingRectangleCorners(radius: cornerRadius)
                .aligned(at: .center)
                .subtracting {
                    Circle(diameter: effectiveHoleDiameter)
                        .clonedAt(x: mountHoleElongation)
                        .aligned(at: .centerX)
                        .convexHull()
                        .translated(size / 2 - mountHoleInset)
                        .symmetry(over: .xy)
                }
                .extruded(height: faceThickness)
                .adding {
                    // Thick front
                    Box(bodySize)
                        .aligned(at: .centerXY)
                        .roundingBoxCorners(.top, axis: .z, radius: cornerRadius)

                    if useStrainRelief {
                        // Floor
                        Box(x: bodySize.x, y: floorThickness, z: slotSpaceLength + strainReliefLength)
                            .aligned(at: .centerX)
                            .translated(y: -size.y / 2)
                            .roundingBoxCorners(.top, axis: .y, radius: cornerRadius)

                        // Braces
                        Box(x: braceThickness, y: floorThickness, z: braceLength)
                            .translated(x: -bodySize.x / 2, y: -bodySize.y / 2, z: bodySize.z)
                            .adding {
                                Box(x: braceThickness, y: braceHeight, z: bodySize.z)
                                    .translated(x: -bodySize.x / 2, y: -bodySize.y / 2)
                            }
                            .convexHull()
                            .symmetry(over: .x)

                        // Strain relief
                        Box(x: cableDiameter, y: strainReliefHeight, z: strainReliefLength)
                            .whileRotated(x: 90°) {
                                $0.applyingTopEdgeProfile(.fillet(radius: cableDiameter / 2), method: .convexHull)
                            }
                            .aligned(at: .centerX)
                            .adding {
                                Box(x: cableDiameter, y: floorThickness, z: strainReliefHeight + strainReliefLength - floorThickness)
                                    .whileRotated(x: 90°) {
                                        $0.applyingTopEdgeProfile(.fillet(radius: cableDiameter / 2), method: .convexHull)
                                    }
                                    .aligned(at: .centerX)
                                    .translated(z: -strainReliefHeight + floorThickness)
                            }
                            .convexHull()
                            .subtracting {
                                Cylinder(diameter: cableDiameter, height: strainReliefLength * 3)
                                    .aligned(at: .centerZ)
                                    .translated(y: strainReliefHeight)
                            }
                            .repeated(along: .x, in: 0..<bodyFullSlotSpaceLength, step: slotWidth)
                            .aligned(at: .centerX)
                            .translated(y: -size.y / 2, z: slotSpaceLength)
                    }
                }
                .subtracting {
                    // Slots
                    KeystoneSlot()
                        .rotated(y: 180°)
                        .aligned(at: .bottom)
                        .translated(z: -0.01)
                        .repeated(along: .x, in: 0..<bodyFullSlotSpaceLength, step: slotWidth)
                        .aligned(at: .centerX)

                    // Cable relief
                    Box(strainReliefHoleSize.with(.y, as: floorThickness + 0.02))
                        .translated(y: -0.01)
                        .adding {
                            Box(strainReliefHoleSize + .init(y: -floorThickness, z: 0.4))
                                .translated(y: floorThickness)
                        }
                        .aligned(at: .centerX)
                        .subtracting {
                            Cylinder(diameter: cableDiameter, height: strainReliefHoleSize.z + 2)
                                .scaled(y: 0.5)
                                .translated(y: strainReliefHoleSize.y)
                        }
                        .repeated(along: .x, in: 0..<bodyFullSlotSpaceLength, step: slotWidth)
                        .aligned(at: .centerX, .centerZ)
                        .translated(y: -size.y / 2 - 0.01, z: slotSpaceLength + strainReliefLength / 2 + strainReliefHoleOffset)
                }
        }
    }
}
