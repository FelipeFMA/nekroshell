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
        launchProc.entry = entry;
        launchProc.startDetached();
    }

    Process {
        id: launchProc

        property DesktopEntry entry

        command: {
            // Try to use exec command directly, fallback to gtk-launch
            const execCmd = entry?.exec ?? "";
            if (execCmd) {
                // Simple parsing: remove desktop entry field codes and split by space
                const cleaned = execCmd.replace(/%[uUfFdDnNickvm]/g, "").trim();
                const parts = cleaned.split(/\s+/).filter(part => part.length > 0);
                return parts.length > 0 ? parts : ["gtk-launch", entry?.id ?? ""];
            }
            return ["gtk-launch", entry?.id ?? ""];
        }
    }
}
