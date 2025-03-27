#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
#DEFINE SMSDEBUG
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ AddOPed      ¦ Autor ¦ Matheus Bientinezi ¦ Data ¦10.12.2023¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦            	
¦¦¦Descriçäo ¦ Inclusão de Pedido	 de Venda.							  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function AddPed()
local cHtml
local nLin			:= 0
local f				:= 0

private cItem 		:= ""
private cFFNome		:= ""
private cFilFat		:= ""
private cTrade		:= ""
private cTradeBase	:= ""
private cAplicacao	:= ""
private cOrcCabec	:= ""
private cOrcItens	:= ""
private cItensHid	:= ""
private cBotoes		:= ""
private cCliente	:= ""
private cTabela		:= ""
private cBtnItens	:= ""
private cObsInterna	:= ""
private cObsNota	:= ""
private cCodLogin 	:= ""
private cVendLogin	:= ""
private cMenus	  	:= ""
private cSite		:= "u_PortalLogin.apw"
private cPagina		:= "Pedido de Venda"
private cTitle	  	:= "Portal SMS"
private nItens		:= 0
private lMoeda		:= .F.
private lNumber		:= .F.
private lNewOrc		:= .T.
private lEdit		:= .T.
private aItens	  	:= {}
Private nTVlrUnit	:= 0
Private nTQtdItem   := 0
Private nTTotal		:= 0
Private cOptProd	:= ""
Private cOptCond	:= ""
Private cOptModal	:= ""

