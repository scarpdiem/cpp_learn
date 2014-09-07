# The mysql2csv and csv2mysql Tools

There are two simple tools here in this directory for exporting and importing Mysql database data using [.csv](http://tools.ietf.org/html/rfc4180) format. The csv format data is rather easy for application to generate and parse. Also, it is very easy to convert .csv file into .xls/.xlsx file or to convert .xls/.xlsx file into .csv file.

- mysql2csv - Export MySQL database data into a csv file
- csv2mysql - Import csv file data into MySQL database



## Compile the Code

Before you compiles the code, if you are using yum, the mysql-devel package should be install, so that the mysql header file mysql/mysql.h and library file libmysqlclient.a or libmysqlclient.so could be found on you system.

Type the following command to comiles the code:

``` shell
g++ mysql2csv.cpp -omysql2csv -g -L/usr/lib64/mysql/  -lmysqlclient
g++ csv2mysql.cpp -ocsv2mysql -g -L/usr/lib64/mysql/  -lmysqlclient
```


## Demo

Create a database and a simple table named "test".

    [roxma@VM_6_207_centos mysql2csv]$ mysql -uroot --password="" --default-character-set=utf8
    ...
    
    mysql> create database csv_test default charset=utf8;
    Query OK, 1 row affected (0.02 sec)
    
    mysql> use csv_test;
    Database changed
    mysql> create table test(id int primary key, value1 varchar(1024))engine=innodb;
    Query OK, 0 rows affected (0.08 sec)
    
    mysql> show create table test \G
    *************************** 1. row ***************************
           Table: test
    Create Table: CREATE TABLE `test` (
      `id` int(11) NOT NULL,
      `value1` varchar(1024) DEFAULT NULL,
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    1 row in set (0.00 sec)
    
    mysql> insert into test (id,value1) values(1,"hello"),(2, 'comma , double quotes " '),(3,NULL);
    Query OK, 3 rows affected (0.00 sec)
    Records: 3  Duplicates: 0  Warnings: 0
    
    mysql> select * from test;
    +----+--------------------------+
    | id | value1                   |
    +----+--------------------------+
    |  1 | hello                    |
    |  2 | comma , double quotes "  |
    |  3 | NULL                     |
    +----+--------------------------+
    3 rows in set (0.00 sec)


Export the table into csv file:

    [roxma@VM_6_207_centos mysql2csv]$ ./mysql2csv host="127.0.0.1" port="3306"  db="csv_test" user="root" passwd="" charset="utf8" execute="select * from test" > data.csv
    host=127.0.0.1
    port=3306
    db=csv_test
    user=root
    passwd=
    charset=utf8
    execute=select * from test
    
    [roxma@VM_6_207_centos mysql2csv]$ cat data.csv
    id,value1
    1,hello
    2,"comma , double quotes "" "
    3,NULL

Import the data from csv file into Mysql database:

    [roxma@VM_6_207_centos mysql2csv]$ ./csv2mysql host="127.0.0.1" port="3306" db="csv_test" user="root" passwd="" charset="utf8" execute="insert into test set id=?id+3, value1=?value1" input="data.csv"
    host=127.0.0.1
    port=3306
    db=csv_test
    user=root
    passwd=
    charset=utf8
    execute=insert into test set id=?id+3, value1=?value1
    input=data.csv
    3 rows executed.

    [roxma@VM_6_207_centos mysql2csv]$ mysql -uroot --password="" --default-character-set=utf8 --database="csv_test"  -e"select * from test"
    +----+--------------------------+
    | id | value1                   |
    +----+--------------------------+
    |  1 | hello                    |
    |  2 | comma , double quotes "  |
    |  3 | NULL                     |
    |  4 | hello                    |
    |  5 | comma , double quotes "  |
    |  6 | NULL                     |
    +----+--------------------------+



## Supported Options

<table>
    <thread>
        <tr>
            <th>Option</th> <th>Description</th> <th>Default</th>
        </tr>
    </thread>
    
    <thread>
        <tr>
            <th colspan="3">Common Options</th>
        </tr>
    </thread>
    
    <tbody>
        <tr>
            <td>host</td> <td>The host name for MySQL server</td> <td>127.0.0.1</td>
        </tr>
        <tr>
            <td>port</td> <td>The destination port for MySQL connection</td> <td>3306</td>
        </tr>
        <tr>
            <td>user</td> <td>MySQL user name</td> <td>root</td>
        </tr>
        <tr>
            <td>passwd</td> <td>The password of the MySQL user</td> <td></td>
        </tr>
        <tr>
            <td>charset</td> <td>The character set of the MySQL connection</td> <td>utf8</td>
        </tr>
        <tr>
            <td>db</td> <td>The database to use</td> <td></td>
        </tr>
    </tbody>

    <thread>
        <tr>
            <th colspan="3">mysql2csv Specific</th>
        </tr>
    </thread>
    <tbody>
        <tr>
            <td>execute</td> <td>The query statement</td> <td></td>
        </tr>
        <tr>
            <td>null_cell_value</td> <td>The string to be used when the value of a column is NULL.</td> <td>NULL</td>
        </tr>
        <tr>
            <td>output</td> <td>The name of the output csv file. If this option is empty, the data of the csv file will be passed to stdout.</td> <td></td>
        </tr>
    </tbody>
    
    <thread>
        <tr>
            <th colspan="3">csv2mysql Specific</th>
        </tr>
    </thread>
    <tbody>
        <tr>
            <td>execute</td> <td>The update statement</td> <td></td>
        </tr>
        <tr>
            <td>warning_as_error</td> <td>If this optioin is set to 1, then if there's any warning when execute the statement, the program treats it as an error and terminate directly.</td> <td>1</td>
        </tr>
        <tr>
            <td>input</td> <td>The name of the input csv file. If this option is empty, the data of the csv file will be read from stdin.</td> <td></td>
        </tr>
    </tbody>
    
</table>

