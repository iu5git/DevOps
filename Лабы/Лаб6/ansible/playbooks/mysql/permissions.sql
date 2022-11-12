CREATE USER 'test_user'@'%' IDENTIFIED BY 'password';
GRANT ALL ON testdb.* to 'test_user'@'%' ;