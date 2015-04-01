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

def debian?
  File.exist? '/etc/debian_version'
end

def rhel?
  File.exist? '/etc/redhat-release'
end

def install_wmi
  puts 'Installing wmi-lite gem'
  `#{Gem.bindir}/bundle install --gemfile #{File.join(File.dirname(__FILE__), 'Gemfile')}`
  Gem.clear_paths
end

def load_wmi
  puts 'Loading wmi-lite gem'
  begin
    gem 'wmi-lite'
  rescue LoadError
    install_wmi
  end

  require 'wmi-lite'
end

def win_interface(name)
  net_adapters.find { |n| n['netconnectionid'] == name }
end

# NIX?
set :backend, :exec unless windows?

# Windows
load_wmi if windows?
set :backend, :cmd if windows?
set :os, :family => 'windows' if windows?
