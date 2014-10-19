<?php

require_once dirname(__FILE__) . "/" . '../../libs/rlib/NetUtils.php';
require_once dirname(__FILE__) . "/" . '../../libs/rlib/Cgi.php';

require_once dirname(__FILE__) . "/" . 'PHPMailerSendFromQqConfig.php';

require_once dirname(__FILE__) . "/" . 'Dao.php';

$dao = new Dao();

$mailUserName = "";
$mailPassword = "";
$dao->GetConfig("mail.user_name", $mailUserName);
$dao->GetConfig("mail.password", $mailPassword);


$data = array();
$dao->GetRules($data);

foreach ($data as &$item){
	
	$from = $mailUserName;
	$passwrod = $mailPassword;
	
	$url = $item["s_url"];
	$to = $item["s_mail_to"];
	$pattern = $item["s_pattern"];
	$lastResult = $item["s_last_result"];

	$currentResult = "";
	
	// load html
	$options = new NetUtilsHttpLoadOptions(); 
	$options->url = $url;
	$options->method = "GET";
	$loadData = "";
	NetUtilsHttpLoad($options, $loadData);
	
	// filter
	$output = array();
	preg_match_all($pattern, $loadData, $output);
	$currentResult = $output[0];
	if(count($currentResult)==0){
		// loading html may have failed, do nothing
		continue;
	}
	$currentResult = json_encode($currentResult);

	// compare with history result
	if($currentResult!=$lastResult){
		
		$mail = new PHPMailer();
		PHPMailerSendFromQqConfig($mail, $from, $passwrod);
		
		//Set who the message is to be sent to
		$mail->addAddress($to, $to);
		
		//Set the subject line
		$mail->Subject = 'update notify';
		
		$mail->msgHTML(
				  htmlspecialchars($url)
				. "<div>" . htmlspecialchars(json_encode($currentResult)) . "</div>"
				. "<div>" . htmlspecialchars(json_encode($lastResult)) . "</div>"
		);
		
		if (!$mail->send()) {
			// on error.
			continue;
		}
		
		$item["s_last_result"] = $currentResult;
		
		$dao->UpdateRule($item);
	}
}


?>