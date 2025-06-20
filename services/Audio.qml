pragma Singleton

import "root:/widgets"
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real volume: sink?.audio?.volume ?? 0

    function setVolume(volume: real): void {
        if (sink?.ready && sink?.audio) {
            sink.audio.muted = false;
            sink.audio.volume = volume;
        }
    }

    function increaseVolume(): void {
        const newVolume = Math.min(1.0, volume + 0.1);
        setVolume(newVolume);
        showOsd();
    }

    function decreaseVolume(): void {
        const newVolume = Math.max(0.0, volume - 0.1);
        setVolume(newVolume);
        showOsd();
    }

    function toggleMute(): void {
        if (sink?.ready && sink?.audio) {
            sink.audio.muted = !sink.audio.muted;
            showOsd();
        }
    }

    function showOsd(): void {
        const visibilities = Visibilities.getForActive();
        if (visibilities) {
            visibilities.osd = true;
        }
    }

    CustomShortcut {
        name: "volumeUp"
        description: "Increase volume and show OSD"
        onPressed: root.increaseVolume()
    }

    CustomShortcut {
        name: "volumeDown"
        description: "Decrease volume and show OSD"
        onPressed: root.decreaseVolume()
    }

    CustomShortcut {
        name: "volumeMute"
        description: "Toggle mute and show OSD"
        onPressed: root.toggleMute()
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }
}
