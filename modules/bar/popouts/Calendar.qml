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
    height: Config.bar.sizes.calendarHeight // Fixed configurable height

    DayOfWeekRow {
        id: days

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: parent.padding
        
        height: 30 // Fixed height for day headers

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
        
        height: parent.height - days.height - parent.spacing - parent.padding * 2 // Fill remaining space

        spacing: 3
        locale: Qt.locale()
        month: new Date().getMonth()
        year: new Date().getFullYear()

        delegate: Item {
            id: day

            required property var model

            width: (grid.width - grid.spacing * 6) / 7 // Fixed width for 7 columns
            height: (grid.height - grid.spacing * 5) / 6 // Fixed height for 6 rows

            StyledRect {
                anchors.centerIn: parent

                width: Math.min(parent.width, parent.height) - 4 // Fixed size with margin
                height: width

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
