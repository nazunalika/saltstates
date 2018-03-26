/etc/salt/minion.d/diskusage.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://beacons/files/diskusage.conf
