#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE SMSDEBUG
#DEFINE SESSHTTP "GlbVend"
/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Portal SMS                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! Login no Portal                                         !
+------------------+---------------------------------------------------------+
!Nome              ! PortalLogin                                             !
+------------------+---------------------------------------------------------+
!Descricao         ! Efetua o login pelo usuário do Protheus, Cliente,       !
!                  ! Fornecedor ou Funcionário                               !
+------------------+---------------------------------------------------------+
!Autor             ! Anderson José Zelenski                                  !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 19/09/2013                                              !
+----------------------------------------------------------------------------+
*/

User Function PortalLogin()
Local cHtml
Local lLogin	:= .F.

Private cMensagem := ""
Private cSite	  := ""
Private cMenus	  := ""
Private cTitle	  := "Portal SMS"
Private cParmPR   := ""

Web Extended Init cHtml Start U_inSite(.f.)
	#IFDEF SMSDEBUG
		conOut(Procname()+"("+ltrim(str(procline()))+") *** Portal ")
		aInfo := HttpGet->aGets
		For nI := 1 to len(aInfo)
			conout('GET '+str(nI,3)+' = '+aInfo[nI]+' -> '+&("HTTPGET->"+aInfo[nI]))
		Next
		aInfo := HttpPost->aPost
		For nI := 1 to len(aInfo)
			conout('POST '+str(nI,3)+' = '+aInfo[nI]+' -> '+&("HTTPPOST->"+aInfo[nI]))
		Next
	#ENDIF
	
	// Pega do parâmetro com o Titulo do Portal
	cTitle	:= SuperGetMV("PS_TITLE", .T., "Portal SMS")
	
	If ValType(HttpPost->login) <> "U" .and. !(Empty(HttpPost->password) .and. !Empty(HttpPost->login))  
		
		//Verifica o tipo de login
		lUsuario:= .F. //U_GetLogin(2, HttpPost->login, HttpPost->password)
		lFornece:= .F. //U_GetLgnFor(HttpPost->login, HttpPost->password)
		lVendedor:= U_GetLgnVend(HttpPost->login, HttpPost->password, @cParmPR)
			
		If !lUsuario .and. !lFornece .and. !lVendedor
			If Empty(cMensagem)			
				cMensagem := "*Login e/ou Senha inválido"
			Endif
			cHtml := H_PortalLogin()		 			
		Else						
			cCodLogin:= U_SetParPR(cParmPR)
			cHtml := U_SMSPortal(cParmPR)	
		Endif	
	Else
		HttpSession->UserId 	:= ""
		HttpSession->Nome 		:= ""
		HttpSession->NomeFull 	:= ""
		HttpSession->Email 		:= ""
		HttpSession->Matricula 	:= ""
		HttpSession->MatFil		:= ""
		HttpSession->Tipo		:= "" // U -> Usuario; C -> Cliente; F -> Fornecedor; M -> Funcionario
		HttpSession->keySCR		:= ""
	
		//Variáveis para fornecedor
		HttpSession->Fornece 	:= ""
		HttpSession->Loja	 	:= ""
		HttpSession->NomeReduz	:= ""
		HttpSession->Nome	 	:= ""
		HttpSession->Email 		:= ""
		
		//Variáveis para vendedor
		HttpSession->CodVend	:= ""
		HttpSession->NomeReduz	:= ""
		HttpSession->Nome	 	:= ""
		HttpSession->Email 		:= ""
		HttpSession->Perfil		:= ""
		HTTPFreeSession() 	
		cHtml := H_PortalLogin()
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
!Modulo            ! Login no Portal                                         !
+------------------+---------------------------------------------------------+
!Nome              ! GetLogin                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Valida login do usuário, cliente, fornecedor ou         !
!                  ! Funcionário                                             !
+------------------+---------------------------------------------------------+
!Autor             ! Anderson José Zelenski                                  !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 19/09/2013                                              !
+----------------------------------------------------------------------------+
*/

