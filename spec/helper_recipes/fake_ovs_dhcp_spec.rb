require 'spec_helper'

describe 'fake::ovs_dhcp' do
  context 'when platform_family rhel 6.x' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'redhat', version: '6.5',
                               step_into: ['rhel_network_interface',
                                           'network_interface'])
                          .converge(described_recipe)
    end

    let(:default_ovsbr0_config_contents) do
      '# This file maintained by Chef.  DO NOT EDIT!

DEVICE="ovsbr0"
TYPE="OVSBridge"
ONBOOT="yes"
BOOTPROTO="none"
NM_CONTROLLED="no"
IPV6INIT="no"
USERCTL="no"
DEVICETYPE="ovs"
ARPCHECK="no"
HOTPLUG="no"
OVSBOOTPROTO="dhcp"
OVSDHCPINTERFACES="eth5"
'
    end

    let(:default_eth5_config_contents) do
      '# This file maintained by Chef.  DO NOT EDIT!

DEVICE="eth5"
TYPE="OVSPort"
ONBOOT="yes"
BOOTPROTO="none"
NM_CONTROLLED="no"
IPV6INIT="no"
DEVICETYPE="ovs"
OVS_BRIDGE="ovsbr0"
'
    end

    let(:default_ovsbr1_config_contents) do
      '# This file maintained by Chef.  DO NOT EDIT!

DEVICE="ovsbr1"
TYPE="OVSBridge"
ONBOOT="yes"
BOOTPROTO="none"
NM_CONTROLLED="no"
IPV6INIT="no"
USERCTL="no"
DEVICETYPE="ovs"
ARPCHECK="no"
HOTPLUG="no"
OVSBOOTPROTO="dhcp"
OVSDHCPINTERFACES="eth6"
'
    end

    let(:default_eth6_config_contents) do
      '# This file maintained by Chef.  DO NOT EDIT!

DEVICE="eth6"
TYPE="OVSPort"
ONBOOT="yes"
BOOTPROTO="none"
NM_CONTROLLED="no"
IPV6INIT="no"
DEVICETYPE="ovs"
OVS_BRIDGE="ovsbr1"
'
    end

    it 'does not install any extra packages' do
      expect(chef_run).not_to install_package 'vconfig'
      expect(chef_run).not_to install_package 'iputils'
      expect(chef_run).not_to install_package 'bridge-utils'
    end

    context 'for interface ovsbr0 definition' do
      it 'creates the bridge' do
        expect(chef_run).to create_network_interface 'ovsbr0'
        expect(chef_run).to create_template(
          '/etc/sysconfig/network-scripts/ifcfg-ovsbr0')
        expect(chef_run).to render_file(
          '/etc/sysconfig/network-scripts/ifcfg-ovsbr0')
          .with_content(default_ovsbr0_config_contents)
      end

      it 'does not reload interface by default' do
        expect(chef_run).not_to run_execute('reload interface ovsbr0')
      end

      it 'it reloads the interface after updating the config' do
        resource = chef_run.template(
          '/etc/sysconfig/network-scripts/ifcfg-ovsbr0')
        expect(resource).to notify('execute[reload interface ovsbr0]')
          .to(:run).immediately
      end

      it 'does not run post up by default' do
        expect(chef_run).not_to run_execute('post up command for ovsbr0')
      end

      it 'does not run post up command after updating config' do
        resource = chef_run.template(
          '/etc/sysconfig/network-scripts/ifcfg-ovsbr0')
        expect(resource).not_to notify('execute[post up command for ovsbr0]')
          .to(:run).immediately
      end
    end

    context 'for interface eth5 definition' do
      it 'adds the device to the bridge' do
        expect(chef_run).to create_network_interface 'eth5'
        expect(chef_run).to create_template(
          '/etc/sysconfig/network-scripts/ifcfg-eth5')
        expect(chef_run).to render_file(
          '/etc/sysconfig/network-scripts/ifcfg-eth5')
          .with_content(default_eth5_config_contents)
      end

      it 'does not reload interface by default' do
        expect(chef_run).not_to run_execute('reload interface eth5')
      end

      it 'it reloads the interface after updating the config' do
        resource = chef_run.template(
          '/etc/sysconfig/network-scripts/ifcfg-eth5')
        expect(resource).to notify('execute[reload interface eth5]')
          .to(:run).immediately
      end

      it 'does not run post up by default' do
        expect(chef_run).not_to run_execute('post up command for eth5')
      end

      it 'does not run post up command after updating config' do
        resource = chef_run.template(
          '/etc/sysconfig/network-scripts/ifcfg-eth5')
        expect(resource).not_to notify('execute[post up command for eth5]')
          .to(:run).immediately
      end
    end

    context 'for interface ovsbr1 definition' do
      it 'creates the bridge' do
        expect(chef_run).to create_network_interface 'ovsbr1'
        expect(chef_run).to create_template(
          '/etc/sysconfig/network-scripts/ifcfg-ovsbr1')
        expect(chef_run).to render_file(
          '/etc/sysconfig/network-scripts/ifcfg-ovsbr1')
          .with_content(default_ovsbr1_config_contents)
      end

      it 'does not reload interface by default' do
        expect(chef_run).not_to run_execute('reload interface ovsbr1')
      end

      it 'it reloads the interface after updating the config' do
        resource = chef_run.template(
          '/etc/sysconfig/network-scripts/ifcfg-ovsbr1')
        expect(resource).to notify('execute[reload interface ovsbr1]')
          .to(:run).immediately
      end

      it 'does not run post up by default' do
        expect(chef_run).not_to run_execute('post up command for ovsbr1')
      end

      it 'does not run post up command after updating config' do
        resource = chef_run.template(
          '/etc/sysconfig/network-scripts/ifcfg-ovsbr1')
        expect(resource).not_to notify('execute[post up command for ovsbr1]')
          .to(:run).immediately
      end
    end

    context 'for interface eth6 definition' do
      it 'adds the device to the bridge' do
        expect(chef_run).to create_network_interface 'eth6'
        expect(chef_run).to create_template(
          '/etc/sysconfig/network-scripts/ifcfg-eth6')
        expect(chef_run).to render_file(
          '/etc/sysconfig/network-scripts/ifcfg-eth6')
          .with_content(default_eth6_config_contents)
      end

      it 'does not reload interface by default' do
        expect(chef_run).not_to run_execute('reload interface eth6')
      end

      it 'it reloads the interface after updating the config' do
        resource = chef_run.template(
          '/etc/sysconfig/network-scripts/ifcfg-eth6')
        expect(resource).to notify('execute[reload interface eth6]')
          .to(:run).immediately
      end

      it 'does not run post up by default' do
        expect(chef_run).not_to run_execute('post up command for eth6')
      end

      it 'does not run post up command after updating config' do
        resource = chef_run.template(
          '/etc/sysconfig/network-scripts/ifcfg-eth6')
        expect(resource).not_to notify('execute[post up command for eth6]')
          .to(:run).immediately
      end
    end
  end

  context 'when platform_family rhel 7.x' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'redhat', version: '7.0',
                               step_into: ['rhel_network_interface',
                                           'network_interface'])
                          .converge(described_recipe)
    end

    let(:default_ovsbr0_config_contents) do
      '# This file maintained by Chef.  DO NOT EDIT!

