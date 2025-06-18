pragma Singleton

import "root:/utils"
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string currentNamePath: `${Paths.state}/wallpaper/path.txt`.slice(7)
    readonly property string path: `${Paths.pictures}/Wallpapers`.slice(7)
    readonly property list<string> extensions: ["jpg", "jpeg", "png", "webp", "tif", "tiff"]

    readonly property list<Wallpaper> list: wallpapers.instances
    property bool showPreview: false
    readonly property string current: showPreview ? previewPath : actualCurrent
    property string previewPath
    property string actualCurrent

    function setWallpaper(path: string): void {
        actualCurrent = path;
        setWall.path = path;
        setWall.startDetached();
    }

    function preview(path: string): void {
        previewPath = path;
        showPreview = true;
    }

    function stopPreview(): void {
        showPreview = false;
        Colours.endPreviewOnNextChange = true;
    }

    reloadableId: "wallpapers"

    IpcHandler {
        target: "wallpaper"

        function get(): string {
            return root.actualCurrent;
        }

        function set(path: string): void {
            root.setWallpaper(path);
        }

        function list(): string {
            return root.list.map(w => w.path).join("\n");
        }
    }

    FileView {
        path: root.currentNamePath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.actualCurrent = text().trim()
    }

    Process {
        id: setWall

        property string path

        command: ["nekroshell", "wallpaper", "-f", path]
    }

    Process {
        running: true
        command: ["find", root.path, "-type", "d", "-path", '*/.*', "-prune", "-o", "-not", "-name", '.*', "-type", "f", "-print"]
        stdout: StdioCollector {
            onStreamFinished: wallpapers.model = text.trim().split("\n").filter(w => root.extensions.includes(w.slice(w.lastIndexOf(".") + 1))).sort()
        }
    }

    Variants {
        id: wallpapers

        Wallpaper {}
    }

    component Wallpaper: QtObject {
        required property string modelData
        readonly property string path: modelData
        readonly property string name: path.slice(path.lastIndexOf("/") + 1, path.lastIndexOf("."))
    }
}
