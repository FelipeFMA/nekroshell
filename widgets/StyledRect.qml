import "root:/config"
import QtQuick

Rectangle {
    id: root

    color: "transparent"

    border.width: borderWidth
    border.color: borderColor
    property int borderWidth: 0
    property color borderColor: "transparent"

    Behavior on color {
        ColorAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.standard
        }
    }

    Behavior on borderColor {
        ColorAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.standard
        }
    }
}
