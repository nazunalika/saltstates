firewalld:
  rabbitmq:
    file: /etc/firewalld/services/rabbitmq.xml
    content: |
      <?xml version="1.0" encoding="utf-8"?>
      <service>
        <short>rabbitmq</short>
        <description>Set of rules for rabbitmq</description>
        <port protocol="tcp" port="1883"/>
        <port protocol="tcp" port="1884"/>
        <port protocol="tcp" port="4369"/>
        <port protocol="tcp" port="5671"/>
        <port protocol="tcp" port="5672"/>
        <port protocol="tcp" port="8883"/>
        <port protocol="tcp" port="15672"/>
        <port protocol="tcp" port="25672"/>
        <port protocol="tcp" port="61613"/>
        <port protocol="tcp" port="61614"/>
      </service>
