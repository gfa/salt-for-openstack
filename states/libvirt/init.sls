include:
  - base: apt
  #  - base: intel-microcode

libvirt-auto-network:
  file.absent:
    - name: /etc/libvirt/qemu/networks/default.xml
  cmd.wait:
    - name: virsh net-destroy default

libvirt-bin:
  pkg.installed:
    - name: libvirt-bin
  service.running:
    - name: libvirtd
    - watch:
      - file: /etc/default/libvirt-bin
      - file: /etc/libvirt/libvirtd.conf
      - file: /etc/libvirt/qemu.conf

sysfsutils:
  pkg.installed

{% for pkg in ('qemu-kvm', 'qemu-system-x86', 'qemu-system-common', 'qemu-keymaps', 'qemu-utils') %}

{{pkg}}:
  pkg:
{% if salt['pillar.get']('nova_version', False) %}
    - installed
    - version: {{ salt['pillar.get']('nova_version') }}
{% else %}
    - latest
{% endif %}

{% endfor %}

/etc/default/libvirt-bin:
  file.managed:
    - source: salt://libvirt/libvirtd.default

/etc/libvirt/libvirtd.conf:
  file.managed:
    - source: salt://libvirt/libvirtd.conf
    - template: jinja
    - defaults:
      my_ip: {{ salt['network.interfaces']()['eth0']['inet'][0]['address'] }}

/etc/libvirt/qemu.conf:
  file.managed:
    - source: salt://libvirt/qemu.conf

/etc/modules:
  file.append:
    - text: |
        kvm
        kvm_intel
        vhost-net
        nbd
  cmd.wait:
    - name: |
        modprobe kvm
        modprobe kvm_intel
        modprobe vhost-net
        modprobe nbd
    - watch:
      - file: /etc/modules

open-iscsi:
  service:
    - dead
    - enabled: False

python-guestfs:
  pkg.installed
