#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
#DEFINE SMSDEBUG
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ AddOrc      ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦28.08.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦            	
¦¦¦Descriçäo ¦ Inclusão de Orçamento de Venda.							  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function AddOrc()
	Local cHtml
	Local nTFil	:= FWSizeFilial()
	Local cItem := ""
	Local cTr   := ""
	Local cTrHid:= ""
	Local nLin	:= 0
	Local a		:= 0
	Local f		:= 0
	Local d		:= 0
	Local nTNum	:= 0
	Local nTPro	:= 0
	Local nDiasEnt := 0
	Local lDigitado:= .F.
	Local lMoeda	:= .F.
	Local lNumber	:= .F.
	Local aTpFrete	:= {}
	Local aTipoOrc	:= {}
	Local aVends		:= {}
	Local lModalBol := .f.
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
	Private cCliente	:= ""
	Private cTabela		:= ""
	Private cTipoOrc	:= ""
	Private cFaixaDesc	:= ""
	Private cEntrega	:= ""
	Private cBtnItens	:= ""
	Private cTblDesc	:= ""
	Private cObsInterna	:= ""
	Private cObsNota	:= ""
	Private cVendedor	:= ""
	Private cImport		:= ""
	Private nQuant		:= 0
	Private nVlrUnit	:= 0
	Private nVlrTotal	:= 0
	Private nVlrIPI		:= 0
	Private nVlrIcms	:= 0
	Private nVlrIST		:= 0
	Private nVlrPis		:= 0
	Private nVlrCofins	:= 0
	Private nFrete		:= 0
	Private nTamContato	:= 0
	Private nItens		:= 0
	Private nTVlrUnit	:= 0
	Private nTQtdItem   := 0
	Private nTTotal		:= 0
	Private nTAcresc	:= 0
	Private nTComiss	:= 0
	Private nTSaldo		:= 0
	Private nTImpostos	:= 0
	Private nTFrete		:= 0
	Private aAnexos 	:= {}
	Private lNewOrc		:= .T.
	Private lEdit		:= .T.
	Private lEstoque	:= .F.
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

	cCodOrc :=	'<input type="hidden" id="CJ_VEND" name="CJ_VEND" value="'+cVendLogin+'">'

	//Função que atualiza os menus
	cMenus := U_GetMenus(AllTrim(Upper(Procname())), cVendLogin)



	//Atualiza as variáveis
	cEndServ := GetMv('MV_WFBRWSR')
	//	cCodVend := HttpSession->CodVend
	cCodVend:=cVendLogin
	cNomeVend:= HttpSession->Nome
	cItem := StrZero(1,TamSX3("CK_ITEM")[1])

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
	[10] - Hidden
	[11] - MaxLength
	*/			
	aItens := {	{"Item","CK_ITEM","*","text-left","C",.F.,.F.,.F.,"",.F.,""},;
		{"Produto","CK_PRODUTO","300px","text-left","C",.T.,.T.,.F.,"Selecione...",.F.,""},;
		{"UM","CK_UM","70px","text-right","C",.F.,.F.,.F.,"",.T.,""},;
		{"Quantidade","CK_QTDVEN","*","text-right","N",.T.,.T.,.F.,"0",.F.,""},;
		{"Vlr de Tabela","CK_PRCVEN","*","text-right","N",.F.,.F.,.T.,"0,00",.F.,""},;
		{"Vlr c/ Impostos","CK_XPRCIMP","*","text-right","N",.F.,.F.,.T.,"0,00",.T.,""},;
		{"Vlr de Venda","iCK_PRCVEN","*","text-right myformato","N",.T.,.F.,.T.,"0,00",.F.,""},;  //"0,00000"
		{"Desconto","CK_XFAIXAD","*","text-right","C",.F.,.F.,.F.,"",.T.,""},;
		{"IPI","CK_XVALIPI","*","text-right","N",.F.,.F.,.T.,"0,00",.T.,""},;
		{"ICMS","CK_XVALICM","*","text-right","N",.F.,.F.,.T.,"0,00",.T.,""},;
		{"ICMS ST","CK_XICMST","*","text-right","N",.F.,.F.,.T.,"0,00",.T.,""},;
		{"% Desconto","CK_DESCONT","*","text-right percentual","N",.T.,.F.,.T.,"0,00",.F.,"7"},;
		{"% Desconto 1","CK_XDESC01","*","text-right percentual","N",.T.,.F.,.T.,"0,00",.T.,"7"},;
		{"% Desconto 2","CK_XDESC02","*","text-right percentual","N",.T.,.F.,.T.,"0,00",.T.,"7"},;
		{"% Desconto 3","CK_XDESC03","*","text-right percentual","N",.T.,.F.,.T.,"0,00",.T.,"7"},;
		{"% Comissão","PER_COM","*","text-right","N",.F.,.F.,.T.,"0,00",.T.,""},;
		{"Vlr Comissão","VAL_COM","*","text-right","N",.F.,.F.,.T.,"0,00",.T.,""},;
		{"Pedido","CK_XPEDCLI","*","text-right","C",.T.,.F.,.F.,"",.F.,""},;
		{"Item","CK_XITEMCL","*","text-right","C",.T.,.F.,.F.,"",.F.,""},;
		{"Total","CK_VALOR","150px","text-right","N",.F.,.F.,.T.,"0,00",.F.,""},;
		{"","ACAO","*","text-center","X",.F.,.F.,.F.,"",.F.,""}}

// Cria o cabeçalho dos Itens
	For nLin := 1 to Len(aItens)

		cOrcCabec += '<th'+Iif(aItens[nLin,2] == "CK_VALOR",' width="'+aItens[nLin,3]+'"',Iif(aItens[nLin,2] == "CK_PRODUTO",' width="'+aItens[nLin,3]+'"',''))
		cOrcCabec+= Iif(aItens[nLin,10],' hidden','')+'>'+aItens[nLin][1]+'</th>'
//		cOrcCabec+= Iif(aItens[nLin,10],' hidden',Iif(Left(aItens[nLin,2],8) = 'CK_XDESC',' style="display: none;"',''))+'>'+aItens[nLin][1]+'</th>'
	Next

//Tipo do Orçamento
	aTipoOrc:= {{"1","Firme"},{"2","Previsto"}} //,{"3","Em elaboração"}
	cTipoOrc:='<select data-plugin-selectTwo class="form-control populate mb-md" data-plugin-options='+"'"+'{"minimumResultsForSearch": "-1"}'+"'"+''
	cTipoOrc+=' name="CJ_XTPORC" id="CJ_XTPORC" required="" aria-required="true">'
	For a:= 1 to Len(aTipoOrc)
		cTipoOrc+='	<option value="'+aTipoOrc[a,1]+'">'+aTipoOrc[a,2]+'</option>'
	Next
	cTipoOrc+='</select>'

//Tipo de frete
	aTpFrete:= {{"S","Sem Frete"},{"C","CIF"},{"F","FOB"},{"R","Retira"}}
	cTpFrete:='<select data-plugin-selectTwo class="form-control poulate mb-md" data-plugin-options='+"'"+'{"minimumResultsForSearch": "-1"}'+"'"'
	cTpFrete+=' name="CJ_TPFRETE" id="CJ_TPFRETE" onchange="javascript:VldFrete()">'
	For f:= 1 to Len(aTpFrete)
		cTpFrete+='	<option value="'+aTpFrete[f,1]+'">'+aTpFrete[f,2]+'</option>'
	Next
	cTpFrete+='</select>'

//Transportadora
//Seleciona as transportadoras disponíveis no combo
	/*
	cQry:= " Select A4_COD COD, A4_NREDUZ NOME"
	cQry+= " From "+RetSqlName("SA4")+" SA4 "
	cQry+= " Where SA4.D_E_L_E_T_ = ' ' " //A4_FILIAL = '"+xFilial("SA4")+"' " -- problema no compartilhamento da tabela

	If Select("QRT")> 0
		QRT->(dbCloseArea())
	Endif	 	
	APWExOpenQuery(ChangeQuery(cQry),'QRT',.T.)
		*/
	cTransp:='<select data-plugin-selectTwo class="form-control populate placeholder mb-md" data-plugin-options='+"'" '
	cTransp+='{ "placeholder": "Selecione uma Transportadora", "allowClear": false }'+"'"+' name="CJ_XTRANSP" id="CJ_XTRANSP" '
	cTransp+='required="" aria-required="true" disabled>'
	cTransp+='	<option value=""></option>'

	/*
	
	While QRT->(!Eof())
		cTransp+='	<option value="'+Alltrim(QRT->COD)+'">'+Alltrim(QRT->COD)+" - "+Alltrim(QRT->NOME)+'</option>'
		QRT->(dbSkip())
	End
	*/	
	cTransp+='</select>'


//Faixas de Desconto
	aAdd(aFaixaDesc, {"0","   ","0"}) // Sem desconto.

	cFaixaDesc:='<select class="form-control populate mb-md" data-prop="CK_XFAIXAD" '
	cFaixaDesc+=' name="CK_XFAIXAD'+cItem+'" id="CK_XFAIXAD'+cItem+'" disabled onchange="javascript:VldFaixa('+"'"+cItem+"'"+')">'
	For d:= 1 to Len(aFaixaDesc)
		cFaixaDesc+='	<option value="'+aFaixaDesc[d,1]+'">'+aFaixaDesc[d,2]+'</option>'
		cTblDesc += 'tblDesc.push({"op" :"'+aFaixaDesc[d,1]+'", "descricao" : "'+aFaixaDesc[d,2]+'","pcom" : '+cValToChar(aFaixaDesc[d,3])+'});'+CRLF
	Next
	cFaixaDesc+='</select>'


//Seleciona as modalidades
	cQry:= " Select X5_CHAVE, X5_DESCRI"
	cQry+= " From "+RetSqlName("SX5")+" SX5 "
	cQry+= " Where X5_TABELA = 'ZE' "
	cQry+= " And X5_CHAVE IN ('001','002') "
	cQry+= " And SX5.D_E_L_E_T_ = ' ' "
	If Select("QRM") > 0
		QRM->(dbCloseArea())
	Endif
	APWExOpenQuery(ChangeQuery(cQry),'QRM',.T.)

	cModali:= '<select data-plugin-selectTwo class="form-control populate mb-md" name="CJ_XMODALI" id="CJ_XMODALI" required="" aria-required="true" '
	cModali+= 'onchange="javascript:condPag()">'
	if QRM->(!Eof())
		lModalBol := (Alltrim(QRM->X5_CHAVE) == "001")
	Endif
	While QRM->(!Eof())
		cModali+='	<option value="'+Alltrim(QRM->X5_CHAVE)+'">'+Alltrim(QRM->X5_DESCRI)+'</option>'
		QRM->(dbSkip())
	End
	cModali+='</select>'


//Seleciona as condições de pagamento disponíveis no combo
	cQry:= " Select E4_CODIGO, E4_DESCRI"
	cQry+= " From "+RetSqlName("SE4")+" SE4 "
	cQry+= " Where E4_FILIAL = '"+xFilial("SE4")+"' "
	cQry+= " And E4_XPORTAL = '1' "
	cQry+= " And E4_MSBLQL <> '1' "
	cQry+= " And SE4.D_E_L_E_T_ = ' ' "

	If Select("QRC")> 0
		QRC->(dbCloseArea())
	Endif
	APWExOpenQuery(ChangeQuery(cQry),'QRC',.T.)

	cCondPag:='<select data-plugin-selectTwo class="form-control populate placeholder mb-md" data-plugin-options='+"'" '
	cCondPag+='{ "placeholder": "Selecione...", "allowClear": false }'+"'"+' name="CJ_CONDPAG" id="CJ_CONDPAG" '
	cCondPag+='required="" aria-required="true" onchange="javascript:vldDescto(),vldAcresc()" >' 
	cCondPag+='	<option value=""></option>'
	While QRC->(!Eof())
		cCondPag+='	<option value="'+Alltrim(QRC->E4_CODIGO)+'">'+Alltrim(QRC->E4_CODIGO)+" - "+Alltrim(QRC->E4_DESCRI)+'</option>'
		QRC->(dbSkip())
	End
	cCondPag+='</select>'


//Select das operadoras
	cOperadora:= '<select data-plugin-selectTwo class="form-control populate placeholder mb-md" data-plugin-options='+"'" '
	cOperadora+= '{ "placeholder": "Selecione...", "allowClear": false }'+"'"+' name="OPERADORA" id="OPERADORA" '
	cOperadora+= 'required="" aria-required="true" onchange="javascript:bandeira()" disabled> '
	cOperadora+= '	<option value=""></option>'
	cOperadora+= '</select>'

//Select da bandeira
	cBandeira:= '<select data-plugin-selectTwo class="form-control populate placeholder mb-md" data-plugin-options='+"'" '
	cBandeira+= '{ "placeholder": "Selecione...", "allowClear": false }'+"'"+' name="BANDEIRA" id="BANDEIRA" '
	cBandeira+= 'required="" aria-required="true" disabled> '
	cBandeira+= '	<option value=""></option>'
	cBandeira+= '</select>'


// Localiza os clientes deste vendedor
	cQuery := " Select A1_COD, A1_LOJA, A1_CGC, A1_NOME, A1_BAIRRO, A1_END, A1_MUN, A1_EST, A1_DDD, A1_TEL, A1_COND "
	cQuery += " From "+RetSqlName("SA1")+" SA1 "
	cQuery += " Where A1_FILIAL = '"+xFilial("SA1")+"' "
	If HttpSession->Tipo = 'S' //Supervisor acessa todos os clientes da sua equipe
		cQuery+= " AND A1_VEND in "+FormatIn(HttpSession->Equipe,"|")+" "
	Else
		cQuery+= " AND A1_VEND = '"+cCodVend+"'" // OR A1_VEND2 = '"+cCodVend+"'  OR A1_VEND3= '"+cCodVend+"' OR A1_VEND4= '"+cCodVend+"' OR A1_VEND5 = '"+cCodVend+"' ) "
	Endif
	cQuery += " And A1_MSBLQL <> '1' "
	cQuery += " And SA1.D_E_L_E_T_ = ' ' "
	cQuery += " Order by A1_NOME "

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	Endif
	APWExOpenQuery(ChangeQuery(cQuery),'QRY',.T.)


	dbSelectArea("QRY")
	cCliente:='<select data-plugin-selectTwo class="form-control populate placeholder" data-plugin-options='+"'"
	cCliente+='{ "placeholder": "Selecione um Cliente", "allowClear": false }'+"'"+' name="CJ_CLIENTE" id="CJ_CLIENTE" '
	cCliente+='onchange="javascript:SelCliente()" required="" aria-required="true"> '
	cCliente+=' <option value=""> </option>'
	While !QRY->(EOF())

		cCliente+='	<option value="'+Alltrim(QRY->A1_COD+QRY->A1_LOJA)+'">'+QRY->A1_COD+'/'+QRY->A1_LOJA+' - '+Alltrim(QRY->A1_NOME)+'</option>'
		QRY->(dbSkip())
	End
	cCliente+='</select>'

	APWExCloseQuery('QRY')


//Combo da tabela de preço
	cTabela:='<select data-plugin-selectTwo class="form-control populate placeholder" data-plugin-options='+"'"
	cTabela+='{ "placeholder": "Selecione...", "allowClear": false }'+"'"+' name="CJ_TABELA" id="CJ_TABELA" '
	cTabela+='onchange="javascript:selProd(),tpTabela(),tabCartao()">'
	cTabela+='	<option value=""> </option>'
	cTabela+='</select>'

//Data Prevista de Entrega
	nDiasEnt:= GetNewPar("AA_DTENT",'0')
	cEntrega:='<input type="text" id="CK_ENTREG" name="CK_ENTREG" data-plugin-datepicker data-plugin-options='+"'"+'{ "startDate": "+'+nDiasEnt+'d", "language": "pt-BR",'
	cEntrega+='"daysOfWeekDisabled": "[0]","daysOfWeekHighlighted":"[0]","autoclose": "true"}'+"'"+' class="form-control only-numbers" placeholder="__/__/____" '
	cEntrega+='value="'+dtoc(date()+val(nDiasEnt))+'">'


