package module

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"monitor/handle"
	"monitor/network"
	"monitor/util"
	"net/http"
	"strconv"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	_ "github.com/go-sql-driver/mysql"
	"github.com/jmoiron/sqlx"
)

type responesData struct {
	index int
	data  interface{}
}

type msgResponse struct {
	_c       chan *responesData
	_endtime int64
	_id      int
}

type HttpModule struct {
	modulebase
	_msg_response   map[int]msgResponse
	_rsp_index      int
	_rsp_index_lock sync.Mutex
	_net_mod        *netModule
	_master_mod     *MasterModule
	_sql            *sqlx.DB
}

func (m *HttpModule) Init(mgr *moduleMgr) {
	m._mod_mgr = mgr
	m._msg_response = make(map[int]msgResponse)
	m._rsp_index = 0
	m._net_mod = mgr.GetModule(MOD_NET).(*netModule)
	m._master_mod = mgr.GetModule(MOD_MASTER).(*MasterModule)

	handle.Handlemsg.AddMsgCall(handle.M_ON_RESPONSE, m.onMsgRespones)

	host := util.GetConfValue("mysql")

	sql, sqlerr := sqlx.Open("mysql", host)
	m._sql = sql

	if sqlerr != nil {
		panic("sql open error:" + sqlerr.Error())
	}

	sql.SetMaxOpenConns(100)
	// 闲置连接数
	sql.SetMaxIdleConns(20)
	// 最大连接周期
	sql.SetConnMaxLifetime(100 * time.Second)
}

func Cors() gin.HandlerFunc {
	return func(c *gin.Context) {
		origin := c.Request.Header.Get("origin") //请求头部
		if len(origin) == 0 {
			origin = c.Request.Header.Get("Origin")
		}
		//接收客户端发送的origin （重要！）
		c.Writer.Header().Set("Access-Control-Allow-Origin", origin)
		//允许客户端传递校验信息比如 cookie (重要)
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		//服务器支持的所有跨域请求的方法
		c.Writer.Header().Set("Access-Control-Allow-Methods", "OPTIONS, GET, POST, PUT, DELETE, UPDATE")
		c.Writer.Header().Set("Content-Type", "application/json; charset=utf-8")
		// 设置预验请求有效期为 86400 秒
		c.Writer.Header().Set("Access-Control-Max-Age", "86400")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	}
}

func (m *HttpModule) AfterInit() {

	router := gin.Default()

	router.Use(Cors())

	router.GET("/", m.apiIndex)
	router.GET("/serverInfo", m.getServerState)
	router.GET("/machine", m.getMachine)
	router.GET("/viewMachine", m.viewMachine)
	router.GET("/getServer", m.getServerInfo)
	router.POST("/hotload", m.reqLoginHotLoad)
	router.POST("/aiupdate", m.reqAiUpdate)
	router.POST("/userlogin", m.userLogin)

	host := util.GetConfValue("webhost")

	go func() {
		router.Run(host)
		fmt.Println("start http server")
	}()

	m.setTikerFunc(time.Second*5, m.checkRespones)
}

func (m *HttpModule) requestMsg(mod modulebase, mid int, d interface{}) *responesData {
	mrsp := m.getRespones()

	mod.sendMsg(mid, responesData{
		index: mrsp._id,
		data:  d,
	})

	getpack := <-mrsp._c
	return getpack
}

func (m *HttpModule) getRespones() msgResponse {
	m._rsp_index_lock.Lock()
	defer m._rsp_index_lock.Unlock()
	msg := msgResponse{
		_c:       make(chan *responesData),
		_endtime: util.GetMillisecond() + 500000, //5s
		_id:      m._rsp_index,
	}
	m._msg_response[m._rsp_index] = msg
	m._rsp_index++
	return msg
}

func (m *HttpModule) checkRespones(dt int64) {
	m._rsp_index_lock.Lock()
	defer m._rsp_index_lock.Unlock()

	for k, v := range m._msg_response {
		if dt > v._endtime {
			v._c <- nil
			delete(m._msg_response, k)
		}
	}
}

