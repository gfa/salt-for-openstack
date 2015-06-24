{% if grains['os'] == 'Debian' %}
  {% set os = 'debian' %}
{% elif grains['os'] == 'Ubuntu' %}
  {% set os = 'ubuntu' %}
{% endif %}

include:
  - at

/etc/salt/minion:
  file:
    - managed
    - source: salt://salt/minion
    - makedirs: True

/etc/apt/trusted.gpg.d/salt.gpg:
  file.managed:
    - source: salt://salt/debian-salt-team-joehealy.gpg.key
    - user: root
    - group: root
    - mode: 644

/etc/apt/trusted.gpg.d/saltppa.gpg:
  file.managed:
    - source: salt://salt/saltppa.gpg
    - user: root
    - group: root
    - mode: 644

/etc/apt/sources.list.d/salt.list:
  file.managed:
    - source: salt://salt/salt.list.{{ os }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
      distrib: {{ salt['grains.get']('lsb_distrib_codename') }}

salt-minion:
  pkg:
    - installed
    - name: salt-minion
    #    - allow_updates: True
    - refresh: True
  service:
    - running
    - enable: True
    - require:
      - pkg: salt-minion
    - watch:
      - file: /etc/salt/minion

python-augeas:
  pkg.latest

salt-minion-reload:
  cmd.wait:
    - name: echo service salt-minion restart | at now + 35 minutes
    - order: last
    - watch:
      - file: /etc/salt/minion
      - pkg: salt-minion

