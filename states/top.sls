base:

  '*':
    - disable_puppet
    - sync
    - apt
    - tmux
    - salt
    - disable_autostart
    - purge

  'compute,controller,controller2,compute2,compute3':
    - match: list
    - apt.openstack
    - ca-certs
    - cloud.ovs
    - cloud.keystone
    - cloud.glance
    - cloud.nova
    - cloud.neutron

  'monitoring':
    - vim

  '*puppet':
    - sync
    - os-tempest
    - tmux

