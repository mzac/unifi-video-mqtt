# unifi-video-mqtt

# Introduction
This script can run on your Unifi Video server and push MQTT messages to a broker when motion is detected.

This can be useful for systems like Homeassistant that are lacking motion detection integration with Unifi Video.

Currently, the script is only setup for one camera but others can be added easily by modifying the script.

# Unifi Protect
If you are looking for Unifi protect please see this fork:
* https://github.com/terafin/mqtt-unifi-protect-bridge
* https://github.com/terafin/unifi-video-mqtt (depreciated)

# Reference
Unifi Video writes to */var/log/unifi-video/motion.log* and it ouputs logs like this.  This script parses this log:
```
1559209064.179 2019-05-30 19:07:44.179/ACST: INFO   [uv.analytics.motion] [AnalyticsService] [REDACTED|Front Door] MotionEvent type:start event:17 clock:14369834 in AnalyticsEvtBus-0
1559209090.983 2019-05-30 19:08:10.983/ACST: INFO   [uv.analytics.motion] [AnalyticsService] [REDACTED|Front Door] MotionEvent type:stop event:17 clock:14396566 in AnalyticsEvtBus-1
```

# Todo
* Re-write in Python as it might be more efficient

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
MQTT_PORT="1883"
MQTT_TOPIC_BASE="camera/motion"

# MQTT User/Pass Vars, only use if needed
#MQTT_USER="username"
#MQTT_PASS="password"
#MQTT_ID="yourid"  ## To make it work with hassio

# Camera Defs
CAM1_NAME="camera_name"
CAM1_ID="F0xxxxxxxxxx"
```

Test it to make sure it works:
```
/usr/local/bin/unifi-video-mqtt.sh
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
