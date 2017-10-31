{%- from "linux/auth/map/map.jinja" import auth with context %}

include:
  {{ auth.includes|yaml(false)|indent(2) }}

