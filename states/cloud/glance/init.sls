{% if grains['node_type'] == 'controller' %}

include:
    - base: apt
    - base: openstackdeps
    - base: mysql.ubuntu
    - base: mysql.glance

glance-user:
  user.present:
    - name: glance
    - shell: /bin/sh
    - home: /var/lib/glance
    - createhome: False
    - remove_groups: False
    - system: True
    - gid_from_name: True

/data/var/lib/glance:
  file.directory:
    - makedirs: True
    - user: glance
    - group: glance
    - mode: '0755'

/var/lib/glance:
  file.symlink:
    - target: /data/var/lib/glance

glance-common:
  pkg.installed:
    - name: glance-common
  require:
    - file: /var/lib/glance
    - file: /data/var/lib/glance
    - user: glance

glance-api:
  pkg.installed:
    - name: glance-api
  require:
    - pkg: glance-common
  service.running:
      - name: glance-api
      - restart: True
      - watch:
        - pkg: glance-api
        - file: /etc/glance/glance-api.conf
        - file: /etc/glance/glance-api-paste.ini
        - file: /etc/glance/policy.json

glance-registry:
  pkg.installed:
    - name: glance-registry
  require:
    - pkg: glance-common
  service.running:
      - name: glance-registry
      - restart: True
      - watch:
        - pkg: glance-registry
        - file: /etc/glance/glance-registry.conf
        - file: /etc/glance/glance-registry-paste.ini
        - file: /etc/glance/policy.json

/etc/glance/glance-api.conf:
  file.managed:
    - source: salt://cloud/glance/glance-api.conf.{{pillar['openstack_release']}}
    - name: /etc/glance/glance-api.conf
    - mode: 440
    - user: root
    - group: glance
    - template: jinja
    - defaults:
      glance_sql_user: {{pillar['glance_sql_user']}}
      glance_sql_password: {{pillar['glance_sql_password']}}
      glance_sql_db: {{pillar['glance_sql_db']}}
      sql_master: {{pillar['sql_master']}}
      sql_master_port: {{pillar['sql_master_port']}}
      registry_client_protocol: {{pillar['registry_client_protocol']}}
      rabbit_host: {{pillar['rabbit_host']}}
      rabbit_durable: {{pillar['rabbit_durable']}}
      rabbit_port: {{pillar['rabbit_port']}}
      rabbit_userid: {{pillar['glance_rabbit_user']}}
      rabbit_password: {{pillar['glance_rabbit_password']}}
      rabbit_virtual_host: {{pillar['glance_rabbit_virtual_host']}}
      auth_host: {{pillar['auth_host']}}
      auth_port: {{pillar['auth_port']}}
      auth_protocol: {{pillar['auth_protocol']}}
      glance_admin_user: {{pillar['glance_admin_user']}}
      glance_admin_password: {{pillar['glance_admin_password']}}
      admin_tenant_name: {{pillar['service_tenant_name']}}
      auth_uri: {{pillar['auth_uri']}}

/etc/glance/glance-api-paste.ini:
  file.managed:
    - source: salt://cloud/glance/glance-api-paste.ini.{{pillar['openstack_release']}}
    - name: /etc/glance/glance-api-paste.ini
    - mode: 440
    - user: root
    - group: glance
    - template: jinja
    - defaults:
      auth_host: {{pillar['auth_host']}}
      auth_port: {{pillar['auth_port']}}
      auth_protocol: {{pillar['auth_protocol']}}
      glance_admin_user: {{pillar['glance_admin_user']}}
      glance_admin_password: {{pillar['glance_admin_user']}}
      admin_tenant_name: {{pillar['service_tenant_name']}}

/etc/glance/glance-registry.conf:
  file.managed:
    - source: salt://cloud/glance/glance-registry.conf.{{pillar['openstack_release']}}
    - name: /etc/glance/glance-registry.conf
    - mode: 440
    - user: root
    - group: glance
    - template: jinja
    - defaults:
      glance_sql_user: {{pillar['glance_sql_user']}}
      glance_sql_password: {{pillar['glance_sql_password']}}
      glance_sql_db: {{pillar['glance_sql_db']}}
      auth_uri: {{pillar['auth_uri']}}
      sql_master: {{pillar['sql_master']}}
      sql_master_port: {{pillar['sql_master_port']}}
      auth_host: {{pillar['auth_host']}}
      auth_port: {{pillar['auth_port']}}
      auth_protocol: {{pillar['auth_protocol']}}
      glance_admin_user: {{pillar['glance_admin_user']}}
      glance_admin_password: {{pillar['glance_admin_user']}}
      admin_tenant_name: {{pillar['service_tenant_name']}}
      rabbit_host: {{pillar['rabbit_host']}}
      rabbit_durable: {{pillar['rabbit_durable']}}
      rabbit_port: {{pillar['rabbit_port']}}
      rabbit_userid: {{pillar['glance_rabbit_user']}}
      rabbit_password: {{pillar['glance_rabbit_password']}}
      rabbit_virtual_host: {{pillar['glance_rabbit_virtual_host']}}

/etc/glance/glance-registry-paste.ini:
  file.managed:
    - source: salt://cloud/glance/glance-registry-paste.ini.{{pillar['openstack_release']}}
    - name: /etc/glance/glance-registry-paste.ini
    - mode: 440
    - user: root
    - group: glance
    - template: jinja
    - defaults:
      auth_host: {{pillar['auth_host']}}
      auth_port: {{pillar['auth_port']}}
      auth_protocol: {{pillar['auth_protocol']}}
      glance_admin_user: {{pillar['glance_admin_user']}}
      glance_admin_password: {{pillar['glance_admin_user']}}
      admin_tenant_name: {{pillar['service_tenant_name']}}

/etc/glance/policy.json:
  file.managed:
    - source: salt://cloud/glance/glance.policy.json.{{pillar['openstack_release']}}
    - mode: 440
    - user: root
    - group: glance

update-db-glance:
    cmd.run:
    - name: glance-manage db_sync && touch /etc/glance/.cloud-builder
    - user: root
    - unless: test -f /etc/glance/.cloud-builder
    - require:
      - service: glance-api
      - service: glance-registry
      - file: /etc/glance/glance-api.conf
      - file: /etc/glance/glance-api-paste.ini
      - file: /etc/glance/policy.json

{% endif %}
