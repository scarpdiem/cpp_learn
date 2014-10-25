<?php 

require_once dirname(__FILE__) . '/' . '../../libs/rlib/Db.php';
require_once dirname(__FILE__) . '/' . '../PhpLearnDbConfig.php';

class Dao{
	
	private $db = NULL;
	
	function __construct(){
		$this->db = new DbMysql(PhpLearnDbConfig());
	}
	
	function SetConfig($name, $value){
		$result = $this->db->Execute(
						  "insert into series_update_reminder_config "
						, " set s_name=", DbWrapStr($name)
						, ", s_value=", DbWrapStr($value)
						, " on duplicate key update s_value=",DbWrapStr($value)
					);
		return $result->errorCode;
	}
	
	function GetConfig($name, &$value){
		$result = $this->db->Execute(
				" select * from series_update_reminder_config "
				, " where s_name=", DbWrapStr($name)
		);
		if($result->errorCode){
			return $result->errorCode;
		}
		if(count($result->selectResult)==0){
			$value = "";
			return 0;
		}
		$value = $result->selectResult[0]["s_value"];
		return 0;
	}
	
	function GetRules(&$rules){
		$result = $this->db->Execute(
			"select * from series_update_reminder_rules"
		);
		$rules = $result->selectResult;
		return $result->errorCode;
	}
	
	function AddRule($rule){
		$result = $this->db->Execute(
			  "insert into series_update_reminder_rules "
			, " set s_url=", DbWrapStr($rule["s_url"])
			, ", s_pattern=", DbWrapStr($rule["s_pattern"])
			, ", s_mail_to=", DbWrapStr($rule["s_mail_to"])
		);
		return $result->errorCode;
	}
	
	function UpdateRule($rule){
		$result = $this->db->Execute(
				"update series_update_reminder_rules "
				, " set s_url=", DbWrapStr($rule["s_url"])
				, ", s_pattern=", DbWrapStr($rule["s_pattern"])
				, ", s_mail_to=", DbWrapStr($rule["s_mail_to"])
				, ", s_last_result=", DbWrapStr($rule["s_last_result"])
				, " where id=", DbWrapStr($rule["id"])
		);
		if($result->affectedRows!=1){
			return __LINE__;
		}
		return 0;
	}
	
};

?>
