#include "PROTHEUS.CH"
#include "RWMAKE.CH"
/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � MA416COR    � Autor � Lucilene Mendes     � Data �03.09.20 ���
��+----------+------------------------------------------------------------���
���Descri��o � Legenda Aprova��o Or�amento de Venda.        			  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function MA416COR()
Local aRet:= Paramixb

aAdd(aRet,{'SCJ->CJ_STATUS=="Q"', 'BR_AZUL'})

Return aRet