//Supervisor habilita o campo de vendedores
	/*
	If HttpSession->Tipo = 'S'
		cVendedor+= '<div class="row form-group">'
		cVendedor+= '	<div class="col-lg-6">'
		cVendedor+= '		<label class="control-label">Representante</label>'
	 	cVendedor+= '		<select data-plugin-selectTwo class="form-control populate placeholder" data-plugin-options='+"'"
		cVendedor+= '{ "placeholder": "Selecione um Representante", "allowClear": false }'+"'"+' name="CJ_VEND" id="CJ_VEND" '
		//cVendedor+='onchange="javascript:SelCliente()" '
		cVendedor+= 'required="" aria-required="true"> '
		cVendedor+= '			<option value=""> </option>'
		
		aVends:= Separa(HttpSession->Representantes,"|")
		For v:= 1 to Len(aVends)
			cVendedor+='		<option value="'+Alltrim(Substr(aVends[v],1,At("-",aVends[v])-1))+'">'+aVends[v]+'</option>'
		Next
		
		cVendedor+= '		</select'													
		cVendedor+= '	</div>'													
		cVendedor+= '</div>'
		       
	Endif
	*/

//Preenchimento dos itens
	nItens++
	cOrcItens += '<tr class="odd" id="linha01">'
	For nLin := 1 to Len(aItens)

		If aItens[nLin,2] == "ACAO"
			cOrcItens += '<td class="actions">'
			cOrcItens += '	<i class="fa fa-info fa-lg" data-toggle="tooltip" data-original-title="Detalhes da linha" onclick="detalheOrc('+"'"+cItem+"'"+');"></i>'
			cOrcItens += '  <i class="fa fa-times-circle fa-lg" data-toggle="tooltip" data-original-title="Remover a linha" onclick="removeItem('+"'"+cItem+"'"+');"></i>
			cOrcItens += '</td>
		Elseif aItens[nLin,2] == "CK_XFAIXAD"
			cOrcItens += '<td'+Iif(aItens[nLin,10],' hidden','')+'>'
			cOrcItens += cFaixaDesc
			cOrcItens += '</td>'
		Else
			cOrcItens += '<td'+Iif(aItens[nLin,10],' hidden','')+'>'

			lMoeda:= aItens[nLin,8] //Indica se é Moeda
			lNumber:= aItens[nLin,5] = "N" //Indica que é numérico
			xValue:= ""
			Do Case
			Case aItens[nLin][5] == 'C'
				If aItens[nLin,2] == "CK_ITEM"
					xValue := "01"
				Else
					xValue := Iif(lNewOrc,space(TamSX3(aItens[nLin][2])[1]),AllTrim(QRY->&(aItens[nLin][2])))
				Endif
			Case aItens[nLin][5] == 'N'
				If aItens[nLin,2] == "CK_QTDVEN"
					xValue := Iif(lNewOrc,"",Alltrim(PadR(TransForm(QRY->&(aItens[nLin][2]),PesqPict("SCK",aItens[nLin,2])),TamSX3(aItens[nLin][2]))))
				ElseIf aItens[nLin,2] == "PER_COM"
					xValue := Iif(lNewOrc,"",Alltrim(PadR(TransForm(QRY->&(aItens[nLin][2]),PesqPict("SD2","D2_COMIS1")),TamSX3("D2_COMIS1"))))
				ElseIf aItens[nLin,2] == "VAL_COM"
					xValue := Iif(lNewOrc,"",Alltrim(PadR(TransForm(QRY->&(aItens[nLin][2]),PesqPict("SCK","CK_PRCVEN")),TamSX3("CK_PRCVEN"))))
				Elseif aItens[nLin,2] == "iCK_PRCVEN"
					xValue := Iif(lNewOrc,"",Alltrim(PadR(TransForm(QRY->&(aItens[nLin][2]),PesqPict("SCK","CK_XICMST")),TamSX3("CK_PRCVEN"))))
				Else
					xValue := Iif(lNewOrc,"",Alltrim(PadR(TransForm(QRY->&(aItens[nLin][2]),PesqPict("SCK",aItens[nLin,2])),TamSX3(aItens[nLin][2]))))
				Endif
			EndCase

			If aItens[nLin,6] //Campo Editável
				If aItens[nLin,2] == "CK_PRODUTO"
					//Cria o select para o produto
					cOrcItens +='<select class="selectpicker" name="CK_PRODUTO'+cItem+'" id="CK_PRODUTO'+cItem+'" '
					cOrcItens += Iif(aItens[nLin][7],'required="" aria-required="true" ','')+' data-live-search="true" '
					cOrcItens +='onchange="javascript:gatProduto($(this))" data-width="290px" value="">' //style="size:4" data-width="90%" style="height:90%"
					cOrcItens +='	<option value="">Selecione...</option>'
					cOrcItens+='</select>'
				Else
					cOrcItens += '<input id="'+aItens[nLin][2]+cItem+'" data-prop="'+aItens[nLin][2]+'" name="'+aItens[nLin][2]+cItem+'" class="form-control '+aItens[nLin,4]
					cOrcItens +=If(lMoeda," ",If(lNumber," only-numbers",""))+'" type="text" '
//					cOrcItens +=If(lMoeda," money5",If(lNumber," only-numbers",""))+'" type="text" '
					cOrcItens += 'placeholder="'+aItens[nLin,9]+'" '
					//Atribui as funções javascript
					If aItens[nLin,2] == "CK_QTDVEN"
						cOrcItens+='onblur="javascript:VldQtd('+"'"+cItem+"'"+') "'
					Endif
					If aItens[nLin,2] == "iCK_PRCVEN"
						cOrcItens+='onblur="javascript:VldValor('+"'"+cItem+"'"+') "'
					Endif

					If aItens[nLin,2] == "CK_DESCONT"
						cOrcItens+='onblur="javascript:VldValor('+"'"+cItem+"'"+')" maxlength="7" '
						//cOrcItens+='onkeyup="formate()" onblur="javascript:VldValor('+"'"+cItem+"'"+') "'
					Endif

					If aItens[nLin,2] $ ("CK_XDESC01|CK_XDESC02|CK_XDESC03")
						cOrcItens+='onblur="javascript:vldDesc('+"'"+cItem+"'"+')" '
						//cOrcItens+='onkeyup="javascript:TotalItem('+"'"+cItem+"'"+') "'
					Endif


					If aItens[nLin,2] == "CK_XPEDCLI"
						cOrcItens+='maxlength="6" '
					Endif

					If aItens[nLin,2] == "CK_XITEMCL"
						cOrcItens+='maxlength="3" '
					Endif

					If aItens[nLin,2] $ ("CK_QTDVEN|iCK_PRCVEN|CK_DESCONT")
						cOrcItens+='onkeyup="javascript:TotalItem('+"'"+cItem+"'"+') "'
					Endif
					//Campo obrigatório
					cOrcItens += Iif(aItens[nLin][7],'required="" aria-required="true" ','')
					//Inicia todos os campos desabilitados
					cOrcItens += 'disabled '
					cOrcItens += 'value="'+Alltrim(xValue)+'">'
				Endif


			Else
				cOrcItens += '<input id="'+aItens[nLin][2]+cItem+'" data-prop="'+aItens[nLin][2]+'" name="'+aItens[nLin][2]+cItem+'" class="form-control '+aItens[nLin,4]+' input-block" '
				If aItens[nLin,2] = "CK_ITIEM"
					cOrcItens += ' size=4 '
				Endif
				cOrcItens += ' type="text" disabled value="'+Alltrim(xValue)+'">'
			Endif
		Endif

		cOrcItens += '</td>'
	Next

//Inputs Hidden
	cItensHid += '<input type="hidden" class="" name="VAL_DESC'+cItem+'" id="VAL_DESC'+cItem+'" value="0" />'
	cItensHid += '<input type="hidden" class="" id="ALIQ_ICMS'+cItem+'" name="ALIQ_ICMS'+cItem+'" value="0">'
	cItensHid += '<input type="hidden" class="" id="ALIQ_IPI'+cItem+'" name="ALIQ_IPI'+cItem+'" value="0">'
	cItensHid += '<input type="hidden" class="" id="ALIQ_ST'+cItem+'" name="ALIQ_ST'+cItem+'" value="0">'
	cItensHid += '<input type="hidden" class="" id="VAL_ICMS'+cItem+'" name="VAL_ICMS'+cItem+'" value="0">'
	cItensHid += '<input type="hidden" class="" id="VAL_IPI'+cItem+'" name="VAL_IPI'+cItem+'" value="0">'
	cItensHid += '<input type="hidden" class="" id="VAL_ST'+cItem+'" name="VAL_ST'+cItem+'" value="0">'
	cItensHid += '<input type="hidden" class="" id="BASE_ICMS'+cItem+'" name="BASE_ICMS'+cItem+'" value="0">'
	cItensHid += '<input type="hidden" class="" id="BASE_ST'+cItem+'" name="BASE_ST'+cItem+'" value="0">'
	cItensHid += '<input type="hidden" class="" id="BASE_IPI'+cItem+'" name="BASE_IPI'+cItem+'" value="0">'
	cItensHid += '<input type="hidden" class="" id="QTD_EMB'+cItem+'" name="QTD_EMB'+cItem+'" value="0">'
	cItensHid += '<input type="hidden" class="" id="CK_TES'+cItem+'" name="CK_TES'+cItem+'" value="">'
	cItensHid += '<input type="hidden" class="" id="PNEU'+cItem+'" name="PNEU'+cItem+'" value="">'
	cItensHid += '<input type="hidden" class="" id="MARCA'+cItem+'" name="MARCA'+cItem+'" value="">'
	cItensHid += '<input type="hidden" class="" id="GRUPO'+cItem+'" name="GRUPO'+cItem+'" value="">'
	cItensHid += '<input type="hidden" class="" id="PERDESC1'+cItem+'" name="PERDESC1'+cItem+'" value="">'
	cItensHid += '<input type="hidden" class="" id="PERDESC2'+cItem+'" name="PERDESC2'+cItem+'" value="">'
	cItensHid += '<input type="hidden" class="" id="PERDESC3'+cItem+'" name="PERDESC3'+cItem+'" value="">'
	cItensHid += '<input type="hidden" class="" id="GERASALDO'+cItem+'" name="GERASALDO'+cItem+'" value="">'
	cItensHid += '<input type="hidden" class="" id="ULTRAPASSA'+cItem+'" name="ULTRAPASSA'+cItem+'" value="">'
	cItensHid += '<input type="hidden" class="" id="QTDMIN'+cItem+'" name="QTDMIN'+cItem+'" value="">'
	cItensHid += '<input type="hidden" class="" id="SALDO'+cItem+'" name="SALDO'+cItem+'" value="0">'
	cOrcItens += '<input type="hidden" name="DESC_MAX" id="DESC_MAX" value="" />'
	cOrcItens += '<input type="hidden" id="PRODUTOS" name="PRODUTOS" value=""/>
	cOrcItens += '<input type="hidden" id="CJ_FRETE" name="CJ_FRETE" value="0"/>

	cOrcItens+=cItensHid
	cOrcItens += '</tr>'

	cOrcItens += '<input type="hidden" name="QtdItens" id="QtdItens" value="'+cValtoChar(nItens)+'"/>'
	cOrcItens += '<input type="hidden" id="PROXIMO" name="PROXIMO" value="01"/>
	cOrcItens += '<input type="hidden" name="CJ_NUM" id="CJ_NUM" value="" />'
	cOrcItens += '<input type="hidden" name="OPCAO" id="OPCAO" value="3" />'
	cOrcItens += '<input type="hidden" name="DESCVISTA" id="DESCVISTA" value=0 />'
	cOrcItens += '<input type="hidden" name="DESCRETIR" id="DESCRETIR" value=0 />'
	cOrcItens += '<input type="hidden" name="ACRESCIMO" id="ACRESCIMO" value=0 />'
	cOrcItens += '<input type="hidden" name="VALMIN_COND" id="VALMIN_COND" value=0 />'
	cOrcItens += '<input type="hidden" name="JUROS_COND" id="JUROS_COND" value=0 />'
	cOrcItens += '<input type="hidden" name="GRUPOS" id="GRUPOS" value="" />'
	cOrcItens += '<input type="hidden" name="POLIMENTO" id="POLIMENTO" value="1" />'
	cOrcItens += '<input type="hidden" name="CONDANT" id="CONDANT" value="" />'

	nPercVend:= GetNewPar("RB_SLDVEND",50)
	cPercDir:= cvaltochar((100 - nPercVend) /100)
	cOrcItens += '<input type="hidden" name="PERCDIR" id="PERCDIR" value='+cPercDir+' />'
	cOrcItens += '<input type="hidden" name="PERCVEND" id="PERCVEND" value='+cValtochar(nPercVend/100)+' />'

//Adiciona os botões de ações na tabela de itens
	cBtnItens+='<div class="row form-group">'
	cBtnItens+='	<div class="col-sm-2">'
	cBtnItens+='		<button class="btn btn-primary" id="btAddItm" name="btAddItm">' //onclick="javascript:newItem()" >'
	cBtnItens+='			<i class="fa fa-plus-square"></i> Novo Item</button>'
	cBtnItens+='	</div>'
	cBtnItens+='</div>'


//Adiciona os botões da página
	cBotoes+='<h5 class="text-primary">Orçamento válido apenas dentro do mês de '+MesExtenso(date())+' de '+cvaltochar(Year(date()))+'.</h5>'
	cBotoes+='<input class="btn btn-primary" type="button" id="btSalvar" name="btSalvar" value="Salvar"/>'+chr(13)+chr(10)
	cBotoes+='<input class="btn btn-primary" type="button" id="btVoltar" name="btVoltar" value="Voltar" onclick="javascript: location.href='+"'"+'u_orcamento.apw?PR='+cCodLogin+"';"+'"/>'+chr(13)+chr(10)

//Retorna o HTML para construção da página
	cHtml := H_AddOrc()

	Web Extended End

Return (cHTML)



