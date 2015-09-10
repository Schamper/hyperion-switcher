
hyperion-switcher
======================

This script was created to allow an [Hyperion](https://github.com/tvdzwan/hyperion/) Ambilight configuration to be altered in reaction to external factors, such as a change in AVR power or input. This was something I desired to be able to do myself, but was also spurred on by requests for such features in the [Hyperion Issues forum](), specifically issues [#177](https://github.com/tvdzwan/hyperion/issues/177) and [#186](https://github.com/tvdzwan/hyperion/issues/186).

My own AVR is a Yamaha RX-V773. Upon investigation I found the RPi could listen in on CEC events. With this ability I was able to alter the behaviour of Hyperion based on CEC events.

### AVR Compatability

Any CEC enabled AVR should be compatible, albeit with different codes for HDMI input sources. For example, my Yamaha seems to prefix every HDMI input number with `2`. So I get `21` when I switch to HDMI 1. An Onkyo seems to prefix it with `3` so that HDMI 1 would become `31`.

## Suggested Installation

Move your existing config file and creating a symbolic link as the file Hyperion will look for. This makes it easier to switch scripts without anything getting overwritten.

#### OpenELEC

SSH as **root** to your installation using `ssh root@box.ip.add.ress`. The default passwords are _openelec_ and _rasplex_ for the respective installs. Now complete the following steps:

```
cd /storage/.config/
mv hyperion.config.json hyperion.config.default.json
ln -s hyperion.config.default.json hyperion.config.json

killall hyperiond
/storage/hyperion/bin/hyperiond.sh /storage/.config/hyperion.config.json </dev/null >/dev/null 2>&1 &

git clone https://github.com/Schamper/hyperion-switcher.git /storage/hyperion/switcher/
cd /storage/hyperion/switcher/
chmod a+x hyperion-switcherd.sh
```

Also add this to `/storage/.config/autostart.sh`:
```
/storage/hyperion/switcher/hyperion.switcher.sh /storage/hyperion/switcher/hyperion.switcher.conf > /dev/null 2>&1 &
```

Now you need to edit the configuration file, `/storage/hyperion/switcher/hyperion-switcher.conf` to your needs.
All the information regarding the configuration is included in the comments.

## Killing the Switcher

If you need to kill the switch script, run

OpenELEC:

`killall -9 hyperion-switcherd.sh`
