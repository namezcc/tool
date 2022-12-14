// Robot.cpp: 定义控制台应用程序的入口点。
//

#include <thread>
#include <chrono>
#include <assert.h>

#include "ClientGame.h"
#include "InputCmd.h"

static int64_t GetMilliSecend()
{
	return std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
}

static int32_t MilliSecend(lua_State *L)
{
	int64_t sec = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
	lua_pushinteger(L, sec);
	return 1;
}

class BaseA
{
public:
	virtual void testFunc()
	{
		std::cout << "BaseA" << std::endl;
	}
};

class BaseB
{
public:
	virtual void testFunc()
	{
		std::cout << "BaseB" << std::endl;
	}
};

class BaseC:public BaseA,public BaseB
{
public:

	virtual void testFunc()
	{
		std::cout << "BaseC" << std::endl;
		BaseA::testFunc();
		BaseB::testFunc();
	}

};

int main(int argc, char const *argv[])
{


#ifdef _WIN32
	//控制台显示乱码纠正
	system("chcp 65001");
	CONSOLE_FONT_INFOEX info = { 0 }; // 以下设置字体来支持中文显示。
	info.cbSize = sizeof(info);
	info.dwFontSize.X = 8;
	info.dwFontSize.Y = 16; // leave X as zero
	info.FontWeight = FW_MEDIUM;
	wcscpy(info.FaceName, L"Consolas");
	SetCurrentConsoleFontEx(GetStdHandle(STD_OUTPUT_HANDLE), NULL, &info);
#endif

	int32_t gameid = 0; 
	if (argc == 2)
	{
		gameid = atoi(argv[1]);
	}

	InputCmd inputcmd;
	inputcmd.Run();

	ClientGame game;
	game.init();

	game.GetLuaState()->BindLuaOrgCall("GetMilliSecend", &MilliSecend);

	if (!game.LoadMainScripet("./script/main.lua", "Main"))
		assert(0);

	game.GetLuaState()->RegistGlobalFunc("UpdateGame", true);
	game.GetLuaState()->CallGlobalLuaFunc("GameInit", gameid);


	game.SetInputCmd(&inputcmd);
	game.BindCmdLuaFunc("DoCmdFunction");

	while (true)
	{
		auto dt = GetMilliSecend();
		game.Run(dt);
		std::this_thread::sleep_for(std::chrono::milliseconds(1));
	}
    return 0;
}

