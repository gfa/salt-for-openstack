{% for cacert in salt['pillar.get']('ca-certs') %}


/usr/local/share/ca-certificates/{{cacert}}.crt:
  file.managed:
    - mode: 644
    - user: root
    - group: root
    - contents_pillar: ca-certs:{{cacert}}

{% endfor %}

update-ca-certificates:
  cmd.run:
    - name: /usr/sbin/update-ca-certificates
