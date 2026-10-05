FROM quay.io/konveyor/builder:latest as gobuilder

RUN go install github.com/google/pprof@latest

FROM quay.io/openshift/origin-must-gather:4.11 as builder

FROM registry.access.redhat.com/ubi9-minimal:latest
RUN echo -ne "[centos-9-appstream]\nname = CentOS 9 (RPMs) - AppStream\nbaseurl = http://mirror.stream.centos.org/9-stream/AppStream/x86_64/os/\nenabled = 1\ngpgcheck = 0" > /etc/yum.repos.d/centos.repo

RUN microdnf -y install rsync tar gzip graphviz findutils

COPY --from=gobuilder /opt/app-root/src/go/bin/pprof /usr/bin/pprof
COPY --from=builder /usr/bin/oc /usr/bin/oc

COPY collection-scripts/* /usr/bin/
COPY collection-scripts/logs/* /usr/bin/
COPY collection-scripts/time_window_gather /usr/bin/

ENTRYPOINT /usr/bin/gather
