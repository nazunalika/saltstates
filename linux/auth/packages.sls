{%- from "linux/auth/map/map.jinja" import auth with context %}
authentication_packages:
  pkg.installed:
    - names: {{ auth.packages }}
    - refresh: True
