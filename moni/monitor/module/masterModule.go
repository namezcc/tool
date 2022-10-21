package module

import (
	"monitor/handle"
	"monitor/network"
	"monitor/util"
)

const (
	ST_LOGIN = 2
)

type serverInfo struct {
	stype  int32
	sid    int32
	state  int32
	connid int
}

type MasterModule struct {
	ServerModule
	servers   map[int]serverInfo
	_http_mod *HttpModule
}

func (m *MasterModule) Init(mgr *moduleMgr) {
	m.ServerModule.Init(mgr)

	m.servers = make(map[int]serverInfo)

	m._http_mod = mgr.GetModule(MOD_HTTP).(*HttpModule)

	util.EventMgr.AddEventCall(util.EV_CONN_CLOSE, m, m.onServerClose)

	handle.Handlemsg.AddMsgCall(handle.N_SERVER_REGIST, m.onServerRegist)

	handle.Handlemsg.AddMsgCall(handle.M_GET_SERVER_STATE, m.onGetServerState)
	handle.Handlemsg.AddMsgCall(handle.M_HOT_LOAD, m.onLoginHotLoad)
	handle.Handlemsg.AddMsgCall(handle.M_AI_UPDATE, m.onLoginAiUpdate)

}

func (m *MasterModule) onServerRegist(msg handle.BaseMsg) {
	p := msg.Data.(network.Msgpack)
	ser_type := p.ReadInt32()
	ser_id := p.ReadInt32()

	info := serverInfo{
		stype:  ser_type,
		sid:    ser_id,
		state:  0,
		connid: p.ConnId(),
	}

	println(util.NowTime(), "server regist type:", ser_type, "serid:", ser_id)
	m.servers[info.connid] = info
}

func (m *MasterModule) onGetServerState(msg handle.BaseMsg) {
	rep := msg.Data.(responesData)

	serstate := make(map[int32]int32)

	for _, v := range m.servers {
		key := (v.stype << 16) | v.sid
		serstate[key] = v.state
	}

	rep.data = serstate
	m._http_mod.sendMsg(handle.M_ON_RESPONSE, rep)
}

func (m *MasterModule) onServerClose(d interface{}) {
	cid := d.(int)

	_, ok := m.servers[cid]

	if ok {
		delete(m.servers, cid)
	}
}

func (m *MasterModule) onLoginHotLoad(msg handle.BaseMsg) {
	if len(m.servers) == 0 {
		return
	}

	info := msg.Data.(hotInfo)

	if len(info.Server) > 0 {
		for _, v := range info.Server {
			ser, ok := m.servers[v]
			if ok {
				pack := network.NewMsgPack(len(info.Lua))
				pack.WriteString([]byte(info.Lua))
				m._net.SendPackMsg(ser.connid, handle.IM_LOGIN_WEB_HOTLOAD, pack)
			}
		}
	} else {
		check := make(map[int]int)
		for _, v := range info.Except {
			check[v] = 1
		}

		for _, v := range m.servers {
			if v.stype != ST_LOGIN {
				continue
			}
			_, ok := check[int(v.sid)]
			if ok {
				continue
			}

			pack := network.NewMsgPack(len(info.Lua))
			pack.WriteString([]byte(info.Lua))
			m._net.SendPackMsg(v.connid, handle.IM_LOGIN_WEB_HOTLOAD, pack)
		}
	}
}

func (m *MasterModule) onLoginAiUpdate(msg handle.BaseMsg) {
	info := msg.Data.(hotInfo)
	for _, v := range m.servers {
		if v.stype != ST_LOGIN {
			continue
		}

		pack := network.NewMsgPack(len(info.Lua))
		pack.WriteString([]byte(info.Lua))
		m._net.SendPackMsg(v.connid, handle.IM_LOGIN_AI_UPDATE, pack)
	}
}
