/etc/apt/sources.list.d/lxd.list:
  file.managed:
    - source: salt://apt/lxd.list
    - template: jinja
    - defaults:
      distrib: {{ salt['grains.get']('lsb_distrib_codename') }}

/etc/apt/trusted.gpg.d/lxc.gpg:
  file.managed:
    - source: salt://apt/lxd.gpg

apt-get update:
  cmd.run

lxc:
  pkg.latest:
    - service: enable
    - service: running

lxd:
  pkg.latest:
    - service: enable
    - service: running

/etc/subuid:
  file.managed:
    - source: salt://lxd/subuid

/etc/subgid:
  file.managed:
    - source: salt://lxd/subgid
