#include 'protheus.ch'
#include 'parmtype.ch'
/*_______________________________________________________________________________
����������������������������������������������������������������������������������
��+----------+--------------+-------+------------------------+------+----------+��
���Fun��o    � MA416FIL     � Autor � Lucilene Mendes        � Data � 15/05/21 ���
��+----------+--------------+-------+------------------------+------+----------+��
���Descri��o � Filtro no browse da aprova��o de or�amentos					   ���
��+----------+-----------------------------------------------------------------+��
����������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/ 
User Function MA416FIL()
Local aParamBox:= {}
Local aRet:= {}
Local cFiltro:= "CJ_XTPORC='1'" //or�amento firme

aAdd(aParamBox,{1,"Emiss�o De"  ,Ctod(Space(8)),"","","","",50,.F.}) 
aAdd(aParamBox,{1,"Emiss�o At�" ,Ctod(Space(8)),"","","","",50,.F.}) 
aAdd(aParamBox,{1,"Vendedor De" ,Space(6),"","","SA3","",0,.F.}) 
aAdd(aParamBox,{1,"Vendedor At�",Space(6),"","","SA3","",0,.F.}) 

If ParamBox(aParamBox,"Filtrar Or�amento",@aRet)
	If !Empty(aRet[1]) .and. !Empty(aRet[2])
		cFiltro+=".AND.CJ_EMISSAO>=ctod('"+DTOC(aRet[1])+"').AND.CJ_EMISSAO<=ctod('"+DTOC(aRet[2])+"')"
	Endif
	If !Empty(aRet[3]) .and. !Empty(aRet[4])
		cFiltro+=".AND.CJ_VEND >='"+aRet[3]+"'.AND.CJ_VEND<='"+aRet[4]+"'"
	Endif	 
Endif

Return cFiltro
