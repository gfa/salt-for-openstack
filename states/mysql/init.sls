mysql-backup:
  pkg:
    - installed
    - name: libio-captureoutput-perl
    - name: libbenchmark-timer-perl
    - name: python-mysqldb

/data2/backup/db_bak:
  file.directory:
    - makedirs: True
    - require_in:
      - file: /etc/cron.daily/mysql_tool.pl

/etc/cron.daily/mysql_tool.pl:
  file.managed:
    - source: salt://mysql/mysql_tool.pl
    - user: root
    - group: root
    - mode: 750

