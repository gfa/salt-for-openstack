tmux:
  pkg:
    - installed

/etc/tmux.conf:
  file.managed:
    - source: salt://tmux/tmux.conf
    - mode: 644
    - user: root
    - group: root
    - require: 
      - pkg: tmux
