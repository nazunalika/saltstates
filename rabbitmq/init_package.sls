{% from "rabbitmq/map.jinja" import rabbitmq with context %}
ensure_epel:
  pkg.installed:
    - pkgs:
      - epel-release
    - refresh: True

rabbitmq_package:
  pkg.installed:
    - pkgs:
      - rabbitmq-server
    - refresh: True

  service.running:
    - name: rabbitmq-server
    - provider: {{ rabbitmq.provider }}
    - enable: True

