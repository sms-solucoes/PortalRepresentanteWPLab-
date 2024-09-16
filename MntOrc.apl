#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
#DEFINE SMSDEBUG
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ MntOrc      ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦28.08.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Manutenção de Orçamento de Venda.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function MntOrc()
Local cHtml
Local nTFil		:= FWSizeFilial()
Local cItem 	:= ""
Local cTr   	:= ""
Local cPolim	:= ""
Local nDiasEnt 	:= 0 
Local nPosFrete	:= 0
Local nPerCom	:= 0
Local nValCom	:= 0
Local nOpc		:= 0
Local nLin		:= 0
Local a			:= 0
Local f			:= 0
Local nI		:= 0
Local lDigitado:= .F.
Local lMoeda	:= .F.
Local lNumber	:= .F.
Local lDeposito := .F.
Local aTpFrete	:= {}
Local aTipoOrc	:= {}
Local aVends		:= {}
Local lModalBol := .F.
Local lAtraso 	:= .F.
Local nRecSCJ   := 0
local cGrupos   :=   ""
Private cFilVen		:= ""
Private cDirOrc		:= "anexosPortal\orcamentos\"
Private cDirPortal 	:= ""
Private cEndServ 	:= "" // Endereço do servidor da pagina de Portal
Private cOrcCabec	:= ""
Private cOrcItens	:= ""
Private cItensHid	:= ""
Private cBotoes		:= ""
Private cCodOrc		:= ""
Private cTpFrete	:= ""
Private cValFre		:= ""
Private cTransp		:= ""
Private cCondPag	:= ""
Private cCliente	:= ""
Private cTabela		:= ""
Private cTipoOrc	:= ""
Private cFaixaDesc	:= ""
Private cEntrega	:= ""
Private cImport		:= ""
Private cBtnItens	:= ""
Private cTblDesc	:= ""
Private cObsInterna	:= ""
Private cObsNota	:= ""
Private cVendedor	:= ""
Private nTVlrUnit	:= 0
Private nTQtdItem   := 0
Private nTTotal		:= 0
Private nTComiss	:= 0
Private nTSaldo		:= 0
Private nTImpostos	:= 0
Private nTFrete		:= 0
Private nItens		:= 0
Private aAnexos 	:= {}
Private lNewOrc		:= .F.
Private lEdit		:= .F.              				
Private lCopy		:= .F.
Private cOptProd	:= ""
Private cOptCond	:= ""              
Private cOptModal	:= ""
				
