name             'network_interfaces_v2'
maintainer       'Jacob McCann'
maintainer_email 'jacob.mccann2@target.com'
license          'Apache 2.0'
description      'Providers for configuring network on Ubuntu, RHEL, and Windows'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.1.2'

supports 'ubuntu', '>= 12.04'
supports 'windows'
supports 'redhat', '~> 6.0'
supports 'centos', '~> 6.0'

depends 'modules', '~> 0.2.0'
