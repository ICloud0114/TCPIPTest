//---------------------------------文件说明-------------------------------
//文件名：SdkTcpClient.h
//完成日期：2015-4-17
//作者：蒋东君
//版本：1.0.0.0
//描述：在跨平台的环境下提供Tcp客户端链接通信功能。类主要提供的函数有异步
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


#ifndef __SDK_TCP_CLIENT__
#define __SDK_TCP_CLIENT__

#include "SdkObject.h"

//发送缓冲大小。
#define TCPCLIENT_SEND_BUFFER_SIZE 4096
//接收缓冲大小。
#define TCPCLIENT_RCV_BUFFER_SIZE 4096


//Tcp通信类。
class SdkTcpClient:public SdkObject
{
public:

	//函数功能：TcpClient对象接收到数据的回调函的类型说明,在收到远程主机发送数据时发生。
	//参数说明：
	//buffer 产生调用时收到的数据，这是一个临时缓冲。
	//length 收到数据的长度。
	//pSyn	 读数据同步对象。
	//返回结果：无。
	typedef void (*RcvCallback)(unsigned char * buffer, int length, void *pSyn);

	//函数功能：返回异步连接结果，在产生链接结果时发生。
	//参数说明：
	//result 连接结果，0表示连接成功，其他对应于失败的原因。
	//pSyn	 连接结果同步对象。
	//返回结果：无。
	//链接常量说明：
	//ERR_LINK_REFUSED	链接被拒绝，可以找到远程主机，但是对方未监听指定端口/其他原因被拒绝链接。
	//ERR_NET_UNREACH	网络不可到达，不能路由到指定网络地址。
	//ERR_CONNECT_TIMEOUT	链接超时，握手包发出去后再指定的时间内没有回应。
	//其他非0代码表示链接失败，具体数字对应具体原因，上面是常见3个。
	typedef void (*ConnectCallback)(ErroCode result, void *pSyn);

	//函数功能：TcpClient连接断开时/或产生异常导致TcpClient对象关闭连接时发生。
	//参数说明：
	//code		链接断开的原因/类型。
	//pSyn		断开回调同步对象。
	//返回结果：无。
	//断开常量说明：
	//ERR_REMOTE_HOST_CLOSE	链接被远程主机关闭。
	//ERR_LINK_TIMEOUT_CLOSE	链接设置了心跳，心跳指定次数没回应被关闭。
	//其他非0代码表示链接被关闭，具体数字对应具体原因，上面是常见2个。
	typedef void (*DisconnectCallback)(ErroCode code, void *pSyn);


	//创建一个TcpClient类实例。
	SdkTcpClient();
	//释放当前对象。
	virtual ~SdkTcpClient();

	//函数功能：动态创建一个当前类的子类对象，具体对象类型由编译选项控制。
	//参数说明：无。
	//返回结果：成功返回指向锁对象的指针。
	//错误说明：无特殊说明。
	static SdkTcpClient *GetNewObject();

	//函数功能：动态创建一个当前类的子类对象，具体对象类型由编译选项控制。
	//参数说明：
	//socketHandle  已经连接成功的socket对象。
	//返回结果：成功返回指向锁对象的指针。
	//错误说明：无特殊说明。
	static SdkTcpClient *GetNewObject(int socketHandle, const char * ip, unsigned short port);

	
	//函数功能：对一个指定ip和端口的服务器发起一个异步链接。
	//连接失败/链接被断开可以再次调用链接函数，调用close()函数后将无法再调用链接。
	//参数说明：
	//ip   服务器ip地址，格式为xxx.xxx.xxx.xxx形式的字符串。
	//port 服务器端口号。
	//timeout    连接超时时间，单位毫秒。
	//callBack   回调函数指针，当连接产生结果时此函数将被调用。
	//pSynObject 连接回调函数中的同步对象。
	//返回结果：0为返回成功，否则为错误代码。
	//错误说明：
	//ERR_INVALID_PARAM	传入无效参数。
	//ERR_REPEAT_DO		重复链接，链接动作正在进行中/已经链接成功。
	//ERR_NET_UNREACH	网络不可到达。
	virtual ErroCode BeginConnect(const char * const ip, unsigned short port, int timeout,
			ConnectCallback callBack, void * pSynObject);

