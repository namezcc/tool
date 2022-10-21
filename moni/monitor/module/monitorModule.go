package module

import (
	"bytes"
	"encoding/json"
	"hash/crc32"
	"io/ioutil"
	"monitor/handle"
	"monitor/network"
	"monitor/util"
	"net/http"
	"strconv"
)

type luaerrs struct {
	num  int
	time int64
	text string
}

type MonitorModule struct {
	ServerModule
	_luaerr map[uint32]*luaerrs
}

func (m *MonitorModule) Init(mgr *moduleMgr) {
	m.ServerModule.Init(mgr)
	m._luaerr = make(map[uint32]*luaerrs)

	handle.Handlemsg.AddMsgCall(handle.N_LOG_ERROR, m.onErrorLog)
}

type pding struct {
	Msgtype string            `json:"msgtype"`
	Text    map[string]string `json:"text"`
}

func (m *MonitorModule) onErrorLog(msg handle.BaseMsg) {
	p := msg.Data.(network.Msgpack)
	str := p.ReadString()
	pam := p.ReadString()
	hash32 := crc32.ChecksumIEEE(str)

	url := "https://oapi.dingtalk.com/robot/send?access_token=ab779f2f8a7397313e25f31aacc1a9ee3dbdd6d242fffc5e4b1e35b01ba9844f"

	lerr, ok := m._luaerr[hash32]

	if ok {
		lerr.num++
		if lerr.time > util.GetSecond() {
			return
		}

		lerr.time = util.GetSecond() + 10*60
	} else {
		lerr = &luaerrs{
			text: string(str),
			num:  1,
			time: util.GetSecond() + 10*60,
		}
		m._luaerr[hash32] = lerr
	}

	println(util.GetSecond(), hash32, lerr.num, string(str))

	cont := "luaerror:" + strconv.Itoa(lerr.num) + ":" + string(str) + string(pam)

	pjs := pding{}

	pjs.Msgtype = "text"
	pjs.Text = make(map[string]string)

	pjs.Text["content"] = cont

	js, jerr := json.Marshal(pjs)
	if jerr != nil {
		println(jerr)
		return
	}

	req, _ := http.NewRequest("POST", url, bytes.NewReader(js))

	req.Header.Set("Content-Type", "application/json; charset=utf-8")

	resp, err := http.DefaultClient.Do(req)

	if err != nil {
		println(err)
	} else {
		b, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			println(err)
		} else {
			println(string(b))
		}
	}
}
