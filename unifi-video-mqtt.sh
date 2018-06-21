#!/bin/bash

# Unifi Video Vars
UNIFI_MOTION_LOG=/var/log/unifi-video/motion.log

# MQTT Vars
MQTT_SERVER="192.168.x.x"
MQTT_TOPIC_BASE="camera/motion"

# Camera Defs
CAM1_NAME="camera_name"
CAM1_ID="F0xxxxxxxxxx"

while inotifywait -e modify $UNIFI_MOTION_LOG; do
  LAST_MESSAGE=`tail -n1 $UNIFI_MOTION_LOG`
  LAST_CAM=`echo $LAST_MESSAGE | awk -F '[][]' '{print $2}'`
  LAST_EVENT=`echo $LAST_MESSAGE | cut -d ':' -f 5 | cut -d ' ' -f 1`

  if echo $LAST_CAM | grep -n1 $CAM1_ID; then
    # Camera 1 triggered
	  if [[ $LAST_EVENT == "start" ]]; then
	    echo "Motion started on $CAM1_NAME"
	    mosquitto_pub -h $MQTT_SERVER -r -t $MQTT_TOPIC_BASE/$CAM1_NAME -m "ON" &
	  else
	    echo "Motion stopped on $CAM1_NAME"
	    mosquitto_pub -h $MQTT_SERVER -r -t $MQTT_TOPIC_BASE/$CAM1_NAME -m "OFF" &
	  fi
  fi
done
