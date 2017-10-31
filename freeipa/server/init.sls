{%- from "freeipa/map.jinja" import server, ipaservers with context %}

include:
  {%- if ipaservers.0 == server.get('hostname', grains['fqdn']) %}
  - freeipa.server.master
  {%- else %}
  - freeipa.server.replica
  {%- endif %}
