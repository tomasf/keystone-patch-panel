import SwiftSCAD

let widthValues = [
    "19inch": 19.inches,
    "halfrack": 9.5.inches,
    "10inch": 10.inches,
    //"test": 96.0
]
let strainReliefValues = [nil: false, "strainrelief": true]
let slotWidthValues = [nil: 18.0, "sparse": 21.0]
let configurations = combinations(widthValues, strainReliefValues, slotWidthValues)


save(environment: .defaultEnvironment.withTolerance(0.3)) {
    for ((name1, width), (name2, useStrainRelief), (name3, slotWidth)) in configurations {
        PatchPanel(
            width: width,
            slotWidth: slotWidth,
            useStrainRelief: useStrainRelief
        )
        .named("patch-panel-" + [name1, name2, name3].compactMap { $0 }.joined(separator: "-"))
    }
}


