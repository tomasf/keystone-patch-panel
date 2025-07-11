import Cadova

let widthValues = [
    "19inch": 19.inches,
    "halfrack": 9.5.inches,
    "10inch": 10.inches,
]
let strainReliefValues = [nil: false, "strainrelief": true]
let slotWidthValues = [nil: 18.0, "sparse": 21.0]
let configurations = combinations(widthValues, strainReliefValues, slotWidthValues)

await Project {
    for ((name1, width), (name2, useStrainRelief), (name3, slotWidth)) in configurations {
        await Model("patch-panel-" + [name1, name2, name3].compactMap { $0 }.joined(separator: "-")) {
            PatchPanel(
                width: width,
                slotWidth: slotWidth,
                useStrainRelief: useStrainRelief,
                extraSideInset: 0
            )
        }
    }
} environment: {
    $0.tolerance = 0.3
}
