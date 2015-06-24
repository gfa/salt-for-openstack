at:
  pkg:
    - installed
    - name: at
  service:
    - name: atd
    - running
    - enable: True
    - require:
      - pkg: at
