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
        property color m3primary_paletteKeyColor: "#D79921"
        property color m3secondary_paletteKeyColor: "#98971A"
        property color m3tertiary_paletteKeyColor: "#458588"
        property color m3neutral_paletteKeyColor: "#928374"
        property color m3neutral_variant_paletteKeyColor: "#928374"
        property color m3background: "#1D2021"
        property color m3onBackground: "#FBF1C7"
        property color m3surface: "#1D2021"
        property color m3surfaceDim: "#1D2021"
        property color m3surfaceBright: "#3C3836"
        property color m3surfaceContainerLowest: "#0D1011"
        property color m3surfaceContainerLow: "#282828"
        property color m3surfaceContainer: "#32302F"
        property color m3surfaceContainerHigh: "#3C3836"
        property color m3surfaceContainerHighest: "#504945"
        property color m3onSurface: "#FBF1C7"
        property color m3surfaceVariant: "#504945"
        property color m3onSurfaceVariant: "#D5C4A1"
        property color m3inverseSurface: "#FBF1C7"
        property color m3inverseOnSurface: "#3C3836"
        property color m3outline: "#928374"
        property color m3outlineVariant: "#504945"
        property color m3shadow: "#000000"
        property color m3scrim: "#000000"
        property color m3surfaceTint: "#D79921"
        property color m3primary: "#D79921"
        property color m3onPrimary: "#1D2021"
        property color m3primaryContainer: "#B57614"
        property color m3onPrimaryContainer: "#FBF1C7"
        property color m3inversePrimary: "#FABD2F"
        property color m3secondary: "#98971A"
        property color m3onSecondary: "#1D2021"
        property color m3secondaryContainer: "#79740E"
        property color m3onSecondaryContainer: "#F9F5D7"
        property color m3tertiary: "#458588"
        property color m3onTertiary: "#FBF1C7"
        property color m3tertiaryContainer: "#076678"
        property color m3onTertiaryContainer: "#FBF1C7"
        property color m3error: "#FB4934"
        property color m3onError: "#1D2021"
        property color m3errorContainer: "#CC241D"
        property color m3onErrorContainer: "#FBF1C7"
        property color m3primaryFixed: "#FBF1C7"
        property color m3primaryFixedDim: "#D79921"
        property color m3onPrimaryFixed: "#1D2021"
        property color m3onPrimaryFixedVariant: "#B57614"
        property color m3secondaryFixed: "#F9F5D7"
        property color m3secondaryFixedDim: "#98971A"
        property color m3onSecondaryFixed: "#1D2021"
        property color m3onSecondaryFixedVariant: "#79740E"
        property color m3tertiaryFixed: "#FBF1C7"
        property color m3tertiaryFixedDim: "#458588"
        property color m3onTertiaryFixed: "#1D2021"
        property color m3onTertiaryFixedVariant: "#076678"

        property color rosewater: "#FBF1C7"
        property color flamingo: "#FE8019"
        property color pink: "#D3869B"
        property color mauve: "#B16286"
        property color red: "#FE8019"
        property color maroon: "#D79921"
        property color peach: "#FE8019"
        property color yellow: "#D79921"
        property color green: "#98971A"
        property color teal: "#689D6A"
        property color sky: "#458588"
        property color sapphire: "#076678"
        property color blue: "#458588"
        property color lavender: "#8EC07C"
    }
}
