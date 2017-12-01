FreeIPA
=======

This is the FreeIPA states for clients and servers. The client states will be ignored if it's the first IPA server in the list of defined servers in pillar. While we have macOS and Solaris examples, this is focused **only** on RHEL/CentOS clients. Support is only provided for RHEL/CentOS. If you have other clients, you will need to add them appropriately in the yaml's and create additional logic as required.

These are the requirements to run these states:

* Delegated subdomain (ipa.domain.tld) or forwarded domain for the servers
* IPA server or servers need to be up and running for the clients
* DHCP server should be telling clients to use the IPA servers have the DNS server *if* it's the only DNS server available
* I cannot stress this enough, **your DNS needs to be setup properly!**

Dynamic DNS from DHCP isn't necessarily required as the clients can be enabled to update themselves in DNS. If you want Dynamic DNS for all your other clients that are not IPA, you need to make sure that you do not set client:dns:updates in your pillar.
