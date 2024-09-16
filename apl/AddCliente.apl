#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
#DEFINE SMSDEBUG
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ AddCliente  ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦01.12.20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Criação de cadastro de cliente simplificado.				  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function AddCliente()
Local cHtml
Local a:= 0

Private cDirPortal 	:= ""
Private cEndServ 	:= "" // Endereço do servidor da pagina de Portal
Private cCodVend	:= ""
Private cNomeVend	:= ""
Private cOpcao		:= ""
Private cTipo		:= ""
Private cComboTipo	:= ""
Private cCNPJ		:= ""
Private cGrupoTri	:= ""
Private cGrupoCli	:= ""
Private cNome		:= ""
Private cNReduz		:= ""
Private cEndereco	:= ""
Private cBairro		:= ""
Private cCidade		:= ""
Private cEstado		:= ""
Private cCep		:= ""
Private cDDD		:= ""
Private cTelefone	:= ""
Private cTelex		:= ""
Private cEmail		:= ""
Private cContato	:= ""
Private cOptMun		:= ""
Private cContrib	:= ""
Private cClassif	:= ""
Private cDisabled	:= ' disabled '
Private nPosTipo	:= 0
Private aTipo	 	:= {}
Private aEstado	 	:= {}             				
				
Private cSite	  := "u_PortalLogin.apw"
Private cPagina	  := "Cadastro de Cliente"
Private cMenus	  := ""
Private cTitle	  := "Portal SMS"
Private cBotoes	  := ""
Private cCodLogin := ""
Private cVendLogin:= ""                                                       	
Web Extended Init cHtml Start U_inSite()
 
 	cVendLogin := u_GetUsrPR()
	cCodLogin  := U_SetParPR(cVendLogin)

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
	cSite	:= Procname()+".apw?PR="+cCodLogin
	
	// Monta o cabeçalho para a pagina
	cHeader := U_PSHeader(cTitle, cSite) 	
	
	//Função que atualiza os menus
	cMenus := U_GetMenus(AllTrim(Upper(Procname())), cVendLogin)
	
	
	
	//Atualiza as variáveis
	cEndServ := GetMv('MV_WFBRWSR')
	cCodVend := cVendLogin //HttpSession->CodVend
	cNomeVend:= HttpSession->Nome
	
	//Tipo do Cliente
	aTipo:= {{"F","Consumidor Final"},{"L","Produtor Rural"},{"R","Revendedor"},{"S","Solidário"},{"X","Exportação"}}
	cTipo:='<select class="form-control mb-md" name="A1_TIPO" id="A1_TIPO" required="" aria-required="true" value="" onchange="javascript:vldTipo();" >'
	cTipo+='	<option value=""></option>'
	For a:= 1 to Len(aTipo)
		cTipo+='	<option value="'+aTipo[a,1]+'">'+aTipo[a,2]+'</option>'
	Next
	cTipo+='</select>'

	//Contribuinte
	cContrib:='<select class="form-control mb-md" name="A1_TIPO" id="A1_CONTRIB" required="" aria-required="true" value="" disabled>'
	cContrib+='	<option value=""></option>'
	cContrib+='	<option value="1">Sim</option>'
	cContrib+='	<option value="2">Não</option>'
	cContrib+='</select>'
	
	//Grupo de cliente - Tributação
	cGrupoTri:='<select data-plugin-selectTwo class="form-control populate mb-md" name="A1_GRPTRIB" id="A1_GRPTRIB" value="" disabled>'
	cGrupoTri+='	<option value=""></option>'
	dbSelectArea("SX5")
	dbSeek(xFilial("SX5")+'Z1')
	While SX5->(!Eof()) .and. SX5->X5_FILIAL = xFilial("SX5") .and. SX5->X5_TABELA = 'Z1'
		cGrupoTri+='	<option value="'+Alltrim(SX5->X5_CHAVE)+'">'+Alltrim(SX5->X5_DESCRI)+'</option>'
		SX5->(dbSkip())
	End
	cGrupoTri+='</select>' 
	
	//Grupo de cliente
	cGrupoCli:='<select data-plugin-selectTwo class="form-control populate mb-md" name="A1_GRPCLI" id="A1_GRPCLI" value="" disabled>'
	cGrupoCli+='	<option value=""></option>'
	dbSelectArea("SX5")
	dbSeek(xFilial("SX5")+'ZD')
	While SX5->(!Eof()) .and. SX5->X5_FILIAL = xFilial("SX5") .and. SX5->X5_TABELA = 'ZD'
		cGrupoCli+='	<option value="'+SX5->X5_CHAVE+'">'+SX5->X5_DESCRI+'</option>'
		SX5->(dbSkip())
	End
	cGrupoCli+='</select>' 

	//Classificação do Cliente                                                                            
	aClass:= {{"1","Habitual"},{"2","Exporádico"},{"3","Formal"},{"4","Objetivo"},{"5","RCC"}}
	cClassif:='<select class="form-control mb-md" name="A1_XCLASS" id="A1_XCLASS" required="" aria-required="true" value="" disabled>'
	cClassif+='	<option value=""></option>'
	For a:= 1 to Len(aClass)
		cClassif+='	<option value="'+aClass[a,1]+'">'+aClass[a,2]+'</option>'
	Next
	cClassif+='</select>'

	//Estado
	dbSelectArea("SX5")
	dbSeek(xFilial("SX5")+'12')
	While SX5->(!Eof()) .and. SX5->X5_FILIAL = xFilial("SX5") .and. SX5->X5_TABELA = '12'
		aAdd(aEstado,{SX5->X5_CHAVE,SX5->X5_DESCRI})
		SX5->(dbSkip())
	End
	cEstado:='<select data-plugin-selectTwo class="form-control populate mb-md" name="A1_EST" id="A1_EST" onchange="javascript:SetCidade()" value="" disabled>'
	cEstado+='	<option value=""></option>'
	For f:= 1 to Len(aEstado)
		cEstado+='	<option value="'+alltrim(aEstado[f,1])+'">'+alltrim(aEstado[f,2])+'</option>'
	Next
	cEstado+='</select>' 
	
	//Adiciona os botões da página
	cBotoes+='<input class="btn btn-primary" type="button" id="btSalvar" name="btSalvar" value="Salvar"/>'+chr(13)+chr(10)
	cBotoes+='<input class="btn btn-primary" type="button" id="btVoltar" name="btVoltar" value="Voltar" onclick="javascript: location.href='+"'"+'u_LimiteCredito.apw?PR='+cCodLogin+"';"+'"/>'+chr(13)+chr(10)
	
	//Retorna o HTML para construção da página 
	cHtml := H_AddCliente()
	
