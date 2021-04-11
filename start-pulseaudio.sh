#!/bin/bash

#pulseaudio -D --exit-idle-time=-1
pulseaudio -D --realtime=true --exit-idle-time=-1 --high-priority=true --log-target=stderr

# Load the virtual sink and set it as default
pacmd load-module module-virtual-sink sink_name=v1
pacmd set-default-sink v1

# set the monitor of v1 sink to be the default source
pacmd set-default-source v1.monitor