base:
  '*':
    - users
    - groups
    - modprobe
    - freeipa.client

  'osmajorrelease:6':
    - match: grain
    - auth.el6
    - audit.el6
    - ssh.el6

  'osmajorrelease:7':
    - match: grain
    - auth.el7
    - audit.el7
    - ssh.el7

  'role:freeipa':
    - match: grain
    - freeipa.server
