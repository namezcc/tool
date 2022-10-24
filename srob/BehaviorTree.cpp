#include "BehaviorTree.h"
#include "Unit.h"
#include "CfgData.h"
#include "Random.h"

int32_t BehaviorTreeBaseNode::invoke(SHARE<Unit> unit, const Int32Table* param, NodeData& nd)
{
	if (m_cfg->action) {
		return unit->doBTAction(*m_cfg, param, nd);
	}
	else {
		return NS_TRUE;
	}
}

void BehaviorTreeBaseNode::addChild(BehaviorTreeBaseNode * n)
{
	m_childNodes.push_back(n);
}

BehaviorTreeBaseNode * BehaviorTreeSelectNode::next_node(SHARE<Unit>& unit, NodeData * nd, std::vector<NodeData>& list)
{
	if (list.size() > nd->index + 1)
	{
		auto cnd = &list[nd->index + 1];
		if (cnd->res == NS_TRUE)
		{
			nd->res = NS_TRUE;
			return NULL;
		}

		int32_t idx = -1;
		for (int32_t i = (int32_t)m_childNodes.size() - 1; i >= 0 ; i--)
		{
			if (cnd->node == m_childNodes[i])
				break;
			else
				idx = i;
		}
		return idx == -1 ? NULL : m_childNodes[idx];
	}
	else
	{
		if (m_childNodes.size() == 0)
			return NULL;
		return *m_childNodes.begin();
	}
	return NULL;
}

BehaviorTreeBaseNode * BehaviorTreeSequenceNode::next_node(SHARE<Unit>& unit, NodeData * nd, std::vector<NodeData>& list)
{
	if (list.size() > nd->index + 1)
	{
		auto cnd = &list[nd->index + 1];
		if (cnd->res == NS_FALSE)
			return NULL;
		
		int32_t idx = -1;
		for (int32_t i = (int32_t)m_childNodes.size() - 1; i >= 0; i--)
		{
			if (cnd->node == m_childNodes[i])
				break;
			else
				idx = i;
		}
		if (idx == -1)
		{
			nd->res = NS_TRUE;
			return NULL;
		}
		else
		{
			return m_childNodes[idx];
		}
	}
	else
	{
		if (m_childNodes.size() == 0)
		{
			return NULL;
		}
		return *m_childNodes.begin();
	}
	return NULL;
}

BehaviorTreeBaseNode * BehaviorTreeRandNode::next_node(SHARE<Unit>& unit, NodeData * nd, std::vector<NodeData>& list)
{
	if (list.size() > nd->index + 1)
	{
		auto cnd = &list[nd->index + 1];
		nd->res = cnd->res;
		return NULL;
	}
	else
	{
		if (m_childNodes.size() == 0 || m_childNodes.size() != m_cfg->child_weight.size())
			return NULL;

		auto rval = RANDOM.generate(0, *m_cfg->child_weight.rbegin());
		for (size_t i = 0; i < m_cfg->child_weight.size(); i++)
		{
			if (rval <= m_cfg->child_weight[i])
				return m_childNodes[i];
		}
		return NULL;
	}
}

BehaviorTreeBaseNode * BehaviorTreeNotNode::next_node(SHARE<Unit>& unit, NodeData * nd, std::vector<NodeData>& list)
{
	if (list.size() > nd->index + 1)
	{
		auto cnd = &list[nd->index + 1];
		nd->res = cnd->res == NS_TRUE ? NS_FALSE : NS_TRUE;
		return NULL;
	}
	else
	{
		if (m_childNodes.size() == 0)
			return NULL;
		return *m_childNodes.begin();
	}
}

BehaviorTreeBaseNode * BehaviorTreeSqlSelectNode::next_node(SHARE<Unit>& unit, NodeData * nd, std::vector<NodeData>& list)
{
	if (list.size() > nd->index + 1)
	{
		auto cnd = &list[nd->index + 1];
		if (cnd->res == NS_TRUE)
			nd->res = NS_TRUE;
		else if (cnd->res == NS_FALSE)
			return NULL;

		int32_t idx = -1;
		for (int32_t i = (int32_t)m_childNodes.size() - 1; i >= 0; i--)
		{
			if (cnd->node == m_childNodes[i])
				break;
			else
				idx = i;
		}
		if (idx == -1)
			return NULL;
		else
			return m_childNodes[idx];
	}
	else
	{
		if (m_childNodes.size() == 0)
		{
			return NULL;
		}
		return *m_childNodes.begin();
	}
	return NULL;
}

BehaviorTreeBaseNode * BehaviorTreeNumNode::next_node(SHARE<Unit>& unit, NodeData * nd, std::vector<NodeData>& list)
{
	auto param = unit->getAiParam(m_cfg->tree_id);
	auto num = unit->getAiData(m_cfg->tree_id, m_cfg->id, 0);
	if (num >= unit->getAiParamValue(m_cfg->param, param, m_cfg->id, 0))
	{
		nd->res = NS_FALSE;
		return NULL;
	}

	if (list.size() > nd->index + 1)
	{
		auto mode = unit->getAiParamValue(m_cfg->param, param, m_cfg->id, 1);
		auto cnd = &list[nd->index + 1];

		if(cnd->res == NS_TRUE)
			nd->res = NS_TRUE;

		if ((cnd->res == NS_TRUE && mode==0) || (cnd->res == NS_FALSE && mode == 1))
		{
			unit->setAiData(m_cfg->tree_id, m_cfg->id, 0, num + 1);
		}
		return NULL;
	}
	else
	{
		if (m_childNodes.size() == 0)
			return NULL;
		return *m_childNodes.begin();
	}
	return NULL;
}