Web Extended End

Return (cHTML) 


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ fVldCGC   	¦ Autor ¦ Lucilene Mendes   ¦ Data ¦ 02.12.20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Função utilizada no Ajax para validar o CPF/CNPJ		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function fVldCGC()
Local cCGC	:= HttpPost->CGC
Local cTipo := HttpPost->tipo
Local cHtml	:= ""

Web Extended Init cHtml Start U_inSite()

	If !Empty(cCgc)
		//Remove os separadores
		cCgc:= StrTran(StrTran(StrTran(cCGC,".",""),"-",""),"/","")
		
		//Verifica se num é válido
		If cTipo <> "X"
			SA1->(dbSetOrder(3))
			If SA1->(dbSeek(xFilial("SA1")+cCGC))
				cHtml:= SA1->A1_COD+'/'+SA1->A1_LOJA
			Endif
		Endif	
	Endif

Web Extended end

Return cHtml



/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ fSetCidade 	¦ Autor ¦ Lucilene Mendes   ¦ Data ¦ 02.12.20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Localiza as cidades do estado selecionado			      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function fSetCidade()
Local cEstado	:= Alltrim(HttpPost->estado)
Local cCombo 	:= ""
Local cHtml	:= ""

Web Extended Init cHtml Start U_inSite()

	If !Empty(cEstado)
		dbSelectArea("CC2")	
		CC2->(dbSeek(xFilial("CC2")+cEstado))
		cCombo+='	<option value=""></option>'
		While CC2->(!Eof()) .and. CC2->CC2_EST = cEstado
			cCombo+='	<option value="'+CC2->CC2_CODMUN+'">'+CC2->CC2_MUN+'</option>'
			CC2->(dbSkip())
		End
	Endif

	cHtml:= cCombo

Web Extended end

Return cHtml


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ SlvCliente  ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦02.12.20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Gera o cadastro do cliente.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function SlvCliente()                                            
Local cHtml
Local cDirErro  := "erro\"
Local cDestMail	:= ""
Local aCliente 	:= ""
Local cTabPreco := ""
Private lMsErroAuto:= .F.

