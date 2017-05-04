require 'spec_helper'

describe 'fake::core' do
  context 'when platform_family rhel 6.x' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'redhat', version: '6.5', step_into: ['rhel_network_interface', 'network_interface']).converge(described_recipe)
    end

    let(:default_eth0_config_contents) do
      '# This file maintained by Chef.  DO NOT EDIT!

DEVICE="eth0"
TYPE="Ethernet"
ONBOOT="yes"
BOOTPROTO="dhcp"
NM_CONTROLLED="no"
'
    end

    let(:default_eth4_config_contents) do
      '# This file maintained by Chef.  DO NOT EDIT!

DEVICE="eth4"
TYPE="OVSBridge"
ONBOOT="yes"
BOOTPROTO="none"
IPADDR="10.12.10.11"
PREFIX=24
NETMASK="255.255.255.0"
GATEWAY="10.0.0.1"
NM_CONTROLLED="no"
DEVICETYPE="ovs"
DEFROUTE="no"
'
    end

    it 'does not install any extra packages' do
      expect(chef_run).not_to install_package 'vconfig'
      expect(chef_run).not_to install_package 'iputils'
      expect(chef_run).not_to install_package 'bridge-utils'
    end

    context 'for interface eth0 definition' do
      it 'creates the interface' do
        expect(chef_run).to create_network_interface 'eth0'
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

    context 'for interface eth4 definition' do
      it 'creates the interface' do
        expect(chef_run).to create_network_interface 'eth4'
        expect(chef_run).to create_template '/etc/sysconfig/network-scripts/ifcfg-eth4'
        expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-eth4').with_content(default_eth4_config_contents)
      end

      it 'does not reload interface by default' do
        expect(chef_run).not_to run_execute('reload interface eth4')
      end

      it 'it reloads the interface after updating the config' do
        resource = chef_run.template('/etc/sysconfig/network-scripts/ifcfg-eth4')
        expect(resource).to notify('execute[reload interface eth4]').to(:run).immediately
      end

      it 'does not run post up by default' do
        resource = chef_run.execute('post up command for eth4')
        expect(resource.command).to eq 'sleep 1'
        expect(chef_run).not_to run_execute('post up command for eth4')
      end

      it 'runs post up command after updating config' do
        resource = chef_run.template('/etc/sysconfig/network-scripts/ifcfg-eth4')
        expect(resource).to notify('execute[post up command for eth4]').to(:run).immediately
      end
    end
  end

  context 'when platform_family rhel 7.x' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'redhat', version: '7.0', step_into: ['rhel_network_interface', 'network_interface']).converge(described_recipe)
    end

    let(:default_enp0s4_config_contents) do
      '# This file maintained by Chef.  DO NOT EDIT!

