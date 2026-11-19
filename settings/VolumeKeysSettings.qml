import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

// Volume keys settings in Settings > Sounds and feedback, below the volume sliders:
// what the keys control, and the alarm volume while the Clock app is open.
Column {
    id: root

    // Stock setting (the keys change media volume even when nothing plays). The patched
    // homescreen ignores it; it's only cleared, so a value left by version 1.x doesn't
    // come back if the patch is removed.
    ConfigurationValue {
        id: forceMediaVolume

        key: "/jolla/sound/force_mediavolume"
        defaultValue: false
    }

    // Read by the patched homescreen (volumecontrol/VolumeControl.qml):
    // "ringtone", "media" (default, stored by removing the key) or "alarm"
    ConfigurationValue {
        id: target

        key: "/apps/sailfish-media-volume-keys/target"
        defaultValue: "media"
    }

    ConfigurationValue {
        id: alarmInClock

        key: "/apps/sailfish-media-volume-keys/alarm_in_clock"
        defaultValue: true
    }

    readonly property var targets: ["ringtone", "media", "alarm"]
    readonly property int targetIndex: Math.max(targets.indexOf(target.value), 0)

    function setTarget(index) {
        target.value = index === 1 ? undefined : targets[index]
        forceMediaVolume.value = undefined
    }

    // Keep the picker in step when the Top menu toggle changes the setting
    onTargetIndexChanged: targetCombo.currentIndex = targetIndex

    ComboBox {
        id: targetCombo

        label: "Volume keys control"
        currentIndex: root.targetIndex
        description: {
            switch (root.targetIndex) {
            case 0:
                return "Ringtone volume, or the media volume while media plays."
            case 2:
                return "Alarm and timer volume, unless media is playing."
            default:
                return "Media volume, also when nothing is playing."
            }
        }

        menu: ContextMenu {
            MenuItem { text: "Ringtone" }
            MenuItem { text: "Media" }
            MenuItem { text: "Alarm" }
        }

        onCurrentIndexChanged: {
            if (currentIndex !== root.targetIndex)
                root.setTarget(currentIndex)
        }
    }

    TextSwitch {
        text: "Control alarm volume while Clock is open"
        description: "While the Clock app is in front, the volume keys change the alarm and timer volume."
        checked: !!alarmInClock.value
        automaticCheck: false
        // on is the default: store only "off", remove the key for "on"
        onClicked: alarmInClock.value = alarmInClock.value ? false : undefined
    }
}
