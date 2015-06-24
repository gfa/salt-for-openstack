include:
    - base: apache2

apache-openstack_ssl:
  apache_module.enable:
    - name: ssl

/etc/apache2/ssl:
  file.directory:
    - makedirs: True
    - mode: 755
    - user: root
    - group: root
