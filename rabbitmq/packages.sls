{#
   NOTE: Erlang in EPEL is too old  so it is absolutely required
         to use another repo for this package
#}

rabbitmq_dependencies:
  pkg.installed:
    - pkgs:
      - erlang
      - socat
