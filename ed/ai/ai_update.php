<?php

function send_post($url, $post_data) {
	$str = json_encode($post_data);
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_TIMEOUT, 3);
	curl_setopt($ch, CURLOPT_POST, 1);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $str);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

	$data = curl_exec($ch);
	curl_close($ch);
	return $data;
}

$pdata = file_get_contents("php://input");

$head = "[header]
id	int	11	树id
node_id	int	11	节点id,0为根节点
node_type	int	11	节点类型,0动作1选择2顺序3.权重随机
child_id	char	11	子节点id
child_weight	char	11	子节点权重
action	int	11	条件或行为(仅0叶子节点需要定义)
wait	int	11	等待时长毫秒
param	char	11	额外参数(:分割)
desc	char	16	描述

[data]
";

$url = "http://127.0.0.1:8999/aiupdate";

$post_data = array(
	"Lua" => $head.$pdata,
	"Server" => array(),
	"Except" => array(),
);

echo send_post($url,$post_data);