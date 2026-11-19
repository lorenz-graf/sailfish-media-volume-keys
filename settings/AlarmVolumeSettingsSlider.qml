import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings 1.0

// Top menu slider (Settings > Top menu > add "Alarm volume"), like the stock
// RingtoneVolumeSettingsSlider.qml
SettingsControl {
    id: root

    contentHeight: slider.height

    AlarmVolumeController {
        slider: slider
    }

    SettingsSlider {
        id: slider

        width: root.width

        onPressAndHold: {
            slider.cancel()
            root.openMenu()
        }
    }
}
