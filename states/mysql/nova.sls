include:
  - base: mysql

mysql_nova_db:
  mysql_database.present:
    - connection_user: {{pillar['mysql_root_user']}}
    - connection_host: 'localhost'
    - connection_unix_socket: {{pillar['mysql_socket']}}
    - connection_pass: {{pillar['mysql_root_pass']}}
    - connection_charset: utf8
    - name: nova

mysql_nova_user:
  mysql_user.present:
    - name: nova
    - password: {{pillar['nova_sql_pass']}}
    - host: '%'
    - connection_user: {{pillar['mysql_root_user']}}
    - connection_host: 'localhost'
    - connection_unix_socket: {{pillar['mysql_socket']}}
    - connection_pass: {{pillar['mysql_root_pass']}}
    - connection_charset: utf8

nova_novadb:
   mysql_grants.present:
    - grant: all privileges
    - database: nova.*
    - user: nova
    - host: '%'
    - connection_user: {{pillar['mysql_root_user']}}
    - connection_host: 'localhost'
    - connection_unix_socket: {{pillar['mysql_socket']}}
    - connection_pass: {{pillar['mysql_root_pass']}}
    - connection_charset: utf8

