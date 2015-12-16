Cookbook network_interfaces_v2
==============================
[![Build Status](https://travis-ci.org/target/network_interfaces_v2-cookbook.svg?branch=travis_ci)](https://travis-ci.org/target/network_interfaces_v2-cookbook)

A cookbook containing providers for defining network interfaces.

Supported Platforms
===================

* RHEL 6.x
* RHEL 7.x
* Ubuntu >= 12.x
* Windows 2012R2

### Semi-supported
These operating systems are not currently being tested on but have been confirmed by other users to be working.

* RHEL 7.x
* Windows 2008R2
  * Works if PowerShell/WMF 4.0 is present, which can be installed via `network_interfaces_v2::powershell_installer` recipe

Usage
=====

Add `depends 'network_interfaces_v2'` to your cookbook metadata.rb file.  This
will give you access to the providers documented below.

Recipes
=======

default
-------
Does nothing and does not need to be included.

powershell_installer
--------------------
Installs WMF 4.0 for Windows 2008 R2 which is a prereq for this cookbook's providers to work on Windows 2008 R2.

network_interface
=================
Provider for managing network interfaces.

Attributes
----------
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
* post_up - Post up command to run after modifying the interface
* reload (default: true) - Wether or not to reload the device on config changes
* reload_type (default: :immediately) - When to reload device on config changes
* cookbook (default: 'network_interfaces_v2') - Cookbook to look for template files in
* source (default: 'ifcfg.erb') - Template file to use for interface config

#### Debian Only Attributes
* ipv6 (true/false) - Wether this is an inet or inet6 network interface.
* bridge_stp (true/false) - Wether to enable/disable bridge STP.  Applies to debian only.
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

#### RHEL Only Attributes
* prefix - Netmask length (e.g. 24 for 255.255.255.0)
* dns - Array of DNS servers
* type - Protocol Type.  Applies to RHEL only.
* bond_master - Device that is the bond master for defined device.  Applies to RHEL only.
* nm_controlled (default: false)- If device should be controlled by network manager.
* type (default: 'Ethernet') -
* ipv6init - true/false
* nozeroconf - true/false
* userctl - true/false
* peerdns - true/false
* bridge_device - Bridge to add defined interface to
* devicetype - Set the type of device (e.g. 'ovs')
* ovs_bridge - OVS Bridge to bind ovs port to (primarily used when `type` is set as 'OVSPort')
* dns_domain - DNS domain
* zone - FirewallD zone

#### Windows Only Attributes
* hw_address - Can be used to define what device to manage
* index - Can be used to define what device to manage
* dns - Array of DNS servers
* dns_domain - DNS domain
* ddns - true/false dynamic dns registration
* netbios - Enable/Disable netbios on the interface.  Valid values: true, false, 'dhcp'

Providers
---------

Long name | Short name
----------|-----------
Chef::Provider::NetworkInterface::Rhel | rhel_network_interface
Chef::Provider::NetworkInterface::Debian | debian_network_interface
Chef::Provider::NetworkInterface::Win | win_network_interface

Examples
--------

Basic example:
```ruby
network_interface 'eth1' do
  bootproto 'static'
  address '10.12.10.11'
  netmask '255.255.255.0'
  gateway '10.12.10.1'
end
```

Two interface DHCP bond0 on rhel family
```ruby
network_interface 'eth1' do
  bootproto 'none'
  bond_master 'bond0'
end

network_interface 'eth2' do
  bootproto 'none'
  bond_master 'bond0'
end

network_interface 'bond0' do
  bond_mode 'mode=1 miimon=100'
end
```

Two interface DHCP bond0 on debian family
```ruby
network_interface 'bond0' do
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

On windows manage device with MAC '00-25-B5-5B-00-25', name it 'eth2',
make it DHCP (default bootproto) and VLAN tagged to VLAN 12
```ruby
network_interface 'eth2' do
  hw_address '00-25-B5-5B-00-25'
  vlan 12
end
```

Testing
=======
Requires [ChefDK](https://downloads.chef.io/chef-dk/) 0.10.0.

```
rubocop
foodcritic -f any -X spec .
rspec --color --format progress
kitchen test
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