User Function GetLogin(cSetOrder, cUser, cPassword)
Local lResult := .F.
Local cResult := "" 
Local aEmpresas, aUsuarios, aOpcoesEmp, aFilEmpresas
Local cDescEmp, cCodEmp
	
	HttpSession->UserId 	:= ""
	HttpSession->Nome 		:= ""
	HttpSession->NomeFull 	:= ""
	HttpSession->Email 		:= ""
	HttpSession->Matricula 	:= ""
	HttpSession->MatFil		:= ""
	HttpSession->Tipo		:= "" // U -> Usuário; C -> Cliente; F -> Fornecedor; M -> Funcionário
	HttpSession->Fornece	:= ""
	HttpSession->Loja		:= ""
	HttpSession->aMenu		:= {}
	HttpSession->aWidGet	:= {}
	
	PswOrder(cSetOrder)
	/*
	nOrder
		1 - ID do usuário/grupo
		2 - Nome do usuário/grupo;
		3 - Senha do usuário
		4 - E-mail do usuário
	*/
	If PswSeek(cUser,.T.)
		aUser := PswRet(1) // Retorna o array com os dados do usuário
			
		if !PswName(cPassword)
			cMensagem:= "Senha inválida."
			conout("Senha Invalida para o usuario: "+cUser)
		Else
			if len(aUser) > 0
				HttpSession->UserId 		:= Alltrim(aUser[1,1])	// Id do Usuário
				HttpSession->Nome 		:= Alltrim(aUser[1,2])		// Nome do Usuário
				HttpSession->NomeFull 	:= Alltrim(aUser[1,4])		// Nome Completo
				HttpSession->Email 		:= Alltrim(aUser[1,14])		// Email
				HttpSession->Matricula  := substr(aUser[1,22],5,6) 	// Salva a Filial escolhida
				HttpSession->MatFil  	:= substr(aUser[1,22],3,2) 	// Salva a Filial escolhida
				HttpSession->Tipo		:= "U"
				HttpSession->Perfil		:= "Aprovador"
				HttpSession->aMenu		:= {}
				HttpSession->aWidGet	:= {}
                lResult := .T.
			EndIf
		EndIf
	Else
		cMensagem:= "Login inválido."
	EndIf
Return lResult      



/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Portal SMS                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! Login no Portal do Fornecedor                           !
+------------------+---------------------------------------------------------+
!Nome              ! GetLgnFor                                               !
+------------------+---------------------------------------------------------+
!Descricao         ! Valida login do fornecedor 							 !
+------------------+---------------------------------------------------------+
!Autor             ! Lucilene Mendes		                                 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 28/07/2017                                              !
+----------------------------------------------------------------------------+
*/
User Function GetLgnFor(cLogin, cPassword)
Local lResult := .F.
Local cResult := "" 
	
HttpSession->Fornece 	:= ""
HttpSession->Loja	 	:= ""
HttpSession->NomeReduz	:= ""
HttpSession->Nome	 	:= ""
HttpSession->Email 		:= ""

If Empty(cLogin)
	Return lResult   
Endif
	
dbSelectArea("SA2")
SA2->(dbSetOrder(3)) //filial+CNPJ
If SA2->(dbSeek(xFilial("SA2")+cLogin))
	If Alltrim(SA2->A2_CGC) == Alltrim(cLogin)
		If Alltrim(SA2->A2_XSENHA) == SubStr(cPassword,1,10)
	
			HttpSession->Fornece	:= SA2->A2_COD				// Codigo do Fornecedor
			HttpSession->Loja		:= SA2->A2_LOJA				// Loja do Fornecedor
			HttpSession->NomeReduz	:= Alltrim(SA2->A2_NREDUZ)	// Nome do Usuário
			HttpSession->Nome	 	:= Alltrim(SA2->A2_NOME)	// Nome Completo
			HttpSession->Email 		:= Alltrim(SA2->A2_EMAIL)	// Email
			HttpSession->Tipo		:= "F"
			HttpSession->NomeFull	:= Alltrim(SA2->A2_NREDUZ)
			HttpSession->Perfil		:= "Fornecedor"
	   		lResult := .T.
	     Else 
	     	cMensagem := "*Senha inválida!"
	     	conout("####### P O R T A L    F O R N E C E D O R #######")
			conout("   Senha invalida para o usuario: "+cLogin)
		EndIf
	Else
		cMensagem := "*Login inválido!"    
		conout("####### P O R T A L    F O R N E C E D O R #######")
		conout("   Usuario invalido: "+cLogin)
	EndIf
Else
	cMensagem := "*Login inválido!"    
	conout("####### P O R T A L    F O R N E C E D O R #######")
	conout("   Usuario invalido: "+cLogin)
EndIf 

Return lResult      
 

/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Portal SMS                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! Login no Portal do Fornecedor                           !
+------------------+---------------------------------------------------------+
!Nome              ! GetLgnVend                                              !
+------------------+---------------------------------------------------------+
!Descricao         ! Valida login do vendedor	 							 !
+------------------+---------------------------------------------------------+
!Autor             ! Lucilene Mendes		                                 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 28/08/2017                                              !
+----------------------------------------------------------------------------+
*/
User Function GetLgnVend(cLogin, cPassword, cParmPR)
Local lResult := .F.
Local cResult := "" 
Local nRecSA3 := 0

