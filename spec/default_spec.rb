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
require 'spec_helper'

describe 'pdns::default' do

  include_context 'debian'

  let (:sqls) {
    %w{
      pgsql-pdns
      pgsql-pdns-dnssec
      pgsql-pdns-domains
    }
  }

  it 'should create directory' do
    chef_run.converge('pdns::default')
    expect(chef_run).to create_directory('/home/pdns')
  end

  it 'should create pdns.conf' do
    chef_run.converge('pdns::default')
    expect(chef_run).to create_file_with_content "#{chef_run.node['pdns']['dir']}/pdns.conf", 'launch=gpgsql'
  end

  it 'should put sqls' do
    chef_run.converge('pdns::default')
    sqls.each do |sql|
      expect(chef_run).to create_file "#{chef_run.node['pdns']['dir']}/#{sql}.sql"
    end
  end

  it 'should enable/start service' do
    chef_run.converge('pdns::default')
    expect(chef_run).to set_service_to_start_on_boot 'pdns'
    expect(chef_run).to start_service 'pdns'
  end

  it 'should initialize database' do
    chef_run_guards.stub_command("[ `su pdns -c \"echo '\\d' | psql -A -t -U pdns pdns | wc -l\"` = \"1\" ]", true)
    chef_run_guards.stub_command(/su/, true)
    chef_run_guards.converge('pdns::default')
    expect(chef_run_guards).to execute_bash_script('pdns-init-database').with(
      :user => 'pdns',
      :code => /^cat .* \| psql pdns$/
    )
  end

  it 'should not initialize database' do
    chef_run_guards.stub_command("[ `su pdns -c \"echo '\\d' | psql -A -t -U pdns pdns | wc -l\"` = \"1\" ]", false)
    chef_run_guards.stub_command(/su/, true)
    chef_run_guards.converge('pdns::default')
    expect(chef_run_guards).not_to execute_bash_script 'pdns-init-database'
  end
end
