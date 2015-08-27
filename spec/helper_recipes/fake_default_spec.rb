require 'spec_helper'

describe 'fake::default' do
  context 'when platform_family rhel' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'redhat', version: '6.5', step_into: ['rhel_network_interface']).converge(described_recipe)
    end

    let(:default_eth0_config_contents) do
      '# This file maintained by Chef.  DO NOT EDIT!

DEVICE="eth0"
TYPE="Ethernet"
ONBOOT="yes"
BOOTPROTO="dhcp"
NM_CONTROLLED="off"
'
    end

    let(:default_eth1_config_contents) do
      '# This file maintained by Chef.  DO NOT EDIT!

DEVICE="eth1"
TYPE="OVSBridge"
ONBOOT="yes"
BOOTPROTO="none"
IPADDR="10.12.10.11"
PREFIX=24
NETMASK="255.255.255.0"
GATEWAY="10.0.0.1"
DNS1="14.13.13.13"
DNS2="14.13.13.12"
NM_CONTROLLED="off"
DEVICETYPE="ovs"
'
    end

    let(:default_eth2_config_contents) do
      '# This file maintained by Chef.  DO NOT EDIT!

DEVICE="eth2"
TYPE="Ethernet"
ONBOOT="yes"
BOOTPROTO="dhcp"
NM_CONTROLLED="off"
'
    end

    it 'does not install any extra packages' do
      expect(chef_run).not_to install_package 'vconfig'
      expect(chef_run).not_to install_package 'iputils'
      expect(chef_run).not_to install_package 'bridge-utils'
    end

    context 'for interface eth0 definition' do
      it 'creates the interface' do
        expect(chef_run).to create_rhel_network_interface 'eth0'
        expect(chef_run).to create_template '/etc/sysconfig/network-scripts/ifcfg-eth0'
        expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth0').with_content(default_eth0_config_contents)
      end

      it 'does not reload interface by default' do
        expect(chef_run).not_to run_execute('reload interface eth0')
      end

      it 'it reloads the interface after updating the config' do
        resource = chef_run.template('/etc/sysconfig/network-scripts/ifcfg-eth0')
        expect(resource).to notify('execute[reload interface eth0]').to(:run).immediately
      end

      it 'does not run post up by default' do
        expect(chef_run).not_to run_execute('post up command for eth0')
      end

      it 'does not run post up command after updating config' do
        resource = chef_run.template('/etc/sysconfig/network-scripts/ifcfg-eth0')
        expect(resource).not_to notify('execute[post up command for eth0]').to(:run).immediately
      end
    end

    context 'for interface eth1 definition' do
      it 'creates the interface' do
        expect(chef_run).to create_rhel_network_interface 'eth1'
        expect(chef_run).to create_template '/etc/sysconfig/network-scripts/ifcfg-eth1'
        expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth1').with_content(default_eth1_config_contents)
      end

      it 'does not reload interface by default' do
        expect(chef_run).not_to run_execute('reload interface eth1')
      end

      it 'it reloads the interface after updating the config' do
        resource = chef_run.template('/etc/sysconfig/network-scripts/ifcfg-eth1')
        expect(resource).to notify('execute[reload interface eth1]').to(:run).immediately
      end

      it 'does not run post up by default' do
        resource = chef_run.execute('post up command for eth1')
        expect(resource.command).to eq 'sleep 1'
        expect(chef_run).not_to run_execute('post up command for eth1')
      end

      it 'runs post up command after updating config' do
        resource = chef_run.template('/etc/sysconfig/network-scripts/ifcfg-eth1')
        expect(resource).to notify('execute[post up command for eth1]').to(:run).immediately
      end
    end

    context 'for interface eth2 definition' do
      it 'creates the interface' do
        expect(chef_run).to create_rhel_network_interface 'eth2'
        expect(chef_run).to create_template '/etc/sysconfig/network-scripts/ifcfg-eth2'
        expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth2').with_content(default_eth2_config_contents)
      end

      it 'does not reload interface by default' do
        expect(chef_run).not_to run_execute('reload interface eth2')
      end

      it 'it reloads the interface after updating the config' do
        resource = chef_run.template('/etc/sysconfig/network-scripts/ifcfg-eth2')
        expect(resource).to notify('execute[reload interface eth2]').to(:run).immediately
      end

      it 'does not run post up by default' do
        expect(chef_run).not_to run_execute('post up command for eth2')
      end

      it 'does not run post up command after updating config' do
        resource = chef_run.template('/etc/sysconfig/network-scripts/ifcfg-eth2')
        expect(resource).not_to notify('execute[post up command for eth2]').to(:run).immediately
      end
    end
  end

  describe 'debian family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.10', step_into: ['debian_network_interface']).converge(described_recipe)
    end

    let(:default_config_contents) do
      '# This file maintained by Chef.  DO NOT EDIT!

auto eth2
iface eth2 inet dhcp
'
    end

    it 'creates directory for interface config files' do
      expect(chef_run).to create_directory '/etc/network/interfaces.d'
    end

    it 'replaces main network config file to reference interface configs' do
      expect(chef_run).to create_cookbook_file '/etc/network/interfaces'
    end

    it 'does not install any extra packages' do
      expect(chef_run).not_to install_package 'vlan'
      expect(chef_run).not_to install_package 'ifenslave-2.6'
      expect(chef_run).not_to install_package 'ifmetric'
      expect(chef_run).not_to install_package 'bridge-utils'
    end

    it 'does not load any modules' do
      expect(chef_run).not_to save_modules '8021q'
      expect(chef_run).not_to save_modules 'bonding'
    end

    it 'creates interface eth1' do
      expect(chef_run).to create_debian_network_interface 'eth1'
    end

    it 'creates interface eth2' do
      expect(chef_run).to create_debian_network_interface 'eth2'
      expect(chef_run).to create_template '/etc/network/interfaces.d/eth2'
      expect(chef_run).to render_file('/etc/network/interfaces.d/eth2').with_content(default_config_contents)
    end

    it 'does not reload interface by default' do
      expect(chef_run).not_to run_execute('reload interface eth2')
    end

    it 'it reloads eth2 interface after deploying config' do
      resource = chef_run.template('/etc/network/interfaces.d/eth2')
      expect(resource).to notify('execute[reload interface eth2]').to(:run).immediately
    end
  end

  describe 'windows family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'windows', version: '2012R2').converge(described_recipe)
    end

    it 'creates interface eth1' do
      expect(chef_run).to create_win_network_interface 'eth1'
    end

    it 'creates interface eth2' do
      expect(chef_run).to create_win_network_interface 'eth2'
    end
  end
end
