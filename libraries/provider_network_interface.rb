#
# Author:: Jacob McCann (<jacob.mccann2@target.com>)
# Cookbook Name:: network_interfaces_v2
# Provider:: network_interface
#
# Copyright:: 2015, Target Corporation
#

require 'chef/provider'

class Chef
  class Provider
    #
    # Chef Provider for Network Interfaces
    #
    class NetworkInterface < Chef::Provider
      # We MUST define this method in our custom provider
      def load_current_resource; end

      def action_create_if_missing
        converge_by("create interface #{new_resource.device}") do
          create_if_missing_interface
          Chef::Log.info "#{@new_resource} created #{new_resource.device}"
        end
      end

      def action_create
        converge_by("create interface #{new_resource.device}") do
          create_interface
          Chef::Log.info "#{@new_resource} created #{new_resource.device}"
        end
      end

      def create_if_missing_interface
        raise Chef::Exceptions::UnsupportedAction, "#{self.to_s} does not support :create_if_missing_interface"
      end

      def create_interface
        raise Chef::Exceptions::UnsupportedAction, "#{self.to_s} does not support :create"
      end
    end
  end
end
