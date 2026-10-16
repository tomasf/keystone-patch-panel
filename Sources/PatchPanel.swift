import Foundation
import Cadova
import Keystone

struct PatchPanel: Geometry3D {
    let width: Double
    let slotWidth: Double
    let useStrainRelief: Bool
    let extraSideInset: Double

    let mountWidth = 15.875 // Width of areas on the sides where screw holes go
    let mountHoleInset = Vector2D(8.74, 6.35) // Distance from edges to center of mount holes
    let unitHeight = 44.5 // 1U
    let mountHoleDiameter = 6.0
    let mountHoleElongation = 2.5

    let cornerRadius = 2.0
    let faceThickness = 4.0
    let floorThickness = 4.0

    let braceThickness = 4.0
    let braceLength = 45.0
    let braceHeight = 30.0

    let slotSpaceLength = 55.0

    let cableDiameter = 8.0
    let strainReliefHeight = 14.0
    let strainReliefLength = 14.0
    let strainReliefHoleSize = Vector3D(12.0, 8.0, 8.0)
    let strainReliefHoleOffset = -2.0

    @Environment(\.tolerance) var tolerance
    @Environment(\.keystoneSlotMetrics) var metrics

    /// How far apart the first and last slot's positions can be, plus one step: the slots go at every
    /// step from the start, as long as they're within it
    func slotSpaceLength(tolerance: Double) -> Double {
        width - 2 * mountWidth - tolerance * 2 - extraSideInset * 2 - slotWidth - 2 * braceThickness
    }

    /// The number of slots the panel has room for at its spacing
    func slotCount(tolerance: Double) -> Int {
        Array(stride(from: 0, to: slotSpaceLength(tolerance: tolerance), by: slotWidth)).count
    }

    var body: any Geometry3D {
        let generousTolerance = tolerance * 2
        let size = Vector2D(width + generousTolerance, unitHeight - generousTolerance)
        let effectiveHoleDiameter = mountHoleDiameter + tolerance

        let keystoneLength = metrics.baseSize.z
        let bodySize = Vector3D(x: width - 2 * mountWidth - generousTolerance - extraSideInset * 2, y: size.y, z: keystoneLength)

        let bodyFullSlotSpaceLength = slotSpaceLength(tolerance: tolerance)

        Rectangle(size)
            .cuttingEdgeProfile(.fillet(radius: cornerRadius))
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
                    .cuttingEdgeProfile(.fillet(radius: cornerRadius), on: .top, along: .z)

                if useStrainRelief {
                    // Floor
                    Box(x: bodySize.x, y: floorThickness, z: slotSpaceLength + strainReliefLength)
                        .aligned(at: .centerX)
                        .translated(y: -size.y / 2)
                        .cuttingEdgeProfile(.fillet(radius: cornerRadius), on: .top, along: .y)

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
                            $0.cuttingEdgeProfile(.fillet(radius: cableDiameter / 2), on: .top)
                        }
                        .aligned(at: .centerX)
                        .adding {
                            Box(x: cableDiameter, y: floorThickness, z: strainReliefHeight + strainReliefLength - floorThickness)
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