	//函数功能：将数据通过Tcp方式发送到服务器，同步函数。
	//参数说明：
	//buffer 发送数据缓冲。
	//offset 发送数据缓冲 buffer 相对缓冲开始索引（0）的偏移量。
	//length 从offset偏移位置开始计算的数据长度。
	//返回结果：0为返回成功，否则为错误代码。
	//错误说明：
	//ERR_INVALID_PARAM		传入无效参数。
	//ERR_NET_NOT_CONNECT	网络未连接。
	virtual ErroCode Send(unsigned char* buffer, int offset, int length);

	//函数功能：断开Tcp连接。
	//参数说明：无。
	//返回结果：0为返回成功，否则为错误代码。
	//错误说明：无。
	virtual ErroCode Disconnect();

	//函数功能：使能Tcp连接心跳检测。
	//参数说明：
	//waitTime  当Tcp连接上没有数据交换时，心跳功能启动等待的时间。
	//interval  心跳功能启动后，两个心跳包之间的发送间隔。
	//quantity  心跳探测次数，超过这个次数连接将会被认为断开。
	//返回结果：0为返回成功，否则为错误代码。
	//错误说明：
	//ERR_INVALID_PARAM	传入无效参数。
	//ERR_SYS_LIMIT		系统资源限制，设置失败。
	virtual ErroCode EnableHeartBeat(int waitTime, int interval, int quantity);


	//函数功能：获得tcp连接对象的状态。
	//参数说明：无
	//返回值：true表示当前对象到远程主机的socket状态是连通的，反之为断开的。
	virtual bool GetState();
	
	//函数功能：设置获得接收到数据后调用的通知函数，每次接收到远程主机发送的数据后回调。
	//参数说明：
	//callBack 	TcpClient::RcvCallback类型的回调函数。
	//返回结果：无
	virtual void SetRcvCallback(RcvCallback callBack);

	//函数功能：设置链接断开后的回调函数。
	//参数说明：
	//callback TcpClient::DisconnectCallback类型的链接断开回调。
	//返回值：无
	virtual void SetDisconnectCallback(DisconnectCallback callback);

	//函数功能：设置接收数据回调同步对象，该对象用于在读到数据后调用的指针函数中使用。
	//参数说明：
	//pSynObject  需要在读回调函数中使用到的对象。
	virtual void SetRcvSynObject(void * pSynObject);

	//函数功能：设置连接断开同步对象，该对象用于在连接断开后调用的回调指针函数中使用。
	//参数说明：
	//pSynObject  需要在断开回调函数中使用到的对象。
	virtual void SetDisconnectSynObject(void * pSynObject);

	//函数功能：获得在BeginConnect函数中设置的连接同步对象。
	virtual void* GetConnectSynObject();

	//函数功能：获得在SetRcvSynObject函数中设置的读同步对象。
	virtual void* GetRcvSynObject();

	//函数功能：获得在SetDisconnectSynObject函数中设置的连接断开同步对象。
	virtual void* GetDisconnectSynObject();

	//获取最后一次正确调用连接函数传入的IP地址。
	virtual char* GetIP();

	//获取最后一次正确调用连接函数传入的IP地址。
	virtual unsigned short GetPort();

protected:

	//连接状态。
	bool m_Connected;

	//读回调函数指针。
	RcvCallback m_RcvCallback;

	//连接结果回调指针。
	ConnectCallback m_ConnectCallback;

	//网络连接断开后调用的通知函数。
	DisconnectCallback m_DisconnectCallback;

	//读回调同步对象。
	void * m_pRcvSynObject;

	//连接结果回调同步对象。
	void * m_pConnectSynObject;

	//链接断开回调同步对象。
	void * m_pDisconnectSynObject;

	//连接地址。
	char m_IP[16];

	//连接端口。
	unsigned short m_Port;

private:

};


#endif // !__SDK_TCP_CLIENT__
