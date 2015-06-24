include:
  - base: apt

under::apt-update:
  cmd.run:
    - name: |
        apt-get update
        apt-get clean

openstack deps:
  pkg.latest:
    - pkgs:
      - python-requests
      - python-six
      - msgpack-python
      - python-boto
      - python-crypto
      - python-paramiko
      - python-simplejson
      - python-mysqldb
      - python-pylibmc
      - curl
