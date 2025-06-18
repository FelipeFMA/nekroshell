pragma ComponentBehavior: Bound

import "root:/widgets"
import "root:/services"
import "root:/config"
import Quickshell.Services.UPower
import QtQuick

Column {
    id: root

    spacing: Appearance.spacing.normal
    width: Config.bar.sizes.batteryWidth

    // Helper function to format time
    function formatSeconds(s: int, fallback: string): string {
        const day = Math.floor(s / 86400);
        const hr = Math.floor(s / 3600) % 60;
        const min = Math.floor(s / 60) % 60;

        let comps = [];
        if (day > 0)
            comps.push(`${day} days`);
        if (hr > 0)
            comps.push(`${hr} hours`);
        if (min > 0)
            comps.push(`${min} mins`);

        return comps.join(", ") || fallback;
    }

    // Overall battery status
    StyledText {
        text: UPower.displayDevice.isLaptopBattery ? qsTr("Overall: %1%").arg(Math.round(UPower.displayDevice.percentage * 100)) : qsTr("No battery detected")
        font.weight: Font.Medium
    }

    StyledText {
        visible: UPower.displayDevice.isLaptopBattery
        text: UPower.displayDevice.isLaptopBattery ? qsTr("Time %1: %2").arg(UPower.onBattery ? "remaining" : "until charged").arg(UPower.onBattery ? formatSeconds(UPower.displayDevice.timeToEmpty, "Calculating...") : formatSeconds(UPower.displayDevice.timeToFull, "Fully charged!")) : ""
    }

    // Separator when we have batteries
    Rectangle {
        visible: UPower.displayDevice.isLaptopBattery && batteryRepeater.count > 0
        width: parent.width
        height: 1
        color: Colours.palette.m3outline
        opacity: 0.3
    }

    // Individual batteries
    Repeater {
        id: batteryRepeater
        model: UPower.devices

        delegate: Item {
            required property var modelData
            
            width: parent.width
            height: batteryInfo.visible ? batteryInfo.implicitHeight + Appearance.spacing.small : 0
            
            Column {
                id: batteryInfo
                
                width: parent.width
                visible: modelData.isLaptopBattery && modelData.percentage >= 0
                spacing: Appearance.spacing.smaller
                
                StyledText {
                    text: qsTr("Battery %1: %2%").arg(modelData.nativePath || "Unknown").arg(Math.round(modelData.percentage * 100))
                    font.pointSize: Appearance.font.size.small
                    color: modelData.percentage > 0.2 ? Colours.palette.m3onSurface : Colours.palette.m3error
                }
                
                StyledText {
                    visible: (modelData.vendor && modelData.vendor !== "") || (modelData.model && modelData.model !== "")
                    text: {
                        let info = "";
                        if (modelData.vendor && modelData.vendor !== "") info += modelData.vendor;
                        if (modelData.model && modelData.model !== "") {
                            if (info !== "") info += " ";
                            info += modelData.model;
                        }
                        return info;
                    }
                    font.pointSize: Appearance.font.size.smaller
                    color: Colours.palette.m3onSurfaceVariant
                }
                
                StyledText {
                    visible: modelData.capacity >= 0 && modelData.capacity < 1
                    text: qsTr("Health: %1%").arg(Math.round(modelData.capacity * 100))
                    font.pointSize: Appearance.font.size.smaller
                    color: modelData.capacity > 0.8 ? Colours.palette.m3onSurfaceVariant : 
                           modelData.capacity > 0.6 ? Colours.palette.m3tertiary : Colours.palette.m3error
                }
            }
        }
    }

    // Power profile info when no batteries are detected
    StyledText {
        visible: !UPower.displayDevice.isLaptopBattery
        text: qsTr("Power profile: %1").arg(PowerProfile.toString(PowerProfiles.profile))
    }

    Loader {
        anchors.horizontalCenter: parent.horizontalCenter

        active: PowerProfiles.degradationReason !== PerformanceDegradationReason.None
        asynchronous: true

        height: active ? (item?.implicitHeight ?? 0) : 0

        sourceComponent: StyledRect {
            implicitWidth: child.implicitWidth + Appearance.padding.normal * 2
            implicitHeight: child.implicitHeight + Appearance.padding.smaller * 2

            color: Colours.palette.m3error
            radius: Appearance.rounding.normal

            Column {
                id: child

                anchors.centerIn: parent

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Appearance.spacing.small

                    MaterialIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -font.pointSize / 10

                        text: "warning"
                        color: Colours.palette.m3onError
                    }

                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("Performance Degraded")
                        color: Colours.palette.m3onError
                        font.family: Appearance.font.family.mono
                        font.weight: 500
                    }

                    MaterialIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -font.pointSize / 10

                        text: "warning"
                        color: Colours.palette.m3onError
                    }
                }

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: qsTr("Reason: %1").arg(PerformanceDegradationReason.toString(PowerProfiles.degradationReason))
                    color: Colours.palette.m3onError
                }
            }
        }
    }

    StyledRect {
        id: profiles

        property string current: {
            const p = PowerProfiles.profile;
            if (p === PowerProfile.PowerSaver)
                return saver.icon;
            if (p === PowerProfile.Performance)
                return perf.icon;
            return balance.icon;
        }

        anchors.horizontalCenter: parent.horizontalCenter

        implicitWidth: saver.implicitHeight + balance.implicitHeight + perf.implicitHeight + Appearance.padding.normal * 2 + Appearance.spacing.large * 2
        implicitHeight: Math.max(saver.implicitHeight, balance.implicitHeight, perf.implicitHeight) + Appearance.padding.small * 2

        color: Colours.palette.m3surfaceContainer
        radius: Appearance.rounding.full

        StyledRect {
            id: indicator

            color: Colours.palette.m3primary
            radius: Appearance.rounding.full
            state: profiles.current

            states: [
                State {
                    name: saver.icon

                    Fill {
                        item: saver
                    }
                },
                State {
                    name: balance.icon

                    Fill {
                        item: balance
                    }
                },
                State {
                    name: perf.icon

                    Fill {
                        item: perf
                    }
                }
            ]

            transitions: Transition {
                AnchorAnimation {
                    duration: Appearance.anim.durations.normal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.curves.emphasized
                }
            }
        }

        Profile {
            id: saver

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Appearance.padding.small

            profile: PowerProfile.PowerSaver
            icon: "energy_savings_leaf"
        }

        Profile {
            id: balance

            anchors.centerIn: parent

            profile: PowerProfile.Balanced
            icon: "balance"
        }

        Profile {
            id: perf

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: Appearance.padding.small

            profile: PowerProfile.Performance
            icon: "rocket_launch"
        }
    }

    component Fill: AnchorChanges {
        required property Item item

        target: indicator
        anchors.left: item.left
        anchors.right: item.right
        anchors.top: item.top
        anchors.bottom: item.bottom
    }

    component Profile: Item {
        required property string icon
        required property int profile

        implicitWidth: icon.implicitHeight + Appearance.padding.small * 2
        implicitHeight: icon.implicitHeight + Appearance.padding.small * 2

        StateLayer {
            radius: Appearance.rounding.full
            color: profiles.current === parent.icon ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface

            function onClicked(): void {
                PowerProfiles.profile = parent.profile;
            }
        }

        MaterialIcon {
            id: icon

            anchors.centerIn: parent

            text: parent.icon
            font.pointSize: Appearance.font.size.large
            color: profiles.current === text ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
            fill: profiles.current === text ? 1 : 0

            Behavior on fill {
                NumberAnimation {
                    duration: Appearance.anim.durations.normal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.curves.standard
                }
            }
        }
    }
}
