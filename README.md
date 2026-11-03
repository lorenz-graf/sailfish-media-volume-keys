# Media volume keys

A switch for **Sailfish OS** that makes the volume keys always change the **media** volume. By default they change the ringtone volume and only switch to media volume while something is already playing, so you can't set the level before a video starts.

| | Switch off (default) | Switch on |
|---|---|---|
| Nothing playing | Ringtone volume | Media volume |
| Media playing | Media volume | Media volume |
| During a call | Call volume | Call volume |
| Volume down to zero | Switches to silent | Mutes media |

Two ways to switch it:

- **Top menu toggle "Media keys":** flip it from anywhere, e.g. right before a video. Add it once in Settings → Top menu.
- **Settings → Volume keys** (in Look and feel, next to Sounds and feedback): the switch **Always control media volume**, plus **Uninstall**.

The ringtone volume stays in Settings → Sounds and feedback and in the Top menu.

Tested on the Jolla Phone (2026), Sailfish OS 5.2.0.22.

## How it works

Nothing is patched. The homescreen's volume control (`volumecontrol/VolumeControl.qml` in lipstick) already reads the dconf key `/jolla/sound/force_mediavolume`, but Settings has no switch for it. This package only adds that switch:

- [`settings/sailfish-media-volume-keys.json`](settings/sailfish-media-volume-keys.json): the Settings entries (page and Top menu toggle).
- [`settings/MediaVolumeKeysPage.qml`](settings/MediaVolumeKeysPage.qml): the page in Settings.
- [`settings/MediaVolumeKeysToggle.qml`](settings/MediaVolumeKeysToggle.qml): the Top menu toggle.
- [`system/sailfish-media-volume-keys-uninstall.service`](system/sailfish-media-volume-keys-uninstall.service) and [`system/49-sailfish-media-volume-keys.rules`](system/49-sailfish-media-volume-keys.rules): the **Uninstall** button. The polkit rule lets the user at the device start only this one unit, which only removes this package.

Changes take effect immediately, without a restart. A future OS update could rename or remove the key; the switch would then do nothing.

## Install

The package `sailfish-media-volume-keys-<version>-<release>.noarch.rpm` adds the **Media keys** Top menu toggle and **Settings → Volume keys** (in Look and feel, next to Sounds and feedback).

1. Install the package. Until it's on OpenRepos/Storeman: download it from the releases and install it as root:
   ```
   devel-su pkcon install-local sailfish-media-volume-keys-<version>-<release>.noarch.rpm
   ```
2. Close Settings completely and reopen it.
3. Settings → **Top menu** → add the **Media keys** toggle.
4. Switch it on, in the Top menu or in Settings → **Volume keys** (**Always control media volume**).

## Without the package

In the Terminal app (as the normal user, no root):

```
dconf write /jolla/sound/force_mediavolume true
```

Check the current value (empty means off, the default):

```
dconf read /jolla/sound/force_mediavolume
```

## Undo

- **Switch:** turn it off in Settings → Volume keys or in the Top menu.
- **Package:** Settings → Volume keys → **Uninstall**, then accept. It switches the setting back off and removes the package (the page and the Top menu toggle go with it). Removing the package with `devel-su pkcon remove sailfish-media-volume-keys` also switches the setting back off for users who are logged in.
- **By hand:** `dconf reset /jolla/sound/force_mediavolume`

## Build

You need `rpmbuild` (Arch: `pacman -S rpm-tools`). No compiled code, the package is `noarch`.

```
./build-rpm.sh   # -> build/sailfish-media-volume-keys-<version>-1.noarch.rpm
```

## License

MIT, see [LICENSE](LICENSE).
