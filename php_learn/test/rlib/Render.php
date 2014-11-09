<?php

require_once dirname(__FILE__) . "/" .  '../../libs/rlib/Render.php';

function Entry(){
	$output = "";
	Render( dirname(__FILE__) . "/" . "Render.tpl.php", array("msg"=>"hello world"), $output);

	var_dump($output);

}

Entry();


?>
