#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
#DEFINE SMSDEBUG
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ ViewNF      ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦03.12.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Visualização das notas fiscais.							  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function ViewNF()
Local cHtml
Local nTFil	:= FWSizeFilial()
Local cItem := ""
Local cTr   := ""
Local cTrHid:= ""
Local nTNum	:= 0
Local nTPro	:= 0
Local nDiasEnt := 0 
Local nPosFrete:= 0
Local lDigitado:= .F.
Local lMoeda	:= .F.
Local lNumber	:= .F.
Local aTpFrete	:= {}
Local aTipoOrc	:= {}

Private cDirPortal 	:= ""
Private cEndServ 	:= "" // Endereço do servidor da pagina de Portal
Private cNFCabec	:= ""
Private cNFItens	:= ""
Private cNFSerie	:= ""
Private cBotoes		:= ""
Private cTpFrete	:= ""
Private cValFre		:= ""
Private cTransp		:= ""
Private cCliente	:= ""
Private cEntrega	:= ""
Private cBtnItens	:= ""
Private cObsNota	:= ""
Private cChaveNF	:= ""
Private cEmissao	:= ""
Private nTVlrUnit	:= 0
Private nTTotal		:= 0
Private nTImpostos	:= 0
Private nTFrete		:= 0
Private nItens		:= 0
				
