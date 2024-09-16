#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Portal SMS                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! PortalSMS                                               !
+------------------+---------------------------------------------------------+
!Nome              ! PortalSMS                                               !
+------------------+---------------------------------------------------------+
!Descricao         ! Portal SMS                                              !
+------------------+---------------------------------------------------------+
!Autor             ! Anderson José Zelenski                                  !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 19/09/2013                                              !
+----------------------------------------------------------------------------+
*/

User Function PortalMenu()
Local cHtml
Local cIdMenu := ""
Local aMenu

Private cMenu
Web Extended Init cHtml // Start U_inSite()

/*
	01 -> Clientes
	02 -> Fornecedor
	03 -> Funcionários
	04 -> Compras
	05 -> Vendas
	06 -> Estoque
	07 -> Financeiro
	08 -> Recursos Humanos
*/

	aMenu := {{'Clientes','5'},{'Fornecedores','5'},{'Funcionários','1'},{'Compras','3'},{'Vendas','2'},{'Estoque','1'},{'Financeiro','4'},{'Recursos Humanos','1'}}

	cQuery := " SELECT ZM0_CODIGO, ZM0_NOME, ZM0_DESCRI, ZM0_MENU "
	cQuery += " FROM "+RetSqlName("ZM0")+" ZM0 "
	cQuery += 		" INNER JOIN "+RetSqlName("ZM2")+" ZM2 ON "
	If !Empty(AllTrim(xFilial("ZM2"))) .And. !Empty(AllTrim(xFilial("ZM0")))
		cQuery += " ZM2_FILIAL = ZM0_FILIAL "
	Else
		cQuery += " ZM2_FILIAL = '"+xFilial("ZM2")+"' "
	EndIf
	cQuery += 		" AND ZM0_CODIGO = ZM2_MODULO AND ZM2.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE ZM0_FILIAL = '"+xFilial("ZM0")+"'"
	cQuery += 		" AND ZM2.ZM2_USER = '"+HttpSession->UserId+"'"
	cQuery += 		" AND ZM0.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY ZM0_MENU, ZM0_ORDEM"
	
	APWExOpenQuery(ChangeQuery(cQuery),'QRY',.T.)
	
	cMenu := ""
	
	While !QRY->(EOF())
		if cIdMenu <> QRY->ZM0_MENU
			if cIdMenu <> ""
				cMenu += '</ul></li>'
			EndIf	
			
			cMenu += '<li class="item'+aMenu[val(QRY->ZM0_MENU)][2]+'"><a href="#">'+aMenu[val(QRY->ZM0_MENU)][1]+'</a><ul>'
			
			cIdMenu := QRY->ZM0_MENU
		EndIf
		
		cMenu += '	<li class="subitem"><a href="#" onclick="parent.'+AllTrim(QRY->ZM0_NOME)+'();">'+QRY->ZM0_DESCRI+'</a></li>'
	
		DbSkip()
	EndDo
	cMenu += '</ul></li>'
	
	APWExCloseQuery('QRY')

	cHtml := H_PortalMenu()
Web Extended end

return (cHTML)