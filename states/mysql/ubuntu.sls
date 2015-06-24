mysql-server:
  pkg.installed:
    - name: mysql-server

mysql:
  service.running:
    - name: mysql
    - enable: True
    - restart: True
    - watch:
      - file: /etc/mysql/my.cnf
    - require:
      - pkg: mysql-server

/etc/mysql/my.cnf:
  file.managed:
    - source: salt://mysql/my.cnf.ubuntu
    #    - replace: False
    - template: jinja
    - defaults:
      hostname: {{ salt['grains.get']('fqdn') }}

root@%:
  mysql_user.present:
    - name: 'root'
    - host: '%'
    - password: {{ pillar['mysql_root_pass'] }}
    - connection_user: root
    - connection_pass:
    - connection_charset: utf8

root@%grant:
  mysql_grants.present:
    - user: 'root'
    - host: '%'
    - grant: all privileges
    - grant_option: True
    - revoke_first: True
    - database: '*.*'
    - connection_user: root
    - connection_pass:
    - connection_charset: utf8
