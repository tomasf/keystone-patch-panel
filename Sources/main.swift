import Cadova

await Project {
    await Model("patch-panel") {
        @Environment(\.buildDestination) var destination

        Metadata(
            title: "Keystone Patch Panel",
            description: "A 1U rack panel with slots for keystone modules."
        )

        @Parameter("Rack width", description: "The width of the rack the panel mounts in")
        var rackWidth = RackWidth.full

        @Parameter("Slot spacing", in: 18...25, step: 0.5, unit: "mm", description: "Distance between neighboring slots")
        var slotSpacing = 18.0

        @Parameter("Strain relief", description: "Add a shelf behind the slots to tie cables to")
        var useStrainRelief = false

        @Parameter("Tolerance", in: 0...0.6, step: 0.05, unit: "mm", description: "Extra clearance for the modules and the rack's screws")
        var tolerance = 0.3

        Environment {
            $0.tolerance = tolerance
        }

        let panel = PatchPanel(
            width: rackWidth.width,
            slotWidth: slotSpacing,
            useStrainRelief: useStrainRelief,
            extraSideInset: 0
        )

        // The panel prints face down, but the preview stands it up, facing the camera
        if destination == .customizerPreview {
            panel.rotated(x: 90°).rotated(z: 180°)
        } else {
            panel
        }
    }
}

enum RackWidth: String, ParameterChoice {
    case full, ten, half

    var width: Double {
        switch self {
        case .full: 19.inches
        case .ten: 10.inches
        case .half: 9.5.inches
        }
    }

    var displayName: String {
        switch self {
        case .full: "19 inch"
        case .ten: "10 inch"
        case .half: "Half 19 inch"
        }
    }
}