/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ SlvOrc      ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦17.08.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Gera a cotação.											  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function SlvOrc()
	Local cHtml
	Local nOpc		:= 3 // 3- Incluir / 4- Alterar / 5- Excluir
	Local cCondPag	:= ""
	Local cTabela	:= ""
	Local cCliente	:= ""
	Local cLoja		:= ""
	Local cMsg		:= ""
	Local cTransp	:= ""
	Local cMetodoP	:= ""
	Local cModalidade:= ""
	Local cImport	:= ""
	Local cItens	:= ""
	Local cLinha	:= ""
	Local cDestOrc	:= ""
	Local cMsgIn	:= ""
	Local nI		:= 0
	Local x			:= 0
	Local i			:= 0
	Local nTotSck	:= 0
	Local nItem		:= 0
	Local nPosLin	:= 0
	Local nDesc1	:= 0
	Local nSaldo	:= 0
	Local nSldItm	:= 0
	Local nAcrFin	:= 0
	Local nAcresc	:= 0
	Local cDirOrc 	:= "anexosPortal\orcamento\"
	Local cDirErro  := "erro\"
	Local aItens	:= {}
	Local cNumSCJ	:= ""
	Local cFilImp 	:= ""
	Local lRet		:= .T.
	Local lPneu		:= .T.
	Local cSaveVend
	local oObjLog := LogSMS():new()
	local lEnvEmail := .f.
	Private cReturn
	Private aCabSCJ :={}
	Private aItemSCJ:={}
	Private aLinhaSCJ:={}
	Private lMsErroAuto:= .F.
	Private cCodLogin := ""
	Private cVendLogin:= ""

	Web Extended Init cHtml Start U_inSite()

	//#IFDEF SMSDEBUG
	//oObjLog:setFileName("\temp\AddOrc_SlvOrc.txt")
	//conOut(Procname()+"("+ltrim(str(procline()))+") *** Portal ")
	//oObjLog:saveMsg(Procname()+"("+ltrim(str(procline()))+") *** Portal ")
	//   if !empty(HTTPHEADIN->REMOTE_ADDR)
	//     oObjLog:saveMsg('HTTPHEADIN REMOTE_ADDR -> '+HTTPHEADIN->REMOTE_ADDR)
	//   endif
	//   if !empty(HTTPHEADIN->REMOTE_PORT)
	//     oObjLog:saveMsg('HTTPHEADIN REMOTE_PORT -> '+cValToChar(HTTPHEADIN->REMOTE_PORT))
	//   endif
	//   if !empty(HTTPCOOKIES->SESSIONID)
	//     oObjLog:saveMsg('HTTPCOOKIES SESSIONID -> '+HTTPCOOKIES->SESSIONID)
	//   endif
	//   if !empty(HttpSession->SESSIONID)
	//     oObjLog:saveMsg('SESSION SESSIONID -> '+HttpSession->SESSIONID)
	//   endif
	//   aInfo := HttpGet->aGets
	//   For nI := 1 to len(aInfo)
	//    conout('GET '+str(nI,3)+' = '+aInfo[nI]+' -> '+&("HTTPGET->"+aInfo[nI]))
	//     oObjLog:saveMsg('GET '+str(nI,3)+' = '+aInfo[nI]+' -> '+&("HTTPGET->"+aInfo[nI]))
	//   Next
	//   aInfo := HttpPost->aPost
	//   For nI := 1 to len(aInfo)
	//    conout('POST '+str(nI,3)+' = '+aInfo[nI]+' -> '+&("HTTPPOST->"+aInfo[nI]))
	//     oObjLog:saveMsg('POST '+str(nI,3)+' = '+aInfo[nI]+' -> '+&("HTTPPOST->"+aInfo[nI]))
	//   Next
	//   if !empty(HttpSession->Tipo)
	//    conout('SESSION = Tipo -> '+HttpSession->Tipo)
	//     oObjLog:saveMsg('SESSION = Tipo -> '+HttpSession->Tipo)
	//   endif
	//   If !empty(HttpSession->Superv)
	//    conout('SESSION = Superv -> '+HttpSession->Superv)
	//     oObjLog:saveMsg('SESSION = Superv -> '+HttpSession->Superv)
	//   endif
	//   if !empty(HttpSession->CodVend)
	//    conout('SESSION = CodVend -> '+HttpSession->CodVend)
	//     oObjLog:saveMsg('SESSION = CodVend -> '+HttpSession->CodVend)
	//   endif
	// #ENDIF

	cVendLogin := u_GetUsrPR()
	cCodLogin  := U_SetParPR(cVendLogin)

	//Verifica se não perdeu a sessão
		If type("HttpSession->CodVend") = "U" .or. Empty(HttpSession->CodVend)
		conout(Procname()+"("+ltrim(str(procline()))+") *** Portal "+"Sessao encerrada")
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_SMSPortal.apw">'
		return cHtml
	Endif

	//Verifica se existe pedido lançado para o cliente nos últimos 50 segundos.
    
	If Empty(HttpPost->CJ_NUM)
	    cQry:= "Select * from "+RetSqlName("SCJ")+" SCJ "
	    cQry+= "Where CJ_FILIAL = '"+xFilial("SCJ")+"' "
	    cQry+= "And CJ_CLIENTE = '"+Left(HttpPost->CJ_CLIENTE,9)+"' "
	    cQry+= "And CJ_LOJA = '"+Right(HttpPost->CJ_CLIENTE,4)+"' "
	    cQry+= "And CJ_EMISSAO = '"+dtos(dDataBase)+"' "
	    cQry+= "And CJ_COTCLI >= '"+StrTran(StrZero(SubHoras(Time(),'00:00:50'),5,2),'.',':')+":00"+"' "  
	    cQry+= "And SCJ.D_E_L_E_T_ = ' ' "
	    If Select("QRH") > 0
			QRH->(dbCloseArea())
		Endif	 	
		conout("Hora: "+Time()+" Vend: "+HttpSession->CodVend+" --> "+cqry)
		APWExOpenQuery(ChangeQuery(cQry),'QRH',.T.)
		If Contar("QRH","!Eof()") > 0
			cHtml:= ""
			Return cHtml
		Endif
    Endif
	
//Variáveis do cabeçalho
	cFilImp 	:= GetNewPar("AA_FILIMP","010101")
	cCondPag:= HttpPost->CJ_CONDPAG
	cTabela:= HttpPost->CJ_TABELA
	nDesc1:= Val(HttpPost->CJ_DESC1)
	nDesc2:= iif(!empty(HttpPost->CJ_DESC2), Val(HttpPost->CJ_DESC2), 0)
	nTotSck := val(HttpPost->PROXIMO)
	cCliente:= Left(HttpPost->CJ_CLIENTE,6)
	cLoja:= Right(HttpPost->CJ_CLIENTE,6)
	cTransp:= Iif(Type("HttpPost->CJ_XTRANSP") <> "U",HttpPost->CJ_XTRANSP,"")
	dDtEntreg := CTOD(HttpPost->CK_ENTREG)
	If HttpPost->CJ_TPFRETE = "R" //Retira
		cTipoFrete:= "S"
		cTransp:= GetNewPar("AA_TRARET", "000414") //Transportadora padrão para retira
	Else
		cTipoFrete := HttpPost->CJ_TPFRETE
	Endif

	nFrete:= Val(StrTran(StrTran(HttpPost->CJ_FRETE,'.',''),',','.'))
	cTpOrc:= HttpPost->CJ_XTPORC
	cMetodoP:= Iif(Type("HttpPost->CJ_XCODPAG") <> "U",HttpPost->CJ_XCODPAG,"")
	cCliOper:= Iif(Type("HttpPost->CJ_CLIOPER") <> "U",HttpPost->CJ_CLIOPER,"")
	cModalidade:= HttpPost->CJ_XMODALI
	cImport:= HttpPost->CJ_XIMPORT
	cNumSCJ := HttpPost->CJ_NUM
	nSaldo:= Val(StrTran(StrTran(HttpPost->CJ_XSALDO,'.',''),',','.'))
	nAcrFin:= Val(StrTran(StrTran(HttpPost->CJ_XACRESC,'.',''),',','.')) 
	cItens:= HttpPost->aItens
	nOpc:= Val(HttpPost->OPCAO)

//Adiciona observação quando o orçamento é gerado pelo supervisor
	If !Empty(HttpSession->Superv) .and. HttpSession->Superv <> HttpSession->CodVend
		cMsgIn:= " ORÇAMENTO GERADO PELO SUPERVISOR "+Alltrim(HttpSession->Superv)+"."
	Endif



	For x:= 1 to nTotSck
		nPosLin:= At("||",cItens)-1
		If nPosLin > 0
			aLinha:= Separa(Substr(cItens,1,nPosLin),";")
			cItens:= Substr(cItens,nPosLin+3)
			If Len(aLinha) > 0
				aAdd(aItens,aLinha)
			Endif
		Endif
		aLinha:= {}
	Next

//Posiciona nas tabelas
	If !Empty(cCondPag)
		Posicione("SE4",1,xFilial("SE4")+cCondPag,"E4_COND")
	Endif
	If !Empty(cTabela)
		Posicione("DA0",1,xFilial("DA0")+cTabela,"DA0_CODTAB")
		//lPneu := Iif(DA0->DA0_XPOLIM = '1', .F.,.T.)
	Endif
	If !Empty(cCliente)
		Posicione("SA1",1,xFilial("SA1")+Alltrim(HttpPost->CJ_CLIENTE),"A1_COD")
	Endif
	If !Empty(cTransp)
		Posicione("SA4",1,xFilial("SA1")+Alltrim(HttpPost->CJ_XTRANSP),"A4_COD")
	Endif
//Monta o cabeçalho
	If !Empty(cNumSCJ) .and. nOpc = 4// Verificar se deve enviar e-mail -> se mudou o tipo de orcamento de em elaboracao para previsto ou firme
		SCJ->(dbSetOrder(1))	// CJ_FILIAL+CJ_NUM
		if SCJ->(dbSeek(xFilial("SCJ")+cNumSCJ))
			lEnvEmail := (cTpOrc = '1')
		endif
		cFilAnt := xFilial("SCJ")
		// aadd(aCabSCJ,{"CJ_FILIAL",xFilial("SCJ"),Nil})
		aadd(aCabSCJ,{"CJ_NUM",cNumSCJ,Nil})
	Else
		aadd(aCabSCJ,{"CJ_COTCLI",Time(),Nil})
		if !empty(HttpPost->CJ_VEND)
			If !empty(HttpSession->Superv) .and. !empty(HttpSession->Tipo) .and. HttpSession->Tipo = 'S' .and. HttpPost->CJ_VEND = HttpSession->Superv //Se supervisor, atualiza p/o vendedor do cliente
				cSaveVend := SA1->A1_VEND
			else
				cSaveVend := HttpPost->CJ_VEND
			Endif
		else
//			cSaveVend := HttpSession->CodVend
			cSaveVend := cVendLogin
		endif
		//if !empty(SA1->A1_VEND+SA1->A1_VEND2+SA1->A1_VEND3) .and. ! (trim(cSaveVend)+"/" $ trim(SA1->A1_VEND)+"/"+trim(SA1->A1_VEND2)+"/"+trim(SA1->A1_VEND3)+"/")
		if !empty(SA1->A1_VEND) .and. ! (trim(cSaveVend)+"/" $ trim(SA1->A1_VEND)+"/")
			cSaveVend := SA1->A1_VEND
		endif
		aadd(aCabSCJ,{"CJ_VEND", cSaveVend, Nil})
		// #IFDEF SMSDEBUG
		//    conout('CJ_VEND = '+cSaveVend)
		//    oObjLog:saveMsg('CJ_VEND = '+cSaveVend)
		// #ENDIF
	EndIf
	aadd(aCabSCJ,{"CJ_CLIENTE",SA1->A1_COD,Nil})
	aadd(aCabSCJ,{"CJ_LOJA", SA1->A1_LOJA ,Nil})
	aadd(aCabSCJ,{"CJ_LOJAENT",SA1->A1_LOJA ,Nil})
	aadd(aCabSCJ,{"CJ_TABELA" ,cTabela,Nil})
	aadd(aCabSCJ,{"CJ_CONDPAG",cCondPag ,Nil})
	aadd(aCabSCJ,{"CJ_XNOTAIN",AllTrim(decodeutf8(HttpPost->CJ_XNOTAIN))+cMsgIn,Nil})
	aadd(aCabSCJ,{"CJ_XMSGNF",AllTrim(decodeutf8(HttpPost->CJ_XMSGNF)),Nil})
	aadd(aCabSCJ,{"CJ_TPFRETE" ,cTipoFrete,Nil})
	aadd(aCabSCJ,{"CJ_FRETE" ,nFrete,Nil})
	aadd(aCabSCJ,{"CJ_XTPORC" ,cTpOrc,Nil})
	aadd(aCabSCJ,{"CJ_XMODALI" ,cModalidade,Nil})
	if !Empty(cImport)
		aadd(aCabSCJ,{"CJ_XIMPORT" ,cImport,Nil})
	ENDIF
	If !Empty(cTransp)
		aadd(aCabSCJ,{"CJ_XTRANSP",IIf(cTipoFrete $ "SR","",cTransp),Nil})
	Endif
	If !Empty(cMetodoP)
		aadd(aCabSCJ,{"CJ_XCODPAG",cMetodoP,Nil})
	Endif
	If !Empty(cCliOper)
		aadd(aCabSCJ,{"CJ_CLIOPER",cCliOper,Nil})
	Endif
	If !Empty(nDesc1)
		aadd(aCabSCJ,{"CJ_DESC1",nDesc1 ,Nil})
	Endif
	If !Empty(nDesc2)
		aadd(aCabSCJ,{"CJ_DESC2",nDesc2 ,Nil})
	Endif

	If HttpPost->CJ_TPFRETE = "R" //Retira
		aadd(aCabSCJ,{"CJ_XRETIRA",'1' ,Nil})
	Endif

	aadd(aCabSCJ,{"CJ_XSALDO",nSaldo ,Nil})
	aadd(aCabSCJ,{"CJ_XACRESC",nAcrFin ,Nil})
//Monta os itens
	dbSelectArea("SB1")
	SB1->(dbSetorder(1))


	If ValType(aItens) == "A"  .and. Len(aItens) > 0

		For i:=1 to Len(aItens)
			If ValType(aItens[i,1]) == 'C'
				aLinhaSCJ:={}
				cItem:= StrZero(i,TamSX3("CK_ITEM")[1])
				cProdSck:= PadR(aItens[i,1], TamSX3("CK_PRODUTO")[1])
				nQuantSck := val(aItens[i,2])
				nPrcVen := aItens[i,3]
				nPrcVen := val(StrTran(StrTran(nPrcVen,".",""),",","."))
				cFaixaDesc := aItens[i,4]
				nValIPI:= aItens[i,5]
				nValIPI := val(StrTran(StrTran(nValIPI,".",""),",","."))
				nValICMS:= aItens[i,6]
				nValICMS := val(StrTran(StrTran(nValICMS,".",""),",","."))
				nValST:= aItens[i,7]
				nValST := val(StrTran(StrTran(nValST,".",""),",","."))
				cTes := aItens[i,8]
				nPerCom:= aItens[i,9]
				nPerCom:= val(StrTran(StrTran(nPerCom,".",""),",","."))
				nAliICMS:= aItens[i,10]
				nAliICMS:= val(StrTran(StrTran(nAliICMS,".",""),",","."))
				nAliIPI:= aItens[i,11]
				nAliIPI:= val(StrTran(StrTran(nAliIPI,".",""),",","."))
				nAliST:= aItens[i,12]
				nAliST:= val(StrTran(StrTran(nAliST,".",""),",","."))
				nDescont:= Iif(Empty(aItens[i,13]),0,Val(StrTran(aItens[i,13],",",".")))
				cPedCli:= aItens[i,14]
				cItemCli:= aItens[i,15]
				nDesc01 := Iif(Empty(aItens[i,16]),0,Val(StrTran(aItens[i,16],",",".")))
				nDesc02 := Iif(Empty(aItens[i,17]),0,Val(StrTran(aItens[i,17],",",".")))
				nDesc03 := Iif(Empty(aItens[i,18]),0,Val(StrTran(aItens[i,18],",",".")))
				nSldItm := Iif(Empty(aItens[i,19]),0,Val(StrTran(aItens[i,19],",",".")))
				nPrcImp := aItens[i,20]
				nPrcImp := val(StrTran(StrTran(nPrcImp,".",""),",","."))
				/*
				nAcresc := val(aItens[i,21])*-1

				If !Empty(nAcresc) .and. i = 1
					aadd(aCabSCJ,{"CJ_XACRESC",nAcresc ,Nil})
				Endif
				*/

				If SB1->(dbSeek(xFilial("SB1")+cProdSck)) .and. nQuantSck > 0 .And. nPrcVen > 0	.and. SB1->B1_MSBLQL <> '1'
					aadd(aLinhaScj,{"CK_ITEM"	,cItem,Nil})
					aadd(aLinhaScj,{"CK_PRODUTO",SB1->B1_COD,Nil})
					//aadd(aLinhaScj,{"CK_LOCAL"	,Iif(cValToChar(cImport) == '1','IM',SB1->B1_LOCPAD),Nil}) //local padrão de orçamento
					aadd(aLinhaScj,{"CK_QTDVEN" ,nQuantSck,Nil})
					aadd(aLinhaScj,{"CK_PRCVEN" ,nPrcVen,Nil})
					aadd(aLinhaScj,{"CK_TES" 	,cTes,Nil})
					aadd(aLinhaScj,{"CK_DESCONT",nDescont-nAcresc,Nil})
					conout(nDescont)
					conout(nAcresc)
					aadd(aLinhaScj,{"CK_ENTREG" ,dDtEntreg,Nil})
					aadd(aLinhaScj,{"CK_XVALIPI",nValIPI,Nil})
					aadd(aLinhaScj,{"CK_XVALICM",nValICMS,Nil})
					aadd(aLinhaScj,{"CK_XICMST"	,nValST,Nil})
					aadd(aLinhaScj,{"CK_XALIICM",nAliICMS,Nil})
					aadd(aLinhaScj,{"CK_XALIIPI",nAliIPI,Nil})
					aadd(aLinhaScj,{"CK_XALIST ",nAliST,Nil})
					aadd(aLinhaScj,{"CK_XPEDCLI",cPedCli,Nil})
					aadd(aLinhaScj,{"CK_XITEMCL",cItemCli,Nil})
					aadd(aLinhaScj,{"CK_XDESC01",nDesc01,Nil})
					aadd(aLinhaScj,{"CK_XDESC02",nDesc02,Nil})
					aadd(aLinhaScj,{"CK_XDESC03",nDesc03,Nil})
					aadd(aLinhaScj,{"CK_XPRCIMP",nPrcImp,Nil})
					aadd(aLinhaScj,{"CK_XDESC"	,nDescont,Nil})
					aadd(aLinhaScj,{"CK_XSALDO"	,nSldItm,Nil})
					aadd(aItemScj,aLinhaScj)
				Else
					lRet:= .F.
				Endif
			Endif
		Next

		//Chama execauto para inclusão do orçamento
		If Len(aCabSCJ) > 0 .and. Len(aItemSCJ) > 0 .and. lRet
			lMsErroAuto:= .F.
			MATA415(aCabSCJ,aItemSCJ,nOpc)
		Else
			If !EmptY(cNumSCJ)
				conout(Procname()+"("+ltrim(str(procline()))+") *** Portal "+"FALHA AO INCLUIR O ORÇAMENTO. REFAÇA A OPERAÇÃO!")
			Else
				conout(Procname()+"("+ltrim(str(procline()))+") *** Portal "+"FALHA AO ALTERAR O ORÇAMENTO. REFAÇA A OPERAÇÃO!")
			EndIf
			lRet := .F.
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
			cMsg:= MostraErro(cDirErro,"erro_orcto_"+strtran(time(),":","")+"_"+cFilAnt+".txt")
			cDestMail:= "pedidos@roberlo.com.br"
			u_MailCM("ERRO ORCAMENTO",{cDestMail},{},"ERRO ORCAMENTO NO PORTAL",cMsg,"","")
			cHtml:= "erro"
		Else
			//SCJ->(dbGoBottom())
			//Verifica se o orçamento utiliza o estoque da importadora
			// If SCJ->CJ_XIMPORT = "1"  .AND. cTpOrc = '2' //Apenas orçamentos firmes
			// 	StartJob("u_OrcImport",getEnvServer(),.F.,cFilImp, nOpc, aCabSCJ, aItemSCJ, SM0->M0_CGC, SCJ->CJ_FILIAL, SCJ->CJ_NUM, SCJ->CJ_XORCIMP)
			// Endif

			cHtml:= SCJ->CJ_NUM+"<br><br>"

			// If lPneu
			cDestOrc := GetNewPar("AA_DESTORC","")
			// Else
			// 	cDestOrc := GetNewPar("AA_DESTORP","")
			// Endif

			//Envia e-mail informando a inclusão do orçamento
			If !Empty(cDestOrc) .and. (nOpc = 3 .or. lEnvEmail) .and. SCJ->CJ_XTPORC = '1' //não envia para orçamento previsto
				cMsg:= "Um novo orçamento foi gerado pelo Portal do Representante.<br><br>"
				cMsg+= "Filial: "+SCJ->CJ_FILIAL+"<br>"
				cMsg+= "Número: "+SCJ->CJ_NUM+"<br> "
				cMsg+= "Vendedor: "+SCJ->CJ_VEND+" - "+Alltrim(Posicione("SA3",1,xFilial("SA3")+SCJ->CJ_VEND,"A3_NOME"))+"<br>"
				cMsg+= "Cliente: "+SCJ->CJ_CLIENTE+"/"+SCJ->CJ_LOJA+" - "+Posicione("SA1",1,+xFilial("SA1")+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA,"A1_NOME")+"<br>"
				cMsg+= "Observação Interna: "+SCJ->CJ_XNOTAIN+"<br><br>"
				cMsg+= "Acesse o Protheus para efetivar o orçamento."
				u_MailCM("ORÇAMENTO",{cDestOrc},{},"NOVO ORCAMENTO PORTAL: "+SCJ->CJ_FILIAL+"/"+SCJ->CJ_NUM+" - "+;
					trim(Posicione("SA1",1,+xFilial("SA1")+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA,"A1_NOME")),cMsg,"","")
			Endif
		EndIf
	Else
		cHtml:= "erro"
	Endif

	Web Extended End

