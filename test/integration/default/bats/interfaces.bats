#!/usr/bin/env bats

platform_family=$(ohai platform_family | grep '"' | awk -F\" '{print $2}')

@test "eth0 is up" {
  ip addr | grep UP | grep ' eth0:'
}

@test "eth1 is up" {
  ip addr | grep UP | grep ' eth1:'
}

@test "eth2 is up" {
  ip addr | grep UP | grep ' eth2:'
}
