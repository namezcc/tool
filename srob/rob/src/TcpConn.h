#ifndef TCP_CONN_H
#define TCP_CONN_H

#include<boost/asio.hpp>
#include "FactorManager.h"

namespace as = asio;
using asio::ip::tcp;

struct NetBuffer:public LoopObject
{
	char* buf;
	int len;
	int use;
	int scan;

	NetBuffer() :buf(NULL), len(0), use(0), scan(0)
	{}

	~NetBuffer()
	{
		if (buf)
			free(buf);
	}

	NetBuffer(NetBuffer&& b) :buf(b.buf), len(b.len), use(b.use), scan(b.scan)
	{
		b.buf = NULL;
		b.use = b.len = b.scan = 0;
	}

	NetBuffer& operator=(NetBuffer&& b)
	{
		assert(this != &b);
		std::swap(buf, b.buf);

		std::swap(len, b.len);
		std::swap(use, b.use);
		std::swap(scan, b.scan);
		return *this;
	}

	void Clear()
	{
		if (buf)
			free(buf);
		buf = NULL;
		len = use = scan = 0;
	}

	void MakeRoome(const int& size)
	{
		if (len >= size)
			return;
		auto room = (char*)malloc(size);
		if (use > 0)
			memcpy(room, buf, use);
		free(buf);
		buf = room;
		len = size;
	}

	void combin(char* newbuf, int nlen)
	{
		if (nlen <= 0)
			return;
		if (use + nlen <= len)
		{
			memcpy(buf + use, newbuf, nlen);
			use += nlen;
		}
		else
		{
			char* room = (char*)malloc(use + nlen);
			if (buf)
			{
				if (use>0)
					memcpy(room, buf, use);
				free(buf);
			}
			memcpy(room + use, newbuf, nlen);
			buf = room;
			len = use + nlen;
			use = len;
		}
	}

	void moveHalf(const int& readed)
	{
		if (readed == 0)
			return;
		int nuse = use - readed;
		if (nuse>0)
			memcpy(buf, buf + readed, nuse);
		use = nuse;
		scan = 0;
	}

	NetBuffer& append(char* p, int len)
	{
		combin(p, len);
		return *this;
	}

	NetBuffer& append(char* p)
	{
		combin(p, strlen(p));
		return *this;
	}

	NetBuffer& append(const std::string& s)
	{
		combin(const_cast<char*>(s.c_str()), s.size());
		return *this;
	}

	// 通过 LoopObject 继承
	virtual void init(FactorManager * fm) {
		len = use = scan = 0;
	};
	virtual void recycle(FactorManager * fm) {
	};
};

struct PB
{
	static int32_t GetInt8(char* msg)
	{
		return *(int8_t*)msg;
	}

	static void WriteInt8(char* res, int8_t n)
	{
		*(int8_t*)res = n;
	}

	static int16_t GetShort(char* msg)
	{
		return *(int16_t*)msg;
	}

	static void WriteShort(char* res, int16_t n)
	{
		*(int16_t*)res = n;
	}

	static int32_t GetInt(char* msg)
	{
		return *(int32_t*)msg;
	}

	static void WriteInt(char* res, int32_t n)
	{
		*(int32_t*)res = n;
	}
};

struct Head
{
	int16_t mid;
	int32_t size;
	int8_t extraSize;
	int32_t pbsize;
};

struct MsgHead:public Head
{
	enum
	{
		HEAD_SIZE = 7 + 4,
	};

	static void Encode(char* buf, const int16_t& mid, int32_t len)
	{
		//len += HEAD_SIZE;

		PB::WriteShort(buf,mid);
		PB::WriteInt(buf+2, len);
		PB::WriteInt8(buf+6, 0);
		PB::WriteInt(buf + 7, len);
	}

	bool Decode(char* buf)
	{
		mid = PB::GetShort(buf);
		size = PB::GetInt(buf+2);
		extraSize = PB::GetInt8(buf+6);
		pbsize = PB::GetInt(buf + 7);
		return true;
	}
};

#define MAX_BUFF_SIZE 4096

class TcpConn:public std::enable_shared_from_this<TcpConn>
{
public:
	typedef std::function<void(const int32_t&, const int32_t&, char*)> ReadCall;
	typedef std::function<void()> CloseCall;

	TcpConn(as::io_context& _context):m_context(_context),m_socket(_context)
	{};
	~TcpConn()
	{
		m_writeBuff.clear();
	};

	bool Connect(const std::string& ip, const int32_t& port);
	bool ReConnect();

	inline void BindOnReadPack(const ReadCall& f) { m_onRead = f; };
	inline void BindOnClose(const CloseCall& f) { m_onClose = f; };

	void SendPackData(const int32_t& mid,const char* buff,const int32_t& size);
	void Close();

protected:
	void init();
	bool RealConnect();
	void DoRecv();
	void DoWrite();
	bool DoReadHead();
	bool DoReadBody();
	void DoClose();

private:
	std::string m_ip;
	int32_t m_port;

	char m_cashBuff[MAX_BUFF_SIZE];

	as::io_context& m_context;
	tcp::socket m_socket;

	ReadCall m_onRead;
	CloseCall m_onClose;

	NetBuffer m_recvBuff;

	MsgHead m_msghead;
	
	std::list<SHARE<NetBuffer>> m_writeBuff;
};

#endif
