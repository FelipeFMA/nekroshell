pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real cpuPerc
    property real cpuTemp
    property real gpuPerc
    property real gpuTemp
    property int memUsed
    property int memTotal
    readonly property real memPerc: memTotal > 0 ? memUsed / memTotal : 0
    property int storageUsed
    property int storageTotal
    property real storagePerc: storageTotal > 0 ? storageUsed / storageTotal : 0

    property int lastCpuIdle
    property int lastCpuTotal

    function formatKib(kib: int): var {
        const mib = 1024;
        const gib = 1024 ** 2;
        const tib = 1024 ** 3;

        if (kib >= tib)
            return {
                value: kib / tib,
                unit: "TiB"
            };
        if (kib >= gib)
            return {
                value: kib / gib,
                unit: "GiB"
            };
        if (kib >= mib)
            return {
                value: kib / mib,
                unit: "MiB"
            };
        return {
            value: kib,
            unit: "KiB"
        };
    }

    Timer {
        running: true
        interval: 3000
        repeat: true
        onTriggered: {
            stat.reload();
            meminfo.reload();
            storage.running = true;
            cpuTemp.running = true;
            gpuUsage.running = true;
            gpuTemp.running = true;
        }
    }

    FileView {
        id: stat

        path: "/proc/stat"
        onLoaded: {
            const data = text().match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/);
            if (data) {
                const stats = data.slice(1).map(n => parseInt(n, 10));
                const total = stats.reduce((a, b) => a + b, 0);
                const idle = stats[3];

                const totalDiff = total - root.lastCpuTotal;
                const idleDiff = idle - root.lastCpuIdle;
                root.cpuPerc = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0;

                root.lastCpuTotal = total;
                root.lastCpuIdle = idle;
            }
        }
    }

    FileView {
        id: meminfo

        path: "/proc/meminfo"
        onLoaded: {
            const data = text();
            root.memTotal = parseInt(data.match(/MemTotal: *(\d+)/)[1], 10) || 1;
            root.memUsed = (root.memTotal - parseInt(data.match(/MemAvailable: *(\d+)/)[1], 10)) || 0;
        }
    }

    Process {
        id: storage

        running: true
        command: ["sh", "-c", "df | grep '^/dev/' | awk '{print $1, $3, $4}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const deviceMap = new Map();

                for (const line of text.trim().split("\n")) {
                    if (line.trim() === "")
                        continue;

                    const parts = line.trim().split(/\s+/);
                    if (parts.length >= 3) {
                        const device = parts[0];
                        const used = parseInt(parts[1], 10) || 0;
                        const avail = parseInt(parts[2], 10) || 0;

                        // Only keep the entry with the largest total space for each device
                        if (!deviceMap.has(device) || (used + avail) > (deviceMap.get(device).used + deviceMap.get(device).avail)) {
                            deviceMap.set(device, {
                                used: used,
                                avail: avail
                            });
                        }
                    }
                }

                let totalUsed = 0;
                let totalAvail = 0;

                for (const [device, stats] of deviceMap) {
                    totalUsed += stats.used;
                    totalAvail += stats.avail;
                }

                root.storageUsed = totalUsed;
                root.storageTotal = totalUsed + totalAvail;
            }
        }
    }

    Process {
        id: cpuTemp

        running: true
        command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone*/temp"]
        stdout: StdioCollector {
            onStreamFinished: {
                const temps = text.trim().split(" ");
                const sum = temps.reduce((acc, d) => acc + parseInt(d, 10), 0);
                root.cpuTemp = sum / temps.length / 1000;
            }
        }
    }

    Process {
        id: gpuUsage

        running: true
        command: ["sh", "-c", "timeout 3s intel_gpu_top -s 500 -o - 2>/dev/null | tail -1 | awk 'NF>=9 {print $9}' | grep -E '^[0-9]+\\.[0-9]+$' || echo '0'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const usage = parseFloat(text.trim()) || 0;
                root.gpuPerc = usage / 100;
            }
        }
    }

    Process {
        id: gpuTemp

        running: true
        command: ["sensors"]
        stdout: StdioCollector {
            onStreamFinished: {
                let temp = 0;
                let foundDedicatedGpu = false;
                let foundIntegratedGpu = false;
                
                // First, try to find dedicated GPU temperature
                let eligible = false;
                for (const line of text.trim().split("\n")) {
                    if (line === "Adapter: PCI adapter")
                        eligible = true;
                    else if (line === "")
                        eligible = false;
                    else if (eligible) {
                        const match = line.match(/^(temp[0-9]+|GPU core|edge):\s+\+([0-9]+\.[0-9]+)°C/);
                        if (match) {
                            temp = parseFloat(match[2]);
                            foundDedicatedGpu = true;
                            break;
                        }
                    }
                }
                
                // If no dedicated GPU found, look for Intel integrated (Package temperature)
                if (!foundDedicatedGpu) {
                    eligible = false;
                    for (const line of text.trim().split("\n")) {
                        if (line === "Adapter: ISA adapter")
                            eligible = true;
                        else if (line === "")
                            eligible = false;
                        else if (eligible) {
                            // Look for Package id (Intel CPU/GPU package temp)
                            const match = line.match(/^Package id [0-9]+:\s+\+([0-9]+\.[0-9]+)°C/);
                            if (match) {
                                temp = parseFloat(match[1]);
                                foundIntegratedGpu = true;
                                break;
                            }
                        }
                    }
                }
                
                // If still no temperature found, try sysfs as fallback
                if (!foundDedicatedGpu && !foundIntegratedGpu) {
                    gpuTempSysfs.running = true;
                } else {
                    root.gpuTemp = temp;
                }
            }
        }
    }
    
    Process {
        id: gpuTempSysfs
        
        running: false
        command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone5/temp 2>/dev/null || echo '0'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const temp = parseInt(text.trim(), 10);
                if (temp > 0) {
                    root.gpuTemp = temp / 1000; // Convert from millidegrees
                }
            }
        }
    }
}
