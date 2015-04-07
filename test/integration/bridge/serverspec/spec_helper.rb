require 'serverspec'

set :backend, :exec

def debian?
  File.exist? '/etc/debian_version'
end

def rhel?
  File.exist? '/etc/redhat-release'
end
