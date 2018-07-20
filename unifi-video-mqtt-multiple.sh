#!/bin/bash

# Unifi Video Vars
UNIFI_MOTION_LOG=/var/log/unifi-video/motion.log

# MQTT Vars
MQTT_SERVER="192.168.x.x"
MQTT_TOPIC_BASE="camera/motion"

# MQTT User/Pass Vars, only use if needed
#MQTT_USER="username"
#MQTT_PASS="password"

# Camera Defs
CAM1_NAME="camera1_name"
CAM1_ID="F0xxxxxxxxxx"
CAM2_NAME="camera2_name"
CAM2_ID="F0xxxxxxxxxx"
CAM3_NAME="camera3_name"
CAM4_ID="F0xxxxxxxxxx"

# --------------------------------------------------------------------------------
# Script starts here

if [[ -n "$MQTT_USER" && -n "$MQTT_PASS" ]]; then
  $MQTT_USER_PASS="-u $MQTT_USER -P $MQTT_PASS"
else
  $MQTT_USER_PASS=""
fi

while inotifywait -e modify $UNIFI_MOTION_LOG; do
  LAST_MESSAGE=`tail -n1 $UNIFI_MOTION_LOG`
  LAST_CAM=`echo $LAST_MESSAGE | awk -F '[][]' '{print $2}'`
  LAST_EVENT=`echo $LAST_MESSAGE | cut -d ':' -f 5 | cut -d ' ' -f 1`

  if echo $LAST_CAM | grep -n1 $CAM1_ID; then
    # Camera 1 triggered
	  if [[ $LAST_EVENT == "start" ]]; then
	    echo "Motion started on $CAM1_NAME"
	    mosquitto_pub -h $MQTT_SERVER $MQTT_USER_PASS -r -t $MQTT_TOPIC_BASE/$CAM1_NAME -m "ON" &
	  else
	    echo "Motion stopped on $CAM1_NAME"
	    mosquitto_pub -h $MQTT_SERVER $MQTT_USER_PASS -r -t $MQTT_TOPIC_BASE/$CAM1_NAME -m "OFF" &
	  fi
  fi

  if echo $LAST_CAM | grep -n1 $CAM2_ID; then
    # Camera 2 triggered
	  if [[ $LAST_EVENT == "start" ]]; then
	    echo "Motion started on $CAM2_NAME"
	    mosquitto_pub -h $MQTT_SERVER $MQTT_USER_PASS -r -t $MQTT_TOPIC_BASE/$CAM2_NAME -m "ON" &
	  else
	    echo "Motion stopped on $CAM2_NAME"
	    mosquitto_pub -h $MQTT_SERVER $MQTT_USER_PASS -r -t $MQTT_TOPIC_BASE/$CAM2_NAME -m "OFF" &
	  fi
  fi

  if echo $LAST_CAM | grep -n1 $CAM3_ID; then
    # Camera 3 triggered
	  if [[ $LAST_EVENT == "start" ]]; then
	    echo "Motion started on $CAM3_NAME"
	    mosquitto_pub -h $MQTT_SERVER $MQTT_USER_PASS -r -t $MQTT_TOPIC_BASE/$CAM3_NAME -m "ON" &
	  else
	    echo "Motion stopped on $CAM3_NAME"
	    mosquitto_pub -h $MQTT_SERVER $MQTT_USER_PASS -r -t $MQTT_TOPIC_BASE/$CAM3_NAME -m "OFF" &
	  fi
  fi
done