Private cSite	  := "u_PortalLogin.apw"
Private cPagina	  := "Nota Fiscal"
Private cMenus	  := ""
Private cTitle	  := ""
Private cAnexos	  := ""
Private aItens	  := {}
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
	cSite	:= Procname()+".apw?PR="+cCodLogin
	
	// Monta o cabeçalho para a pagina
	cHeader := U_PSHeader(cTitle, cSite) 	
	
	
	
	//Função que atualiza os menus
	cMenus := U_GetMenus(AllTrim(Upper(Procname())), cVendLogin)
	
	
	
	//Atualiza as variáveis
	cEndServ := GetMv('MV_WFBRWSR')
	cItem := StrZero(1,TamSX3("D2_ITEM")[1])
	nRecSF2 := val(HttpGet->rec)   
	
	
	//Posiciona na Nota Fiscal
	If !Empty(nRecSF2)
		dbSelectArea("SF2")
		SF2->(dbGoTo(nRecSF2))
		
		//Troca de filial
		u_PTChgFil(SF2->F2_FILIAL)
		
		dbSelectArea("SF2")
		SF2->(dbGoTo(nRecSF2))
		
		dbSelectArea("SD2")
		SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE))
	Endif	 
	
	cNFSerie:= SF2->F2_DOC+'/'+SF2->F2_SERIE
	cChaveNF:= SF2->F2_CHVNFE
	cEmissao:= dtoc(SF2->F2_EMISSAO)
		
	//Observações do orçamento
	cObsNota:= SF2->F2_MENNOTA
	
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
	*/			
	aItens := {	{"Produto","D2_COD","300px","left","C",.F.,.T.,.F.,"Selecione..."},;   //				{"UM","D2_UM","70px","right","C",.F.,.F.,.F.,""},;           
				{"Quantidade","D2_QUANT","*","right","N",.F.,.T.,.F.,"0"},;
				{"V.Unitário","D2_PRCVEN","*","","N",.F.,.F.,.T.,"0,00000"},;
				{"IPI","D2_VALIPI","*","right","N",.F.,.F.,.T.,"0,00"},;
				{"ICMS","D2_VALICM","*","right","N",.F.,.F.,.T.,"0,00"},;
				{"ICMS ST","D2_ICMSRET","*","right","N",.F.,.F.,.T.,"0,00"},;
				{"Total","D2_TOTAL","*","right","N",.F.,.F.,.T.,"0,00"}}			
		    
		
	// Cria o cabeçalho dos Itens
	For nLin := 1 to Len(aItens)
		cNFCabec += '<th'+Iif(aItens[nLin,2] == "D2_COD",' width="'+aItens[nLin,3]+'"','')+'>'+aItens[nLin][1]+'</th>'
	Next 
	
	//Tipo de frete
	aTpFrete:= {{"S","Sem Frete"},{"C","CIF"},{"F","FOB"}}
	cTpFrete:='<select class="form-control mb-md" name="F2_TPFRETE" id="F2_TPFRETE" value="'+SF2->F2_TPFRETE+'" disabled>'

	nPosFrete:= aScan(aTpFrete,{|x|x[1]==SF2->F2_TPFRETE})
	If nPosFrete = 0
		nPosFrete:= 1
	Endif	
	cTpFrete+='	<option value="'+SF2->F2_TPFRETE+'">'+aTpFrete[nPosFrete,2]+'</option>'	
	
	cTpFrete+='</select>' 
	
	cValFre:= Transform(SF2->F2_FRETE,"@E 999,999,999.99")
	
	
	//Transportadora
	cTransp:= SF2->F2_TRANSP+' - '+Alltrim(Posicione("SA4",1,xFilial("SA4")+SF2->F2_TRANSP,"A4_NREDUZ"))
		
    //Condição de Pagamento
	cCondPag:='<select class="form-control mb-md" name="F2_COND" id="F2_COND" required="" aria-required="true" disabled>'
	cCondPag+='	<option value="'+SF2->F2_COND+'">'+SF2->F2_COND+" - "+Posicione("SE4",1,xFilial("SE4")+SF2->F2_COND,"E4_DESCRI")+'</option>'		
	cCondPag+='</select>'	                             
	 
	//Cliente
	cCliente:='<select data-plugin-selectTwo class="form-control populate placeholder" data-plugin-options='+"'"
	cCliente+='{ "placeholder": "Selecione um Cliente", "allowClear": false }'+"'"+' name="CJ_CLIENTE" id="CJ_CLIENTE" '
	cCliente+=' disabled >' 
	cCliente+=' <option value='+SF2->F2_CLIENTE+SF2->F2_LOJA+'>'+SF2->F2_CLIENTE+'/'+SF2->F2_LOJA+' - '+Alltrim(Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NOME"))+'</option>'
	cCliente+='</select>'
	

	//Data Prevista de Entrega
	/*
	nDiasEnt:= GetNewPar("AE_DTENT",10)
	cEntrega:='<input type="text" id="CK_ENTREG" name="CK_ENTREG" data-plugin-datepicker data-plugin-options='+"'"+'{ "startDate": "+'+nDiasEnt+'d", "language": "pt-BR",'
	cEntrega+='"daysOfWeekDisabled": "[0]","daysOfWeekHighlighted":"[0]"}'+"'"+' class="form-control only-numbers" placeholder="__/__/____"'
	cEntrega+='value='+DTOC(SCK->CK_ENTREG) 
	cEntrega+=Iif(!lEdit,' disabled','')+'>'
     */
	//Preenchimento dos itens
	nTTotal:=  Sf2->F2_VALFAT 	
	nTFrete:= SF2->F2_FRETE
	dbSelectArea("SD2")
	SD2->(dbSetOrder(3))
	SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE))
	While SD2->(!Eof()) .and. SD2->D2_DOC = SF2->F2_DOC .AND. SD2->D2_SERIE = SF2->F2_SERIE
		nItens++
		Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC")		
		cNFItens += '<tr class="odd" id="linha'+StrZero(nItens,2)+'">'
		
		nTImpostos += SD2->(D2_ICMSRET+D2_VALIPI) //D2_VALICM+
		nTVlrUnit +=  SD2->D2_QUANT * SD2->D2_PRCVEN			
				
		For nLin := 1 to Len(aItens)
			
			cNFItens += '<td'+Iif(!Empty(aItens[nLin][4]),' align="'+aItens[nLin][4]+'"',"")+'>'
			
			lMoeda:= aItens[nLin,8] //Indica se é Moeda  			
			lNumber:= aItens[nLin,5] = "N" //Indica que é numérico  			
			xValue:= ""
			Do Case
				Case aItens[nLin][5] == 'C'
					If aItens[nLin,2] == "D2_COD"
						xValue := AllTrim(SD2->&(aItens[nLin][2]))+Alltrim(SB1->B1_DESC)
					Else
						xValue := AllTrim(SD2->&(aItens[nLin][2]))
					Endif
				Case aItens[nLin][5] == 'N'
					If aItens[nLin,2] == "D2_QUANT"
						xValue := Alltrim(PadR(TransForm(SD2->&(aItens[nLin][2]),"@E 999,999,999"),14))
					Else	
						xValue := Alltrim(PadR(TransForm(SD2->&(aItens[nLin][2]),"@E 999,999,999.99"),14))
					Endif	
			EndCase  
		   
			cNFItens += '<input id="'+aItens[nLin][2]+cItem+'" data-prop="'+aItens[nLin][2]+'" name="'+aItens[nLin][2]+cItem+'" class="form-control input-block" type="text" disabled width="" '
			cNFItens += 'value="'+Alltrim(xValue)+'" title="'+Alltrim(xValue)+'">'
			cNFItens += '</td>' 
		Next	                                                                        
			
		cNFItens += '</tr>'
		SD2->(dbSkip())	
	End	
	
	//Adiciona os botões da página
	cBotoes+='<input class="btn btn-primary" type="button" id="btVoltar" name="btVoltar" value="Voltar" onclick="javascript: location.href='+"'"+'u_notasfiscais.apw?PR='+cCodLogin+"';"+'"/>'+chr(13)+chr(10)
	
	//Retorna o HTML para construção da página 
	cHtml := H_ViewNF()
	
Web Extended End

Return (cHTML) 
