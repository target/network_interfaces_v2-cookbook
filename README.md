Cookbook network_interfaces_v2
==============================

A cookbook containing providers for defining network interfaces.

Supported Platforms
===================

* RHEL 6.x
* Ubuntu >= 12.x
* Windows 2012R2

Usage
=====

Recipes
-------

* default - Does nothing
* _debian - Contains dependencies for providers.  DO NOT INCLUDE
* _rhel - Contains dependencies for providers.  DO NOT INCLUDE
* _win - Contains dependencies for providers.  DO NOT INCLUDE

Providers
=========

network_interface
-----------------

#### Attributes

* device (**REQUIRED**) - Device name
* onboot (default: true) - Wether or not to online device on boot
* bootproto (default: 'dhcp') - Device protocol
* bond_mode - Bonding mode
* address - IP address
* netmask - Netmask
* gateway - Gateway IP address
* broadcast - Broadcast address
* mtu - MTU
* hw_address - MAC address of device to configure
* vlan
 * debian - VLAN device interface
 * RHEL - true/false if device defined is a VLAN interface
 * Win - Integer VlanID to tag to defined device
* reload (default: true) - Wether or not to reload the device on config changes
* reload_type (default: :immediately) - When to reload device on config changes
* cookbook (default: 'network_interfaces_v2') - Cookbook to look for template files in
* source (default: 'ifcfg.erb') - Template file to use for interface config

##### Debian Only Attributes
* bridge_stp (true/false) - Wether to enable/disable bridge STP.  Applies to debian only.

##### RHEL Only Attributes
* type - Protocol Type.  Applies to RHEL only.
* bond_master - Device that is the bond master for defined device.  Applies to RHEL only.

#### Example

```ruby
network_interface 'eth1' do
  bootproto 'static'
  address '10.12.10.11'
  netmask '255.255.255.0'
  gateway '10.12.10.1'
end
```

rhel_network_interface
----------------------
Inherits all attributes from `network_interface` provider as well as:

* nm_controlled (default: false)- If device should be controlled by network manager.
* type (default: 'Ethernet') -
* ipv6init - true/false
* nozeroconf - true/false
* userctl - true/false
* peerdns - true/false
* bridge_device - Bridge to add defined interface to

#### Example

Two interface DHCP bond0
```ruby
network_interface 'eth1' do
  bootproto 'none'
  bond_master 'bond0'
end

network_interface 'eth2' do
  bootproto 'none'
  bond_master 'bond0'
end

rhel_network_interface 'bond0' do
  bond_mode 'mode=1 miimon=100'
end
```

debian_network_interface
------------------------
Inherits all attributes from `network_interface` provider as well as:

* bridge_ports - Array of interfaces to add to defined bridge
* metric -
* bond_slaves - Array of interfaces to add to defined bond
* pre_up (default: 'sleep 2')- Pre up command
* up - Up command
* post_up - Post up command
* pre_down - Pre down command
* down - Down command
* post_down - Post down command
* custom - Hash of extra attributes to put in device config

#### Example

Two interface DHCP bond0
```ruby
debian_network_interface 'bond0' do
  bond_slaves ['eth1', 'eth2']
  bond_mode '0'
end

network_interface 'eth1' do
  bootproto 'manual'
  bond_master 'bond0'
end

network_interface 'eth2' do
  bootproto 'manual'
  bond_master 'bond0'
end
```

win_network_interface
---------------------
Inherits all attributes from `network_interface` provider as well as:

* hw_address - Can be used to define what device to manage
* index - Can be used to define what device to manage
* dns - Array of DNS servers
* dns_search - Array of DNS suffix search order
* ddns - true/false dynamic dns registration

#### Example

Manage device with MAC '00-25-B5-5B-00-25', name it 'eth2' with DHCP tagged to VLAN 12
```ruby
win_network_interface 'eth2' do
  hw_address '00-25-B5-5B-00-25'
  vlan 12
end
```

License and Authors
===================

Author:: Jacob McCann (<jacob.mccann2@target.com>)

Based on work from https://github.com/redguide/network_interfaces

```text
Copyright:: 2015, Target Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