Web Extended Init cHtml Start U_inSite()
 
	cVendLogin := u_GetUsrPR()
	cCodLogin  := U_SetParPR(cVendLogin)

	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL='+cSite+'">'	
		Return cHtml
	Endif
		
	// Pega do parâmetro com o Titulo do Portal
	cTitle := "Portal SMS"
	// Define a funcao a ser chama no link
	cSite	:= Procname()+".apw?PR="+cCodLogin
	// Monta o cabeçalho para a pagina
	cHeader := U_PSHeader(cTitle, cSite) 		
	//Função que atualiza os menus
	cMenus := U_GetMenus(AllTrim(Upper(Procname())), cVendLogin)
		
	//Atualiza as variáveis
	cCodVend:=cVendLogin
	cNomeVend:= HttpSession->Nome

	cFFNome := cvaltochar(HttpSession->Filial) + " - " + cvaltochar(FWFilialName(SM0->M0_CODIGO,HttpSession->Filial,2))

	cItem := StrZero(1,TamSX3("C6_ITEM")[1])
	
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
	aItens := {	{"Item","C6_ITEM","*","text-left","C",.F.,.F.,.F.,"",.F.,""},;  
				{"Produto","C6_PRODUTO","280px","text-left","C",.T.,.T.,.F.,"Selecione...",.F.,""},;
				{"Un. Medida","C6_UM","*","text-right","C",.F.,.T.,.F.,"",.F.,""},;
				{"Quantidade","C6_QTDVEN","*","text-right","N",.T.,.T.,.F.,"0",.F.,""},;
				{"V. Tabela","C6_PRCVEN","*","text-right","N",.F.,.F.,.T.,"0,00",.F.,""},;
				{"Total","C6_VALOR","100px","text-right","N",.F.,.F.,.T.,"0,00",.F.,""},;
				{"Desconto (%)","C6_DESCONT","*","text-right","N",.T.,.F.,.F.,"0",.F.,""},;
				{"Qtd. Bônus","C6_BONUS","*","text-right","N",.T.,.T.,.F.,"0",.F.,""},;
				{"Ord. Compra","C6_PEDCLI","*","text-right","C",.T.,.T.,.F.,"",.F.,""},;
				{"","ACAO","*","text-center","X",.F.,.F.,.F.,"",.F.,""}};
		
	// Cria o cabeçalho dos Itens
	For nLin := 1 to Len(aItens)
		cOrcCabec += '<th'+Iif(aItens[nLin,2] == "C6_VALOR",' width="'+aItens[nLin,3]+'"',Iif(aItens[nLin,2] == "C6_PRODUTO",' width="'+aItens[nLin,3]+'"',''))
		cOrcCabec+= Iif(aItens[nLin,10],' hidden','')+'>'+aItens[nLin][1]+'</th>'
	Next 

	//FILIAL FATURAMENTO ======================================
	cFilFat:='<input class="form-control" type="text" id="C5_FILFAT" name="C5_FILFAT" value="'+alltrim(cFFNome)+'" disabled> '

	// CLIENTES ====================================
	cQuery := " Select A1_COD, A1_LOJA, A1_CGC, A1_NOME, A1_BAIRRO, A1_END, A1_MUN, A1_EST, A1_DDD, A1_TEL, A1_COND "
	cQuery += " From "+RetSqlName("SA1")+" SA1 "
	cQuery += " Where SA1.A1_VEND = '"+cVendLogin+"' "
	cQuery +="  AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' "
	cQuery += " AND A1_MSBLQL <> '1' "
	cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
	cQuery += " Order by SA1.A1_NOME "
	
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	Endif	 	
	APWExOpenQuery(ChangeQuery(cQuery),'QRY',.T.)

	dbSelectArea("QRY")
	cCliente:='<select data-plugin-selectTwo class="form-control populate placeholder" data-plugin-options='+"'"
	cCliente+='{ "placeholder": "Selecione um Cliente", "allowClear": false }'+"'"+' name="C5_CLIENTE" id="C5_CLIENTE" '
	cCliente+='onchange="javascript:buscaDadosCli(this.value)" required="" aria-required="true"> '
	cCliente+=' <option value=""> </option>'
	While !QRY->(EOF())
		cCliente+='	<option value="'+Alltrim(QRY->A1_COD+QRY->A1_LOJA)+'">'+QRY->A1_COD+'/'+QRY->A1_LOJA+' - '+Alltrim(QRY->A1_NOME)+ ' - '+ Alltrim(QRY->A1_CGC) +' - '+ alltrim(QRY->A1_EST)+'</option>'
		QRY->(dbSkip())
	End	
	cCliente+='</select>'
	APWExCloseQuery('QRY')

	//TABELA DE PREÇO ======================================
	cTabela:='<input class="form-control" type="text" id="C5_TABELA" name="C5_TABELA" value="" disabled> '

	//CONDIÇÕES PAGAMENTO =====================================
	cCondPag:='<input class="form-control" type="text" id="C5_CONDPAG" name="C5_CONDPAG" value="" disabled> '

	//Percentual Trade ======================================
	cTrade:='<input class="form-control" type="text" onchange="javascript:validaTrade(this.value), validaAplicacao(), TotalGeral() " id="C5_XTRADE" name="C5_XTRADE" value="0"> '

	//Percentual Trade ======================================
	cTradeBase:='<input class="form-control" type="hidden"  id="C5_XTRADEBASE" name="C5_XTRADEBASE" value="0"> '

	//Aplicacao =================================================
	aApli:= {{"BO","Boleto"},{"NF","Nota Fiscal"},{"CC","Conta Corrente"}}
	cAplicacao:='<select data-plugin-selectTwo class="form-control poulate mb-md" data-plugin-options='+"'"+'{"minimumResultsForSearch": "-1"}'+"'"'
	cAplicacao+=' name="C5_XAPLIC" id="C5_XAPLIC" onchange="javascript:validaAplicacao(), atualizaMsgNota()">'
	For f:= 1 to Len(aApli)
		cAplicacao+='	<option value="'+aApli[f,1]+'">'+aApli[f,2]+'</option>'
	Next
	cAplicacao+='</select>' 
	
	//ITENS ================================================
	nItens++
	cOrcItens += '<tr class="odd" id="linha01">'
	For nLin := 1 to Len(aItens)
		If aItens[nLin,2] == "ACAO"
			cOrcItens += '<td class="actions">' 
			cOrcItens += '	<i class="fa fa-info fa-lg" data-toggle="tooltip" data-original-title="Detalhes da linha" onclick="detalheOrc('+"'"+cItem+"'"+');"></i>'
			cOrcItens += '  <i class="fa fa-times-circle fa-lg" data-toggle="tooltip" data-original-title="Remover a linha" onclick="removeItem('+"'"+cItem+"'"+');"></i> 
			cOrcItens += '</td>
		Else	
			cOrcItens += '<td'+Iif(aItens[nLin,10],' hidden','')+'>'
			lMoeda:= aItens[nLin,8] //Indica se é Moeda
			lNumber:= aItens[nLin,5] = "N" //Indica que é numérico
			xValue:= ""
			Do Case
				Case aItens[nLin][5] == 'C' 
					If aItens[nLin,2] == "C6_ITEM"
						xValue := "01"
					Else	
						xValue := Iif(lNewOrc,space(TamSX3(aItens[nLin][2])[1]),AllTrim(QRY->&(aItens[nLin][2])))
					Endif
			EndCase  
		   
			If aItens[nLin,6] //Campo Editável
				If aItens[nLin,2] == "C6_PRODUTO"
				   //Cria o select para o produto
				   	cOrcItens +='<select class="selectpicker" name="C6_PRODUTO'+cItem+'" id="C6_PRODUTO'+cItem+'" '
					cOrcItens += Iif(aItens[nLin][7],'required="" aria-required="true" ','')+' data-live-search="true" '                                           
					cOrcItens +='onchange="javascript:gatProduto($(this))" data-width="280px" value="">' //style="size:4" data-width="90%" style="height:90%"
					cOrcItens +='	<option value="">Selecione...</option>'
					cOrcItens+='</select>'
				Else
					cOrcItens += '<input id="'+aItens[nLin][2]+cItem+'" data-prop="'+aItens[nLin][2]+'" name="'+aItens[nLin][2]+cItem+'" class="form-control '+aItens[nLin,4] 
					cOrcItens +=If(lMoeda," ",If(lNumber," only-numbers",""))+'" type="text" '
				 	cOrcItens += 'placeholder="'+aItens[nLin,9]+'" '
				 	If aItens[nLin,2] == "C6_QTDVEN"
				 		cOrcItens+='onchange="javascript:VldQtd('+"'"+cItem+"'"+') "'
				 		cOrcItens+=' onkeydown="return onlynum(event);" '
				 	Endif

					If aItens[nLin,2] == "C6_DESCONT"
				 		cOrcItens+=' onkeydown="return onlynum(event);" '
				 	Endif
				 					 	
				 	If aItens[nLin,2] $ ("C6_QTDVEN|C6_PRCVEN|C6_DESCONT") 
				 		cOrcItens+='onchange="javascript:TotalItem('+"'"+cItem+"'"+') "'
				 	Endif	
				 	//Campo obrigatório
					cOrcItens += Iif(aItens[nLin][7],'required="" aria-required="true" ','')
					//Inicia todos os campos desabilitados
					If aItens[nLin,2] == "C6_PEDCLI" 
						cOrcItens+='onchange="javascript:atualizaOC(this) "'
					endif
					If aItens[nLin,2] <> ("C6_PEDCLI") 
						cOrcItens += 'disabled '
						cOrcItens += 'value="'+Alltrim(xValue)+'">'
					endif
			    Endif
			Else
				cOrcItens += '<input id="'+aItens[nLin][2]+cItem+'" data-prop="'+aItens[nLin][2]+'" name="'+aItens[nLin][2]+cItem+'" class="form-control '+aItens[nLin,4]+' input-block" '
				If aItens[nLin,2] = "C6_ITEM"
					cOrcItens += ' size=4 '
				Endif	
				cOrcItens += ' type="text" disabled value="'+Alltrim(xValue)+'">'
			Endif
		Endif			
		cOrcItens += '</td>' 
	Next

	//INPUTS HIDDEN ==========================================
	cItensHid += '<input type="hidden" class="" id="B1_QE'+cItem+'" name="B1_QE'+cItem+'" value="0">'
	cItensHid += '<input type="hidden" class="" id="C6_TES'+cItem+'" name="C6_TES'+cItem+'" value="">' 
	cItensHid += '<input type="hidden" class="" id="GRUPO'+cItem+'" name="GRUPO'+cItem+'" value="">' 
	cItensHid += '<input type="hidden" class="" id="ACR_LOTE'+cItem+'" name="ACR_LOTE'+cItem+'" value="0">'
	cItensHid += '<input type="hidden" class="" id="ACQ_QUANT'+cItem+'" name="ACQ_QUANT'+cItem+'" value="0">'
	cOrcItens+=cItensHid 
	cOrcItens += '</tr>'
	
	cOrcItens += '<input type="hidden" id="PRODUTOS" name="PRODUTOS" value=""/>
	cOrcItens += '<input type="hidden" name="QtdItens" id="QtdItens" value="'+cValtoChar(nItens)+'"/>'
	cOrcItens += '<input type="hidden" id="PROXIMO" name="PROXIMO" value="01"/>
	cOrcItens += '<input type="hidden" name="C5_NUM" id="C5_NUM" value="" />'
	cOrcItens += '<input type="hidden" name="OPCAO" id="OPCAO" value="3" />'

	cOrcItens += '<input type="hidden" name="TXTPAD" id="TXTPAD" value="ORDEM DE COMPRA CLIENTE:" />'
	cOrcItens += '<input type="hidden" name="TXTORDEM" id="TXTORDEM" value="" />'
	cOrcItens += '<input type="hidden" name="TXTMSGNOTA" id="TXTMSGNOTA" value="BO" />'
	
	cBtnItens+='<div class="row form-group">'
	cBtnItens+='	<div class="col-sm-2">'
	cBtnItens+='		<button class="btn btn-primary" id="btAddItm" name="btAddItm">'
	cBtnItens+='			<i class="fa fa-plus-square"></i> Novo Item</button>'
	cBtnItens+='	</div>' 
	cBtnItens+='</div>'
	
	
	//Adiciona os botões da página
	cBotoes+='<input class="btn btn-primary" type="button" id="btSalvar" name="btSalvar" value="Salvar"/>'+chr(13)+chr(10)
	cBotoes+='<input class="btn btn-primary" type="button" id="btVoltar" name="btVoltar" value="Voltar" onclick="javascript: location.href='+"'"+'u_PedVenda.apw?PR='+cCodLogin+"';"+'"/>'+chr(13)+chr(10)
	
	//Retorna o HTML para construção da página 
	cHtml := H_AddPed()
	