DEVICE="ovsbr0"
TYPE="OVSBridge"
ONBOOT="yes"
BOOTPROTO="none"
NM_CONTROLLED="no"
IPV6INIT="no"
USERCTL="no"
DEVICETYPE="ovs"
ARPCHECK="no"
HOTPLUG="no"
OVSBOOTPROTO="dhcp"
OVSDHCPINTERFACES="enp0s5"
'
    end

    let(:default_enp0s5_config_contents) do
      '# This file maintained by Chef.  DO NOT EDIT!

DEVICE="enp0s5"
TYPE="OVSPort"
ONBOOT="yes"
BOOTPROTO="none"
NM_CONTROLLED="no"
IPV6INIT="no"
DEVICETYPE="ovs"
OVS_BRIDGE="ovsbr0"
'
    end
    let(:default_ovsbr1_config_contents) do
      '# This file maintained by Chef.  DO NOT EDIT!

DEVICE="ovsbr1"
TYPE="OVSBridge"
ONBOOT="yes"
BOOTPROTO="none"
NM_CONTROLLED="no"
IPV6INIT="no"
USERCTL="no"
DEVICETYPE="ovs"
ARPCHECK="no"
HOTPLUG="no"
OVSBOOTPROTO="dhcp"
OVSDHCPINTERFACES="enp0s6"
'
    end

    let(:default_enp0s6_config_contents) do
      '# This file maintained by Chef.  DO NOT EDIT!