Return (cHTML)


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetTabela   	¦ Autor ¦ Lucilene Mendes   ¦ Data ¦ 02.09.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Função utilizada no Ajax pra retornar a tabela de preço    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function GetTabela(cTab,lEst, cVendEst)
	Local cHtml
	Local cVend	 	:= HttpSession->CodVend
	Local cTabela	:= ""
	Local cCodTab	:= ""
	Local cTabClas	:= ""
	Local cTabCamp	:= ""
	Local cEstVend	:= ""
	local aInfoVend := {"", ""}				// Informacoes do vendedor (Tipo e Equipe)
	Default cTab	:= ""
	Default lEst	:= .F.
	Default cVendEst  := ""
	Private cCodLogin := ""
	Private cVendLogin:= ""

	Web Extended Init cHtml Start U_inSite(!lEst)

	If!lEst.and.Empty(HttpSession->CodVend)
		cHtml:='<METAHTTP-EQUIV="Refresh"CONTENT="0;URL=U_PortalLogin.apw">'
		Return cHtml
	endif

	//Tabela vinculada ao cliente
	if type("httppost->cliente") <> "U"
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+httppost->cliente))
			cCodTab:= SA1->A1_TABELA

			//Verifica se cliente tem classificação
			If !Empty(SA1->A1_XCLASS)
				//Busca a tabela de preço da classificação
				cQry:= "SELECT DA0_CODTAB "
				cQry+= "FROM "+RetSqlName("DA0")+" DA0 "
				cQry+= "WHERE DA0_FILIAL = '"+xFilial("DA0")+"'
				cQry+= "AND DA0_XCLASS = '"+SA1->A1_XCLASS+"' "
				cQry+= "AND DA0_ATIVO = '1' "
				cQry+= "AND D_E_L_E_T_ = ' ' "
				If Select("QCLAS") > 0
					QCLAS->(dbCloseArea())
				Endif	
				TcQuery cQry New Alias "QCLAS"

				If QCLAS->(!Eof())
					cTabClas:= QCLAS->DA0_CODTAB
					//Tabela da classificação do cliente
					DA0->(dbSetOrder(1))
					If DA0->(dbSeek(xFilial("DA0")+cTabClas))
						cTabela+='	<option value="'+Alltrim(DA0->DA0_CODTAB)+'">'+Alltrim(DA0->DA0_CODTAB)+' - '+Alltrim(DA0->DA0_DESCRI)+'</option>' 
					Endif
				Endif
			Endif
		Endif
	Endif
	if lEst
		cVendLogin := cVendEst
	Else
		cVendLogin := u_GetUsrPR()
	endif
	aInfoVend := u_getUsPR("Vendedor", cVendLogin)

	//Tabela do cliente
	if !Empty(cCodTab)
		DA0->(dbSetOrder(1))
		If DA0->(dbSeek(xFilial("DA0")+cCodTab))
			cTabela+='	<option value="'+Alltrim(DA0->DA0_CODTAB)+'">'+Alltrim(DA0->DA0_CODTAB)+' - '+Alltrim(DA0->DA0_DESCRI)+'</option>' 
		Endif
	Endif

	//Tabela de preço de campanha
	cQry:= "SELECT DA0_CODTAB, DA0_DESCRI "
	cQry+= "FROM "+RetSqlName("DA0")+" DA0 "
	cQry+= "WHERE DA0_FILIAL = '"+xFilial("DA0")+"'
	cQry+= "AND SUBSTRING(DA0_CODTAB,1,1) = 'C' "
	cQry+= "AND DA0_DATDE <= '"+DTOS(dDataBase)+"' "
	cQry+= "AND DA0_DATATE >= '"+DTOS(dDataBase)+"' "
	cQry+= "AND D_E_L_E_T_ = ' ' "
	If Select("QCAMP") > 0
		QCAMP->(dbCloseArea())
	Endif	
	TcQuery cQry New Alias "QCAMP"

	While QCAMP->(!Eof())
		cTabela+='	<option value="'+Alltrim(QCAMP->DA0_CODTAB)+'">'+Alltrim(QCAMP->DA0_CODTAB)+' - '+Alltrim(QCAMP->DA0_DESCRI)+'</option>' 
		QCAMP->(dbSkip())
	End	

	//Tabela de preço do grupo de vendas
	cQry:= "SELECT DA0_CODTAB, DA0_DESCRI "
	cQry+= "FROM "+RetSqlName("DA0")+" DA0 "
	cQry+= "INNER JOIN "+RetSqlName("ZYG")+" ZYG ON ZYG_FILIAL = '"+xFilial("ZYG")+"' and ZYG.D_E_L_E_T_ = ' ' "
	If lEst
		//Busca os estados dos clientes
		cQryEst:= "Select DISTINCT A1_EST "
		cQryEst+= "FROM "+RetSqlName("SA1")+" SA1 "
		cQryEst+= "Where SA1.D_E_L_E_T_ = ' ' "
		If aInfoVend[1] = "S" //Supervisor acessa informações da sua equipe
			cQryEst+=" And A1_VEND in "+FormatIn(aInfoVend[2] ,"|")+" "
		Else
			cQryEst+=" And A1_VEND = '"+cVendLogin+"'
		Endif
		If Select("QEST") > 0
			QEST->(dbCloseArea())
		Endif
		TcQuery cQryEst New Alias "QEST"	

		While QEST->(!Eof())
			cEstVend+= QEST->A1_EST+"/"
			QEST->(dbSkip())
		End			

		cQry+= " and ZYG_EST in "+FormatIn(cEstVend,"/")+"  "
	Else
		cQry+= " and ZYG_EST = '"+SA1->A1_EST+"'  "
	Endif
	cQry+= "WHERE DA0_FILIAL = '"+xFilial("DA0")+"' "
	cQry+= "AND DA0_XGRUPO = ZYG_CODIGO "
	cQry+= "AND DA0_ATIVO = '1' " 
	cQry+= "AND DA0.D_E_L_E_T_ = ' ' "
	If Select("QGPO") > 0
		QGPO->(dbCloseArea())
	Endif	
	TcQuery cQry New Alias "QGPO"

	If QGPO->(!Eof())
		While QGPO->(!Eof())
			cTabela+='	<option value="'+Alltrim(QGPO->DA0_CODTAB)+'">'+Alltrim(QGPO->DA0_CODTAB)+' - '+Alltrim(QGPO->DA0_DESCRI)+'</option>' 
			QGPO->(dbSkip())
		End
	Endif	

	If lEst
		//Busca os itens da tabela de preço
		cQry:="Select DISTINCT DA0_FILIAL, DA0_CODTAB, DA0_DESCRI "
		cQry+=" From "+RetSqlName("DA0")+" DA0 "
		cQry+=" INNER JOIN "+RetSqlName("SA1")+" SA1 "
		cQry+=" ON DA0_CODTAB = A1_TABELA "
		cQry+=" AND A1_MSBLQL <> '1' AND SA1.D_E_L_E_T_ = ' ' "
		cQry+=" Where DA0_FILIAL = '"+xFilial("DA0")+"' "
		If aInfoVend[1] = "S" //Supervisor acessa informações da sua equipe
			cQry+=" And A1_VEND in "+FormatIn(aInfoVend[2] ,"|")+" "
		Else
			cQry+=" And A1_VEND = '"+cVendLogin+"'
		Endif
		cQry+=" AND DA0_ATIVO = '1' "
		cQry+=" AND DA0.D_E_L_E_T_ = ' ' "

		If !Empty(cTab)
			cQry+= " AND DA0_CODTAB <> '"+cTab+"' "
		Endif

		if !Empty(cCodTab)
			cQry+= " AND DA0_CODTAB <> '"+cCodTab+"' "
		Endif

		If !Empty(cTabClas)
			cQry+= " AND DA0_CODTAB <> '"+cTabClas+"' "
		Endif

		If !Empty(QGPO->DA0_CODTAB)
			cQry+= " AND DA0_CODTAB <> '"+QGPO->DA0_CODTAB+"' "
		Endif
		cQry+= " AND SUBSTRING(DA0_CODTAB,1,1) <> 'C' "
		cQry+=" Order by DA0_CODTAB "
		conout("PesqTab " +time()+" "+cqry)
		If Select("QRT") > 0
			QRT->(dbCloseArea())
		Endif

		APWExOpenQuery(ChangeQuery(cQry),'QRT',.T.)

		//Preenche o select da tabela
		While QRT->(!Eof())
			cTabela+='	<option value="'+Alltrim(QRT->DA0_CODTAB)+'" name="1" >'+Iif(lEst,Alltrim(QRT->DA0_FILIAL)+"/","")+Alltrim(QRT->DA0_CODTAB)+' - '+Alltrim(QRT->DA0_DESCRI)+'</option>'
			QRT->(dbSkip())
		End
		conout("Fim PesqTab " +time())
	Endif

	cHtml:= cTabela

	Web Extended end

Return cHtml

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetProdutos 	¦ Autor ¦ Lucilene Mendes   ¦ Data ¦ 02.09.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Função utilizada no Ajax pra retornar os produtos da tabela¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function GetProdutos()
	Local cHtml
	Local cCliente:= HttpPost->CLIENTE
	Local cTabela:= HttpPost->TABELA
	Local cProds := ""
	Local cGrupo := ""

	Web Extended Init cHtml Start U_inSite()

	// TODO - Pedro 20210208 - Remover???
	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_PortalLogin.apw">'
		Return cHtml
	endif
	//Atualiza a variável de sessão
	HttpSession->TABELA := cTabela

	//Busca os itens da tabela de preço
	cQry:="Select DA1_CODTAB, B1_GRUPO, BM_DESC, DA1_CODPRO, B1_DESC "
	cQry+=" From "+RetSqlName("DA1")+" DA1"
	cQry+=" INNER JOIN "+RetSqlName("DA0")+" DA0 ON DA0_FILIAL = DA1_FILIAL AND DA0_CODTAB = DA1_CODTAB AND DA0_ATIVO = '1' AND DA0.D_E_L_E_T_ = ' ' "
	cQry+=" INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = DA1_CODPRO AND B1_MSBLQL <> '1' AND SB1.D_E_L_E_T_ = ' ' "
	cQry+=" INNER JOIN "+RetSqlName("SBM")+" SBM ON BM_FILIAL = '"+xFilial("SBM")+"' AND B1_GRUPO = BM_GRUPO AND SBM.D_E_L_E_T_ = ' ' "
	cQry+=" Where DA1_FILIAL = '"+xFilial("DA1")+"' "
	cQry+=" And DA1_CODTAB = '"+cTabela+"' "
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
			cProds+= '<optgroup label="'+Alltrim(Strtran(QRP->BM_DESC,"'",""))+'">
		Elseif !Empty(cGrupo) .and. cGrupo <> QRP->B1_GRUPO
			cProds+= '</optgroup>'
			cProds+= '<optgroup label="'+Alltrim(Strtran(QRP->BM_DESC,"'",""))+'">
		Endif
		cProds+='	<option value="'+Alltrim(QRP->DA1_CODPRO)+'">'+Alltrim(QRP->DA1_CODPRO)+' - '+Alltrim(Strtran(QRP->B1_DESC,"'",""))+'</option>'
		cGrupo:= QRP->B1_GRUPO
		QRP->(dbSkip())
	End
	If !Empty(cProds)
		cProds+= '</optgroup>'
	Endif
	cHtml:= cProds


	Web Extended end

