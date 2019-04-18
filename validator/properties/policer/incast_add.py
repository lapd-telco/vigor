from state import flow_emap, dyn_vals
EXP_TIME = 10
LAN_DEVICE = 0
WAN_DEVICE = 1
BURST = 125000
RATE = 12500
WORD_SIZE = 4
ETHER_IP_HDRLEN = 34

h2 = pop_header(ipv4, on_mismatch=([],[]))
# malformed ipv4 header
if h2.vihl & 0xf < 5 or (packet_size - ETHER_IP_HDRLEN < ((h2.vihl & 0xf) - 5)*WORD_SIZE):
    return ([],[])
h1 = pop_header(ether, on_mismatch=([],[]))

if EXP_TIME <= now:
    flow_emap.expire_all(now - EXP_TIME)

if (received_on_port == WAN_DEVICE and
    not flow_emap.has(ip_addrc(h2.daddr)) and
    not flow_emap.full()):
    flow_idx = the_index_allocated
    flow_emap.add(ip_addrc(h2.daddr), flow_idx, now)
    flow = DynamicValuec(BURST - packet_size, now)
    dyn_vals.set(flow_idx, flow)
    return ([LAN_DEVICE], [ether(h1), ipv4(h2)])
else:
    pass