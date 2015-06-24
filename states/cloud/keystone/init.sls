{% if grains['node_type'] == 'controller' %}

include:
    - base: apt.openstack
    - base: openstackdeps
    - base: mysql.ubuntu
    - base: apache2.wsgi
    - base: apache2.ssl
    - base: mysql.keystone
    - base: disable_autostart

memcached:
  pkg:
    - installed
  service:
    - running
    - enable: True

python-memcache:
  pkg.installed

keystone:
  pkg.installed:
    - name: keystone
    - pkg: memcached
  service:
    - enable: False
    - dead

/etc/apache2/ssl/keystone_chain_cert:
  file.managed:
    - source: salt://cloud/keystone/{{pillar['keystone_ssl_chain']}}
    - mode: 440
    - user: keystone
    - group: www-data

/etc/apache2/ssl/{{pillar['keystone_ssl_key']}}:
  file.managed:
    - source: salt://cloud/keystone/{{pillar['keystone_ssl_key']}}
    - mode: 440
    - user: keystone
    - group: www-data

/etc/apache2/ssl/{{pillar['keystone_ssl_crt']}}:
  file.managed:
    - source: salt://cloud/keystone/{{pillar['keystone_ssl_crt']}}
    - mode: 440
    - user: keystone
    - group: www-data

/etc/keystone/keystone-paste.ini:
  file.managed:
    - source: salt://cloud/keystone/keystone-paste.ini.{{pillar['openstack_release']}}
    - mode: 440
    - user: keystone
    - group: www-data
    - name: /etc/keystone/keystone-paste.ini

/var/www/keystone/main:
  file.managed:
    - source: salt://cloud/keystone/main.{{pillar['openstack_release']}}
    - mode: 0755
    - makedirs: True
    - user: root
    - group: root

/var/www/keystone/admin:
  file.managed:
    - source: salt://cloud/keystone/main.{{pillar['openstack_release']}}
    - mode: 0755
    - makedirs: True
    - user: root
    - group: root

/etc/apache2/sites-available/keystone.conf:
  file.managed:
    - source: salt://cloud/keystone/keystone.vhost.conf
    - name: /etc/apache2/sites-available/keystone.conf
    - mode: 440
    - user: keystone
    - group: www-data
    - template: jinja
    - defaults:
      keystone_ssl_crt: {{pillar['keystone_ssl_crt']}}
      keystone_ssl_key: {{pillar['keystone_ssl_key']}}
      keystone_ssl_chain: {{pillar['keystone_ssl_chain']}}

/etc/keystone/keystone.conf:
  file.managed:
    - source: salt://cloud/keystone/keystone.conf.{{pillar['openstack_release']}}
    #- source: salt://cloud/keystone/keystone.conf
    - name: /etc/keystone/keystone.conf
    - mode: 440
    - user: keystone
    - group: www-data
    - template: jinja
    - defaults:
      keystone_sql_user: {{pillar['keystone_sql_user']}}
      keystone_admin_token: {{pillar['keystone_admin_token']}}
      keystone_sql_password: {{pillar['keystone_sql_password']}}
      keystone_sql_db: {{pillar['keystone_sql_db']}}
      sql_master: {{pillar['sql_master']}}
      sql_master_port: {{pillar['sql_master_port']}}
      sql_slave: {{pillar['sql_slave']}}
      sql_slave_port: {{pillar['sql_slave_port']}}
      public_endpoint: {{pillar['auth_uri']}}
      admin_endpoint: {{pillar['keystone_admin_endpoint']}}
      rabbit_durable: {{pillar['rabbit_durable']}}
      rabbit_hosts: {{pillar['rabbit_hosts']}}
      rabbit_host: {{pillar['rabbit_host']}}
      rabbit_port: {{pillar['rabbit_port']}}
      rabbit_userid: {{pillar['keystone_rabbit_user']}}
      rabbit_virtual_host: {{pillar['keystone_rabbit_virtual_host']}}
      rabbit_password: {{pillar['keystone_rabbit_password']}}

enable-keystone-vhost:
  cmd.wait:
    - name: a2ensite keystone.conf && apache2ctl restart
    - watch:
        - file: /etc/keystone/keystone.conf
        - file: /etc/keystone/keystone-paste.ini
        - file: /etc/apache2/sites-available/keystone.conf
        - file: /etc/apache2/ssl/{{pillar['keystone_ssl_key']}}
        - file: /etc/apache2/ssl/{{pillar['keystone_ssl_chain']}}
        - file: /etc/apache2/ssl/{{pillar['keystone_ssl_crt']}}
    - require:
      - service: keystone


cloud-builder:
  cmd.script:
    - source: salt://cloud/keystone/cloud-builder.sh
    - cwd: /var/tmp
    - user: root
    - unless: test -f /var/log/cloud-builder.log
    - require:
      - service: keystone
      - pkg: keystone
      - cmd:  enable-keystone-vhost
      - mysql_database: mysql_keystone_db
      - mysql_user: mysql_keystone_user
      - mysql_grants: keystone_keystonedb
    - template: jinja
    - defaults:
      public_endpoint: {{pillar['auth_uri']}}
      admin_endpoint: {{pillar['keystone_admin_endpoint']}}
      admin_password: {{pillar['keystone_admin_password']}}
      neutron_admin_user: {{pillar['neutron_admin_user']}}
      neutron_admin_password: {{pillar['neutron_admin_password']}}
      neutron_user: {{pillar['neutron_user']}}
      neutron_password: {{pillar['neutron_password']}}
      neutron_url: {{pillar['neutron_url']}}
      nova_neutron_admin_username: {{pillar['nova_neutron_admin_username']}}
      nova_neutron_admin_password: {{pillar['nova_neutron_admin_password']}}
      nova_admin_user: {{pillar['nova_admin_user']}}
      nova_notify_user: {{pillar['nova_notify_user']}}
      glance_admin_user: {{pillar['glance_admin_user']}}
      nova_admin_password: {{pillar['nova_admin_password']}}
      nova_notify_password: {{pillar['nova_notify_password']}}
      glance_admin_password: {{pillar['glance_admin_password']}}
      service_tenant_name: {{pillar['service_tenant_name']}}
      service_tenant_id: {{pillar['service_tenant_id']}}
      keystone_admin_token: {{pillar['keystone_admin_token']}}
      pillar_env: {{pillar['pillar_env']}}
      nova_url: {{pillar['nova_url']}}
      nova_endpoint: {{pillar['nova_url']}}/%(tenant_id)s
      glance_host: {{pillar['glance_host']}}
      keystone_admin_endpoint: {{pillar['keystone_admin_endpoint']}}
      auth_uri: {{pillar['auth_uri']}}

{% endif %}