HttpSession->CodVend 	:= ""
HttpSession->NomeReuz 	:= ""
HttpSession->Nome	 	:= ""
HttpSession->Email 		:= ""
HttpSession->Equipe		:= ""
HttpSession->Representantes:= ""
HttpSession->Superv		:= ""
HttpSession->Gerente	:= ""
If Empty(cLogin)
	Return lResult   
Endif
	
dbSelectArea("SA3")
SA3->(dbSetOrder(1)) //filial+Cod
If SA3->(dbSeek(xFilial("SA3")+cLogin))
	If Alltrim(SA3->A3_COD) == Alltrim(cLogin)
		If Alltrim(SA3->A3_SENHA) == cPassword
			//Verifica se o vendedor tem a amarração com região de vendas
			/*
			If Empty(SA3->A3_XREGIAO)        
				cMensagem := "*Representante sem cadastro de região de vendas!"
		     	conout("####### P O R T A L    R E P R E S E N T A N T E #######")
				conout("   Usuário "+cLogin+" sem cadastro de região de venda - A3_XREGIAO")
			Else 
				//Busca a filial de faturamento da região de vendas
				dbSelectArea("ZEF")
				If !ZEF->(dbSeek(xFilial("ZEF")+SA3->A3_XREGIAO)) .or. Empty(ZEF->ZEF_EMPRES) .or. !fwFilExist("01",ZEF->ZEF_EMPRES)
					cMensagem := "*Empresa de faturamento não localizada!"
			     	conout("####### P O R T A L    R E P R E S E N T A N T E #######")
					conout("   Usuário "+cLogin+" empresa de faturamento "+ZEF->ZEF_EMPRES+" inválida.")
				Else
					//Altera a empresa para a filial de faturamento
					nRecSA3:= SA3->(Recno())
					HttpSession->Filial:= ZEF->ZEF_EMPRES //CEMPANT+CFILANT+CEMPFIL
					u_InSite()
					
					//Posiciona na SA3 novamente, pois ao trocar a filial fecha a tabela
					dbSelectArea("SA3")
					SA3->(dbGoTo(nRecSA3))
			  */		 
					//Verifica se vendedor é supervisor ou gerente
					// cQry:= "Select * "
					// cQry+= " From "+RetSqlName("SA3")+" SA3 "
					// cQry+= " Where (A3_XSUPERV =  '"+SA3->A3_COD+"' OR A3_XGERENT =  '"+SA3->A3_COD+"') "
					// cQry+= " And A3_MSBLQL <> '1' "
					// cQry+= " And SA3.D_E_L_E_T_ = ' ' "
					// If Select("SUP") > 0
					// 	SUP->(dbCloseArea())
					// Endif
	
					// APWExOpenQuery(ChangeQuery(cQry),'SUP',.T.)
					
					// If SUP->(!Eof())
					// 	HttpSession->Tipo		:= "S"
					// 	HttpSession->Perfil		:= "Supervisor"
					// 	lGeren:= .f.	
					// 	HttpSession->Superv		:= SA3->A3_COD
					// 	HttpSession->Equipe 	+= SA3->A3_COD+"|"  //Supervisor
					// 	While SUP->(!Eof())
					// 		If !Empty(SUP->A3_XGERENT) .and. !lGeren
					// 			lGeren:= .T.
					// 			HttpSession->Perfil		:= "Supervisor/Gerente"
					// 		Endif
					// 		HttpSession->Equipe += SUP->A3_COD+"|"  //Equipe de vendas
					// 		HttpSession->Representantes += SUP->A3_COD+" - "+SUP->A3_NOME+"|"
					// 		SUP->(dbSkip())
					// 	End 
					// 	HttpSession->Equipe:= Substr(HttpSession->Equipe,1,Len(HttpSession->Equipe)-1)
					// 	HttpSession->Representantes:= Substr(HttpSession->Representantes,1,Len(HttpSession->Representantes)-1)	
					// Else 
						HttpSession->Tipo		:= "V"
						HttpSession->Perfil		:= "Representante"
					// Endif
					HttpSession->CodVend	:= SA3->A3_COD				// Codigo do Fornecedor
					HttpSession->NomeReduz	:= Alltrim(SA3->A3_NREDUZ)	// Nome do Usuário
					HttpSession->Nome	 	:= Alltrim(SA3->A3_NOME)	// Nome Completo
					HttpSession->Email 		:= Alltrim(SA3->A3_EMAIL)	// Email
					HttpSession->NomeFull	:= Alltrim(SA3->A3_NREDUZ)
					
					// Salva o vinculo Session X Vendedor no arquivo de controle (fonte insite.apl)
					u_svUsSes(SA3->A3_COD)
					saveUsPR("Vendedor", HttpSession->CodVend, HttpSession->Tipo, HttpSession->Equipe)
					cParmPR := SA3->A3_COD					
					
					
					HttpSession->Polimento	:= .F.
					
					
					
			   		lResult := .T.
		//	   	Endif
		//	Endif	   		
	     Else 
	     	cMensagem := "*Senha inválida!"
	     	conout("####### P O R T A L    R E P R E S E N T A N T E #######")
			conout("   Senha invalida para o usuario: "+cLogin)
		EndIf
	Else
		cMensagem := "*Login inválido!"    
		conout("####### P O R T A L    R E P R E S E N T A N T E #######")
		conout("   Usuario invalido: "+cLogin)
	EndIf