Return cHtml


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GatProd   	¦ Autor ¦ Lucilene Mendes   ¦ Data ¦ 05.09.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Gatilho para atualização dos preços ao selecionar o produto¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function GatProd()
	Local cProduto	:= Alltrim(HttpPost->PRODUTO)
	Local cTabela	:= Alltrim(HttpSession->Tabela)
	Local cCliente	:= Alltrim(HttpSession->Cliente)
	Local cGeraSaldo:= ""
	Local cUltrapassa:= ""
	Local nDescVista:= 0
	Local nDescRetir:= 0
	Local nPDesc01	:= 0
	Local nPDesc02	:= 0
	Local nPDesc03	:= 0
	Local cSepReg 	:= "#*#*"
	Local cSepField := "|#|"
	Local cTes		:= ""
	Local cPneus	:= ""
	Local cMarca	:= ""
	Local nQtdFis 	:= 1
	Local nDesc 	:= 0
	Local nValIcms	:= 0
	Local nBaseIcms	:= 0
	Local nValST	:= 0
	Local nBaseST	:= 0
	Local nValIPI	:= 0
	Local nBaseIPI	:= 0
	Local cAliqIPI	:= 0
	Local cAliqICMS	:= 0
	Local cAliqST	:= 0
	Local nAcresCF	:= 0 //acréscimo consumidor final
	Local nQtdMin	:= 0
	Local aRet		:= {}
	Local cHtml

	if valtype(HttpPost->DescVista) = "C"
		nDescVista := val(HttpPost->DescVista)
	Endif
	if valtype(HttpPost->DescRetir) = "C"
		nDescRetir:= val(HttpPost->DescRetir)
	Endif

	nSec:= Seconds()

	Web Extended Init cHtml Start U_inSite()

	Conout("[ADDORC] - tempo Abertura InSite: "+cValtoChar(Seconds()-nSec)+"s") 

	//Busca o cadastro do cliente
	Posicione("SA1",1,xFilial("SA1")+cCliente,"A1_COD")

	//Posiciona no cadastro do produto
	Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_COD")

	//Busca os grupos de pneus
	cPneus:= GetNewPar("AA_GRPNEUP","20|21|22|23|24")

	//Grupo de pneus para acréscimo consumidor final
	cPneusCF:= GetNewPar("AA_GRPNEUF","20|21|22|23|24")

	//Marca do produto
	cMarca:= Alltrim(Posicione("SX5",1,xFilial("SX5")+'ZB'+SB1->B1_SMARCA,"X5_DESCRI"))

	cGeraSaldo:= Iif(!Empty(SB1->B1_XGERASL),SB1->B1_XGERASL,'1')
	cUltrapassa:= '2' //Iif(!Empty(SB1->B1_XULTMAX),SB1->B1_XULTMAX,'1')

	//Posiciona na tabela de preço
	Posicione("DA0",1,xFilial("DA0")+cTabela,"DA0_CODTAB")
	Posicione("DA1",1,xFilial("DA1")+cTabela+cProduto,"DA1_CODTAB")
	//Descontos
	nPDesc01:= DA1->DA1_XDESC1
	nPDesc02:= DA1->DA1_XDESC2
	nPDesc03:= DA1->DA1_XDESC3
	nPrcTab := DA1->DA1_PRCVEN
	nQtdMin:= DA1->DA1_XQTMIN
	cGeraSaldo:= Iif(Left(cTabela,1)="C",'2',cGeraSaldo) //Tabela de campanha não deve gerar saldo

	//Aplica acrescimo para consumidor final
	If SA1->A1_PESSOA = 'F' .and. (Alltrim(SB1->B1_GRUPO) $ cPneusCF) //.or. DA0->DA0_XPOLIM = '1'
		nAcresCF := GetMv("AA_ACRESCF")
	Endif

	If nPrcTab > 0
		// Retira do preco o desconto a vista
		if (nDescVista > 0)
			nPrcTab := nPrcTab * (1 - (nDescVista/100.00))
		endif
		// Retira do preco o desconto retirada
		if ( nDescRetir > 0 )
			nPrcTab := nPrcTab * (1 - (nDescRetir/100.00))
		endif
		// Adiciona o acréscimo para consumidor final
		if ( nAcresCF > 0 )
			nPrcTab := nPrcTab * (1 + (nAcresCF/100.00))
		endif

		nSec:= Seconds()
		//Obtem os valores de impostos
		u_GetValImp(SA1->A1_COD+SA1->A1_LOJA,nPrcTab,nDesc,nQtdFis,@nValIcms,@nBaseICMS,@nValST,@nBaseST,@nValIPI,@nBaseIPI,@cAliqIPI,@cAliqICMS,@cAliqST,@cTes)

		Conout("[ADDORC] - tempo u_GetValImp: "+cValtoChar(Seconds()-nSec)+"s") 

		If Empty(cTes)
			cHtml:= "ERRO:TES nao localizada."
		Else	

			nValDesc:= nPrcTab * nDesc
			cPrcTab := TransForm((nPrcTab-nValDesc),PesqPict("SCK","CK_XICMST"))
	//		cPrcTab := TransForm((nPrcTab-nValDesc),PesqPict("SCK","CK_PRCVEN"))
			cTotalST:= Transform(((nPrcTab-nValDesc)+nValST),PesqPict("SCK","CK_PRCVEN"))

			aAdd(aRet,Alltrim(SB1->B1_UM))
			aAdd(aRet,Alltrim(cPrcTab))
			aAdd(aRet,Alltrim(Transform(nValIcms,PesqPict("SCK","CK_XVALICM"))))
			aAdd(aRet,Alltrim(Transform(nValIPI,PesqPict("SCK","CK_XVALIPI"))))
			aAdd(aRet,Alltrim(Transform(nValST,PesqPict("SCK","CK_XICMST"))))
			aAdd(aRet,cAliqIPI)
			aAdd(aRet,cAliqICMS)
			aAdd(aRet,cValtochar(SB1->B1_QE))
			aAdd(aRet,cTES)
			aAdd(aRet,cValtoChar(nBaseICMS))
			aAdd(aRet,cValtoChar(nBaseST))
			aAdd(aRet,cValtoChar(nBaseIPI))
			aAdd(aRet,cAliqST)
			aAdd(aRet,Iif(Alltrim(SB1->B1_GRUPO) $ cPneus,"1","2"))  //SE PRODUTO É PNEU
			aAdd(aRet,cMarca)
			aAdd(aRet,SB1->B1_GRUPO)
			aAdd(aRet,cvaltochar(nPDesc01))
			aAdd(aRet,cvaltochar(nPDesc02))
			aAdd(aRet,cvaltochar(nPDesc03))
			aAdd(aRet,cGeraSaldo)
			aAdd(aRet,cUltrapassa)
			aAdd(aRet,cvaltochar(nQtdMin))

			cHtml := "OK:"
			cHtml += aRet[1]+cSepField+aRet[2]+cSepField+aRet[3]+cSepField+aRet[4]+cSepField+aRet[5]+cSepField+aRet[6]+cSepField+aRet[7]+cSepField+aRet[8]
			cHtml +=cSepField+aRet[9]+cSepField+aRet[10]+cSepField+aRet[11]+cSepField+aRet[12]+cSepField+aRet[13]+cSepField+aRet[14]+cSepField+aRet[15]
			cHtml +=cSepField+aRet[16]+cSepField+aRet[17]+cSepField+aRet[18]+cSepField+aRet[19]+cSepField+aRet[20]+cSepField+aRet[21]+cSepField+aRet[22]
		Endif
	Else
		cHtml := "ERRO:Não foi possível localizar o produto"
	Endif

	Web Extended end

Return cHtml

User Function GetImpostos()
	Local cProduto	:= Alltrim(HttpPost->PRODUTO)
	Local nPrcTab	:= Val(HttpPost->prcvenda)
//	Local cTabela	:= Alltrim(HttpSession->Tabela)
	Local cCliente	:= Alltrim(HttpSession->Cliente)
	Local nQtdFis 	:= Val(HttpPost->quantidade)
//	Local cSepReg 	:= "#*#*"
	Local cSepField := "|#|"
	Local cTes		:= ""
	Local nDesc 	:= 0
	Local nValIcms	:= 0
	Local nBaseIcms	:= 0
	Local nValST	:= 0
	Local nBaseST	:= 0
	Local nValIPI	:= 0
	Local nBaseIPI	:= 0
	Local cAliqIPI	:= 0
	Local cAliqICMS	:= 0
	Local cAliqST	:= 0
	Local aRet		:= {}
	Local cHtml

	Web Extended Init cHtml Start U_inSite()

	//Busca o cadastro do cliente
	Posicione("SA1",1,xFilial("SA1")+cCliente,"A1_COD")

	//Posiciona no cadastro do produto
	Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_COD")

	If nPrcTab > 0

		//Obtem os valores de impostos
		u_GetValImp(SA1->A1_COD+SA1->A1_LOJA,nPrcTab,nDesc,nQtdFis,@nValIcms,@nBaseICMS,@nValST,@nBaseST,@nValIPI,@nBaseIPI,@cAliqIPI,@cAliqICMS,@cAliqST,@cTes)

		nValDesc:= nPrcTab * nDesc
		cPrcTab := TransForm((nPrcTab-nValDesc),PesqPict("SCK","CK_XICMST"))
//		cPrcTab := TransForm((nPrcTab-nValDesc),PesqPict("SCK","CK_PRCVEN"))
		cTotalST:= Transform(((nPrcTab-nValDesc)+nValST),PesqPict("SCK","CK_PRCVEN"))

		aAdd(aRet,Alltrim(SB1->B1_UM))
		aAdd(aRet,Alltrim(cPrcTab))
		aAdd(aRet,Alltrim(Transform(nValIcms,PesqPict("SCK","CK_XVALICM"))))
		aAdd(aRet,Alltrim(Transform(nValIPI,PesqPict("SCK","CK_XVALIPI"))))
		aAdd(aRet,Alltrim(cValtoChar(nValST)))
		//aAdd(aRet,Alltrim(Transform(nValST,PesqPict("SCK","CK_XICMST"))))
		aAdd(aRet,cAliqIPI)
		aAdd(aRet,cAliqICMS)
		aAdd(aRet,cValtochar(SB1->B1_QE))
		aAdd(aRet,cTES)
		aAdd(aRet,cValtoChar(nBaseICMS))
		aAdd(aRet,cValtoChar(nBaseST))
		aAdd(aRet,cValtoChar(nBaseIPI))
		aAdd(aRet,cAliqST)

		cHtml := "OK:"
		cHtml += aRet[1]+cSepField+aRet[2]+cSepField+aRet[3]+cSepField+aRet[4]+cSepField+aRet[5]+cSepField+aRet[6]+cSepField+aRet[7]+cSepField+aRet[8]
		cHtml +=cSepField+aRet[9]+cSepField+aRet[10]+cSepField+aRet[11]+cSepField+aRet[12]+cSepField+aRet[13]
	Else
		cHtml := "Falha ao calcular impostos"
	Endif

	Web Extended end

Return cHtml

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetValImp   ¦ Autor ¦ Anderson Zelenski  ¦ Data ¦ 09.09.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Função para cálculo dos impostos						      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function GetValImp(cCliente,nPreco,nDesc,nQtdFis,nValIcms,nBaseIcms,nValST,nBaseST,nValIPI,nBaseIPI,cAliqIPI,cAliqICMS,cAliqST,cTes)
	Local _nItem:= 0
	Local cCodOper:= ""
	MaFisEnd()

	SA1->(dbSetorder(1))
	SA1->(dbSeek(xFilial("SA1")+cCliente))

	cCodOper:= Iif(Empty(SA1->A1_YCDOPER),GetNewPar("AA_CODOPER","01"),SA1->A1_YCDOPER)

	MaFisIni(SA1->A1_COD,;// 1-Codigo Cliente/Fornecedor
	SA1->A1_LOJA,;// 2-Loja do Cliente/Fornecedor
	"C",; // 3-C:Cliente , F:Fornecedor
	"N",; // 4-Tipo da NF
	SA1->A1_TIPO,;// 5-Tipo do Cliente/Fornecedor
	MaFisRelImp("MT100", {"SF2", "SD2"}),; // 6-Relacao de Impostos que suportados no arquivo
	,;// 7-Tipo de complemento
	,;// 8-Permite Incluir Impostos no Rodape .T./.F.
	"SB1",; // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
	"MATA461")

	dbSelectArea("SE4")
	SE4->(DbSetOrder(1))

	cTes:= MaTesInt(2,cCodOper,SA1->A1_COD,SA1->A1_LOJA,"C",SB1->B1_COD,"",SA1->A1_TIPO)
	// conout("tes -->"+cTes)
	// conout("prod -->"+SB1->B1_COD)
	_nItem := MaFisAdd(SB1->B1_COD,; // 1-Codigo do Produto ( Obrigatorio )
	cTes,;// 2-Codigo do TES ( Opcional )
	nQtdFis,; // 3-Quantidade ( Obrigatorio )
	nPreco,; // 4-Preco Unitario ( Obrigatorio )
	nDesc,; // 5-Valor do Desconto ( Opcional )
	,;// 6-Numero da NF Original ( Devolucao/Benef )
	,;// 7-Serie da NF Original ( Devolucao/Benef )
	,;// 8-RecNo da NF Original no arq SD1/SD2
	0,; // 9-Valor do Frete do Item ( Opcional )
	0,; // 10-Valor da Despesa do item ( Opcional )
	0,; // 11-Valor do Seguro do item ( Opcional )
	0,; // 12-Valor do Frete Autonomo ( Opcional )
	nPreco,; // 13-Valor da Mercadoria ( Obrigatorio )
	0,; // 14-Valor da Embalagem ( Opiconal )
	0,; // 15-RecNo do SB1
	0)// 16-RecNo do SF4

//ICMS
	nValIcms:= MaFisRet(_nItem,"IT_VALICM")
	nBaseIcms:= MaFisRet(_nItem,"IT_BASEICM")
	cAliqICMS:= Alltrim(Str(MaFisRet(_nItem,"IT_ALIQICM")))

//IPI
	nValIPI := MaFisRet(_nItem,"IT_VALIPI")
	nBaseIPI := MaFisRet(_nItem,"IT_BASEIPI")
	cAliqIPI := Alltrim(Str(MaFisRet(_nItem,"IT_ALIQIPI")))

//ICMS ST
	nValST	:= MaFisRet(_nItem,"IT_VALSOL")
	nBaseST := MaFisRet(_nItem,"IT_BASESOL")
	cAliqST	:= Alltrim(Str(MaFisRet(_nItem,"IT_ALIQSOL")))

Return
/*
User Function GetValImp(cCliente,nPreco,nDesc,nQtdFis,nValIcms,nBaseIcms,nValST,nBaseST,nValIPI,nBaseIPI,cAliqIPI,cAliqICMS,cAliqST,cTes)
	Local _nItem:= 0
	Local cCodOper:= ""
	MaFisEnd()

	SA1->(dbSetorder(1))
	SA1->(dbSeek(xFilial("SA1")+cCliente))

	cCodOper:= Iif(Empty(SA1->A1_YCDOPER),GetNewPar("AA_CODOPER","01"),SA1->A1_YCDOPER)

	MaFisIni(SA1->A1_COD,;// 1-Codigo Cliente/Fornecedor
	SA1->A1_LOJA,;// 2-Loja do Cliente/Fornecedor
	"C",; // 3-C:Cliente , F:Fornecedor
	"N",; // 4-Tipo da NF
	SA1->A1_TIPO,;// 5-Tipo do Cliente/Fornecedor
	MaFisRelImp("MTR700",{"SC5","SC6"}),; // 6-Relacao de Impostos que suportados no arquivo
	,;// 7-Tipo de complemento
	,;// 8-Permite Incluir Impostos no Rodape .T./.F.
	"SB1",; // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
	"MTR700")


	dbSelectArea("SE4")
	SE4->(DbSetOrder(1))

	cTes:= MaTesInt(2,cCodOper,SA1->A1_COD,SA1->A1_LOJA,"C",SB1->B1_COD,"",SA1->A1_TIPO)
	// conout("tes -->"+cTes)
	// conout("prod -->"+SB1->B1_COD)
	_nItem := MaFisAdd(SB1->B1_COD,; // 1-Codigo do Produto ( Obrigatorio )
	cTes,;// 2-Codigo do TES ( Opcional )
	nQtdFis,; // 3-Quantidade ( Obrigatorio )
	nPreco,; // 4-Preco Unitario ( Obrigatorio )
	nDesc,; // 5-Valor do Desconto ( Opcional )
	,;// 6-Numero da NF Original ( Devolucao/Benef )
	,;// 7-Serie da NF Original ( Devolucao/Benef )
	,;// 8-RecNo da NF Original no arq SD1/SD2
	0,; // 9-Valor do Frete do Item ( Opcional )
	0,; // 10-Valor da Despesa do item ( Opcional )
	0,; // 11-Valor do Seguro do item ( Opcional )
	0,; // 12-Valor do Frete Autonomo ( Opcional )
	nPreco,; // 13-Valor da Mercadoria ( Obrigatorio )
	0,; // 14-Valor da Embalagem ( Opiconal )
	0,; // 15-RecNo do SB1
	0)// 16-RecNo do SF4

//ICMS
	nValIcms:= MaFisRet(_nItem,"IT_VALICM")
	nBaseIcms:= MaFisRet(_nItem,"IT_BASEICM")
	cAliqICMS:= Alltrim(Str(MaFisRet(_nItem,"IT_ALIQICM")))

//IPI
	nValIPI := MaFisRet(_nItem,"IT_VALIPI")
	nBaseIPI := MaFisRet(_nItem,"IT_BASEIPI")
	cAliqIPI := Alltrim(Str(MaFisRet(_nItem,"IT_ALIQIPI")))

//ICMS ST
	nValST	:= MaFisRet(_nItem,"IT_VALSOL")
	nBaseST := MaFisRet(_nItem,"IT_BASESOL")
	cAliqST	:= Alltrim(Str(MaFisRet(_nItem,"IT_ALIQSOL")))

Return
*/

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ FreteMinimo ¦ Autor ¦ Lucilene Mendes  	¦ Data ¦ 09.09.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Validação para valor mínimo do frete.				      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function FreteMinimo()
	Local cHtml
	Local cCliente	:= Alltrim(HttpSession->Cliente)
	Local cTipo		:= Alltrim(HttpPost->tipoFrete)
	Local cUF		:= ""
	Local nValMin	:= 0

	Web Extended Init cHtml Start U_inSite()

	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_PortalLogin.apw">'
		Return cHtml
	endif
	//Busca o UF do cliente
	cUF:= Posicione("SA1",1,xFilial("SA1")+cCliente,"A1_EST")
	//Busca o valor mínimo
	nValMin:= Iif(cUF = 'PR',GetNewPar("AA_FRTMPR",2500),GetNewPar("AA_FRTMIN",3500))
	cHtml:= cvaltochar(nValMin)

	Web Extended end

