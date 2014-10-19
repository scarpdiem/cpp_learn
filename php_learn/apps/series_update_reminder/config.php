<?php

	require_once dirname(__FILE__) . "/" . '../../libs/rlib/Cgi.php';
	
	require_once dirname(__FILE__) . "/" . 'Dao.php';
	
	$dao = new Dao();

	$mailUserName = "";
	$mailPassword = "";
	$data = array();

	if(CgiInput("post_config", "")=="1"){
		$mailUserName = CgiInput("mail_user_name","");
		$mailPassword = CgiInput("mail_password", "");

		$dao->SetConfig("mail.user_name", $mailUserName);
		$dao->SetConfig("mail.password", $mailPassword);
	}
	$dao->GetConfig("mail.user_name", $mailUserName);
	$dao->GetConfig("mail.password", $mailPassword);
	
	if(CgiInput("post_data_add","")=="1"){
		$url = CgiInput("url", "");
		$pattern = CgiInput("pattern", "");
		$mailTo = CgiInput("mail_to", "");
		$rule = array();
		$rule["s_url"] = $url;
		$rule["s_pattern"] = $pattern;
		$rule["s_mail_to"] = $mailTo;
		$dao->AddRule($rule);
	}
	
	$data = array();
	$dao->GetRules($data);
	
?><!DOCTYPE html>
<html>

<head>
	<meta charset="UTF-8">
	<title>series_update_reminder - 配置</title>	
</head>

<body>
	<form method="post" action="config.php" >
		<input type="hidden" name="post_config" value="1">
		<div>
			<label>邮件用户名</label>
			<input type="text" autocomplete="off" name="mail_user_name" value="<?php echo $mailUserName;?>" >
		</div>
		<div>
			<label>密码</label>
			<input type="password" autocomplete="off" name="mail_password" value="<?php echo $mailPassword;?>" >
		</div>
		<div>
			<input type="submit" value="提交">
		</div>
	</form>
	<br />
	
	<table border="1">
		<thead>
			<tr>
				<th colspan="3">更新检测项</th>
			</tr>
			<tr>
				<th>url</th>
				<th>pattern</th>
				<th>mail to</th>
			</tr>
		</thead>
		<tbody>
			<?php foreach($data as $item) { ?>
				<tr>
					<td style="padding:10px;"><?php echo htmlspecialchars($item["s_url"]);?></td>
					<td style="padding:10px;"><?php echo htmlspecialchars($item["s_pattern"]);?></td>
					<td style="padding:10px;"><?php echo htmlspecialchars($item["s_mail_to"]);?></td>
				</tr>
			<?php } ?>
		</tbody>
	</table>
	<br />
	
	<form method="post" action="config.php">
		<div><b>新增更新检测项</b></div>
		<input type="hidden" name="post_data_add" value="1">
		<div>
			<label>url</label>
			<input type="text" name="url" value="" >
		</div>
		<div>
			<label>pattern</label>
			<input type="text" name="pattern" value="" >
		</div>
		<div>
			<label>mail to</label>
			<input type="text" name="mail_to" value="" >
		</div>
		<div>
			<input type="submit" value="添加">
		</div>
	</form>
	<br />

</body>

</html>