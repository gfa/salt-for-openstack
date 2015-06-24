neutron-metadata-agent:
  pkg.installed:
    - name: neutron-metadata-agent
    - require:
      - pkg: neutron-common
  service.running:
      - name: neutron-metadata-agent
      - restart: True
      - watch:
        - pkg: neutron-metadata-agent
        - file: /etc/neutron/neutron.conf
        - file: /etc/neutron/metadata_agent.ini
        - file: /etc/neutron/api-paste.ini

/etc/neutron/metadata_agent.ini:
  file.managed:
    - source: salt://cloud/neutron/metadata_agent.ini.{{pillar['openstack_release']}}
    - mode: 640
    - user: root
    - makedirs: True
    - group: neutron
    - name: /etc/neutron/metadata_agent.ini
    - template: jinja
    - defaults:
      auth_url: {{pillar['auth_uri']}}
      auth_region: {{pillar['pillar_env']}}
      admin_user: {{pillar['neutron_admin_user']}}
      admin_password: {{pillar['neutron_admin_password']}}
      admin_tenant_name: {{pillar['service_tenant_name']}}
      nova_metadata_ip: {{pillar['nova_metadata_ip']}}
      metadata_proxy_shared_secret: {{pillar['neutron_metadata_proxy_shared_secret']}}

/etc/neutron/l3_agent.ini:
  file.managed:
    - source: salt://cloud/neutron/l3_agent.ini.{{pillar['openstack_release']}}
    - mode: 640
    - user: root
    - group: neutron
    - makedirs: True
    - name: /etc/neutron/l3_agent.ini

neutron-l3-agent:
  pkg.installed:
    - name: neutron-l3-agent
    - require:
      - pkg: neutron-common
  service.running:
      - name: neutron-l3-agent
      - restart: True
      - watch:
        - file: /etc/neutron/l3_agent.ini
        - pkg: neutron-l3-agent
