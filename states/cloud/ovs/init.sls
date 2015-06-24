include:
  - base: apt.openstack

openvswitch-switch:
  pkg:
    - installed

cloud-init:
  pkg:
    - purged

openvswitch-service:
  service:
    - running
    - enable: True
    - restart: True
    - name: openvswitch-switch
    - require:
      - pkg: openvswitch-switch

br-int-bridge:
  cmd.run:
    - name: ovs-vsctl add-br br-int
    - unless: ovs-vsctl list-br | grep 'br-int'
    - require:
      - service: openvswitch-service

br-tun-bridge:
  cmd.run:
    - name: ovs-vsctl add-br br-tun
    - unless: ovs-vsctl list-br | grep 'br-tun'
    - require:
      - service: openvswitch-service

br-inet-bridge:
  cmd.script:
    - source: salt://cloud/ovs/bridge-creator.sh
    - cwd: /var/tmp
    - user: root
    - unless: ovs-vsctl list-br | grep 'br-inet'
    - template: jinja
    - defaults:
      IFACE: {{pillar['inet-iface']}}
      NAME: inet

br-prov-bridge:
  cmd.script:
    - source: salt://cloud/ovs/bridge-creator.sh
    - cwd: /var/tmp
    - user: root
    - unless: ovs-vsctl list-br | grep 'br-prov'
    - template: jinja
    - defaults:
      IFACE: {{pillar['prov-iface']}}
      NAME: prov

br-prov-grain:
    grains.present:
      - name: br-prov
      - value: True
    require:
      - cmd: br-prov-bridge

br-inet-grain:
    grains.present:
      - name: br-inet
      - value: True
    require:
      - cmd: br-inet-bridge
