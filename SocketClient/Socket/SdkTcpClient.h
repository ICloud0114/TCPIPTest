//---------------------------------�ļ�˵��-------------------------------
//�ļ�����SdkTcpClient.h
//������ڣ�2015-4-17
//���ߣ�������
//�汾��1.0.0.0
//�������ڿ�ƽ̨�Ļ������ṩTcp�ͻ�������ͨ�Ź��ܡ�����Ҫ�ṩ�ĺ������첽
//���Ӻ�����ͬ���ķ��ͺ��������ص��ȣ�������˵����
//
//��ǰ����ֻ��������ӿڣ���ʵ����ع��ܣ�����Ĳ���������ʵ�֣�����ʵ��ϸ��
//Ҫ���ÿ����Ա������ע�ӡ�

//---------------------------------�޸���ʷ-------------------------------
//ÿ���޸ļ�¼Ӧ�����޸���š��޸����ڡ��޸��߼��޸����ݼ��
//�޸���ţ�1
//�޸����ڣ�
//�޸��ߣ�
//�޸����ݣ�
//++++++++++++++++++++++++++++++++++++++


#ifndef __SDK_TCP_CLIENT__
#define __SDK_TCP_CLIENT__

#include "SdkObject.h"

//���ͻ����С��
#define TCPCLIENT_SEND_BUFFER_SIZE 4096
//���ջ����С��
#define TCPCLIENT_RCV_BUFFER_SIZE 4096


//Tcpͨ���ࡣ
class SdkTcpClient:public SdkObject
{
public:

	//�������ܣ�TcpClient������յ����ݵĻص���������˵��,���յ�Զ��������������ʱ������
	//����˵����
	//buffer ��������ʱ�յ������ݣ�����һ����ʱ���塣
	//length �յ����ݵĳ��ȡ�
	//pSyn	 ������ͬ������
	//���ؽ�����ޡ�
	typedef void (*RcvCallback)(unsigned char * buffer, int length, void *pSyn);

	//�������ܣ������첽���ӽ�����ڲ������ӽ��ʱ������
	//����˵����
	//result ���ӽ����0��ʾ���ӳɹ���������Ӧ��ʧ�ܵ�ԭ��
	//pSyn	 ���ӽ��ͬ������
	//���ؽ�����ޡ�
	//���ӳ���˵����
	//ERR_LINK_REFUSED	���ӱ��ܾ��������ҵ�Զ�����������ǶԷ�δ����ָ���˿�/����ԭ�򱻾ܾ����ӡ�
	//ERR_NET_UNREACH	���粻�ɵ������·�ɵ�ָ�������ַ��
	//ERR_CONNECT_TIMEOUT	���ӳ�ʱ�����ְ�����ȥ����ָ����ʱ����û�л�Ӧ��
	//������0�����ʾ����ʧ�ܣ��������ֶ�Ӧ����ԭ�������ǳ���3����
	typedef void (*ConnectCallback)(ErroCode result, void *pSyn);

	//�������ܣ�TcpClient���ӶϿ�ʱ/������쳣����TcpClient����ر�����ʱ������
	//����˵����
	//code		���ӶϿ���ԭ��/���͡�
	//pSyn		�Ͽ��ص�ͬ������
	//���ؽ�����ޡ�
	//�Ͽ�����˵����
	//ERR_REMOTE_HOST_CLOSE	���ӱ�Զ�������رա�
	//ERR_LINK_TIMEOUT_CLOSE	��������������������ָ������û��Ӧ���رա�
	//������0�����ʾ���ӱ��رգ��������ֶ�Ӧ����ԭ�������ǳ���2����
	typedef void (*DisconnectCallback)(ErroCode code, void *pSyn);


	//����һ��TcpClient��ʵ����
	SdkTcpClient();
	//�ͷŵ�ǰ����
	virtual ~SdkTcpClient();

	//�������ܣ���̬����һ����ǰ���������󣬾�����������ɱ���ѡ����ơ�
	//����˵�����ޡ�
	//���ؽ�����ɹ�����ָ���������ָ�롣
	//����˵����������˵����
	static SdkTcpClient *GetNewObject();

	//�������ܣ���̬����һ����ǰ���������󣬾�����������ɱ���ѡ����ơ�
	//����˵����
	//socketHandle  �Ѿ����ӳɹ���socket����
	//���ؽ�����ɹ�����ָ���������ָ�롣
	//����˵����������˵����
	static SdkTcpClient *GetNewObject(int socketHandle, const char * ip, unsigned short port);

	
	//�������ܣ���һ��ָ��ip�Ͷ˿ڵķ���������һ���첽���ӡ�
	//����ʧ��/���ӱ��Ͽ������ٴε������Ӻ���������close()�������޷��ٵ������ӡ�
	//����˵����
	//ip   ������ip��ַ����ʽΪxxx.xxx.xxx.xxx��ʽ���ַ�����
	//port �������˿ںš�
	//timeout    ���ӳ�ʱʱ�䣬��λ���롣
	//callBack   �ص�����ָ�룬�����Ӳ������ʱ�˺����������á�
	//pSynObject ���ӻص������е�ͬ������
	//���ؽ����0Ϊ���سɹ�������Ϊ������롣
	//����˵����
	//ERR_INVALID_PARAM	������Ч������
	//ERR_REPEAT_DO		�ظ����ӣ����Ӷ������ڽ�����/�Ѿ����ӳɹ���
	//ERR_NET_UNREACH	���粻�ɵ��
	virtual ErroCode BeginConnect(const char * const ip, unsigned short port, int timeout,
			ConnectCallback callBack, void * pSynObject);

