#! /bin/bash

# The bird config file path is different for Red Hat and Debian/Ubuntu.
if [ -f /etc/bird6.conf ]; then
    BIRD_CONF=/etc/bird6.conf
else
    BIRD_CONF=/etc/bird/bird6.conf
fi

BIRD_CONF_TEMPLATE=/usr/share/calico/bird/calico-bird6.conf.template
BIRD_CONF_PEER_TEMPLATE=/usr/share/calico/bird/calico-bird6-peer.conf.template

# Require 4 arguments.
[ $# -eq 4 ] || cat <<EOF

Usage: $0 <my-ipv4-address> <my-ipv6-address> <rr-ipv6-address> <as-number>

where
  <my-ipv4-address> is the external IPv4 address of the local machine
  <my-ipv6-address> is the external IPv6 address of the local machine
  <rr-ipv6-address> is the IPv6 address of the route reflector that
      the local BIRD6 should peer with
  <as-number> is the BGP AS number that the route reflector is using.

Please specify exactly these 4 required arguments.

EOF
[ $# -eq 4 ] || exit -1

# Name the arguments.
my_ipv4_address=$1
my_ipv6_address=$2
rr_ipv6_address=$3
as_number=$4

# Generate peer-independent BIRD config.
mkdir -p $(dirname $BIRD_CONF)
sed -e "
s/@MY_IPV4_ADDRESS@/$my_ipv4_address/;
" < $BIRD_CONF_TEMPLATE > $BIRD_CONF

# Generate config to peer with route reflector.
sed -e "
s/@ID@/N1/;
s/@DESCRIPTION@/Connection to BGP route reflector/;
s/@MY_IPV6_ADDRESS@/$my_ipv6_address/;
s/@PEER_IPV6_ADDRESS@/$rr_ipv6_address/;
s/@AS_NUMBER@/$as_number/;
" < $BIRD_CONF_PEER_TEMPLATE >> $BIRD_CONF

echo BIRD6 configuration generated at $BIRD_CONF

service bird6 restart
echo BIRD6 restarted
