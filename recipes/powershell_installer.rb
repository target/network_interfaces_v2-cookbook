#
# Author:: Diego F. Duarte (<diego.fl.duarte@gmail.com>)
# Cookbook Name:: network_interfaces_v2
# Recipe:: powershell_installer.rb
#
# Copyright:: 2015
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Confirm whether Windows Update Service is enabled (necessary)

windows_service 'wuauserv' do
  startup_type :automatic
  action [:enable, :start]
end

# Looks for powershell version Start the Powershell/WMF 4.0 install

include_recipe 'powershell::powershell4'

reboot 'now' do
  action :reboot_now
  reason 'Cannot continue Chef run without a reboot.'
  delay_mins 2
  retry_delay 2
end
