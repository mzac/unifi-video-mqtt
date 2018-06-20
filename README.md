# unifi-video-mqtt

# Introduction
This script can run on your Unifi Video server and push MQTT messages to a broker when motion is detected.

This can be useful for systems like Homeassistant that are lacking motion detection integration with Unifi Video.

Currently, the script is only setup for one camera but others can be added easily by modifying
the script.

# Requirements
* Unifi Video Server
* MQTT Client
* MQTT Server
* Inotify Tools

# Installation

The installation should be done on your server that is running Unifi video

Debian based install
```
apt install -y inotify-tools mosquitto-clients
cd /tmp
git clone https://github.com/mzac/unifi-video-mqtt.git
cd /tmp/unifi-video-mqtt
cp unifi-video-mqtt.sh /usr/local/bin
chown unifi-video:unifi-video /usr/local/bin/unifi-video-mqtt.sh
chmod a+x /usr/local/bin/unifi-video-mqtt.sh
cp unifi-video-mqtt.service /etc/systemd/system
systemctl daemon-reload
systemctl enable unifi-video-mqtt
```

Before starting the service, make sure to edit */usr/local/bin/unifi-video-mqtt.sh* with your specific
settings (ip, username, password, etc)

Test it to make sure it works:
```
/usr/local/bin/unifi-video-mqtt
```

Create some motion on your camera and subscribe to your MQTT server and see if you see motion:

```
root@pi3:~# mosquitto_sub -h 192.168.x.x -t "camera/motion/#" -v
camera/motion/front_door on
camera/motion/front_door off
```

Once all changes are done, go ahead and start the daemon
```
systemctl start unifi-video-mqtt
```
