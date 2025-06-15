import "root:/widgets"
import "root:/services"
import "root:/config"
import QtQuick

Column {
    id: root

    property color colour: "#ebdbb2"

    spacing: Appearance.spacing.small

    MaterialIcon {
        id: icon

        text: "calendar_month"
        color: root.colour

        anchors.horizontalCenter: parent.horizontalCenter
    }

    StyledText {
        id: text

        anchors.horizontalCenter: parent.horizontalCenter

        horizontalAlignment: StyledText.AlignHCenter
        text: Time.format("h:mm\nAP")
        font.pointSize: Appearance.font.size.smaller
        font.family: Appearance.font.family.mono
        color: root.colour
    }
}