func (m *HttpModule) onMsgRespones(msg handle.BaseMsg) {
	pack := msg.Data.(responesData)
	index := pack.index
	m._rsp_index_lock.Lock()
	rsp, ok := m._msg_response[int(index)]
	if !ok {
		m._rsp_index_lock.Unlock()
		return
	}
	delete(m._msg_response, int(index))
	m._rsp_index_lock.Unlock()

	rsp._c <- &pack
}

func (m *HttpModule) apiIndex(c *gin.Context) {
	fmt.Println(c.Request.Method, c.Request.URL)

	pack := m.requestMsg(m._master_mod.modulebase, handle.N_WBE_REQUEST_1, nil)
	if pack == nil {
		c.String(http.StatusOK, "getpack nil")
		return
	}

	c.String(http.StatusOK, string(""))
}

type dbMachine struct {
	Id int    `db:"id" json:"id"`
	Ip string `db:"ip" json:"ip"`
}

type dbServer struct {
	Type int    `db:"type" json:"type"`
	Id   int    `db:"id" json:"id"`
	Name string `db:"name" json:"name"`
	Ip   string `db:"ip" json:"ip"`
	Port int    `db:"port" json:"port"`
}

type servernode struct {
	Type  int    `json:"type"`
	Id    int    `json:"id"`
	Name  string `json:"name"`
	Ip    string `json:"ip"`
	Open  int    `json:"open"`
	Error int    `json:"error"`
}

func (m *HttpModule) getServerState(c *gin.Context) {

	pack := m.requestMsg(m._master_mod.modulebase, handle.M_GET_SERVER_STATE, nil)
	if pack == nil {
		c.String(http.StatusOK, "[]")
		return
	}
	var serverInfo []dbServer

	err := m._sql.Select(&serverInfo, "SELECT * FROM `server`;")
	if err != nil {
		println(err.Error())
		c.String(http.StatusOK, "[]")
		return
	}

	serstate := pack.data.(map[int32]int32)

	snode := make([]servernode, 0, len(serverInfo))

	for _, v := range serverInfo {
		key := (v.Type << 16) | v.Id

		state, ok := serstate[int32(key)]
		open := 0
		if ok {
			open = 1
		} else {
			state = 0
		}

		snode = append(snode, servernode{
			Type:  v.Type,
			Id:    v.Id,
			Name:  v.Name,
			Ip:    v.Ip,
			Open:  open,
			Error: int(state),
		})
	}

	c.JSON(http.StatusOK, snode)
}

func (m *HttpModule) getMachine(c *gin.Context) {

	var machines []dbMachine
	err := m._sql.Select(&machines, "select * from machine;")
	if err != nil {
		c.String(http.StatusOK, err.Error())
		return
	}

	// js, _ := json.Marshal(machines)
	// c.String(http.StatusOK, "")
	c.JSON(http.StatusOK, machines)

}

type machineInfo struct {
	Open   int32        `json:"open"`
	Server []servernode `json:"server"`
}

var serverName = map[int32]string{
	1:  "proxy",
	2:  "login",
	3:  "mysqlServer",
	4:  "proxy",
	7:  "dbproxy",
	8:  "room",
	9:  "room mgr",
	10: "loginLock",
	15: "team",
	17: "account_db",
	18: "teamproxy",
}

func (m *HttpModule) viewMachine(c *gin.Context) {

	minfo := machineInfo{
		Open: 0,
	}

	id, _ := strconv.Atoi(c.Query("id"))
	if id == 0 {
		c.JSON(http.StatusOK, minfo)
		return
	}

	pack := m.requestMsg(m._master_mod.modulebase, handle.N_WEB_VIEW_MACHINE, id)
	if pack == nil {
		c.JSON(http.StatusOK, minfo)
		return
	}

	// minfo.Open = pack.ReadInt32()

	// num := pack.ReadInt32()

	// for i := 0; i < int(num); i++ {
	// 	type_ := pack.ReadInt32()
	// 	id_ := pack.ReadInt32()
	// 	open_ := pack.ReadInt32()
	// 	err_ := pack.ReadInt32()

	// 	minfo.Server = append(minfo.Server, servernode{
	// 		Type:  type_,
	// 		Name:  serverName[type_],
	// 		Id:    id_,
	// 		Open:  open_,
	// 		Error: err_,
	// 	})
	// }

	c.JSON(http.StatusOK, minfo)
}

