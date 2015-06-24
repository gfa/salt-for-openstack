nothing: 'here - configure master to provide the environment pillar'
{% if grains['os'] == 'RedHat' %}
apache: httpd
git: git
{% elif grains['os'] == 'Debian' %}
apache: apache2
git: git-core
syslog_user: root
{% elif grains['os'] == 'Ubuntu' %}
apache: apache2
git: git-core
syslog_user: syslog
{% endif %}
approxrepo: 'http://192.168.255.1:9999'
acnghost: '192.168.255.1'
