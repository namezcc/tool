<?php

$aidata = fopen("behavior_tree.cfg","r");
if(!$aidata)
{
	echo "[]";
	return;
}

$data = array();

function parseLine($str)
{
	$line = str_getcsv($str,"\t");

	$line[0] = intval($line[0]);
	$line[1] = intval($line[1]);
	$line[2] = intval($line[2]);
	$line[5] = intval($line[5]);
	$line[6] = intval($line[6]);
	return $line;
}

$datastart = false;

while (!feof($aidata)) {
	$str = fgets($aidata);
	if ($datastart) {
		array_push($data,parseLine($str));
	}else {
		if (!(strpos($str,"[data]")===false)) {
			$datastart = true;
		}
	}
}

fclose($aidata);

echo json_encode($data);
