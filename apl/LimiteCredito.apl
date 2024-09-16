#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ LimiteCredito ¦ Autor ¦ Lucilene Mendes   ¦ Data ¦16.07.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Grid com lista de clientes x vendedor p consulta de credito¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function LimiteCredito()
Local cHtml
                   
Private cColunas:= ""
Private cItens	:= ""  
Private cTopo	:= ""  
Private cSite	:= "u_PortalLogin.apw"
Private cPagina	:= "Clientes"
Private cTitle	:= "" 
Private lTableTools:= .T.
Private lSidebar:= .F.
Private cCodLogin := ""
Private cVendLogin:= ""

Web Extended Init cHtml Start U_inSite()

	cVendLogin := u_GetUsrPR()
	cCodLogin  := U_SetParPR(cVendLogin)

	// TODO - Pedro 20210208 - Remover???
	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL='+cSite+'">'	
		Return cHtml
	Else
		If !Empty(HttpSession->Superv) .and. HttpSession->Superv <> HttpSession->CodVend
			HttpSession->CodVend:= HttpSession->Superv
		Endif
	Endif
	
	// Pega do parâmetro com o Titulo do Portal
	cTitle	:= SuperGetMV("PS_TITLE", .T., "Portal SMS")
	
	// Define a funcao a ser chama no link
	cSite	:= "u_SMSPortal.apw?PR="+cCodLogin
	
	// Monta o cabeçalho para a pagina
	cHeader := U_PSHeader(cTitle, cSite) 	
	
	//Função que atualiza os menus
	cMenus := U_GetMenus(AllTrim(Upper(Procname())), cVendLogin)
	    
	//Topo da janela
	//Botão incluir novo orçamento
	cTopo:= '<div class="row form-group">'
  	cTopo+= '	<div class="col-sm-3">'
    cTopo+= '		<button class="btn btn-primary" id="btAddCli" name="btAddCli" onclick="javascript: location.href= '+"'"+' u_AddCliente.apw?PR=' +cCodLogin+"'"+ ';">'
    cTopo+= '		  <i class="fa fa-plus"></i> Novo Cliente</button>'
    cTopo+= '  	</div>'
	cTopo+= '</div>'

	//Cabeçalho do grid
	cColunas+= '<th>Código</th>'
	cColunas+= '<th>Loja</th>'
	cColunas+= '<th>CNPJ</th>'
	cColunas+= '<th>Razão Social</th>'
	cColunas+= '<th>Nome Fantasia</th>'
	cColunas+= '<th>Endereço</th>'
	cColunas+= '<th>Cidade</th>'
	cColunas+= '<th>UF</th>'
	cColunas+= '<th>Telefone</th>'
	cColunas+= '<th>E-mail</th>'
	cColunas+= '<th>Última Compra</th>'
	cColunas+= '<th>Dias em Atraso</th>'
	If HttpSession->Tipo = 'S' //Supervisor acessa todas as informações da sua equipe
		cColunas+= '<th>Vendedor</th>'
    Endif
	cColunas+= '<th>Mensagem para o financeiro</th>'
    
	// Localiza os clientes deste vendedor
	cQuery := " Select SA1.R_E_C_N_O_ RECSA1, A1_COD, A1_LOJA, A1_CGC, A1_NOME, A1_NREDUZ, A1_BAIRRO, A1_END, A1_MUN, A1_EST, A1_DDD,"
	cQuery += " A1_TEL, A1_EMAIL, A1_COND, A1_VEND, A1_ULTCOM, (SELECT MIN(E1_VENCTO )VENCTO FROM "+RetSqlName("SE1")+" SE1 "
	cQuery += " WHERE E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA AND E1_SALDO > 0 AND E1_VENCTO < '"+dtos(dDataBase)+"' "
	cQuery += " AND SE1.D_E_L_E_T_ = ' ') AS VENCTO"
	cQuery += " From "+RetSqlName("SA1")+" SA1 "
	cQuery += " Where A1_FILIAL = '"+xFilial("SA1")+"' "
	If HttpSession->Tipo = 'S' //Supervisor acessa todas as informações da sua equipe
		cQuery += " And A1_VEND in "+FormatIn(HttpSession->Equipe,"|")+" "
	Else	
		cQuery += " And A1_VEND = '"+Alltrim(HttpSession->CodVend)+"' "
    Endif
	cQuery += " And A1_MSBLQL <> '1' "
	cQuery += " And A1_ULTCOM >= '"+DTOS(MonthSub(date(),6))+"' "
	cQuery += " And SA1.D_E_L_E_T_ = ' ' "
	cQuery += " Order by A1_NOME "
	
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	Endif	 	
	APWExOpenQuery(ChangeQuery(cQuery),'QRY',.T.)
 
	While QRY->(!Eof())
		cClick:= 'onclick="detLimite('+"'"+QRY->A1_COD+QRY->A1_LOJA+"'"+'); "'
		cItens+='<tr>'
	    cItens+='	<td role="button" '+cClick+'>'+QRY->A1_COD+'</td>'
	    cItens+='	<td role="button" '+cClick+'>'+QRY->A1_LOJA+'</td>'
	    cItens+='	<td role="button" '+cClick+'>'+Transform(QRY->A1_CGC,PesqPict("SA2","A2_CGC"))+'</td>'
	    cItens+='	<td role="button" '+cClick+'>'+Alltrim(QRY->A1_NOME)+'</td>'
	    cItens+='	<td role="button" '+cClick+'>'+Alltrim(QRY->A1_NREDUZ)+'</td>'
	    cItens+='	<td role="button" '+cClick+'>'+Alltrim(QRY->A1_END)+" - "+Alltrim(QRY->A1_BAIRRO)+'</td>'
	    cItens+='	<td role="button" '+cClick+'>'+Alltrim(QRY->A1_MUN)+'</td>'
	    cItens+='	<td role="button" '+cClick+'>'+Alltrim(QRY->A1_EST)+'</td>'
	    cItens+='	<td role="button" '+cClick+'>('+Alltrim(QRY->A1_DDD)+')'+Alltrim(QRY->A1_TEL)+'</td>'
	    cItens+='	<td role="button" '+cClick+'>'+Alltrim(QRY->A1_EMAIL)+'</td>'
	    cItens+='	<td role="button"  '+cClick+' data-order="'+(QRY->A1_ULTCOM)+'">'+dtoc(stod(QRY->A1_ULTCOM))+'</td>'
	    cItens+='	<td role="button"  '+cClick+' data-order="'+(QRY->VENCTO)+'">'+Iif(Empty(QRY->VENCTO),"0",cValtochar(dDataBase - STOD(QRY->VENCTO)))+'</td>'
	    If HttpSession->Tipo = 'S' //Supervisor acessa todas as informações da sua equipe
			cItens+='	<td role="button" '+cClick+'>'+QRY->A1_VEND+' - '+Posicione("SA3",1,xFilial("SA3")+QRY->A1_VEND,"A3_NREDUZ")+'</td>'
	    Endif
		cItens+='	<td class="actions">'
		cItens+='   <a href="#" data-toggle="tooltip" data-original-title="Mensagem ao financeiro" title="" onClick="javascript:mensagemFin('+cValtoChar(QRY->RECSA1)+');"><i class="fa fa-envelope-o"></i></a>'
	    cItens+='	</td>'
	    cItens+='</tr>'
	    
	    QRY->(dbSkip())
	End    
	
	//Retorna o HTML para construção da página 
	cHtml := H_SMSGrid()	
	