BehaviorTreeBaseNode * BehaviorLoopNode::next_node(SHARE<Unit>& unit, NodeData * nd, std::vector<NodeData>& list)
{
	if (list.size() > nd->index + 1)
	{
		auto cnd = &list[nd->index + 1];
		if (cnd->res == NS_TRUE)
		{
			return m_childNodes[0];
		}
		else if (cnd->res == NS_FALSE)
		{
			nd->res = NS_FALSE;
			return NULL;
		}
	}
	else
	{
		if (m_childNodes.size() == 0)
			return NULL;
		
		return *m_childNodes.begin();
	}
	return NULL;
}

BehaviorTreeBaseNode * BehaviorMustSequenceNode::next_node(SHARE<Unit>& unit, NodeData * nd, std::vector<NodeData>& list)
{
	if (list.size() > nd->index + 1)
	{
		auto cnd = &list[nd->index + 1];

		int32_t idx = -1;
		for (int32_t i = (int32_t)m_childNodes.size() - 1; i >= 0; i--)
		{
			if (cnd->node == m_childNodes[i])
				break;
			else
				idx = i;
		}
		if (idx == -1)
		{
			nd->res = cnd->res;
			return NULL;
		}
		else
			return m_childNodes[idx];
	}
	else
	{
		if (m_childNodes.size() == 0)
			return NULL;
		return *m_childNodes.begin();
	}
	return NULL;
}


void BehaviorTreeManager::init()
{
	m_ai_index = 0;

	const CfgBehaviorTreeNodeTable2& cfgtab = CFG_DATA.getBehaviorTree();

	for (auto& it:cfgtab)
	{
		BehaviorTreeBaseNodeTable nodetab;

		for (auto it2=it.second.begin();it2!=it.second.end();++it2)
		{
			SHARE<BehaviorTreeBaseNode> node = nullptr;
			if (it2->second.type == BTNT_SELECT)
				node = std::make_shared<BehaviorTreeSelectNode>();
			else if (it2->second.type == BTNT_SEQUENCE)
				node = std::make_shared<BehaviorTreeSequenceNode>();
			else if (it2->second.type == BTNT_NOT)
				node = std::make_shared<BehaviorTreeNotNode>();
			else if (it2->second.type == BTNT_RAND)
				node = std::make_shared<BehaviorTreeRandNode>();
			else if (it2->second.type == BTNT_SEQ_SELECT)
				node = std::make_shared<BehaviorTreeSqlSelectNode>();
			else if (it2->second.type == BTNT_NUM)
				node = std::make_shared<BehaviorTreeNumNode>();
			else if (it2->second.type == BTNT_LOOP)
				node = std::make_shared<BehaviorLoopNode>();
			else if (it2->second.type == BTNT_MUST_SEQUENCE)
				node = std::make_shared<BehaviorMustSequenceNode>();
			else
				node = std::make_shared<BehaviorTreeBaseNode>();

			node->init(&it2->second);
			nodetab[it2->first] = node;
		}

		for (auto itn=nodetab.begin();itn!= nodetab.end();++itn)
		{
			if (itn->second->m_cfg->child_id.empty())
				continue;
			for (auto &nid : itn->second->m_cfg->child_id)
			{
				auto itc = nodetab.find(nid);
				if (itc == nodetab.end() || itc == itn)
					LOG_ERROR("error childnode or child is self tid:%d pid:%d id:%d\n", it.first,itn->first,nid);
				else
					itn->second->addChild(itc->second.get());
			}
		}

		m_trees[it.first] = std::move(nodetab);
	}
}

