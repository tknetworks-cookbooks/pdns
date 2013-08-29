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

describe 'pdns::backup' do
  include_context 'debian'

  before do
    Chef::EncryptedDataBagItem.stub(:load).with('ssh_keys', 'pdns-backup').and_return({
      'key' => 'SSH_KEY'
    })
    chef_run.converge('pdns::backup')
  end

  it 'should create .ssh directory' do
    expect(chef_run).to create_directory('/home/pdns/.ssh')
    dir = chef_run.directory('/home/pdns/.ssh')
    expect(dir).to be_owned_by('pdns', 'pdns')
    expect(dir.mode).to eq(0700)
  end

  it 'should set ssh key from databag' do
    key = chef_run.file('/home/pdns/.ssh/id_rsa')
    expect(chef_run).to create_file_with_content key.path, 'SSH_KEY'
    expect(key).to be_owned_by('pdns', 'pdns')
    expect(key.mode).to eq(0600)
  end

  it 'should clone from the backup repository' do
    git = chef_run.git('/home/pdns/pdns-backup')
    expect(git.action).to include(:sync)
    expect(git.reference).to eq('master')
    expect(git.user).to eq('pdns')
    expect(git.group).to eq('pdns')
    expect(git.repository).to eq('git@example.org:pdns-backup.git')
  end

  it 'should create cronjob' do
    cron = chef_run.cron('pdns-backup')
    expect(cron.command).to eq('/home/pdns/pdns-backup/bin/pdns-backup.sh')
    expect(cron.hour).to eq('5')
    expect(cron.minute).to eq('30')
    expect(cron.mailto).to eq('hostmaster@example.org')
    expect(cron.user).to eq('pdns')
  end
end
