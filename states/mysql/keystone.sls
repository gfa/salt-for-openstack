include:
  - base: mysql

mysql_keystone_db:
  mysql_database.present:
    - connection_user: {{pillar['mysql_root_user']}}
    - connection_host: 'localhost'
    - connection_unix_socket: {{pillar['mysql_socket']}}
    - connection_pass: {{pillar['mysql_root_pass']}}
    - connection_charset: utf8
    - name: keystone

mysql_keystone_user:
  mysql_user.present:
    - name: keystone
    - password: {{pillar['keystone_sql_password']}}
    - host: '%'
    - connection_user: {{pillar['mysql_root_user']}}
    - connection_host: 'localhost'
    - connection_unix_socket: {{pillar['mysql_socket']}}
    - connection_pass: {{pillar['mysql_root_pass']}}
    - connection_charset: utf8

keystone_keystonedb:
   mysql_grants.present:
    - grant: all privileges
    - database: keystone.*
    - user: keystone
    - host: '%'
    - connection_user: {{pillar['mysql_root_user']}}
    - connection_host: 'localhost'
    - connection_unix_socket: {{pillar['mysql_socket']}}
    - connection_pass: {{pillar['mysql_root_pass']}}
    - connection_charset: utf8

# moved to cloud-builder.sh script
#update-db-keystone:
  #  cmd.watch:
    #  - name: keystone-manage db_sync
    #- watch:
      # - mysql_database: mysql_keystone_db
      #- pkg: keystone
