import "root:/widgets"
import "root:/services"
import "root:/config"
import Quickshell
import Quickshell.Io
import QtQuick

Column {
    id: root

    required property Brightness.Monitor monitor

    padding: Appearance.padding.large

    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left

    spacing: Appearance.spacing.normal

    VerticalSlider {
        icon: {
            if (Audio.muted)
                return "no_sound";
            if (value >= 0.5)
                return "volume_up";
            if (value > 0)
                return "volume_down";
            return "volume_mute";
        }
        value: Audio.volume
        onMoved: Audio.setVolume(value)

        implicitWidth: Config.osd.sizes.sliderWidth
        implicitHeight: Config.osd.sizes.sliderHeight
    }

    VerticalSlider {
        icon: `brightness_${(Math.round(value * 6) + 1)}`
        value: root.monitor?.brightness ?? 0
        onMoved: root.monitor?.setBrightness(value)

        implicitWidth: Config.osd.sizes.sliderWidth
        implicitHeight: Config.osd.sizes.sliderHeight
    }

    StyledRect {
        id: nightLightButton

        implicitWidth: Config.osd.sizes.sliderWidth
        implicitHeight: Config.osd.sizes.sliderWidth

        radius: Appearance.rounding.full
        color: wlsunsetActive ? Colours.palette.m3primary : Colours.palette.m3surfaceContainer

        property bool wlsunsetActive: false
        
        StateLayer {
            radius: parent.radius
            color: nightLightButton.wlsunsetActive ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface

            function onClicked(): void {
                toggleWlsunsetProc.startDetached();
            }
        }

        MaterialIcon {
            anchors.centerIn: parent

            text: "bedtime"
            color: nightLightButton.wlsunsetActive ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
            font.pointSize: Appearance.font.size.large
        }

        Process {
            id: toggleWlsunsetProc

            command: ["sh", "-c", `
                if pkill -x wlsunset; then
                    echo "wlsunset was running and has been killed."
                else
                    echo "wlsunset was not running. Starting wlsunset -t 4000 -T 4001..."
                    wlsunset -t 4000 -T 4001 &
                    echo "wlsunset started with PID $!"
                fi
            `]

            onExited: {
                // Check if wlsunset is running after the toggle
                checkWlsunsetProc.startDetached();
            }
        }

        Process {
            id: checkWlsunsetProc

            command: ["pgrep", "-x", "wlsunset"]
            
            onExited: {
                nightLightButton.wlsunsetActive = (exitCode === 0);
            }
        }

        Component.onCompleted: {
            // Check initial state
            checkWlsunsetProc.startDetached();
        }

        Behavior on color {
            ColorAnimation {
                duration: Appearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.standard
            }
        }
    }
}