Return cHtml

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetTransp ¦ Autor ¦ Lucilene Mendes  	¦ Data ¦ 11.09.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Retorna a transportadora de acordo com o tipo de frete.    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function GetTransp()
	Local cHtml
	Local cCliente	:= Alltrim(HttpSession->Cliente)
	Local cTabPreco	:= Alltrim(HttpPost->Tabela)
	Local cTransp	:= ""

	Web Extended Init cHtml Start U_inSite()

	// TODO - Pedro 20210208 - Remover???
	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_PortalLogin.apw">'
		Return cHtml
	endif

	cTransp:= Posicione("SA3",1,xFilial("SA3")+HttpSession->CodVend,"A3_XTRANSP")

	If !Empty(cTransp)
		cNome:= Alltrim(Posicione("SA4",1,xFilial("SA4")+cTransp,"A4_NOME"))
		cTransp+='	<option value="'+Alltrim(cTransp)+'">'+cNome+'</option>'
	Endif

	/*
	If Empty(cTransp)
		//Seleciona as transportadoras disponíveis no combo
		cQry:= " Select A4_COD COD, A4_NOME NOME"
		cQry+= " From "+RetSqlName("SA4")+" SA4 "
		cQry+= " Where SA4.D_E_L_E_T_ = ' ' " //A4_FILIAL = '"+xFilial("SA4")+"' " -- problema no compartilhamento da tabela

		If Select("QRT")> 0
			QRT->(dbCloseArea())
		Endif	 	
		APWExOpenQuery(ChangeQuery(cQry),'QRT',.T.)

		cTransp+='	<option value=""></option>'
			
		While QRT->(!Eof())
			cTransp+='	<option value="'+Alltrim(QRT->COD)+'">'+Alltrim(QRT->NOME)+'</option>'
			QRT->(dbSkip())
		End	
	Endif
	*/
	cHtml:= cTransp

	Web Extended end

Return cHtml


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetVlrDesc ¦ Autor ¦ Lucilene Mendes  	¦ Data ¦ 11.07.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Verifica o valor máximo permitido de desconto.   		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function GetVlrDesc()
	Local cHtml
	Local cTabela := Alltrim(HttpSession->Tabela)
	Local cProduto:= Alltrim(HttpPost->Produto)
	Local cGrp	  := ""
	Local cDesc   := "0"

	Web Extended Init cHtml Start U_inSite()

	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_PortalLogin.apw">'
		Return cHtml
	endif
	//Busca o grupo de comissão
	cGrp := Posicione("DA1", 1, xFilial("DA1") + cTabela + cProduto, "DA1_GRPCOM")

	cQry:= " SELECT MAX(Z3_DESCON) Z3_DESCON "
	cQry+= " FROM "+RetSqlName("SZ3")+" SZ3 "
	cQry+= " WHERE SZ3.D_E_L_E_T_ = ' ' "
	cQry+= " AND Z3_FILIAL = '"+xFilial("SZ3")+"' "
	cQry+= " AND Z3_CODTAB = '"+cTabela+"' "
	cQry+= " AND Z3_GRPCOM = '"+cGrp+"' "
	cQry+= " AND Z3_MSBLQL <> '1' "

	If Select("QRD") > 0
		QRD->(dbCloseArea())
	Endif
	APWExOpenQuery(ChangeQuery(cQry),'QRD',.T.)

	cDesc:= cValtoChar(QRD->Z3_DESCON)

	cHtml:= cDesc

	Web Extended end

Return cHtml




/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetSitCli    ¦ Autor ¦ Lucilene Mendes   ¦ Data ¦ 19.11.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Função para buscar os dados de crédito do cliente.         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function GetSitCli()
	Local cHtml
	Local cCliente	:= Alltrim(HttpPost->Cliente)
	Local cMsg	:= ""
	Local nDias	:= 0
	Local nSaldoLC := 0
	Local lAtraso:= .F.
	Local lVencLC:= .F.
	Local lUltCom:= .F.

	Web Extended Init cHtml Start U_inSite()

	// TODO - Pedro 20210208 - Remover???
	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_PortalLogin.apw">'
		Return cHtml
	endif
	//Posiciona no cliente
	dbSelectArea("SA1")
	SA1->(dbSeek(xFilial("SA1")+cCliente))
	cRisco:= SA1->A1_RISCO
	//lVencLC:= Empty(SA1->A1_VENCLC) .OR. SA1->A1_VENCLC < date() //.and. SA1->A1_TIPO = 'F'
	lUltCom:= Empty(SA1->A1_ULTCOM) .OR. SA1->A1_ULTCOM < MonthSub(date(),6)

	//Atualiza a variável de sessão
	HttpSession->Cliente := cCliente
	If HttpSession->Tipo = 'S' //Se supervisor, atualiza p/o vendedor do cliente
		HttpSession->CodVend:= SA1->A1_VEND

		// Salva o vinculo Session X Vendedor no arquivo de controle (fonte insite.apl)
		u_svUsSes(SA1->A1_VEND)
	Endif


 /*   
    //Busca o saldo do limite
    cQry:= "Select SUM(E1_SALDO) SALDO "
	cQry+= " From "+RetSqlName("SE1")+" SE1 "
	cQry+= " Where E1_FILIAL = '"+xFilial("SE1")+"' "
	cQry+= " And E1_CLIENTE = '"+SA1->A1_COD+"' "
	cQry+= " And E1_LOJA = '"+SA1->A1_LOJA+"' "
	cQry+= " And E1_SALDO > 0 "
	cQry+= " And D_E_L_E_T_ = ' ' "
    If Select("QSAL") > 0
    	QSAL->(dbCloseArea())
    Endif
    TcQuery cQry New Alias "QSAL"	
 */   
//Busca pedidos aprovados em aberto
	cQry:= " SELECT SUM(C6_VALOR) PEDIDO "
	cQry+= " FROM "+RetSqlName("SC5")+" SC5 "
	cQry+= " INNER JOIN "+RetSqlName("SC6")+" SC6 ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND C6_NOTA = C5_NOTA AND SC6.D_E_L_E_T_ = ' ' "
	cQry+= " WHERE C5_FILIAL = '"+xFilial("SC5")+"' "
	cQry+= " And C5_CLIENTE = '"+SA1->A1_COD+"' "
	cQry+= " And C5_LOJACLI = '"+SA1->A1_LOJA+"' "
	cQry+= " AND C5_NOTA = ' ' "
	cQry+= " AND C5_LIBEROK = 'S'
	cQry+= " And SC5.D_E_L_E_T_ = ' ' "
	
	If Select("QPED") > 0
		QPED->(dbCloseArea())
	Endif
	
	TcQuery cQry New Alias "QPED"
 /* 
    nSaldoLC:= SA1->A1_LC - QSAL->SALDO - QPED->PEDIDO   
    cMsg+= '<div class="row form-group">'+CHR(13)+CHR(10)
    //cMsg+= '	<span><b>Limite de crÃ©dito</b></span><br>'+CHR(13)+CHR(10)
    cMsg+= '<header class="panel-heading">'
	cMsg+= '	<h2 class="panel-title">Limite de crÃ©dito</h2>'
	cMsg+= '</header>'
	cMsg+= '<br>'
	cMsg+= '	<div class="col-lg-6">Limite Total: R$ '+Alltrim(Transform(SA1->A1_LC,PesqPict("SA1","A1_LC")))+'</div>'+CHR(13)+CHR(10)
	cMsg+= '	<div class="col-lg-6">Saldo dispon&iacute;vel: R$ '+Alltrim(Transform(nSaldoLC,PesqPict("SA1","A1_LC")))+'</div>'+CHR(13)+CHR(10)
	cMsg+= '</div>'+CHR(13)+CHR(10)
	cMsg+= '<br>'+CHR(13)+CHR(10)
 */	
	nDias:= GetNewPar("AA_DIASATR",1)
// If !Empty(cRisco) .and. cRisco <> "A"
// 	If !Empty(GetMV("MV_RISCO"+cRisco))
//    		nDias:= GetMV("MV_RISCO"+cRisco)
// 	Endif
// Endif

//Busca os titulos em atraso do cliente
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

	If lAtraso .or. lVencLC .or. lUltCom
		cMsg+= '<div class="row form-group">'+CHR(13)+CHR(10)
		cMsg+= "<br>"+CHR(13)+CHR(10)
		cMsg+= '<div class="col-lg-12">'+CHR(13)+CHR(10)
		cMsg+= '	<header class="panel-heading">'
		cMsg+= '		<h2 class="panel-title">Financeiro</h2>'
		cMsg+= '	</header>'
		cMsg+= '	<br>'
		If cRisco = "E"
			cMsg+= '	<div class="col-lg-12">Cliente com risco alto. Permitida somente venda a vista.</div>'+CHR(13)+CHR(10)
		ElseIf lAtraso //.and. lVencLC
			cMsg+= '	<div class="col-lg-12">Cliente com t&iacute;tulos em atraso. O or&ccedilamento ser&aacute; do tipo previsto.</div>'+CHR(13)+CHR(10)
		Elseif lUltCom
			cMsg+= '	<div class="col-lg-12">Cliente sem compras nos &uacute;ltimos 6 meses, o cadastro deve passar por an&aacute;lise. N&atildeo ser&aacute; poss&iacute;vel continuar a venda.</div>'+CHR(13)+CHR(10)
		Endif

		/*
			If lAtraso
				cMsg+= '	<div class="col-lg-12">Cliente com t&iacute;tulos em atraso. N&atildeo ser&aacute; poss&iacute;vel continuar a venda.</div>'+CHR(13)+CHR(10)
			Else
				If SA1->A1_TIPO = 'F' //consumidor final pode fazer compra a vista
					cMsg+= '	<div class="col-lg-12">Cliente com documenta&ccedil&atildeo em atraso. Permitida somente venda a vista.</div>'+CHR(13)+CHR(10)
				Else
					// Chamado 24912 - Por gentileza, ajustar regra para pedidos com documentação em atraso permitir compra à vista, solicitação da Claudia do financeiro dia 11/03/2021
//					cMsg+= '	<div class="col-lg-12">Cliente com documenta&ccedil&atildeo em atraso. N&atildeo ser&aacute; poss&iacute;vel continuar a venda.</div>'+CHR(13)+CHR(10)
					cMsg+= '	<div class="col-lg-12">Cliente com documenta&ccedil&atildeo em atraso. Permitida somente venda a vista.</div>'+CHR(13)+CHR(10)
				Endif
			Endif
		Endif
		*/
		//cMsg+= '	<div class="col-lg-12">Cliente com t&iacute;tulos em atraso. O or&ccedilamento gerado ser&aacute do tipo PREVISTO ou EM ELABORACAO.</div>'+CHR(13)+CHR(10)
		cMsg+= '</div>'+CHR(13)+CHR(10)
		cMsg+= '</div>'+CHR(13)+CHR(10)

    /*
    	cMsg+= '<div class="row form-group">'+CHR(13)+CHR(10)
    	cMsg+= "<br>"+CHR(13)+CHR(10)
    	cMsg+= '<div class="col-lg-12">'+CHR(13)+CHR(10)
    	cMsg+= '<header class="panel-heading">'
		cMsg+= '	<h2 class="panel-title">T&iacute;tulos em atraso</h2>'
		cMsg+= '</header>'
    	
    	cMsg+= '<table class="table table-bordered table-striped table-condensed mb-none" id="titulosAtraso">'+CHR(13)+CHR(10)
    	cMsg+= "	<thead>"+CHR(13)+CHR(10)
    	cMsg+= "		<tr>"+CHR(13)+CHR(10)
    	cMsg+= "			<th>Numero</th>"+CHR(13)+CHR(10)
    	cMsg+= "			<th>Parcela</th>"+CHR(13)+CHR(10)
    	cMsg+= "			<th>Vencimento</th>"+CHR(13)+CHR(10)
    	cMsg+= "			<th>Saldo</th>"+CHR(13)+CHR(10)
    	cMsg+= "		</tr>"+CHR(13)+CHR(10)
    	cMsg+= "	</thead>"+CHR(13)+CHR(10)
    	cMsg+= "	<tbody>"+CHR(13)+CHR(10)
    										
	    While QRY->(!Eof())
	    	cMsg+= "<tr>
	    	cMsg+= "	<td>"+QRY->E1_PREFIXO+' - '+QRY->E1_NUM+"</td>"+CHR(13)+CHR(10)	
	    	cMsg+= "	<td>"+QRY->E1_PARCELA+"</td>"+CHR(13)+CHR(10)
	    	cMsg+= "	<td>"+DTOC(STOD(QRY->E1_VENCTO))+"</td>"+CHR(13)+CHR(10)	
	    	cMsg+= "	<td>"+Transform(QRY->E1_SALDO,PesqPict("SE1","E1_SALDO"))+"</td>"+CHR(13)+CHR(10)	
        	cMsg+= "</tr>"+CHR(13)+CHR(10)
        	QRY->(dbSkip())
        End
    	cMsg+="		</tbody>"+CHR(13)+CHR(10)
    	cMsg+="</table>"+CHR(13)+CHR(10)
    	cMsg+="</div>"+CHR(13)+CHR(10)
    	cMsg+="</div>"+CHR(13)+CHR(10)
    */
	Endif
	cHtml:= cMsg

	Web Extended end

Return cHtml


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetCellTb   ¦ Autor ¦ Lucilene Mendes  	¦ Data ¦ 22.11.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Função para geração da linha da tabela de itens		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function GetCellTb()

	Local cHtml
	Local nCol	:= HttpPost->coluna
	Local nLin	:= val(HttpPost->linha)
	Local cItem	:= ""
	Local cCampo:= ""

	Web Extended Init cHtml Start U_inSite()

	cItem:= StrZero(nLin,TamSX3("CK_ITEM")[1])

	cCampo:= "var campo = document.createElement('input'); " // create input element
	cCampo+= " campo.setAttribute('class', 'form-control input-block'); "        // set class attribute
	cCampo+= " campo.name = '"+aItens[nCol,2]+cItem+"'; "
	cCampo+= " campo.id = '"+aItens[nCol,2]+cItem+"'; "
	cCampo+= " campo.align = '"+aItens[nCol][4]+"';"

	cHtml:= cCampo

	Web Extended end

Return cHTML

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ ParcMinima   ¦ Autor ¦ Lucilene Mendes  	¦ Data ¦ 06.12.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Função para geração da linha da tabela de itens		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function ParcMinima()

	Local cHtml
	Local cCond	:= HttpPost->condPgto
	Local nValor:= Val(StrTran(StrTran(HttpPost->valor,'.',''),',','.'))
	Local nValMin:= 0
	Local cAVista := "" //condições de pagamento que não entram nesta regra, como pgto à vista
	Local aCond := {}

	Web Extended Init cHtml Start U_inSite()

	// TODO - Pedro 20210208 - Remover???
	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_PortalLogin.apw">'
		Return cHtml
	endif

	nValMin:= GetNewPar("AE_PMINFAT",500)
	cAVista:= GetNewPar("AE_PVSTFAT")
	If !cCond $ cAVista
		aCond:= Condicao(nValor,cCond,0,dDataBase,0)
	Endif
	cHtml:= cValtoChar(nValMin)+'|'+Iif(Len(aCond)>0,cValtoChar(aCond[1,2]),cValtoChar(nValMin+1))

	Web Extended end

