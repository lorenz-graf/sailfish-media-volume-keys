import QtQuick 2.0
import Sailfish.Silica 1.0

// Alarm and timer volume in Settings > Sounds and feedback, below the stock ringtone and
// media sliders (like the stock RingtoneVolumeSlider.qml)
Slider {
    id: slider

    AlarmVolumeController {
        slider: slider
    }
}