Web Extended Init cHtml Start U_inSite()


	// #IFDEF SMSDEBUG
	//   conOut(Procname()+"("+ltrim(str(procline()))+") *** Portal ")
	//   aInfo := HttpGet->aGets
	//   For nI := 1 to len(aInfo)
	//    conout('GET '+str(nI,3)+' = '+aInfo[nI]+' -> '+&("HTTPGET->"+aInfo[nI]))
	//   Next
	//   aInfo := HttpPost->aPost
	//   For nI := 1 to len(aInfo)
	//    conout('POST '+str(nI,3)+' = '+aInfo[nI]+' -> '+&("HTTPPOST->"+aInfo[nI]))
	//   Next
	// #ENDIF
    
    //Verifica se não perdeu a sessão
    If type("HttpSession->CodVend") = "U" .or. Empty(HttpSession->CodVend)
		conout(Procname()+"("+ltrim(str(procline()))+") *** Portal "+"Sessao encerrada")
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_SMSPortal.apw">'
		return cHtml
	Else	
		//Posiciona no vendedor
		SA3->(dbSeek(xFilial("SA3")+HttpSession->CodVend))
	Endif
	
	cCnpj:= StrTran(StrTran(StrTran(HttpPost->A1_CGC,".",""),"-",""),"/","")
	cTipo:= Iif(HttpPost->A1_TIPO = "F" .and. !Empty(HttpPost->A1_INSCR),"S",HttpPost->A1_TIPO)
	cDDD:= Iif(Type("HttpPost->A1_TEL") = "U","",Left(StrTran(StrTran(HttpPost->A1_TEL,"(",""),")",""),2))
	cTel:= Iif(Type("HttpPost->A1_TEL") = "U","",Alltrim(Substr(StrTran(StrTran(HttpPost->A1_TEL,"(",""),")",""),3)))
	cFax:= Iif(Type("HttpPost->A1_TELEX") = "U","",Substr(StrTran(StrTran(HttpPost->A1_TELEX,"(",""),")",""),3))
	cCep:= Iif(Type("HttpPost->A1_CEP") = "U","",StrTran(HttpPost->A1_CEP,"-",""))
	cEndereco:= Iif(Type("HttpPost->A1_END") = "U","",Upper(HttpPost->A1_END))
	cComplem:= Iif(Type("HttpPost->A1_COMPLEM") = "U","",ALLTRIM(HttpPost->A1_COMPLEM))
	cBairro:= Iif(Type("HttpPost->A1_BAIRRO") = "U","",ALLTRIM(Upper(HttpPost->A1_BAIRRO)))
	cEmail:= Iif(Type("HttpPost->A1_EMAIL") = "U","",ALLTRIM(Lower(HttpPost->A1_EMAIL)))
	cInscricao:= Iif(Type("HttpPost->A1_INSCR") = "U","",Iif(Empty(HttpPost->A1_INSCR),'ISENTO',HttpPost->A1_INSCR))
	cGrupoCli:= Iif(Type("HttpPost->A1_GRPCLI") = "U","",Alltrim(HttpPost->A1_GRPCLI))
	cGrupoTri:= Iif(Type("HttpPost->A1_GRPTRIB") = "U","",Alltrim(HttpPost->A1_GRPTRIB))
	cContato:= Iif(Type("HttpPost->A1_CONTATO") = "U","",Upper(HttpPost->A1_CONTATO))
	cContrib:= Iif(Type("HttpPost->A1_CONTRIB") = "U","2",HttpPost->A1_CONTRIB)
	cClassif:= Iif(Type("HttpPost->A1_XCLASS")= "U","",HttpPost->A1_XCLASS)
	cMsBlock:= '1' //Iif(Val(cInscricao)>0 .and. HttpPost->A1_TIPO $ "F|R",'1','2')
	cNatureza:= GetNewPar("AA_NATCLI","1001001")
	cCtaContabil:= GetNewPar("AA_CTACLI","11201002")
	cTabPreco := GetNewPar("RB_TABCLI","001")

	// Verifica se o cliente ja esta cadastrado
	dbSelectArea("SA1")
	SA1->(DbSetOrder(3))  // A1_FILIAL+A1_CGC
	if SA1->(dbSeek(xFilial("SA1")+cCNPJ))
		cHtml:= "erro"
		return cHtml
	endif
	SA1->(DbSetOrder(1))  // A1_FILIAL+A1_COD+A1_LOJA
	//Dados para cadastrar o cliente
	aCliente:=  	{{"A1_CGC"       ,cCNPJ 										,Nil},;
					{"A1_NOME"      ,ALLTRIM(Upper(HttpPost->A1_NOME))				,Nil},;
					{"A1_PESSOA"    ,Iif(Len(cCNPJ)>11,"J","F")						,Nil},;
					{"A1_NREDUZ"    ,ALLTRIM(Upper(HttpPost->A1_NREDUZ))			,Nil},;
					{"A1_TIPO"      ,cTipo											,Nil},;
					{"A1_CEP"       ,cCep											,Nil},; 
					{"A1_END"       ,cEndereco										,Nil},;
					{"A1_EST"       ,ALLTRIM(HttpPost->A1_EST)	 					,Nil},;
					{"A1_COD_MUN"   ,ALLTRIM(HttpPost->A1_COD_MUN)					,Nil},;
					{"A1_BAIRRO"    ,Left(cBairro,30)								,Nil},;
					{"A1_COMPLEM"   ,cComplem										,Nil},;
					{"A1_INSCR"     ,cInscricao										,Nil},;
					{"A1_CONTRIB"   ,cContrib										,Nil},;
					{"A1_DDD"   	,cDDD											,Nil},;
					{"A1_TEL"   	,StrTran(cTel,"-","")							,Nil},;
					{"A1_TELEX"   	,StrTran(cFax,"-","")							,Nil},;	
					{"A1_EMAIL"   	,cEmail											,Nil},;	
					{"A1_PAIS"   	,"105"											,Nil},;   
					{"A1_CODPAIS"   ,"01058"  										,Nil},;   
					{"A1_RISCO"     ,"D"  											,Nil},; 
					{"A1_LC"     	,0.01  											,Nil},; 
					{"A1_MORADIA"  	,GetNewPar("AA_MORADIA",0.07)					,Nil},; 
					{"A1_MSBLQL"    ,cMsBlock										,Nil},; 
					{"A1_DTINIV"    ,date()				  							,Nil},; 
					{"A1_GRPTRIB"   ,cGrupoTri			  							,Nil},;
					{"A1_GRPCLI"    ,cGrupoCli			  							,Nil},;
					{"A1_XCLASS"    ,cClassif			  							,Nil},;
					{"A1_CONTA"     ,cCtaContabil			  						,Nil},;
					{"A1_VEND"      ,SA3->A3_COD			  						,Nil},; //{"A1_VEND2"     ,SA3->A3_SUPER			  						,Nil},;//{"A1_VEND3"     ,SA3->A3_GEREN			  						,Nil},;
					{"A1_CONTATO"   ,cContato				  						,Nil},;
					{"A1_NATUREZ"   ,cNatureza  									,Nil},;
					{"A1_TABELA"    ,cTabPreco    									,Nil}}   
                          
              
						 
	lMsErroAuto := .F.
	MSExecAuto({|x,y| Mata030(x,y)},aCliente,3)

	If lMsErroAuto
		If !ExistDir(cDirErro)
			MakeDir(cDirErro)
		Endif	
		
		cDirErro+=dtos(date())
		If !ExistDir(cDirErro)
			MakeDir(cDirErro)
		Endif
		//Grava o erro
		cMsg:= MostraErro(cDirErro,"erro_cliente_"+cCNPJ+'_'+strtran(time(),":","")+".txt")
		
		cHtml:= "erro" 

		//Envio de e-mail avisando do cadastro
		cDestMail:= GetNewPar("AA_MCADCLE")
	
		u_MailCM("ERRO CADASTRO DE CLIENTE",{cDestMail},{},"ERRO NOVO CLIENTE PORTAL",cMsg,"","")
	Else
		SA1->(dbSetOrder(3))
		SA1->(dbSeek(xFilial("SA1")+cCNPJ))
		cHtml:= "Cliente cadastrado com sucesso! Aguarde a libera&ccedil;&atilde;o do cliente pelo setor Financeiro. C&oacute;digo: "+SA1->A1_COD+'/'+SA1->A1_LOJA+".<br><br>"
		

		//Envio de e-mail avisando do cadastro
		cDestMail:= GetNewPar("AA_MCADCLI")
		cMsg:= "Um novo cadastro de cliente foi gerado pelo Portal do Representante.<br><br>"
		cMsg+= "Vendedor: "+HttpSession->CodVend+" - "+Alltrim(Posicione("SA3",1,xFilial("SA3")+HttpSession->CodVend,"A3_NOME"))+"<br>"
		cMsg+= "Cliente: "+SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+SA1->A1_NOME+"<br>"
	
		aCombo:= StrTokArr(Posicione('SX3',2,'A1_TIPO','X3CBox()'),";")
		nPos:= aScan(aCombo,{|x| Left(x,1)== SA1->A1_TIPO})
		cMsg+= "Tipo: "+Substr(aCombo[nPos],3)+"<br>"
		u_MailCM("CADASTRO DE CLIENTE",{cDestMail},{},"NOVO CLIENTE PORTAL: "+SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+;
				    trim(SA1->A1_NOME),cMsg,"","")

	Endif
Web Extended End

Return cHTML

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ fCEPEnd	   ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦22.12.20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Busca o endereço pelo CEP.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function fCEPEnd()
Local cHtml	:= ""
Local cCep:= ""
Local aRet:= {}

Web Extended Init cHtml Start U_inSite()

cCep:= StrTran(HttpPost->CEP,"-","")
If len(cCep) < 8
	cHtml:= "F#CEP inv&aacute;lido."
Else	
	aRet:=  u_fbuscaCEP(cCep,.T.)
	If !aRet[1]
		cHtml:= "F#"+aRet[2]
	Else
		cHtml:= "T#"+Upper(aRet[2])+"#"+Substr(aRet[3],3)+"#"+Upper(NoAcento(Left(aRet[5],40)))+"#"+Upper(NoAcento(aRet[6]))	
	Endif
Endif	

Web Extended End

Return cHTML