Private cSite	  := "u_PortalLogin.apw"
Private cPagina	  := "Orçamento de Venda"
Private cMenus	  := ""
Private cTitle	  := "Portal SMS"
Private cAnexos	  := ""
Private aItens	  := {}
Private aFaixaDesc:= {}
Private lCartao    := .F.
Private lAVista    := .F.
Private lBoleto    := .F.
Private cCodLogin := ""
Private cVendLogin:= ""
Web Extended Init cHtml Start U_inSite()
 
	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL='+cSite+'">'	
		Return cHtml
	Else
		If !Empty(HttpSession->Superv) .and. HttpSession->Superv <> HttpSession->CodVend
			HttpSession->CodVend:= HttpSession->Superv
		Endif
	Endif

	cVendLogin := u_GetUsrPR()
	cCodLogin  := U_SetParPR(cVendLogin)

	// Pega do parâmetro com o Titulo do Portal
	cTitle	:= SuperGetMV("PS_TITLE", .T., "Portal SMS")
	
	// Define a funcao a ser chama no link
	cSite	:= "u_SMSPortal.apw?PR="+cCodLogin
	
	// Monta o cabeçalho para a pagina
	cHeader := U_PSHeader(cTitle, cSite) 	
	
	
	
	//Função que atualiza os menus
	cMenus := U_GetMenus(AllTrim(Upper(Procname())), cVendLogin)
	
	
	
	//Atualiza as variáveis
	cEndServ := GetMv('MV_WFBRWSR')
	cCodVend := HttpSession->CodVend
	cNomeVend:= HttpSession->Nome
	cItem := StrZero(1,TamSX3("CK_ITEM")[1])
	cOpcao := HttpGet->opc
	if !empty(HttpGet->rec)
		nRecSCJ := val(HttpGet->rec)
	EndIf
	
	lEdit := .F.
	lDele := .F.
	
	Do Case 
	     Case cOpcao == "view" 
	     	nOpc:= 2
	     	cPagina += " - Visualizar"
	     Case cOpcao == "edit" 
	     	nOpc:= 4
	     	cPagina += " - Alterar"
	     	lEdit := .T.
	     Case cOpcao == "dele"
	     	nOpc:= 5
	     	cPagina += " - Excluir"
	     	lDele := .T.
	     Case cOpcao == "copy"
	     	nOpc = 3
	     	cPagina += " - Copiar"
	     	lEdit := .T.
	     	lCopy := .T.
	EndCase
	
	//Posiciona no Orçamento
	If !Empty(nRecSCJ)
		dbSelectArea("SCJ")
		SCJ->(dbGoTo(nRecSCJ))
		
		//Troca de filial
   		u_PTChgFil(SCJ->CJ_FILIAL)
		
		dbSelectArea("SCJ")
		SCJ->(dbGoTo(nRecSCJ))
		
		dbSelectArea("SCK")
		SCK->(DbSetOrder(1))
		SCK->(dbgotop())
		SCK->(dbSeek(xFilial("SCK")+SCJ->CJ_NUM))

		dbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(dbgotop())
		SA1->(dbSeek(xFilial("SA1")+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA))
	Endif	 
		
	cCodOrc :=	'<div class="row form-group">'
	cCodOrc +=	'	<div class="col-lg-2">'
	cCodOrc +=	'		<label class="control-label">Número</label>'
	cCodOrc +=	'		<input id="CJ_NUM" name="CJ_NUM" class="form-control" value="'+SCJ->CJ_NUM+'" disabled >'
	cCodOrc +=	'		<input id="CJ_VEND" name="CJ_VEND" type="hidden" value="'+SCJ->CJ_VEND+'">'
	cCodOrc +=	'	</div>'
	cCodOrc +=	'</div>'
	cCodOrc +=	'	<div class="mb-md hidden-lg hidden-xl"></div>'
	cCodOrc +=	'<div class="mb-md hidden-lg hidden-xl"></div>'	

	//Observações do orçamento
	cObsInterna:= AllTrim(SCJ->CJ_XNOTAIN)
	cObsNota:= AllTrim(SCJ->CJ_XMSGNF)
	/*             
	aItens - array que define o cabeçalho da tabela de produtos
	[1] - Nome da coluna
	[2] - Nome do campo
	[3] - Tamanho
	[4] - Alinhamento
	[5] - Tipo
	[6] - Editável
	[7] - Obrigatório
	[8] - Moeda
	[9] - Placeholder
	[10]- Hidden
	[11] - MaxLength
	*/			
		    
	aItens := {	{"Item","CK_ITEM","*","text-left","C",.F.,.F.,.F.,"",.F.,""},;
				{"Produto","CK_PRODUTO","300px"," text-left","C",lEdit,.T.,.F.,"Selecione...",.F.,""},;  
				{"UM","CK_UM","70px"," text-right","C",lEdit,.F.,.F.,"",.T.,""},;           
				{"Quantidade","CK_QTDVEN","*"," text-right","N",lEdit,.T.,.F.,"0",.F.,""},;
				{"Vlr de Tabela","CK_PRCVEN","*"," text-right","N",lEdit,.F.,.T.,"0,00",.F.,""},;
				{"Vlr c/ Impostos","CK_XPRCIMP","*","text-right","N",.F.,.F.,.T.,"0,00",.T.,""},;
				{"Vlr de Venda","iCK_PRCVEN","*"," text-right myformato","N",.F.,.F.,.T.,"0,00",.F.,""},;
				{"Desconto","CK_XFAIXAD","*"," text-right","C",.F.,.F.,.F.,"",.T.,""},;
				{"IPI","CK_XVALIPI","*"," text-right","N",lEdit,.F.,.T.,"0,00",.T.,""},;
				{"ICMS","CK_XVALICM","*"," text-right","N",lEdit,.F.,.T.,"0,00",.T.,""},;
				{"ICMS ST","CK_XICMST","*"," text-right","N",lEdit,.F.,.T.,"0,00",.T.,""},;
			    {"% Desconto","CK_DESCONT","*"," text-right percentual","N",lEdit,.F.,.T.,"0,00",.F. ,"7"},;
				{"% Desconto 1","CK_XDESC01","*"," text-right percentual","N",.T.,.F.,.T. ,"0,00",.T.,"7"},;
				{"% Desconto 2","CK_XDESC02","*"," text-right percentual","N",.T.,.F.,.T. ,"0,00",.T.,"7"},;
				{"% Desconto 3","CK_XDESC03","*"," text-right percentual","N",.T.,.F.,.T. ,"0,00",.T.,"7"},;
				{"% Comissão","PER_COM","*"," text-right","N",.F.,.F.,.T.,"0,00",.T.,""},;
				{"Vlr Comissão","VAL_COM","*"," text-right","N",lEdit,.F.,.T.,"0,00",.T.,""},;				
		   		{"Pedido","CK_XPEDCLI","*","text-right","C",lEdit,.F.,.F.,"",.F.,""},; 
				{"Item","CK_XITEMCL","*"," text-right","C",lEdit,.F.,.F.,"" ,.F.,""},; 
		   		{"Total","CK_VALOR","150px"," text-right","N",.F.,.F.,.T.,"0,00",.F.,""},;				
				{"","ACAO","*"," text-center","X",lEdit,.F.,.F.,"",.F.,""}}				
		
	// Cria o cabeçalho dos Itens
	For nLin := 1 to Len(aItens)
		cOrcCabec += '<th'+Iif(aItens[nLin,2] == "CK_VALOR",' width="'+aItens[nLin,3]+'"',Iif(aItens[nLin,2] == "CK_PRODUTO",' width="'+aItens[nLin,3]+'"',''))
		cOrcCabec+= Iif(aItens[nLin,10],' hidden','')+'>'+aItens[nLin][1]+'</th>'
	Next 
	
	
	//Busca os titulos em atraso do cliente
	nDias:= GetNewPar("AA_DIASATR",1)
	cQry:= " Select E1_PREFIXO, E1_NUM, E1_PARCELA, E1_VENCREA, E1_SALDO from "+RetSqlName("SE1")+" SE1 "
	cQry+= " Where E1_CLIENTE = '"+SA1->A1_COD+"' "
	cQry+= " And E1_LOJA = '"+SA1->A1_LOJA+"' "
	cQry+= " And E1_SALDO > 0 "
	cQry+= " And E1_TIPO not in ('NCC','RA') "
	cQry+= " And E1_VENCREA < '"+dtos(dDataBase - nDias)+"' "
	cQry+= " And D_E_L_E_T_ = ' ' "
	cQry+= " Order by E1_NUM, E1_VENCTO "

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	Endif
	TcQuery cQry New Alias "QRY"


	If QRY->(!Eof())
		lAtraso:= .T.
	Endif

	//Tipo do Orçamento            		
	aTipoOrc:= {{"1","Firme"},{"2","Previsto"}} //,{"3","Em elaboração"}
	cTipoOrc:='<select data-plugin-selectTwo class="form-control populate mb-md" data-plugin-options='+"'"+'{"minimumResultsForSearch": "-1"}'+"'"+' 
	cTipoOrc+=' name="CJ_XTPORC" id="CJ_XTPORC" required="" aria-required="true" '
	//cTipoOrc:='<select class="form-control mb-md" name="CJ_XTPORC" id="CJ_XTPORC" required="" aria-required="true" value="'+SCJ->CJ_XTPORC+'" '
	cTipoOrc+= Iif(!lEdit .or. lAtraso,'disabled','')+'>'
	If lEdit
		For a:= 1 to Len(aTipoOrc)
			cTipoOrc+='	<option value="'+aTipoOrc[a,1]+'" '+Iif(AllTrim(aTipoOrc[a,1]) == AllTrim(SCJ->CJ_XTPORC),'selected','')+'>'+aTipoOrc[a,2]+'</option>'
		Next
	Else
		nPosTipo:= aScan(aTipoOrc,{|x|x[1]==SCJ->CJ_XTPORC})
		If nPosTipo = 0
			nPosTipo:= 1
		Endif
		cTipoOrc+='	<option value="'+aTipoOrc[nPosTipo,1]+'">'+aTipoOrc[nPosTipo,2]+'</option>'
	Endif			
	cTipoOrc+='</select>'
	
	//Tipo de frete
	aTpFrete:= {{"S","Sem Frete"},{"C","CIF"},{"F","FOB"},{"R","Retira"}}
	cTpFrete:='<select data-plugin-selectTwo class="form-control poulatemb-md" data-plugin-options='+"'"+'{"minimumResultsForSearch": "-1"}'+"'"'
	cTpFrete+=' name="CJ_TPFRETE" id="CJ_TPFRETE" onchange="javascript:VldFrete()" '
	
	//cTpFrete:='<select class="form-control mb-md" name="CJ_TPFRETE" id="CJ_TPFRETE" onchange="javascript:VldFrete()" value="'+SCJ->CJ_TPFRETE+'"'
	cTpFrete+= Iif(!lCopy .and. !lEdit,'disabled','')+'>'
	If lEdit
		For f:= 1 to Len(aTpFrete)
			cTpFrete+='	<option value="'+aTpFrete[f,1]+'" '+Iif(AllTrim(aTpFrete[f,1]) == AllTrim(SCJ->CJ_TPFRETE),'selected','')+'>'+aTpFrete[f,2]+'</option>'
		Next
	Else
		nPosFrete:= aScan(aTpFrete,{|x|x[1]==SCJ->CJ_TPFRETE})
		If nPosFrete = 0
			nPosFrete:= 1
		Endif	
		cTpFrete+='	<option value="'+SCJ->CJ_TPFRETE+'">'+aTpFrete[nPosFrete,2]+'</option>'	
	Endif	
	cTpFrete+='</select>' 
	
	// cValFre:= Alltrim(PadR(TransForm(SCJ->CJ_FRETE,PesqPict("SCJ","CJ_FRETE")),TamSX3("CJ_FRETE")[1]))
	cValFre:= Transform(SCJ->CJ_FRETE,"@E 999,999,999,999.99")
	
	//Transportadora	
	cTransp:='<select data-plugin-selectTwo class="form-control populate placeholder mb-md" data-plugin-options='+"'" '
	cTransp+='{ "placeholder": "Selecione uma Transportadora", "allowClear": false }'+"'"+' name="CJ_XTRANSP" id="CJ_XTRANSP" '
	cTransp+='required="" aria-required="true" '
	cTransp+= Iif(!lEdit .or. SCJ->CJ_TPFRETE <> 'C','disabled','')+'>' 
	cTransp+='	<option value="'+SCJ->CJ_XTRANSP+'">'+Alltrim(Posicione("SA4",1,xFilial("SA4")+SCJ->CJ_XTRANSP,"A4_NOME"))+'</option>'		
	cTransp+='</select>'
	
	
	//Faixas de Desconto
	aAdd(aFaixaDesc, {"0","   ","0"}) // Sem desconto.

    //Verifica se a tabela é de cartão de crédito/débito
	//lCartao:= Posicione("DA0",1,xFilial("DA0")+SCJ->CJ_TABELA,"DA0_XCARTA") = '1'

	//Seleciona as modalidades
	cQry:= " Select X5_CHAVE, X5_DESCRI"
	cQry+= " From "+RetSqlName("SX5")+" SX5 "
	cQry+= " Where X5_TABELA = 'ZE' "
	cQry+= " And X5_CHAVE IN ('001','002') "
	// If lCartao
	// 	cQry+= " And X5_DESCENG IN ('CC','CD') "
	// Else
	// 	cQry+= " And X5_DESCENG NOT IN ('CC','CD') "
	// Endif
	cQry+= " And SX5.D_E_L_E_T_ = ' ' "
	If Select("QRM") > 0
		QRM->(dbCloseArea())
	Endif
	APWExOpenQuery(ChangeQuery(cQry),'QRM',.T.)	
	
	cModali:= '<select data-plugin-selectTwo class="form-control populate mb-md" name="CJ_XMODALI" id="CJ_XMODALI" required="" aria-required="true" '
	cModali+= 'onchange="javascript:condPag()" '+Iif(!lEdit,'disabled','')+'>' 
    
	While QRM->(!Eof())
		cModali+='	<option value="'+Alltrim(QRM->X5_CHAVE)+'"'+Iif(AllTrim(QRM->X5_CHAVE) == AllTrim(SCJ->CJ_XMODALI),'selected','')+'>'+Alltrim(QRM->X5_DESCRI)+'</option>'
	    QRM->(dbSkip())
	End 
	cModali+='</select>'

	If SCJ->CJ_XMODALI = "002"
		lDeposito := .T.
	Endif
	cCondAV:= GetNewPar("AA_CONDAV","001") //Separar condições com vírgula. 001,002,003.


	//Seleciona as condições de pagamento disponíveis no combo
	cQry:= " Select E4_CODIGO, E4_DESCRI"
	cQry+= " From "+RetSqlName("SE4")+" SE4 "
	cQry+= " Where E4_FILIAL = '"+xFilial("SE4")+"' "
	cQry+= " And E4_XPORTAL = '1' "
	cQry+= " And E4_MSBLQL <> '1' "
	If lDeposito
		cQry+= " And E4_CODIGO IN "+FormatIn(cCondAV,",")+" " 
	Endif
	cQry+= " And SE4.D_E_L_E_T_ = ' ' "
	
	If Select("QRC")> 0
		QRC->(dbCloseArea())
	Endif	 	
	APWExOpenQuery(ChangeQuery(cQry),'QRC',.T.)
	CONOUT(CQRY) 	
	cCondPag:='<select data-plugin-selectTwo class="form-control populate placeholder mb-md" data-plugin-options='+"'" '
	cCondPag+='{ "placeholder": "Selecione...", "allowClear": false }'+"'"+' name="CJ_CONDPAG" id="CJ_CONDPAG" ' 
	cCondPag+='required="" aria-required="true" '+Iif(lCopy .or. (lEdit .and. SCJ->CJ_XTPORC $ '3/2'),'','disabled')+' onchange="javascript:vldDescto()" >'   //                             
				
	If lEdit
		While QRC->(!Eof())
            
			cCondPag+='	<option value="'+Alltrim(QRC->E4_CODIGO)+'" '+Iif(Alltrim(QRC->E4_CODIGO) == AllTrim(SCJ->CJ_CONDPAG),'selected','')+'>'+Alltrim(QRC->E4_CODIGO)+" - "+Alltrim(QRC->E4_DESCRI)+'</option>'
			QRC->(dbSkip())
		End
	Else
	 	cCondPag+='	<option value="'+SCJ->CJ_CONDPAG+'">'+SCJ->CJ_CONDPAG+" - "+Posicione("SE4",1,xFilial("SE4")+SCJ->CJ_CONDPAG,"E4_DESCRI")+'</option>'		
	Endif	
	cCondPag+='</select>'	                             
	
	
	//Select das operadoras
	
	cQry:= " Select AE_CODCLI, A1_NREDUZ"
	cQry+= " From "+RetSqlName("SA1")+" SA1, "+RetSqlName("SAE")+" SAE, "+RetSqlName("SX5")+" SX5 "
	cQry+= " Where AE_CODCLI = A1_COD "  
	cQry+= " And X5_TABELA = 'ZE' AND X5_CHAVE = '"+SCJ->CJ_XMODALI+"' "
	cQry+= " And AE_TIPO = X5_DESCENG "    
	cQry+= " And A1_FILIAL = '"+xFilial("SA1")+"' "  
	cQry+= " And AE_FILIAL = '"+xFilial("SA3")+"' "  
	cQry+= " And X5_FILIAL = '"+xFilial("SX5")+"' "  
	cQry+= " And SA1.D_E_L_E_T_ = '' "  
	cQry+= " And SAE.D_E_L_E_T_ = '' "   
	cQry+= " And SX5.D_E_L_E_T_ = '' "   
	cQry+= " Group by AE_CODCLI, A1_NREDUZ "   
	
	If Select("QRO") > 0
		QRO->(dbCloseArea())
	Endif
	APWExOpenQuery(ChangeQuery(cQry),'QRO',.T.)	
	 	
	
	cOperadora:= '<select data-plugin-selectTwo class="form-control populate placeholder mb-md" data-plugin-options='+"'" '
	cOperadora+= '{ "placeholder": "Selecione...", "allowClear": false }'+"'"+' name="OPERADORA" id="OPERADORA" '
	cOperadora+= 'required="" aria-required="true" onchange="javascript:bandeira()" disabled> ' 
     
	//Seleciona as operadoras   SAE-- BANDEIRA / ZYD -- METODO / SX5 -- MODALIDADE
	cQry:= " Select AE_CODCLI, A1_NREDUZ"
	cQry+= " From "+RetSqlName("SA1")+" SA1, "+RetSqlName("SAE")+" SAE, "+RetSqlName("SX5")+" SX5 "
	cQry+= " Where AE_CODCLI = A1_COD "  
	cQry+= " And X5_TABELA = 'ZE' AND X5_CHAVE = '"+SCJ->CJ_XMODALI+"' "
	cQry+= " And AE_TIPO = X5_DESCENG "    
	cQry+= " And A1_FILIAL = '"+xFilial("SA1")+"' "  
	cQry+= " And AE_FILIAL = '"+xFilial("SA3")+"' "  
	cQry+= " And X5_FILIAL = '"+xFilial("SX5")+"' "  
	cQry+= " And SA1.D_E_L_E_T_ = '' "  
	cQry+= " And SAE.D_E_L_E_T_ = '' "   
	cQry+= " And SX5.D_E_L_E_T_ = '' "   
	cQry+= " Group by AE_CODCLI, A1_NREDUZ "   

	If Select("QRO") > 0
		QRO->(dbCloseArea())
	Endif
	APWExOpenQuery(ChangeQuery(cQry),'QRO',.T.)	

	//Preenche o select da tabela
	While QRO->(!Eof())
		cOperadora+='	<option value="'+Alltrim(QRO->AE_CODCLI)+'" '
		cOperadora+= Iif(Alltrim(QRO->AE_CODCLI) == AllTrim(SCJ->CJ_CLIOPER),'selected','')+'>'+Alltrim(QRO->A1_NREDUZ)+'</option>'
	    QRO->(dbSkip())
    End	
    cOperadora+= '</select>'
	
	
	//Select da bandeira
	cBandeira:= '<select data-plugin-selectTwo class="form-control populate placeholder mb-md" data-plugin-options='+"'" '
	cBandeira+= '{ "placeholder": "Selecione...", "allowClear": false }'+"'"+' name="BANDEIRA" id="BANDEIRA" '
	cBandeira+= 'required="" aria-required="true" disabled> ' 


	//Seleciona as operadoras   SAE-- BANDEIRA / ZYD -- METODO / SX5 -- MODALIDADE
	// cQry:= " Select ZYD_METODO, AE_DESC"
	// cQry+= " From "+RetSqlName("ZYD")+" ZYD, "+RetSqlName("SAE")+" SAE, "+RetSqlName("SX5")+" SX5 "
	// cQry+= " Where AE_CODCLI = '"+SCJ->CJ_CLIOPER+"' "  
	// cQry+= " And AE_COD = ZYD_ADMFIN "     
	// cQry+= " And X5_TABELA = 'ZE' AND X5_CHAVE = '"+SCJ->CJ_XMODALI+"' "     
	// cQry+= " And AE_TIPO = X5_DESCENG "     
	// cQry+= " And AE_FILIAL = '"+xFilial("SA3")+"' "  
	// cQry+= " And ZYD_FILIAL = '"+xFilial("ZYD")+"' " 
	// cQry+= " And X5_FILIAL = '"+xFilial("SX5")+"' " 
	// cQry+= " And SAE.D_E_L_E_T_ = '' "   
	// cQry+= " And ZYD.D_E_L_E_T_ = '' "      
	// cQry+= " And SX5.D_E_L_E_T_ = '' "      
	
	// If Select("QRB") > 0
	// 	QRB->(dbCloseArea())
	// Endif
	// APWExOpenQuery(ChangeQuery(cQry),'QRB',.T.)	
	 
	// //Preenche o select da tabela
	// While QRB->(!Eof())
	// 	cBandeira+='	<option value="'+Alltrim(QRB->ZYD_METODO)+'" '+Iif(Alltrim(QRB->ZYD_METODO)==Alltrim(SCJ->CJ_XCODPAG),' selected','')+'>'+Alltrim(QRB->AE_DESC)+'</option>'
	//     QRB->(dbSkip())
    // End
	cBandeira+='	<option value=""></option>'
	cBandeira+= '</select>'

	
	
	//Cliente 	
	cCliente:='<select data-plugin-selectTwo class="form-control populate placeholder" data-plugin-options='+"'"
	cCliente+='{ "placeholder": "Selecione um Cliente", "allowClear": false }'+"'"+' name="CJ_CLIENTE" id="CJ_CLIENTE" '
	cCliente+=' disabled >' //value='+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA+'
	cCliente+=' <option value='+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA+'>'+SCJ->CJ_CLIENTE+'/'+SCJ->CJ_LOJA+' - '+Alltrim(Posicione("SA1",1,xFilial("SA1")+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA,"A1_NOME"))+'</option>'
	cCliente+='</select>'
	HttpSession->Cliente:= SCJ->CJ_CLIENTE+SCJ->CJ_LOJA

	//Combo da tabela de preço
	cTabela:='<select data-plugin-selectTwo class="form-control populate placeholder" data-plugin-options='+"'"
	cTabela+='{ "placeholder": "Selecione...", "allowClear": false }'+"'"+' name="CJ_TABELA" id="CJ_TABELA" '
	cTabela+='onchange="javascript:selProd()" disabled >'
	cTabela+='	<option value='+SCJ->CJ_TABELA+'>'+Alltrim(Posicione("DA0",1,xFilial("DA0")+SCJ->CJ_TABELA,"DA0_DESCRI"))+'</option>'
	cTabela+='</select>'
	HttpSession->Tabela:= SCJ->CJ_TABELA
    cPolim:= '1'
    
	//Data Prevista de Entrega
	nDiasEnt:= GetNewPar("AA_DTENT",'0')
	cEntrega:='<input type="text" id="CK_ENTREG" name="CK_ENTREG" data-plugin-datepicker data-plugin-options='+"'"+'{ "startDate": "+'+nDiasEnt+'d", "language": "pt-BR",'
	cEntrega+='"daysOfWeekDisabled": "[0]","daysOfWeekHighlighted":"[0]"}'+"'"+' class="form-control only-numbers" placeholder="__/__/____"'
	cEntrega+='value="'+Iif(lCopy,dtoc(date()+val(nDiasEnt)),DTOC(SCK->CK_ENTREG))+'" ' 
	cEntrega+=Iif(!lEdit,' disabled','')+'>'
    
    //Importadora 
