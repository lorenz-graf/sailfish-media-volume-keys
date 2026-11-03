# Media volume keys for Sailfish OS: a Settings page and a Top menu toggle that make the
# volume keys always control media volume. Built by ../build-rpm.sh (noarch, no compiled code).

Name:       sailfish-media-volume-keys
Version:    %{mvk_version}
Release:    1
Summary:    Make the volume keys always control media volume
License:    MIT
URL:        https://github.com/lorenz-graf/sailfish-media-volume-keys
BuildArch:  noarch
Requires:   jolla-settings
Requires:   lipstick-jolla-home-qt5

%description
Adds Settings > Volume keys with a switch that makes the volume keys always change
the media volume, also when nothing is playing (by default they change the ringtone
volume then). A matching toggle can be added to the Top menu.

It uses a setting the homescreen already supports (/jolla/sound/force_mediavolume);
nothing is patched. Uninstalling switches it back off for logged-in users.

%prep
cp %{_sourcedir}/LICENSE .

%build

%install
S=%{_sourcedir}
P=%{buildroot}%{_datadir}/jolla-settings/pages/sailfish-media-volume-keys
install -D -m 0644 $S/sailfish-media-volume-keys.json    %{buildroot}%{_datadir}/jolla-settings/entries/sailfish-media-volume-keys.json
install -D -m 0644 $S/MediaVolumeKeysPage.qml   $P/MediaVolumeKeysPage.qml
install -D -m 0644 $S/MediaVolumeKeysToggle.qml $P/MediaVolumeKeysToggle.qml

%postun
if [ "$1" -eq 0 ]; then
    # Uninstalled: turn the setting off again for every user with a running session.
    for sock in /run/user/*/dbus/user_bus_socket; do
        [ -S "$sock" ] || continue
        uid=$(echo "$sock" | cut -d/ -f4)
        user=$(getent passwd "$uid" | cut -d: -f1)
        [ -n "$user" ] || continue
        su -s /bin/sh -c "DBUS_SESSION_BUS_ADDRESS=unix:path=$sock dconf reset /jolla/sound/force_mediavolume" "$user" >/dev/null 2>&1 || :
    done
fi

%files
%license LICENSE
%dir %{_datadir}/jolla-settings/pages/sailfish-media-volume-keys
%{_datadir}/jolla-settings/entries/sailfish-media-volume-keys.json
%{_datadir}/jolla-settings/pages/sailfish-media-volume-keys/MediaVolumeKeysPage.qml
%{_datadir}/jolla-settings/pages/sailfish-media-volume-keys/MediaVolumeKeysToggle.qml
