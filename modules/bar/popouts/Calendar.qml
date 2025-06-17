pragma ComponentBehavior: Bound

import "root:/widgets"
import "root:/services"
import "root:/config"
import QtQuick
import QtQuick.Controls

Column {
    id: root

    padding: Appearance.padding.large
    spacing: Appearance.spacing.small
    width: Config.bar.sizes.calendarWidth

    DayOfWeekRow {
        id: days

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: parent.padding

        delegate: StyledText {
            required property var model

            horizontalAlignment: Text.AlignHCenter
            text: model.shortName
            font.family: Appearance.font.family.sans
            font.weight: 500
        }
    }

    MonthGrid {
        id: grid

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: parent.padding

        spacing: 3
        locale: Qt.locale()
        month: new Date().getMonth()
        year: new Date().getFullYear()

        delegate: Item {
            id: day

            required property var model

            implicitWidth: implicitHeight
            implicitHeight: text.implicitHeight + Appearance.padding.small * 2

            StyledRect {
                anchors.centerIn: parent

                implicitWidth: parent.implicitHeight
                implicitHeight: parent.implicitHeight

                radius: Appearance.rounding.full
                color: {
                    const today = new Date()
                    const modelDate = day.model.date
                    const isToday = modelDate.getDate() === today.getDate() && 
                                  modelDate.getMonth() === today.getMonth() && 
                                  modelDate.getFullYear() === today.getFullYear()
                    return isToday ? Colours.palette.m3primary : "transparent"
                }

                StyledText {
                    id: text

                    anchors.centerIn: parent

                    horizontalAlignment: Text.AlignHCenter
                    text: grid.locale.toString(day.model.date, "d")
                    color: {
                        const today = new Date()
                        const modelDate = day.model.date
                        const isToday = modelDate.getDate() === today.getDate() && 
                                      modelDate.getMonth() === today.getMonth() && 
                                      modelDate.getFullYear() === today.getFullYear()
                        return isToday ? Colours.palette.m3onPrimary : day.model.month === grid.month ? Colours.palette.m3onSurfaceVariant : Colours.palette.m3outline
                    }
                }
            }
        }
    }
}
