import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Nemo.DBus 2.0

Page {
    id: page

    property bool uninstalling
    property string error

    // Read by the homescreen's volume control (lipstick, volumecontrol/VolumeControl.qml).
    // When true, the volume keys change media volume even when nothing is playing.
    ConfigurationValue {
        id: forceMediaVolume

        key: "/jolla/sound/force_mediavolume"
        defaultValue: false
    }

    // Uninstalling starts sailfish-media-volume-keys-uninstall.service (root), allowed by
    // /usr/share/polkit-1/rules.d/49-sailfish-media-volume-keys.rules.
    DBusInterface {
        id: systemd

        bus: DBus.SystemBus
        service: "org.freedesktop.systemd1"
        path: "/org/freedesktop/systemd1"
        iface: "org.freedesktop.systemd1.Manager"
    }

    function uninstall() {
        uninstalling = true
        error = ""
        // Back to the default right away: undefined removes the key (like dconf reset).
        // The package's uninstall script resets it as well.
        forceMediaVolume.value = undefined
        systemd.typedCall("StartUnit", [
            { "type": "s", "value": "sailfish-media-volume-keys-uninstall.service" },
            { "type": "s", "value": "replace" }
        ], function() { }, function(err) {
            page.uninstalling = false
            page.error = "Didn't work: " + err
        })
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
                enabled: !page.uninstalling
                onClicked: forceMediaVolume.value = !forceMediaVolume.value
            }

            Item { width: 1; height: Theme.paddingLarge }

            BackgroundItem {
                id: uninstallRow

                enabled: !page.uninstalling
                height: Math.max(implicitHeight, uninstallLabel.height + 2 * Theme.paddingSmall)
                onClicked: pageStack.animatorPush(uninstallDialog)

                Icon {
                    id: uninstallIcon

                    x: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    source: "image://theme/icon-m-delete"
                    highlighted: uninstallRow.highlighted
                    opacity: uninstallRow.enabled ? 1.0 : Theme.opacityLow
                }
                Label {
                    id: uninstallLabel

                    anchors {
                        left: uninstallIcon.right
                        leftMargin: Theme.paddingMedium
                        right: parent.right
                        rightMargin: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }
                    wrapMode: Text.Wrap
                    color: uninstallRow.highlighted ? Theme.highlightColor : Theme.primaryColor
                    opacity: uninstallRow.enabled ? 1.0 : Theme.opacityLow
                    text: "Uninstall"
                }
            }

            Label {
                visible: page.uninstalling || page.error !== ""
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: page.error !== "" ? Theme.errorColor : Theme.secondaryHighlightColor
                text: page.error !== ""
                      ? page.error
                      : "Uninstalling. The volume keys are back to the default. Close Settings to remove this page."
            }
        }

        VerticalScrollDecorator {}
    }

    // Own page for the destructive action; Accept (or swiping forward) uninstalls.
    Component {
        id: uninstallDialog

        Dialog {
            onAccepted: page.uninstall()

            Column {
                width: parent.width

                DialogHeader {
                    acceptText: "Uninstall"
                }

                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    wrapMode: Text.Wrap
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                    text: "Uninstall Media volume keys?"
                }

                Item { width: 1; height: Theme.paddingLarge }

                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    wrapMode: Text.Wrap
                    color: Theme.highlightColor
                    text: "The volume keys go back to the default (ringtone volume when nothing is playing), "
                          + "and this page and the Top menu toggle are removed."
                }

                Item { width: 1; height: Theme.paddingLarge }

                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    wrapMode: Text.Wrap
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryHighlightColor
                    text: "Accept to uninstall, or go back to keep it."
                }
            }
        }
    }
}
