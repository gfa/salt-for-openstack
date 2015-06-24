include:
  - base: rabbitmq

nova_rabbit_user:
    rabbitmq_user.present:
        - password: {{pillar['nova_rabbit_password']}}
        - name: {{pillar['nova_rabbit_user']}}
        - force: True
    require:
      - pkg: rabbitmq-server
      - service.running: rabbitmq-server

nova_virtual_host:
    rabbitmq_vhost.present:
        - name: {{pillar['nova_rabbit_virtual_host']}}
        - owner: {{pillar['nova_rabbit_user']}}
        - conf: .*
        - write: .*
        - read: .*
    require:
      - service.running: rabbitmq-server
      - rabbitmq_user: {{pillar['nova_rabbit_user']}}

nova_rabbit_perms:
    rabbitmq_user.present:
        - password: {{pillar['nova_rabbit_password']}}
        - name: {{pillar['nova_rabbit_user']}}
        - force: True
        - tags:
            - user
        - perms:
          - '{{pillar['nova_rabbit_virtual_host']}}':
            - '.*'
            - '.*'
            - '.*'
    require:
      - service.running: rabbitmq-server
      - rabbitmq_user: {{pillar['nova_rabbit_user']}}
      - rabbitmq_vhost: {{pillar['nova_rabbit_virtual_host']}}
