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

    property bool showPasswordDialog: false
    property string selectedSSID: ""

    width: Config.bar.sizes.networkWidth
    spacing: Appearance.spacing.normal

    // Watch for connection results
    Connections {
        target: Network
        
        function onConnectionResultChanged() {
            if (Network.connectionResult === "need_password") {
                root.showPasswordDialog = true;
            } else if (Network.connectionResult === "success") {
                root.showPasswordDialog = false;
            } else if (Network.connectionResult === "failed") {
                root.showPasswordDialog = false;
                // Could show an error message here
            }
        }
    }

    // Current connection status
    StyledRect {
        width: parent.width
        implicitHeight: connectionInfo.implicitHeight + Appearance.padding.normal * 2
        color: Colours.palette.m3surfaceContainer
        radius: Appearance.rounding.normal

        Column {
            id: connectionInfo
            anchors.centerIn: parent
            spacing: Appearance.spacing.small

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Appearance.spacing.normal

                MaterialIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Network.active ? Icons.getNetworkIcon(Network.active.strength ?? 0) : "wifi_off"
                    color: Network.active ? Colours.palette.m3primary : Colours.palette.m3outline
                }

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Network.active ? Network.active.ssid : qsTr("Not Connected")
                    font.weight: 600
                    color: Network.active ? Colours.palette.m3onSurface : Colours.palette.m3outline
                }
            }

            StyledText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Network.active ? qsTr("Signal: %1%").arg(Network.active.strength) : qsTr("No active connection")
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
                visible: Network.active
            }

            // Disconnect button
            Loader {
                anchors.horizontalCenter: parent.horizontalCenter
                active: Network.active
                
                sourceComponent: StyledRect {
                    implicitWidth: disconnectText.implicitWidth + Appearance.padding.normal * 2
                    implicitHeight: disconnectText.implicitHeight + Appearance.padding.small * 2
                    color: Colours.palette.m3errorContainer
                    radius: Appearance.rounding.full

                    StyledText {
                        id: disconnectText
                        anchors.centerIn: parent
                        text: qsTr("Disconnect")
                        color: Colours.palette.m3onErrorContainer
                        font.pointSize: Appearance.font.size.small
                    }

                    StateLayer {
                        radius: parent.radius
                        color: Colours.palette.m3onErrorContainer

                        function onClicked(): void {
                            Network.disconnectFromNetwork();
                        }
                    }
                }
            }
        }
    }

    // Available networks header with refresh button
    Row {
        width: parent.width
        spacing: Appearance.spacing.normal

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Available Networks")
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
            text: "refresh"
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small

            RotationAnimation on rotation {
                loops: Animation.Infinite
                duration: 1000
                from: 0
                to: 360
                running: false // We could add a scanning state to Network service
            }

            StateLayer {
                anchors.centerIn: parent
                implicitWidth: parent.implicitWidth + Appearance.padding.small * 2
                implicitHeight: parent.implicitHeight + Appearance.padding.small * 2
                radius: Appearance.rounding.full
                color: Colours.palette.m3onSurfaceVariant

                function onClicked(): void {
                    Network.refreshNetworks();
                }
            }
        }
    }

    StyledRect {
        width: parent.width
        implicitHeight: Math.min(networksList.contentHeight + Appearance.padding.normal * 2, 300)
        color: Colours.palette.m3surfaceContainer
        radius: Appearance.rounding.normal

        ListView {
            id: networksList
            anchors.fill: parent
            anchors.margins: Appearance.padding.normal
            clip: true
            spacing: Appearance.spacing.small

            model: ScriptModel {
                values: Network.networks.filter(n => !n.active).sort((a, b) => (b.strength || 0) - (a.strength || 0))
            }

            delegate: StyledRect {
                required property Network.AccessPoint modelData
                
                width: networksList.width
                implicitHeight: networkContent.implicitHeight + Appearance.padding.small * 2
                color: "transparent"
                radius: Appearance.rounding.normal

                Item {
                    id: networkContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: Appearance.padding.small
                    anchors.rightMargin: Appearance.padding.small
                    implicitHeight: Math.max(networkIcon.implicitHeight, networkInfo.implicitHeight)

                    MaterialIcon {
                        id: networkIcon
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: Icons.getNetworkIcon(modelData.strength)
                        color: Colours.palette.m3primary
                        font.pointSize: Appearance.font.size.normal
                    }

                    Column {
                        id: networkInfo
                        anchors.left: networkIcon.right
                        anchors.leftMargin: Appearance.spacing.normal
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        StyledText {
                            text: modelData.ssid
                            color: Colours.palette.m3onSurface
                            font.weight: 500
                        }

                        StyledText {
                            text: qsTr("%1% • %2 MHz").arg(modelData.strength).arg(modelData.frequency)
                            color: Colours.palette.m3onSurfaceVariant
                            font.pointSize: Appearance.font.size.small
                        }
                    }

                    MaterialIcon {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: "lock"
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
                        visible: modelData.isSecured
                    }
                }

                StateLayer {
                    id: stateLayer
                    radius: parent.radius
                    color: Colours.palette.m3onSurface

                    function onClicked() {
                        root.selectedSSID = modelData.ssid;
                        if (modelData.isSecured) {
                            // Try to connect with saved credentials first
                            Network.connectToNetwork(modelData.ssid);
                            // If it fails, the connection result will trigger password dialog
                        } else {
                            // Connect directly to open network
                            Network.connectToNetwork(modelData.ssid);
                        }
                    }
                }
            }
        }
    }

    // Password Dialog
    Loader {
        anchors.horizontalCenter: parent.horizontalCenter
        active: root.showPasswordDialog
        
        sourceComponent: StyledRect {
            width: root.width
            implicitHeight: passwordContent.implicitHeight + Appearance.padding.normal * 2
            color: Colours.palette.m3surfaceContainerHigh
            radius: Appearance.rounding.normal
            border.width: 1
            border.color: Colours.palette.m3outline

            Column {
                id: passwordContent
                anchors.centerIn: parent
                spacing: Appearance.spacing.normal
                width: parent.width - Appearance.padding.normal * 2

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Connect to %1").arg(root.selectedSSID)
                    font.weight: 600
                    color: Colours.palette.m3onSurface
                }

                StyledTextField {
                    id: passwordField
                    width: parent.width
                    placeholderText: qsTr("Password")
                    echoMode: TextInput.Password
                    passwordCharacter: "●"
                    passwordMaskDelay: 0
                    selectByMouse: true
                    
                    // Override colors for better visibility in password mode
                    color: Colours.palette.m3onSurface
                    
                    Keys.onReturnPressed: connectButton.clicked()
                    Keys.onEscapePressed: {
                        root.showPasswordDialog = false;
                        text = "";
                    }
                    
                    Component.onCompleted: {
                        Qt.callLater(() => {
                            forceActiveFocus();
                        });
                    }
                    
                    onVisibleChanged: {
                        if (visible) {
                            Qt.callLater(() => {
                                forceActiveFocus();
                            });
                        }
                    }
                    
                    // Additional focus timer to ensure focus is gained
                    Timer {
                        interval: 100
                        running: passwordField.visible
                        onTriggered: {
                            if (!passwordField.activeFocus) {
                                passwordField.forceActiveFocus();
                            }
                        }
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Appearance.spacing.normal

                    StyledRect {
                        implicitWidth: cancelText.implicitWidth + Appearance.padding.normal * 2
                        implicitHeight: cancelText.implicitHeight + Appearance.padding.small * 2
                        color: Colours.palette.m3surfaceVariant
                        radius: Appearance.rounding.full

                        StyledText {
                            id: cancelText
                            anchors.centerIn: parent
                            text: qsTr("Cancel")
                            color: Colours.palette.m3onSurfaceVariant
                        }

                        StateLayer {
                            radius: parent.radius
                            color: Colours.palette.m3onSurfaceVariant

                            function onClicked(): void {
                                root.showPasswordDialog = false;
                                passwordField.text = "";
                            }
                        }
                    }

                    StyledRect {
                        id: connectButton
                        implicitWidth: connectText.implicitWidth + Appearance.padding.normal * 2
                        implicitHeight: connectText.implicitHeight + Appearance.padding.small * 2
                        color: Colours.palette.m3primary
                        radius: Appearance.rounding.full

                        function clicked() {
                            Network.connectToNetwork(root.selectedSSID, passwordField.text);
                            root.showPasswordDialog = false;
                            passwordField.text = "";
                        }

                        StyledText {
                            id: connectText
                            anchors.centerIn: parent
                            text: qsTr("Connect")
                            color: Colours.palette.m3onPrimary
                        }

                        StateLayer {
                            id: connectStateLayer
                            radius: parent.radius
                            color: Colours.palette.m3onPrimary

                            function onClicked() {
                                connectButton.clicked();
                            }
                        }
                    }
                }
            }
        }
    }
}
