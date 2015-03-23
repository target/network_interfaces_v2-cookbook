#
# Cookbook Name:: network_interfaces_v2
# Recipe:: default
#
# Copyright (C) 2015 Target Corporation
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'network_interfaces_v2::_rhel' if %w(rhel fedora).include? node['platform_family']
include_recipe 'network_interfaces_v2::_debian' if %w(debian ubuntu).include? node['platform_family']
