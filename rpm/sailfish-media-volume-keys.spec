# Media volume keys for Sailfish OS: a Settings page and a Top menu toggle that make the
# volume keys always control media volume. Built by ../build-rpm.sh (noarch, no compiled code).
# Sailfish defines %%_unitdir (systemd rpm macros); rpmbuild outside the SDK may not.
%{!?_unitdir:%global _unitdir /usr/lib/systemd/system}

Name:       sailfish-media-volume-keys
Version:    %{mvk_version}
Release:    1
Summary:    Make the volume keys always control media volume
License:    MIT
URL:        https://github.com/lorenz-graf/sailfish-media-volume-keys
BuildArch:  noarch
Requires:   jolla-settings
Requires:   lipstick-jolla-home-qt5
Requires:   polkit
Requires:   systemd

%description
Adds Settings > Volume keys with a switch that makes the volume keys always change
the media volume, also when nothing is playing (by default they change the ringtone
volume then). A matching toggle can be added to the Top menu.

It uses a setting the homescreen already supports (/jolla/sound/force_mediavolume);
nothing is patched. The page has an Uninstall button, which removes the package and
switches the setting back off.

%prep
cp %{_sourcedir}/LICENSE .

%build

%install
S=%{_sourcedir}
P=%{buildroot}%{_datadir}/jolla-settings/pages/sailfish-media-volume-keys
install -D -m 0644 $S/sailfish-media-volume-keys.json    %{buildroot}%{_datadir}/jolla-settings/entries/sailfish-media-volume-keys.json
install -D -m 0644 $S/MediaVolumeKeysPage.qml   $P/MediaVolumeKeysPage.qml
install -D -m 0644 $S/MediaVolumeKeysToggle.qml $P/MediaVolumeKeysToggle.qml
install -D -m 0644 $S/sailfish-media-volume-keys-uninstall.service %{buildroot}%{_unitdir}/sailfish-media-volume-keys-uninstall.service
install -D -m 0644 $S/49-sailfish-media-volume-keys.rules %{buildroot}%{_datadir}/polkit-1/rules.d/49-sailfish-media-volume-keys.rules

%post
systemctl daemon-reload >/dev/null 2>&1 || :

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
systemctl daemon-reload >/dev/null 2>&1 || :

%files
%license LICENSE
%dir %{_datadir}/jolla-settings/pages/sailfish-media-volume-keys
%{_datadir}/jolla-settings/entries/sailfish-media-volume-keys.json
%{_datadir}/jolla-settings/pages/sailfish-media-volume-keys/MediaVolumeKeysPage.qml
%{_datadir}/jolla-settings/pages/sailfish-media-volume-keys/MediaVolumeKeysToggle.qml
%{_unitdir}/sailfish-media-volume-keys-uninstall.service
%{_datadir}/polkit-1/rules.d/49-sailfish-media-volume-keys.rules
