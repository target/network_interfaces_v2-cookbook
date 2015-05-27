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
