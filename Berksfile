site :opscode

metadata
cookbook "postgresql", git: "git://github.com/tknetworks-cookbooks/postgresql.git"
cookbook "debian", git: "git://github.com/tknetworks-cookbooks/debian.git"

group :integration do
  cookbook 'minitest-handler'
end