Else
	cMensagem := "*Login inválido!"    
	conout("####### P O R T A L    R E P R E S E N T A N T E #######")
	conout("   Usuario invalido: "+cLogin)
EndIf 

Return lResult      
 

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetEmpresas ¦ Autor ¦  Lucilene Mendes   ¦ Data ¦08.08.17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Retorna as empresas da tabela SM0					      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

Static Function GetEmpresas()

	dbSelectArea("SM0")
	dbGotop()
			
	While SM0->(!Eof())
		If SM0->M0_CODIGO $ '01|03'
			cEmpresas += "<option value='"+SM0->M0_CODIGO+SM0->M0_CODFIL+"'>"+SM0->M0_CODIGO+"/"+SM0->M0_CODFIL+" - "+;
		    				Left(FWFilialName(SM0->M0_CODIGO,SM0->M0_CODFIL,1),35)+"</option>"
		Endif	
		SM0->(dbSkip())
	EndDo   
		
Return cEmpresas		

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetMenus	 ¦ Autor ¦  Lucilene Mendes     ¦ Data ¦08.08.17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Retorna os menus que o usuário tem acesso			      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function GetMenus(cMnuAtivo, cCodVend)
Local cUsrMenus	:= ""
Local cQryMenu := ""
Local cQryMnPai := ""
Local aMnuPai := {} 
Local nI := 1
Local nPos := 0
Local nPosPai := 0
Local aMenus := {}
Local aWidGet := {}
Private cCodLogin := ""

