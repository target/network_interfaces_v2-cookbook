#
# Author:: Adam Edwards (<adamed@getchef.com>)
#
# Copyright:: 2014, Chef Software, Inc.
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
# @see https://github.com/opscode-cookbooks/windows/blob/master/libraries/wmi_helper.rb
#

if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  require 'win32ole'

  #
  # Executes a WQL query and returns an array of WMI objects
  #
  # @param wmi_query [String]
  #
  # @return [WIN32OLE, nil]
  #
  def execute_wmi_query(wmi_query)
    wmi = ::WIN32OLE.connect('winmgmts://')
    result = wmi.ExecQuery(wmi_query)
    return nil unless result.each.count > 0
    result
  end

  #
  # Get property from WMI object
  #
  # @param wmi_object [??]
  # @param wmi_property [String]
  #
  def wmi_object_property(wmi_object, wmi_property)
    wmi_object.send(wmi_property)
  end
end

#
# Return an array of WMI object from ISWbemObjectSet
#
# @param wmi_object [WIN32OLE] WIN32OLE_TYPE:ISWbemObjectSet
#
# @return [Array]
def wmi_object_array(wmi_object)
  x = []
  wmi_object.each do |o|
    x << o
  end
  x
end
