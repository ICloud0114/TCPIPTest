//----------------------------------------------文件说明-------------------------------------------
//文件名：ErroInfo.h
//完成日期：2014-10-17
//作者：蒋东君
//版本：1.0.0.0
//描述：当前文件中包含程序的错误类型说明和定义。为了兼容不同系统的已有错误代码，在开发和升级中更好的
//的获得系统错误状态，将错误的返回类型定义为long long类型扩展系统错误，将sdk的错误范围使用定义如下：
//0表示无错误；
//正数表示系统错误，具体含义与具体系统和编程所用到的系统接口有关。
//-1至-100000000为自定区，在具体函数中具体定义和说明，如函数没有说明该值就是系统错误。编程中要注意
//控制不要与系统错误相重叠。
//-100000000至long long的最小值,为Sdk通用自定义错误，错误详细说明见当前文件的
//《库自定义错误代码宏以及其说明》注释说明段。


#ifndef __ERRO_INFO__
#define __ERRO_INFO__


//编译控制宏，其值说明如下：
//1  Linux运行环境。
//2  Andriod运行环境。
//3  IOS运行环境。
//4  Win32运行环境。
#define SDK_COMPILE_CTRL  3


//根据不同平台控制打印宏定义。
#if SDK_COMPILE_CTRL == 2
#include <errno.h>
#include <android/log.h>
#define DEBUG_PRINTF(...) __android_log_print(ANDROID_LOG_INFO, "LibTest", __VA_ARGS__)
#define ERRO_PRINTF(...)  __android_log_print(ANDROID_LOG_ERROR, "LibErro", __VA_ARGS__)

#elif SDK_COMPILE_CTRL == 1 || SDK_COMPILE_CTRL == 3
#include <errno.h>
#define DEBUG_PRINTF(...) printf(__VA_ARGS__)
#define ERRO_PRINTF(...)  printf(__VA_ARGS__)

#endif


//0为无错误。
//1至-100000000为函数自定义区，在函数注视中给出。
//-100000000至long long的最小值为Sdk通用错误代码，
//正数为系统错误，具体错误含义查看系统错误宏，需要转换或处理。
typedef long long ErroCode;

//-----------------------------库自定义错误代码宏以及其说明------------------------------//

#define ERRO_CODE_PRODUCE(a)            	(-100000000LL-(a))

//无错误。
#define ERR_NO_ERRO                     	0

//对象未初始化/未能初始化成功。
#define ERR_OBJECT_NOT_INIT             	ERRO_CODE_PRODUCE(0)

//对象已经释放/对象内部关键资源已经释放，如Udp对象调用关闭函数后调用发送函数返回的错误。
#define ERR_OBJECT_FREED                	ERRO_CODE_PRODUCE(1)

//调用了无效的函数（未实现或取消实现的函数或无效的基类函数等），如果函数有重载，请调用其重载。
#define ERR_INVALID_FUN            			ERRO_CODE_PRODUCE(2)

//函数传入无效参数，函数调用失败。
#define ERR_INVALID_PARAM               	ERRO_CODE_PRODUCE(3)

//函数重复调用错误，即函数已经被调用成功，对象已处于该状态，或函数调用是异步函数，动作正在执行中。
#define ERR_REPEAT_DO						ERRO_CODE_PRODUCE(4)

//内存申请失败/内存不足无法完成指定的调用。
#define ERR_MEMORY_INSUFFICIENT	           	ERRO_CODE_PRODUCE(5)

//由于系统资源不够/超过了系统的对该资源限制/超过了进程对某些资源的限制而引起的错误。
#define ERR_SYS_LIMIT           			ERRO_CODE_PRODUCE(6)


//死锁错误。
#define ERR_DEATH_LOCK           			ERRO_CODE_PRODUCE(7)


//地址已经在使用中错误。
#define ERR_ADDR_IN_USE						ERRO_CODE_PRODUCE(8)

//地址在当前主机中不可用/没有权限使用该地址。
#define ERR_ADDR_NOT_AVAILABLE				ERRO_CODE_PRODUCE(9)

//数据太长，无法作为一个数据包被发送，Udp发送数据包长限制（大约是65538-2-7=65507）。
#define ERR_DATA_TOO_LONG					ERRO_CODE_PRODUCE(10)

//UDP未使能，使用广播地址发送数据错误。
#define ERR_BROADCAST_NOT_ENABLE			ERRO_CODE_PRODUCE(11)

//网络不可到达，无法路由到指定主机，一般出现这种情况是网络未连接，如wifi未连接，wifi禁用等。
#define ERR_NET_UNREACH						ERRO_CODE_PRODUCE(12)

//系统IO接口读写错误。
#define ERR_SYSTEM_IO_EXCEPTION				ERRO_CODE_PRODUCE(13)



//连接动作被拒绝，服务器主机未监听指定的端口。
#define ERR_LINK_REFUSED			    	ERRO_CODE_PRODUCE(14)

//连接动作超时。
#define ERR_CONNECT_TIMEOUT					ERRO_CODE_PRODUCE(15)

//网络未连接错误。
#define ERR_NET_NOT_CONNECT			    	ERRO_CODE_PRODUCE(16)

//链接超时断开错误，在Tcp连接断开后发生，Tcp设置了超时心跳，过了指定的次数没有收到心跳的回应。
#define ERR_LINK_TIMEOUT_CLOSE			    ERRO_CODE_PRODUCE(17)

//远程主机关闭连接。
#define ERR_REMOTE_HOST_CLOSE				ERRO_CODE_PRODUCE(18)


//对象被挂起后引起的错误，这个主要是IOS系统上出现。
#define ERR_HANGUP_LEADTO_ERROR             ERRO_CODE_PRODUCE(19)

//对象内部资源被损坏，无法继续使用。
#define ERR_OBJECT_DESTROYED                ERRO_CODE_PRODUCE(20)

//未启动先决条件，即调用某个函数之前没有调用对应必要先调用的函数。
#define ERR_UNSTART_PRECONDITION            ERRO_CODE_PRODUCE(21)

//非法调用，在某些特定情况下，对象中的某些函数不允许调用。如Tcp监听对象中调用同步接受连接后，
//再调用同步对象就会出现这类错误等。
#define ERR_INVALID_CALL            		ERRO_CODE_PRODUCE(22)



#endif // !__ERRO_INFO__



