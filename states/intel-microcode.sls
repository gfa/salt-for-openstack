debconf-utils:
  pkg.installed

microcodedebconf:
  debconf.set:
    - name: microcode.ctl
    - data:
        'microcode.ctl/check-new': {'type': 'boolean', 'value': False}

intel-microcode:
    pkg.installed