Web Extended End

Return (cHTML) 





/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ ConsLmt	   ¦ Autor ¦ Lucilene Mendes  	¦ Data ¦ 16.07.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Retorna o limite do cliente							      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function ConsLmt()
Local cHtml:= ""
Local cCliente	:= Alltrim(HttpPost->cliente)
Local nSaldo	:= 0
Local nPrev		:= 0
Local nFirme	:= 0
Local nAtraso 	:= 0
Local nDias		:= 0

Web Extended Init cHtml Start U_inSite()
  
	//Posiciona no cliente              
	dbSelectArea("SA1")
	SA1->(dbSeek(xFilial("SA1")+cCliente))   
    
	//Busca valor em orçamentos
	cQry:= "SELECT CJ_XTPORC, SUM(CK_VALOR) VALOR FROM "+RetSqlName("SCJ")+" SCJ "
	cQry+= "INNER JOIN "+RetSqlName("SCK")+" SCK ON CK_FILIAL = CJ_FILIAL AND CK_CLIENTE = CJ_CLIENT AND CK_LOJA = CJ_LOJA AND CK_NUM = CJ_NUM "
	cQry+= "	AND SCK.D_E_L_E_T_ = ' ' "
	cQry+= "WHERE CJ_CLIENTE = '"+SA1->A1_COD+"' AND CJ_LOJA = '"+SA1->A1_LOJA+"' "
	cQry+= "AND CJ_STATUS = 'A' AND SCJ.D_E_L_E_T_ = ' ' "
	cQry+= "GROUP BY CJ_XTPORC "

	If Select("QRL") > 0
		QRL->(dbCloseArea())
	Endif
	APWExOpenQuery(cQry,'QRL',.T.)	
	
	While QRL->(!Eof())
		If QRL->CJ_XTPORC = '2'
			nPrev+= QRL->VALOR
		Else
			nFirme+= QRL->VALOR
		Endif		
		QRL->(DBSkip())
	End	
	
	nSaldo:= SA1->A1_LC - (SA1->A1_SALPEDL+SA1->A1_SALDUP)

	//Busca os titulos em atraso do cliente
	nDias:= GetNewPar("AA_DIASATR",1)
	cQry:= " Select SUM(E1_SALDO) ATRASO from "+RetSqlName("SE1")+" SE1 "
	cQry+= " Where E1_CLIENTE = '"+SA1->A1_COD+"' "
	cQry+= " And E1_LOJA = '"+SA1->A1_LOJA+"' "
	cQry+= " And E1_SALDO > 0 "
	cQry+= " And E1_TIPO not in ('NCC','RA') "
	cQry+= " And E1_VENCREA < '"+dtos(dDataBase - nDias)+"' "
	cQry+= " And D_E_L_E_T_ = ' ' "

	If Select("QRA") > 0
		QRA->(dbCloseArea())
	Endif
	TcQuery cQry New Alias "QRA"


	If QRA->(!Eof())
		nAtraso:= QRA->ATRASO
	Endif

	  
	cHtml:= Transform(SA1->A1_LC,PesqPict("SA1","A1_LC"))+'|'+Transform(SA1->A1_SALPEDL,PesqPict("SA1","A1_SALPEDL"))
	cHtml+='|'+Transform(SA1->A1_SALDUP,PesqPict("SA1","A1_SALDUP"))+'|'+Transform(nSaldo,PesqPict("SA1","A1_SALDUP"))
	cHtml+='|'+dtoc(SA1->A1_VENCLC)+'|'+SA1->A1_RISCO+'|'+Transform(SA1->A1_SALPED,PesqPict("SA1","A1_SALPED")) 
	cHtml+='|'+Transform(nPrev,PesqPict("SA1","A1_SALDUP"))+'|'+Transform(nFirme,PesqPict("SA1","A1_SALDUP"))
	cHtml+='|'+Transform(nAtraso,PesqPict("SA1","A1_SALDUP"))+'|'+Transform(SA1->A1_SALPEDL+SA1->A1_SALDUP,PesqPict("SA1","A1_SALDUP"))
