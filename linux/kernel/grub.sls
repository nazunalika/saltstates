{% from "linux/kernel/map/map.jinja" import kernel with context %}
{%- set kernel_boot_opts = [] %}
{%- do kernel_boot_opts.append('isolcpus=' ~ kernel.isolcpu) if kernel.isolcpu is defined %}
{%- do kernel_boot_opts.append('elevator=' ~ kernel.elevator) if kernel.elevator is defined %}
{%- do kernel_boot_opts.extend(kernel.boot_options) if kernel.boot_options is defined %}

{%- if kernel_boot_opts %}
grubby_legacy:
  cmd.run:
    - name: grubby --update-kernel=ALL --args="{{ kernel_boot_opts|join(' ') }}"
{% endif %}
