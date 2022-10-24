#pragma once
#include "DataType.h"
#include <boost/serialization/singleton.hpp>
#include <vector>
#include <map>

enum BehaviorTreeNodeType
{
	BTNT_ACTION = 0,	//动作
	BTNT_SELECT = 1,	//选择节点
	BTNT_SEQUENCE = 2,	//顺序节点
	BTNT_RAND = 3,		//权重随机
	BTNT_NOT = 4,		//取反节点
	BTNT_SEQ_SELECT = 5,	//顺序选择	顺序直到返回失败有一个成功就算成功
	BTNT_NUM = 6,		//指定成功次数
	BTNT_LOOP = 7,		//循环节点
	BTNT_PARALLEL = 8,	//并行执行节点
	BTNT_MUST_SEQUENCE = 9,	//绝对顺序 顺序执行返回最后一个节点的结果
};

enum NodeState
{
	NS_TRUE,
	NS_FALSE,
	NS_RUNNING,
};

class Unit;
struct CfgBehaviorTreeNode;
class BehaviorTreeBaseNode;

struct NodeData;

typedef std::vector<NodeData> NodeDataVector;

struct NodeData
{
	NodeData() :node(NULL), res(0), index(0), from_wait(false), wait_tick(0)
	{
	}

	void reset()
	{
		res = NS_FALSE;
		from_wait = false;
		wait_tick = 0;
	}

	BehaviorTreeBaseNode* node;
	int32_t res;
	int32_t index;
	bool from_wait;
	int64_t wait_tick;
	std::vector<NodeDataVector> lists;
};

class BehaviorTreeBaseNode
{
public:
	BehaviorTreeBaseNode() 
		: m_cfg(nullptr)
	{}
	virtual ~BehaviorTreeBaseNode() {}
	void init(const CfgBehaviorTreeNode *cfg) { m_cfg = cfg; }
	virtual int32_t invoke(SHARE<Unit> unit, const Int32Table* param,NodeData& nd);
	virtual void addChild(BehaviorTreeBaseNode* n);
	virtual BehaviorTreeBaseNode* next_node(SHARE<Unit>& unit, NodeData* nd, std::vector<NodeData>& list) { return NULL; };

public:
	const CfgBehaviorTreeNode *m_cfg;
	std::vector<BehaviorTreeBaseNode*> m_childNodes;
};
typedef std::map<int32_t, SHARE<BehaviorTreeBaseNode>> BehaviorTreeBaseNodeTable;

class BehaviorTreeSelectNode
	: public BehaviorTreeBaseNode
{
public:
	BehaviorTreeSelectNode() {}
	virtual ~BehaviorTreeSelectNode() {}
	virtual BehaviorTreeBaseNode* next_node(SHARE<Unit>& unit, NodeData* nd, std::vector<NodeData>& list);
};

class BehaviorTreeSequenceNode
	: public BehaviorTreeBaseNode
{
public:
	BehaviorTreeSequenceNode() {};
	virtual ~BehaviorTreeSequenceNode() {};
	virtual BehaviorTreeBaseNode* next_node(SHARE<Unit>& unit, NodeData* nd, std::vector<NodeData>& list);
};

class BehaviorTreeRandNode
	: public BehaviorTreeBaseNode
{
public:
	BehaviorTreeRandNode() {};
	virtual ~BehaviorTreeRandNode() {};
	virtual BehaviorTreeBaseNode* next_node(SHARE<Unit>& unit, NodeData* nd, std::vector<NodeData>& list);
};

class BehaviorTreeNotNode
	: public BehaviorTreeBaseNode
{
public:
	BehaviorTreeNotNode() {};
	virtual ~BehaviorTreeNotNode() {};
	virtual BehaviorTreeBaseNode* next_node(SHARE<Unit>& unit, NodeData* nd, std::vector<NodeData>& list);
};

class BehaviorTreeSqlSelectNode
	: public BehaviorTreeBaseNode
{
public:
	BehaviorTreeSqlSelectNode() {};
	virtual ~BehaviorTreeSqlSelectNode() {};
	virtual BehaviorTreeBaseNode* next_node(SHARE<Unit>& unit, NodeData* nd, std::vector<NodeData>& list);
};

class BehaviorTreeNumNode
	: public BehaviorTreeBaseNode
{
public:
	BehaviorTreeNumNode() {};
	virtual ~BehaviorTreeNumNode() {};
	virtual BehaviorTreeBaseNode* next_node(SHARE<Unit>& unit,NodeData* nd, std::vector<NodeData>& list);
};

class BehaviorLoopNode
	: public BehaviorTreeBaseNode
{
public:
	BehaviorLoopNode() {};
	virtual ~BehaviorLoopNode() {};
	virtual BehaviorTreeBaseNode* next_node(SHARE<Unit>& unit, NodeData* nd, std::vector<NodeData>& list);
};

class BehaviorMustSequenceNode
	: public BehaviorTreeBaseNode
{
public:
	BehaviorMustSequenceNode() {};
	virtual ~BehaviorMustSequenceNode() {};
	virtual BehaviorTreeBaseNode* next_node(SHARE<Unit>& unit, NodeData* nd, std::vector<NodeData>& list);
};

class BehaviorTreeManager
{
public:
	BehaviorTreeManager() {};
	~BehaviorTreeManager() {};

	void init();
	void initTree(int32_t id);
	void getTree(int32_t id, std::vector<NodeData>& list);

	void pushNodeData(BehaviorTreeBaseNode* node, std::vector<NodeData>& list);
	void run_node(SHARE<Unit> unit,std::vector<NodeData>& list,const Int32Table* param);
	bool next_node(SHARE<Unit>& unit, NodeData* nd, std::vector<NodeData>& list);


	int32_t m_ai_index;
private:
	std::map<int32_t, BehaviorTreeBaseNodeTable> m_trees;
};
#define BT_MANAGER boost::serialization::singleton<BehaviorTreeManager>::get_mutable_instance()
