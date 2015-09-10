
hyperion-switcher
======================

This script is a fork from [hyperion-config-switch](https://github.com/Hwulex/hyperion-config-switch). The original uses networking to detect changes. However, I didn't feel like routing another UTP cable to my TV set so I tried to convert the script to use CEC instead. After a bit of digging I found out that the RPi could listen in on CEC events. With this ability I was able to alter the behaviour of Hyperion based on CEC events.

### AVR Compatability

Any CEC enabled AVR should be compatible, albeit with different codes for HDMI input sources. For example, my Yamaha seems to prefix every HDMI input number with `2`. So I get `21` when I switch to HDMI 1. An Onkyo seems to prefix it with `3` so that HDMI 1 would become `31`.

### Finding the necessary CEC codes

To start finding your HDMI CEC codes (or if you AVR is compatible) you should start with this command:
```
cec-client -m -d 8
```
It should show you any CEC communications currently happening. Start changing HDMI inputs on your AVR and see if there are any codes on the screen that look like `5f:80:XX:00:XX:00` where XX can be any number.

To break this down:
- 5 means it's coming from your AVR
- f means that it's a broadcast (for any device)
- 80 means a change happened in HDMI routing
- The first XX should indicate the previous HDMI input
- The second XX should indicate the current HDMI input <- this is what you want to know

So for example, on my Yamaha, if I change from HDMI 1 to HDMI 2 I should see the code `5f:80:21:00:22:00`. Notice the 21 and 22. Yamaha seems to prefix the HDMI input numbers with `2` whereas Onkyo seems to prefix them with `3`. I don't currently know about any other AVR models.
Every input number that you want to use for the v4l2 grabber should be added to the `src_grabber` config field, seperated with `|`.

This process is also described in the config file.

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

mkdir /storage/hyperion/switcher/ && cd /storage/hyperion/switcher/
curl -L --output hyperion-switcherd.sh --get https://raw.githubusercontent.com/Schamper/hyperion-switcher/master/hyperion-switcherd.sh
curl -L --output hyperion-switcher.conf --get https://raw.githubusercontent.com/Schamper/hyperion-switcher/master/hyperion-switcher.conf
chmod a+x hyperion-switcherd.sh
```

Also add this line to `/storage/.config/autostart.sh`:
```
/storage/hyperion/switcher/hyperion-switcherd.sh /storage/hyperion/switcher/hyperion-switcher.conf > /dev/null 2>&1 &
```

Now you need to edit the configuration file, `/storage/hyperion/switcher/hyperion-switcher.conf` to your needs.
All the information regarding the configuration is included in the comments.

At this point it's probably easiest to reboot.

## Killing the Switcher

If you need to kill the switch script, run

OpenELEC:

`killall -9 hyperion-switcherd.sh`
