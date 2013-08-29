#
# Author:: Ken-ichi TANABE (<nabeken@tknetworks.org>)
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
require 'chefspec'

shared_context 'debian' do
  def set_node(node)
    node.automatic_attrs['platform'] = 'debian'
    node.automatic_attrs['kernel']['machine'] = 'x86_64'
    node.automatic_attrs['etc']['passwd']['pdns']['dir'] = '/home/pdns'
    node.automatic_attrs['pdns']['db_password'] = 'pdns'
    node.automatic_attrs['pdns']['backup']['repository'] = 'git@example.org:pdns-backup.git'
    node.automatic_attrs['pdns']['backup']['mailto'] = 'hostmaster@example.org'
  end

  let (:chef_run) {
    ChefSpec::ChefRunner.new() do |node|
      set_node(node)
    end
  }

  let (:chef_run_guards) {
    ChefSpec::ChefRunner.new({:evaluate_guards => true}) do |node|
      set_node(node)
    end
  }
end
