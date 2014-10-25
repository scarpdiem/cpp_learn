
mysql -u root --default-character-set=utf8 --database=test -e"drop table if exists test_mysql2csv; create table test_mysql2csv(id bigint primary key, message varchar(1024))engine=Innodb, charset=utf8"

./csv2mysql --input=input.csv --database=test --user=root --password="" --host=127.0.0.1 --port=3306 --execute="insert into test_mysql2csv set id=?id, message=?message"

./mysql2csv --output=output.csv --database=test --user=root --password="" --host=127.0.0.1 --port=3306 --execute="select * from test_mysql2csv"

