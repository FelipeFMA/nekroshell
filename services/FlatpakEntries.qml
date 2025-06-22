import Quickshell
import Quickshell.Io
import QtQuick

Item {
    property alias entries: de.values

    DesktopEntries {
        id: de
        paths: parent.paths
    }
}
