<?php 

require_once dirname(__FILE__) . '/' . '../../libs/rlib/DbMysqli.php';
require_once dirname(__FILE__) . '/' . '../PhpLearnDbConfig.php';

require_once dirname(__FILE__) . "/" . '../common/GetLogger.php';

class Dao{

	private $db = NULL;

	function __construct(){
		$this->db = new DbMysqli(PhpLearnDbConfig());
	}

	/**
	 * @return error code
	 */
	function SetConfig($name, $value){
		$result = $this->db->Execute(
						  "insert into series_update_reminder_config "
						, " set s_name=", DbWrapStr($name)
						, ", s_value=", DbWrapStr($value)
						, " on duplicate key update s_value=",DbWrapStr($value)
					);
		return $result->errorCode;
	}

	/**
	 * @return error code
	 */
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

	function GetRules(Dao_GetRulesIn $in, Dao_GetRulesOut $out){
		$result = $this->db->Execute(
			"select * from series_update_reminder_rules"
		);
		$out->rules = $result->selectResult;
		$out->errorCode = $result->errorCode;
		$out->errorMessage = $result->errorMessage;
	}

	function AddRule(Dao_AddRuleIn $in, Dao_AddRuleOut $out){
		$result = $this->db->Execute(
			  "insert into series_update_reminder_rules "
			, " set s_url=", DbWrapStr($in->url)
			, ", s_pattern=", DbWrapStr($in->pattern)
			, ", s_creator=", DbWrapStr($in->creator)
			, ", s_last_result=", DbWrapStr("")
		);
		if($result->errorCode){
			GetLogger()->error("execute sql error: " . $result->statement . " message:" . $result->errorMessage);
			$out->errorCode = $result->errorCode;
			$out->errorMessage = $result->errorMessage;
			return;
		}
		GetLogger()->info("executed: " . $result->statement);
		$out->errorCode = $result->errorCode;
		$out->errorMessage = $result->errorMessage;
		return;
	}

	function UpdateRuleLastResult(Dao_UpdateRuleLastResultIn $in, Dao_UpdateRuleLastResultOut $out){
		$result = $this->db->Execute(
			"update series_update_reminder_rules "
			, " set s_last_result=", DbWrapStr($in->lastResult)
			, ",  d_last_update=now()"
			, " where id=", DbWrapStr($in->id)
		);
		if($result->errorCode){
			GetLogger()->error("execute sql error: " . $result->statement . " message:" . $result->errorMessage);
			$out->errorCode = $result->errorCode;
			$out->errorMessage = $result->errorMessage;
			return;
		}
		GetLogger()->info("executed: " . $result->statement);
		$out->errorCode = $result->errorCode;
		$out->errorMessage = $result->errorMessage;
		return;
	}

	function GetUsersToInformUpdate(Dao_GetUsersToInformUpdateIn $in, Dao_GetUsersToInformUpdateOut $out){
		$query = array();
		$query[] = "select r.id as i_rule_id, r.s_url as s_url, r.s_pattern as s_pattern, u.s_subscriber  as s_subscriber ";
		$query[] = " from series_update_reminder_rules as r, series_update_reminder_subscribers as u ";
		$query[] = " where r.id = u.i_rule_id ";
		$query[] = " and u.d_last_mail < r.d_last_update ";
		$result = $this->db->Execute($query);
		$out->errorCode = $result->errorCode;
		$out->errorMessage = $result->errorMessage;
		$out->users = $result->selectResult;
		return;
	}

	function UpdateUserInformTime(Dao_UpdateUserInformTimeIn $in, Dao_UpdateUserInformTimeOut $out){
		$query = array();
		$query[] = "update series_update_reminder_subscribers ";
		$query[] = " set d_last_mail=now() ";
		$query[] = " where i_rule_id=";		$query[] = DbWrapStr($in->ruleId);
		$query[] = " and s_subscriber=";	$query[] = DbWrapStr($in->subscriber);
		$result = $this->db->Execute($query);
		if($result->errorCode){
			GetLogger()->error("execute sql error: " . $result->statement . " message:" . $result->errorMessage);
			$out->errorCode = $result->errorCode;
			$out->errorMessage = $result->errorMessage;
			return;
		}
		GetLogger()->info("executed: " . $result->statement);
		$out->errorCode = $result->errorCode;
		$out->errorMessage = $result->errorMessage;
		return;
	}

};

class Dao_GetRulesIn{
};
class Dao_GetRulesOut{
	var $rules = array();
	var $errorCode = 0;
	var $errorMessage = "";
};

class Dao_AddRuleIn{
	var $url = "";
	var $pattern = "";
	var $creator = "";
};
class Dao_AddRuleOut{
	var $errorCode = 0;
	var $errorMessage = "";
};

class Dao_UpdateRuleLastResultIn{
	var $id = 0;
	var $lastResult;
};
class Dao_UpdateRuleLastResultOut{
	var $errorCode = 0;
	var $errorMessage = "";
};

class Dao_GetUsersToInformUpdateIn{
};
class Dao_GetUsersToInformUpdateOut{
	var $users = array();
	var $errorCode = 0;
	var $errorMessage = "";
};

class Dao_UpdateUserInformTimeIn{
	var $ruleId = 0;
	var $subscriber = "";
};
class Dao_UpdateUserInformTimeOut{
	var $errorCode = 0;
	var $errorMessage = "";
};

?>
