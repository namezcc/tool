#ifndef RANK_ARRAY_H
#define RANK_ARRAY_H
//RankArray
#include <vector>
#include <map>
#include <stdint.h>

template <typename T,typename K,typename _pr = std::less<T> >
class RankArray
{
public:
	struct RankItem
	{
		int32_t index;
		T data;
		K key;
	};
	typedef std::map<K, RankItem*> RankMap;
	typedef std::vector<RankItem*> RankData;

	RankArray(int32_t _maxSize):m_maxSize(_maxSize)
	{
		m_data.reserve(_maxSize);
	}
	~RankArray()
	{
		Clear();
	}

	void Clear()
	{
		for (size_t i = 0; i < m_data.size(); i++)
		{
			delete m_data[i];
		}
		m_data.clear();
		m_map.clear();
	}

	void InsertData(const K& _key, const T& _data)
	{
		typename RankMap::iterator it = m_map.find(_key);
		if (it == m_map.end())
		{
			if (m_data.size() >= (size_t)m_maxSize)
			{
				if (m_less(m_data.back()->data, _data))
					SwapItem(m_data.size() - 1,_key, _data);
			}
			else
				AddItem(_key,_data);
		}
		else
		{
			it->second->data = _data;
			UpdateRank(it->second->index);
		}
	}

	void DeleteData(const K& _key)
	{
		typename RankMap::iterator it = m_map.find(_key);
		if (it == m_map.end())
			return;

		m_data.erase(m_data.begin() + it->second->index);
		delete it->second;
		m_map.erase(it);
	}

	const RankData& GetRank()
	{
		return m_data;
	}

	int32_t GetRankIndex(const K& _key)
	{
		typename RankMap::iterator it = m_map.find(_key);
		if (it == m_map.end())
		{
			return -1;
		}else
			return it->second->index;
	}

	RankItem* GetRankItem(const K& _key)
	{
		typename RankMap::iterator it = m_map.find(_key);
		if (it == m_map.end())
		{
			return NULL;
		}else
			return it->second;
	}

protected:

	void AddItem(const K& _key,const T& data)
	{
		RankItem* item = new RankItem();
		item->key = _key;
		item->data = data;
		item->index = m_data.size();
		m_data.push_back(item);
		m_map[_key] = item;
		UpdateRank(item->index);
	}

	void SwapItem(int32_t _index, const K& _key, const T& data)
	{
		RankItem* item = m_data[_index];
		m_map.erase(item->key);
		m_map[_key] = item;
		item->key = _key;
		item->data = data;
		UpdateRank(_index);
	}

	void UpdateRank(int32_t index)
	{
		if (m_data.size() == 0)
			return;
		RankItem* item = m_data[index];
		int32_t ibeg = 0;
		int32_t iend = m_data.size() - 1;
		if (index > ibeg && m_less(m_data[index-1]->data, item->data))
		{
			iend = index;
		}
		else if (index < iend && m_less(item->data, m_data[index + 1]->data))
		{
			ibeg = index;
		}
		else
			return;

		if (ibeg < index)
		{//up
			while (ibeg < iend)
			{
				int32_t imid = (ibeg + iend) / 2;
				if (m_less(m_data[imid]->data, item->data))
					iend = imid;
				else
					ibeg = imid + 1;
			}
			for (int32_t i = index; i > ibeg; i--)
			{
				m_data[i] = m_data[i - 1];
				m_data[i]->index = i;
			}
			item->index = ibeg;
			m_data[ibeg] = item;
		}
		else
		{//down
			while (ibeg < iend)
			{
				int32_t imid = (ibeg + iend) / 2;
				if (m_less(m_data[imid]->data, item->data))
					iend = imid;
				else
				{
					if(imid != index && m_data[imid]->data == item->data)
						iend = imid - 1;
					else
						ibeg = imid + 1;
				}
			}
			if (m_less(m_data[ibeg]->data, item->data))
				--ibeg;
			for (int32_t i = index; i < ibeg; i++)
			{
				m_data[i] = m_data[i + 1];
				m_data[i]->index = i;
			}
			item->index = ibeg;
			m_data[ibeg] = item;
		}
	}

private:
	int32_t m_maxSize;
	RankData m_data;
	RankMap m_map;
	_pr m_less;
};

#endif
