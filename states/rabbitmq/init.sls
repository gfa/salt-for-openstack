rabbitmq-server:
  pkg:
    - installed
  service.running:
    - enable: True
    - name: rabbitmq-server
    - restart: True
    - watch:
      - file: /etc/rabbitmq/rabbitmq-env.conf
      - file: /etc/rabbitmq/rabbitmq.config

/etc/rabbitmq/rabbitmq-env.conf:
  file.managed:
    - source: salt://rabbitmq/rabbitmq-env.conf
    - template: jinja
    - defaults:
      hostname: {{ salt['grains.get']('fqdn') }}

/etc/rabbitmq/rabbitmq.config:
  file.managed:
    - source: salt://rabbitmq/rabbitmq.config