	//�������ܣ�������ͨ��Tcp��ʽ���͵���������ͬ��������
	//����˵����
	//buffer �������ݻ��塣
	//offset �������ݻ��� buffer ��Ի��忪ʼ������0����ƫ������
	//length ��offsetƫ��λ�ÿ�ʼ��������ݳ��ȡ�
	//���ؽ����0Ϊ���سɹ�������Ϊ������롣
	//����˵����
	//ERR_INVALID_PARAM		������Ч������
	//ERR_NET_NOT_CONNECT	����δ���ӡ�
	virtual ErroCode Send(unsigned char* buffer, int offset, int length);

	//�������ܣ��Ͽ�Tcp���ӡ�
	//����˵�����ޡ�
	//���ؽ����0Ϊ���سɹ�������Ϊ������롣
	//����˵�����ޡ�
	virtual ErroCode Disconnect();

	//�������ܣ�ʹ��Tcp����������⡣
	//����˵����
	//waitTime  ��Tcp������û�����ݽ���ʱ���������������ȴ���ʱ�䡣
	//interval  ������������������������֮��ķ��ͼ����
	//quantity  ����̽���������������������ӽ��ᱻ��Ϊ�Ͽ���
	//���ؽ����0Ϊ���سɹ�������Ϊ������롣
	//����˵����
	//ERR_INVALID_PARAM	������Ч������
	//ERR_SYS_LIMIT		ϵͳ��Դ���ƣ�����ʧ�ܡ�
	virtual ErroCode EnableHeartBeat(int waitTime, int interval, int quantity);


	//�������ܣ����tcp���Ӷ����״̬��
	//����˵������
	//����ֵ��true��ʾ��ǰ����Զ��������socket״̬����ͨ�ģ���֮Ϊ�Ͽ��ġ�
	virtual bool GetState();
	
	//�������ܣ����û�ý��յ����ݺ���õ�֪ͨ������ÿ�ν��յ�Զ���������͵����ݺ�ص���
	//����˵����
	//callBack 	TcpClient::RcvCallback���͵Ļص�������
	//���ؽ������
	virtual void SetRcvCallback(RcvCallback callBack);

	//�������ܣ��������ӶϿ���Ļص�������
	//����˵����
	//callback TcpClient::DisconnectCallback���͵����ӶϿ��ص���
	//����ֵ����
	virtual void SetDisconnectCallback(DisconnectCallback callback);

	//�������ܣ����ý������ݻص�ͬ�����󣬸ö��������ڶ������ݺ���õ�ָ�뺯����ʹ�á�
	//����˵����
	//pSynObject  ��Ҫ�ڶ��ص�������ʹ�õ��Ķ���
	virtual void SetRcvSynObject(void * pSynObject);

	//�������ܣ��������ӶϿ�ͬ�����󣬸ö������������ӶϿ�����õĻص�ָ�뺯����ʹ�á�
	//����˵����
	//pSynObject  ��Ҫ�ڶϿ��ص�������ʹ�õ��Ķ���
	virtual void SetDisconnectSynObject(void * pSynObject);

	//�������ܣ������BeginConnect���������õ�����ͬ������
	virtual void* GetConnectSynObject();

	//�������ܣ������SetRcvSynObject���������õĶ�ͬ������
	virtual void* GetRcvSynObject();

	//�������ܣ������SetDisconnectSynObject���������õ����ӶϿ�ͬ������
	virtual void* GetDisconnectSynObject();

	//��ȡ���һ����ȷ�������Ӻ��������IP��ַ��
	virtual char* GetIP();

	//��ȡ���һ����ȷ�������Ӻ��������IP��ַ��
	virtual unsigned short GetPort();

protected:

	//����״̬��
	bool m_Connected;

	//���ص�����ָ�롣
	RcvCallback m_RcvCallback;

	//���ӽ���ص�ָ�롣
	ConnectCallback m_ConnectCallback;

	//�������ӶϿ�����õ�֪ͨ������
	DisconnectCallback m_DisconnectCallback;

	//���ص�ͬ������
	void * m_pRcvSynObject;

	//���ӽ���ص�ͬ������
	void * m_pConnectSynObject;

	//���ӶϿ��ص�ͬ������
	void * m_pDisconnectSynObject;

	//���ӵ�ַ��
	char m_IP[16];

	//���Ӷ˿ڡ�
	unsigned short m_Port;

private:

};


#endif // !__SDK_TCP_CLIENT__
