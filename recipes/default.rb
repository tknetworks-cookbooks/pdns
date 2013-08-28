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

# you must load postgresql recipe via run_list before this recipe
# include_recipe "postgresql::server"

pdns_deb_file = "#{node['pdns']['package']}_#{node['pdns']['deb_version']}_#{node['debian']['arch']}.deb"
pdns_deb = "#{node['debian']['deb_archive']}/#{pdns_deb_file}"

e = remote_file pdns_deb do
  source "#{node['pdns']['deb_baseurl']}/#{pdns_deb_file}"
  backup false
  mode 0600
  not_if do
    ::File.exists?(pdns_deb)
  end
end
e.run_action(:create_if_missing)

d = dpkg_package node['pdns']['package'] do
  source pdns_deb
  action :install
end
d.run_action(:install)

o = ohai "pdns-ohai-reload" do
  action :reload
  plugin "passwd"
end

u = user "pdns" do
  action :create
  system true
  manage_home true
  home node['pdns']['home_dir']
  notifies :reload, "ohai[pdns-ohai-reload]", :immediately
end
u.run_action(:create)

if u.updated_by_last_action?
  o.run_action(:reload)
end

directory node['etc']['passwd']['pdns']['dir'] do
  owner "pdns"
  group "pdns"
  mode 0700
end

node.set['postgresql']['pg_hba'] = [
  {:comment => '# pdns-local',
   :type    => 'local',
   :db      => 'pdns',
   :user    => 'pdns',
   :method  => 'ident'},
  {:comment => '# pdns-loopback',
   :type    => 'host',
   :db      => 'pdns',
   :addr    => '127.0.0.1/32',
   :user    => 'pdns',
   :method  => 'md5'}
] + node['postgresql']['pg_hba']

template "#{node['pdns']['dir']}/pdns.conf" do
  source "pdns.conf.erb"
  owner  "root"
  group  "pdns"
  mode   "0660"
  notifies :restart, "service[pdns]"
end

sql_files = %W{
  pgsql-pdns.sql
  pgsql-pdns-dnssec.sql
  pgsql-pdns-domains.sql
}

sql_files.each do |sql|
  cookbook_file "#{node['pdns']['dir']}/#{sql}" do
    source sql
    owner "pdns"
    group "pdns"
    mode  0600
  end
end

# createuser
createuser "pdns" do
  password node['pdns']['db_password']
end

# createdb
createdb "pdns"

# create table
bash "pdns-init-database" do
  user "pdns"
  code <<-EOC
cat #{node['pdns']['dir']}/{#{sql_files.join(",")}} | psql pdns
EOC
  only_if "[ `su pdns -c \"echo '\\d' | psql -A -t -U pdns pdns | wc -l\"` = \"1\" ]"
end

service "pdns" do
  action [:enable, :start]
end
