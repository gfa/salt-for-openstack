include:
    - base: apache2

libapache2-mod-wsgi:
  pkg.installed:
    - name: libapache2-mod-wsgi

apache2-mpm-worker:
  pkg.installed:
    - name: apache2-mpm-worker

apache-openstack_wsgi:
    apache_module.enable:
      - name: wsgi
      - require:
        - pkg: libapache2-mod-wsgi
        - pkg: apache2-mpm-worker
