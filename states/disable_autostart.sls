/usr/sbin/policy-rc.d:
  file.managed:
    - user: root
    - group: root
    - mode: '0755'
    - contents: |
        exit 101
