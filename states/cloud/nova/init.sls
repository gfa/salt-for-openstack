nova-group:
  group.present:
    - name: nova

nova-user:
  user.present:
    - name: nova
    - shell: /bin/sh
    - home: /var/lib/nova
    - createhome: False
    - optional_groups:
      - libvirtd
      - kvm
      - lxd
    - remove_groups: False
    - system: True
    - groups:
      - nova
    - require:
      - group: nova

# https://github.com/saltstack/salt/issues/9185
{% for pkg in ('python-nova', 'nova-common') %}

{{pkg}}:
  pkg:
{% if salt['pillar.get']('nova_version', False) %}
    - installed
    - version: {{ salt['pillar.get']('nova_version') }}
{% else %}
    - latest
{% endif %}

{% endfor %}

{% if grains['node_type'] == 'controller' %}
include:
  - base: mysql.nova
  - base: rabbitmq.nova

nova-scheduler:
  pkg:
    - name: nova-scheduler
    - require:
      - pkg: nova-common
    {% if salt['pillar.get']('nova_version', False) %}
    - installed
    - version: {{pillar['nova_version']}}
    {% else %}
    - latest
    {% endif %}
  service.running:
      - name: nova-scheduler
      - restart: True
      - watch:
        - pkg: nova-scheduler
        - file: /etc/nova/nova.conf
        - file: /etc/nova/logging.conf
        - file: /etc/nova/api-paste.ini

nova-api:
  pkg:
    - name: nova-api
    - require:
      - pkg: nova-common
    {% if salt['pillar.get']('nova_version', False) %}
    - installed
    - version: {{pillar['nova_version']}}
    {% else %}
    - latest
    {% endif %}
  service.running:
      - name: nova-api
      - restart: True
      - watch:
        - pkg: nova-api
        - file: /etc/nova/nova.conf
        - file: /etc/nova/policy.json
        - file: /etc/nova/logging.conf
        - file: /etc/nova/api-paste.ini

nova-conductor:
  pkg:
    - name: nova-conductor
    - require:
      - pkg: nova-common
    {% if salt['pillar.get']('nova_version', False) %}
    - installed
    - version: {{pillar['nova_version']}}
    {% else %}
    - latest
    {% endif %}
  service.running:
      - name: nova-conductor
      - restart: True
      - watch:
        - pkg: nova-conductor
        - file: /etc/nova/nova.conf
        - file: /etc/nova/logging.conf
        - file: /etc/nova/api-paste.ini

python-novaclient:
  pkg.installed

update-db-nova:
  cmd.run:
    - name: nova-manage db sync && touch /etc/nova/.firstrun
    - unless: test -f /etc/nova/.firstrun
    - require:
      - mysql_database: mysql_nova_db
      - pkg: nova-common
      - file: /etc/nova/nova.conf
{% endif %}

nova.conf:
  file.managed:
    - source: salt://cloud/nova/nova.conf.{{pillar['openstack_release']}}
    - mode: 640
    - require:
      - pkg: nova-common
    - user: root
    - group: nova
    - name: /etc/nova/nova.conf
    - template: jinja
    - defaults:
      my_ip: {{ salt['network.interfaces']()['eth0']['inet'][0]['address'] }}
      nova_url: {{pillar['nova_url']}}
      neutron_metadata_proxy_shared_secret: {{pillar['neutron_metadata_proxy_shared_secret']}}
      rabbit_hosts: {{pillar['rabbit_hosts']}}
      rabbit_durable: {{pillar['rabbit_durable']}}
      rabbit_userid: {{pillar['nova_rabbit_user']}}
      rabbit_virtual_host: {{pillar['nova_rabbit_virtual_host']}}
      rabbit_password: {{pillar['nova_rabbit_password']}}
      neutron_admin_username: {{pillar['nova_neutron_admin_username']}}
      neutron_admin_password: {{pillar['nova_neutron_admin_password']}}
      neutron_region_name: {{pillar['auth_region']}}
      neutron_url: {{pillar['neutron_url']}}
      auth_region: {{pillar['auth_region']}}
      novncproxy_base_url: {{pillar['novncproxy_base_url']}}
      vncserver_proxyclient_address: {{pillar['vncserver_proxyclient_address']}}
      auth_host: {{pillar['auth_host']}}
      admin_tenant_name: {{pillar['service_tenant_name']}}
      auth_protocol: {{pillar['auth_protocol']}}
      dhcp_domain: {{pillar['dhcp_domain']}}
      auth_uri: {{pillar['auth_uri']}}
      hostname: {{ salt['grains.get']('fqdn') }}
      glance_host: {{pillar['glance_host']}}
      glance_api_servers: {{pillar['glance_api_servers']}}
      auth_port: {{pillar['auth_port']}}
      admin_user: {{pillar['nova_admin_user']}}
      admin_password: {{pillar['nova_admin_password']}}
      vif_plugging_is_fatal: {{pillar['nova_vif_plugging_is_fatal']}}
      vif_plugging_timeout: {{pillar['nova_vif_plugging_timeout']}}
{% if grains['mem_total'] >= 48000 %}
      reserved_host_memory_mb: 8192
      {% else %}
      reserved_host_memory_mb: 1024
{% endif %}
      vcpu_pin_set: 2-{{ salt['grains.get']('num_cpus') - 1}}
{% if grains['node_type'] == 'controller' %}
      conductor: True
      nova_sql_user: {{pillar['nova_sql_user']}}
      nova_sql_pass: {{pillar['nova_sql_pass']}}
      nova_sql_db: {{pillar['nova_sql_db']}}
      sql_master: {{pillar['sql_master']}}
      sql_slave: {{pillar['sql_slave']}}
      sql_master_port: {{pillar['sql_master_port']}}
      sql_slave_port: {{pillar['sql_slave_port']}}
{% elif grains['node_type'] == 'compute' %}
      conductor: False
      nova_sql_user: FAKE
      nova_sql_pass: FAKE
      nova_sql_db: FAKE
      sql_master: 127.0.0.1
      sql_slave: 127.0.0.1
      sql_master_port: 1234
      sql_slave_port: 1234
{% endif %}

