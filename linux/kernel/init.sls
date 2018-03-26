{% from "linux/kernel/map/map.jinja" import kernel with context %}

include:
  {{ kernel.includes|yaml(false)|indent(2) }}

