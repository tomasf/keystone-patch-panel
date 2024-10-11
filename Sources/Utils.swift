import Foundation
import SwiftSCAD

func combinations<T1: Sequence, T2: Sequence, T3: Sequence>(_ s1: T1, _ s2: T2, _ s3: T3) -> [(T1.Element, T2.Element, T3.Element)] {
    s1.flatMap { a in s2.flatMap { b in s3.map { c in (a, b, c) }}}
}

extension Double {
    var inches: Double {
        self * 25.4
    }
}

extension Geometry3D {
    func whileTransformed(_ transform: AffineTransform3D, @UnionBuilder3D action: (any Geometry3D) -> any Geometry3D) -> any Geometry3D {
        action(self.transformed(transform)).transformed(transform.inverse)
    }

    func whileRotated(x: Angle = 0°, y: Angle = 0°, z: Angle = 0°, @UnionBuilder3D action: (any Geometry3D) -> any Geometry3D) -> any Geometry3D {
        whileTransformed(.rotation(x: x, y: y, z: z), action: action)
    }
}
