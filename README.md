# unifi-video-mqtt

# Introduction
This script can run on your Unifi Video server and push MQTT messages to a broker when motion is detected.

This can be useful for systems like Homeassistant that are lacking motion detection integration with Unifi Video.

Currently, the script is only setup for one camera but others can be added easily by modifying the script.

# Reference
Unifi Video writes to */var/log/unifi-video/motion.log* and it ouputs logs like this.  This script parses this log:
```
1529536461.847 2018-06-20 19:14:21.847/EDT: INFO   Camera[F0xxxxxxxxxx] type:start event:13 clock:11856432 (Front Door) in ApplicationEvtBus-7
1529536479.865 2018-06-20 19:14:39.865/EDT: INFO   Camera[F0xxxxxxxxxx] type:stop event:13 clock:11874454 (Front Door) in ApplicationEvtBus-16
```

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

# IMPORTANT!!!
Before starting the service, make sure to edit */usr/local/bin/unifi-video-mqtt.sh* with your specific
settings:

```
# MQTT Vars
MQTT_SERVER="192.168.x.x"
MQTT_TOPIC_BASE="camera/motion"

# Camera Defs
CAM1_NAME="camera_name"
CAM1_ID="F0xxxxxxxxxx"
```

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
