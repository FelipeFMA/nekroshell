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
        readDesktopFileProc.entry = entry;
        readDesktopFileProc.running = true;
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
                    var cleaned = execCommand.replace(/%[uUfFdDnNickvm]/g, "").trim();
                    var parts = cleaned.split(/\s+/).filter(function(part) { return part.length > 0; });
                    if (parts.length > 0) {
                        launchProc.command = parts;
                        launchProc.startDetached();
                    }
                }
            }
        }
    }

    Process {
        id: launchProc
    }
}