nova.policy.json:
  file.managed:
    - source: salt://cloud/nova/nova.policy.json.{{pillar['openstack_release']}}
    - mode: 640
    - user: root
    - group: nova
    - name: /etc/nova/policy.json
    - require:
      - pkg: nova-common

nova.logging.conf:
  file.managed:
    - source: salt://cloud/nova/logging.conf.{{pillar['openstack_release']}}
    - mode: 640
    - user: root
    - group: nova
    - name: /etc/nova/logging.conf
    - require:
      - pkg: nova-common

/etc/nova/api-paste.ini:
  file.managed:
    - source: salt://cloud/nova/api-paste.ini.{{pillar['openstack_release']}}
    - mode: 640
    - require:
      - pkg: nova-common
    - user: root
    - group: nova
    - name: /etc/nova/api-paste.ini
    - template: jinja
    - defaults:
      auth_host: {{pillar['auth_host']}}
      auth_port: {{pillar['auth_port']}}
      auth_protocol: {{pillar['auth_protocol']}}
      admin_user: {{pillar['nova_admin_user']}}
      auth_uri: {{pillar['auth_uri']}}
      admin_password: {{pillar['nova_admin_password']}}
      admin_tenant_name: {{pillar['service_tenant_name']}}

{% if grains['node_type'] == 'compute' %}

  {% if grains['virtual'] == 'physical' %}
  {% set compute_module = 'nova-compute-qemu' %}

include:
  - base: openstackdeps
  - base: libvirt

  {% elif grains['virtual'] == 'kvm' %}

    {% if grains['os'] == 'Debian' %}
      {% set compute_module = 'nova-compute-lxc' %}
include:
  - base: openstackdeps
  - base: dbus


    {% elif grains['os'] == 'Ubuntu' %}
      {% set compute_module = 'nova-compute-lxd' %}
include:
  - base: openstackdeps
  - base: lxd

    {% endif %}

  {% endif %}


{{ compute_module }}:
  pkg:
{% if salt['pillar.get']('nova_version', False) %}
    - installed
    - version: {{ salt['pillar.get']('nova_version') }}
{% else %}
    - latest
{% endif %}


nova-computesrv:
  service.running:
      - name: nova-compute
      - restart: True
      - watch:
        - pkg: {{compute_module }}
        - file: /etc/nova/nova.conf
        - file: /etc/nova/logging.conf
        - file: /etc/nova/api-paste.ini
      - require:
        - file: /var/lib/nova
        - pkg: nova-common

/data/var/lib/nova:
  file.directory:
    - makedirs: True
    - recurse:
      - user
      - group
    - user: nova
    - group: nova
    - mode: '0755'
    - require_in:
      - pkg: nova-common

/var/lib/nova:
  file.symlink:
    - target: /data/var/lib/nova
    - require_in:
      - pkg: nova-common

/var/lib/nova/.ssh/id_rsa.pub:
  file.managed:
    - makedirs: True
    - source: salt://cloud/nova/nova-compute.id_rsa.pub
    - user: nova
    - group: nova
    - mode: '0640'
    - require:
      - file: /var/lib/nova

/var/lib/nova/.ssh/id_rsa:
  file.managed:
    - makedirs: True
    - source: salt://cloud/nova/nova-compute.id_rsa
    - user: nova
    - group: nova
    - mode: '0600'
    - require:
      - file: /var/lib/nova

/var/lib/nova/.ssh/authorized_keys:
  file.managed:
    - makedirs: True
    - source: salt://cloud/nova/nova-compute.authorized_keys
    - user: nova
    - group: nova
    - mode: '0600'
    - require:
      - file: /var/lib/nova


/home/nova/.ssh:
  file.symlink:
    - makedirs: True
    - target: /var/lib/nova/.ssh
    - require:
      - file: /var/lib/nova

libvirtd-group:
  group.present:
    - name: libvirtd
    - addusers:
      - nova

kvm-group:
  group.present:
    - name: kvm
    - addusers:
      - nova

lxd-group:
  group.present:
    - name: lxd
    - addusers:
      - nova

{% endif %}
