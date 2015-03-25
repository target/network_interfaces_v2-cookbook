#!/usr/bin/env bats

platform_family=$(ohai platform_family | grep '"' | awk -F\" '{print $2}')

@test 'created config file for eth0' {
  # Debian/Ubuntu specific tests
  if [[ "$platform_family" == 'debian' ]]; then
    [ -f /etc/network/interfaces.d/eth0 ]
  fi

  # CentOS specific tests
  if [[ "$platform_family" == 'rhel' ]]; then
    [ -f /etc/sysconfig/network-scripts/ifcfg-eth0 ]
  fi
}

@test 'created config file for eth1' {
  # Debian/Ubuntu specific tests
  if [[ "$platform_family" == 'debian' ]]; then
    [ -f /etc/network/interfaces.d/eth1 ]
  fi

  # CentOS specific tests
  if [[ "$platform_family" == 'rhel' ]]; then
    [ -f /etc/sysconfig/network-scripts/ifcfg-eth1 ]
  fi
}

@test 'created config file for eth2' {
  # Debian/Ubuntu specific tests
  if [[ "$platform_family" == 'debian' ]]; then
    [ -f /etc/network/interfaces.d/eth2 ]
  fi

  # CentOS specific tests
  if [[ "$platform_family" == 'rhel' ]]; then
    [ -f /etc/sysconfig/network-scripts/ifcfg-eth2 ]
  fi
}
