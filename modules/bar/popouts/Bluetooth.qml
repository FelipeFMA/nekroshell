pragma ComponentBehavior: Bound

import "root:/widgets"
import "root:/services"
import "root:/utils"
import "root:/config"
import Quickshell
import QtQuick
import QtQuick.Controls

Column {
    id: root

    width: Config.bar.sizes.networkWidth
    spacing: Appearance.spacing.normal

    // Bluetooth Power Toggle
    StyledRect {
        width: parent.width
        implicitHeight: powerToggle.implicitHeight + Appearance.padding.normal * 2
        color: Colours.palette.m3surfaceContainer
        radius: Appearance.rounding.normal

        Row {
            id: powerToggle
            anchors.centerIn: parent
            spacing: Appearance.spacing.normal

            MaterialIcon {
                anchors.verticalCenter: parent.verticalCenter
                text: Bluetooth.powered ? "bluetooth" : "bluetooth_disabled"
                color: Bluetooth.powered ? Colours.palette.m3primary : Colours.palette.m3outline
                font.pointSize: Appearance.font.size.normal
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                StyledText {
                    text: qsTr("Bluetooth")
                    font.weight: 600
                    color: Colours.palette.m3onSurface
                }

                StyledText {
                    text: Bluetooth.powered ? qsTr("Enabled") : qsTr("Disabled")
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.small
                }
            }

            Item {
                // Spacer
                width: Math.max(0, root.width - powerToggle.children[0].implicitWidth - powerToggle.children[1].implicitWidth - toggleSwitch.implicitWidth - powerToggle.spacing * 3 - Appearance.padding.normal * 6)
                height: 1
            }

            // Toggle Switch
            StyledRect {
                id: toggleSwitch
                anchors.verticalCenter: parent.verticalCenter
                width: 48
                height: 24
                radius: 12
                color: Bluetooth.powered ? Colours.palette.m3primary : Colours.palette.m3outline

                StyledRect {
                    id: toggleHandle
                    width: 20
                    height: 20
                    radius: 10
                    color: Bluetooth.powered ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Behavior on x {
                        NumberAnimation { duration: 150 }
                    }
                    
                    x: Bluetooth.powered ? parent.width - width - 2 : 2
                }

                StateLayer {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Colours.palette.m3onSurface

                    function onClicked(): void {
                        console.log("Toggle clicked, current state:", Bluetooth.powered);
                        Bluetooth.setPower(!Bluetooth.powered);
                    }
                }
            }
        }
    }

    // Connected devices section
    Loader {
        width: parent.width
        active: Bluetooth.powered && Bluetooth.devices.some(d => d.connected)

        sourceComponent: StyledRect {
            width: root.width
            implicitHeight: connectedDevices.implicitHeight + Appearance.padding.normal * 2
            color: Colours.palette.m3surfaceContainer
            radius: Appearance.rounding.normal

            Column {
                id: connectedDevices
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: Appearance.padding.normal
                spacing: Appearance.spacing.small

                StyledText {
                    text: qsTr("Connected Devices")
                    font.weight: 600
                    color: Colours.palette.m3primary
                    font.pointSize: Appearance.font.size.small
                }

                Repeater {
                    model: ScriptModel {
                        values: Bluetooth.devices.filter(d => d.connected)
                    }

                    delegate: Item {
                        required property Bluetooth.Device modelData
                        
                        width: connectedDevices.width
                        implicitHeight: connectedDeviceContent.implicitHeight

                        Row {
                            id: connectedDeviceContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Appearance.spacing.normal

                            MaterialIcon {
                                anchors.verticalCenter: parent.verticalCenter
                                text: Icons.getBluetoothIcon(modelData.icon || "")
                                color: Colours.palette.m3primary
                                font.pointSize: Appearance.font.size.small
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2

                                StyledText {
                                    text: modelData.alias || modelData.name
                                    color: Colours.palette.m3onSurface
                                    font.weight: 500
                                    font.pointSize: Appearance.font.size.small
                                }

                                StyledText {
                                    text: qsTr("Connected")
                                    color: Colours.palette.m3primary
                                    font.pointSize: Appearance.font.size.tiny
                                }
                            }

                            Item {
                                // Spacer
                                width: parent.width - parent.children[0].implicitWidth - parent.children[1].implicitWidth - disconnectBtn.implicitWidth - parent.spacing * 3
                                height: 1
                            }

                            StyledRect {
                                id: disconnectBtn
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: disconnectText.implicitWidth + Appearance.padding.small * 2
                                implicitHeight: disconnectText.implicitHeight + Appearance.padding.tiny * 2
                                color: Colours.palette.m3errorContainer
                                radius: Appearance.rounding.full

                                StyledText {
                                    id: disconnectText
                                    anchors.centerIn: parent
                                    text: qsTr("Disconnect")
                                    color: Colours.palette.m3onErrorContainer
                                    font.pointSize: Appearance.font.size.tiny
                                }

                                StateLayer {
                                    radius: parent.radius
                                    color: Colours.palette.m3onErrorContainer

                                    function onClicked(): void {
                                        Bluetooth.disconnectDevice(modelData.address);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Available devices header with scan button
    Loader {
        width: parent.width
        active: Bluetooth.powered

        sourceComponent: Row {
            width: root.width
            spacing: Appearance.spacing.normal

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Available Devices")
                font.weight: 600
                color: Colours.palette.m3onSurface
            }

            Item {
                // Spacer
                width: parent.width - parent.children[0].implicitWidth - parent.children[2].implicitWidth - parent.spacing * 2
                height: 1
            }

            MaterialIcon {
                anchors.verticalCenter: parent.verticalCenter
                text: "search"
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small

                RotationAnimation on rotation {
                    loops: Animation.Infinite
                    duration: 2000
                    from: 0
                    to: 360
                    running: Bluetooth.discovering
                }

                StateLayer {
                    anchors.centerIn: parent
                    implicitWidth: parent.implicitWidth + Appearance.padding.small * 2
                    implicitHeight: parent.implicitHeight + Appearance.padding.small * 2
                    radius: Appearance.rounding.full
                    color: Colours.palette.m3onSurfaceVariant

                    function onClicked(): void {
                        console.log("Scan clicked, current discovering state:", Bluetooth.discovering);
                        if (Bluetooth.discovering) {
                            Bluetooth.stopDiscovery();
                        } else {
                            Bluetooth.startDiscovery();
                        }
                    }
                }
            }
        }
    }

    // Available devices list
    Loader {
        width: parent.width
        active: Bluetooth.powered

        sourceComponent: StyledRect {
            width: root.width
            implicitHeight: Math.min(devicesList.contentHeight + Appearance.padding.normal * 2, 300)
            color: Colours.palette.m3surfaceContainer
            radius: Appearance.rounding.normal

            ListView {
                id: devicesList
                anchors.fill: parent
                anchors.margins: Appearance.padding.normal
                clip: true
                spacing: Appearance.spacing.small

                model: ScriptModel {
                    values: Bluetooth.devices.filter(d => !d.connected)
                }

                delegate: StyledRect {
                    required property Bluetooth.Device modelData
                    
                    width: devicesList.width
                    implicitHeight: deviceContent.implicitHeight + Appearance.padding.small * 2
                    color: "transparent"
                    radius: Appearance.rounding.normal

                    Item {
                        id: deviceContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: Appearance.padding.small
                        anchors.rightMargin: Appearance.padding.small
                        implicitHeight: Math.max(deviceIcon.implicitHeight, deviceInfo.implicitHeight)

                        MaterialIcon {
                            id: deviceIcon
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: Icons.getBluetoothIcon(modelData.icon || "")
                            color: modelData.paired ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                            font.pointSize: Appearance.font.size.normal
                        }

                        Column {
                            id: deviceInfo
                            anchors.left: deviceIcon.right
                            anchors.leftMargin: Appearance.spacing.normal
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            StyledText {
                                text: modelData.alias || modelData.name
                                color: Colours.palette.m3onSurface
                                font.weight: 500
                            }

                            Row {
                                spacing: Appearance.spacing.small

                                StyledText {
                                    text: modelData.paired ? qsTr("Paired") : qsTr("Not paired")
                                    color: modelData.paired ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                                    font.pointSize: Appearance.font.size.small
                                }

                                StyledText {
                                    text: "•"
                                    color: Colours.palette.m3onSurfaceVariant
                                    font.pointSize: Appearance.font.size.small
                                    visible: modelData.trusted
                                }

                                StyledText {
                                    text: qsTr("Trusted")
                                    color: Colours.palette.m3onSurfaceVariant
                                    font.pointSize: Appearance.font.size.small
                                    visible: modelData.trusted
                                }
                            }
                        }

                        Row {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Appearance.spacing.small

                            // Connect/Pair button
                            StyledRect {
                                visible: modelData.paired
                                implicitWidth: connectText.implicitWidth + Appearance.padding.small * 2
                                implicitHeight: connectText.implicitHeight + Appearance.padding.tiny * 2
                                color: Colours.palette.m3primaryContainer
                                radius: Appearance.rounding.full

                                StyledText {
                                    id: connectText
                                    anchors.centerIn: parent
                                    text: qsTr("Connect")
                                    color: Colours.palette.m3onPrimaryContainer
                                    font.pointSize: Appearance.font.size.tiny
                                }

                                StateLayer {
                                    radius: parent.radius
                                    color: Colours.palette.m3onPrimaryContainer

                                    function onClicked(): void {
                                        Bluetooth.connectDevice(modelData.address);
                                    }
                                }
                            }

                            StyledRect {
                                visible: !modelData.paired
                                implicitWidth: pairText.implicitWidth + Appearance.padding.small * 2
                                implicitHeight: pairText.implicitHeight + Appearance.padding.tiny * 2
                                color: Colours.palette.m3secondaryContainer
                                radius: Appearance.rounding.full

                                StyledText {
                                    id: pairText
                                    anchors.centerIn: parent
                                    text: qsTr("Pair")
                                    color: Colours.palette.m3onSecondaryContainer
                                    font.pointSize: Appearance.font.size.tiny
                                }

                                StateLayer {
                                    radius: parent.radius
                                    color: Colours.palette.m3onSecondaryContainer

                                    function onClicked(): void {
                                        Bluetooth.pairDevice(modelData.address);
                                        if (!modelData.trusted) {
                                            Bluetooth.trustDevice(modelData.address);
                                        }
                                    }
                                }
                            }
                        }
                    }

                    StateLayer {
                        id: stateLayer
                        radius: parent.radius
                        color: Colours.palette.m3onSurface
                        enabled: false // Disable general click since we have specific buttons
                    }
                }
            }
        }
    }

    // No bluetooth message
    Loader {
        width: parent.width
        active: !Bluetooth.powered

        sourceComponent: StyledRect {
            width: root.width
            implicitHeight: noBluetoothContent.implicitHeight + Appearance.padding.normal * 2
            color: Colours.palette.m3surfaceContainer
            radius: Appearance.rounding.normal

            Column {
                id: noBluetoothContent
                anchors.centerIn: parent
                spacing: Appearance.spacing.small

                MaterialIcon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "bluetooth_disabled"
                    color: Colours.palette.m3outline
                    font.pointSize: Appearance.font.size.large
                }

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Bluetooth is disabled")
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.small
                }

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Enable Bluetooth to see devices")
                    color: Colours.palette.m3outline
                    font.pointSize: Appearance.font.size.tiny
                }
            }
        }
    }
}