Return cHTML



/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ VerSessao   ¦ Autor ¦ Lucilene Mendes  	¦ Data ¦ 27.04.18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Verifica se a sessão está ativa						      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function VerSessao()
	Local cHtml:= "ok"

	Web Extended Init cHtml
	If Valtype(HttpSession->CodVend) <> "C"
		cHtml:= "nok"
	Endif
	Web Extended end

Return cHtml



/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetCondPgto 	¦ Autor ¦ Lucilene Mendes   ¦ Data ¦ 01.07.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Função utilizada no Ajax pra retornar a cond de pagamento  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function GetCondPgto()
	Local cHtml
	Local lCartao 	:= .F.
	Local lAVista 	:= .F.
	Local lBoleto   := .F.
	Local lDeposito	:= .F.
	Local cModali	:= Alltrim(HttpPost->modali)
	Local cCondPg	:= ""
	Local cCondAV	:= ""

	Web Extended Init cHtml Start U_inSite()

	// TODO - Pedro 20210208 - Remover???
	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_PortalLogin.apw">'
		Return cHtml
	endif
	//Verifica se a condição é cartão
	If cModali $ GetNewPar("AA_MODALCC","005")
		lCartao := .T.
	Endif
	If cModali $ GetNewPar("AA_MODALAV","002/004/006")
		lAVista := .T.
	Endif
	If cModali = "001"
		lBoleto := .T.
	Endif
	If cModali = "002"
		lDeposito := .T.
	Endif
	cCondAV:= GetNewPar("AA_CONDAV","001") //Separar condições com vírgula. 001,002,003.

	//Seleciona as condições de pagamento disponíveis no combo
	cQry:= " Select E4_CODIGO, E4_DESCRI"
	cQry+= " From "+RetSqlName("SE4")+" SE4 "
	cQry+= " Where E4_FILIAL = '"+xFilial("SE4")+"' "
	cQry+= " And E4_XPORTAL = '1' "
	If lDeposito
		cQry+= " And E4_CODIGO IN "+FormatIn(cCondAV,",")+" "
	Endif
	/*
	If lCartao
		cQry+= " And E4_XCC = '1' "
	Elseif lAVista
		If cModali = '006' //CARTÃO DEBITO
			cQry+= " And E4_CODIGO IN ('633' ) "
		Else
			cQry+= " And E4_CODIGO IN ('001','563' ) "
		Endif
	Else
		cQry+= " And E4_XCC <> '1' "
	Endif
	*/
	cQry+= " And E4_MSBLQL <> '1' "
	cQry+= " And SE4.D_E_L_E_T_ = ' ' "

	If Select("QRT") > 0
		QRT->(dbCloseArea())
	Endif
	APWExOpenQuery(ChangeQuery(cQry),'QRT',.T.)

//Preenche o select da tabela
	cCondPg+='	<option value=""></option>'
	While QRT->(!Eof())
		if (lBoleto .and. QRT->E4_CODIGO $ cCondAV)
			QRT->(dbSkip())
			loop
		Endif
		cCondPg+='	<option value="'+Alltrim(QRT->E4_CODIGO)+'">'+Alltrim(QRT->E4_CODIGO)+" - "+Alltrim(QRT->E4_DESCRI)+'</option>'
		QRT->(dbSkip())
	End

	cHtml:= cCondPg

	Web Extended end

Return cHtml

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetOperadora	¦ Autor ¦ Lucilene Mendes   ¦ Data ¦ 02.07.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Função utilizada no Ajax pra retornar a operadora		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function GetOperadora()
	Local cHtml
	Local cModali	:= Alltrim(HttpPost->modali)
	Local cOperad	:= ""

	Web Extended Init cHtml Start U_inSite()

	// TODO - Pedro 20210208 - Remover???
	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_PortalLogin.apw">'
		Return cHtml
	endif

	//Seleciona as operadoras   SAE-- BANDEIRA / ZYD -- METODO / SX5 -- MODALIDADE
	cQry:= " Select AE_CODCLI, A1_NREDUZ"
	cQry+= " From "+RetSqlName("SA1")+" SA1, "+RetSqlName("SAE")+" SAE, "+RetSqlName("SX5")+" SX5 "
	cQry+= " Where AE_CODCLI = A1_COD "
	cQry+= " And X5_TABELA = 'ZE' AND X5_CHAVE = '"+cModali+"' "
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
	cOperad+='	<option value=""></option>'
	While QRO->(!Eof())
		cOperad+='	<option value="'+Alltrim(QRO->AE_CODCLI)+'">'+Alltrim(QRO->A1_NREDUZ)+'</option>'
		QRO->(dbSkip())
	End

	cHtml:= cOperad

	Web Extended end

Return cHtml


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetBandeira	¦ Autor ¦ Lucilene Mendes   ¦ Data ¦ 03.07.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Função utilizada no Ajax pra retornar as bandeiras		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function GetBandeira()
	Local cHtml
	Local cModali	:= Alltrim(HttpPost->modalidade)
	Local cOperad	:= Alltrim(HttpPost->operadora)
	Local cBandeiras:= ""

	Web Extended Init cHtml Start U_inSite()

	// TODO - Pedro 20210208 - Remover???
	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_PortalLogin.apw">'
		Return cHtml
	endif

	//Seleciona as operadoras   SAE-- BANDEIRA / ZYD -- METODO / SX5 -- MODALIDADE
	cQry:= " Select ZYD_METODO, AE_DESC"
	cQry+= " From "+RetSqlName("ZYD")+" ZYD, "+RetSqlName("SAE")+" SAE, "+RetSqlName("SX5")+" SX5 "
	cQry+= " Where AE_CODCLI = '"+cOperad+"' "
	cQry+= " And AE_COD = ZYD_ADMFIN "
	cQry+= " And X5_TABELA = 'ZE' AND X5_CHAVE = '"+cModali+"' "
	cQry+= " And AE_TIPO = X5_DESCENG "
	cQry+= " And AE_FILIAL = '"+xFilial("SA3")+"' "
	cQry+= " And ZYD_FILIAL = '"+xFilial("ZYD")+"' "
	cQry+= " And X5_FILIAL = '"+xFilial("SX5")+"' "
	cQry+= " And SAE.D_E_L_E_T_ = '' "
	cQry+= " And ZYD.D_E_L_E_T_ = '' "
	cQry+= " And SX5.D_E_L_E_T_ = '' "

	If Select("QRB") > 0
		QRB->(dbCloseArea())
	Endif
	APWExOpenQuery(ChangeQuery(cQry),'QRB',.T.)

	//Preenche o select da tabela
	While QRB->(!Eof())
		cBandeiras+='	<option value="'+Alltrim(QRB->ZYD_METODO)+'">'+Alltrim(QRB->AE_DESC)+'</option>'
		QRB->(dbSkip())
	End

	cHtml:= cBandeiras

	Web Extended end

Return cHtml

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetEstDisp	¦ Autor ¦ Lucilene Mendes   ¦ Data ¦ 04.07.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Função utilizada no Ajax pra retornar o estoque disponível ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
//Estoque disponível: saldo do produto – empenhos – quantidade pedido de venda – quantidade orçamentos Firmes e não efetivados.
User Function GetEstDisp()
	Local cHtml
	Local cProduto	:= Alltrim(HttpPost->produto)
	Local nQuant	:= Val(HttpPost->quantidade)
	Local lImport   := If(Alltrim(HttpPost->importadora) = "1",.T.,.F.) //Busca o estoque da filial importadora
	Local cVend	 	:= HttpSession->CodVend
	Local cImportad	:= ""
	Local cNArmazem	:= ""
	Local lVldEstoq := .T.

	Web Extended Init cHtml Start U_inSite()

	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_PortalLogin.apw">'
		Return cHtml
	endif

	lVldEstoq:= GetNewPar("AA_VLDESTQ",.F.)

	If !lVldEstoq
		Return '9999999'
	Endif

	//Armazéns considerados para busca do estoque
	cNArmazem:= GetNewPar("AA_NLOCALP","'01','03','GE','02','04','05'") //deve estar no formato '01','02'
	SZ1->(dbSetOrder(3))
	If SZ1->(dbSeek(xFilial("SZ1")+Padr(cVend,TamSX3("A3_COD")[1],"")+'GE'))
		cNArmazem+= ",'GE'"
	Endif

	cImportad:= GetNewPar("AA_FILIMP","010101")

	//Busca o saldo do produto
    /*
    cQry:= "Select SUM(B2_QATU) - SUM(B2_QEMP) - SUM(B2_QPEDVEN)  - SUM(ISNULL(CK_QTDVEN,0)) SALDO "
	cQry+= "From "+RetSqlName("SB2")+" SB2 "
	cQry+= "Left Join "+RetSqlName("SCJ")+" SCJ on CJ_FILIAL = B2_FILIAL AND CJ_XTPORC = '1' AND CJ_STATUS = 'A' AND SCJ.D_E_L_E_T_ = ' ' "
	cQry+= "Left Join "+RetSqlName("SCK")+" SCK on CK_FILIAL = CJ_FILIAL AND CK_NUM = CJ_NUM AND CK_PRODUTO = B2_COD and SCK.D_E_L_E_T_ = ' ' "
	If !Empty(cNArmazem)
		cQry+= "AND CK_LOCAL not in ("+cNArmazem+") " 
	Endif
	cQry+= "Where B2_FILIAL = '"+Iif(lImport,cImportad,xFilial("SB2"))+"' "
	cQry+= "And B2_COD = '"+cProduto+"' "
	If !Empty(cNArmazem)
		cQry+= "AND B2_LOCAL not in ("+cNArmazem+") " 
	Endif
	cQry+= "And SB2.D_E_L_E_T_ = ' ' "  
     */


	cQry:= "With QRY AS( "
//	cQry+= "Select SUM(B2_QATU) EST , SUM(B2_QEMP) + SUM(B2_RESERVA) + SUM(B2_QPEDVEN) EMPENHO " //adicionado reserva 07.02.20 - Lucilene
	cQry+= "Select SUM(B2_QATU) EST , SUM(CASE WHEN B2_QEMP >= 0 THEN B2_QEMP ELSE 0 END) + SUM(CASE WHEN B2_RESERVA >= 0 THEN B2_RESERVA ELSE 0 END) + SUM(CASE WHEN B2_QPEDVEN >= 0 THEN B2_QPEDVEN ELSE 0 END) EMPENHO " //adicionado reserva 07.02.20 - Lucilene
	cQry+= "From "+RetSqlName("SB2")+" SB2 "
	cQry+= "Where B2_FILIAL = '"+Iif(lImport,cImportad,xFilial("SB2"))+"' And B2_COD = '"+cProduto+"' And SB2.D_E_L_E_T_ = ' ' "
	If !Empty(cNArmazem)
		cQry+= "AND B2_LOCAL in ("+cNArmazem+") "
	Endif
	cQry+= "UNION ALL "
	cQry+= "Select 0 EST , SUM(CK_QTDVEN) EMPENHO "
	cQry+= "From "+RetSqlName("SCJ")+" SCJ, "+RetSqlName("SCK")+" SCK "
	cQry+= "Where CJ_FILIAL =  '"+Iif(lImport,cImportad,xFilial("SB2"))+"'  AND CJ_XTPORC = '1' AND CJ_STATUS = 'A' AND SCJ.D_E_L_E_T_ = ' ' "
	cQry+= "and CK_FILIAL = CJ_FILIAL AND CK_NUM = CJ_NUM AND CK_PRODUTO = '"+cProduto+"' and SCK.D_E_L_E_T_ = ' ' "
	If !Empty(cNArmazem)
		cQry+= "AND CK_LOCAL in ("+cNArmazem+") "
	Endif
	cQry+= ")"
	cQry+= "SELECT SUM(EST) -SUM(EMPENHO) SALDO FROM QRY "

	If Select("QRS") > 0
		QRS->(dbCloseArea())
	Endif
	APWExOpenQuery(cQry,'QRS',.T.)
	conout(cQry)
	cHtml:= cValtoChar(QRS->SALDO)

	Web Extended end

Return cHtml

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetListEstDisp¦ Autor ¦ Ewerton Vinicius  ¦ Data ¦ 02.07.23 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Função utilizada no Ajax pra retornar o estoque disponível ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
//Estoque disponível: saldo do produto – empenhos – quantidade pedido de venda – quantidade orçamentos Firmes e não efetivados.
User Function GetListEstDisp()
	Local cHtml
	local cItens := HttpPost->aItens
	Local nPosLin	:= 0
	local x := 0
	local x1 := 0
	local nIt := 0
	Local nQtde:= 0
	Local nSaldo:= 0
	Local nValor:= 0
	Local nTotal:= 0
	local aSemEst := {}
	local aItens := {}
	local cProd :=""
	local cMsg :=""

	Web Extended Init cHtml Start U_inSite()

	cVendLogin := u_GetUsrPR()
	cCodLogin  := U_SetParPR(cVendLogin)


	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_PortalLogin.apw">'
		Return cHtml:= 'erro: sessão encerrada'
	endif

	nTotSck := val(HttpPost->PROXIMO)

	For x:= 1 to nTotSck
		nPosLin:= At("||",cItens)-1
		If nPosLin > 0
			aLinha:= Separa(Substr(cItens,1,nPosLin),";")
			cItens:= Substr(cItens,nPosLin+3)
			If Len(aLinha) > 0
				aAdd(aItens,aLinha)
			Endif
		Endif
		aLinha:= {}
	Next


	For x1:= 1 to len(aItens)
		cProd := Alltrim(aItens[x1][1])+" - "+Posicione("SB1",1,xFilial("SB1")+aItens[x1][1],"B1_DESC")
		nQtde := aItens[x1][2]
		nValor := aItens[x1][3]
 		nSaldo := u_verEstoque(aItens[x1][1])
		
		If nSaldo < nQtde
			aAdd(aSemEst,{cProd,nQtde,nValor,aItens[x1][4]})
			nTotal += val(StrTran(StrTran(aItens[x1][4],".",""),",",".")) 
		Endif
	Next

	If Len(aSemEst) > 0

		cMsg+='<h5>Os produtos abaixo n&atildeo possuem saldo dispon&iacute;vel:<h5>'
		cMsg+= '<table class="table table-bordered table-striped table-condensed mb-none" id="titulosAtraso">'+CHR(13)+CHR(10)
		cMsg+= "	<thead>"+CHR(13)+CHR(10)
		cMsg+= "		<tr>"+CHR(13)+CHR(10)
		cMsg+= "			<th>Produto</th>"+CHR(13)+CHR(10)
		cMsg+= "			<th>Quantidade</th>"+CHR(13)+CHR(10)
		cMsg+= "			<th>Valor</th>"+CHR(13)+CHR(10)
		cMsg+= "			<th>Total</th>"+CHR(13)+CHR(10)
		cMsg+= "		</tr>"+CHR(13)+CHR(10)
		cMsg+= "	</thead>"+CHR(13)+CHR(10)
		cMsg+= "	<tbody>"+CHR(13)+CHR(10)
				
		for nIt := 1 to len(aSemEst)
			cMsg+= "	<tr>
			cMsg+= "		<td>"+aSemEst[nIt,1]+"</td>"
			cMsg+= "		<td>"+aSemEst[nIt,2]+"</td>"	
			cMsg+= "		<td>"+aSemEst[nIt,3]+"</td>"	
			cMsg+= "		<td>"+aSemEst[nIt,4]+"</td>"	
			cMsg+= "	</tr>"
		next									
		cMsg+="		</tbody>"+CHR(13)+CHR(10)
		cMsg+="</table>"+CHR(13)+CHR(10)
		cMsg+="<br>"+CHR(13)+CHR(10)
		cMsg+="<br>"+CHR(13)+CHR(10)
		cMsg+="<h5>Total do Or&ccedilamento: "+Transform(nTotal,PesqPict("SCK","CK_VALOR"))+'</h5>'+CHR(13)+CHR(10)

	Else
		cMsg:= "OK"
	Endif

	cHtml := cMsg

	Web Extended end