void BehaviorTreeManager::initTree(int32_t id)
{
	BT_MANAGER.m_ai_index++;

	auto vec = CFG_DATA.getBehaviorTreeNodeVec(id);
	if (vec == NULL)
		return;
	
	BehaviorTreeBaseNodeTable nodetab;

	for (auto it2 = vec->begin(); it2 != vec->end(); ++it2)
	{
		SHARE<BehaviorTreeBaseNode> node = nullptr;
		if (it2->second.type == BTNT_SELECT)
			node = std::make_shared<BehaviorTreeSelectNode>();
		else if (it2->second.type == BTNT_SEQUENCE)
			node = std::make_shared<BehaviorTreeSequenceNode>();
		else if (it2->second.type == BTNT_NOT)
			node = std::make_shared<BehaviorTreeNotNode>();
		else if (it2->second.type == BTNT_RAND)
			node = std::make_shared<BehaviorTreeRandNode>();
		else if (it2->second.type == BTNT_SEQ_SELECT)
			node = std::make_shared<BehaviorTreeSqlSelectNode>();
		else if (it2->second.type == BTNT_NUM)
			node = std::make_shared<BehaviorTreeNumNode>();
		else if (it2->second.type == BTNT_LOOP)
			node = std::make_shared<BehaviorLoopNode>();
		else
			node = std::make_shared<BehaviorTreeBaseNode>();

		node->init(&it2->second);
		nodetab[it2->first] = node;
	}

	for (auto itn = nodetab.begin(); itn != nodetab.end(); ++itn)
	{
		if (itn->second->m_cfg->child_id.empty())
			continue;
		for (auto &nid : itn->second->m_cfg->child_id)
		{
			auto itc = nodetab.find(nid);
			if (itc == nodetab.end() || itc == itn)
				LOG_ERROR("error childnode or child is self tid:%d pid:%d id:%d\n",id, itn->first, nid);
			else
				itn->second->addChild(itc->second.get());
		}
	}

	m_trees[id] = std::move(nodetab);
}

void BehaviorTreeManager::getTree(int32_t id, std::vector<NodeData>& list)
{
	list.clear();

	auto it = m_trees.find(id);
	if (it == m_trees.end())
		return;

	auto it2 = it->second.find(0);
	if (it2 == it->second.end())
		return;

	pushNodeData(it2->second.get(), list);
}

void BehaviorTreeManager::pushNodeData(BehaviorTreeBaseNode * node, std::vector<NodeData>& list)
{
	NodeData nd;
	nd.node = node;
	nd.res = node->m_cfg->type == BTNT_ACTION ? NS_TRUE : NS_FALSE;
	nd.index = list.size();
	nd.from_wait = false;
	list.push_back(nd);
}

void BehaviorTreeManager::run_node(SHARE<Unit> unit, std::vector<NodeData>& list, const Int32Table* param)
{
	if (unit == NULL || list.empty())
		return;

	NodeData* nd = &(*list.rbegin());

	while (nd)
	{
		if (nd->node->m_cfg->type == BTNT_ACTION)
		{
			if (nd->wait_tick > 0 && nd->wait_tick > unit->getTick())
				return;

			if (nd->from_wait == false)
			{
				if(nd->wait_tick == 0 || nd->res == NS_RUNNING)
					nd->res = nd->node->invoke(unit, param,*nd);

				if (nd->res != NS_RUNNING && nd->node->m_cfg->wait > 0)
				{
					nd->from_wait = true;
					unit->setBTreeWait(nd->node->m_cfg->wait,*nd);
					return;
				}
				if (nd->wait_tick > 0 && nd->wait_tick > unit->getTick())
					return;
			}
		}
		else if(nd->node->m_cfg->type == BTNT_PARALLEL)
		{
			if (nd->lists.size() != nd->node->m_childNodes.size())
			{
				nd->lists.resize(nd->node->m_childNodes.size());
				for (size_t i = 0; i < nd->node->m_childNodes.size(); i++)
				{
					pushNodeData(nd->node->m_childNodes[i], nd->lists[i]);
				}
			}

			nd->res = NS_TRUE;
			for (auto& l:nd->lists)
			{
				if (l.size() == 1)
					l[0].reset();
				run_node(unit, l, param);
				if (l.size() == 1)
				{
					if (l[0].res == NS_FALSE)
					{
						nd->res = NS_FALSE;
						break;
					}
					else if (l[0].res == NS_RUNNING)
					{
						nd->res = NS_RUNNING;
					}
				}
				else
					nd->res = NS_RUNNING;
			}
			//if(nd->res != NS_RUNNING)
				//LOG_ERROR("PARALLEL tree:%d id:%d end res:%d \n", nd->node->m_cfg->tree_id, nd->node->m_cfg->id, nd->res);
		}

		if (nd->res != NS_RUNNING)
		{
			if (next_node(unit,nd, list) && !list.empty())
				nd = &(*list.rbegin());
			else
				return;
		}
		else
			return;
	}
}

bool BehaviorTreeManager::next_node(SHARE<Unit>& unit, NodeData * nd, std::vector<NodeData>& list)
{
	while (nd)
	{
		BehaviorTreeBaseNode* node = nd->node;
		bool isloop = node->m_cfg->type == BTNT_LOOP;
		if (node->m_cfg->type == BTNT_ACTION)
		{
			if (nd->index == 0 || nd->index >= list.size())
			{
				//LOG_ERROR("node index error id:%d act:%d\n",node->m_cfg->id, node->m_cfg->action);
				return false;
			}
			nd = &list[nd->index - 1];
		}
		else
		{
			node = node->next_node(unit,nd, list);
			if (node == NULL)
			{
				while (list.size() > nd->index+1)
					list.pop_back();
				if (nd->index == 0 || nd->index >= list.size())
					return false;
				nd = &list[nd->index - 1];
			}
			else
			{
				while (list.size() > nd->index + 1)
					list.pop_back();
				pushNodeData(node, list);
				if (isloop)
					return false;
				else
					return true;
			}
		}
	}
	return true;
}