Web Extended End

Return (cHTML) 


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ EnvMsgFin   ¦ Autor ¦ Lucilene Mendes  	¦ Data ¦ 14.09.22 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Envia mensagem para o financeiro						      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function EnvMsgFin()
Local cHtml:= ""
Local cMsg:= ""
Local cDestMail:= ""
Local cDirAnexos:= '\web\PortalSMS\upload\'+dtos(dDataBase)
Local cVend:= ""
Local cMensag:= Alltrim(HttpPost->mensagem)
Local cAnexos:= Alltrim(HttpPost->anexos)
Local nRecCli:= val(Alltrim(HttpPost->cliente))
Local aAnexos:= {}
Local i:= 0

Web Extended Init cHtml Start U_inSite()
  
	cVend := u_GetUsrPR()
	cCodLogin  := U_SetParPR(cVend)
	HttpSession->codVend:= cVend

	cDirAnexos+= +'\'+cVend+"\"
	//Verifica se possui anexos
	If !Empty(cAnexos)
		aAnexos:= Separa(cAnexos,"|")

		For i:= 1 to Len(aAnexos)
			If !Empty(aAnexos[i])
				aAnexos[i]:= cDirAnexos+aAnexos[i]
			Endif
		Next
	Endif

	//Posiciona no cliente              
	dbSelectArea("SA1")
	SA1->(dbGoto(nRecCli))

	//Posiciona no vendedor              
	dbSelectArea("SA3")
	SA3->(dbSeek(xFilial("SA3")+cVend))

	cMsg:= "Mensagem enviada pelo Portal do Representante.<br><br>"
	cMsg+= chr(13)+chr(10)
	cMsg+= "Vendedor: "+SA3->A3_COD+" - "+Upper(Alltrim(SA3->A3_NOME))+'<br>'
	cMsg+= "Cliente: "+SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+Upper(Alltrim(SA1->A1_NOME))+'<br>'
	cMsg+= "Mensagem: "+cMensag
	cDestMail:= GetNewPar("RB_MSGFIN")
	u_MailCM("Mensagem do Representante",{cDestMail},{},"Mensagem do Representante",cMsg,"","",aAnexos)



