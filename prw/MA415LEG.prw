#include "PROTHEUS.CH"
#include "RWMAKE.CH"
/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � MA415COR    � Autor � Lucilene Mendes     � Data �03.09.20 ���
��+----------+------------------------------------------------------------���
���Descri��o � Legenda Or�amento de Venda.      						  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function MA415COR()
Local aRet:= Paramixb

aAdd(aRet,{'SCJ->CJ_STATUS=="Q"', 'BR_AZUL'})

Return aRet

/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � MA415LEG    � Autor � Lucilene Mendes     � Data �03.09.20 ���
��+----------+------------------------------------------------------------���
���Descri��o � Legenda Or�amento de Venda.      						  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function MA415LEG()
Local aRet:= Paramixb

aAdd(aRet,{ 'BR_AZUL' , "Or�amento Cancelado Automaticamente" })

Return aRet
