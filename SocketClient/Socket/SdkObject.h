//---------------------------------文件说明-------------------------------
//文件名：SdkObject.h
//完成日期：2015-3-13
//作者：蒋东君
//版本：1.0.0.0
//描述：在跨平台环境下Sdk所有类的基类。
//

//---------------------------------修改历史-------------------------------
//每条修改记录应包含修改序号、修改日期、修改者及修改内容简介
//修改序号：1
//修改日期：
//修改者：
//修改内容：
//++++++++++++++++++++++++++++++++++++++

#ifndef __SDK_OBJECT__
#define __SDK_OBJECT__

#include <stdio.h>
#include <string.h>
#include "ErroInfo.h"

//Sdk中所有对象整个生命周期中的5种状态。
typedef enum _OBJECT_STATE
{
	OBJECT_STATE_UNINIT,		//对象内部资源未初始化。
	OBJECT_STATE_INIT_FAIL,		//初始化失败，可能对象内部部分资源已经初始化成功，所有对象功能函数不可调用，可调用释放函数。
	OBJECT_STATE_INIT_SUCCESS,	//初始化成功，对象内部资源已经全部初始化成功，对象功能函数正常调用。
	OBJECT_STATE_FREE_FAIL,		//释放失败，对象内部部分对象释放成功，部分失败，对象功能函数无法调用。
	OBJECT_STATE_FREE_SUCCESS,	//释放成功，对象内部资源全部释放成功。
}OBJECT_STATE;

//在跨平台环境下Sdk所有类的基类。
class SdkObject
{
public:
	SdkObject();
	virtual ~SdkObject();

	//函数功能：获得当前对象的状态。
	//参数说明：无。
	//返回结果：返回对象5个状态枚举值之一,可用来查看是否创建成功。
	virtual OBJECT_STATE GetObjectState();

	//函数功能：获得当前对象的错误状态。
	//参数说明：无。
	//返回结果：返回对象发生的错误代码。
	virtual ErroCode GetLastErro();

	//函数功能：释放由GetNewObject函数动态创建的对象，并将指针置空。
	//参数说明：无。
	//返回结果：无。
	static void FreeObject(SdkObject ** ppSdkObject);

protected:

	//函数功能：根据当前对象的生存状态判断对象函数是否能调用。
	//参数说明：无。
	//返回结果：可以调用返回ERR_NO_ERRO,否者返回库错误代码。
	ErroCode CallJudge();

	//对象生存状态，OBJECT_STATE枚举标识状态。状态含义说明见OBJECT_STATE枚举定义。
	OBJECT_STATE m_ObjectState;

	//对象最后的错误状态，用于在使用过程中发生错误查证。
	ErroCode m_LastErro;

private:

};

#endif
