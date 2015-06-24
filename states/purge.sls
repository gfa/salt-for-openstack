{% for pkg in ('exim4-base', 'exim4-config', 'exim4-daemon-light', 'nano') %}

{{pkg}}:
  pkg:
    - purged

{% endfor %}


