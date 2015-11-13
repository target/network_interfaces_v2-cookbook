require 'serverspec'

set :backend, :exec

def debian?
  File.exist? '/etc/debian_version'
end

def rhel?
  File.exist? '/etc/redhat-release'
end

def rhel_version
  File.read('/etc/redhat-release').gsub(/.* ([\.0-9]+).*/, '\1').chomp
end
