#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � ScExcOrcto  � Autor � Lucilene Mendes     � Data �15.05.21 ���
��+----------+------------------------------------------------------------���
���Descri��o � Exclus�o de Or�amentos abertos. - Schedule				  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function ScExcOrcto(aParam)
Local cModulo := 'GCT'
Local cTabs := 'SCR,CND,CNE,SAK,SAL'

If Empty(aParam)
	aParam:= {'02','010101'}
Endif	

//Abre o ambiente
Prepare Environment EMPRESA aParam[1] FILIAL aParam[2] MODULO cModulo Tables cTabs

//Verifica se abriu o ambiente
If Select("SX2") > 0
	lAbriu := .T.
Endif

If !lAbriu
	Return lRet
Endif

//Executa no primeiro dia do m�s
If date() == FirstDay(date())

	//Busca todos os or�amentos abertos
	cQry:= "Select R_E_C_N_O_ RECSCJ "
	cQry+= "From "+RetSqlName("SCJ")+" SCJ "
	cQry+= "Where CJ_STATUS = 'A' "
	cQry+= "And CJ_XTPORC < '3' " //Firme e previsto
	cQry+= "And SCJ.D_E_L_E_T_ = ' ' "
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	Endif
	TcQuery cQry New Alias "QRY"

	While QRY->(!Eof())
		SCJ->(dbGoTo(QRY->RECSCJ))
		Reclock("SCJ",.F.)
		SCJ->CJ_STATUS := "Q" //cancelado automaticamente
		SCJ->(msUnlock())
		QRY->(dbSkip())
	End
Endif

Reset Environment
	
Return
