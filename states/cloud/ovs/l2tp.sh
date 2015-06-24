WIP

#auto l2tpeth0
iface l2tpeth0 inet manual
    pre-up modprobe l2tp_eth
    pre-up ip l2tp add tunnel tunnel_id 3000 peer_tunnel_id 4000 encap udp local 58.215.181.42 remote 58.215.181.46 udp_sport 5000 udp_dport 6000
    pre-up ip l2tp add session tunnel_id 3000 session_id 1000 peer_session_id 2000
    # pure ip
    #pre-up ip link set l2tpeth0 up mtu 1488
    # raw ethernet
    pre-up ip link set l2tpeth0 up mtu 1446

