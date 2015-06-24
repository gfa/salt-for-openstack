apache2:
  pkg.installed:
      - name: apache2
  service.running:
      - name: apache2
      - watch:
        - file: /etc/apache2/ports.conf
        #        - file: /etc/apache2/apache2.conf

/etc/apache2/ports.conf:
  file.managed:
    - source: salt://apache2/ports.conf

#/etc/apache2/apache2.conf:
  #  file.managed:
    #  - source: salt://apache2/apache2.conf

# touch if does not exists
#/etc/apache2/httpd.conf:
  #  file.touch

#/etc/apache2/conf.d/empty.conf:
  #  file.touch:
    #  - makedirs: True

# reload will happend on each service that adds a vhost
#/etc/apache2/sites-enabled:
  #  file.recurse