Web Extended End

Return (cHTML) 



/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ SlvPed      ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦17.08.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Gera a cotação.											  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function SlvPed()
Local cHtml
Local nOpc		:= 3 // 3- Incluir / 4- Alterar / 5- Excluir 
local nI		:= 0
local x			:= 0
local i			:= 0
PRIVATE cCondPag	:= ""
PRIVATE cTabela		:= ""
PRIVATE cTrade		:= ""
PRIVATE cCliente	:= ""
PRIVATE cLoja		:= ""
PRIVATE cMsg		:= ""
PRIVATE cTransp	:= ""
PRIVATE cMetodoP	:= ""
PRIVATE cModalidade:= ""
PRIVATE cImport	:= ""
PRIVATE cItens	:= ""
PRIVATE cLinha	:= ""
PRIVATE cDestOrc	:= ""
PRIVATE cMsgIn	:= ""
PRIVATE nTotSC6	:= 0
PRIVATE nItem		:= 0
PRIVATE nSaldo 	:= 0
PRIVATE nSldUt 	:= 0
PRIVATE nPosLin	:= 0
PRIVATE nDesc1	:= 0
PRIVATE cDirOrc 	:= "anexosPortal\orcamento\"
PRIVATE cDirErro  := "erro\"
PRIVATE aItens	:= {}
PRIVATE cNumSC5	:= ""
PRIVATE cNumBon	:= ""
PRIVATE cAplicacao:= ""
PRIVATE lRet		:= .T.
PRIVATE lPneu		:= .T.
PRIVATE cSaveVend
PRIVATE cSupVend
PRIVATE oObjLog := LogSMS():new()
PRIVATE nFatDescAcrs
PRIVATE nPrcTabOrig
PRIVATE nPrcTabBase
PRIVATE nBaseIPI
PRIVATE nBaseST
PRIVATE lEnvEmail := .f.
PRIVATE aArmazens := {}     // Armazens a verificar estoque do orcamento
PRIVATE nQtdItPV  := 0      // Quantidade de itens acumulado no SC6
PRIVATE nQtdItCK  := 0      // Quantidade do item para o CK
PRIVATE cArmItCK  := ""     // PRIVATE de armazem do item
PRIVATE nIndArmz  := 0      // Indice de armazem
PRIVATE nPosIniAr := 0      // Posicao inicial do armazem
PRIVATE cCliLock			  // Lock de cliente
Private cReturn
Private aCabSC5 :={}
Private aItemSC5:={}
Private aItemSC5Bonus:={}
Private aLinhaSC5:={}
Private aLinhaSC5Bonus:={}
Private lMsErroAuto:= .F.
Private cCodLogin := ""
Private cVendLogin:= ""