DEVICE="enp0s6"
TYPE="OVSPort"
ONBOOT="yes"
BOOTPROTO="none"
NM_CONTROLLED="no"
IPV6INIT="no"
DEVICETYPE="ovs"
OVS_BRIDGE="ovsbr1"
'
    end

    context 'for interface ovsbr0 definition' do
      it 'creates the bridge' do
        expect(chef_run).to create_network_interface 'ovsbr0'
        expect(chef_run).to create_template(
          '/etc/sysconfig/network-scripts/ifcfg-ovsbr0')
        expect(chef_run).to render_file(
          '/etc/sysconfig/network-scripts/ifcfg-ovsbr0')
          .with_content(default_ovsbr0_config_contents)
      end

      it 'does not reload interface by default' do
        expect(chef_run).not_to run_execute('reload interface ovsbr0')
      end

      it 'it reloads the interface after updating the config' do
        resource = chef_run.template(
          '/etc/sysconfig/network-scripts/ifcfg-ovsbr0')
        expect(resource).to notify('execute[reload interface ovsbr0]')
          .to(:run).immediately
      end

      it 'does not run post up by default' do
        expect(chef_run).not_to run_execute('post up command for ovsbr0')
      end

      it 'does not run post up command after updating config' do
        resource = chef_run.template(
          '/etc/sysconfig/network-scripts/ifcfg-ovsbr0')
        expect(resource).not_to notify('execute[post up command for ovsbr0]')
          .to(:run).immediately
      end
    end

    context 'for interface enp0s5 definition' do
      it 'adds the device to the bridge' do
        expect(chef_run).to create_network_interface 'enp0s5'
        expect(chef_run).to create_template(
          '/etc/sysconfig/network-scripts/ifcfg-enp0s5')
        expect(chef_run).to render_file(
          '/etc/sysconfig/network-scripts/ifcfg-enp0s5')
          .with_content(default_enp0s5_config_contents)
      end

      it 'does not reload interface by default' do
        expect(chef_run).not_to run_execute('reload interface enp0s5')
      end

      it 'it reloads the interface after updating the config' do
        resource = chef_run.template(
          '/etc/sysconfig/network-scripts/ifcfg-enp0s5')
        expect(resource).to notify('execute[reload interface enp0s5]')
          .to(:run).immediately
      end

      it 'does not run post up by default' do
        expect(chef_run).not_to run_execute('post up command for enp0s5')
      end

      it 'does not run post up command after updating config' do
        resource = chef_run.template(
          '/etc/sysconfig/network-scripts/ifcfg-enp0s5')
        expect(resource).not_to notify('execute[post up command for enp0s5]')
          .to(:run).immediately
      end
    end

    context 'for interface ovsbr1 definition' do
      it 'creates the bridge' do
        expect(chef_run).to create_network_interface 'ovsbr1'
        expect(chef_run).to create_template(
          '/etc/sysconfig/network-scripts/ifcfg-ovsbr1')
        expect(chef_run).to render_file(
          '/etc/sysconfig/network-scripts/ifcfg-ovsbr1')
          .with_content(default_ovsbr1_config_contents)
      end

      it 'does not reload interface by default' do
        expect(chef_run).not_to run_execute('reload interface ovsbr1')
      end

      it 'it reloads the interface after updating the config' do
        resource = chef_run.template(
          '/etc/sysconfig/network-scripts/ifcfg-ovsbr1')
        expect(resource).to notify('execute[reload interface ovsbr1]')
          .to(:run).immediately
      end

      it 'does not run post up by default' do
        expect(chef_run).not_to run_execute('post up command for ovsbr1')
      end

      it 'does not run post up command after updating config' do
        resource = chef_run.template(
          '/etc/sysconfig/network-scripts/ifcfg-ovsbr1')
        expect(resource).not_to notify('execute[post up command for ovsbr1]')
          .to(:run).immediately
      end
    end

    context 'for interface enp0s6 definition' do
      it 'adds the device to the bridge' do
        expect(chef_run).to create_network_interface 'enp0s6'
        expect(chef_run).to create_template(
          '/etc/sysconfig/network-scripts/ifcfg-enp0s6')
        expect(chef_run).to render_file(
          '/etc/sysconfig/network-scripts/ifcfg-enp0s6')
          .with_content(default_enp0s6_config_contents)
      end

      it 'does not reload interface by default' do
        expect(chef_run).not_to run_execute('reload interface enp0s6')
      end

      it 'it reloads the interface after updating the config' do
        resource = chef_run.template(
          '/etc/sysconfig/network-scripts/ifcfg-enp0s6')
        expect(resource).to notify('execute[reload interface enp0s6]')
          .to(:run).immediately
      end

      it 'does not run post up by default' do
        expect(chef_run).not_to run_execute('post up command for enp0s6')
      end

      it 'does not run post up command after updating config' do
        resource = chef_run.template(
          '/etc/sysconfig/network-scripts/ifcfg-enp0s6')
        expect(resource).not_to notify('execute[post up command for enp0s6]')
          .to(:run).immediately
      end
    end
  end
end
