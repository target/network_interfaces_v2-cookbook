# 1.1.0

* Add running post scripts on interface config to all platforms
* On windows release DHCP address when configuring static from DHCP
* Update logic for configuring static address
 * Update if address or netmask are missing or incorrect
 * Add IP to 'front' of array of addresses ... keep any extra addresses that may have been configured outside of Chef
  * I've heard this can happen from things like MSFT products/services being added to a system ... like clustering

# 1.0.0

Initial release of network_interfaces_v2
