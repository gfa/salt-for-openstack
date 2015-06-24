vim-nox:
  pkg.installed

/etc/vim/vimrc:
  file.managed:
    - source: salt://vim/vimrc
    - mode: 644
    - user: root
    - group: root
