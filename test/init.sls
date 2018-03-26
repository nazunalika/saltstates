{%- from "test/map/map.jinja" import client with context %}

{#tester_cmd:
  cmd.run:
    - name: echo {{ client.trust.defaultdomain }}
#}
{% set gget = salt['grains.get'] %}
{% for interface, hwaddr in grains.get('hwaddr_interfaces', {}).items() %}
{% if '00:00:00:00:00:00' not in hwaddr %}
{{interface}}_testing:
  cmd.run:
    - name: echo "{{interface}} {{hwaddr}}"
{% endif %}
{% endfor %}
