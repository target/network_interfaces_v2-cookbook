require 'serverspec'

def windows?
  RUBY_PLATFORM =~ /mswin|mingw32|windows/
end

def debian?
  File.exist? '/etc/debian_version'
end

def rhel?
  File.exist? '/etc/redhat-release'
end

set :backend, :exec unless windows?
set :backend, :cmd if windows?
set :os, :family => 'windows' if windows?
