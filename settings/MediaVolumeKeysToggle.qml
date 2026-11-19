import QtQuick 2.6
import Sailfish.Silica 1.0
import com.jolla.settings 1.0
import Nemo.Configuration 1.0

// Top menu toggle (Settings > Top menu > add "Media keys"): on = the volume keys change the
// media volume (the default), off = the ringtone volume. Same setting as "Volume keys
// control" in Settings > Sounds and feedback.
SettingsToggle {
    name: "Media keys"
    icon.source: "image://theme/icon-m-speaker-on"
    checked: target.value === "media"
    onToggled: target.value = checked ? "ringtone" : undefined

    ConfigurationValue {
        id: target

        key: "/apps/sailfish-media-volume-keys/target"
        defaultValue: "media"
    }
}
