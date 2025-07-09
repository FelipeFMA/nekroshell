import "root:/widgets"
import "root:/services"
import "root:/config"
import "root:/modules/bar/popouts" as BarPopouts
import "components"
import "components/workspaces"
import Quickshell
import QtQuick

Item {
    id: root

    required property ShellScreen screen
    required property BarPopouts.Wrapper popouts

    function checkPopout(y: real): void {
        const spacing = Appearance.spacing.small;

        const ty = tray.y;
        const th = tray.implicitHeight;
        const trayItems = tray.items;

        const n = statusIconsInner.network;
        const ny = statusIcons.y + statusIconsInner.y + n.y - spacing / 2;

        const bls = statusIcons.y + statusIconsInner.y + statusIconsInner.bs - spacing / 2;
        const ble = statusIcons.y + statusIconsInner.y + statusIconsInner.be + spacing / 2;

        const b = statusIconsInner.battery;
        const by = statusIcons.y + statusIconsInner.y + b.y - spacing / 2;

        const cy = clockArea.y - spacing / 2;
        const cye = clockArea.y + clockArea.implicitHeight + spacing / 2;

        if (y > ty && y < ty + th) {
            const index = Math.floor(((y - ty) / th) * trayItems.count);
            const item = trayItems.itemAt(index);

            popouts.currentName = `traymenu${index}`;
            popouts.currentCenter = Qt.binding(() => tray.y + item.y + item.implicitHeight / 2);
            popouts.hasCurrent = true;
        } else if (y >= ny && y <= ny + n.implicitHeight + spacing) {
            popouts.currentName = "network";
            popouts.currentCenter = Qt.binding(() => statusIcons.y + statusIconsInner.y + n.y + n.implicitHeight / 2);
            popouts.hasCurrent = true;
        } else if (y >= bls && y <= ble) {
            popouts.currentName = "bluetooth";
            popouts.currentCenter = Qt.binding(() => statusIcons.y + statusIconsInner.y + statusIconsInner.bs + (statusIconsInner.be - statusIconsInner.bs) / 2);
            popouts.hasCurrent = true;
        } else if (y >= by && y <= by + b.implicitHeight + spacing) {
            popouts.currentName = "battery";
            popouts.currentCenter = Qt.binding(() => statusIcons.y + statusIconsInner.y + b.y + b.implicitHeight / 2);
            popouts.hasCurrent = true;
        } else if (y >= cy && y <= cye) {
            popouts.currentName = "calendar";
            popouts.currentCenter = Qt.binding(() => clockArea.y + clockArea.implicitHeight / 2);
            popouts.hasCurrent = true;
        } else {
            popouts.hasCurrent = false;
        }
    }

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.left: parent.left

    implicitWidth: child.implicitWidth + Config.border.thickness * 2

    Item {
        id: child

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        implicitWidth: Math.max(workspaces.implicitWidth, tray.implicitWidth, clock.implicitWidth, statusIcons.implicitWidth, power.implicitWidth)

        StyledRect {
            id: workspaces

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Appearance.padding.large

            radius: Appearance.rounding.full
            color: Colours.palette.m3surfaceContainer

            implicitWidth: workspacesInner.implicitWidth + Appearance.padding.small * 2
            implicitHeight: workspacesInner.implicitHeight + Appearance.padding.small * 2

            MouseArea {
                anchors.fill: parent
                anchors.leftMargin: -Config.border.thickness
                anchors.rightMargin: -Config.border.thickness

                onWheel: event => {
                    const activeWs = WindowManager.activeClient?.workspace?.name;
                    if (activeWs?.startsWith("special:"))
                        WindowManager.dispatch(`togglespecialworkspace ${activeWs.slice(8)}`);
                    else if (event.angleDelta.y < 0 || WindowManager.activeWsId > 1)
                        WindowManager.dispatch(`workspace r${event.angleDelta.y > 0 ? "-" : "+"}1`);
                }
            }

            Workspaces {
                id: workspacesInner

                anchors.centerIn: parent
            }
        }

        Tray {
            id: tray

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: workspaces.bottom
            anchors.topMargin: Appearance.spacing.large
            anchors.bottom: clockArea.top
            anchors.bottomMargin: Appearance.spacing.larger
        }

        Item {
            id: clockArea

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: statusIcons.top
            anchors.bottomMargin: Appearance.spacing.normal

            implicitWidth: clock.implicitWidth
            implicitHeight: clock.implicitHeight

            MouseArea {
                anchors.fill: parent
                anchors.leftMargin: -Config.border.thickness
                anchors.rightMargin: -Config.border.thickness

                hoverEnabled: true

                onPositionChanged: event => {
                    root.checkPopout(event.y + clockArea.y);
                }

                onExited: {
                    if (!popouts.hasCurrent || popouts.currentName !== "calendar") {
                        popouts.hasCurrent = false;
                    }
                }
            }

            Clock {
                id: clock

                anchors.centerIn: parent
            }
        }

        StyledRect {
            id: statusIcons

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: power.top
            anchors.bottomMargin: Appearance.spacing.normal

            radius: Appearance.rounding.full
            color: Colours.palette.m3surfaceContainer

            implicitHeight: statusIconsInner.implicitHeight + Appearance.padding.normal * 2

            MouseArea {
                anchors.fill: parent
                anchors.leftMargin: -Config.border.thickness
                anchors.rightMargin: -Config.border.thickness

                hoverEnabled: true

                onPositionChanged: event => {
                    root.checkPopout(event.y + statusIcons.y);
                }

                onExited: {
                    if (!popouts.hasCurrent || (popouts.currentName !== "network" && popouts.currentName !== "bluetooth" && popouts.currentName !== "battery")) {
                        popouts.hasCurrent = false;
                    }
                }
            }

            StatusIcons {
                id: statusIconsInner

                anchors.centerIn: parent
            }
        }

        Power {
            id: power

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Appearance.padding.large
        }
    }
}
