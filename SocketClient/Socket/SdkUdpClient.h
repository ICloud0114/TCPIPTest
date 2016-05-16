//---------------------------------文件说明-------------------------------
//文件名：SdkUdpClient.h
//完成日期：2015-4-10
//作者：蒋东君
//版本：1.0.0.0
//描述：在跨平台的环境下提供Ucp客户端通信功能。
//
//当前父类只定义基础接口，不实现相关功能，具体功能由子类实现，在父类的
//GetNewObject()中实现对应平台的子类对象创建，
//从而实现父类函数运行时的多态。更多实现细节和要求说明见每个成员的声明注释。

//---------------------------------修改历史-------------------------------
//每条修改记录应包含修改序号、修改日期、修改者及修改内容简介
//修改序号：1
//修改日期：
//修改者：
//修改内容：
//++++++++++++++++++++++++++++++++++++++

#ifndef __SDK_UDP_CLIENT__
#define __SDK_UDP_CLIENT__

#include "SdkObject.h"

//发送缓冲大小。
#define UDPCLIENT_SEND_BUFFER_SIZE 40960
//接收缓冲大小。
#define UDPCLIENT_RCV_BUFFER_SIZE  40960
//全网广播地址。
#define UDP_BROADCAST_IP "255.255.255.255"

//在跨平台环境下提供Udp通信功能的对象。
class SdkUdpClient:public SdkObject
{
public:

	//函数功能：数据接收回调函数,在收到远程主机通过Udp发送数据时发生。
	//对象产生错误时buffer、ip都为NULL，length和port值为0，调用对象的
	//GetLastErro()函数可获得对象最后发生的错误,一般情况下此时的UDP对象
    //已经异常，无法在正常使用,应该创建新的对象。
	//参数说明：
	//buffer  接收到的数据。
	//length  接收数据的长度。
	//ip      发送数据的ip地址,格式为xxx.xxx.xxx.xxx的字符串。
	//port    发送数据的端口号。
	//pSyn    同步对象。
	//错误说明：
	//ERR_SYS_LIMIT  内存不足错误。
    //ERR_HANGUP_LEADTO_ERROR 在IOS上出现，程序挂起后唤醒造成对象异常，无法再使用。
	typedef void (*RcvCallback)(unsigned char * pBuffer, int length,
			const char * pIp, unsigned short port, void *pSyn);

	//函数功能：构造函数。两个参数的带的默认参数为NULL和0。
	//仅设置IP（端口传入0）无效，不会有绑定动作。仅设置端口（IP传入NULL）会绑定到本地所有可用IP地址的端口上。
	//参数说明：
	//ip   本地ip地址字符串，格式为xxx.xxx.xxx.xxx，传入NULL表示绑定到本地所有可用地址。
	//port 需要绑定到的本地端口,0表示绑定到任意可用的端口号。
	SdkUdpClient(const char * const ip = NULL, unsigned short port = 0);
	virtual ~SdkUdpClient();

	//函数功能：动态创建一个当前类的子类对象，具体对象类型由编译选项控制。对象创建行为如构造函数描述。
	//参数说明：
	//ip   本地ip地址字符串，格式为xxx.xxx.xxx.xxx，传入NULL表示绑定到本地所有可用地址。
	//port 需要绑定到的本地端口,0表示绑定到任意可用的端口号。
	//返回结果：成功返回指向锁对象的指针，可以检查对象状态查看是否初始化成功。
	//错误说明：
	//ERR_INVALID_PARAM		传入不符合要求的参数。
	//ERR_ADDR_IN_USE		地址在使用中，无法绑定。
	//ERR_ADDR_NOT_AVAILABLE	传入的地址不能被绑定，非当前主机地址/地址在保护区间等。
	static SdkUdpClient *GetNewObject(const char * const ip = NULL, unsigned short port = 0);

	//函数功能：将数据通过Udp的方式发送到指定的目标ip和端口。
	//参数说明：
	//buffer 包含发送数据的缓冲。
	//offset 发送数据缓冲 buffer 相对缓冲开始索引（0）的偏移量。
	//length 从offset偏移位置开始需要发送数据的长度。
	//ip     接收数据的目标ip地址字符串，格式为xxx.xxx.xxx.xxx。
	//port   目标主机的接收端口。
	//返回结果：成功返回ERR_NO_ERRO，否则为库错误代码。
	//错误说明：
	//ERR_INVALID_PARAM		传入错误参数。
	//ERR_DATA_TOO_LONG		发送数据长度太长。
	//ERR_BROADCAST_NOT_ENABLE	未开启广播功能，无发送发送广播数据。
	//ERR_ADDR_NOT_AVAILABLE	接收地址处于非法地址空间，仅见于IOS上。
	//ERR_NET_UNREACH		网络不可到达，无路由路径到达指定的接收地址。
	//ERR_SYS_LIMIT			系统内存错误。
    //ERR_OBJECT_DESTROYED  对象内部关键资源损坏，无法调用。
	virtual ErroCode Send(unsigned char * buffer, int offset, int length,
			const char * const ip, unsigned short port);

	//函数功能：关闭Udp通信功能,并释放socket相关资源。
	//参数说明：无。
	//返回结果：成功返回ERR_NO_ERRO，否则为库错误代码。
	//错误说明：无。
	virtual ErroCode Close();

	//函数功能：开启当前UDP对象的广播功能。
	//参数说明：无。
	//返回结果：成功返回ERR_NO_ERRO，否则为库错误代码。
	//错误说明：
	//ERR_SYS_LIMIT		系统内存不足错误。
	virtual ErroCode EnableBroadcast();

	//函数功能：设置接收到数据后的回调函数。
	//参数说明：
	//callBack  UdpClient::RcvCallback类型的回调函数。
	//返回结果：无。
	virtual void SetRcvCallback(RcvCallback callBack);

	//函数功能：设置接收数据回调函数中的同步对象，该对象将传递给接收数据回调函数。
	//参数说明：
	//pSynObject   需要在接收数据回调函数中使用到的对象。
	//返回结果：无。
	virtual void SetRcvSynObject(void * pSynObject);

	//函数功能：获取接收数据回调函数中的同步对象。
	//参数说明：无。
	//返回结果：返回接收数据回调函数中的同步对象指针。
	virtual void* GetRcvSynObject();

protected:

	//接收到数据回调函数指针。
	RcvCallback m_pRcvCallback;

	//接收到数据同步对象，该对象用于在接收到数据后调用的指针函数中使用。
	void * m_pRcvSynObject;

	//绑定的本地Ip地址。
	char * m_pLocalIP;

	//绑定的本地端口。
	unsigned short m_LocalPort;
};


#endif // !__SDK_UDP_CLIENT__
