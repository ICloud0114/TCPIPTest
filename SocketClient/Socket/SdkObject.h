//---------------------------------�ļ�˵��-------------------------------
//�ļ�����SdkObject.h
//������ڣ�2015-3-13
//���ߣ�������
//�汾��1.0.0.0
//�������ڿ�ƽ̨������Sdk������Ļ��ࡣ
//

//---------------------------------�޸���ʷ-------------------------------
//ÿ���޸ļ�¼Ӧ�����޸���š��޸����ڡ��޸��߼��޸����ݼ��
//�޸���ţ�1
//�޸����ڣ�
//�޸��ߣ�
//�޸����ݣ�
//++++++++++++++++++++++++++++++++++++++

#ifndef __SDK_OBJECT__
#define __SDK_OBJECT__

#include <stdio.h>
#include <string.h>
#include "ErroInfo.h"

//Sdk�����ж����������������е�5��״̬��
typedef enum _OBJECT_STATE
{
	OBJECT_STATE_UNINIT,		//�����ڲ���Դδ��ʼ����
	OBJECT_STATE_INIT_FAIL,		//��ʼ��ʧ�ܣ����ܶ����ڲ�������Դ�Ѿ���ʼ���ɹ������ж����ܺ������ɵ��ã��ɵ����ͷź�����
	OBJECT_STATE_INIT_SUCCESS,	//��ʼ���ɹ��������ڲ���Դ�Ѿ�ȫ����ʼ���ɹ��������ܺ����������á�
	OBJECT_STATE_FREE_FAIL,		//�ͷ�ʧ�ܣ������ڲ����ֶ����ͷųɹ�������ʧ�ܣ������ܺ����޷����á�
	OBJECT_STATE_FREE_SUCCESS,	//�ͷųɹ��������ڲ���Դȫ���ͷųɹ���
}OBJECT_STATE;

//�ڿ�ƽ̨������Sdk������Ļ��ࡣ
class SdkObject
{
public:
	SdkObject();
	virtual ~SdkObject();

	//�������ܣ���õ�ǰ�����״̬��
	//����˵�����ޡ�
	//���ؽ�������ض���5��״̬ö��ֵ֮һ,�������鿴�Ƿ񴴽��ɹ���
	virtual OBJECT_STATE GetObjectState();

	//�������ܣ���õ�ǰ����Ĵ���״̬��
	//����˵�����ޡ�
	//���ؽ�������ض������Ĵ�����롣
	virtual ErroCode GetLastErro();

	//�������ܣ��ͷ���GetNewObject������̬�����Ķ��󣬲���ָ���ÿա�
	//����˵�����ޡ�
	//���ؽ�����ޡ�
	static void FreeObject(SdkObject ** ppSdkObject);

protected:

	//�������ܣ����ݵ�ǰ���������״̬�ж϶������Ƿ��ܵ��á�
	//����˵�����ޡ�
	//���ؽ�������Ե��÷���ERR_NO_ERRO,���߷��ؿ������롣
	ErroCode CallJudge();

	//��������״̬��OBJECT_STATEö�ٱ�ʶ״̬��״̬����˵����OBJECT_STATEö�ٶ��塣
	OBJECT_STATE m_ObjectState;

	//�������Ĵ���״̬��������ʹ�ù����з��������֤��
	ErroCode m_LastErro;

private:

};

#endif
