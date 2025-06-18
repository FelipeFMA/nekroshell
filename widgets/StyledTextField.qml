pragma ComponentBehavior: Bound

import "root:/services"
import "root:/config"
import QtQuick
import QtQuick.Controls

TextField {
    id: root

    color: Colours.palette.m3onSurface
    placeholderTextColor: Colours.palette.m3outline
    font.family: Appearance.font.family.sans
    font.pointSize: Appearance.font.size.smaller
    leftPadding: Appearance.padding.normal
    rightPadding: Appearance.padding.normal
    topPadding: Appearance.padding.small
    bottomPadding: Appearance.padding.small

    background: StyledRect {
        color: Colours.palette.m3surfaceContainer
        radius: Appearance.rounding.normal
        border.width: root.activeFocus ? 2 : 1
        border.color: root.activeFocus ? Colours.palette.m3primary : Colours.palette.m3outline

        Behavior on border.color {
            ColorAnimation {
                duration: Appearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.standard
            }
        }
    }

    cursorDelegate: StyledRect {
        id: cursor

        property bool disableBlink

        implicitWidth: 2
        color: Colours.palette.m3primary
        radius: Appearance.rounding.normal
        onXChanged: {
            opacity = 1;
            disableBlink = true;
            enableBlink.start();
        }

        Timer {
            id: enableBlink

            interval: 100
            onTriggered: cursor.disableBlink = false
        }

        Timer {
            running: root.cursorVisible && !cursor.disableBlink
            repeat: true
            interval: 500
            onTriggered: parent.opacity = parent.opacity === 1 ? 0 : 1
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.anim.durations.small
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

    Behavior on placeholderTextColor {
        ColorAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.standard
        }
    }
}