Web Extended End

Return (cHTML) 




// Função para anexar os arquivos no Portal - Joab Rodrigues - 05/03/2012
User Function uploadfile()
Local cDrive, cDir:='', cNome, cExt
Local cDirAnx:= '\web\PortalSMS\upload\'
Local cHtml:= ""
Local nI:= 0

Web Extended Init cHtml Start U_inSite()
	cVendLogin := u_GetUsrPR()
	cCodLogin  := U_SetParPR(cVendLogin)
	HttpSession->codVend:= cVendLogin

	aInfo := HttpPost->aPost
	if valtype(aInfo) = "A"

		//Cria a pasta para salvar o arquvio
		
		If !ExistDir(cDirAnx)
			MakeDir(cDirAnx)
		Endif	
		
		cDirAnx+=dtos(dDataBase)
		If !ExistDir(cDirAnx)
			MakeDir(cDirAnx)
		Endif

		cDirAnx+='\'+HttpSession->CodVend
		If !ExistDir(cDirAnx)
			MakeDir(cDirAnx)
		Endif
		cDirAnx+='\'

		For nI := 1 to len(aInfo)
			conout('POST '+str(nI,3)+' = '+aInfo[nI]+' -> '+&("HTTPPOST->"+aInfo[nI]))
			SplitPath( &("HTTPPOST->"+aInfo[nI]), @cDrive, @cDir, @cNome, @cExt )
			cNomeArq := STRTRAN(U_NoAcMI(cNome)," ","_")
			
			If(FRenameEx(&("HTTPPOST->"+aInfo[nI]),cDirAnx+cNomeArq+cExt)==-1)
				conout(FError())
			EndIf
			cHtml+=cNomeArq+cExt+"|"
		Next
	endif
Web Extended End

Return cHtml

