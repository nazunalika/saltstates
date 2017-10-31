{%- from "freeipa/map/map.jinja" import client, server, ipahost with context %}

include:
  {%- if server.get('enabled', False) %}
  - freeipa.server
  {%- else %}
  - freeipa.client
  {%- endif %}

{#
  This section is for providing additional certificates to hosts that would be signed by the IPA servers.
#}

