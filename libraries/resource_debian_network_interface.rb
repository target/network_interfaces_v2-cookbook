#
# Author:: Jacob McCann (<jacob.mccann2@target.com>)
# Cookbook Name:: network_interfaces_v2
# Resource:: debian_network_interface
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
      # Chef Resource for a debian_network_interface
      #
      class Debian < Chef::Resource::NetworkInterface
        provides :debian_network_interface
        provides :network_interface, os: 'linux', platform_family: %w(debian) if Gem::Version.new(Chef::VERSION) >= Gem::Version.new('12.0.0')
        provides :network_interface, on_platforms: [:debian, :ubuntu] unless Gem::Version.new(Chef::VERSION) >= Gem::Version.new('12.0.0')

        def initialize(name, run_context = nil)
          super
          @resource_name = :debian_network_interface
          @provider = Chef::Provider::NetworkInterface::Debian

          @source = 'debian_interface.erb'
          @pre_up = 'sleep 2'
        end

        def bridge_ports(arg = nil)
          set_or_return(:bridge_ports, arg, kind_of: Array)
        end

        def metric(arg = nil)
          set_or_return(:metric, arg, kind_of: Integer)
        end

        def vlan(arg = nil)
          set_or_return(:vlan, arg, kind_of: String)
        end

        def bond_slaves(arg = nil)
          set_or_return(:bond_slaves, arg, kind_of: Array)
        end

        def type(arg = nil)
          set_or_return(:type, @bootproto, kind_of: String) if @type.nil?
          set_or_return(:type, arg, kind_of: String)
        end

        def dns(arg = nil)
          set_or_return(:dns, arg, kind_of: [String, Array])
        end

        def pre_up(arg = 'NOVAL')
          # Handle 'unsetting' default value with nil or ''
          @pre_up = nil if arg.nil? || arg == ''
          arg = nil if arg == 'NOVAL'

          set_or_return(:pre_up, arg, kind_of: String)
        end

        def up(arg = nil)
          set_or_return(:up, arg, kind_of: String)
        end

        def pre_down(arg = nil)
          set_or_return(:pre_down, arg, kind_of: String)
        end

        def down(arg = nil)
          set_or_return(:down, arg, kind_of: String)
        end

        def post_down(arg = nil)
          set_or_return(:post_down, arg, kind_of: String)
        end

        def custom(arg = nil)
          set_or_return(:custom, arg, kind_of: Hash)
        end
      end
    end
  end
end