DEVICE="enp0s4"
TYPE="OVSBridge"
ONBOOT="yes"
BOOTPROTO="none"
IPADDR="10.12.10.11"
PREFIX=24
NETMASK="255.255.255.0"
GATEWAY="10.0.0.1"
NM_CONTROLLED="no"
DEVICETYPE="ovs"
ZONE="trusted"
ARPCHECK="yes"
HOTPLUG="no"
'
    end

    context 'for interface enp0s4 definition' do
      it 'configures firewalld zone' do
        expect(chef_run).to create_network_interface 'enp0s4'
        expect(chef_run).to create_template '/etc/sysconfig/network-scripts/ifcfg-enp0s4'
        expect(chef_run).to render_file('/etc/sysconfig/network-scripts/ifcfg-enp0s4').with_content(default_enp0s4_config_contents)
      end
    end
  end

  context 'debian family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04', step_into: ['debian_network_interface', 'network_interface']).converge(described_recipe)
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

    it 'creates interface eth4' do
      expect(chef_run).to create_network_interface 'eth4'
    end
  end

  describe 'windows family' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'windows', version: '2012R2') do |node|
        node.automatic['network']['interfaces'] = {
          '0xc' => {
            'addresses' => {
              '10.0.2.15' => {
                'prefixlen' => '24',
                'netmask' => '255.255.255.0',
                'broadcast' => '10.0.2.255',
                'family' => 'inet',
              },
              'fe80::e488:b85c:5262:ff86' => {
                'prefixlen' => '64',
                'family' => 'inet6',
                'scope' => 'Link',
              },
              '00:25:B5:5B:00:33' => {
                'family' => 'lladdr',
              },
            },
            'configuration' => {
              'arp_always_source_route' => nil,
              'arp_use_ether_snap' => nil,
              'caption' => '[00000010] Intel(R) PRO/1000 MT Desktop Adapter',
              'database_path' => '%SystemRoot%\System32\drivers\etc',
              'dead_gw_detect_enabled' => nil,
              'default_ip_gateway' => [
                '10.0.2.2',
              ],
              'default_tos' => nil,
              'default_ttl' => nil,
              'description' => 'Intel(R) PRO/1000 MT Desktop Adapter',
              'dhcp_enabled' => true,
              'dhcp_lease_expires' => '20151015214803.000000-420',
              'dhcp_lease_obtained' => '20151014214803.000000-420',
              'dhcp_server' => '10.0.2.2',
              'dns_domain' => 'target.com',
              'dns_domain_suffix_search_order' => [
                'test.it.com',
                'target.com',
              ],
              'dns_enabled_for_wins_resolution' => false,
              'dns_host_name' => 'vagrant-2012-r2',
              'dns_server_search_order' => [
                '10.97.40.216',
                '10.64.40.216',
              ],
              'domain_dns_registration_enabled' => false,
              'forward_buffer_memory' => nil,
              'full_dns_registration_enabled' => true,
              'gateway_cost_metric' => [
                0,
              ],
              'igmp_level' => nil,
              'index' => 10,
              'interface_index' => 12,
              'ip_address' => [
                '10.0.2.15',
                'fe80:e488:b85c:5262:ff86',
              ],
              'ip_connection_metric' => 10,
              'ip_enabled' => true,
              'ip_filter_security_enabled' => false,
              'ip_port_security_enabled' => nil,
              'ip_sec_permit_ip_protocols' => [

              ],
              'ip_sec_permit_tcp_ports' => [

              ],
              'ip_sec_permit_udp_ports' => [

              ],
              'ip_subnet' => [
                '255.255.255.0',
                '64',
              ],
              'ip_use_zero_broadcast' => nil,
              'ipx_address' => nil,
              'ipx_enabled' => nil,
              'ipx_frame_type' => nil,
              'ipx_media_type' => nil,
              'ipx_network_number' => nil,
              'ipx_virtual_net_number' => nil,
              'keep_alive_interval' => nil,
              'keep_alive_time' => nil,
              'mac_address' => '08:00:27:D5:9D:5A',
              'mtu' => nil,
              'num_forward_packets' => nil,
              'pmtubh_detect_enabled' => nil,
              'pmtu_discovery_enabled' => nil,
              'service_name' => 'E1G60',
              'setting_id' => '{DD72B02C-4E48-4924-8D0F-F80EA2755534}',
              'tcpip_netbios_options' => 0,
              'tcp_max_connect_retransmissions' => nil,
              'tcp_max_data_retransmissions' => nil,
              'tcp_num_connections' => nil,
              'tcp_use_rfc1122_urgent_pointer' => nil,
              'tcp_window_size' => 64240,
              'wins_enable_lm_hosts_lookup' => true,
              'wins_host_lookup_file' => nil,
              'wins_primary_server' => nil,
              'wins_scope_id' => '',
              'wins_secondary_server' => nil,
            },
            'instance' => {
              'index' => 10,
              'interface_index' => 12,
              'net_connection_id' => 'Ethernet 4',
            },
          },
        }
      end.converge(described_recipe)
    end

    it 'creates interface eth2' do
      expect(chef_run).to create_win_network_interface 'eth2'
    end
  end

  context 'when platform_family debian 6.x' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04', step_into: ['debian_network_interface', 'network_interface']).converge(described_recipe)
    end

    let(:default_eth4_config_contents) do
      '# This file maintained by Chef.  DO NOT EDIT!

auto eth4
iface eth4 inet static
  address 10.12.10.11
  netmask 255.255.255.0
  gateway 10.0.0.1
  pre-up sleep 2
  post-up sleep 1
'
    end

    context 'for interface eth4 definition' do
      it 'creates the interface' do
        expect(chef_run).to create_network_interface 'eth4'
        expect(chef_run).to create_template '/etc/network/interfaces.d/eth4'
        expect(chef_run).to render_file('/etc/network/interfaces.d/eth4').with_content(default_eth4_config_contents)
      end
    end
  end
end
