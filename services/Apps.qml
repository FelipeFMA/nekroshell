pragma Singleton

import "root:/utils/scripts/fuzzysort.js" as Fuzzy
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property list<DesktopEntry> list: DesktopEntries.applications.values.filter(a => !a.noDisplay).sort((a, b) => a.name.localeCompare(b.name))
    readonly property list<var> preppedApps: list.map(a => ({
                name: Fuzzy.prepare(a.name),
                comment: Fuzzy.prepare(a.comment),
                entry: a
            }))

    function fuzzyQuery(search: string): var { // Idk why list<DesktopEntry> doesn't work
        return Fuzzy.go(search, preppedApps, {
            all: true,
            keys: ["name", "comment"],
            scoreFn: r => r[0].score > 0 ? r[0].score * 0.9 + r[1].score * 0.1 : 0
        }).map(r => r.obj.entry);
    }

    function launch(entry: DesktopEntry): void {
        // Read the desktop file directly to get the Exec command
        readDesktopFileProc.entry = entry;
        readDesktopFileProc.running = true;
    }

    function parseExecCommand(execString) {
        if (!execString) return [];
        
        // Remove desktop entry field codes like %U, %F, %u, %f, etc.
        var cleaned = execString.replace(/%[uUfFdDnNickvm]/g, "").trim();
        
        // Simple command parsing - split by spaces but handle quoted arguments
        var parts = [];
        var current = "";
        var inQuotes = false;
        var quoteChar = "";
        
        for (var i = 0; i < cleaned.length; i++) {
            var currentChar = cleaned[i];
            
            if (!inQuotes && (currentChar === '"' || currentChar === "'")) {
                inQuotes = true;
                quoteChar = currentChar;
            } else if (inQuotes && currentChar === quoteChar) {
                inQuotes = false;
                quoteChar = "";
            } else if (!inQuotes && currentChar === ' ') {
                if (current.trim()) {
                    parts.push(current.trim());
                    current = "";
                }
            } else {
                current += currentChar;
            }
        }
        
        if (current.trim()) {
            parts.push(current.trim());
        }
        
        return parts;
    }

    Process {
        id: readDesktopFileProc
        
        property DesktopEntry entry
        
        command: ["sh", "-c", "grep -m1 \"^Exec=\" /usr/share/applications/" + (entry?.id ?? "") + ".desktop 2>/dev/null || echo \"Exec=\""]
        
        stdout: StdioCollector {
            onStreamFinished: {
                var output = text.trim();
                var execMatch = output.match(/^Exec=(.*)$/);
                if (execMatch && execMatch[1]) {
                    var execCommand = execMatch[1];
                    console.log("Found exec command:", execCommand);
                    var parsedCommand = root.parseExecCommand(execCommand);
                    if (parsedCommand.length > 0) {
                        launchProc.command = parsedCommand;
                        launchProc.startDetached();
                    } else {
                        console.log("Failed to parse exec command:", execCommand);
                    }
                } else {
                    console.log("No Exec line found in desktop file for:", readDesktopFileProc.entry?.id);
                }
            }
        }
    }

    Process {
        id: launchProc
        // Command will be set dynamically by readDesktopFileProc
    }
}
