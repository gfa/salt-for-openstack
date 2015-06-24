{% if grains['os'] == 'Debian' %}
  {% set agent = 'neutron-openvswitch-agent' %}
{% elif grains['os'] == 'Ubuntu' %}
  {% set agent = 'neutron-plugin-openvswitch-agent' %}
  {% set agent = 'neutron-plugin-linuxbridge-agent' %}
{% endif %}

dnsmasq:
  pkg:
    - purged

{% if not grains['node_type'] == 'compute' %}
include:
    - base: mysql.neutron
    - base: rabbitmq.neutron
    - base: openstackdeps
    - base: rsyslog
    - base: cloud.neutron.l3


support netnode pkgs:
  pkg.installed:
  - pkgs:
    - iputils-arping
    - socat
    - tcpdump

/etc/neutron/dhcp_agent.ini:
  file.managed:
    - source: salt://cloud/neutron/dhcp_agent.ini.{{pillar['openstack_release']}}
    - mode: 640
    - user: root
    - group: neutron
    - makedirs: True
    - name: /etc/neutron/dhcp_agent.ini
    - template: jinja
    - defaults:
      dhcp_domain: {{pillar['dhcp_domain']}}
      dnsmasq_dns_server: {{pillar['dnsmasq_dns_server']}}

/etc/neutron/dnsmasq-neutron.conf:
  file.managed:
    - source: salt://cloud/neutron/dnsmasq-neutron.conf
    - mode: 640
    - user: root
    - group: neutron
    - makedirs: True
    - name: /etc/neutron/dnsmasq-neutron.conf
    - watch_in:
      - service: rsyslog
    - require:
      - pkg: neutron-common

/etc/rsyslog.d/dnsmasq-neutron.conf:
  file.managed:
    - source: salt://cloud/neutron/dnsmasq-rsyslog.conf
    - mode: 640
    - user: root
    - group: root
    - name: /etc/rsyslog.d/dnsmasq-neutron.conf
    - watch_in:
      - service: rsyslog

neutron.policy.json:
  file.managed:
    - source: salt://cloud/neutron/neutron.policy.json.{{pillar['openstack_release']}}
    - mode: 640
    - user: root
    - makedirs: True
    - group: neutron
    - name: /etc/neutron/policy.json


/usr/local/bin/netns:
  file.managed:
    - source: salt://cloud/neutron/netns
    - mode: 755
    - user: root
    - group: root


/root/.bashrc:
  file.append:
    - text: |
        PS1='${NETNS:+($NETNS)}${debian_chroot:+($debian_chroot)}\h:\w\$ '

neutron-server:
  pkg.installed:
    - name: neutron-server
  service.running:
      - name: neutron-server
      - restart: True
      - watch:
        - pkg: neutron-server
        - file: /etc/neutron/neutron.conf
        - file: /etc/neutron/policy.json
        - file: /etc/neutron/api-paste.ini
      - require:
        - pkg: neutron-common

neutron-dhcp-agent:
  pkg.installed:
    - name: neutron-dhcp-agent
    - require:
      - pkg: neutron-common
  service.running:
      - name: neutron-dhcp-agent
      - restart: True
      - watch:
        - pkg: neutron-dhcp-agent
        - file: /etc/neutron/neutron.conf
        - file: /etc/neutron/dhcp_agent.ini
        - file: /etc/neutron/api-paste.ini
        - file: /etc/neutron/dnsmasq-neutron.conf
        - pkg: dnsmasq
      - require:
        - pkg: neutron-dhcp-agent
        - file: /etc/neutron/dhcp_agent.ini

update-db-neutron:
  cmd.run:
    - name: neutron-db-manage --config-file /etc/neutron/neutron.conf upgrade {{pillar['openstack_release']}} && touch /etc/neutron/.firstrun
    - unless: test -f /etc/neutron/.firstrun
    - require:
      - mysql_database: mysql_neutron_db
      - pkg: neutron-common
      - file: /etc/neutron/neutron.conf

network-builder.sh:
  file.managed:
    - source: salt://cloud/neutron/network-builder.sh
    - name: /root/network-builder.sh
    - mode: 640
    - user: root
    - group: root

