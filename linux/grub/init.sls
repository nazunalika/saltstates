{% if salt['grains.get']('init') == 'systemd' %}
grub_d_directory:
  file.directory:
    - name: /etc/default/grub.d
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/etc/default/grub:
  file.append:
    - text:
      - for x in $(ls /etc/default/grub.d) ; do source /etc/default/grub.d/$x ; done

update_grub2:
  cmd.run:
    - name: grub2-mkconfig -o "$(readlink /etc/grub2.cfg)"

{% endif %}
