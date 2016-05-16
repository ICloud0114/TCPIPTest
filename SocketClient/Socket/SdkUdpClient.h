//---------------------------------�ļ�˵��-------------------------------
//�ļ�����SdkUdpClient.h
//������ڣ�2015-4-10
//���ߣ�������
//�汾��1.0.0.0
//�������ڿ�ƽ̨�Ļ������ṩUcp�ͻ���ͨ�Ź��ܡ�
//
//��ǰ����ֻ��������ӿڣ���ʵ����ع��ܣ����幦��������ʵ�֣��ڸ����
//GetNewObject()��ʵ�ֶ�Ӧƽ̨��������󴴽���
//�Ӷ�ʵ�ָ��ຯ������ʱ�Ķ�̬������ʵ��ϸ�ں�Ҫ��˵����ÿ����Ա������ע�͡�

//---------------------------------�޸���ʷ-------------------------------
//ÿ���޸ļ�¼Ӧ�����޸���š��޸����ڡ��޸��߼��޸����ݼ��
//�޸���ţ�1
//�޸����ڣ�
//�޸��ߣ�
//�޸����ݣ�
//++++++++++++++++++++++++++++++++++++++

#ifndef __SDK_UDP_CLIENT__
#define __SDK_UDP_CLIENT__

#include "SdkObject.h"

//���ͻ����С��
#define UDPCLIENT_SEND_BUFFER_SIZE 40960
//���ջ����С��
#define UDPCLIENT_RCV_BUFFER_SIZE  40960
//ȫ���㲥��ַ��
#define UDP_BROADCAST_IP "255.255.255.255"

//�ڿ�ƽ̨�������ṩUdpͨ�Ź��ܵĶ���
class SdkUdpClient:public SdkObject
{
public:

	//�������ܣ����ݽ��ջص�����,���յ�Զ������ͨ��Udp��������ʱ������
	//�����������ʱbuffer��ip��ΪNULL��length��portֵΪ0�����ö����
	//GetLastErro()�����ɻ�ö���������Ĵ���,һ������´�ʱ��UDP����
    //�Ѿ��쳣���޷�������ʹ��,Ӧ�ô����µĶ���
	//����˵����
	//buffer  ���յ������ݡ�
	//length  �������ݵĳ��ȡ�
	//ip      �������ݵ�ip��ַ,��ʽΪxxx.xxx.xxx.xxx���ַ�����
	//port    �������ݵĶ˿ںš�
	//pSyn    ͬ������
	//����˵����
	//ERR_SYS_LIMIT  �ڴ治�����
    //ERR_HANGUP_LEADTO_ERROR ��IOS�ϳ��֣�������������ɶ����쳣���޷���ʹ�á�
	typedef void (*RcvCallback)(unsigned char * pBuffer, int length,
			const char * pIp, unsigned short port, void *pSyn);

	//�������ܣ����캯�������������Ĵ���Ĭ�ϲ���ΪNULL��0��
	//������IP���˿ڴ���0����Ч�������а󶨶����������ö˿ڣ�IP����NULL����󶨵��������п���IP��ַ�Ķ˿��ϡ�
	//����˵����
	//ip   ����ip��ַ�ַ�������ʽΪxxx.xxx.xxx.xxx������NULL��ʾ�󶨵��������п��õ�ַ��
	//port ��Ҫ�󶨵��ı��ض˿�,0��ʾ�󶨵�������õĶ˿ںš�
	SdkUdpClient(const char * const ip = NULL, unsigned short port = 0);
	virtual ~SdkUdpClient();