/*
    cImport:= '<div class="col-lg-2">'
	cImport+= '<label class="control-label">Importadora</label>'
	cImport+= '<select data-plugin-selectTwo class="form-control populate placeholder" data-plugin-options='+"'"+'{"minimumResultsForSearch": "-1", "placeholder": "Selecione..."}'+"'"
	cImport+= ' name="CJ_XIMPORT" id="CJ_XIMPORT" required="" aria-required="true" onchange="'
	cImport+= "$('#CJ_XIMPORT').attr('disabled','');"
	cImport+= '"'+Iif(!lEdit,' disabled','')+'>'
	If SCJ->CJ_XIMPORT = '1'
		cImport+= '	<option value="1" selected>Sim</option>'
		cImport+= '	<option value="2">Não</option>'  
	Else
		cImport+= '	<option value="2" selected>Não</option>'
		cImport+= '	<option value="1">Sim</option>'
	Endif		
	cImport+= '</select></div>'
  */

    //Observações
    cObsIntern:= Alltrim(SCJ->CJ_XNOTAIN)
    cObsNota:= Alltrim(SCJ->CJ_XMSGNF)

	//Preenchimento dos itens	
	nTFrete+= SCJ->CJ_FRETE
	nTTotal+= nTFrete
	nTSaldo+= SCJ->CJ_XSALDO
	
	dbSelectArea("SCK")
	SCK->(dbSeek(SCJ->CJ_FILIAL+SCJ->CJ_NUM))
	While SCK->(!Eof()) .and. SCK->CK_FILIAL == SCJ->CJ_FILIAL .and. SCK->CK_NUM == SCJ->CJ_NUM 
		nItens++
		
		cItem := StrZero(nItens,TamSX3("CK_ITEM")[1])
		
		Posicione("SB1",1,xFilial("SB1")+SCK->CK_PRODUTO,"B1_DESC")	
		cGrupos += 	SB1->B1_GRUPO+"/"
		cOrcItens += '<tr class="odd" id="linha'+StrZero(nItens,2)+'">'
		
		nTImpostos += SCK->(CK_XICMST+CK_XVALIPI)
        nTQtdItem += SCK->CK_QTDVEN
		nTVlrUnit +=  Round(SCK->CK_QTDVEN * SCK->CK_PRCVEN,2)//- (SCK->CK_PRCVEN * Abs(SCK->CK_DESCONT) / 100))			
		nTTotal +=  SCK->(CK_VALOR+CK_XVALIPI+CK_XICMST)
		nPerCom:= 0
        nValCom:= (SCK->CK_QTDVEN * SCK->CK_PRCVEN) * (nPerCom/100)
        nTComiss+= nValCom
        		
        // gera os produtos de acordo com o Cliente e Tabela
        cOptProd := GetProdOrc(SCJ->CJ_CLIENTE, SCJ->CJ_TABELA, "")
        
		For nLin := 1 to Len(aItens)
			
			If aItens[nLin,2] == "ACAO"
				cOrcItens += '<td class="actions">' 
				If lEdit .or. lCopy //!lDele 
					//cOrcItens += '	<a href="#" id="btnRemItm" name="btnRemItm" class="on-default remove-row"><i class="fa fa-times-circle"></i></a>'
					cOrcItens += '	<i class="fa fa-info fa-lg" data-toggle="tooltip" data-original-title="Detalhes da linha" onclick="detalheOrc('+"'"+cItem+"'"+');"></i>'
					If lEdit .or. lCopy
						cOrcItens += '  <i class="fa fa-times-circle fa-lg" data-toggle="tooltip" data-original-title="Remover a linha" onclick="removeItem('+"'"+cItem+"'"+');"></i>
					Endif
				Endif
				cOrcItens += '</td>
			/*
			Elseif aItens[nLin,2] == "CK_XFAIXAD" 
				
				cFaixaDesc:='<select class="form-control mb-md" data-prop="CK_XFAIXAD" name="CK_XFAIXAD'+cItem+'" id="CK_XFAIXAD'+cItem+'" disabled '
				cFaixaDesc+='onchange="javascript:VldFaixa('+"'"+cItem+"'"+')" value='+SCK->CK_XFAIXAD+'>'
				If lEdit
					For d:= 1 to Len(aFaixaDesc)
						cFaixaDesc+='	<option value="'+aFaixaDesc[d,1]+'" '+Iif(aFaixaDesc[d,1]==SCK->CK_XFAIXAD,'selected','')+' >'+aFaixaDesc[d,2]+'</option>'
						cTblDesc += 'tblDesc.push({"op" :"'+aFaixaDesc[d,1]+'", "descricao" : "'+aFaixaDesc[d,2]+'","pcom" : '+cValToChar(aFaixaDesc[d,3])+'});'+CRLF 
					Next 
				Else 
					nPosDesc:= aScan(aFaixaDesc,{|x|x[1]==SCK->CK_XFAIXAD})
					If nPosDesc = 0
						nPosDesc:= 1
					Endif	
					cFaixaDesc+='	<option value="'+SCK->CK_XFAIXAD+'">'+aFaixaDesc[nPosDesc,2]+'</option>' 	
				Endif
				cFaixaDesc+='</select>' 
			
			
				cOrcItens += '<td'+Iif(aItens[nLin,10],' hidden','')+'>'
				cOrcItens += cFaixaDesc
				cOrcItens += '</td>'
			  */
			Else	
				cOrcItens += '<td'+Iif(!Empty(aItens[nLin][4]),' align="'+aItens[nLin][4]+'"',"")+Iif(aItens[nLin,10],'hidden','')+'>'
				
				lMoeda:= aItens[nLin,8] //Indica se é Moeda  			
				lNumber:= aItens[nLin,5] = "N" //Indica que é numérico  			
				xValue:= ""
								
				Do Case
					Case aItens[nLin][5] == 'C'
						If aItens[nLin,2] == "CK_PRODUTO"
							xValue := AllTrim(SCK->&(aItens[nLin][2]))+' - '+Alltrim(SB1->B1_DESC)
						Else
							If aItens[nLin][2] = "CK_XFAIXAD"
								xValue := ""
							Else	
								xValue := AllTrim(SCK->&(aItens[nLin][2]))
							Endif
						Endif
					Case aItens[nLin][5] == 'N'
						If aItens[nLin,2] == "CK_QTDVEN"
							//xValue := Iif(lNewOrc,"",Alltrim(PadR(TransForm(SCK->&(aItens[nLin][2]),PesqPict("SCK","CK_QTDVEN")),TamSX3(aItens[nLin,2])[1])))
						
						
							xValue := Iif(lNewOrc,"",Alltrim(cvaltochar(SCK->&(aItens[nLin][2]))))
					
						
						ElseIf aItens[nLin,2] == "PER_COM"
							xValue := Iif(lNewOrc,"",Alltrim(PadR(TransForm(nPerCom,PesqPict("SD2","D2_COMIS1")),TamSX3("D2_COMIS1")[1])))
						ElseIf aItens[nLin,2] == "VAL_COM"
							xValue := Iif(lNewOrc,"",Alltrim(PadR(TransForm(nValCom,PesqPict("SCK","CK_PRCVEN")),TamSX3("CK_PRCVEN")[1])))
						ElseIf aItens[nLin,2] == "iCK_PRCVEN"
						    xValue := Iif(lNewOrc,"",Alltrim(TransForm(SCK->CK_PRCVEN,PesqPict("SCK","CK_XICMST"))))
						Else	
							If aItens[nLin,2] == "iCK_PRCVEN"	
								xValue := Alltrim(PadR(TransForm(SCK->CK_PRCVEN,PesqPict("SCK","CK_XICMST")),TamSX3("CK_PRCVEN")[1]))
							Elseif aItens[nLin,2] == "CK_PRCVEN"	
								xValue := Alltrim(PadR(TransForm(SCK->CK_PRUNIT,PesqPict("SCK","CK_PRCVEN")),TamSX3(aItens[nLin,2])[1]))
							Elseif aItens[nLin,2] == "CK_VALOR"	
								xValue := Alltrim(TransForm(SCK->(CK_VALOR+CK_XVALIPI+CK_XICMST),PesqPict("SCK",aItens[nLin,2])))
							Else
								xValue := Alltrim(TransForm(SCK->&(aItens[nLin][2]),PesqPict("SCK",aItens[nLin,2])))
							Endif	
						Endif	
				EndCase  
			   
				If aItens[nLin,6] //Campo Editável
					If aItens[nLin,2] == "CK_PRODUTO"
					   //Cria o select para o produto
						cOrcItens +='<select class="selectpicker" name="CK_PRODUTO'+cItem+'" id="CK_PRODUTO'+cItem+'" '
						cOrcItens += Iif(aItens[nLin][7],'required="" aria-required="true" ','')+' data-live-search="true" '                                           
						cOrcItens +='onchange="javascript:gatProduto($(this))" data-width="290px" >' //style="size:4" data-width="90%" style="height:90%"
						
						cOrcItens += GetProdOrc(SCJ->CJ_CLIENTE, SCJ->CJ_TABELA, SCK->CK_PRODUTO)
		
						cOrcItens+='</select>'
					Else
						cOrcItens += '<input id="'+aItens[nLin][2]+cItem+'" data-prop="'+aItens[nLin][2]+'" name="'+aItens[nLin][2]+cItem+'" class="form-control'
						cOrcItens += Iif(lNumber, aItens[nLin][4], "")
						cOrcItens +=If(lMoeda," ",If(lNumber," only-numbers",""))+'" type="text" '
					 	cOrcItens += 'placeholder="'+aItens[nLin,9]+'" '
					 	
					 	//Atribui as funções javascript 
					 	If aItens[nLin,2] == "CK_QTDVEN"
					 		cOrcItens+='onblur="javascript:VldQtd('+"'"+cItem+"'"+') "'
					 	Endif
					 	
					 	If aItens[nLin,2] == "iCK_PRCVEN"
					 		cOrcItens+='onblur="javascript:VldValor('+"'"+cItem+"'"+') " '
					 	Endif 
					 	
					 	If aItens[nLin,2] == "CK_DESCONT" 
					 		cOrcItens+='onblur="javascript:VldValor('+"'"+cItem+"'"+') "'
					 		cOrcItens+='onclick="javascript:descPolimento('+"'"+cItem+"'"+') "'
							 
					 	Endif
				 		
				 		
					 	If aItens[nLin,2] $ ("CK_XDESC01|CK_XDESC02|CK_XDESC03")
					 		cOrcItens+='onblur="javascript:vldDesc('+"'"+cItem+"'"+')" '
					 		//cOrcItens+='onkeyup="javascript:TotalItem('+"'"+cItem+"'"+') "'
					 	Endif
					 	
				 		
					 	If aItens[nLin,2] $ ("CK_QTDVEN|iCK_PRCVEN|CK_DESCONT")
					 		cOrcItens+='onkeyup="javascript:TotalItem('+"'"+cItem+"'"+') "'
					 	Endif	
					 	//Campo obrigatório
						cOrcItens += Iif(aItens[nLin][7],'required="" aria-required="true" ','')
						
						If lEdit //Inicia todos os campos desabilitados caso não for para editar ou copiar 
							If aItens[nLin,2] <> "CK_QTDVEN" .And. !(aItens[nLin,2] $ "CK_DESCONT|CK_XDESC01|CK_XDESC02|CK_XDESC03") .And. aItens[nLin,2] <> "CK_XPEDCLI" .And. aItens[nLin,2] <> "CK_XITEMCL"
								cOrcItens += 'disabled '
							EndIf

							//Tabela de preço de campanha não gera saldo
							If Left(DA0->DA0_CODTAB,1) = "C" .and. aItens[nLin,2] = "CK_XDESC03"
								cOrcItens += 'disabled '	
							Endif
						Else
							cOrcItens += 'disabled '
						EndIf
						cOrcItens += 'value="'+Alltrim(xValue)+'">'
				    Endif
				    
				
				Else
					cOrcItens += '<input id="'+aItens[nLin][2]+cItem+'" data-prop="'+aItens[nLin][2]+'" name="'+aItens[nLin][2]+cItem+'" '
					cOrcItens += 'class="form-control input-block '+Iif(lNumber, aItens[nLin][4], "")+'" '
					cOrcItens += 'type="text" disabled width="" '
					cOrcItens += 'value="'+Alltrim(xValue)+'">'
				Endif
			Endif			
		    	    
			cOrcItens += '</td>' 
		Next	                                                                        
					
		If lEdit
			//Inputs Hidden
			cItensHid := '<input type="hidden" class="" name="VAL_DESC'+cItem+'" id="VAL_DESC'+cItem+'" value="0" />'
		    cItensHid += '<input type="hidden" class="" id="ALIQ_ICMS'+cItem+'" name="ALIQ_ICMS'+cItem+'" value="'+cValtochar(SCK->CK_XALIICM)+'">'
			cItensHid += '<input type="hidden" class="" id="ALIQ_IPI'+cItem+'" name="ALIQ_IPI'+cItem+'" value="'+cValtochar(SCK->CK_XALIIPI)+'">'
			cItensHid += '<input type="hidden" class="" id="ALIQ_ST'+cItem+'" name="ALIQ_ST'+cItem+'" value="'+cValtochar(SCK->CK_XALIST)+'">'
			cItensHid += '<input type="hidden" class="" id="VAL_ICMS'+cItem+'" name="VAL_ICMS'+cItem+'" value="'+Alltrim(Transform(SCK->CK_XVALICM,PesqPict("SCK","CK_XVALICM")))+'">'
			cItensHid += '<input type="hidden" class="" id="VAL_IPI'+cItem+'" name="VAL_IPI'+cItem+'" value="'+Alltrim(Transform(SCK->CK_XVALIPI,PesqPict("SCK","CK_XVALIPI")))+'">'
			cItensHid += '<input type="hidden" class="" id="VAL_ST'+cItem+'" name="VAL_ST'+cItem+'" value="'+Alltrim(Transform(SCK->CK_XICMST,PesqPict("SCK","CK_XICMST")))+'">'
			cItensHid += '<input type="hidden" class="" id="BASE_ICMS'+cItem+'" name="BASE_ICMS'+cItem+'" value="0">'
			cItensHid += '<input type="hidden" class="" id="BASE_ST'+cItem+'" name="BASE_ST'+cItem+'" value="0">'
			cItensHid += '<input type="hidden" class="" id="BASE_IPI'+cItem+'" name="BASE_IPI'+cItem+'" value="0">'
			cItensHid += '<input type="hidden" class="" id="QTD_EMB'+cItem+'" name="QTD_EMB'+cItem+'" value="'+cValtochar(SB1->B1_QE)+'">'
			cItensHid += '<input type="hidden" class="" id="CK_TES'+cItem+'" name="CK_TES'+cItem+'" value="'+SCK->CK_TES+'">'
			cItensHid += '<input type="hidden" class="" id="PNEU'+cItem+'" name="PNEU'+cItem+'" value="">'
			cItensHid += '<input type="hidden" class="" id="PERDESC1'+cItem+'" name="PERDESC1'+cItem+'" value="'+cValtochar(DA1->DA1_XDESC1)+'">' 
			cItensHid += '<input type="hidden" class="" id="PERDESC2'+cItem+'" name="PERDESC2'+cItem+'" value="'+cValtochar(DA1->DA1_XDESC2)+'">' 
			cItensHid += '<input type="hidden" class="" id="PERDESC3'+cItem+'" name="PERDESC3'+cItem+'" value="'+cValtochar(DA1->DA1_XDESC3)+'">' 
			cItensHid += '<input type="hidden" class="" id="GERASALDO'+cItem+'" name="GERASALDO'+cItem+'" value="'+Iif(Left(DA0->DA0_CODTAB,1) = "C",'2',cValtochar(SB1->B1_XGERASL))+'">' 
			cItensHid += '<input type="hidden" class="" id="ULTRAPASSA'+cItem+'" name="ULTRAPASSA'+cItem+'" value="'+Iif(!Empty(SB1->B1_XULTMAX),SB1->B1_XULTMAX,'1')+'">'
			cItensHid += '<input type="hidden" class="" id="QTDMIN'+cItem+'" name="QTDMIN'+cItem+'" value="'+cvaltochar(Posicione("DA1",1,xFilial("DA1")+SCJ->CJ_TABELA,"DA1_XQTMIN"))+'">'
	
			cItensHid += '<input type="hidden" class="" id="SALDO'+cItem+'" name="SALDO'+cItem+'" value="'+cValtochar(SCK->CK_XSALDO)+'">' 
	
			cItensHid += '<input type="hidden" name="DESC_MAX" id="DESC_MAX" value="" />'
			cItensHid += '<input type="hidden" id="PRODUTOS" name="PRODUTOS" value=""/>
			cOrcItens+=cItensHid 
		EndIf
			
		SCK->(dbSkip())
	End                 
	
	cOrcItens += '</tr>'	
	cOrcItens += '<input type="hidden" name="QtdItens" id="QtdItens" value="'+cValtoChar(nItens)+'"/>'
	cOrcItens += '<input type="hidden" id="PROXIMO" name="PROXIMO" value="'+StrZero(nItens,2)+'"/>
	cOrcItens += '<input type="hidden" class="" name="CJ_NUM" id="CJ_NUM" value="'+IIf(lCopy, "", SCJ->CJ_NUM)+'" />'
	cOrcItens += '<input type="hidden" name="OPCAO" id="OPCAO" value="'+cValtoChar(nOpc)+'" />'
	cOrcItens += '<input type="hidden" name="POLIMENTO" id="POLIMENTO" value="'+cPolim+'" />'
	cOrcItens += '<input type="hidden" name="DESCVISTA" id="DESCVISTA" value=0 />'
	cOrcItens += '<input type="hidden" name="ACRESCIMO" id="ACRESCIMO" value=0 />'
	cOrcItens += '<input type="hidden" name="GRUPOS" id="GRUPOS" value="'+ cGrupos + '" />'
	cOrcItens += '<input type="hidden" id="CJ_XIMPORT" name="CJ_XIMPORT" value="2"/>
	cOrcItens += '<input type="hidden" id="CONDANT" name="CONDANT" value="'+SCJ->CJ_CONDPAG+'"/>
	
	//Adiciona os botões de ações na tabela de itens
	If lEdit
		cBtnItens+='<div class="row form-group">'	              
		cBtnItens+='	<div class="col-sm-2">' 
		cBtnItens+='		<button class="btn btn-primary" id="btAddItm" name="btAddItm">' //onclick="javascript:newItem()" >'
		cBtnItens+='			<i class="fa fa-plus-square"></i> Novo Item</button>'
		cBtnItens+='	</div>'  
		cBtnItens+='</div>'
	Endif
	
	//Adiciona os botões da página
	If lEdit
		cBotoes+='<h5 class="text-primary">Orçamento válido apenas dentro do mês de '+MesExtenso(SCJ->CJ_EMISSAO)+' de '+cvaltochar(Year(SCJ->CJ_EMISSAO))+'.</h5>'
		cBotoes+='<input class="btn btn-primary" type="button" id="btSalvar" name="btSalvar" value="Salvar"/>'+chr(13)+chr(10)
	Elseif lDele
		cBotoes+='<input class="btn btn-primary " type="button" id="btExcluir" name="btExcluir" value="Excluir"/>'+chr(13)+chr(10)
	Endif
	cBotoes+='<input class="btn btn-primary" type="button" id="btVoltar" name="btVoltar" value="Voltar" onclick="javascript: location.href='+"'"+'u_orcamento.apw?PR='+cCodLogin+"';"+'"/>'+chr(13)+chr(10)
	
	//Retorna o HTML para construção da página 
	cHtml := H_AddOrc()
	
