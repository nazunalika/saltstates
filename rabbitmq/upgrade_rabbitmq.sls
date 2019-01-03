{% from "rabbitmq/map/map.jinja" import rabbitmq with context %}                                                                                                                                                                               
stop_rabbitmq:
  service.dead:
    - name: rabbitmq

include:
  - .unpack
  - .configure