type serLink struct {
	Name string
	Type int32
	Id   int32
	Port int32
	Open int32
}

type serInfo struct {
	Link []serLink
}

func (m *HttpModule) getServerInfo(c *gin.Context) {

	mid, _ := strconv.Atoi(c.Query("mid"))
	sertype, _ := strconv.Atoi(c.Query("type"))
	serid, _ := strconv.Atoi(c.Query("id"))

	spack := network.NewMsgPackDef()
	spack.WriteInt32(mid)
	spack.WriteInt32(sertype)
	spack.WriteInt32(serid)

	var vserInfo serInfo

	pack := m.requestMsg(m._master_mod.modulebase, handle.N_WEB_GET_SERVER_INFO, spack)
	if pack == nil {
		c.JSON(http.StatusOK, vserInfo)
		return
	}

	// num := pack.ReadInt32()

	// for i := 0; i < int(num); i++ {

	// 	lst := pack.ReadInt32()
	// 	vserInfo.Link = append(vserInfo.Link, serLink{
	// 		Name: serverName[lst],
	// 		Type: lst,
	// 		Id:   pack.ReadInt32(),
	// 		Port: pack.ReadInt32(),
	// 		Open: pack.ReadInt32(),
	// 	})
	// }

	c.JSON(http.StatusOK, vserInfo)
}

type hotInfo struct {
	Lua    string `json:"lua"`
	Server []int  `json:"server"`
	Except []int  `json:"except"`
}

func (m *HttpModule) reqLoginHotLoad(c *gin.Context) {
	buf, err := ioutil.ReadAll(c.Request.Body)
	if err != nil {
		c.String(http.StatusOK, err.Error())
		return
	}

	var info hotInfo

	err = json.Unmarshal(buf, &info)
	if err != nil {
		c.String(http.StatusOK, err.Error())
		return
	}

	// println(info.Lua)
	c.String(http.StatusOK, "ok")
	m._master_mod.sendMsg(handle.M_HOT_LOAD, info)
}

func (m *HttpModule) reqAiUpdate(c *gin.Context) {
	buf, err := ioutil.ReadAll(c.Request.Body)
	if err != nil {
		c.String(http.StatusOK, err.Error())
		return
	}

	var info hotInfo

	err = json.Unmarshal(buf, &info)
	if err != nil {
		c.String(http.StatusOK, err.Error())
		return
	}

	// println(info.Lua)
	c.String(http.StatusOK, "ok")
	m._master_mod.sendMsg(handle.M_AI_UPDATE, info)
}

type userInfo struct {
	Name string `json:"name"`
	Pass string `json:"pass"`
}

type dbAdmin struct {
	Name string `db:"name" json:"name"`
	Pass string `db:"pass" json:"pass"`
}

func (m *HttpModule) userLogin(c *gin.Context) {
	buf, err := ioutil.ReadAll(c.Request.Body)
	if err != nil {
		c.String(http.StatusOK, err.Error())
		return
	}

	var info userInfo

	err = json.Unmarshal(buf, &info)
	if err != nil {
		c.String(http.StatusOK, err.Error())
		return
	}

	var dbuser dbAdmin

	err = m._sql.QueryRow("SELECT * FROM `admin` WHERE `name`=?;", info.Name).Scan(&dbuser.Name, &dbuser.Pass)
	if err != nil {
		println(err.Error())
		c.String(http.StatusOK, "0")
		return
	}

	if info.Pass == dbuser.Pass {
		c.String(http.StatusOK, "1")
	} else {
		c.String(http.StatusOK, "0")
	}
}
