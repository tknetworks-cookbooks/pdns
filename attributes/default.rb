default['pdns']['db_host'] = "127.0.0.1"
default['pdns']['db_user'] = "pdns"
default['pdns']['db_name'] = "pdns"
default['pdns']['db_password'] = ""
default['pdns']['axfr_ips'] = []
default['pdns']['launch'] = "gpgsql"
default['pdns']['bind_inet'] = ""
default['pdns']['bind_inet6'] = ""
default['pdns']['home_dir'] = "/home/pdns"

case platform
when "debian"
  default['pdns']['package'] = "pdns-static"
  default['pdns']['dir'] = "/etc/powerdns"
  default['pdns']['deb_version'] = "3.3-1"
  default['pdns']['deb_baseurl'] = "http://downloads.powerdns.com/releases/deb"
end
