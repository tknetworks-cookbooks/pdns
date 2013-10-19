name             "pdns_test"
maintainer       "TANABE Ken-ichi"
maintainer_email "nabeken@tknetworks.org"
license          "Apache 2.0"
description      "Test parent, pdns cookbook"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

%w{pdns}.each do |c|
  depends c
end