Web Extended End

Return (cHTML) 


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ ExcOrc      ¦ Autor ¦ Anderson Zelenski   ¦ Data ¦10.12.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Exclui o Orçamento de Venda								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function ExcOrc()                                            
Local cHtml
Local nOpc		:= 5 // 3- Incluir / 4- Alterar / 5- Excluir 
Local cCliente	:= ""
Local cLoja		:= ""
Local cNumOrc	:= ""
Local cDirErro  := "erro\"
Local nI		:= 0

Private cReturn
Private aCabSCJ :={}
Private aItemSCJ:={}
Private aLinhaSCJ:={}
Private lMsErroAuto:= .F.
Private cCodLogin := ""
Private cVendLogin:= ""
Web Extended Init cHtml Start U_inSite()

    //Verifica se não perdeu a sessão
    If type("HttpSession->CodVend") = "U" .or. Empty(HttpSession->CodVend)
		conout(Procname()+"("+ltrim(str(procline()))+") *** Portal "+"Sessao encerrada")
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_SMSPortal.apw">'
		return cHtml
	Endif	

	cVendLogin := u_GetUsrPR()
	cCodLogin  := U_SetParPR(cVendLogin)

    //Variáveis do cabeçalho
    cCliente:= Left(HttpPost->CJ_CLIENTE,6)
	cLoja:= Right(HttpPost->CJ_CLIENTE,6)
	cNumOrc:= HttpPost->CJ_NUM 
	
	//Posiciona nas tabelas
	If !Empty(cCliente)
		Posicione("SA1",1,xFilial("SA1")+Alltrim(HttpPost->CJ_CLIENTE),"A1_COD")
	Endif
	
	//Posiciona no orçamento
	Posicione("SCJ",1,xFilial("SCJ")+cNumOrc,"CJ_NUM")
	cFilOrc:= SCJ->CJ_FILIAL
		
	//Monta o cabeçalho
	aadd(aCabSCJ,{"CJ_NUM",cNumOrc,Nil})
	aadd(aCabSCJ,{"CJ_CLIENTE",SA1->A1_COD,Nil})
	aadd(aCabSCJ,{"CJ_LOJA", SA1->A1_LOJA ,Nil})
	
	aLinhaSCJ:={}
	
    //Monta os itens
	lMsErroAuto:= .F.
	
	//Chama execauto para inclusão do orçamento
	If Len(aCabSCJ) > 0 
		MATA415(aCabSCJ,aItemSCJ,nOpc)
	Else
		conout(Procname()+"("+ltrim(str(procline()))+") *** Portal "+"FALHA AO EXCLUIR O ORÇAMENTO!")
		lMsErroAuto:= .T.
	Endif

	If lMsErroAuto
		If !ExistDir(cDirErro)
			MakeDir(cDirErro)
		Endif	
		
		cDirErro+=dtos(date())
		If !ExistDir(cDirErro)
			MakeDir(cDirErro)
		Endif
		
		//Grava o erro
  		MostraErro(cDirErro,"erro_orcto_"+strtran(time(),":","")+".txt")
	   	cHtml:= "erro" 
	Else            
		
		SCJ->(dbGoBottom())
		cHtml:= SCJ->CJ_NUM
	EndIf
			
