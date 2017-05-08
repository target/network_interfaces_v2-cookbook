name             'network_interfaces_v2'
maintainer       'Jacob McCann'
maintainer_email 'jacob.mccann2@target.com'
license          'Apache-2.0'
description      'Providers for configuring network on Ubuntu, RHEL, and Windows'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url       'https://github.com/target/network_interfaces_v2-cookbook'
issues_url       'https://github.com/target/network_interfaces_v2-cookbook/issues'
version          '2.11.0'
chef_version     '>= 12'

supports 'ubuntu', '>= 14.04'
supports 'windows'
supports 'redhat', '>= 6.0'
supports 'centos', '>= 6.0'

depends 'kernel_module', '~> 1.0'
depends 'powershell'
