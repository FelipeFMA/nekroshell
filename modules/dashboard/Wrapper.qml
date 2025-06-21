import QtQuick
import Quickshell
import "root:/config"
import "root:/services"

Item {
    id: root

    required property PersistentProperties visibilities

    visible: height > 0
    implicitHeight: 0
    implicitWidth: content.implicitWidth

    states: State {
        name: "visible"
        when: root.visibilities.dashboard

        PropertyChanges {
            root.implicitHeight: content.implicitHeight
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"

            NumberAnimation {
                target: root
                property: "implicitHeight"
                duration: Appearance.anim.durations.expressiveDefaultSpatial
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            }
        },
        Transition {
            from: "visible"
            to: ""

            NumberAnimation {
                target: root
                property: "implicitHeight"
                duration: Appearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.emphasized
            }
        }
    ]

    Component.onCompleted: {
        SystemUsage.dashboardVisible = root.visibilities.dashboard;
    }
    onVisibleChanged: {
        SystemUsage.dashboardVisible = root.visibilities.dashboard;
    }
    onVisibilitiesChanged: {
        SystemUsage.dashboardVisible = root.visibilities.dashboard;
    }

    Content {
        id: content

        visibilities: root.visibilities
    }
}
