FROM registry.access.redhat.com/ubi9/ubi-minimal

ARG USER_HOME_DIR="/home/podman"

ENV HOME=${USER_HOME_DIR}
ENV BUILDAH_ISOLATION=chroot
ENV PODMAN_IGNORE_CGROUPSV1_WARNING=true

RUN microdnf --disableplugin=subscription-manager install --setopt=install_weak_deps=0 --setopt=tsflags=nodocs -y git tar jq podman buildah skopeo &&\
    microdnf update -y &&\
    microdnf clean all &&\
    mkdir -p ${USER_HOME_DIR} &&\
    touch /etc/subuid /etc/subgid &&\
    chmod -R g=u /etc/passwd /etc/group /etc/subuid /etc/subgid /home 

WORKDIR ${HOME}

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]