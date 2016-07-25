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

def rhel_version
  File.read('/etc/redhat-release').gsub(/.* ([\.0-9]+).*/, '\1').chomp
end

def ubuntu_version
  `lsb_release -r -s`
end

def win_interface(name)
  net_adapters.find { |n| n['netconnectionid'] == name }
end

def win_interface_config(name)
  adapter_configs.find { |n| n['interfaceindex'] == win_interface(name)['interfaceindex'] }
end

def prefix
  return 'enp0s' if rhel? && rhel_version.split('.').first.to_i > 6
  return 'enp0s' if !rhel? && ubuntu_version.to_s >= '16.04'
  'eth'
end

def int
  @int ||= begin
    int = {}
    int['0'] = 'eth0'
    int['0'] = 'enp0s3' if rhel? && rhel_version.split('.').first.to_i > 6
    int['0'] = 'enp0s3' if !rhel? && ubuntu_version.to_s >= '16.04'
    (4..9).each do |n|
      int[n.to_s] = "#{prefix}#{n}"
    end
    int
  end
end

# NIX?
set :backend, :exec unless windows?

# Windows
require 'wmi-lite' if windows?
set :backend, :cmd if windows?
set :os, family: 'windows' if windows?
