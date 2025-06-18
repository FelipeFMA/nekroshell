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
        color: NightLight.active ? Colours.palette.m3primary : Colours.palette.m3surfaceContainer
        
        StateLayer {
            radius: parent.radius
            color: NightLight.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface

            function onClicked(): void {
                NightLight.toggle();
            }
            
            Behavior on color {
                ColorAnimation {
                    duration: Appearance.anim.durations.normal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.curves.standard
                }
            }
        }

        MaterialIcon {
            anchors.centerIn: parent

            text: "bedtime"
            color: NightLight.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
            font.pointSize: Appearance.font.size.large
            
            Behavior on color {
                ColorAnimation {
                    duration: Appearance.anim.durations.normal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.curves.standard
                }
            }
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
