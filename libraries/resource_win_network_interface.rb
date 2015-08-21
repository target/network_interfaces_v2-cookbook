#
# Author:: Jacob McCann (<jacob.mccann2@target.com>)
# Cookbook Name:: network_interfaces_v2
# Resource:: win_network_interface
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
      # Chef Resource for a win_network_interface
      #
      class Win < Chef::Resource::NetworkInterface
        provides :win_network_interface
        provides :network_interface, os: 'windows' if Gem::Version.new(Chef::VERSION) >= Gem::Version.new('12.0.0')
        provides :network_interface, on_platforms: :windows unless Gem::Version.new(Chef::VERSION) >= Gem::Version.new('12.0.0')

        attr_accessor :addresses, :netmasks

        def initialize(name, run_context = nil)
          super
          @resource_name = :win_network_interface
          @provider = Chef::Provider::NetworkInterface::Win

          @netbios = 'dhcp'
        end

        def hw_address(arg = nil)
          arg = arg.tr('-', ':').upcase unless arg.nil?
          set_or_return(:hw_address, arg, kind_of: String, regex: /^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$/)
        end

        def index(arg = nil)
          set_or_return(:index, arg, kind_of: Integer)
        end

        def vlan(arg = nil)
          set_or_return(:vlan, arg, kind_of: [Integer, String])
        end

        def dns(arg = nil)
          set_or_return(:dns, arg, kind_of: Array)
        end

        def dns_domain(arg = nil)
          set_or_return(:dns_domain, arg, kind_of: String)
        end

        def ddns(arg = nil)
          set_or_return(:ddns, arg, kind_of: [TrueClass, FalseClass])
        end

        def netbios(arg = nil)
          set_or_return(:netbios, arg, kind_of: [TrueClass, FalseClass, String], equal_to: [true, false, 'dhcp'])
        end
      end
    end
  end
end