Web Extended Init cHtml Start U_inSite()

	cVendLogin := u_GetUsrPR()
	cCodLogin  := U_SetParPR(cVendLogin)
    
    //Verifica se não perdeu a sessão
    If type("HttpSession->CodVend") = "U" .or. Empty(HttpSession->CodVend)
		conout(Procname()+"("+ltrim(str(procline()))+") *** Portal "+"Sessao encerrada")
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_SMSPortal.apw">'
		return cHtml
	Endif
	
	// Lock do cliente
	cCliLock := "\temp\"+trim(cValToChar(HttpPost->C5_CLIENTE))+".lock"

	// Travar o cliente
	memowrite(cCliLock, dtos(date())+time())

    //Variáveis do cabeçalho
	cCondPag	:= alltrim(StrTokArr(HttpPost->C5_CONDPAG,"-")[1])
	cVendedor	:= httpSession->codvend
	cTabela		:= alltrim(StrTokArr(HttpPost->C5_TABELA,"-")[1]) 
	nTotSC6 	:= val(HttpPost->PROXIMO)
    cCliente	:= Left(HttpPost->C5_CLIENTE,6)
	cLoja		:= Right(HttpPost->C5_CLIENTE,6)
	cTrade		:= val(HttpPost->C5_XTRADE)
	cObsInterna	:= HttpPost->C5_XOBSINT
	cObsNota	:= HttpPost->C5_XMSGNF

	// cNumSC5 := HttpPost->C5_NUM
	cAplicacao := HttpPost->C5_XAPLIC
	cItens:= HttpPost->aItens
	
	For x:= 1 to nTotSC6
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
	Endif
	If !Empty(cCliente)
		Posicione("SA1",1,xFilial("SA1")+Alltrim(HttpPost->C5_CLIENTE),"A1_COD")
	Endif	

	//Monta o cabeçalho
	// cNumSC5 := GetSxeNum("SC5", "C5_NUM")
	// If !Empty(cNumSC5)
	// 	aadd(aCabSC5,{"C5_NUM",cNumSC5,Nil})
	// 	nOpc := 4
	// EndIf

	aadd(aCabSC5,{"C5_VEND1",  cVendedor, Nil})
	aadd(aCabSC5,{"C5_CLIENTE",SA1->A1_COD,Nil})
	aadd(aCabSC5,{"C5_LOJACLI", SA1->A1_LOJA ,Nil})
	aadd(aCabSC5,{"C5_LOJAENT",SA1->A1_LOJA ,Nil})
	aadd(aCabSC5,{"C5_TABELA" ,cTabela,Nil})
	aadd(aCabSC5,{"C5_CONDPAG",cCondPag ,Nil})
	aadd(aCabSC5,{"C5_TPFRETE" , "S",Nil})
	aadd(aCabSC5,{"C5_ORIGEM" ,"PORTAL",Nil})
	aadd(aCabSC5,{"C5_TIPO" ,"N",Nil})
	aadd(aCabSC5,{"C5_XAPLIC" , cAplicacao,Nil})
	aadd(aCabSC5,{"C5_XMENNOT" ,cObsNota ,Nil})
	aadd(aCabSC5,{"C5_XOBSINT" ,cObsInterna ,Nil})
	aadd(aCabSC5,{"C5_XTRADE" ,cTrade ,Nil})

	if cAplicacao = 'BO'
		aadd(aCabSC5,{"C5_DESCFI" ,cTrade ,Nil})
	endif

    //Monta os itens
	dbSelectArea("SB1")
	SB1->(dbSetorder(1))
	
	If ValType(aItens) == "A"  .and. Len(aItens) > 0
		For i:=1 to Len(aItens) 
			If ValType(aItens[i,1]) == 'C'
				aLinhaSC5:={}
				aLinhaSC5Bonus:={}
				cItem:= StrZero(i,TamSX3("C6_ITEM")[1])
				cProdSC6:= PadR(aItens[i,1], TamSX3("C6_PRODUTO")[1])
				nQuantSC6 := val(StrTran(StrTran(aItens[i,2],".",""),",","."))
				nPrcVen := aItens[i,3]
				nPrcVen := val(StrTran(StrTran(nPrcVen,".",""),",","."))
				cTes := aItens[i,4]
				nDescont := val(aItens[i,5])
				nValor := nQuantSC6 * nPrcVen 
				nBonus := aItens[i, 6]
				nValorBonus := val(nBonus) * nPrcVen 
				nNumpcom := aItens[i, 7]

				If SB1->(dbSeek(xFilial("SB1")+cProdSC6)) .and. nQuantSC6 > 0 .And. nPrcVen > 0	.and. SB1->B1_MSBLQL <> '1'
					aadd(aLinhaSC5,{"C6_ITEM"	, strzero(len(aItemSC5)+1,2),Nil})
					aadd(aLinhaSC5,{"C6_PRODUTO",SB1->B1_COD,Nil})
					aadd(aLinhaSC5,{"C6_LOCAL"	, SB1->B1_LOCPAD,Nil})
					aadd(aLinhaSC5,{"C6_QTDVEN" ,nQuantSC6,Nil})
					// aadd(aLinhaSC5,{"C6_QTDENT" ,nQuantSC6,Nil})
					aadd(aLinhaSC5,{"C6_DESCONT" ,nDescont,Nil})
					aadd(aLinhaSC5,{"C6_OPER" 	,"01", Nil}) 
					//aadd(aLinhaSC5,{"C6_TES" 	, "", Nil}) 
					aadd(aLinhaSC5,{"C6_PRUNIT" ,A410Arred(nPrcVen, "C6_PRCVEN"),Nil})
					aadd(aLinhaSC5,{"C6_PRCVEN" ,A410Arred(nPrcVen, "C6_PRCVEN"),Nil})
					aadd(aLinhaSC5,{"C6_VALOR" , NoRound( nValor, 2 ), Nil}) 
					aadd(aLinhaSC5,{"C6_PEDCLI" , nNumpcom, Nil}) 
					aadd(aItemSC5,aLinhaSC5)
					// Salva a posicao inicial deste produto caso precise ajustar estoque
					if val(nBonus) > 0
						aadd(aLinhaSC5Bonus,{"C6_ITEM"	, strzero(len(aItemSC5)+1,2),Nil})
						aadd(aLinhaSC5Bonus,{"C6_PRODUTO",SB1->B1_COD,Nil})
						aadd(aLinhaSC5Bonus,{"C6_LOCAL"	, SB1->B1_LOCPAD,Nil})
						aadd(aLinhaSC5Bonus,{"C6_QTDVEN" ,val(nBonus),Nil})
						// aadd(aLinhaSC5Bonus,{"C6_QTDENT" ,val(nBonus),Nil})
						aadd(aLinhaSC5Bonus,{"C6_DESCONT" ,0,Nil})
						aadd(aLinhaSC5Bonus,{"C6_OPER" 	,"01", Nil}) 
						//aadd(aLinhaSC5Bonus,{"C6_TES" 	, "", Nil}) 
						aadd(aLinhaSC5Bonus,{"C6_PRUNIT" ,A410Arred(nPrcVen, "C6_PRCVEN"),Nil})
						aadd(aLinhaSC5Bonus,{"C6_PRCVEN" ,A410Arred(nPrcVen, "C6_PRCVEN"),Nil})
						aadd(aLinhaSC5Bonus,{"C6_VALOR" , NoRound( nValorBonus, 2 ), Nil}) 
						aadd(aItemSC5Bonus,aLinhaSC5Bonus)
					endif 
					
					if empty(nPosIniAr)
						nPosIniAr := len(aItemSC5)
					endif
					nQtdItPV += nQuantSC6
				Else
					lRet:= .F.
				Endif
			Endif	
		Next
		cCab := varinfo("cab", aCabSC5, , .f., .f. ) 
		cCab += varinfo("aItemSC5", aItemSC5, , .f., .f. ) 
		 memowrite("\temp\salvoarm.txt", cCab)

		//Chama execauto para inclusão do pedido
		If Len(aCabSC5) > 0 .and. Len(aItemSC5) > 0 .and. lRet
			lMsErroAuto:= .F.
			MATA410(aCabSC5,aItemSC5,nOpc)
		Else
			If !EmptY(cNumSC5)
				conout(Procname()+"("+ltrim(str(procline()))+") *** Portal "+"FALHA AO INCLUIR O PEDIDO. REFAÇA A OPERAÇÃO!")
			Else
				conout(Procname()+"("+ltrim(str(procline()))+") *** Portal "+"FALHA AO ALTERAR O PEDIDO. REFAÇA A OPERAÇÃO!")
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
    		MostraErro(cDirErro,"erro_PED_"+strtran(time(),":","")+"_"+cFilAnt+".txt")
			
		   	cHtml:= "erro" 
		Else
			cHtml:= SC5->C5_NUM+"<br><br>"
			cNumOrigem := SC5->C5_NUM

			if len(aItemSC5Bonus) > 0
				lMsErroAuto:= .F.
				//  aScan(aHeader,{|x| AllTrim(x[2])=="CK_PRCVEN"})
				MATA410(aCabSC5,aItemSC5Bonus,nOpc)

				If lMsErroAuto
					If !ExistDir(cDirErro)
						MakeDir(cDirErro)
					Endif	
					
					cDirErro+=dtos(date())
					If !ExistDir(cDirErro)
						MakeDir(cDirErro)
					Endif
					//Grava o erro
					MostraErro(cDirErro,"erro_PEDBONUS_"+strtran(time(),":","")+"_"+cFilAnt+".txt")
					cHtml:= "errobonus" 
				else
					cHtml:= cNumOrigem+" - Bonificacao: "+ SC5->C5_NUM + "<br><br>"
					cNumBon := SC5->C5_NUM

					// Salva a área atual
					aAreaSC5 := SC5->(GetArea())

					dbSelectArea("SC5")
					SC5->(DbSetOrder(1))
					If SC5->(dbSeek(xFilial("SC5")+cNumOrigem))
						RecLock('SC5', .F.)
						SC5->C5_XBONUS := cNumBon
						MsUnLock()
					ENDIF

					// Atualiza o pedido de bonificação
					dbSelectArea("SC5")
					SC5->(DbSetOrder(1))
					If SC5->(dbSeek(xFilial("SC5")+ cNumBon))
						RecLock('SC5', .F.)
						SC5->C5_XORIG := cNumOrigem
						MsUnLock()
					ENDIF

					// Restaura a área original
					RestArea(aAreaSC5)
				endif
			endif
		EndIf
	Else
		cHtml:= "erro"
	Endif
	
	// Apagar o lock do cliente
	ferase(cCliLock)
	
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
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function GetTabela(cTab,lEst, cVendEst)
Local cHtml
Local cTabela	:= ""
Local cCodTab	:= ""
local aInfoVend := {"", ""}				// Informacoes do vendedor (Tipo e Equipe)
local aTabsPrco := {}
local nInd
Default cTab	:= ""
Default lEst	:= .F.
Default cVendEst  := "" 
Private cCodLogin := ""
Private cVendLogin:= ""

