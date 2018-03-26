{% from "linux/kernel/map/map.jinja" import kernel with context %}
{%- set kernel_boot_opts = [] %}
{%- do kernel_boot_opts.append('isolcpus=' ~ kernel.isolcpu) if kernel.isolcpu is defined %}
{%- do kernel_boot_opts.append('elevator=' ~ kernel.elevator) if kernel.elevator is defined %}
{%- do kernel_boot_opts.extend(kernel.boot_options) if kernel.boot_options is defined %}

include:
  - linux.grub

{%- if kernel_boot_opts %}
/etc/default/grub.d/99-aoc.cfg:
  file.managed:
    - contents: 'GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT {{ kernel_boot_opts|join(' ') }}"'
    - watch_in:
      - cmd: update_grub2
{% endif %}
