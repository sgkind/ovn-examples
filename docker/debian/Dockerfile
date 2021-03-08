FROM ubuntu:16.04
MAINTAINER "Aliasgar Ginwala" <aginwala@ebay.com>

ARG OVN_BRANCH
ARG GITHUB_SRC
ARG DISTRO

copy $DISTRO/build.sh /build.sh
copy install_ovn.sh /install_ovn.sh
copy ovs /build/ovs
copy ovn /build/ovn
RUN /build.sh $OVN_BRANCH $GITHUB_SRC

COPY ovn_default_nb_port /etc/ovn/ovn_default_nb_port
COPY ovn_default_sb_port /etc/ovn/ovn_default_sb_port
COPY ovn_default_northd_host /etc/ovn/ovn_default_northd_host

COPY start-ovn /bin/start-ovn
COPY scripts/start-ovs /bin/start-ovs
COPY scripts/start-ovn-controller /bin/start-ovn-controller
COPY scripts/start-ovn-northd /bin/start-ovn-northd
COPY scripts/stop-ovs /bin/stop-ovs
COPY scripts/stop-ovn-controller /bin/stop-ovn-controller
COPY scripts/stop-ovn-northd /bin/stop-ovn-northd
VOLUME ["/var/log/openvswitch", \
"/var/lib/openvswitch", "/var/run/openvswitch", "/etc/openvswitch", \
"/var/log/ovn", "/var/lib/ovn", "/var/run/ovn", "/etc/ovn"]
