include:
  - base: mysql

mysql_glance_db:
  mysql_database.present:
    - connection_user: {{pillar['mysql_root_user']}}
    - connection_host: 'localhost'
    - connection_unix_socket: {{pillar['mysql_socket']}}
    - connection_pass: {{pillar['mysql_root_pass']}}
    - connection_charset: utf8
    - name: glance

mysql_glance_user:
  mysql_user.present:
    - name: glance
    - password: {{pillar['glance_sql_password']}}
    - host: '%'
    - connection_user: {{pillar['mysql_root_user']}}
    - connection_host: 'localhost'
    - connection_unix_socket: {{pillar['mysql_socket']}}
    - connection_pass: {{pillar['mysql_root_pass']}}
    - connection_charset: utf8

glance_glancedb:
   mysql_grants.present:
    - grant: all privileges
    - database: glance.*
    - user: glance
    - host: '%'
    - connection_user: {{pillar['mysql_root_user']}}
    - connection_host: 'localhost'
    - connection_unix_socket: {{pillar['mysql_socket']}}
    - connection_pass: {{pillar['mysql_root_pass']}}
    - connection_charset: utf8

#update-db-glance:
  #  cmd.watch:
    #  - name: glance-manage db_sync
    #- watch:
      #  - mysql_database: mysql_glance_db
      #  - pkg: glance-api
