package main

import (
	"fmt"
	"monitor/handle"
	"monitor/module"
	"monitor/util"
	"time"
	// _ "net/http/pprof"
)

func main() {
	util.Readconf("conf.ini")

	module.ServerAddr = util.GetConfValue("host")
	module.ModuleMgr.Init()
	module.ModuleMgr.InitMsg(handle.MS_BEGIN, handle.MS_END)
	fmt.Println("start main")

	// module.ModuleMgr.AddModule(module.MOD_LOGIC, &module.LogicModule{})
	module.ModuleMgr.AddModule(module.MOD_MONITOR_SERVER, &module.MonitorModule{})

	module.ModuleMgr.StartRun()
	for range time.Tick(time.Second * 60) {

	}
}
