{% if grains['os'] == 'Debian' %}
  {% set os = 'debian' %}
  {% set repos = 'main' %}
{% elif grains['os'] == 'Ubuntu' %}
  {% set os = 'ubuntu' %}
  {% set repos = 'main universe ' %}
{% endif %}

include:
  - base: apt

/etc/apt/sources.list.d/openstack.list:
  file.managed:
    - source: salt://apt/openstack.list.{{ os }}
    - mode: 644
    - user: root
    - group: root
    - name: /etc/apt/sources.list.d/openstack.list
    - template: jinja
    - defaults:
      distrib: {{ salt['grains.get']('lsb_distrib_codename') }}
      openstack_release: {{pillar['openstack_release']}}

ubuntu-ppa:
  file.managed:
    - source: salt://apt/ubuntu-openstack-ppa.gpg
    - mode: 644
    - user: root
    - group: root
    - name: /etc/apt/trusted.gpg.d/ubuntu-openstack-ppa.gpg

debian-openstack-jenkins:
  file.managed:
    - source: salt://apt/debian-openstack-jenkins.gpg
    - mode: 644
    - user: root
    - group: root
    - name: /etc/apt/trusted.gpg.d/debian-openstack-jenkins.gpg