{# no DVR
#{% else %}

# if not does not work :@
#{% if salt['pillar.get']('openstack_release', 'juno') %}
#  {% if grains['pillar.get']('openstack_release' == 'juno' %}
#include:
#    - base: cloud.neutron.l3
#  {% endif %}
#}
{% endif %}

neutron-common:
  pkg:
    - installed

{{ agent }}:
  pkg.installed:
    - name: {{ agent }}
    - require:
      - pkg: neutron-common
  service.running:
      - name: {{ agent }}
      - restart: True
      - watch:
        - pkg: {{ agent }}
        - file: /etc/neutron/neutron.conf
        - file: /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini
        - file: /etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini
        - file: /etc/init/{{ agent }}.conf
        - file: /etc/neutron/api-paste.ini

stupid ubuntu:
  file.symlink:
    - name: /usr/bin/neutron-plugin-linuxbridge-agent
    - target: /usr/bin/neutron-linuxbridge-agent

/etc/neutron/api-paste.ini:
  file.managed:
    - source: salt://cloud/neutron/api-paste.ini.{{pillar['openstack_release']}}
    - mode: 640
    - user: root
    - group: neutron
    - name: /etc/neutron/api-paste.ini
    - template: jinja
    - defaults:
      auth_host: {{pillar['auth_host']}}
      auth_uri: {{pillar['auth_uri']}}
      admin_user: {{pillar['neutron_admin_user']}}
      admin_password: {{pillar['neutron_admin_password']}}
      admin_tenant_name: {{pillar['service_tenant_name']}}

/etc/init/{{ agent }}.conf:
  file.managed:
    - source: salt://cloud/neutron/{{ agent }}.conf.init
    - mode: 640
    - user: root
    - group: root

neutron.conf:
  file.managed:
    - source: salt://cloud/neutron/neutron.conf.{{pillar['openstack_release']}}
    - mode: 640
    - user: root
    - group: neutron
    - name: /etc/neutron/neutron.conf
    - template: jinja
    - defaults:
      my_ip: {{ salt['network.interfaces']()['eth0']['inet'][0]['address'] }}
      neutron_url: {{pillar['neutron_url']}}
      neutron_metadata_proxy_shared_secret: {{pillar['neutron_metadata_proxy_shared_secret']}}
      rabbit_hosts: {{pillar['rabbit_hosts']}}
      rabbit_durable: {{pillar['rabbit_durable']}}
      rabbit_host: {{pillar['rabbit_host']}}
      rabbit_port: {{pillar['rabbit_port']}}
      rabbit_userid: {{pillar['neutron_rabbit_user']}}
      rabbit_virtual_host: {{pillar['neutron_rabbit_virtual_host']}}
      rabbit_password: {{pillar['neutron_rabbit_password']}}
      dhcp_lease_duration: {{pillar['dhcp_lease_duration']}}
      core_plugin: {{pillar['neutron_core_plugin']}}
      service_plugins: {{pillar['neutron_service_plugins']}}
      hostname: {{ salt['grains.get']('fqdn') }}
      dhcp_agents_per_network: {{pillar['dhcp_agents_per_network']}}
      auth_host: {{pillar['auth_host']}}
      auth_protocol: {{pillar['auth_protocol']}}
      auth_port: {{pillar['auth_port']}}
      admin_tenant_name: {{pillar['service_tenant_name']}}
      neutron_admin_user: {{pillar['neutron_user']}}
      neutron_admin_password: {{pillar['neutron_password']}}
      neutron_sql_user: {{pillar['neutron_sql_user']}}
      neutron_sql_pass: {{pillar['neutron_sql_pass']}}
      neutron_sql_db: {{pillar['neutron_sql_db']}}
      sql_master: {{pillar['sql_master']}}
      sql_master_port: {{pillar['sql_master_port']}}
      service_provider: {{pillar['neutron_service_provider']}}
      nova_notify: {{pillar['neutron_nova_notify']}}
      nova_url: {{pillar['nova_url']}}
      nova_notify_user: {{pillar['nova_notify_user']}}
      service_tenant_id: {{pillar['service_tenant_id']}}
      nova_notify_password: {{pillar['nova_notify_password']}}
      auth_uri: {{pillar['auth_uri']}}
      router_distributed: {{pillar['router_distributed']}}
      l3_ha: {{pillar['l3_ha']}}
      l3_ha_net_cidr: {{pillar['l3_ha_net_cidr']}}

/etc/neutron/plugins/ml2/ml2_conf.ini:
  file.managed:
    - source: salt://cloud/neutron/ml2_conf.ini.{{pillar['openstack_release']}}
    - mode: 640
    - user: root
    - group: neutron
    - name: /etc/neutron/plugins/ml2/ml2_conf.ini
    - template: jinja
    - makedirs: True
    - defaults:
      firewall_driver: {{pillar['neutron_firewall_driver']}}
      neutron_sql_user: {{pillar['neutron_sql_user']}}
      neutron_sql_pass: {{pillar['neutron_sql_pass']}}
      neutron_sql_db: {{pillar['neutron_sql_db']}}
      sql_master: {{pillar['sql_master']}}
      sql_master_port: {{pillar['sql_master_port']}}
      tenant_network_type: {{pillar['tenant_network_type']}}
      mechanism_drivers: {{pillar['mechanism_drivers']}}
      network_vlan_ranges: {{pillar['network_vlan_ranges']}}
      enable_tunneling: {{pillar['enable_tunneling']}}
      tunnel_type: {{pillar['tunnel_type']}}
      tunnel_id_ranges: {{pillar['tunnel_id_ranges']}}
      local_ip: {{ salt['network.interfaces']()['eth0']['inet'][0]['address'] }}
      bridge_mappings: {{pillar['bridge_mappings']}}
      agent_polling_interval: {{pillar['neutron_agent_polling_interval']}}
      veth_mtu: {{pillar['veth_mtu']}}
      enable_l2_population: {{pillar['enable_l2_population']}}
      type_driver: {{pillar['neutron_type_driver']}}

linuxbridge_conf.ini:
  file.managed:
    - name: /etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini
    - source: salt://cloud/neutron/linuxbridge_conf.ini
    - mode: 640
    - user: root
    - group: neutron
    - makedirs: True
    - template: jinja
    - defaults:
      firewall_driver: {{pillar['neutron_firewall_driver']}}
      neutron_sql_user: {{pillar['neutron_sql_user']}}
      neutron_sql_pass: {{pillar['neutron_sql_pass']}}
      neutron_sql_db: {{pillar['neutron_sql_db']}}
      sql_master: {{pillar['sql_master']}}
      sql_master_port: {{pillar['sql_master_port']}}
      tenant_network_type: {{pillar['tenant_network_type']}}
      network_vlan_ranges: {{pillar['network_vlan_ranges']}}
      enable_tunneling: {{pillar['enable_tunneling']}}
      tunnel_type: {{pillar['tunnel_type']}}
      tunnel_id_ranges: {{pillar['tunnel_id_ranges']}}
      local_ip: {{ salt['network.interfaces']()['eth0']['inet'][0]['address'] }}
      bridge_mappings: {{pillar['bridge_mappings']}}
      agent_polling_interval: {{pillar['neutron_agent_polling_interval']}}
      veth_mtu: {{pillar['veth_mtu']}}
      enable_l2_population: {{pillar['enable_l2_population']}}

ovs_neutron_plugin.ini:
  file.managed:
    - source: salt://cloud/neutron/ovs_neutron_plugin.ini.{{pillar['openstack_release']}}
    - mode: 640
    - user: root
    - group: neutron
    - name: /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini
    - makedirs: True
    - template: jinja
    - defaults:
      firewall_driver: {{pillar['neutron_firewall_driver']}}
      neutron_sql_user: {{pillar['neutron_sql_user']}}
      neutron_sql_pass: {{pillar['neutron_sql_pass']}}
      neutron_sql_db: {{pillar['neutron_sql_db']}}
      sql_master: {{pillar['sql_master']}}
      sql_master_port: {{pillar['sql_master_port']}}
      tenant_network_type: {{pillar['tenant_network_type']}}
      network_vlan_ranges: {{pillar['network_vlan_ranges']}}
      enable_tunneling: {{pillar['enable_tunneling']}}
      tunnel_type: {{pillar['tunnel_type']}}
      tunnel_id_ranges: {{pillar['tunnel_id_ranges']}}
      local_ip: {{ salt['network.interfaces']()['eth0']['inet'][0]['address'] }}
      bridge_mappings: {{pillar['bridge_mappings']}}
      agent_polling_interval: {{pillar['neutron_agent_polling_interval']}}
      veth_mtu: {{pillar['veth_mtu']}}
      enable_l2_population: {{pillar['enable_l2_population']}}
