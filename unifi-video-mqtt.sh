#!/bin/bash

# Unifi Video Vars
UNIFI_MOTION_LOG=/var/log/unifi-video/motion.log

# MQTT Vars
#MQTT_SERVER="192.168.x.x"
#MQTT_PORT="1883"
#MQTT_TOPIC_BASE="camera/motion"

# MQTT User/Pass Vars, only use if needed
#MQTT_USER="username"
#MQTT_PASS="password"
#MQTT_ID="yourid"  ## To make it work with hassio

# Camera Defs
#CAM1_NAME="camera_name"
#CAM1_ID="F0xxxxxxxxxx"

# --------------------------------------------------------------------------------
# Script starts here

# Check if a username/password is defined and if so create the vars to pass to the cli
if [[ -n "$MQTT_USER" && -n "$MQTT_PASS" ]]; then
  MQTT_USER_PASS="-u $MQTT_USER -P $MQTT_PASS"
else
  MQTT_USER_PASS=""
fi

# Check if a MQTT_ID has been defined, needed for newer versions of Home Assistant
if [[ -n "$MQTT_ID" ]]; then
  MQTT_ID_OPT="-I $MQTT_ID"
else
  MQTT_ID_OPT=""
fi

# Check for version of log file, the format changed in Unifi Video 3.10
VER_TEST=`tail -1 $UNIFI_MOTION_LOG | awk {'print $6'} | cut -d '[' -f 1`

while inotifywait -e modify $UNIFI_MOTION_LOG; do
  LAST_MESSAGE=`tail -n1 $UNIFI_MOTION_LOG`

  if [[ $VER_TEST == "Camera" ]]; then
    # New Format
    LAST_CAM=`echo $LAST_MESSAGE | awk -F '[][]' '{print $4}'`
  else
    # Old Format
    LAST_CAM=`echo $LAST_MESSAGE | awk -F '[][]' '{print $2}'`
  fi

  LAST_EVENT=`echo $LAST_MESSAGE | cut -d ':' -f 5 | cut -d ' ' -f 1`

  if echo $LAST_CAM | grep $CAM1_ID; then
    # Camera 1 triggered
	  if [[ $LAST_EVENT == "start" ]]; then
	    echo "Motion started on $CAM1_NAME"
	    mosquitto_pub -h $MQTT_SERVER -p $MQTT_PORT $MQTT_USER_PASS -r $MQTT_ID_OPT -t $MQTT_TOPIC_BASE/$CAM1_NAME -m "ON" &
	  else
	    echo "Motion stopped on $CAM1_NAME"
	    mosquitto_pub -h $MQTT_SERVER -p $MQTT_PORT $MQTT_USER_PASS -r $MQTT_ID_OPT -t $MQTT_TOPIC_BASE/$CAM1_NAME -m "OFF" &
	  fi
  fi
done
