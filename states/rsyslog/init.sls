{% set files = ['cron.log','daemon.log','syslog','kern.log','auth.log','rsyslog.log','mail.log','user.log']  %}

{% for file in files %}
/var/log/{{file}}:
  file.managed:
    - user: {{pillar['syslog_user']}}
    - group: adm
    - create: True
    - replace: False
    - mode: 644

{% endfor %}

rsyslog:
  pkg.installed:
    - name: rsyslog
    - name: logrotate
  service.running:
      - name: rsyslog
      - restart: True
      - watch:
        - file: /etc/rsyslog.conf
        - file: /etc/rsyslog.d/50-default.conf

/etc/rsyslog.conf:
  file.managed:
    - source: salt://rsyslog/rsyslog.conf
    - template: jinja
      defaults:
      syslog_user: {{pillar['syslog_user']}}

/etc/rsyslog.d/50-default.conf:
  file.managed:
    - source: salt://rsyslog/50-default.conf

/etc/logrotate.d/syslog-ng.disabled:
  file.absent

