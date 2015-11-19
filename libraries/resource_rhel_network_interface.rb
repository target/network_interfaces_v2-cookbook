#
# Author:: Jacob McCann (<jacob.mccann2@target.com>)
# Cookbook Name:: network_interfaces_v2
# Resource:: rhel_network_interface
#
# Copyright:: 2015, Target Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_relative 'resource_network_interface'

class Chef
  class Resource
    class NetworkInterface
      #
      # Chef Resource for a rhel_network_interface
      #
      class Rhel < Chef::Resource::NetworkInterface
        provides :rhel_network_interface
        provides :network_interface, os: 'linux', platform_family: %w(rhel fedora) if Gem::Version.new(Chef::VERSION) >= Gem::Version.new('12.0.0')
        provides :network_interface, on_platforms: [:redhat, :centos] unless Gem::Version.new(Chef::VERSION) >= Gem::Version.new('12.0.0')

        def initialize(name, run_context = nil)
          super
          @resource_name = :rhel_network_interface
          @provider = Chef::Provider::NetworkInterface::Rhel

          @type = 'Ethernet'
          @nm_controlled = false
        end

        def nm_controlled(arg = nil)
          set_or_return(:nm_controlled, arg, kind_of: [TrueClass, FalseClass])
        end

        def ipv6init(arg = nil)
          set_or_return(:ipv6init, arg, kind_of: [TrueClass, FalseClass])
        end

        def nozeroconf(arg = nil)
          set_or_return(:nozeroconf, arg, kind_of: [TrueClass, FalseClass])
        end

        def userctl(arg = nil)
          set_or_return(:userctl, arg, kind_of: [TrueClass, FalseClass])
        end

        def peerdns(arg = nil)
          set_or_return(:peerdns, arg, kind_of: [TrueClass, FalseClass])
        end

        def bridge_device(arg = nil)
          set_or_return(:bridge_device, arg, kind_of: String)
        end

        def network(arg = nil)
          set_or_return(:network, arg, kind_of: String)
        end

        def type(arg = nil)
          set_or_return(:type, arg, kind_of: String)
        end

        def devicetype(arg = nil)
          set_or_return(:devicetype, arg, kind_of: String)
        end

        def ovs_bridge(arg = nil)
          set_or_return(:ovs_bridge, arg, kind_of: String)
        end

        def vlan(arg = nil)
          set_or_return(:vlan, arg, kind_of: [TrueClass, FalseClass])
        end

        def mac_address(arg = nil)
          set_or_return(:mac_address, arg, kind_of: String, regex: /^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$/)
        end

        def dns(arg = nil)
          set_or_return(:dns, arg, kind_of: [String, Array])
        end

        def prefix(arg = nil)
          set_or_return(:prefix, arg, kind_of: Integer)
        end

        def dns_domain(arg = nil)
          set_or_return(:dns_domain, arg, kind_of: String)
        end

        def zone(arg = nil)
          set_or_return(:zone, arg, kind_of: String)
        end
      end
    end
  end
end