Default cMnuAtivo := ""
Default HttpSession->UserId:= ""
Default HttpSession->CodVend:= ""
Default HttpSession->Fornece:= ""
Default HttpSession->Loja:= ""
	
	If ValType(HttpSession->aMenu) == "U"
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_SMSPortal.apw">'
	 	Return cHtml
	Endif 	     
	cCodLogin := U_SetParPR(cCodVend)
	If Len(HttpSession->aMenu) == 0
		// Gera os itens do Menu Pai 
		cQryMnPai := " SELECT ZM0_CODIGO, ZM0_NOME, ZM0_MNUPAI, ZM0_ROTINA, ZM0_ALIAS, ZM0_ICONE  " 
		cQryMnPai += " FROM "+RetSqlName("ZM0")+" ZM0 " 
		cQryMnPai += " WHERE ZM0_FILIAL = '"+xFilial("ZM0")+"' "
		cQryMnPai += 	" AND ZM0.ZM0_MNUPAI = ' ' "
		cQryMnPai += 	" AND ZM0.D_E_L_E_T_ = ' ' "
		
		If Select("QRYMNP") > 0
			QRYMNP->(dbCloseArea())
		Endif
	
		APWExOpenQuery(ChangeQuery(cQryMnPai),'QRYMNP',.T.)
	
		While !QRYMNP->(Eof())
			
			aAdd(aMnuPai, {.F., QRYMNP->ZM0_CODIGO, QRYMNP->ZM0_NOME, QRYMNP->ZM0_MNUPAI, QRYMNP->ZM0_ROTINA, QRYMNP->ZM0_ALIAS, QRYMNP->ZM0_ICONE})
			
			QRYMNP->(DbSkip())
		EndDo
	
		// Gera os itens do Menu Filhos
		cQryMenu := " SELECT ZM0_CODIGO, ZM0_NOME, ZM0_MNUPAI, ZM0_ROTINA, ZM0_ALIAS, ZM0_ICONE, ZM0_WIDGET " 
		cQryMenu += " FROM "+RetSqlName("ZM0")+" ZM0 " 
		cQryMenu += " WHERE ZM0_FILIAL = '"+xFilial("ZM0")+"' "
		cQryMenu += 	" AND ZM0.ZM0_ALIAS IN ( "
		//cQryMenu += 		" SELECT DISTINCT 'SCR' AS ALIAS "
		//cQryMenu += 		" FROM "+RetSqlName("SCR")+" SCR "
		//cQryMenu += 		" WHERE SCR.CR_FILIAL = '"+xFilial("SCR")+"'"
		//cQryMenu += 			" AND SCR.CR_USER = '"+HttpSession->UserId+"' "
		//cQryMenu +=				" AND SCR.D_E_L_E_T_ = ' ' " 
		//cQryMenu +=			" UNION "
		cQryMenu += 		" SELECT DISTINCT 'SA3' AS ALIAS "
		cQryMenu += 		" FROM "+RetSqlName("SA3")+" SA3 "
		cQryMenu += 		" WHERE SA3.A3_FILIAL = '"+xFilial("SA3")+"'"
		cQryMenu += 			" AND SA3.A3_COD = '"+cCodVend+"' "
		//cQryMenu += 			" AND SA3.A3_CODUSR <> ' ' "
		//cQryMenu += 			" AND SA3.A3_COD = '000006' "
		cQryMenu +=				" AND SA3.D_E_L_E_T_ = ' ' "
		// cQryMenu +=			" UNION "
		// cQryMenu += 		" SELECT DISTINCT 'SA2' AS ALIAS "
		// cQryMenu += 		" FROM "+RetSqlName("SA2")+" SA2 "
		// cQryMenu += 		" WHERE SA2.A2_FILIAL = '"+xFilial("SA2")+"'"
		// cQryMenu += 			" AND SA2.A2_COD = '"+HttpSession->Fornece+"' "
		// cQryMenu += 			" AND SA2.A2_LOJA = '"+HttpSession->Loja+"' "
		// cQryMenu +=				" AND SA2.D_E_L_E_T_ = ' ' "
		cQryMenu +=			" ) "
		cQryMenu += 	" AND ZM0.D_E_L_E_T_ = ' ' "
		cQryMenu += " ORDER BY ZM0_MNUPAI "
		
		If Select("QRYMNU") > 0
			QRYMNU->(dbCloseArea())
		Endif	 
		APWExOpenQuery(ChangeQuery(cQryMenu),'QRYMNU',.T.)
	
		ZM0->(DbSetOrder(1))
		
		While !QRYMNU->(Eof())
			
			nPos := aScan(aMenus,{|x|x[2] == AllTrim(QRYMNU->ZM0_MNUPAI)})
			
			If nPos == 0 
				aAdd(aMenus, aMnuPai[aScan(aMnuPai,{|x|x[2] == AllTrim(QRYMNU->ZM0_MNUPAI)})])
				
				conout("ProcName "+cMnuAtivo+" = "+AllTrim(Upper(QRYMNU->ZM0_ROTINA)))
				
				if !Empty(cMnuAtivo) .And. cMnuAtivo == AllTrim(Upper(QRYMNU->ZM0_ROTINA))
					aMenus[Len(aMenus),1] := .T.
				EndIf
			Else
			
				conout("ProcName "+cMnuAtivo+" = "+AllTrim(Upper(QRYMNU->ZM0_ROTINA)))
				
				if !Empty(cMnuAtivo) .And. cMnuAtivo == AllTrim(Upper(QRYMNU->ZM0_ROTINA))
					aMenus[nPos,1] := .T.
				EndIf
			EndIf
			
			aAdd(aMenus, {(!Empty(cMnuAtivo) .And. cMnuAtivo == AllTrim(Upper(QRYMNU->ZM0_ROTINA))), QRYMNU->ZM0_CODIGO, QRYMNU->ZM0_NOME, QRYMNU->ZM0_MNUPAI, AllTrim(QRYMNU->ZM0_ROTINA), QRYMNU->ZM0_ALIAS, AllTrim(QRYMNU->ZM0_ICONE)})
			
			// Salva os WidGet definidos na tabela ZM0
			If !Empty(AllTrim(QRYMNU->ZM0_WIDGET))
				aAdd(aWidGet, {QRYMNU->ZM0_CODIGO, QRYMNU->ZM0_NOME, AllTrim(QRYMNU->ZM0_WIDGET), AllTrim(QRYMNU->ZM0_ICONE), AllTrim(QRYMNU->ZM0_ROTINA)})
			EndIf
			
			QRYMNU->(DbSkip())
		EndDo
		
		// Salva na Session o menu já gerado nas querys para acesso
		HttpSession->aMenu := aMenus
		HttpSession->aWidGet := aWidGet
	Else
		// Recupera os Menus salvos na Session
		aMenus := HttpSession->aMenu
		
		// Limpa as opções de Ativas do Menu
		For nX := 1 To Len(aMenus)
			aMenus[nX, 1] := .F.
		Next
		
		// De acordo com a rotina define o menu que será destacado como ativo.
		For nX := 1 To Len(aMenus)
			if Upper(aMenus[nX, 5]) == cMnuAtivo
				aMenus[nX, 1] := .T.
				
				// Localiza o Menu Pai para marcar como ativo.
				nPos := aScan(aMenus,{|x|x[2] == aMenus[nX, 4]})
				If nPos > 0  
					aMenus[nPos, 1] := .T.
				EndIf
			EndIf 
		Next
		
	EndIf
	
	For nI := 1 To Len(aMenus)
		// Inclui os menus Pais.
		If Empty(Alltrim(aMenus[nI,4]))
			cUsrMenus += '<li class="nav-parent '+Iif(aMenus[nI,1],'nav-expanded nav-active','')+'">'
			cUsrMenus += 	'<a href="#">'
			cUsrMenus += 		'<i class="'+aMenus[nI,7]+'" aria-hidden="true"></i>
			cUsrMenus += 		'<span>'+aMenus[nI,3]+'</span>'
			cUsrMenus+='	</a>'                        
			cUsrMenus += 	getKidMenu(aMenus, aMenus[nI,2], cCodLogin)
			cUsrMenus += '</li>'
		EndIf
