INSERT INTO domains (name, type) VALUES ('example.org', 'NATIVE');

INSERT INTO records (domain_id, ttl, type, name, content)
SELECT id, '60', 'SOA', 'example.org', 'ns1.example.org hostmaster.example.org 2013082700 28800 7200 604800 86400 86400' FROM domains WHERE name = 'example.org';

INSERT INTO records (domain_id, ttl, type, name, content)
SELECT id, '60', 'NS', 'example.org', 'ns1.example.org' FROM domains WHERE name = 'example.org';

INSERT INTO records (domain_id, ttl, type, name, content)
SELECT id, '60', 'NS', 'example.org', 'ns2.example.org' FROM domains WHERE name = 'example.org';

INSERT INTO records (domain_id, ttl, type, name, content)
SELECT id, '60', 'A', 'ns1.example.org', '192.168.1.101' FROM domains WHERE name = 'example.org';

INSERT INTO records (domain_id, ttl, type, name, content)
SELECT id, '60', 'A', 'ns2.example.org', '192.168.1.102' FROM domains WHERE name = 'example.org';

INSERT INTO records (domain_id, ttl, type, name, content)
SELECT id, '60', 'A', 'www.example.org', '192.168.1.100' FROM domains WHERE name = 'example.org';
