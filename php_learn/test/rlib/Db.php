<?php

require_once '../../libs/rlib/Db.php';

$config = new DbConfig();
$config->userName = "root";
$config->password = "";
$config->charset = "utf-8";
$config->useDatabase = "rlib_test";

$db = new Db($config);

$db->Execute("create table test(uin bigint primary key, content varchar(1024) not null default '')");
$db->Execute("delete from test");

$result = $db->Execute("insert into test (uin,content) values(1,1),(2,2),(3,3)");
if($result->affectedRows!=3){
	die("insertRows=$insertRows, ". $db->GetLastError());
}


$query= array();
$query[] = "  uin=";
$query[] = DbWrapStr("3");
$result = $db->Execute( "select * from test where ", $query, " or uin=", DbEscape("1"));

if($result->affectedRows!=2){
	die("selectRows=" . $result->affectedRows);
}
var_dump($result);


echo "transaction test begin...\n";

echo "transaction test 1 ... \n";

$result = $db->Execute("delete from test");
if($result->affectedRows!=3){
	die("deleteRows=" . $result->affectedRows);
}

$result = $db->Begin();
if($result->errorCode){
	var_dump($result);
	die("begin transaction error.");
}

$result = $db->Execute("insert into test (uin,content) values(1,1),(2,2),(3,3)");
if($result->affectedRows!=3){
	die("insertRows=$insertRows, ". $db->GetLastError());
}

$result = $db->Commit();
if($result->errorCode){
	var_dump($result);
	die("commit error.");
}

$result = $db->Execute("select * from test");
if($result->affectedRows!=3){
	var_dump($result);
	die("select error, transaction test failed.");
}

echo "transaction test 1 done.\n";


echo "transaction test 2 ... \n";

$result = $db->Execute("delete from test");
if($result->affectedRows!=3){
	die("deleteRows=" . $result->affectedRows);
}

$result = $db->Begin();
if($result->errorCode){
	var_dump($result);
	die("begin transaction error.");
}

$result = $db->Execute("insert into test (uin,content) values(1,1),(2,2),(3,3)");
if($result->affectedRows!=3){
	die("insertRows=$insertRows, ". $db->GetLastError());
}

$result = $db->RollBack();
if($result->errorCode){
	var_dump($result);
	die("commit error.");
}

$result = $db->Execute("select * from test");
if($result->affectedRows!=0){
	var_dump($result);
	die("select error, transaction test failed.");
}

echo "transaction test 2 done.\n";

$result = $db->Execute("insert into test (uin,content) values(1,1),(2,2),(3,3)");
if($result->affectedRows!=3){
	die("insertRows=$insertRows, ". $db->GetLastError());
}
$result = $db->Execute("select * from test");
if($result->affectedRows!=3){
	var_dump($result);
	die("select error, transaction test failed.");
}


echo "test done.\n";

?>