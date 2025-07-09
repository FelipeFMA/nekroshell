pragma Singleton

import "root:/config"
import "root:/utils"
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property list<string> colourNames: ["rosewater", "flamingo", "pink", "mauve", "red", "maroon", "peach", "yellow", "green", "teal", "sky", "sapphire", "blue", "lavender"]

    property bool showPreview
    property bool endPreviewOnNextChange
    property bool light
    readonly property Colours palette: showPreview ? preview : current
    readonly property Colours current: Colours {}
    readonly property Colours preview: Colours {}
    readonly property Transparency transparency: Transparency {}

    function alpha(c: color, layer: bool): color {
        if (!transparency.enabled)
            return c;
        c = Qt.rgba(c.r, c.g, c.b, layer ? transparency.layers : transparency.base);
        if (layer)
            c.hsvValue = Math.max(0, Math.min(1, c.hslLightness + (light ? -0.2 : 0.2))); // TODO: edit based on colours (hue or smth)
        return c;
    }

    function on(c: color): color {
        if (c.hslLightness < 0.5)
            return Qt.hsla(c.hslHue, c.hslSaturation, 0.9, 1);
        return Qt.hsla(c.hslHue, c.hslSaturation, 0.1, 1);
    }

    function load(data: string, isPreview: bool): void {
        const colours = isPreview ? preview : current;
        const scheme = JSON.parse(data);

        light = scheme.mode === "light";

        for (const [name, colour] of Object.entries(scheme.colours)) {
            const propName = colourNames.includes(name) ? name : `m3${name}`;
            if (colours.hasOwnProperty(propName))
                colours[propName] = `#${colour}`;
        }

        if (!isPreview || (isPreview && endPreviewOnNextChange)) {
            showPreview = false;
            endPreviewOnNextChange = false;
        }
    }

    function setMode(mode: string): void {
        setModeProc.command = ["nekroshell", "scheme", "-m", mode];
        setModeProc.startDetached();
    }

    Process {
        id: setModeProc
    }

    FileView {
        path: `${Paths.state}/scheme.json`
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.load(text(), false)
    }

    component Transparency: QtObject {
        readonly property bool enabled: false
        readonly property real base: 0.78
        readonly property real layers: 0.58
    }

    component Colours: QtObject {
        property color m3primary_paletteKeyColor: "#fabd2f"
        property color m3secondary_paletteKeyColor: "#83a598"
        property color m3tertiary_paletteKeyColor: "#d3869b"
        property color m3neutral_paletteKeyColor: "#a89984"
        property color m3neutral_variant_paletteKeyColor: "#928374"
        property color m3background: "#282828"
        property color m3onBackground: "#ebdbb2"
        property color m3surface: "#282828"
        property color m3surfaceDim: "#1d2021"
        property color m3surfaceBright: "#3c3836"
        property color m3surfaceContainerLowest: "#1d2021"
        property color m3surfaceContainerLow: "#282828"
        property color m3surfaceContainer: "#3c3836"
        property color m3surfaceContainerHigh: "#504945"
        property color m3surfaceContainerHighest: "#665c54"
        property color m3onSurface: "#ebdbb2"
        property color m3surfaceVariant: "#504945"
        property color m3onSurfaceVariant: "#ebdbb2"
        property color m3inverseSurface: "#ebdbb2"
        property color m3inverseOnSurface: "#282828"
        property color m3outline: "#ebdbb2"
        property color m3outlineVariant: "#504945"
        property color m3shadow: "#000000"
        property color m3scrim: "#000000"
        property color m3surfaceTint: "#fabd2f"
        property color m3primary: "#ebdbb2"
        property color m3onPrimary: "#282828"
        property color m3primaryContainer: "#b57614"
        property color m3onPrimaryContainer: "#ebdbb2"
        property color m3inversePrimary: "#fabd2f"
        property color m3secondary: "#ebdbb2"
        property color m3onSecondary: "#282828"
        property color m3secondaryContainer: "#076678"
        property color m3onSecondaryContainer: "#ebdbb2"
        property color m3tertiary: "#ebdbb2"
        property color m3onTertiary: "#282828"
        property color m3tertiaryContainer: "#b16286"
        property color m3onTertiaryContainer: "#ebdbb2"
        property color m3error: "#fb4934"
        property color m3onError: "#282828"
        property color m3errorContainer: "#cc241d"
        property color m3onErrorContainer: "#ebdbb2"
        property color m3primaryFixed: "#fabd2f"
        property color m3primaryFixedDim: "#d79921"
        property color m3onPrimaryFixed: "#282828"
        property color m3onPrimaryFixedVariant: "#ebdbb2"
        property color m3secondaryFixed: "#83a598"
        property color m3secondaryFixedDim: "#458588"
        property color m3onSecondaryFixed: "#282828"
        property color m3onSecondaryFixedVariant: "#ebdbb2"
        property color m3tertiaryFixed: "#d3869b"
        property color m3tertiaryFixedDim: "#b16286"
        property color m3onTertiaryFixed: "#282828"
        property color m3onTertiaryFixedVariant: "#ebdbb2"

        property color rosewater: "#f2e5bc"
        property color flamingo: "#ebdbb2"
        property color pink: "#d3869b"
        property color mauve: "#d3869b"
        property color red: "#fb4934"
        property color maroon: "#cc241d"
        property color peach: "#ebdbb2"
        property color yellow: "#fabd2f"
        property color green: "#b8bb26"
        property color teal: "#8ec07c"
        property color sky: "#83a598"
        property color sapphire: "#458588"
        property color blue: "#83a598"
        property color lavender: "#d3869b"
    }
}