Web Extended Init cHtml Start U_inSite(!lEst)

	//TODO-Pedro20210208-Remover???
	If Empty(HttpSession->CodVend)
		cHtml:='<METAHTTP-EQUIV="Refresh"CONTENT="0;URL=U_PortalLogin.apw">'
		Return cHtml
	endif	
	
	if type("httppost->cliente") <> "U"
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+httppost->cliente))
			cCodTab:= SA1->A1_TABELA
		Endif
	Endif
	if lEst
		cVendLogin := cVendEst
	Else
		cVendLogin := u_GetUsrPR()
	endif
	aInfoVend := u_getUsPR("Vendedor", cVendLogin)

	aTabsPrco := u_retTabPr(aInfoVend, cCodTab, .f.)

	//Preenche o select da tabela
	for nInd:= 1 to len(aTabsPrco)
		cTabela+= aTabsPrco[nInd,2]
	next
   
	cHtml:= cTabela

Web Extended end

Return cHtml



/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ retTabPr   	¦ Autor ¦Pedro A. de Souza  ¦ Data ¦ 06.06.22 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Retorna array com tabelas de preco do vendedor             ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User function retTabPr(aInfoVend, cCodTab, lEst)
	local aRet := {}
	local cQry := ""
	if !Empty(cCodTab)
		DA0->(dbSetOrder(1))
		If DA0->(dbSeek(xFilial("DA0")+cCodTab))
			aadd(aRet, {DA0->DA0_FILIAL, alltrim(DA0->DA0_CODTAB), alltrim(DA0->DA0_DESCRI)})
		Endif
	Endif
	
	//Busca os itens da tabela de preço
	cQry:="Select DISTINCT DA0_FILIAL, DA0_CODTAB, DA0_DESCRI " 
	cQry+=" From "+RetSqlName("DA0")+" DA0 "
	cQry+=" Where 1=1 "
	cQry+=" And DA0_FILIAL = '"+xFilial("DA0")+"' "
	cQry+=" AND DA0_ATIVO = '1' "
	cQry+=" AND DA0_DATATE >= '"+dtos(date())+"' "
	cQry+=" AND DA0.D_E_L_E_T_ = ' ' "
	
	if !Empty(cCodTab)
		cQry+= " AND (DA0_FILIAL + DA0_CODTAB <> '"+xFilial("DA0")+cCodTab+"') "
	Endif	
	cQry+=" Order by DA0_FILIAL, DA0_CODTAB " 
	// conout(cqry)
	If Select("QRT") > 0
		QRT->(dbCloseArea())
	Endif	 	
	//memowrite("\temp\qtab.txt", cQry)
	APWExOpenQuery(ChangeQuery(cQry),'QRT',.T.)

	//Preenche o select da tabela
	While QRT->(!Eof())
		aadd(aRet, {Alltrim(QRT->DA0_FILIAL), alltrim(QRT->DA0_CODTAB), alltrim(QRT->DA0_DESCRI)})
	    QRT->(dbSkip())
    End
	QRT->(dbCloseArea())
