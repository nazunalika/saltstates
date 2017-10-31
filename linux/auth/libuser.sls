{% from "linux/auth/map/map.jinja" import auth with context %}
{% set os = auth.version %}

libuser_reqpkgs:
  pkg.installed:
    - pkgs:
      - libuser

libuser_conf:
  file.managed:
    - name: /etc/libuser.conf
    - source: salt://linux/auth/files/libuser/{{ os }}-libuser.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: libuser_reqpkgs

