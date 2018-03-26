{% set pget = salt['pillar.get'] %}
{% for name, module in pillar.get('modprobe', {}).items() %}

{% if module == None %}
{% set module = {} %}
{% endif %}

{% set current = salt.user.info(name) %}
{% set modprobefile = module.get('file', current.get('file', "/etc/modprobe.d/%s.conf" % name)) %}

modprobe_{{ name }}_file:
  file.managed:
    - name: {{ modprobefile }}
    - user: root
    - group: root
    - mode: 644
    - contents_pillar: modprobe:{{ name }}:content

{% endfor %}

