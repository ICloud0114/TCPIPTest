//---------------------------------文件说明-------------------------------
//文件名：SdkTcpListener.h
//完成日期：2015-7-1
//作者：蒋东君
//版本：1.0.0.0
//描述：在跨平台的环境下提供Tcp服务器监听功能。类主要提供的函数有异步
//链接函数、同步的发送函数、读回调等，无特殊说明。
//
//当前基类只定义基础接口，不实现相关功能，具体的操作由子类实现，更多实现细节
//要求见每个成员的声明注视。

//---------------------------------修改历史-------------------------------
//每条修改记录应包含修改序号、修改日期、修改者及修改内容简介
//修改序号：1
//修改日期：
//修改者：
//修改内容：
//++++++++++++++++++++++++++++++++++++++

#ifndef __SDK_TCP_LISTENER__
#define __SDK_TCP_LISTENER__

#include "SdkObject.h"
#include "SdkTcpClient.h"

//Tcp通信类。
class SdkTcpListener:public SdkObject
{
public:

	//函数功能：TcpListener监听并收到连接后的回调函数。
	//参数说明：
	//pClient 	连接到服务器的客户端，动态创建，用完需要调用delete释放。
	//当pClient为NULL，说明监听出现了错误，可以调用对象的GetLastErro函数获得发生的错误。
	//pSyn	 	开始接受连接函数传入的同步对象。
	//返回结果：无。
	typedef void (*AcceptCallback)(SdkTcpClient * pClient, void *pSyn);

	//创建一个TcpClient类实例。
	SdkTcpListener(){};
	//释放当前对象。
	virtual ~SdkTcpListener(){};

	//函数功能：动态创建一个当前类的子类对象，具体对象类型由编译选项控制。
	//参数说明：
	//返回结果：成功返回指向锁对象的指针。
	//错误说明：无特殊说明。
	static SdkTcpListener *GetNewObject();


	//函数功能：在启动监听的端口上启动异步接收链接操作。
	//参数说明：
	//callBack   回调函数指针，当有链接连接上服务器时促发回调函数。
	//pSynObject 连接回调函数中的同步对象。
	//返回结果：0为返回成功，否则为错误代码。
	//错误说明：
	//ERR_UNSTART_PRECONDITION	未启动监听，无法启动接受链接。
	//ERR_INVALID_CALL	非法调用，对象处于同步接收状态中，无法调用异步接收链接。
	//ERR_REPEAT_DO		重复调用，异步接收连接已经启动。
	virtual ErroCode BeginAccept(AcceptCallback callBack, void * pSynObject) = 0;

	//函数功能：阻塞当前线程，开始接收对服务器的连接，一旦收到一个连接就立即返回。
	//参数说明：无。
	//返回结果：成功获得连接上主机的链接，服务器异常返回NULL，可以调用对象的GetLastErro函数获得发生的错误。
	//错误说明：
	//ERR_UNSTART_PRECONDITION	未启动监听，无法启动接受链接。
	//ERR_INVALID_CALL	非法调用，对象处于异步接收状态中，无法调用阻塞接收链接函数。
	virtual SdkTcpClient* Accept() = 0;

	//函数功能：启动端口监听。
	//参数说明：无。
	//返回结果：0为返回成功，否则为错误代码。
	//错误说明：
	//ERR_SYS_LIMIT  	系统资源限制，启动监听失败。
	//ERR_ADDR_IN_USE	端口被占用，启动监听失败。
	//ERR_ADDR_NOT_AVAILABLE	端口不可用，端口在非用户段的端口。
	virtual ErroCode Start(unsigned short port) = 0;

	//函数功能：停止监听。
	//参数说明：无。
	//返回结果：0为返回成功，否则为错误代码。
	//错误说明：无。
	virtual void Stop() = 0;

	//函数功能：获取监听对象的监听状态，true表示启动，false表示没有启动监听。
	virtual bool GetListenerState() = 0;

	//函数功能：获取设置的监听端口号。
	virtual unsigned short GetPort() = 0;

	//函数功能：获得接收客户端连接成功后回调的函数指针。
	//参数说明：无。
	//返回结果：收到客户端连接后的回调函数。
	virtual AcceptCallback GetAcceptCallback() = 0;

	//函数功能：获得接收客户端连接的同步对象。
	virtual void* GetAcceptSynObject() = 0;
};

#endif // !__SDK_TCP_LISTENER__
