#include "rwmake.ch"
#include "protheus.ch" 
#include "topconn.ch"

/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � CadZYF	   � Autor �  Lucilene Mendes   � Data �21.05.21  ���
��+----------+------------------------------------------------------------���
���Descri��o � Cadastro de Saldos x Vendedor	        				  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function CadZYF()
Local cAlias	:= "ZYF"
Private aRotina	:= {}
Private oBrowse
Private cCadastro := "Saldos x Vendedor"

//Op��es de menu dispon�veis
aAdd(aRotina, {"Visualizar"	 , "AxVisual", 0, 2})
///aAdd(aRotina, {"Incluir", "AxInclui", 0, 3})
//aAdd(aRotina, {"Alterar", "AxAltera", 0, 4})
//aAdd(aRotina, {"Excluir", "AxDeleta", 0, 5})

//Monta o browse
oBrowse := FWmBrowse():New()
oBrowse:SetAlias(cAlias)
oBrowse:SetDescription( cCadastro )  
oBrowse:DisableDetails()

//Abre a tela
oBrowse:Activate() 

Return
