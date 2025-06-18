pragma ComponentBehavior: Bound

import "root:/widgets"
import "root:/services"
import "root:/config"
import Quickshell
import QtQuick
import QtQuick.Controls

Item {
    id: root

    required property PersistentProperties visibilities
    required property TextField search
    required property int padding
    required property int rounding

    property bool showWallpapers: false
    property var currentList: appList.item

    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right

    clip: true

    implicitWidth: Config.launcher.sizes.itemWidth
    implicitHeight: Math.max(empty.height, appList.height)

    Loader {
        id: appList

        active: true
        asynchronous: true

        anchors.left: parent.left
        anchors.right: parent.right

        sourceComponent: AppList {
            padding: root.padding
            search: root.search
            visibilities: root.visibilities
        }
    }

    Item {
        id: empty

        opacity: root.currentList?.count === 0 ? 1 : 0
        scale: root.currentList?.count === 0 ? 1 : 0.5

        implicitWidth: icon.width + text.width + Appearance.spacing.small
        implicitHeight: icon.height

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        MaterialIcon {
            id: icon

            text: "manage_search"
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.extraLarge

            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            id: text

            anchors.left: icon.right
            anchors.leftMargin: Appearance.spacing.small
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("No results")
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.larger
            font.weight: 500
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.standard
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Appearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.standard
            }
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Appearance.anim.durations.large
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.emphasizedDecel
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Appearance.anim.durations.large
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.emphasizedDecel
        }
    }
}
