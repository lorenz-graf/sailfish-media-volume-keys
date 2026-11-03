import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

Page {
    // Read by the homescreen's volume control (lipstick, volumecontrol/VolumeControl.qml).
    // When true, the volume keys change media volume even when nothing is playing.
    ConfigurationValue {
        id: forceMediaVolume

        key: "/jolla/sound/force_mediavolume"
        defaultValue: false
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height + Theme.paddingLarge

        Column {
            id: content

            width: parent.width

            PageHeader {
                title: "Volume keys"
            }

            TextSwitch {
                text: "Always control media volume"
                description: "The volume keys change the media volume even when nothing is playing. "
                             + "Change the ringtone volume in Settings > Sounds and feedback or in the Top menu. "
                             + "During calls the keys still change the call volume."
                checked: !!forceMediaVolume.value
                automaticCheck: false
                onClicked: forceMediaVolume.value = !forceMediaVolume.value
            }
        }

        VerticalScrollDecorator {}
    }
}
