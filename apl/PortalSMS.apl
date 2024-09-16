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

User Function PortalSMS()
Local cHtml
Local aMenu
Private cJS

Web Extended Init cHtml Start U_inSite()
	if Empty(AllTrim(HttpSession->Nome))
		cHtml := U_PortalLogin()
	else
		aMenu := {'clientes','fornecedores','funcionarios','compras','vendas','estoque','financeiro','rh'}
		
		// Localiza os modulos disponível para adicionar os arquivos JavaScript
		cQuery := "SELECT ZM0_NOME, ZM0_MENU "
		cQuery += " FROM ZM0990 ZM0 "  //"+RetSqlName("ZM0")+"
		cQuery += 		" INNER JOIN ZM2990 ZM2 ON " //"+RetSqlName("ZM2")+"
		If !Empty(AllTrim(xFilial("ZM2"))) .And. !Empty(AllTrim(xFilial("ZM0")))
			cQuery += " ZM2_FILIAL = ZM0_FILIAL "
		Else
			cQuery += " ZM2_FILIAL = '"+xFilial("ZM2")+"' "
		EndIf
		cQuery += 		" AND ZM0_CODIGO = ZM2_MODULO AND ZM2.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE ZM0_FILIAL = '"+xFilial("ZM0")+"'"
		cQuery += "	AND ZM2.ZM2_USER = '"+HttpSession->UserId+"'"
		cQuery += "	AND ZM0.D_E_L_E_T_ = ' '"
		cQuery += "ORDER BY ZM0_MENU"
		
		APWExOpenQuery(ChangeQuery(cQuery),'QRY',.T.)
		
		cJS := ""
		
		While !QRY->(EOF())
			
			cJS += '<script type="text/javascript" src="'+AllTrim(aMenu[val(QRY->ZM0_MENU)])+'/'+AllTrim(QRY->ZM0_NOME)+'/js/'+AllTrim(QRY->ZM0_NOME)+'.js"></script>'
		
			DbSkip()
		EndDo
		
		APWExCloseQuery('QRY')
	
		cHtml := H_PortalSMS()
	EndIf
Web Extended end

return (cHTML)

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
!Nome              ! PSLogado                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Retorna o ID do usuario logado                          !
+------------------+---------------------------------------------------------+
!Autor             ! Anderson José Zelenski                                  !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 29/09/2013                                              !
+----------------------------------------------------------------------------+
*/

User Function PSLogado()
Local cHtml

Private cReturn

Web Extended Init cHtml Start U_inSite()

	cReturn := AllTrim(HttpSession->UserId)
	
	cHtml := H_PSReturn()
Web Extended end

return (cHTML)

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
!Nome              ! PSSCRKey                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Retorna a chave da aprovação                            !
+------------------+---------------------------------------------------------+
!Autor             ! Anderson José Zelenski                                  !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 02/10/2013                                              !
+----------------------------------------------------------------------------+
*/

User Function PSSCRKey()
Local cHtml

Private cReturn

Web Extended Init cHtml 
	if ValType(HttpSession->SCRKey) <> "U"
		cReturn := AllTrim(HttpSession->SCRKey)
	Else
		cReturn := ""
	End
	
	cHtml := H_PSReturn()
Web Extended end

return (cHTML)

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
!Nome              ! PSSCRTip                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Verifica se existe a chave e retorna o tipo             !
+------------------+---------------------------------------------------------+
!Autor             ! Anderson José Zelenski                                  !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 02/10/2013                                              !
+----------------------------------------------------------------------------+
*/

User Function PSSCRTip()
Local cHtml

Private cReturn

Web Extended Init cHtml 
	if ValType(HttpSession->SCRKey) <> "U"
		Do Case
			Case HttpSession->SCRTipo == 'PC'
				DbSelectArea("SCR")
				DbGoTo(Val(HttpSession->SCRKey))
				
				if SCR->(Recno()) == Val(HttpSession->SCRKey) .And. SCR->CR_STATUS <> "01"
					cReturn := AllTrim(HttpSession->SCRTipo)
				Else
					cReturn := ""
				End
			Case HttpSession->SCRTipo == 'SO'
			       
				DbSelectArea("SCR")
				DbGoTo(Val(HttpSession->SCRKey))
				
				if SCR->(Recno()) == Val(HttpSession->SCRKey) .And. SCR->CR_STATUS <> "01"
					cReturn := AllTrim(HttpSession->SCRTipo)
				Else
					cReturn := ""
				End
			Case HttpSession->SCRTipo == 'AE'
				DbSelectArea("SCR")
				DbGoTo(Val(HttpSession->SCRKey))
				
				if SCR->(Recno()) == Val(HttpSession->SCRKey) .And. SCR->CR_STATUS <> "01"
					cReturn := AllTrim(HttpSession->SCRTipo)
				Else
					cReturn := ""
				End
			Case HttpSession->SCRTipo == 'CT'
				DbSelectArea("SCR")
				DbGoTo(Val(HttpSession->SCRKey))
				
				if SCR->(Recno()) == Val(HttpSession->SCRKey) .And. SCR->CR_STATUS <> "01"
					cReturn := AllTrim(HttpSession->SCRTipo)
				Else
					cReturn := ""
				End			
		EndCase
	Else
		cReturn := ""
	End
	
	cHtml := H_PSReturn()
Web Extended end

return (cHTML)