Next	
				
Return cUsrMenus				                    

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ getKidMenu ¦ Autor ¦ Anderson Zelenski  ¦ Data ¦11.08.2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Gera os menus filhos                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

Static Function getKidMenu(aMenu, cPai, cCodLogin)
Local cKidMenu := ""
Local nK := 1
	
	cKidMenu := '<ul class="nav nav-children">'
	
	For nK := 1 To Len(aMenu)
		If aMenu[nK,4] == cPai
			cKidMenu += '<li '+Iif(aMenu[nK,1],'class="nav-active"','')+'>'
			cKidMenu += 	'<a href="'+aMenu[nK,5]+'.apw?PR='+cCodLogin+'">'
			cKidMenu += 		'<i class="'+aMenu[nk,7]+'"></i>
			cKidMenu += 		'<span>'+aMenu[nk,3]+'</span>'
			cKidMenu += 	'</a>'
			cKidMenu += '</li>'
		EndIf
	Next
	
	cKidMenu += '</ul>'

Return cKidMenu

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetNmPg   ¦ Autor ¦ Anderson Zelenski    ¦ Data ¦16.08.17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Retorna o nome a ser exibido na página do portal           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function GetNmPg(cMnuAtivo)
Local cNomePag	:= ""
Local nX 		:= 1
Local aMenus 	:= {}

Default cMnuAtivo := ""

	aMenus := HttpSession->aMenu
		
	// De acordo com a rotina define o menu que será destacado como ativo.
	For nX := 1 To Len(aMenus)
		if Upper(aMenus[nX, 5]) == cMnuAtivo
			cNomePag := aMenus[nX, 3]
		EndIf 
	Next
		
Return cNomePag


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetAnexos ¦ Autor ¦  Lucilene Mendes     ¦ Data ¦22.08.17  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Retorna os anexos formatos para exibição				      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function GetAnexos(aAttach,cDiretorio)
Local cDrive:= ""
Local cDir	:= ""
Local cNome	:= ""
Local cExt	:= ""
Local cRet	:= ""
Local nDiv	:= Round(Len(aAttach)/3,0)

If Len(aAttach) > 1
	cRet += '<div class="isotope-item document col-sm-6 col-md-4 col-lg-2">'
EndIf

