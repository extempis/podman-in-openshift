#!/usr/bin/env bash
set -x 

# set uid to the user
echo "${USER_NAME:-podman}:x:$(id -u):0:${USER_NAME:-podman} podman:${HOME}:/bin/bash" >> /etc/passwd
echo "${USER_NAME:-podman}:x:$(id -u):" >> /etc/group

#set subuid/subgid for rootless
USER=$(whoami)
START_ID=$(( $(id -u)+1 ))
echo "${USER}:${START_ID}:2147483646" > /etc/subuid
echo "${USER}:${START_ID}:2147483646" > /etc/subgid

# this is not needed for ocp 4.15 and higer clusters as fuse-overlayfs will be made available
# https://docs.openshift.com/container-platform/4.15/nodes/containers/nodes-containers-dev-fuse.html#nodes-containers-dev-fuse
mkdir -p ${HOME}/.config/containers
(echo '[storage]';echo 'driver = "vfs"') > ${HOME}/.config/containers/storage.conf

exec "$@"
