import "root:/widgets"
import "root:/services"
import "root:/config"
import "root:/utils"
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Effects

Item {
    id: root

    anchors.fill: parent

    // Reset state when becoming visible again (fixes second lock issue)
    onVisibleChanged: {
        if (visible) {
            console.log("Lockscreen content becoming visible - resetting state");
            // Reset auth state
            passwordContainer.authState = "idle";
            passwordField.text = "";
            
            // Reset animation state and restart entrance animation
            mainContainer.scale = 0.8;
            mainContainer.opacity = 0;
            entranceAnimation.restart();
            
            // Set focus after a short delay to ensure UI is ready
            Qt.callLater(() => passwordField.forceActiveFocus());
        }
    }

    // Blurred background with wallpaper
    Item {
        id: backgroundLayer
        anchors.fill: parent
        visible: false

        // Current wallpaper as background
        CachingImage {
            id: wallpaperImage
            anchors.fill: parent
            path: (Wallpapers.actualCurrent && width > 0 && height > 0) ? Wallpapers.actualCurrent : ""
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            
            onStatusChanged: {
                if (status === Image.Error) {
                    console.warn("Failed to load wallpaper for lockscreen background")
                }
            }
        }
    }

    // Apply blur effect to background
    MultiEffect {
        id: blurEffect
        anchors.fill: parent
        source: backgroundLayer
        blurEnabled: Config.lockscreen.enableBlur
        blur: 1.0
        blurMax: Config.lockscreen.blurRadius
        blurMultiplier: 2.0
        
        // Add slight darkening overlay for better contrast
        Rectangle {
            anchors.fill: parent
            color: Colours.palette.m3scrim
            opacity: Config.lockscreen.backgroundOpacity
        }
    }

    // Main lockscreen content container
    StyledRect {
        id: mainContainer
        
        anchors.centerIn: parent
        implicitWidth: Math.min(parent.width * Config.lockscreen.sizes.containerWidthRatio, Config.lockscreen.sizes.containerWidth)
        implicitHeight: clockContainer.implicitHeight + authContainer.implicitHeight + Appearance.spacing.large * 3

        radius: Appearance.rounding.large
        color: Colours.alpha(Colours.palette.m3surface, true)

        // Drop shadow
        RectangularShadow {
            anchors.fill: parent
            radius: parent.radius
            color: Qt.alpha(Colours.palette.m3shadow, 0.5)
            blur: 20
            spread: 5
        }

        Column {
            anchors.fill: parent
            anchors.margins: Appearance.padding.large * 2
            spacing: Appearance.spacing.large

            // Clock and date section
            Item {
                id: clockContainer
                anchors.horizontalCenter: parent.horizontalCenter
                implicitWidth: timeText.implicitWidth
                implicitHeight: timeText.implicitHeight + dateText.implicitHeight + Appearance.spacing.normal

                Column {
                    anchors.centerIn: parent
                    spacing: Appearance.spacing.normal

                    StyledText {
                        id: timeText
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Time.format("h:mm")
                        font.pointSize: Config.lockscreen.sizes.clockFontSize
                        font.weight: 300
                        color: Colours.palette.m3onSurface
                        horizontalAlignment: Text.AlignHCenter
                        visible: Config.lockscreen.showClock
                    }

                    StyledText {
                        id: dateText
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Time.format("dddd, MMMM d")
                        font.pointSize: Config.lockscreen.sizes.dateFontSize
                        color: Colours.palette.m3onSurfaceVariant
                        horizontalAlignment: Text.AlignHCenter
                        visible: Config.lockscreen.showDate
                    }
                }
            }

            // Authentication section
            Item {
                id: authContainer
                anchors.horizontalCenter: parent.horizontalCenter
                implicitWidth: Math.max(userInfo.implicitWidth, authForm.implicitWidth)
                implicitHeight: userInfo.implicitHeight + authForm.implicitHeight + Appearance.spacing.large

                Column {
                    anchors.centerIn: parent
                    spacing: Appearance.spacing.large

                    // User info section
                    Row {
                        id: userInfo
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Appearance.spacing.normal

                        StyledClippingRect {
                            anchors.verticalCenter: parent.verticalCenter
                            implicitWidth: Config.lockscreen.sizes.avatarSize
                            implicitHeight: Config.lockscreen.sizes.avatarSize
                            radius: Appearance.rounding.full
                            color: Colours.palette.m3surfaceContainerHigh
                            visible: Config.lockscreen.showUserInfo

                            MaterialIcon {
                                anchors.centerIn: parent
                                text: "person"
                                fill: 1
                                font.pointSize: Appearance.font.size.large
                                color: Colours.palette.m3onSurface
                            }

                            // Try to load user face image if available
                            CachingImage {
                                anchors.fill: parent
                                path: `${Paths.home}/.face`
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Appearance.spacing.small / 2
                            visible: Config.lockscreen.showUserInfo

                            StyledText {
                                text: Quickshell.env("USER") || "User"
                                font.pointSize: Appearance.font.size.larger
                                font.weight: 500
                                color: Colours.palette.m3onSurface
                            }

                            StyledText {
                                text: qsTr("Enter password to unlock")
                                font.pointSize: Appearance.font.size.normal
                                color: Colours.palette.m3onSurfaceVariant
                            }
                        }
                    }

                    // Authentication form
                    Column {
                        id: authForm
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Appearance.spacing.normal

                        // Password field
                        StyledRect {
                            id: passwordContainer
                            
                            anchors.horizontalCenter: parent.horizontalCenter
                            implicitWidth: 300
                            implicitHeight: passwordField.implicitHeight + Appearance.padding.normal * 2

                            property string authState: "idle" // idle, authenticating, error, success

                            radius: Appearance.rounding.normal
                            color: Colours.alpha(Colours.palette.m3surfaceContainer, true)
                            border.width: passwordField.activeFocus ? 2 : 0
                            border.color: passwordContainer.authState === "error" ? Colours.palette.m3error : Colours.palette.m3primary

                            // Password input field
                            StyledTextField {
                                id: passwordField
                                
                                anchors.centerIn: parent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.margins: Appearance.padding.normal
                                
                                echoMode: TextInput.Password
                                passwordCharacter: "●"
                                passwordMaskDelay: 0
                                placeholderText: qsTr("Password")
                                background: null
                                color: Colours.palette.m3onSurface
                                placeholderTextColor: Colours.palette.m3onSurfaceVariant
                                font.pointSize: Appearance.font.size.normal

                                onAccepted: authenticate()
                                
                                function authenticate() {
                                    console.log("authenticate() called with text:", text);
                                    if (text.length === 0) {
                                        console.log("Empty password, returning");
                                        return;
                                    }
                                    console.log("Setting auth state to authenticating");
                                    passwordContainer.authState = "authenticating";
                                    console.log("Calling LockscreenService.authenticate");
                                    LockscreenService.authenticate(text);
                                }

                                // Listen to authentication results
                                Connections {
                                    target: LockscreenService
                                    
                                    function onAuthenticationSucceeded() {
                                        passwordContainer.authState = "success";
                                        unlockAnimation.start();
                                    }
                                    
                                    function onAuthenticationFailed() {
                                        passwordContainer.authState = "error";
                                        errorTimer.start();
                                        shakeAnimation.start();
                                        passwordField.text = "";
                                    }
                                }

                                // Error state timer
                                Timer {
                                    id: errorTimer
                                    interval: 2000
                                    onTriggered: passwordContainer.authState = "idle"
                                }

                                // Shake animation for errors
                                SequentialAnimation {
                                    id: shakeAnimation
                                    
                                    NumberAnimation {
                                        target: passwordContainer
                                        property: "x"
                                        from: passwordContainer.x
                                        to: passwordContainer.x - 10
                                        duration: 100
                                        easing.type: Easing.OutQuad
                                    }
                                    NumberAnimation {
                                        target: passwordContainer
                                        property: "x"
                                        to: passwordContainer.x + 10
                                        duration: 100
                                        easing.type: Easing.InOutQuad
                                    }
                                    NumberAnimation {
                                        target: passwordContainer
                                        property: "x"
                                        to: passwordContainer.x - 5
                                        duration: 100
                                        easing.type: Easing.InOutQuad
                                    }
                                    NumberAnimation {
                                        target: passwordContainer
                                        property: "x"
                                        to: passwordContainer.x
                                        duration: 100
                                        easing.type: Easing.InQuad
                                    }
                                }

                                Component.onCompleted: forceActiveFocus()
                            }

                            // Loading indicator
                            StyledRect {
                                id: loadingIndicator
                                
                                anchors.right: parent.right
                                anchors.rightMargin: Appearance.padding.normal
                                anchors.verticalCenter: parent.verticalCenter
                                
                                implicitWidth: 20
                                implicitHeight: 20
                                radius: Appearance.rounding.full
                                color: Colours.palette.m3primary
                                
                                visible: passwordContainer.authState === "authenticating"
                                
                                RotationAnimation {
                                    target: loadingIndicator
                                    property: "rotation"
                                    from: 0
                                    to: 360
                                    duration: 1000
                                    loops: Animation.Infinite
                                    running: loadingIndicator.visible
                                }
                            }
                        }

                        // Error message
                        StyledText {
                            id: errorMessage
                            
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("Authentication failed")
                            color: Colours.palette.m3error
                            font.pointSize: Appearance.font.size.normal
                            opacity: passwordContainer.authState === "error" ? 1 : 0
                            
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Appearance.anim.durations.normal
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: Appearance.anim.curves.standard
                                }
                            }
                        }

                        // Unlock button
                        StyledRect {
                            id: unlockButton
                            
                            anchors.horizontalCenter: parent.horizontalCenter
                            implicitWidth: 120
                            implicitHeight: 40
                            
                            radius: Appearance.rounding.full
                            color: passwordField.text.length > 0 ? Colours.palette.m3primary : Colours.palette.m3surfaceContainer
                            
                            StateLayer {
                                radius: parent.radius
                                color: Colours.palette.m3onPrimary
                                enabled: passwordField.text.length > 0
                                
                                function onClicked() {
                                    passwordField.authenticate();
                                }
                            }
                            
                            StyledText {
                                anchors.centerIn: parent
                                text: qsTr("Unlock")
                                color: passwordField.text.length > 0 ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
                                font.pointSize: Appearance.font.size.normal
                                font.weight: 500
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
                }
            }
        }
    }

    // Unlock animation
    SequentialAnimation {
        id: unlockAnimation
        
        ParallelAnimation {
            NumberAnimation {
                target: mainContainer
                property: "scale"
                to: 1.1
                duration: Appearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.standard
            }
            NumberAnimation {
                target: mainContainer
                property: "opacity"
                to: 0
                duration: Appearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.standard
            }
        }
        
        ScriptAction {
            script: LockscreenService.unlock()
        }
    }

    // Entrance animation
    ParallelAnimation {
        id: entranceAnimation
        
        NumberAnimation {
            target: mainContainer
            property: "scale"
            from: 0.8
            to: 1
            duration: Appearance.anim.durations.large
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.emphasizedDecel
        }
        NumberAnimation {
            target: mainContainer
            property: "opacity"
            from: 0
            to: 1
            duration: Appearance.anim.durations.large
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.emphasizedDecel
        }
    }

    Component.onCompleted: {
        if (visible) {
            mainContainer.scale = 0.8;
            mainContainer.opacity = 0;
            entranceAnimation.start();
        }
    }
}
