# 2.11.0
* Add ability to define array of pre/up/post and pre/down/post commands.

# 2.10.0
* Add defroute attribute for rhel family interface
* Add ovsbootproto attribute for rhel family interface
* Add ovsdhcpinterfaces attribute for rhel family interface

# 2.9.0
* Support for Ubuntu 16.04
* Support for multiple device definitions on ubuntu (#20 and #26)

# 2.8.0
* Add hw_address support for debian

# 2.7.0
* Add ipv6 support for debian

# 2.6.0
* Add management of debian DNS
* Add management of RHEL firewalld zones

# 2.5.1
* Fix RHEL configs from on/off to yes/no

# 2.5.0
* Add powershell installer for Windows 2008 R2 to allow cookbook to work

# 2.4.1
* bug: Fix `win_interface` to be able to manage interfae via `index`
* bug: Enable static on `win_interface` when DHCP with matching ip/subnet (#13)

# 2.4.0
* Add `dns_domain` attribute to network_interface for RHEL

# 2.3.0
* Add `ovs_bridge` attribtue to network_interface for RHEL

# 2.2.0
* Add `dns` attribute to network_interface for RHEL
* Add `devicetype` attribute to network_interface for RHEL
* Add `prefix` attribute to network_interface for RHEL

# 2.1.2

* Add supported platforms to metadata.rb
* Update gem source for integration testing to https from http

# 2.1.1

* Update how to determine when to specify `provides` in providers

# 2.1.0

* Remove dependency on ruby-wmi gem

# 2.0.1

* Fix handling DNS for windows VLAN devices

# 2.0.0

* Fix providers not triggering notifications
* No longer manage removal of 'extra' network config files in debian
* Add ability to enable/disable NetBIOS on windows interfaces

# 1.1.0

* Add running post scripts on interface config to all platforms
* On windows release DHCP address when configuring static from DHCP
* Update logic for configuring static address
 * Update if address or netmask are missing or incorrect
 * Add IP to 'front' of array of addresses ... keep any extra addresses that may have been configured outside of Chef
  * I've heard this can happen from things like MSFT products/services being added to a system ... like clustering

# 1.0.0

Initial release of network_interfaces_v2
