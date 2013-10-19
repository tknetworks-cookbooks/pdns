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

describe_recipe 'pdns_test::default' do
  it 'installs pdns-static' do
    package('pdns-static').must_be_installed
  end

  it 'creates pdns.conf' do
    file('/etc/powerdns/pdns.conf')
    .must_exist
    .must_include('launch=gpgsql')
    .must_include('allow-axfr-ips=192.168.1.200,192.168.1.201')
    .must_include('master=on')
    .must_include('disable-axfr=no')
  end

  it 'starts/enables service' do
    service('pdns').must_be_running
    service('pdns').must_be_enabled
  end

  it 'initializes a database' do
    assert_sh("[ `su pdns -c \"echo '\\d' | psql -A -t -U pdns pdns | wc -l\"` = \"11\" ]")
  end

  it 'setups example.org' do
    expected = {
      'dig +short @127.0.0.1 -t ns example.org | sort' => "ns1.example.org.\nns2.example.org.",
      'dig +short @127.0.0.1 -t a www.example.org' => '192.168.1.100',
      'dig +short @127.0.0.1 -t a ns1.example.org' => '192.168.1.101',
      'dig +short @127.0.0.1 -t a ns2.example.org' => '192.168.1.102',
    }
    expected.each do |cmd, ret|
      assert_sh("[ \"`#{cmd}`\" = \"#{ret}\" ]")
    end
  end
end
