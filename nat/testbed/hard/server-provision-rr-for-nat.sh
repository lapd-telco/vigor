. ./config.sh

ifconfig $SERVER_DEVICE up
ip addr flush dev $SERVER_DEVICE
ip addr add $SERVER_IP/24 dev $SERVER_DEVICE
arp -s $MB_IP_TO_SRV $MB_TO_SRV_MAC