return aRet


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetProdutos 	¦ Autor ¦ Lucilene Mendes   ¦ Data ¦ 02.09.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Função utilizada no Ajax pra retornar os produtos da tabela¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function GetProdutos()
Local cHtml      
Local cTabela:= HttpPost->TABELA
Local cProds := ""

Web Extended Init cHtml Start U_inSite()
    
	// TODO - Pedro 20210208 - Remover???
	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_PortalLogin.apw">'	
		Return cHtml
	endif
    //Atualiza a variável de sessão
    HttpSession->TABELA := cTabela
    
	//Busca os itens da tabela de preço
	cQry:="Select DISTINCT DA1_CODTAB, B1_COD  DA1_CODPRO, B1_DESC " 
	cQry+=" From "+RetSqlName("DA1")+" DA1"
	cQry+=" INNER JOIN "+RetSqlName("DA0")+" DA0 ON DA0_FILIAL = DA1_FILIAL AND DA0_CODTAB = DA1_CODTAB AND DA0_ATIVO = '1' AND DA0.D_E_L_E_T_ = ' ' "
	cQry+=" INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = DA1_CODPRO AND B1_MSBLQL <> '1' AND SB1.D_E_L_E_T_ = ' ' "
	cQry+=" Where DA1_FILIAL = '"+xFilial("DA1")+"' "
	cQry+=" And DA1_CODTAB = '"+cTabela+"' "
	cQry+=" AND DA1_ATIVO = '1' "
	cQry+=" AND DA1_PRCVEN > 0 "
	cQry+=" AND DA1.D_E_L_E_T_ = ' ' " 
	cQry+=" Order by DA1_CODTAB, B1_COD " 
	
	If Select("QRP") > 0
		QRP->(dbCloseArea())
	Endif	 	
	APWExOpenQuery(ChangeQuery(cQry),'QRP',.T.)
	 
	//Preenche o select de produtos
	While QRP->(!Eof()) 
		cProds+='	<option value="'+Alltrim(QRP->DA1_CODPRO)+'">'+Alltrim(QRP->DA1_CODPRO)+' - '+Alltrim(Strtran(QRP->B1_DESC,"'",""))+'</option>'
		QRP->(dbSkip())
    End
	
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
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function GatProd()
Local cProduto	:= Alltrim(HttpPost->PRODUTO)
Local cTabela	:= Alltrim(HttpSession->Tabela)
Local cSepField := "|#|" 
Local cTes		:= ""
Local nDesc 	:= 0
Local aRet		:= {}
Local cHtml
local nValDesc 	:=0

