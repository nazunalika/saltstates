{% from "rabbitmq/map.jinja" import rabbitmq with context %}
include:
  - .{{ rabbitmq.rabbitmq_type }}
