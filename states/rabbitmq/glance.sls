include:
  - base: rabbitmq

glance_rabbit_user:
    rabbitmq_user.present:
        - password: {{pillar['glance_rabbit_pass']}}
        - name: {{pillar['glance_rabbit_user']}}
        - force: True
        - tags:
            - user
        - perms:
          - '/':
            - '.*'
            - '.*'
            - '.*'
        - runas: rabbitmq

glance_virtual_host:
    rabbitmq_vhost.present:
        - name: {{pillar['glance_virtual_host']}}
        - user: {{pillar['glance_rabbit_user']}}
        - conf: .*
        - write: .*
        - read: .*
