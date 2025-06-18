pragma ComponentBehavior: Bound

import "root:/widgets"
import "root:/services"
import "root:/config"
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root

    required property Notifs.Notif modelData
    readonly property bool hasImage: modelData.image.length > 0
    readonly property bool hasAppIcon: modelData.appIcon.length > 0
    readonly property int nonAnimHeight: summary.implicitHeight + (root.expanded ? appName.height + body.height + actions.height + actions.anchors.topMargin : bodyPreview.height) + inner.anchors.margins * 2
    property bool expanded

    color: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3secondaryContainer : Colours.palette.m3surfaceContainer
    radius: Appearance.rounding.normal
    implicitWidth: Config.notifs.sizes.width
    implicitHeight: inner.implicitHeight

    x: Config.notifs.sizes.width
    Component.onCompleted: x = 0

    RetainableLock {
        object: root.modelData.notification
        locked: true
    }

    MouseArea {
        property int startY

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: pressed ? Qt.ClosedHandCursor : undefined
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        preventStealing: true

        onEntered: root.modelData.timer.stop()
        onExited: root.modelData.timer.start()

        drag.target: parent
        drag.axis: Drag.XAxis

        onPressed: event => {
            startY = event.y;
            if (event.button === Qt.MiddleButton)
                root.modelData.notification.dismiss();
        }
        onReleased: event => {
            if (Math.abs(root.x) < Config.notifs.sizes.width * Config.notifs.clearThreshold)
                root.x = 0;
            else
                root.modelData.popup = false;
        }
        onPositionChanged: event => {
            if (pressed) {
                const diffY = event.y - startY;
                if (Math.abs(diffY) > Config.notifs.expandThreshold)
                    root.expanded = diffY > 0;
            }
        }
        onClicked: event => {
            if (!Config.notifs.actionOnClick || event.button !== Qt.LeftButton)
                return;

            const actions = root.modelData.actions;
            if (actions?.length === 1)
                actions[0].invoke();
        }
    }

    Behavior on x {
        NumberAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.emphasizedDecel
        }
    }

    Item {
        id: inner

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Appearance.padding.normal

        implicitHeight: root.nonAnimHeight

        Behavior on implicitHeight {
            Anim {
                duration: Appearance.anim.durations.expressiveDefaultSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            }
        }

        Loader {
            id: image

            active: root.hasImage
            asynchronous: true

            anchors.left: parent.left
            anchors.top: parent.top
            width: Config.notifs.sizes.image
            height: Config.notifs.sizes.image
            visible: root.hasImage || root.hasAppIcon

            sourceComponent: ClippingRectangle {
                radius: Appearance.rounding.full
                implicitWidth: Config.notifs.sizes.image
                implicitHeight: Config.notifs.sizes.image

                Image {
                    anchors.fill: parent
                    source: Qt.resolvedUrl(root.modelData.image)
                    fillMode: Image.PreserveAspectCrop
                    cache: false
                    asynchronous: true
                }
            }
        }

        Loader {
            id: appIcon

            active: root.hasAppIcon || !root.hasImage
            asynchronous: true

            anchors.horizontalCenter: root.hasImage ? undefined : image.horizontalCenter
            anchors.verticalCenter: root.hasImage ? undefined : image.verticalCenter
            anchors.right: root.hasImage ? image.right : undefined
            anchors.bottom: root.hasImage ? image.bottom : undefined

            sourceComponent: StyledRect {
                radius: Appearance.rounding.full
                color: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3error : root.modelData.urgency === NotificationUrgency.Low ? Colours.palette.m3surfaceContainerHighest : Colours.palette.m3tertiaryContainer
                implicitWidth: root.hasImage ? Config.notifs.sizes.badge : Config.notifs.sizes.image
                implicitHeight: root.hasImage ? Config.notifs.sizes.badge : Config.notifs.sizes.image

                Loader {
                    id: icon

                    active: root.hasAppIcon
                    asynchronous: true

                    anchors.centerIn: parent
                    visible: !root.modelData.appIcon.endsWith("symbolic")

                    width: Math.round(parent.width * 0.6)
                    height: Math.round(parent.width * 0.6)

                    sourceComponent: Item {
                        implicitWidth: Math.round(parent.width * 0.6)
                        implicitHeight: Math.round(parent.width * 0.6)

                        // Try to load as image first if it's a file path
                        Image {
                            id: fileImage
                            anchors.fill: parent
                            source: {
                                const isFilePath = root.modelData.appIcon.startsWith("file://") || root.modelData.appIcon.startsWith("/");
                                if (isFilePath) {
                                    console.log("Loading notification icon as file:", root.modelData.appIcon);
                                    return root.modelData.appIcon;
                                }
                                return "";
                            }
                            asynchronous: true
                            cache: false
                            fillMode: Image.PreserveAspectFit
                            visible: status === Image.Ready
                            
                            onStatusChanged: {
                                if (status === Image.Error) {
                                    console.warn("Failed to load notification icon file:", root.modelData.appIcon);
                                }
                            }
                        }

                        // Fallback to icon if image fails or if it's not a file path
                        IconImage {
                            anchors.fill: parent
                            source: {
                                const isFilePath = root.modelData.appIcon.startsWith("file://") || root.modelData.appIcon.startsWith("/");
                                if (isFilePath) {
                                    // For file paths that failed, try common browser icon names
                                    if (fileImage.status === Image.Error) {
                                        return Quickshell.iconPath("google-chrome") || Quickshell.iconPath("web-browser") || Quickshell.iconPath("application-x-executable");
                                    }
                                    return ""; // Don't try to load file paths as icon names
                                }
                                const iconPath = Quickshell.iconPath(root.modelData.appIcon, "web");
                                console.log("Loading notification icon from theme:", root.modelData.appIcon, "->", iconPath);
                                return iconPath;
                            }
                            asynchronous: true
                            visible: fileImage.status !== Image.Ready
                        }
                    }
                }

                Loader {
                    active: root.modelData.appIcon.endsWith("symbolic")
                    asynchronous: true
                    anchors.fill: icon

                    sourceComponent: Colouriser {
                        source: icon
                        colorizationColor: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3onError : root.modelData.urgency === NotificationUrgency.Low ? Colours.palette.m3onSurface : Colours.palette.m3onTertiaryContainer
                    }
                }

                Loader {
                    active: !root.hasAppIcon
                    asynchronous: true
                    anchors.centerIn: parent

                    sourceComponent: MaterialIcon {
                        text: {
                            const summary = root.modelData.summary.toLowerCase();
                            if (summary.includes("reboot"))
                                return "restart_alt";
                            if (summary.includes("recording"))
                                return "screen_record";
                            if (summary.includes("battery"))
                                return "power";
                            if (summary.includes("screenshot"))
                                return "screenshot_monitor";
                            if (summary.includes("welcome"))
                                return "waving_hand";
                            if (summary.includes("time") || summary.includes("a break"))
                                return "schedule";
                            if (summary.includes("installed"))
                                return "download";
                            if (summary.includes("update"))
                                return "update";
                            if (summary.startsWith("file"))
                                return "folder_copy";
                            if (root.modelData.urgency === NotificationUrgency.Critical)
                                return "release_alert";
                            return "chat";
                        }

                        color: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3onError : root.modelData.urgency === NotificationUrgency.Low ? Colours.palette.m3onSurface : Colours.palette.m3onTertiaryContainer
                        font.pointSize: Appearance.font.size.large
                    }
                }
            }
        }

        StyledText {
            id: appName

            anchors.top: parent.top
            anchors.left: image.right
            anchors.leftMargin: Appearance.spacing.smaller

            animate: true
            text: appNameMetrics.elidedText
            maximumLineCount: 1
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small

            opacity: root.expanded ? 1 : 0

            Behavior on opacity {
                Anim {}
            }
        }

        TextMetrics {
            id: appNameMetrics

            text: root.modelData.appName
            font.family: appName.font.family
            font.pointSize: appName.font.pointSize
            elide: Text.ElideRight
            elideWidth: expandBtn.x - time.width - timeSep.width - summary.x - Appearance.spacing.small * 3
        }

        StyledText {
            id: summary

            anchors.top: parent.top
            anchors.left: image.right
            anchors.leftMargin: Appearance.spacing.smaller

            animate: true
            text: summaryMetrics.elidedText
            maximumLineCount: 1
            height: implicitHeight

            states: State {
                name: "expanded"
                when: root.expanded

                PropertyChanges {
                    summary.maximumLineCount: undefined
                }

                AnchorChanges {
                    target: summary
                    anchors.top: appName.bottom
                }
            }

            transitions: Transition {
                PropertyAction {
                    target: summary
                    property: "maximumLineCount"
                }
                AnchorAnimation {
                    duration: Appearance.anim.durations.normal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.curves.standard
                }
            }

            Behavior on height {
                Anim {}
            }
        }

        TextMetrics {
            id: summaryMetrics

            text: root.modelData.summary
            font.family: summary.font.family
            font.pointSize: summary.font.pointSize
            elide: Text.ElideRight
            elideWidth: expandBtn.x - time.width - timeSep.width - summary.x - Appearance.spacing.small * 3
        }

        StyledText {
            id: timeSep

            anchors.top: parent.top
            anchors.left: summary.right
            anchors.leftMargin: Appearance.spacing.small

            text: "•"
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small

            states: State {
                name: "expanded"
                when: root.expanded

                AnchorChanges {
                    target: timeSep
                    anchors.left: appName.right
                }
            }

            transitions: Transition {
                AnchorAnimation {
                    duration: Appearance.anim.durations.normal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.curves.standard
                }
            }
        }

        StyledText {
            id: time

            anchors.top: parent.top
            anchors.left: timeSep.right
            anchors.leftMargin: Appearance.spacing.small

            animate: true
            horizontalAlignment: Text.AlignLeft
            text: root.modelData.timeStr
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
        }

        Item {
            id: expandBtn

            anchors.right: parent.right
            anchors.top: parent.top

            implicitWidth: expandIcon.height
            implicitHeight: expandIcon.height

            StateLayer {
                radius: Appearance.rounding.full

                function onClicked() {
                    root.expanded = !root.expanded;
                }
            }

            MaterialIcon {
                id: expandIcon

                anchors.centerIn: parent

                animate: true
                text: root.expanded ? "expand_less" : "expand_more"
                font.pointSize: Appearance.font.size.normal
            }
        }

        StyledText {
            id: bodyPreview

            anchors.left: summary.left
            anchors.right: expandBtn.left
            anchors.top: summary.bottom
            anchors.topMargin: Appearance.spacing.small
            anchors.rightMargin: Appearance.spacing.small

            animate: true
            textFormat: Text.RichText
            text: {
                let content = root.modelData?.body || "";
                if (!content) return "";
                
                // Process the content to move links to end and style them
                let links = [];
                let textWithoutLinks = content;
                
                // Find HTML links and extract them
                const htmlLinkRegex = /<a[^>]*href="([^"]*)"[^>]*>([^<]*)<\/a>/g;
                let match;
                while ((match = htmlLinkRegex.exec(content)) !== null) {
                    if (match[1] && match[2]) {
                        links.push(`<a href="${match[1]}" style="color: #FBF1C7;">${match[2]}</a>`);
                        textWithoutLinks = textWithoutLinks.replace(match[0], '');
                    }
                }
                
                // Find markdown links
                const markdownLinkRegex = /\[([^\]]+)\]\(([^)]+)\)/g;
                while ((match = markdownLinkRegex.exec(textWithoutLinks)) !== null) {
                    if (match[1] && match[2]) {
                        links.push(`<a href="${match[2]}" style="color: #FBF1C7;">${match[1]}</a>`);
                        textWithoutLinks = textWithoutLinks.replace(match[0], '');
                    }
                }
                
                // Clean up text
                textWithoutLinks = textWithoutLinks.replace(/\s+/g, ' ').trim();
                
                // For collapsed view, limit the text length
                const maxLength = 100; // Adjust this value as needed
                let truncatedText = textWithoutLinks;
                let needsEllipsis = false;
                
                if (textWithoutLinks.length > maxLength) {
                    truncatedText = textWithoutLinks.substring(0, maxLength).trim();
                    // Make sure we don't cut off in the middle of a word
                    const lastSpace = truncatedText.lastIndexOf(' ');
                    if (lastSpace > maxLength * 0.8) { // Only cut at word boundary if it's not too short
                        truncatedText = truncatedText.substring(0, lastSpace);
                    }
                    needsEllipsis = true;
                }
                
                // Combine text with links at the end
                let result = truncatedText || "";
                if (needsEllipsis) {
                    result += '...';
                }
                if (links.length > 0 && !needsEllipsis) {
                    result += (truncatedText ? '<br>' : '') + links.join(' ');
                }
                
                return result || "";
            }
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 2
            elide: Text.ElideRight

            opacity: root.expanded ? 0 : 1
            visible: opacity > 0

            Behavior on opacity {
                Anim {}
            }
        }

        property string processedBodyText: {
            let content = root.modelData?.body || "";
            if (!content) return "";
            
            // Extract links and move them to the end
            let links = [];
            let textWithoutLinks = content;
            
            // Find HTML links
            const htmlLinkRegex = /<a[^>]*href="([^"]*)"[^>]*>([^<]*)<\/a>/g;
            let match;
            while ((match = htmlLinkRegex.exec(content)) !== null) {
                if (match[2]) {
                    links.push(match[2]); // Just the link text for TextMetrics
                    textWithoutLinks = textWithoutLinks.replace(match[0], '');
                }
            }
            
            // Find markdown links
            const markdownLinkRegex = /\[([^\]]+)\]\(([^)]+)\)/g;
            while ((match = markdownLinkRegex.exec(content)) !== null) {
                if (match[1]) {
                    links.push(match[1]); // Just the link text for TextMetrics
                    textWithoutLinks = textWithoutLinks.replace(match[0], '');
                }
            }
            
            // Find plain URLs
            const urlRegex = /(https?:\/\/[^\s]+)/g;
            while ((match = urlRegex.exec(textWithoutLinks)) !== null) {
                if (match[1]) {
                    links.push(match[1]); // The URL itself
                    textWithoutLinks = textWithoutLinks.replace(match[1], '');
                }
            }
            
            // Clean up extra spaces
            textWithoutLinks = textWithoutLinks.replace(/\s+/g, ' ').trim();
            
            // Combine text with links at the end (plain text for TextMetrics)
            let result = textWithoutLinks || "";
            if (links.length > 0) {
                result += (textWithoutLinks ? ' ' : '') + links.join(' ');
            }
            
            return result;
        }

        TextMetrics {
            id: bodyPreviewMetrics

            text: root.processedBodyText || ""
            font.family: bodyPreview.font.family
            font.pointSize: bodyPreview.font.pointSize
            elide: Text.ElideRight
            elideWidth: Math.max(bodyPreview.width, 200) // Ensure minimum width
        }

        StyledText {
            id: body

            anchors.left: summary.left
            anchors.right: expandBtn.left
            anchors.top: summary.bottom
            anchors.rightMargin: Appearance.spacing.small

            animate: true
            textFormat: Text.RichText
            text: {
                let content = root.modelData?.body || "";
                if (!content) return "";
                
                // Extract links and move them to the end
                let links = [];
                let textWithoutLinks = content;
                
                // Find HTML links
                const htmlLinkRegex = /<a[^>]*href="([^"]*)"[^>]*>([^<]*)<\/a>/g;
                let match;
                while ((match = htmlLinkRegex.exec(content)) !== null) {
                    if (match[1] && match[2]) {
                        links.push(`<a href="${match[1]}">${match[2]}</a>`);
                        textWithoutLinks = textWithoutLinks.replace(match[0], '');
                    }
                }
                
                // Find markdown links
                const markdownLinkRegex = /\[([^\]]+)\]\(([^)]+)\)/g;
                while ((match = markdownLinkRegex.exec(content)) !== null) {
                    if (match[1] && match[2]) {
                        links.push(`<a href="${match[2]}">${match[1]}</a>`);
                        textWithoutLinks = textWithoutLinks.replace(match[0], '');
                    }
                }
                
                // Find plain URLs
                const urlRegex = /(https?:\/\/[^\s]+)/g;
                while ((match = urlRegex.exec(textWithoutLinks)) !== null) {
                    if (match[1]) {
                        links.push(`<a href="${match[1]}">${match[1]}</a>`);
                        textWithoutLinks = textWithoutLinks.replace(match[1], '');
                    }
                }
                
                // Clean up extra spaces
                textWithoutLinks = textWithoutLinks.replace(/\s+/g, ' ').trim();
                
                // Combine text with links at the end
                let result = '<style>a { color: #FBF1C7; }</style>';
                if (textWithoutLinks) {
                    result += textWithoutLinks;
                }
                if (links.length > 0) {
                    result += (textWithoutLinks ? '<br>' : '') + links.join(' ');
                }
                
                return result || "";
            }
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            opacity: root.expanded ? 1 : 0

            Behavior on opacity {
                Anim {}
            }
        }

        RowLayout {
            id: actions

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: body.bottom
            anchors.topMargin: Appearance.spacing.small

            spacing: Appearance.spacing.smaller

            opacity: root.expanded ? 1 : 0

            Behavior on opacity {
                Anim {}
            }

            Repeater {
                model: root.modelData.actions

                delegate: StyledRect {
                    id: action

                    required property NotificationAction modelData

                    radius: Appearance.rounding.full
                    color: Colours.palette.m3surfaceContainerHigh

                    Layout.preferredWidth: actionText.width + Appearance.padding.normal * 2
                    Layout.preferredHeight: actionText.height + Appearance.padding.small * 2
                    implicitWidth: actionText.width + Appearance.padding.normal * 2
                    implicitHeight: actionText.height + Appearance.padding.small * 2

                    StateLayer {
                        radius: Appearance.rounding.full

                        function onClicked(): void {
                            action.modelData.invoke();
                        }
                    }

                    StyledText {
                        id: actionText

                        anchors.centerIn: parent
                        text: actionTextMetrics.elidedText
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.small
                    }

                    TextMetrics {
                        id: actionTextMetrics

                        text: modelData.text
                        font.family: actionText.font.family
                        font.pointSize: actionText.font.pointSize
                        elide: Text.ElideRight
                        elideWidth: {
                            const numActions = root.modelData.actions.length;
                            return (inner.width - actions.spacing * (numActions - 1)) / numActions - Appearance.padding.normal * 2;
                        }
                    }
                }
            }
        }
    }

    component Anim: NumberAnimation {
        duration: Appearance.anim.durations.normal
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.anim.curves.standard
    }
}
