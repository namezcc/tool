<?php

$aidata = fopen("ai_check","r");
if(!$aidata)
{
	echo "0";
	return;
}

$time = fgets($aidata);
fclose($aidata);

function saveTime($t)
{
	$f = fopen("ai_check","w");
	fwrite($f,$t);
	fclose($f);
}

$save = $_GET['time'];

if ($save == "0") {
	if ($time == "0") {
		$time = time();
		saveTime($time);
	}
	echo $time;
	return;
}

$res = array();

$res["res"] = 0;

if ($save == $time) {
	$time = time();
	saveTime(time());
	$res["res"] = 1;
	$res["time"] = $time;
}

echo json_encode($res);