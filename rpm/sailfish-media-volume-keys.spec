# Volume keys for Sailfish OS, packaged as an RPM Patchmanager patch (see Patchmanager's
# README-Patch-Developers.md). Built by ../build-rpm.sh (noarch, only the patch files).
# Up to 1.1 this package installed the Settings files directly; from 2.0 the patch adds
# them, so an update removes the old files and the user activates the patch.
%global patchname sailfish-media-volume-keys
%global patchdir %{_datadir}/patchmanager/patches/%{patchname}

Name:       sailfish-media-volume-keys
Version:    %{mvk_version}
Release:    10
Summary:    Choose what the volume keys control (Patchmanager patch)
License:    MIT
URL:        https://github.com/lorenz-graf/sailfish-media-volume-keys
BuildArch:  noarch
Requires:   patchmanager >= 3.0
Requires:   jolla-settings
Requires:   lipstick-jolla-home-qt5

%description
A Patchmanager patch for Settings > Sounds and feedback: an alarm and timer volume
slider (never below 20 %) and a choice of what the volume keys control (ringtone,
media or alarm volume), optionally the alarm volume while the Clock app is open.
Also "Alarm volume" and "Media keys" for the Top menu.

After installing or updating, activate "Volume keys" in Settings > Patchmanager and
pull down > Restart preloaded services. Uninstalling deactivates the patch first.

# Patchmanager unapplies with the diff stored in the patch dir, so the patch must be
# deactivated before its files are replaced (update) or removed. "patchmanager -u"
# asks the daemon over D-Bus and waits; for a patch that isn't active it does nothing.
%pre
export NO_PM_PRELOAD=1
if [ -x /usr/sbin/patchmanager ] && [ -d %{patchdir} ]; then
    /usr/sbin/patchmanager -u %{patchname} >/dev/null 2>&1 || :
fi
exit 0

%preun
export NO_PM_PRELOAD=1
if [ "$1" -eq 0 ] && [ -x /usr/sbin/patchmanager ]; then
    /usr/sbin/patchmanager -u %{patchname} >/dev/null 2>&1 || :
fi
exit 0

%postun
if [ "$1" -eq 0 ]; then
    # Uninstalled: the volume keys go back to the default for every user with a
    # running session (the stock homescreen still reads force_mediavolume).
    for sock in /run/user/*/dbus/user_bus_socket; do
        [ -S "$sock" ] || continue
        uid=$(echo "$sock" | cut -d/ -f4)
        user=$(getent passwd "$uid" | cut -d: -f1)
        [ -n "$user" ] || continue
        su -s /bin/sh -c "export DBUS_SESSION_BUS_ADDRESS=unix:path=$sock; dconf reset /jolla/sound/force_mediavolume; dconf reset -f /apps/sailfish-media-volume-keys/" "$user" >/dev/null 2>&1 || :
    done
fi
exit 0

%prep
cp %{_sourcedir}/LICENSE .

%build

%install
install -D -m 0644 %{_sourcedir}/patch.json         %{buildroot}%{patchdir}/patch.json
install -D -m 0644 %{_sourcedir}/unified_diff.patch %{buildroot}%{patchdir}/unified_diff.patch

%files
%license LICENSE
%dir %{patchdir}
%{patchdir}/patch.json
%{patchdir}/unified_diff.patch
