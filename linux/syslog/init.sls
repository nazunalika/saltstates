{% from "linux/syslog/map/map.jinja" import syslog with context %}

{# This is for syslog configuration. We are doing additional rsyslog confs in pillar #}

{% set pget = salt['pillar.get'] %}

{{ syslog.service }}:
  pkg.installed:
    - name: {{ syslog.service }}

  file.managed:
    - name: {{ syslog.conf }}
    - source: {{ syslog.source }}
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: {{ syslog.service }}
    - watch_in:
      - service: {{ syslog.service }}

  service.running:
    - name: {{ syslog.service }}
    - enable: True
    - watch:
      - pkg: {{ syslog.service }}
      - file: {{ syslog.service }}

{% for name, logconf in pillar.get('syslog', {}).items() %}
{% if logconf == None %}
{% set logconf = {} %}
{% endif %}

{% set current = salt.user.info(name) %}
{% set syslogconf = logconf.get('file', current.get('file', "/etc/rsyslog.d/%s.conf" % name)) %}

{{ syslog.service }}_{{ name }}_file:
  file.managed:
    - name: {{ syslogconf }}
    - user: root
    - group: root
    - mode: 644
    - contents_pillar: syslog:{{name}}:content
    - watch_in:
      - service: {{ syslog.service }}

{% endfor %}