Web Extended Init cHtml Start U_inSite()

	// TODO - Pedro 20210208 - Remover???
	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_PortalLogin.apw">'	
		Return cHtml
	endif
    
    //Posiciona no cadastro do produto
    Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_COD")

	nPrcTab	 := Posicione("DA1",7,xFilial("DA1")+cTabela+cProduto,"DA1_PRCVEN")
   
	If nPrcTab > 0
		nValDesc:= nPrcTab * nDesc 
		cPrcTab := TransForm((nPrcTab-nValDesc),PesqPict("SC6","C6_PRCVEN"))

		aAdd(aRet,Alltrim(SB1->B1_UM))
		aAdd(aRet,cValtochar(nPrcTab))
		aAdd(aRet,cValtochar(SB1->B1_QE)) 
		aAdd(aRet,cTES) 
		aAdd(aRet,SB1->B1_GRUPO)

		cQry:=" SELECT ACR.ACR_FILIAL " 
		cQry+="	,ACR.ACR_CODPRO " 
		cQry+="	,ACR.ACR_LOTE " 
		cQry+="	,ACQ.ACQ_QUANT " 
		cQry+="	,ACQ.ACQ_DATDE " 
		cQry+="	,ACQ.ACQ_DATATE " 
		cQry+=" FROM "+RetSqlName("ACR")+" ACR "
		cQry+=" JOIN ACQ010 ACQ ON ACQ.ACQ_CODPRO = ACR.ACR_CODPRO AND ACQ.ACQ_FILIAL = ACR.ACR_FILIAL AND ACR.D_E_L_E_T_ = ' ' "
		cQry+=" Where ACQ.ACQ_FILIAL = '"+xFilial("ACR")+"' "
		cQry+=" And ACQ.ACQ_CODPRO = '"+cProduto+"' "

		CONOUT("@@@QRY - bonificacao: " + cQry)

		If Select("ACR") > 0
			ACR->(dbCloseArea())
		Endif	 	
		APWExOpenQuery(ChangeQuery(cQry),'ACR',.T.)
		
		//Preenche o select de produtos
		While ACR->(!Eof()) 

			CONOUT("@@@QRY - bonificacao:" + cvaltochar(stod(ACR->ACQ_DATATE)))
			CONOUT("@@@QRY - bonificacao:" + cvaltochar(stod(ACR->ACQ_DATDE)))

			if date() <= stod(ACR->ACQ_DATATE) .AND. date() >= stod(ACR->ACQ_DATDE)
				CONOUT("@@@QRY - bonificacao: entrou aqui")
				aAdd(aRet,cvaltochar(ACR->ACR_LOTE))
				aAdd(aRet,cvaltochar(ACR->ACQ_QUANT))
			endif
			ACR->(dbSkip())
		End
	
		cHtml := "OK:"
		if len(aRet) > 5
  			cHtml += aRet[1]+cSepField+aRet[2]+cSepField+aRet[3]+cSepField+aRet[4]+cSepField+aRet[5]+cSepField+aRet[6]+cSepField+aRet[7]
		else
			cHtml += aRet[1]+cSepField+aRet[2]+cSepField+aRet[3]+cSepField+aRet[4]+cSepField+aRet[5]
		endif

	Else
    	cHtml := "Não foi possível localizar o produto"
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
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function GetValImp(cCliente,nPreco,nDesc,nQtdFis,nValIcms,nBaseIcms,nValST,nBaseST,nValIPI,nBaseIPI,cAliqIPI,cAliqICMS,cAliqST,cTes)
	Local _nItem:= 0
	Local cCodOper:= ""
	MaFisEnd()

	SA1->(dbSetorder(1))	// A1_FILIAL+A1_COD+A1_LOJA
	SA1->(dbSeek(xFilial("SA1")+cCliente))

	cCodOper:= "01"

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
	conout("tes -->"+cTes)
	conout("prod -->"+SB1->B1_COD)
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
	nBaseST :=MaFisRet(_nItem,"IT_BASESOL")
	cAliqST	:= Alltrim(Str(MaFisRet(_nItem,"IT_ALIQSOL")))
	// Ajusta o ICMS ST 
	U_AjustST(SA1->A1_COD, SA1->A1_LOJA, SA1->A1_TIPO, SA1->A1_EST, _nItem, @nValST, @nBaseST)

Return

/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Nome              ! AjustST                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Ajusta o cálculo da base do DIFAL para base duplaelas   !
!                  ! conforme calculos de M410SOLI.prw e M460SOLI.prw        !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 10/02/2022                                              !
+----------------------------------------------------------------------------+
*/
User function AjustST(cCliente, cLoja, cTipoCli, cEstCli, _nItem, nValST, nBaseST)
   // Local _aEst     := GETMV("MV_UFBDST")
    // Local _cItemSC6 := ParamIxb[2] //Item do Pedido de Venda (C6_ITEM)
    Local _nAlisIcm := MaFisRet(_nItem,"IT_ALIQSOL")
    // Local _nBasFCP  := MafisRet(_nItem,"IT_BSFCPST")
    // Local _nAliFCP  := MafisRet(_nItem,"IT_ALFCST")
    // Local _nValFCP  := MafisRet(_nItem,"IT_VFECPST")
    Local _nIcmBas  := MaFisRet(_nItem,"IT_BASEICM")
    // Local _nAliInt  := MaFisRet(paramixb[1],"IT_ALIQICM")

    // Local _nValIcm := 0
    // if !(SC5->C5_TIPO $ "BD") .and. SA1->(dbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)) .and. (Alltrim(SA1->A1_EST)$_aEst .and. SC5->C5_TIPOCLI=="S")
 //   if (Alltrim(cEstCli)$_aEst .and. cTipoCli=="S")
        // Para transportadora de MG pneus de carga não calcula ST - Chamado 27119 - Mara/Pedro 24/05/2022
        // if U_chIncMG(SB1->B1_COD)   // cSA1->A1_EST == "MG" .and. trim(SB1->B1_GRTRIB)+"/" $ '007/020/' .and. trim(SA1->A1_GRPTRIB) == "004"
        //     nBaseST   := 0.00
        //     nValST := 0.00
		// else
			nBaseST   := (_nIcmBas-MaFisRet(_nItem,"IT_VALICM"))/(1-(_nAlisIcm/100))
			nValST := (nBaseST*(_nAlisIcm/100))-MaFisRet(_nItem,"IT_VALICM")
		// endif
   // Endif
