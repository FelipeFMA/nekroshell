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
        property color m3primary_paletteKeyColor: "#ffffff"
        property color m3secondary_paletteKeyColor: "#ffffff"
        property color m3tertiary_paletteKeyColor: "#ffffff"
        property color m3neutral_paletteKeyColor: "#ffffff"
        property color m3neutral_variant_paletteKeyColor: "#ffffff"
        property color m3background: "#1b1b1b"
        property color m3onBackground: "#ffffff"
        property color m3surface: "#1b1b1b"
        property color m3surfaceDim: "#1b1b1b"
        property color m3surfaceBright: "#2a2a2a"
        property color m3surfaceContainerLowest: "#0f0f0f"
        property color m3surfaceContainerLow: "#1f1f1f"
        property color m3surfaceContainer: "#252525"
        property color m3surfaceContainerHigh: "#2a2a2a"
        property color m3surfaceContainerHighest: "#303030"
        property color m3onSurface: "#ffffff"
        property color m3surfaceVariant: "#303030"
        property color m3onSurfaceVariant: "#cccccc"
        property color m3inverseSurface: "#ffffff"
        property color m3inverseOnSurface: "#2a2a2a"
        property color m3outline: "#888888"
        property color m3outlineVariant: "#303030"
        property color m3shadow: "#000000"
        property color m3scrim: "#000000"
        property color m3surfaceTint: "#ffffff"
        property color m3primary: "#ffffff"
        property color m3onPrimary: "#1b1b1b"
        property color m3primaryContainer: "#cccccc"
        property color m3onPrimaryContainer: "#1b1b1b"
        property color m3inversePrimary: "#ffffff"
        property color m3secondary: "#ffffff"
        property color m3onSecondary: "#1b1b1b"
        property color m3secondaryContainer: "#cccccc"
        property color m3onSecondaryContainer: "#1b1b1b"
        property color m3tertiary: "#ffffff"
        property color m3onTertiary: "#1b1b1b"
        property color m3tertiaryContainer: "#cccccc"
        property color m3onTertiaryContainer: "#1b1b1b"
        property color m3error: "#ffffff"
        property color m3onError: "#1b1b1b"
        property color m3errorContainer: "#888888"
        property color m3onErrorContainer: "#ffffff"
        property color m3primaryFixed: "#ffffff"
        property color m3primaryFixedDim: "#cccccc"
        property color m3onPrimaryFixed: "#1b1b1b"
        property color m3onPrimaryFixedVariant: "#888888"
        property color m3secondaryFixed: "#ffffff"
        property color m3secondaryFixedDim: "#cccccc"
        property color m3onSecondaryFixed: "#1b1b1b"
        property color m3onSecondaryFixedVariant: "#888888"
        property color m3tertiaryFixed: "#ffffff"
        property color m3tertiaryFixedDim: "#cccccc"
        property color m3onTertiaryFixed: "#1b1b1b"
        property color m3onTertiaryFixedVariant: "#888888"

        property color rosewater: "#ffffff"
        property color flamingo: "#ffffff"
        property color pink: "#ffffff"
        property color mauve: "#ffffff"
        property color red: "#ffffff"
        property color maroon: "#ffffff"
        property color peach: "#ffffff"
        property color yellow: "#ffffff"
        property color green: "#ffffff"
        property color teal: "#ffffff"
        property color sky: "#ffffff"
        property color sapphire: "#ffffff"
        property color blue: "#ffffff"
        property color lavender: "#ffffff"
    }
}
