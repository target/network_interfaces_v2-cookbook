#!/usr/bin/env bats

platform_family=$(ohai platform_family | grep '"' | awk -F\" '{print $2}')

@test 'created config files for each device' {
  # Debian/Ubuntu specific tests
  if [[ "$platform_family" == 'debian' ]]; then
    [ -f /etc/network/interfaces.d/eth10 ]
    [ -f /etc/network/interfaces.d/eth11 ]
    grep 'lo' /etc/network/interfaces
    grep 'eth10' /etc/network/interfaces
    grep 'eth11' /etc/network/interfaces
  fi

  # CentOS specific tests
  if [[ "$platform_family" == 'rhel' ]]; then
    [ -f /etc/sysconfig/network-scripts/ifcfg-eth10 ]
    [ -f /etc/sysconfig/network-scripts/ifcfg-eth11 ]
  fi
}
