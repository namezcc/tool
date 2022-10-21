<?php

$pdata = file_get_contents("php://input");

// var_dump($pdata);

$aidata = fopen("behavior_tree.cfg","w");

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

fwrite($aidata,$head);
fwrite($aidata,$pdata);
fclose($aidata);

echo "成功";