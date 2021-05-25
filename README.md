# Docker Jibri Pulseaudio

[![Docker Image Version](https://img.shields.io/docker/v/prayagsingh/jibri-pulseaudio/latest)](https://hub.docker.com/r/prayagsingh/jibri-pulseaudio/tags) [![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/prayagsingh/jibri-pulseaudio)](https://hub.docker.com/r/prayagsingh/jibri-pulseaudio)


#### Run Jibri using PulseAudio.

#### Try `prayagsingh/jibri:pulse_v2.2` docker image. Using unstable build.

#### Please use `prayagsingh/jibri-pulseaudio:latest` for latest changes using unstable build.

#### Inbuilt Support for streaming to any rtmp server and to facebook too(one at a time). 

#### Inbuilt support for rclone. use rclone to copy the recording to either google drive or S3 compatible storage. Need to add the logic in finalize.sh file.

**NOTE 1: It is mandatory to map `/dev/shm` else chrome crashes when screen-share is enabled**

### FILES

1. Use `examples/jibri.yml` with docker-compose.
2. Use `examples/stack-jibri.yml` with `docker stack deploy`.
3. Use `examples/jibri-k8s` directory to setup jibri on k8s. Use `examples/jibri-k8s/kustomization.yaml` for deployment. `Kustomize` version is `v4.0.5`.
4. Look for `update_this` and change the value accordingly. Also change `meet.example.com` with a valid URL.

***NOTE 2:*** Here I'm using `external` network in both the files. Please change it accordingly. 

***NOTE 3:*** Please take the necessary steps to secure the AWS keys when using with rclone. 

### SETUP tested 
1. **docker-compose:** working with `1920x1080` 
2. **docker-swarm:** working with `1920x1080` 
3. **k8s:** working with `1280x720` resolution only. With `1920x1080`, the memory consumption reached up to 7.5 GiB and vCPU up to 6 and after 10 minutes recording crashed. With resolution `1280x720`, recording went fine. Tested in 50 minutes meeting with 3 participants and with/without screen-sharing. In order to lower down the resolution to `1280x720`, we have to change `Virtual 1920 1080`  with `Virtual 1280 720` in `xorg-video-dummy.conf` file and set env variable `JIBRI_FFMPEG_RESOLUTION="1280x720"`.

**K8s resource usage with 1280x720 resolution with 3 participants in a meeting: Stable**

![Screenshot (619)](https://user-images.githubusercontent.com/8455114/114389163-48a21d80-9bb2-11eb-893f-43b80dae7dfc.png)

**K8s resource usage with 1920x1080 resolution with 3 participants in a meeting: Unstable and Crashed**

![Screenshot (617)](https://user-images.githubusercontent.com/8455114/114389344-843ce780-9bb2-11eb-96ad-5c2a9c947742.png)
