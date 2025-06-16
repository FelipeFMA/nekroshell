pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "root:/utils"

Singleton {
    id: root

    property bool locked: false
    property bool authenticating: false

    signal lockRequested()
    signal unlockRequested()
    signal authenticationFailed()
    signal authenticationSucceeded()

    function lock() {
        locked = true;
        lockRequested();
    }

    function unlock() {
        locked = false;
        unlockRequested();
    }

    function authenticate(password) {
        console.log("LockscreenService.authenticate called with password length:", password.length);
        if (authenticating) {
            console.log("Already authenticating, returning false");
            return false;
        }
        
        console.log("Starting authentication process");
        authenticating = true;
        
        // Set up the auth command dynamically by creating a new process
        authProcess.running = false; // Stop any existing process
        
        // Use the PAM authentication script
        const escapedPassword = password.replace(/'/g, "'\\''");
        const scriptPath = Paths.root + "/utils/scripts/pam-auth.sh";
        authProcess.command = ["bash", "-c", `echo '${escapedPassword}' | "${scriptPath}"`];
        console.log("Starting auth with PAM script");
        authProcess.running = true;
        
        return true;
    }

    // PAM authentication process
    Process {
        id: authProcess
        
        command: ["echo", "test"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                console.log("Auth script output:", text);
                if (text && text.trim().includes("AUTH_SUCCESS")) {
                    console.log("Authentication successful");
                    root.authenticationSucceeded();
                    root.unlock();
                } else {
                    console.log("Authentication failed, output:", text);
                    root.authenticationFailed();
                }
                root.authenticating = false;
            }
        }
        
        onRunningChanged: {
            console.log("Auth process running changed to:", running);
        }
        
        onExited: (exitCode) => {
            console.log("Auth script exited with code:", exitCode);
            if (exitCode !== 0) {
                root.authenticationFailed();
            }
            root.authenticating = false;
        }
    }

    // Handle system lock requests
    IpcHandler {
        target: "lockscreen"

        function lock(): void {
            root.lock();
        }

        function unlock(): void {
            root.unlock();
        }

        function status(): string {
            return root.locked ? "locked" : "unlocked";
        }

        function authenticate(password: string): boolean {
            return root.authenticate(password);
        }
    }

    Component.onCompleted: {
        // Check if we should start locked
        if (typeof Quickshell !== "undefined" && Quickshell.argv) {
            const args = Quickshell.argv;
            if (args && args.includes && args.includes("--locked")) {
                root.lock();
            }
        }
    }
}
