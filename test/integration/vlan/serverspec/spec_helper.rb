require 'serverspec'

def windows?
  !(RUBY_PLATFORM =~ /mswin|mingw32|windows/).nil?
end

def wmi
  @wmi ||= WmiLite::Wmi.new
end

def net_adapters
  @adapters ||= wmi.instances_of('Win32_NetworkAdapter')
end

def adapter_configs
  @adapter_configs ||= wmi.instances_of('Win32_NetworkAdapterConfiguration')
end

def debian?
  File.exist? '/etc/debian_version'
end

def rhel?
  File.exist? '/etc/redhat-release'
end

def win_interface(name)
  net_adapters.find { |n| n['netconnectionid'] == name }
end

def win_interface_config(name)
  adapter_configs.find { |n| n['interfaceindex'] == win_interface(name)['interfaceindex'] }
end

# NIX?
set :backend, :exec unless windows?

# Windows
require 'wmi-lite' if windows?
set :backend, :cmd if windows?
set :os, :family => 'windows' if windows?
