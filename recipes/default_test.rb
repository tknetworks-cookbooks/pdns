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
include_recipe 'pdns'

cookbook_file "/tmp/pgsql-pdns-test.sql" do
  source "pgsql-pdns-test.sql"
end

bash "pdns-insert-test-data" do
  user "pdns"
  code <<-EOC
cat /tmp/pgsql-pdns-test.sql | psql pdns
EOC
  not_if "[ `su pdns -c 'echo \"SELECT count(*) FROM records;\" | psql -A -t -U pdns pdns'` = 9 ]"
end
