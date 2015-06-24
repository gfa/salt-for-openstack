include:
  - base: mysql

mysql_neutron_db:
  mysql_database.present:
    - connection_user: {{pillar['mysql_root_user']}}
    - connection_host: 'localhost'
    - connection_unix_socket: {{pillar['mysql_socket']}}
    - connection_pass: {{pillar['mysql_root_pass']}} 
    - connection_charset: utf8
    - name: neutron

mysql_neutron_user:
  mysql_user.present:
    - name: neutron
    - password: {{pillar['neutron_sql_pass']}}
    - host: '%'
    - connection_user: {{pillar['mysql_root_user']}}
    - connection_host: 'localhost'
    - connection_unix_socket: {{pillar['mysql_socket']}}
    - connection_pass: {{pillar['mysql_root_pass']}} 
    - connection_charset: utf8

neutron_neutrondb:
   mysql_grants.present:
    - grant: all privileges
    - database: neutron.*
    - user: neutron
    - host: '%'
    - connection_user: {{pillar['mysql_root_user']}}
    - connection_host: 'localhost'
    - connection_unix_socket: {{pillar['mysql_socket']}}
    - connection_pass: {{pillar['mysql_root_pass']}} 
    - connection_charset: utf8