Return cHtml

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ verEstoque		¦ Autor ¦ Ewerton Vinicius¦Data ¦ 06.07.23¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Função utilizada no Ajax pra retornar o limite disponível  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function verEstoque(prod)
	Local cHtml
	Local cProduto	:= prod
	Local cNArmazem	:= ""

	//Armazéns considerados para busca do estoque
	cNArmazem:= GetNewPar("AA_NLOCALP","'01','03','GE','02','04','05'") //deve estar no formato '01','02'

	cQry:= "With QRY AS( "
	cQry+= "Select SUM(B2_QATU) EST , SUM(CASE WHEN B2_QEMP >= 0 THEN B2_QEMP ELSE 0 END) + SUM(CASE WHEN B2_RESERVA >= 0 THEN B2_RESERVA ELSE 0 END) + SUM(CASE WHEN B2_QPEDVEN >= 0 THEN B2_QPEDVEN ELSE 0 END) EMPENHO " //adicionado reserva 07.02.20 - Lucilene
	cQry+= "From "+RetSqlName("SB2")+" SB2 "
	cQry+= "Where B2_FILIAL = '"+xFilial("SB2")+"' And B2_COD = '"+cProduto+"' And SB2.D_E_L_E_T_ = ' ' "
	If !Empty(cNArmazem)
		cQry+= "AND B2_LOCAL in ("+cNArmazem+") "
	Endif
	cQry+= "UNION ALL "
	cQry+= "Select 0 EST , SUM(CK_QTDVEN) EMPENHO "
	cQry+= "From "+RetSqlName("SCJ")+" SCJ, "+RetSqlName("SCK")+" SCK "
	cQry+= "Where CJ_FILIAL =  '"+xFilial("SB2")+"'  AND CJ_XTPORC = '1' AND CJ_STATUS = 'A' AND SCJ.D_E_L_E_T_ = ' ' "
	cQry+= "and CK_FILIAL = CJ_FILIAL AND CK_NUM = CJ_NUM AND CK_PRODUTO = '"+cProduto+"' and SCK.D_E_L_E_T_ = ' ' "
	If !Empty(cNArmazem)
		cQry+= "AND CK_LOCAL in ("+cNArmazem+") "
	Endif
	cQry+= ")"
	cQry+= "SELECT SUM(EST) -SUM(EMPENHO) SALDO FROM QRY "

	If Select("QRS") > 0
		QRS->(dbCloseArea())
	Endif
	APWExOpenQuery(cQry,'QRS',.T.)
	conout(cQry)
	cHtml:= cValtoChar(QRS->SALDO)

Return cHtml


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetLimCred	¦ Autor ¦ Lucilene Mendes   ¦ Data ¦ 04.07.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Função utilizada no Ajax pra retornar o limite disponível  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function GetLimCred()
	Local cHtml
	Local cCliente	:= Alltrim(HttpPost->cliente)
	Local nTotal	:= Val(HttpPost->valor)
	Local nSaldo	:= 0
	Local nToler	:= 0

	Web Extended Init cHtml Start U_inSite()

	// TODO - Pedro 20210208 - Remover???
	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_PortalLogin.apw">'
		Return cHtml
	endif
	//Posiciona no cliente
	dbSelectArea("SA1")
	SA1->(dbSeek(xFilial("SA1")+cCliente))

	//Busca valor em pedidos liberados
	cQry:= "SELECT SUM(C6_VALOR) TOTAL FROM "+RetSqlName("SC6")+" SC6 "
	cQry+= "INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = C6_FILIAL AND C5_NUM  = C6_NUM AND C5_CLIENT = C6_CLI "
	cQry+= "AND C5_LOJACLI = C6_LOJA AND C5_LIBEROK = 'S' AND C5_NOTA = ' ' AND SC5.D_E_L_E_T_ = ' ' "
	cQry+= "WHERE C6_CLI = '"+SA1->A1_COD+"' AND C6_LOJA = '"+SA1->A1_LOJA+"' "
	cQry+= "AND NOT EXISTS (SELECT * FROM "+RetSqlName("SC9")+" SC9 WHERE C9_FILIAL = C5_FILIAL AND C9_PEDIDO = C5_NUM AND C9_BLCRED NOT IN (' ','10') "
	cQry+= "AND SC9.D_E_L_E_T_ = ' ') "
	cQry+= "AND SC6.D_E_L_E_T_ = ' ' "

	If Select("QRL") > 0
		QRL->(dbCloseArea())
	Endif
	APWExOpenQuery(cQry,'QRL',.T.)

	nSaldo:= SA1->A1_LC - (SA1->A1_SALDUP + QRL->TOTAL)
	nToler:= nSaldo * GetNewPar("AA_TOLERLC",1)/100 //Tolerancia de 1%
	//nSaldo:= nSaldo + nToler

	cHtml:= cValtochar(nSaldo)+"|"+cValtochar(nToler) //Alltrim(Transform(nSaldo,"@E 999,999,999,999.99"))
	Web Extended end

Return cHtml

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ DescVista	¦ Autor ¦ Lucilene Mendes   ¦ Data ¦ 21.08.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Verifica se a condição de pagamento tem desconto à vista   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function DescVista()
	Local cHtml
	Local cCondicao	:= Alltrim(HttpPost->condicao)

	Web Extended Init cHtml Start U_inSite()
	cHtml:= cValtoChar(Posicione("SE4",1,xFilial("SE4")+cCondicao,"E4_DESCPED"))
	Web Extended end

Return cHtml



/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ AcresCond	¦ Autor ¦ Lucilene Mendes   ¦ Data ¦ 23.08.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Verifica se a condição de pagamento tem acrescimo		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function AcresCond()
	Local cHtml
	Local cCondicao	:= Alltrim(HttpPost->condicao)
	Local nValMin	:= 0
	Local nPerJur	:= 0
	Web Extended Init cHtml Start U_inSite()

	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_PortalLogin.apw">'
		Return cHtml
	endif

	nValMin:= Posicione("SE4",1,xFilial("SE4")+cCondicao,"E4_XVALMIN")
	nPerJur:= SE4->E4_XPERJUR
		

	cHtml:=  cvaltochar(nValMin)+'|'+ cValtoChar(nPerJur)

	Web Extended end

Return cHtml

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ OrcImport	¦ Autor ¦ Lucilene Mendes   ¦ Data ¦ 11.07.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Gera o orçamento na importadora							  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/	
User Function OrcImport(cFilImp, nOpc, aCabOri, aItensOri, cCNPJ, cFilOri, cNumOri, cOrcDest)

	Local aSrvTabelas	:={"SCJ","SCK","SA1"} //Tabelas a serem abertas
	Local aCab			:= {}
	Local aItens		:= {}
	Local aLinha		:= {}
	Local cTabImport	:= ""
	Local cCondPag		:= ""
	Local cTesImport	:= ""
	Local xConteudo		:= ""
	Local cEmail		:= ""
	Local cDirErro  	:= "erro\"
	Local i				:= 0
	Local y				:= 0
	Local nPos			:= 0
	Local aCposCab		:= {"CJ_NUM","CJ_CLIENTE","CJ_LOJA","CJ_LOJAENT","CJ_CONDPAG","CJ_TABELA","CJ_XTPORC","CJ_XIMPORT","CJ_XORCIMP","CJ_XLINHA"}
	Local aCposItm		:= {"CK_ITEM","CK_PRODUTO","CK_LOCAL","CK_QTDVEN","CK_PRCVEN","CK_TES","CK_ENTREG"}
	Local lRet			:= .T.
	Private lMsErroAuto	:= .F.


//Loga na filial importadora

	RpcClearEnv()
	RPCSetType(3) //Nao consome licença
	If !RPCSETENV("01", cFilImp, , , "SIGAFAT", , aSrvTabelas)
		conout("Falha ao logar na filial "+cFilImp)
		lRet:= .F.
	Else

		//Altera os campos para a importadora
		cTabImport:= GetNewPar("AA_TABIMP","")
		cCondPag:= GetNewPar("AA_CONDIMP","001")
		cTesImport:= GetNewPar("AA_TESIMP","528")
		cEmail:= GetNewPar("AA_MAILIMP","lucilene@smsti.com.br")

		//Atualiza os dados do cabeçalho
		For i:= 1 to Len(aCabOri)
			nPos:= aScan(aCposCab,{|x| AllTrim(x)==aCabOri[i,1]})
			If nPos > 0
				xConteudo:= aCabOri[i,2]
				If !Empty(cOrcDest) .and. nOpc > 3
					If aCabOri[i,1] = "CJ_NUM"
						xConteudo:= Right(Alltrim(cOrcDest),6)
					Endif
				Endif
				If aCabOri[i,1] = "CJ_TABELA"
					xConteudo:= Iif(!Empty(SA1->A1_TABELA),SA1->A1_TABELA,cTabImport)
				Elseif aCabOri[i,1] = "CJ_CLIENTE"
					xConteudo:= Posicione("SA1",3,xFilial("SA1")+cCnpj,"A1_COD")
				Elseif aCabOri[i,1] $ "CJ_LOJA|CJ_LOJAENT"
					xConteudo:= SA1->A1_LOJA
				Elseif aCabOri[i,1] = "CJ_CONDPAG"
					xConteudo:= cCondPag
				Endif

				aadd(aCab,{aCabOri[i,1],xConteudo,nil})

				If i = Len(aCabOri) .and. nOpc < 5
					aadd(aCab,{"CJ_XORCIMP",cFilOri+"/"+cNumOri,nil})
				Endif
			Endif
		Next

		//Atualiza os dados dos itens
		For i:= 1 to Len(aItensOri)
			aLinha:= {}
			For y:= 1 to Len(aItensOri[i])
				nPos:= aScan(aCposItm,{|x| AllTrim(x)==aItensOri[i,y,1]})
				If nPos > 0
					xConteudo:= aItensOri[i,y,2]

					If aItensOri[i,y,1] = "CK_PRODUTO"
						SB1->(dbSetOrder(1))
						SB1->(dbSeek(xFilial("SB1")+aItensOri[i,y,2]))
					Elseif aItensOri[i,y,1] = "CK_LOCAL"
						xConteudo:= SB1->B1_LOCPAD
					Elseif aItensOri[i,y,1] = "CK_PRCVEN"
						xConteudo:= Posicione("DA1",1,xFilial("DA1")+cTabImport+SB1->B1_COD,"DA1_PRCVEN")
					Elseif aItensOri[i,y,1] = "CK_TES"
						xConteudo:= cTesImport
					Endif
					aadd(aLinha,{aItensOri[i,y,1],xConteudo, nil})
				Endif
			Next
			aadd(aItens,aLinha)
		Next

		//Chama execauto para inclusão do orçamento
		If Len(aCab) > 0 .and. Iif(nOpc < 5,Len(aItens) > 0,.T.) .and. nOpc > 0
			lMsErroAuto:= .F.
			MATA415(aCab,aItens,nOpc)
		Else
			lRet:= .F.
			conout(Procname()+"("+ltrim(str(procline()))+") *** Portal "+"FALHA AO "+Iif(nOpc=3,'INCLUIR','ALTERAR')+" O ORÇAMENTO DA IMPORTADORA!")
		Endif

		If lMsErroAuto
			lRet:= .F.
			If !ExistDir(cDirErro)
				MakeDir(cDirErro)
			Endif

			cDirErro+=dtos(date())
			If !ExistDir(cDirErro)
				MakeDir(cDirErro)
			Endif
			//Grava o erro
			MostraErro(cDirErro,"erro_orcto_imp_"+strtran(time(),":","")+".txt")
		Else
			If nOpc <> 5
				//Atualiza o orçamento original com o orçamento gerado na importadora
				cQry:= "Update "+RetSqlName("SCJ")
				cQry+= " Set CJ_XORCIMP = '"+SCJ->CJ_FILIAL+"/"+SCJ->CJ_NUM+"' "
				cQry+= "Where CJ_FILIAL = '"+cFilOri+"' "
				cQry+= "And CJ_NUM = '"+cNumOri+"' "
				cQry+= "And D_E_L_E_T_ = ' ' "
				TCSqlExec(cQry)
			Endif
		EndIf

		//Função envio de email - Cód.User,Mensagem, Tabela itens
		cTipo:= "ORÇAMENTO IMPORTADORA"
		cAssunto:= "Orçamento Importadora - Origem "+cFilOri+"/"+cNumOri
		If lRet
			If nOpc = 3
				cMsg:= "Gerado"
			Elseif nOpc = 4
				cMsg:= "Atualizado"
			Elseif nOpc = 5
				cMsg:= "Excluído"
			Endif
			cMsg+= " o orçamento para a importadora."+chr(13)+chr(10)
			cMsg+= "Origem: "+cFilOri+"/"+cNumOri+chr(13)+chr(10)
			cMsg+= "Destino: "+cFilImp
		Else
			cMsg:= "Falha ao "
			If nOpc = 3
				cMsg+= "gerar"
			Elseif nOpc = 4
				cMsg+= "atualizar"
			Elseif nOpc = 5
				cMsg+= "excluir"
			Endif

			cMsg+= " o orçamento para a importadora."+chr(13)+chr(10)
			cMsg+= "Origem: "+cFilOri+"/"+cNumOri+chr(13)+chr(10)
		Endif
		u_MailCM(cTipo,{cEmail},{},cAssunto,cMsg,"","")
	Endif


Return

User Function DescRetira()
	Local cHtml
	Web Extended Init cHtml Start U_inSite()

	cHtml:=  GetNewPar("AA_TRARET", "000414")+'|'+cvaltochar(GetNewPar("AA_PERFRE", 1.5))

	Web Extended end

Return cHtml

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ lTabCartao	¦ Autor ¦ Lucilene Mendes   ¦ Data ¦ 30.10.20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Verifica se a tabela de preço é de cartão				  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function lTabCartao()
	Local cHtml := ""
	Local cTabela	:= Alltrim(HttpPost->tabela)
	Local lCartao	:= .F.
	Web Extended Init cHtml Start U_inSite()

	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_PortalLogin.apw">'
		Return cHtml
	endif

	//Verifica se a tabela é de cartão de crédito/débito
	//lCartao:= Posicione("DA0",1,xFilial("DA0")+cTabela,"DA0_XCARTA") = '1'

	//Seleciona as modalidades
	cQry:= " Select X5_CHAVE, X5_DESCRI"
	cQry+= " From "+RetSqlName("SX5")+" SX5 "
	cQry+= " Where X5_TABELA = 'ZE' "
	If lCartao
		cQry+= " And X5_DESCENG IN ('CC','CD') "
	Else
		cQry+= " And X5_DESCENG NOT IN ('CC','CD') "
		cQry+= " And X5_CHAVE IN ('001','002') "
	Endif
	cQry+= " And SX5.D_E_L_E_T_ = ' ' "
	If Select("QRM") > 0
		QRM->(dbCloseArea())
	Endif
	APWExOpenQuery(ChangeQuery(cQry),'QRM',.T.)

	cHtml+='	<option value=""></option>'

	While QRM->(!Eof())
		cHtml+='	<option value="'+Alltrim(QRM->X5_CHAVE)+'">'+Alltrim(QRM->X5_DESCRI)+'</option>'
		QRM->(dbSkip())
	End

	Web Extended end

Return cHtml





/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ InfGetAn    ¦ Autor ¦ Anderson Zelenski  ¦ Data ¦ 24.08.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Função para utilizar no Ajax pra retornar os anexos        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
/*
User Function InfGetAn()                                            
Local cHtml
Local cCotacao	:= ""
Local cFornece	:= ""
Local cLoja		:= ""
Local cDirCot	:= "anexosPortal\cotacoes\"

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

	cCotacao	:= HttpPost->cotacao
	cFornece	:= HttpPost->fornece
	cLoja		:= HttpPost->loja

	//Verifica se existem anexos
    cDirCot += cCotacao+'\'+cFornece+cLoja+'\' 
    cDirPortal := "../anexos/cotacoes/"+cCotacao+"/"+cFornece+cLoja+"/"
    
    aAnexos := DIRECTORY(cDirCot+"*.*","",,.T.) 
    
	If Len(aAnexos) > 0
		cHTML := U_GetAnexos(aAnexos,cDirPortal)
	Else
		cHTML := "Sem Anexos para essa cotação."
	EndIf
			
Web Extended End

Return (cHTML) 
Static Function NewDlg1()
/*
A tag abaixo define a criação e ativação do novo diálogo. Você pode colocar esta tag
onde quer que deseje em seu código fonte. A linha exata onde esta tag se encontra, definirá
quando o diálogo será exibido ao usuário.
Nota: Todos os objetos definidos no diálogo serão declarados como Local no escopo da
função onde a tag se encontra no código fonte.
*/

Return


