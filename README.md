# jibri-pulseaudio
Jibri using pulseaudio

## Run Jibri using PulseAudio. Try `prayagsingh/jibri:pulse_v2.1` docker image.

## Inbuilt Support for streaming to any rtmp server and to facebook too(one at a time). 

## Inbuilt support for rclone. use rclone to copy the recording to either google drive or S3 bucket. Need to add the logic in finalize.sh file. 

## Tested with docker-compose and docker-swarm setup. 

**NOTE: It is mandatory to map `/dev/shm` else chrome crashes with screen-sharing**