For i:= 1 to Len(aAttach)			
	cRet += '<div class="thumbnail">'
	cRet += '	<div class="thumb-preview">'
	cRet += '		<a class="text-muted text-uppercase" href="'+cDiretorio+Alltrim(aAttach[i,1])+'">'
	
	SplitPath(aAttach[i,1], @cDrive, @cDir, @cNome, @cExt )
	
	Do Case
		Case Upper(cExt) $ ".PDF"
			cRet += '			<i class="fa fa-file-pdf-o fa-3x"></i>
		Case Upper(cExt) $ ".DOCX"
			cRet += '			<i class="fa fa-file-word-o fa-3x"></i>
		Case Upper(cExt) $ ".XLSX"
			cRet += '			<i class="fa fa-file-excel-o fa-3x"></i>
		Case Upper(cExt) $ ".CSV"
			cRet += '			<i class="fa fa-file-excel-o fa-3x"></i>
		Case Upper(cExt) $ ".JPG"
			cRet += '			<i class="fa fa-file-image-o fa-3x"></i>
		Case Upper(cExt) $ ".JPEG"
			cRet += '			<i class="fa fa-file-image-o fa-3x"></i>
		Case Upper(cExt) $ ".BMP"
			cRet += '			<i class="fa fa-file-image-o fa-3x"></i>
		Case Upper(cExt) $ ".PNG"
			cRet += '			<i class="fa fa-file-image-o fa-3x"></i>
		Case Upper(cExt) $ ".PPTX"
			cRet += '			<i class="fa fa-file-powerpoint-o fa-3x"></i>
		Case Upper(cExt) $ ".ZIP"
			cRet += '			<i class="fa fa-file-zip-o fa-3x"></i>
		Case Upper(cExt) $ ".RAR"
			cRet += '			<i class="fa fa-file-zip-o fa-3x"></i>
		Case Upper(cExt) $ ".MSG"
			cRet += '			<i class="fa fa-envelope-o fa-3x"></i>
		Case Upper(cExt) $ ".TXT"
			cRet += '			<i class="fa fa-file-text-o fa-3x"></i>
		OTHERWISE
			cRet += '			<i class="fa fa-file-o fa-3x"></i>
	EndCase
	
	cRet += '			<span class="mg-title text-weight-semibold">'+Substr(cNome,1,20)+cExt+'</span>'
	cRet += '		</a>'
	cRet += '	</div>'
	cRet += '</div>'
	
	If Mod(i,nDiv) == 0 .And. i < Len(aAttach) // Verifica se deverá quebrar o div 
		cRet += '</div>'
		cRet += '<div class="isotope-item document col-sm-6 col-md-4 col-lg-2">'
	EndIf
	
Next

If Len(aAttach) > 1 // Verifica se existe anexos para fechar o div 
	cRet += '</div>'	
EndIf

Return cRet	

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetHeader     ¦ Autor ¦ Anderson Zelenski ¦ Data ¦15.08.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Gera o cabeçalho das paginas para o portal                 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function PSHeader(cTitle, cSite)
Local cHeader := ""
Local cFim := Chr(13)+Chr(10)

	cHeader := '<div class="logo-container">'+cFim
	cHeader += '	<a href="'+cSite+'" class="logo pull-left">'+cFim
	cHeader += '		<img src="images/logo.png" alt="'+cTitle+'" height="35"/>'+cFim
	cHeader += '	</a>'+cFim
	cHeader += '	<div class="visible-xs toggle-sidebar-left" data-toggle-class="sidebar-left-opened" data-target="html" data-fire-event="sidebar-left-opened">'+cFim
	cHeader += '		<i class="fa fa-bars" aria-label="Toggle sidebar"></i>'+cFim
	cHeader += '	</div>'+cFim
	cHeader += '</div>'+cFim
	cHeader += '<div class="header-right">'+cFim
	cHeader += '	<span class="separator"></span>'+cFim
	cHeader += '	<div id="userbox" class="userbox">'+cFim
	cHeader += '		<a href="#" data-toggle="dropdown">'+cFim
	//cHeader += '			<figure class="profile-picture">'+cFim
	//cHeader += '				<img src="assets/images/!logged-user.jpg" alt="'+HttpSession->NomeFull+'" class="img-circle" data-lock-picture="assets/images/!logged-user.jpg" />'+cFim
	//cHeader += '			</figure>'+cFim
	cHeader += '			<div class="profile-info" data-lock-name="'+HttpSession->Nome+'">'+cFim
	cHeader += '				<span class="name">'+HttpSession->NomeFull+'</span>'+cFim
	cHeader += '			<span class="role">'+HttpSession->Perfil+'</span>'+cFim
	cHeader += '			</div>'+cFim
	cHeader += '			<i class="fa custom-caret"></i>'+cFim
	cHeader += '		</a>'+cFim
	cHeader += '		<div class="dropdown-menu">'+cFim
	cHeader += '			<ul class="list-unstyled">'+cFim
	//cHeader += '				<li class="divider"></li>'+cFim
	//cHeader += '				<li>'+cFim
	//cHeader += '					<a role="menuitem" tabindex="-1" href="pages-signin.html"><i class="fa fa-eye"></i>Alterar Visão</a>'+cFim
	//cHeader += '				</li>'+cFim
	cHeader += '				<li>'+cFim
	cHeader += '					<a role="menuitem" tabindex="-1" href="U_PortalLogin.apw"><i class="fa fa-power-off"></i> Sair</a>'+cFim
	cHeader += '				</li>'+cFim
	cHeader += '			</ul>'+cFim
	cHeader += '		</div>'+cFim
	cHeader += '	</div>'+cFim
	cHeader += '</div>'+cFim

