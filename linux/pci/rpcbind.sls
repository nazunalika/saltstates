kill_nfs:
  service.dead:
    - name: nfs

disable_nfs:
  service.disabled:
    - name: nfs

disable_nfs_server:
  service.disabled:
    - name: nfs-server
