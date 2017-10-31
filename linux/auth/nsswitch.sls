{% from "linux/auth/map/map.jinja" import auth with context %}
{% set os = auth.version %}

nsswitch_config:
  file.managed:
    - name: /etc/nsswitch.conf
    - source: salt://linux/auth/files/nsswitch/{{ os }}-nsswitch.conf
    - user: root
    - group: root
    - mode: 644

