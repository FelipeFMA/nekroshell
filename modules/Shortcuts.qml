import "root:/widgets"
import "root:/services"
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property bool launcherInterrupted

    CustomShortcut {
        name: "showall"
        description: "Toggle launcher, dashboard and osd"
        onPressed: {
            const v = Visibilities.getForActive();
            v.launcher = v.dashboard = v.osd = !(v.launcher || v.dashboard || v.osd);
        }
    }

    CustomShortcut {
        name: "session"
        description: "Toggle session menu"
        onPressed: {
            const visibilities = Visibilities.getForActive();
            visibilities.session = !visibilities.session;
        }
    }

    CustomShortcut {
        name: "launcher"
        description: "Toggle launcher"
        onPressed: root.launcherInterrupted = false
        onReleased: {
            if (!root.launcherInterrupted) {
                const visibilities = Visibilities.getForActive();
                visibilities.launcher = !visibilities.launcher;
            }
            root.launcherInterrupted = false;
        }
    }

    CustomShortcut {
        name: "launcherInterrupt"
        description: "Interrupt launcher keybind"
        onPressed: root.launcherInterrupted = true
    }

    CustomShortcut {
        name: "nightLight"
        description: "Toggle night light (wlsunset)"
        onPressed: {
            nightLightProc.startDetached();
        }
    }

    CustomShortcut {
        name: "lock"
        description: "Lock the session"
        onPressed: LockscreenService.lock()
    }

    Process {
        id: nightLightProc

        command: ["sh", "-c", `
            if pkill -x wlsunset; then
                echo "wlsunset was running and has been killed."
            else
                echo "wlsunset was not running. Starting wlsunset -t 4000 -T 4001..."
                wlsunset -t 4000 -T 4001 &
                echo "wlsunset started with PID $!"
            fi
        `]
    }

    IpcHandler {
        target: "drawers"

        function toggle(drawer: string): void {
            if (list().split("\n").includes(drawer)) {
                const visibilities = Visibilities.getForActive();
                visibilities[drawer] = !visibilities[drawer];
            } else {
                console.warn(`[IPC] Drawer "${drawer}" does not exist`);
            }
        }

        function list(): string {
            const visibilities = Visibilities.getForActive();
            return Object.keys(visibilities).filter(k => typeof visibilities[k] === "boolean").join("\n");
        }
    }
}