Return cHeader



/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ InfUpload   ¦ Autor ¦ Anderson Zelenski  ¦ Data ¦ 23.08.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Upload de arquivo no Portal SMS                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function InfUpload()
Local cHtml
Local cDrive, cDir:='', cNome, cExt

Web Extended Init cHtml Start U_inSite()
	#IFDEF SMSDEBUG
		conOut(Procname()+"("+ltrim(str(procline()))+") *** Portal ")
		aInfo := HttpGet->aGets
		For nI := 1 to len(aInfo)
			conout('GET '+str(nI,3)+' = '+aInfo[nI]+' -> '+&("HTTPGET->"+aInfo[nI]))
		Next
		aInfo := HttpPost->aPost
		For nI := 1 to len(aInfo)
			conout('POST '+str(nI,3)+' = '+aInfo[nI]+' -> '+&("HTTPPOST->"+aInfo[nI]))
		Next
	#ENDIF
	
	cDirCot :=	HttpPost->dirCot

	iF(VALTYPE(&('HttpPost->anexo'))<>'U')
		SplitPath( &('HttpPost->anexo'), @cDrive, @cDir, @cNome, @cExt )
	
		if(!ExistDir(cDirCot))
			MakeDir (cDirCot)
		EndIf
		
		conout(cDirCot)
		conout(cDrive)
		conout(cDir)
		conout(cNome)
		conout(cExt)
	
		cNomeArq := STRTRAN(U_NoAcMI(cNome)," ","_")
		If(FRenameEx(&('HttpPost->anexo'),cDirCot+'\'+cNomeArq+cExt)==-1)
			conout(FError())
		EndIf
		cHtml := "Ok"
	Else
		cHtml := "erro"
	EndIf
	
Web Extended End

Return (cHTML)


User Function PTChgFil(cNewFil)
	//Altera a filial 
	nRecSA3:= SA3->(Recno())
	If cNewFil <> HttpSession->Filial 
		HttpSession->Filial:= cNewFil 
		u_InSite()
	Endif
	
	//Posiciona na SA3 novamente, pois ao trocar a filial fecha a tabela
	dbSelectArea("SA3")
	SA3->(dbGoTo(nRecSA3))

Return cFilAnt  


/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Portal SMS                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! Portal SMS - Insite                                     !
+------------------+---------------------------------------------------------+
!Nome              ! saveUsPR                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Salva informacoes do usuario do portal em variaveis     !
!                  !  globais. (ficava em session antes)                     !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 08/02/2021                                              !
+----------------------------------------------------------------------------+
*/
static function saveUsPR(cTipo, cCodigo, cTipoInterno, cEquipe)
    local aSessions := {}
	local nPos 
	default cTipo := "Vendedor" 
    // Tratamento por variáveis globais
    GetGlbVars(SESSHTTP, aSessions)
    if valtype(aSessions) <> "A"
        aSessions := {}
    endif
	nPos := ascan(aSessions, {|x| upper(x[1]) = upper(cTipo) .and. x[2] = cCodigo})
	if empty(nPos)
		aadd(aSessions, {cTipo, cCodigo,"",""})
		nPos := len(aSessions)
	Endif
	aSessions[nPos, 3] := cTipoInterno
	aSessions[nPos, 4] := cEquipe
    PutGlbVars(SESSHTTP, aSessions)
return


/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Portal SMS                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! Portal SMS - Insite                                     !
+------------------+---------------------------------------------------------+
!Nome              ! getUsPR                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Restaura informacoes do usuario do portal em variaveis !
!                  !  globais. (ficava em session antes                      !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 08/02/2021                                              !
+----------------------------------------------------------------------------+
*/
user function getUsPR(cTipo, cCodigo)
	local aSessions := {}
	local aRet := {"", ""}
	local nPos
	default cTipo := "Vendedor" 
	GetGlbVars(SESSHTTP, aSessions)
    if valtype(aSessions) = "A"
		nPos := ascan(aSessions, {|x| upper(x[1]) = upper(cTipo) .and. x[2] = cCodigo})
		if !empty(nPos)
			aRet[1] := aSessions[nPos, 3]
			aRet[2] := aSessions[nPos, 4]
		Endif
    endif
return aRet
