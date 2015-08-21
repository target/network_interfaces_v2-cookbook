#
# Author:: Jacob McCann (<jacob.mccann2@target.com>)
# Cookbook Name:: network_interfaces_v2
# Resource:: network_interface
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

require 'chef/resource'

class Chef
  class Resource
    #
    # Chef Resource for a network_interface
    #
    class NetworkInterface < Chef::Resource
      def initialize(name, run_context = nil) # rubocop:disable MethodLength
        super
        @resource_name = :network_interface
        @provider = Chef::Provider::NetworkInterface
        @action = :create
        @allowed_actions = [:create]

        # This is equivalent to setting :name_attribute => true
        @device = name

        @bootproto = 'dhcp'
        @onboot = true
        @cookbook = 'network_interfaces_v2'
        @source = 'ifcfg.erb'
        @reload = true
        @reload_type = :immediately
      end

      def cookbook(arg = nil)
        set_or_return(:cookbook, arg, kind_of: String)
      end

      def source(arg = nil)
        set_or_return(:source, arg, kind_of: String)
      end

      def device(arg = nil)
        set_or_return(:device, arg, kind_of: String)
      end

      def type(arg = nil)
        set_or_return(:type, arg, kind_of: String)
      end

      def bridge_stp(arg = nil)
        set_or_return(:bridge_stp, arg, kind_of: [TrueClass, FalseClass])
      end

      def bond_master(arg = nil)
        set_or_return(:bond_master, arg, kind_of: String)
      end

      def bond_mode(arg = nil)
        set_or_return(:bond_mode, arg, kind_of: String)
      end

      def onboot(arg = nil)
        set_or_return(:onboot, arg, kind_of: [TrueClass, FalseClass])
      end

      def bootproto(arg = nil)
        set_or_return(:bootproto, arg, kind_of: String)
      end

      def address(arg = nil)
        set_or_return(:address, arg, kind_of: String)
      end

      def gateway(arg = nil)
        set_or_return(:gateway, arg, kind_of: String)
      end

      def mtu(arg = nil)
        set_or_return(:mtu, arg, kind_of: Integer)
      end

      def netmask(arg = nil)
        set_or_return(:mask, arg, kind_of: String)
      end

      def broadcast(arg = nil)
        set_or_return(:broadcast, arg, kind_of: String)
      end

      def reload(arg = nil)
        set_or_return(:reload, arg, kind_of: [TrueClass, FalseClass])
      end

      def reload_type(arg = nil)
        set_or_return(:reload_type, arg, kind_of: Symbol)
      end

      def hw_address(arg = nil)
        set_or_return(:hw_address, arg, kind_of: String, regex: /^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$/)
      end

      def vlan(arg = nil)
        set_or_return(:vlan, arg, kind_of: [TrueClass, FalseClass, String, Integer])
      end

      def post_up(arg = nil)
        set_or_return(:post_up, arg, kind_of: String)
      end
    end
  end
end