	//�������ܣ���̬����һ����ǰ���������󣬾�����������ɱ���ѡ����ơ����󴴽���Ϊ�繹�캯��������
	//����˵����
	//ip   ����ip��ַ�ַ�������ʽΪxxx.xxx.xxx.xxx������NULL��ʾ�󶨵��������п��õ�ַ��
	//port ��Ҫ�󶨵��ı��ض˿�,0��ʾ�󶨵�������õĶ˿ںš�
	//���ؽ�����ɹ�����ָ���������ָ�룬���Լ�����״̬�鿴�Ƿ��ʼ���ɹ���
	//����˵����
	//ERR_INVALID_PARAM		���벻����Ҫ��Ĳ�����
	//ERR_ADDR_IN_USE		��ַ��ʹ���У��޷��󶨡�
	//ERR_ADDR_NOT_AVAILABLE	����ĵ�ַ���ܱ��󶨣��ǵ�ǰ������ַ/��ַ�ڱ�������ȡ�
	static SdkUdpClient *GetNewObject(const char * const ip = NULL, unsigned short port = 0);

	//�������ܣ�������ͨ��Udp�ķ�ʽ���͵�ָ����Ŀ��ip�Ͷ˿ڡ�
	//����˵����
	//buffer �����������ݵĻ��塣
	//offset �������ݻ��� buffer ��Ի��忪ʼ������0����ƫ������
	//length ��offsetƫ��λ�ÿ�ʼ��Ҫ�������ݵĳ��ȡ�
	//ip     �������ݵ�Ŀ��ip��ַ�ַ�������ʽΪxxx.xxx.xxx.xxx��
	//port   Ŀ�������Ľ��ն˿ڡ�
	//���ؽ�����ɹ�����ERR_NO_ERRO������Ϊ�������롣
	//����˵����
	//ERR_INVALID_PARAM		������������
	//ERR_DATA_TOO_LONG		�������ݳ���̫����
	//ERR_BROADCAST_NOT_ENABLE	δ�����㲥���ܣ��޷��ͷ��͹㲥���ݡ�
	//ERR_ADDR_NOT_AVAILABLE	���յ�ַ���ڷǷ���ַ�ռ䣬������IOS�ϡ�
	//ERR_NET_UNREACH		���粻�ɵ����·��·������ָ���Ľ��յ�ַ��
	//ERR_SYS_LIMIT			ϵͳ�ڴ����
    //ERR_OBJECT_DESTROYED  �����ڲ��ؼ���Դ�𻵣��޷����á�
	virtual ErroCode Send(unsigned char * buffer, int offset, int length,
			const char * const ip, unsigned short port);

	//�������ܣ��ر�Udpͨ�Ź���,���ͷ�socket�����Դ��
	//����˵�����ޡ�
	//���ؽ�����ɹ�����ERR_NO_ERRO������Ϊ�������롣
	//����˵�����ޡ�
	virtual ErroCode Close();

	//�������ܣ�������ǰUDP����Ĺ㲥���ܡ�
	//����˵�����ޡ�
	//���ؽ�����ɹ�����ERR_NO_ERRO������Ϊ�������롣
	//����˵����
	//ERR_SYS_LIMIT		ϵͳ�ڴ治�����
	virtual ErroCode EnableBroadcast();

	//�������ܣ����ý��յ����ݺ�Ļص�������
	//����˵����
	//callBack  UdpClient::RcvCallback���͵Ļص�������
	//���ؽ�����ޡ�
	virtual void SetRcvCallback(RcvCallback callBack);

	//�������ܣ����ý������ݻص������е�ͬ�����󣬸ö��󽫴��ݸ��������ݻص�������
	//����˵����
	//pSynObject   ��Ҫ�ڽ������ݻص�������ʹ�õ��Ķ���
	//���ؽ�����ޡ�
	virtual void SetRcvSynObject(void * pSynObject);

	//�������ܣ���ȡ�������ݻص������е�ͬ������
	//����˵�����ޡ�
	//���ؽ�������ؽ������ݻص������е�ͬ������ָ�롣
	virtual void* GetRcvSynObject();

protected:

	//���յ����ݻص�����ָ�롣
	RcvCallback m_pRcvCallback;

	//���յ�����ͬ�����󣬸ö��������ڽ��յ����ݺ���õ�ָ�뺯����ʹ�á�
	void * m_pRcvSynObject;

	//�󶨵ı���Ip��ַ��
	char * m_pLocalIP;

	//�󶨵ı��ض˿ڡ�
	unsigned short m_LocalPort;
};


#endif // !__SDK_UDP_CLIENT__
