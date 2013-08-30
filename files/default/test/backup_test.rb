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
require 'minitest/spec'

describe_recipe 'pdns::backup' do
  it 'creates .ssh directory' do
    directory('/home/pdns/.ssh').must_exist.with(:owner, 'pdns').and(:group, 'pdns')
  end

  it 'sets ssh key' do
    key = '/home/pdns/.ssh/id_rsa'
    assert_file key, 'pdns', 'pdns', 0600
    file(key).must_include 'SSH_KEY'
  end

  it 'clones from the backup repository' do
    dump = '/home/pdns/pdns-backup/pdns.sql'
    file(dump).must_include 'PostgreSQL database dump'
  end

  it 'configures pdns-backup repository' do
    %w{email name}.each do |a|
      assert_sh("cd /home/pdns/pdns-backup; git config --get user.#{a}")
    end
  end

  it 'creates cronjob' do
    assert_sh("su - pdns -c 'crontab -l' | grep pdns-backup.sh")
  end
end
