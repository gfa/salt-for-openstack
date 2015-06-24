include:
  - base: rabbitmq

neutron_rabbit_user:
    rabbitmq_user.present:
        - password: {{pillar['neutron_rabbit_password']}}
        - name: {{pillar['neutron_rabbit_user']}}
        - force: True
    require:
      - pkg: rabbitmq-server
      - service.running: rabbitmq-server

neutron_virtual_host:
    rabbitmq_vhost.present:
        - name: {{pillar['neutron_rabbit_virtual_host']}}
        - owner: {{pillar['neutron_rabbit_user']}}
        - conf: .*
        - write: .*
        - read: .*
    require:
      - service.running: rabbitmq-server
      - rabbitmq_user: {{pillar['neutron_rabbit_user']}}

neutron_rabbit_perms:
    rabbitmq_user.present:
        - password: {{pillar['neutron_rabbit_password']}}
        - name: {{pillar['neutron_rabbit_user']}}
        - force: True
        - tags:
            - user
        - perms:
          - '{{pillar['neutron_rabbit_virtual_host']}}':
            - '.*'
            - '.*'
            - '.*'
    require:
      - service.running: rabbitmq-server
      - rabbitmq_user: {{pillar['neutron_rabbit_user']}}
      - rabbitmq_vhost: {{pillar['neutron_rabbit_virtual_host']}}


