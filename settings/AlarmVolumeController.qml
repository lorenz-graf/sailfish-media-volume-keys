import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import Nemo.DBus 2.0

// Alarm and timer volume for a slider, styled like the stock ringtone and media sliders
// (jolla-settings pages/sounds/VolumeSliderController.qml). Used by AlarmVolumeSlider
// (Settings > Sounds and feedback) and AlarmVolumeSettingsSlider (Top menu).
// The value is profiled "clock.alert.volume" (0-100, passed as a string). It never goes
// below 20 %, so alarms stay audible (same minimum as the homescreen patch).
Item {
    id: root

    property QtObject slider
    readonly property int minimum: 20

    function useValue(value) {
        var v = parseInt(value, 10)
        if (isNaN(v) || slider.down)
            return
        slider.value = Math.max(Math.min(v, 100), minimum)
    }

    Component.onCompleted: {
        // maximum first: Silica warns while the maximum is below the minimum
        slider.maximumValue = 100
        slider.minimumValue = minimum
        slider.stepSize = 10
        slider.value = 100
        slider.label = "Alarm volume"
        // room for the value above the handle
        slider.height = Qt.binding(function () {
            return slider.implicitHeight + valueLabel.height + Theme.paddingSmall
        })
    }

    Connections {
        target: root.slider
        onReleased: {
            profiled.typedCall("set_value", [{ "type": "s", "value": "general" },
                                             { "type": "s", "value": "clock.alert.volume" },
                                             { "type": "s", "value": String(Math.round(root.slider.value)) }])
        }
    }

    DBusInterface {
        id: profiled

        bus: DBus.SessionBus
        service: "com.nokia.profiled"
        path: "/com/nokia/profiled"
        iface: "com.nokia.profiled"
        signalsEnabled: true

        function profile_changed(changed, active, profile, values) {
            for (var i = 0; i < values.length; i++) {
                if (values[i][0] === "clock.alert.volume")
                    root.useValue(values[i][1])
            }
        }

        Component.onCompleted: {
            typedCall("get_value", [{ "type": "s", "value": "general" },
                                    { "type": "s", "value": "clock.alert.volume" }],
                      function (value) { root.useValue(value) })
        }
    }

    SliderValueLabel {
        id: valueLabel

        parent: root.slider
        slider: root.slider
        text: Math.round(root.slider.value) + "%"
        scale: root.slider.pressed ? Theme.fontSizeLarge / Theme.fontSizeMedium : 1.0
        font.pixelSize: Theme.fontSizeMedium
    }
}
