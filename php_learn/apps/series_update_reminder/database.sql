use php_learn;

drop table if exists series_update_reminder_config ;
create table series_update_reminder_config(
	  s_name		varchar(255)	primary key		not null
	, s_value		varchar(255)	default ""		not null
	, last_modify	timestamp
)engine = INNODB charset=utf8;

drop table if exists series_update_reminder_rules ;
create table series_update_reminder_rules(
	  id			bigint			primary key auto_increment
	, s_url			varchar(255)					not null
	, s_pattern		varchar(1024)					not null
	, s_mail_to		varchar(255)					not null
	, s_last_result text			default ""	not null
	, last_modify	timestamp
)engine = INNODB charset=utf8;