return

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetCellTb   ¦ Autor ¦ Lucilene Mendes  	¦ Data ¦ 22.11.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Função para geração da linha da tabela de itens		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function GetCellTb()

Local cHtml
Local nCol	:= HttpPost->coluna
Local nLin	:= val(HttpPost->linha)
Local cItem	:= ""
Local cCampo:= ""

Web Extended Init cHtml Start U_inSite()

	cItem:= StrZero(nLin,TamSX3("C6_ITEM")[1])
	
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
¦¦¦Funçäo    ¦ VerSessao   ¦ Autor ¦ Lucilene Mendes  	¦ Data ¦ 27.04.18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Verifica se a sessão está ativa						      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
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
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function DadosCli()
Local cHtml	
Local cCondPg		:= ""
Local cCondDescri	:= ""
local cCodLoja := HttpPost->cliente

Web Extended Init cHtml Start U_inSite()
    
 	// TODO - Pedro 20210208 - Remover???
	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_PortalLogin.apw">'	
		Return cHtml
	endif

	//Seleciona as condições de pagamento disponíveis no combo
	cQry:= " Select A1_CONDPAG, A1_TABELA, A1_XTRADE "
	cQry+= " From "+RetSqlName("SA1")+" SA1 "
	cQry+= " Where A1_COD+A1_LOJA = '"+cCodLoja+"' "
	cQry+= " And A1_VEND = '"+HttpSession->CodVend+"' "
	cQry+= " And A1_MSBLQL <> 1 "
	cQry+= " And SA1.D_E_L_E_T_ = ' ' "
	
	If Select("QRT") > 0
		QRT->(dbCloseArea())
	Endif	 	
	APWExOpenQuery(ChangeQuery(cQry),'QRT',.T.)
	 
	//Preenche o select da tabela
	cCondPg+='	<option value=""></option>'
	While QRT->(!Eof())
		private cTabela 	:= cvaltochar(QRT->A1_TABELA)
		private cCondPag 	:= cvaltochar(QRT->A1_CONDPAG)
		private cTrade		:= cvaltochar(QRT->A1_XTRADE)

		if ALLTRIM(cTabela) == ""
			cHtml := "NOK1"
		else
			dbSelectArea("DA0")
			DA0->(DbSetOrder(1))
			If DA0->(dbSeek(xFilial("DA0")+cTabela))
				cCondDescri := Posicione("SE4",1,xFilial("SE4")+DA0->DA0_CONDPG,"E4_DESCRI")
				cCondPag := iif(alltrim(cCondPag) == "", DA0->DA0_CONDPG + " - " + cCondDescri, cCondPag + " - " + cCondDescri) 
				cTabela := cTabela + " - " + DA0->DA0_DESCRI

				if date() > DA0->DA0_DATATE .or. date() < DA0->DA0_DATDE .OR. DA0->DA0_ATIVO = '2'
					cHtml := "NOK2"
				elseif cCondPag = "" 
					cHtml := "NOK1"
				else
					cHtml:= cTabela+"|"+cCondPag+"|"+cTrade
				endif
			Else
				cHtml := "NOK2"
			Endif

		endif
	    QRT->(dbSkip())
    End

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
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function GetCondTabela()
Local cHtml
Local cCondPg	:= ""
Local cCondPag	:= Posicione("SA1",1,xFilial("SA1")+HttpPost->cliloja,"A1_COND")

Web Extended Init cHtml Start U_inSite()
    
 	// TODO - Pedro 20210208 - Remover???
	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=U_PortalLogin.apw">'	
		Return cHtml
	endif

	//Seleciona as condições de pagamento disponíveis no combo
	cQry:= " Select E4_CODIGO, E4_DESCRI "
	cQry+= " From "+RetSqlName("SE4")+" SE4 "
	cQry+= " Where E4_FILIAL = '"+xFilial("SE4")+"' "
	cQry+= " And E4_CODIGO = "+cCondPag+" "
	cQry+= " And E4_MSBLQL <> 1 "
	cQry+= " And SE4.D_E_L_E_T_ = ' ' "
	
	If Select("QRT") > 0
		QRT->(dbCloseArea())
	Endif	 	
	APWExOpenQuery(ChangeQuery(cQry),'QRT',.T.)
	 
	//Preenche o select da tabela
	cCondPg+='	<option value=""></option>'
	While QRT->(!Eof())
		cCondPg+='	<option value="'+Alltrim(QRT->E4_CODIGO)+'">'+Alltrim(QRT->E4_CODIGO)+" - "+Alltrim(QRT->E4_DESCRI)+'</option>'
		
	    QRT->(dbSkip())
    End
    
	cHtml:= cCondPg

Web Extended end

Return cHtml
