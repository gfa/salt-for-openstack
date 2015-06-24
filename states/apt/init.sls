{% if grains['os'] == 'Debian' %}
  {% set os = 'debian' %}
  {% set repos = 'main' %}
{% elif grains['os'] == 'Ubuntu' %}
  {% set os = 'ubuntu' %}
  {% set repos = 'main universe ' %}
{% endif %}

apt-repo:
  file.managed:
    - source: salt://apt/sources.list
    - mode: 644
    - user: root
    - group: root
    - name: /etc/apt/sources.list
    - template: jinja
    - defaults:
      distrib: {{ salt['grains.get']('lsb_distrib_codename') }}
      id: {{ os }}
      repos: {{ repos }}

/etc/apt/apt.conf.d/000apt-cacher-ng-proxy:
  file.managed:
    - source: salt://apt/000apt-cacher-ng-proxy
    - template: jinja

apt-clean:
  file.managed:
    - source: salt://apt/20cache
    - mode: 644
    - user: root
    - group: root
    - name: /etc/apt/apt.conf.d/20cache

apt-pdiff:
  file.managed:
    - source: salt://apt/10pdiff
    - mode: 644
    - user: root
    - group: root
    - name: /etc/apt/apt.conf.d/10pdiff

apt-preferences:
  file.managed:
    - source: salt://apt/preferences
    - mode: 644
    - user: root
    - group: root
    - name: /etc/apt/preferences


apt-update:
  cmd.run:
    - name: |
        apt-get update
        apt-get clean
