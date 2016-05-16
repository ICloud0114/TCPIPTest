//----------------------------------------------�ļ�˵��-------------------------------------------
//�ļ�����ErroInfo.h
//������ڣ�2014-10-17
//���ߣ�������
//�汾��1.0.0.0
//��������ǰ�ļ��а�������Ĵ�������˵���Ͷ��塣Ϊ�˼��ݲ�ͬϵͳ�����д�����룬�ڿ����������и��õ�
//�Ļ��ϵͳ����״̬��������ķ������Ͷ���Ϊlong long������չϵͳ���󣬽�sdk�Ĵ���Χʹ�ö������£�
//0��ʾ�޴���
//������ʾϵͳ���󣬾��庬�������ϵͳ�ͱ�����õ���ϵͳ�ӿ��йء�
//-1��-100000000Ϊ�Զ������ھ��庯���о��嶨���˵�����纯��û��˵����ֵ����ϵͳ���󡣱����Ҫע��
//���Ʋ�Ҫ��ϵͳ�������ص���
//-100000000��long long����Сֵ,ΪSdkͨ���Զ�����󣬴�����ϸ˵������ǰ�ļ���
//�����Զ�����������Լ���˵����ע��˵���Ρ�


#ifndef __ERRO_INFO__
#define __ERRO_INFO__


//������ƺ꣬��ֵ˵�����£�
//1  Linux���л�����
//2  Andriod���л�����
//3  IOS���л�����
//4  Win32���л�����
#define SDK_COMPILE_CTRL  3


//���ݲ�ͬƽ̨���ƴ�ӡ�궨�塣
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


//0Ϊ�޴���
//1��-100000000Ϊ�����Զ��������ں���ע���и�����
//-100000000��long long����СֵΪSdkͨ�ô�����룬
//����Ϊϵͳ���󣬾��������鿴ϵͳ����꣬��Ҫת������
typedef long long ErroCode;

//-----------------------------���Զ�����������Լ���˵��------------------------------//

#define ERRO_CODE_PRODUCE(a)            	(-100000000LL-(a))

//�޴���
#define ERR_NO_ERRO                     	0

//����δ��ʼ��/δ�ܳ�ʼ���ɹ���
#define ERR_OBJECT_NOT_INIT             	ERRO_CODE_PRODUCE(0)

//�����Ѿ��ͷ�/�����ڲ��ؼ���Դ�Ѿ��ͷţ���Udp������ùرպ�������÷��ͺ������صĴ���
#define ERR_OBJECT_FREED                	ERRO_CODE_PRODUCE(1)

//��������Ч�ĺ�����δʵ�ֻ�ȡ��ʵ�ֵĺ�������Ч�Ļ��ຯ���ȣ���������������أ�����������ء�
#define ERR_INVALID_FUN            			ERRO_CODE_PRODUCE(2)

//����������Ч��������������ʧ�ܡ�
#define ERR_INVALID_PARAM               	ERRO_CODE_PRODUCE(3)

//�����ظ����ô��󣬼������Ѿ������óɹ��������Ѵ��ڸ�״̬�������������첽��������������ִ���С�
#define ERR_REPEAT_DO						ERRO_CODE_PRODUCE(4)

//�ڴ�����ʧ��/�ڴ治���޷����ָ���ĵ��á�
#define ERR_MEMORY_INSUFFICIENT	           	ERRO_CODE_PRODUCE(5)

//����ϵͳ��Դ����/������ϵͳ�ĶԸ���Դ����/�����˽��̶�ĳЩ��Դ�����ƶ�����Ĵ���
#define ERR_SYS_LIMIT           			ERRO_CODE_PRODUCE(6)


//��������
#define ERR_DEATH_LOCK           			ERRO_CODE_PRODUCE(7)


//��ַ�Ѿ���ʹ���д���
#define ERR_ADDR_IN_USE						ERRO_CODE_PRODUCE(8)

//��ַ�ڵ�ǰ�����в�����/û��Ȩ��ʹ�øõ�ַ��
#define ERR_ADDR_NOT_AVAILABLE				ERRO_CODE_PRODUCE(9)

//����̫�����޷���Ϊһ�����ݰ������ͣ�Udp�������ݰ������ƣ���Լ��65538-2-7=65507����
#define ERR_DATA_TOO_LONG					ERRO_CODE_PRODUCE(10)

//UDPδʹ�ܣ�ʹ�ù㲥��ַ�������ݴ���
#define ERR_BROADCAST_NOT_ENABLE			ERRO_CODE_PRODUCE(11)

//���粻�ɵ���޷�·�ɵ�ָ��������һ������������������δ���ӣ���wifiδ���ӣ�wifi���õȡ�
#define ERR_NET_UNREACH						ERRO_CODE_PRODUCE(12)

//ϵͳIO�ӿڶ�д����
#define ERR_SYSTEM_IO_EXCEPTION				ERRO_CODE_PRODUCE(13)



//���Ӷ������ܾ�������������δ����ָ���Ķ˿ڡ�
#define ERR_LINK_REFUSED			    	ERRO_CODE_PRODUCE(14)

//���Ӷ�����ʱ��
#define ERR_CONNECT_TIMEOUT					ERRO_CODE_PRODUCE(15)

//����δ���Ӵ���
#define ERR_NET_NOT_CONNECT			    	ERRO_CODE_PRODUCE(16)

//���ӳ�ʱ�Ͽ�������Tcp���ӶϿ�������Tcp�����˳�ʱ����������ָ���Ĵ���û���յ������Ļ�Ӧ��
#define ERR_LINK_TIMEOUT_CLOSE			    ERRO_CODE_PRODUCE(17)

//Զ�������ر����ӡ�
#define ERR_REMOTE_HOST_CLOSE				ERRO_CODE_PRODUCE(18)


//���󱻹��������Ĵ��������Ҫ��IOSϵͳ�ϳ��֡�
#define ERR_HANGUP_LEADTO_ERROR             ERRO_CODE_PRODUCE(19)

//�����ڲ���Դ���𻵣��޷�����ʹ�á�
#define ERR_OBJECT_DESTROYED                ERRO_CODE_PRODUCE(20)

//δ�����Ⱦ�������������ĳ������֮ǰû�е��ö�Ӧ��Ҫ�ȵ��õĺ�����
#define ERR_UNSTART_PRECONDITION            ERRO_CODE_PRODUCE(21)

//�Ƿ����ã���ĳЩ�ض�����£������е�ĳЩ������������á���Tcp���������е���ͬ���������Ӻ�
//�ٵ���ͬ������ͻ�����������ȡ�
#define ERR_INVALID_CALL            		ERRO_CODE_PRODUCE(22)



#endif // !__ERRO_INFO__



