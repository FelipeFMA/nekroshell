pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool active: false

    function toggle(): void {
        toggleProcess.running = true;
    }

    function checkState(): void {
        checkProcess.running = true;
    }

    Process {
        id: toggleProcess

        command: ["sh", "-c", `
            if pgrep -x wlsunset > /dev/null 2>&1; then
                pkill -x wlsunset
                echo "Killed wlsunset"
                exit 1
            else
                nohup wlsunset -t 4000 -T 4001 > /dev/null 2>&1 &
                sleep 0.1
                if pgrep -x wlsunset > /dev/null 2>&1; then
                    echo "Started wlsunset successfully"
                    exit 0
                else
                    echo "Failed to start wlsunset"
                    exit 2
                fi
            fi
        `]

        onExited: function(exitCode) {
            // Wait a moment then check the actual state
            checkTimer.start();
        }
    }

    Process {
        id: checkProcess

        command: ["pgrep", "-x", "wlsunset"]
        
        onExited: function(exitCode) {
            const newState = (exitCode === 0);
            root.active = newState;
        }
    }

    Timer {
        id: checkTimer
        interval: 100
        onTriggered: checkProcess.running = true
    }

    Component.onCompleted: {
        checkState();
    }

    onActiveChanged: {
        // State changed
    }
}
