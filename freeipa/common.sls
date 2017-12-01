{%- from "freeipa/map/map.jinja" import client with context %}
include:
  {{ client.commonsls|yaml(false)|indent(2) }}

