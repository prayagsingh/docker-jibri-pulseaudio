# jibri-pulseaudio

#### Run Jibri using PulseAudio.

#### Try `prayagsingh/jibri:pulse_v2.1` docker image. Using unstable build. 

#### Inbuilt Support for streaming to any rtmp server and to facebook too(one at a time). 

#### Inbuilt support for rclone. use rclone to copy the recording to either google drive or S3 bucket. Need to add the logic in finalize.sh file. 

#### Tested with docker-compose and docker-swarm setup. 

**NOTE: It is mandatory to map `/dev/shm` else chrome crashes with screen-sharing**

### FILES

1. Use `jibri.yml` with docker-compose.
2. Use `stack-jibri.yml` with `docker stack deploy`. 

***NOTE:*** Here I'm using `external` network in both the files. Please change it accordingly. 

### SETUP tested 
1. docker-compose 
2. docker-swarm
3. k8s (WIP)