Web Extended End

Return (cHTML) 


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetProdOrc 	¦ Autor ¦ Anderson Zelenski ¦ Data ¦ 10.12.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Função para retornar os produtos da tabela e esta no Orç.  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function GetProdOrc(cOrcCli, cOrcTab, cOrcProd)
Local cHtml      
Local cProds := ""
Local cGrupo := ""

    //Atualiza a variável de sessão
    HttpSession->TABELA := cOrcTab
    
	//Busca os itens da tabela de preço
	cQry:="Select DA1_CODTAB, B1_GRUPO, BM_DESC, DA1_CODPRO, B1_DESC " 
	cQry+=" From "+RetSqlName("DA1")+" DA1"
	cQry+=" INNER JOIN "+RetSqlName("DA0")+" DA0 ON DA0_FILIAL = DA1_FILIAL AND DA0_CODTAB = DA1_CODTAB AND DA0_ATIVO = '1' AND DA0.D_E_L_E_T_ = ' ' "
	cQry+=" INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = DA1_CODPRO AND B1_MSBLQL <> '1' AND SB1.D_E_L_E_T_ = ' ' "
	cQry+=" INNER JOIN "+RetSqlName("SBM")+" SBM ON BM_FILIAL = '"+xFilial("SBM")+"' AND B1_GRUPO = BM_GRUPO AND SBM.D_E_L_E_T_ = ' ' "
	cQry+=" Where DA1_FILIAL = '"+xFilial("DA1")+"' "
	cQry+=" And DA1_CODTAB = '"+cOrcTab+"' "
	cQry+=" AND DA1_ATIVO = '1' "
	cQry+=" AND DA1_PRCVEN > 0 "
	cQry+=" AND DA1.D_E_L_E_T_ = ' ' " 
	cQry+=" Order by DA1_CODTAB, B1_GRUPO, B1_COD " 
	
	If Select("QRP") > 0
		QRP->(dbCloseArea())
	Endif	 	
	APWExOpenQuery(ChangeQuery(cQry),'QRP',.T.)
	 
	//Preenche o select de produtos
	While QRP->(!Eof())
		If Empty(cGrupo) 
		 	cProds+= '<optgroup label="'+Alltrim(StrTran(QRP->BM_DESC,"'",""))+'">
		Elseif !Empty(cGrupo) .and. cGrupo <> QRP->B1_GRUPO
			cProds+= '</optgroup>'
		    cProds+= '<optgroup label="'+Alltrim(StrTran(QRP->BM_DESC,"'",""))+'">		    
		Endif    
		cProds+='	<option value="'+Alltrim(QRP->DA1_CODPRO)+'" '+Iif(Alltrim(QRP->DA1_CODPRO) == AllTrim(cOrcProd), 'selected','')+'>'+Alltrim(QRP->DA1_CODPRO)+' - '+Alltrim(StrTran(QRP->B1_DESC,"'",""))+'</option>'
		
	    cGrupo:= QRP->B1_GRUPO
		QRP->(dbSkip())
    End
    If !Empty(cProds)
    	cProds+= '</optgroup>'
    Endif	
	cHtml:= cProds
    
Return cHtml
