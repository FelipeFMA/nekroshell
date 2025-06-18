pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool powered
    property bool discovering
    readonly property list<Device> devices: []

    Timer {
        id: refreshTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            if (root.powered) {
                getInfo.running = true;
                getDevices.running = true;
            }
        }
    }

    Process {
        running: true
        command: ["bluetoothctl"]
        stdout: SplitParser {
            onRead: {
                getInfo.running = true;
                getDevices.running = true;
            }
        }
    }

    Process {
        id: getInfo

        running: true
        command: ["bluetoothctl", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.powered = text.includes("Powered: yes");
                root.discovering = text.includes("Discovering: yes");
            }
        }
    }

    Process {
        id: getDevices

        running: true
        command: ["fish", "-c", `
            for line in (bluetoothctl devices)
                if string match -q 'Device *' $line
                    set addr (string split ' ' $line)[2]
                    bluetoothctl info $addr
                    echo "---DEVICE_SEPARATOR---"
                end
            end`]
        stdout: StdioCollector {
            onStreamFinished: {
                const deviceTexts = text.trim().split("---DEVICE_SEPARATOR---").filter(d => d.trim().length > 0);
                const devices = [];
                
                for (const deviceText of deviceTexts) {
                    try {
                        const addressMatch = deviceText.match(/Device ([0-9A-Fa-f:]{17})/);
                        const nameMatch = deviceText.match(/Name: (.*)/);
                        const aliasMatch = deviceText.match(/Alias: (.*)/);
                        const iconMatch = deviceText.match(/Icon: (.*)/);
                        
                        if (addressMatch) {
                            devices.push({
                                name: nameMatch ? nameMatch[1].trim() : "Unknown Device",
                                alias: aliasMatch ? aliasMatch[1].trim() : (nameMatch ? nameMatch[1].trim() : "Unknown Device"),
                                address: addressMatch[1],
                                icon: iconMatch ? iconMatch[1].trim() : "",
                                connected: deviceText.includes("Connected: yes"),
                                paired: deviceText.includes("Paired: yes"),
                                trusted: deviceText.includes("Trusted: yes")
                            });
                        }
                    } catch (e) {
                        console.log("Error parsing device:", e);
                    }
                }
                
                const rDevices = root.devices;

                const destroyed = rDevices.filter(rd => !devices.find(d => d.address === rd.address));
                for (const device of destroyed)
                    rDevices.splice(rDevices.indexOf(device), 1).forEach(d => d.destroy());

                for (const device of devices) {
                    const match = rDevices.find(d => d.address === device.address);
                    if (match) {
                        match.lastIpcObject = device;
                    } else {
                        rDevices.push(deviceComp.createObject(root, {
                            lastIpcObject: device
                        }));
                    }
                }
            }
        }
    }

    component Device: QtObject {
        required property var lastIpcObject
        readonly property string name: lastIpcObject.name
        readonly property string alias: lastIpcObject.alias
        readonly property string address: lastIpcObject.address
        readonly property string icon: lastIpcObject.icon
        readonly property bool connected: lastIpcObject.connected
        readonly property bool paired: lastIpcObject.paired
        readonly property bool trusted: lastIpcObject.trusted
    }

    Component {
        id: deviceComp

        Device {}
    }

    function setPower(enabled: bool): void {
        console.log("Bluetooth setPower called:", enabled);
        powerProcess.command = ["bluetoothctl", "power", enabled ? "on" : "off"];
        powerProcess.running = true;
    }

    function startDiscovery(): void {
        console.log("Bluetooth startDiscovery called");
        scanOnProcess.running = true;
    }

    function stopDiscovery(): void {
        console.log("Bluetooth stopDiscovery called");
        scanOffProcess.running = true;
    }

    Timer {
        id: discoveryTimer
        interval: 2000
        running: false
        repeat: true
        onTriggered: {
            getDevices.running = true;
        }
    }

    function connectDevice(address: string): void {
        console.log("Bluetooth connectDevice called:", address);
        connectProcess.command = ["bluetoothctl", "connect", address];
        connectProcess.running = true;
    }

    function disconnectDevice(address: string): void {
        console.log("Bluetooth disconnectDevice called:", address);
        disconnectProcess.command = ["bluetoothctl", "disconnect", address];
        disconnectProcess.running = true;
    }

    function pairDevice(address: string): void {
        pairProcess.command = ["bluetoothctl", "pair", address];
        pairProcess.running = true;
    }

    function trustDevice(address: string): void {
        trustProcess.command = ["bluetoothctl", "trust", address];
        trustProcess.running = true;
    }

    function removeDevice(address: string): void {
        removeProcess.command = ["bluetoothctl", "remove", address];
        removeProcess.running = true;
    }

    Process {
        id: powerProcess
        running: false
        stdout: SplitParser {
            onRead: {
                Qt.callLater(() => {
                    getInfo.running = true;
                });
            }
        }
    }

    Process {
        id: scanOnProcess
        command: ["bluetoothctl", "scan", "on"]
        running: false
        stdout: SplitParser {
            onRead: {
                Qt.callLater(() => {
                    getInfo.running = true;
                    discoveryTimer.start();
                });
            }
        }
    }

    Process {
        id: scanOffProcess
        command: ["bluetoothctl", "scan", "off"]
        running: false
        stdout: SplitParser {
            onRead: {
                Qt.callLater(() => {
                    getInfo.running = true;
                    discoveryTimer.stop();
                });
            }
        }
    }

    Process {
        id: connectProcess
        running: false
        stdout: SplitParser {
            onRead: {
                Qt.callLater(() => {
                    getDevices.running = true;
                });
            }
        }
    }

    Process {
        id: disconnectProcess
        running: false
        stdout: SplitParser {
            onRead: {
                Qt.callLater(() => {
                    getDevices.running = true;
                });
            }
        }
    }

    Process {
        id: pairProcess
        running: false
        stdout: SplitParser {
            onRead: {
                Qt.callLater(() => {
                    getDevices.running = true;
                });
            }
        }
    }

    Process {
        id: trustProcess
        running: false
        stdout: SplitParser {
            onRead: {
                Qt.callLater(() => {
                    getDevices.running = true;
                });
            }
        }
    }

    Process {
        id: removeProcess
        running: false
        stdout: SplitParser {
            onRead: {
                Qt.callLater(() => {
                    getDevices.running = true;
                });
            }
        }
    }
}
