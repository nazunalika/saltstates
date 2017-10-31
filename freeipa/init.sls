{#
  This is the beginning of FreeIPA. We do the client and/or server installations based on
  what we see in pillar.
#}
include:
  {%- if pillar.freeipa.client is defined %}
  - .client
  {%- endif %}
  {%- if pillar.freeipa.server is defined %}
  - .server
  {%- endif %}
  - .common
