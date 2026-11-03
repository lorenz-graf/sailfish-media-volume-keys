import QtQuick 2.6
import Sailfish.Silica 1.0
import com.jolla.settings 1.0
import Nemo.Configuration 1.0

// Top menu toggle (Settings > Top menu > add "Media keys").
SettingsToggle {
    name: "Media keys"
    icon.source: "image://theme/icon-m-speaker-on"
    checked: !!forceMediaVolume.value
    onToggled: forceMediaVolume.value = !forceMediaVolume.value

    ConfigurationValue {
        id: forceMediaVolume

        key: "/jolla/sound/force_mediavolume"
        defaultValue: false
    }
}
