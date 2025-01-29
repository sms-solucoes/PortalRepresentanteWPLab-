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
¦¦¦Descriçäo ¦ Visualização das notas fiscais.	-						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function ViewPedido()
Local cHtml
// Local nTFil	:= FWSizeFilial()
Local cItem := ""
// Local cTr   := ""
// Local cTrHid:= ""
// Local nTNum	:= 0
// Local nTPro	:= 0
// Local nDiasEnt := 0 
// Local nPosFrete:= 0
// Local lDigitado:= .F.
// Local lMoeda	:= .F.
// Local lNumber	:= .F.
// Local aTpFrete	:= {}
// Local aTipoOrc	:= {}
Local nLin
// Private cDirPortal 	:= ""
// Private cEndServ 	:= "" // Endereço do servidor da pagina de Portal
Private cPEDCabec	:= ""
Private cPEDItens	:= ""
Private cNumSC5   	:= ""
Private cOCCliente  := ""
Private cBotoes		:= ""
Private cTpFrete	:= ""
Private cValFre		:= ""
Private cTransp		:= ""
Private cCliente	:= ""
// Private cEntrega	:= ""
Private cBtnItens	:= ""
Private cObsNota	:= ""
Private cEmissao	:= ""
Private cTabPreco	:= ""
Private nTVlrUnit	:= 0
Private nTTotal		:= 0
Private nTQtdItem	:= 0
Private nTTotalDes	:= 0
Private nTImpostos	:= 0
Private nTFrete		:= 0
Private nItens		:= 0
				
Private cSite	  := "u_PortalLogin.apw"
Private cPagina	  := "Pedido de Venda"
Private cMenus	  := ""
Private cTitle	  := ""
// Private cAnexos	  := ""
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
	Endif
	
	// Pega do parâmetro com o Titulo do Portal
	cTitle	:= SuperGetMV("PS_TITLE", .T., "Portal SMS")
	
	// Define a funcao a ser chama no link
	cSite	:= Procname()+".apw?PR="+cCodLogin
	
	// Monta o cabeçalho para a pagina
	cHeader := U_PSHeader(cTitle, cSite, cCodLogin) 	

	//Função que atualiza os menus
	cMenus := U_GetMenus(AllTrim(Upper(Procname())), cVendLogin)
	
	//Atualiza as variáveis
	cEndServ := GetMv('MV_WFBRWSR')
	nRECSC5 := val(HttpGet->rec) 
	
	//Posiciona no pedido
	SC5->(dbGoto(nRECSC5))
	cNumSC5:= SC5->C5_NUM

	//Troca de filial
	u_PTChgFil(SC5->C5_FILIAL)
	
	dbSelectArea("SC5")
	SC5->(dbGoTo(nRECSC5))

	dbSelectArea("SC6")
	dbSetOrder(1)
	SC6->(dbSeek(SC5->C5_FILIAL+SC5->C5_NUM))
	// if !empty(SC5->(fieldpos("C5_XOCCLI")))
	// 	cOCCliente := SC5->C5_XOCCLI
	// endif
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
	aItens := {	{"Item","C6_ITEM","30px","left","A",.F.,.T.,.F.,"Selecione..."},;
				{"Produto","C6_PRODUTO","250px","left","B",.F.,.T.,.F.,"Selecione..."},;       
				{"Quantidade","C6_QTDVEN","80px","right","C",.F.,.T.,.F.,"0"},;
				{"V.Unitário","C6_PRCVEN","80px","right","D",.F.,.F.,.T.,"0,00000"},;
				{"Total","C6_VALOR","80px","right","E",.F.,.F.,.T.,"0,00"},;
				{"Ord.Compra","C6_NUMPCOM","80px","left","E",.F.,.F.,.T.,""},;
				{"Status","C6_STATUS","80px","left","E",.F.,.F.,.T.,""};
			  }			



		    
	//Cria o cabeçalho dos Itens
	For nLin := 1 to Len(aItens)
		cPEDCabec += '<th style="width: '+aItens[nLin,3]+'; text-align: '+aItens[nLin,4]+';">'+aItens[nLin][1]+'</th>'
	Next 
	
	//Tipo de frete
	aTpFrete:= {{"S","Sem Frete"},{"C","CIF"},{"F","FOB"}}
	cTpFrete:='<select class="form-control mb-md" name="F2_TPFRETE" id="F2_TPFRETE" value="'+SC5->C5_TPFRETE+'" disabled>'

	nPosFrete:= aScan(aTpFrete,{|x|x[1]==SC5->C5_TPFRETE})
	If nPosFrete = 0
		nPosFrete:= 1
	Endif	
	cTpFrete+='	<option value="'+SC5->C5_TPFRETE+'">'+aTpFrete[nPosFrete,2]+'</option>'	
	
	cTpFrete+='</select>' 
	
	cValFre:= Transform(SC5->C5_FRETE,"@E 999,999,999.99")

	cEmissao := dtoc(SC5->C5_EMISSAO)

	//Tabela de preço
	cTabPreco:='<select class="form-control mb-md" name="C5_TABELA" id="C5_TABELA" required="" aria-required="true" disabled>'
	cTabPreco+='	<option value="'+SC5->C5_TABELA+'">'+SC5->C5_TABELA+" - "+Posicione("DA0",1,xFilial("DA0")+SC5->C5_TABELA,"DA0_DESCRI")+'</option>'		
	cTabPreco+='</select>'	
	
	//Transportadora
	cTransp:= SC5->C5_TRANSP+' - '+Alltrim(Posicione("SA4",1,"      "+SC5->C5_TRANSP,"A4_NREDUZ"))
		
    //Condição de Pagamento
	cCondPag:='<select class="form-control mb-md" name="F2_COND" id="F2_COND" required="" aria-required="true" disabled>'
	cCondPag+='	<option value="'+SC5->C5_CONDPAG+'">'+SC5->C5_CONDPAG+" - "+Posicione("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"E4_DESCRI")+'</option>'		
	cCondPag+='</select>'	                             
	 
	//Cliente
	cCliente:='<select data-plugin-selectTwo class="form-control populate placeholder" data-plugin-options='+"'"
	cCliente+='{ "placeholder": "Selecione um Cliente", "allowClear": false }'+"'"+' name="CJ_CLIENTE" id="CJ_CLIENTE" '
	cCliente+=' disabled >' 
	cCliente+=' <option value='+SC5->C5_CLIENTE+SC5->C5_LOJACLI+'>'+SC5->C5_CLIENTE+'/'+SC5->C5_LOJACLI+' - '+Alltrim(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"))+" - "+right(trim(SA1->A1_CGC), 6)+'</option>'
	cCliente+='</select>'
	
	//Preenchimento dos itens
	nTFrete:= SC5->C5_FRETE
	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))
	SC6->(dbSeek(SC5->C5_FILIAL+SC5->C5_NUM))
	While SC6->(!Eof()) .and. SC6->C6_NUM = SC5->C5_NUM
		nItens++
		cPEDItens += '<tr class="odd" id="linha'+StrZero(nItens,2)+'">'
		
		nTQtdItem += SC6->C6_QTDVEN
		nTVlrUnit +=  SC6->C6_QTDVEN * SC6->C6_PRCVEN
		nTTotalDes += (SC6->C6_QTDVEN * SC6->C6_PRCVEN) * (SC5->C5_DESCFI / 100)
		nTTotal   := nTVlrUnit - nTTotalDes
		// nTTotal:=  nTVlrUnit + nTFrete
		For nLin := 1 to Len(aItens)
			cPEDItens += '<td'+Iif(!Empty(aItens[nLin][4]),' align="'+aItens[nLin][4]+'"',"")+'>'
			// Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC")	
			lMoeda:= aItens[nLin,8] //Indica se é Moeda  			
			lNumber:= aItens[nLin,5] = "N" //Indica que é numérico  			
			xValue:= ""
			cItem := trim(SC6->C6_ITEM)
			Do Case 
				Case aItens[nLin][2] == 'C6_ITEM'
						xValue := SC6->C6_ITEM
				Case aItens[nLin][2] == 'C6_PRODUTO'
						xValue := AllTrim(trim(SC6->C6_PRODUTO)+" - "+trim(SC6->C6_DESCRI))
				Case aItens[nLin][2] == 'C6_QTDVEN'
						xValue := Alltrim(PadR(TransForm(SC6->&(aItens[nLin][2]),"@E 999,999,999.99"),14))
				Case aItens[nLin][2] == 'C6_PRCVEN'
						xValue := Alltrim(PadR(TransForm(SC6->&(aItens[nLin][2]),"@E 999,999,999.99"),14))
				Case aItens[nLin][2] == 'C6_VALOR'
						xValue := Alltrim(PadR(TransForm(SC6->C6_VALOR,"@E 999,999,999.99"),14))
				Case aItens[nLin][2] == 'C6_NUMPCOM'
						xValue := SC6->C6_NUMPCOM
						//xValue := dtoc(SC6->C6_PEDCOM)
				Case aItens[nLin][2] == 'C6_STATUS'
						if SC6->C6_QTDENT = SC6->C6_QTDVEN .or. C6_BLQ = "R"
							xValue := "Faturado"
						elseif SC6->C6_QTDENT > 0 
							xValue := "Parcial"
						elseif SC6->C6_QTDLIB > 0 
							xValue := "Liberado"
						else
							xValue := "Aberto"
						endif
			EndCase  
		   
			cPEDItens += '<input id="'+aItens[nLin][2]+cItem+'" data-prop="'+aItens[nLin][2]+'" '
			cPEDItens += ' name="'+aItens[nLin][2]+cItem+'" class="form-control input-block" type="text" disabled '
			cPEDItens += ' style="text-align: '+aItens[nLin,4]+';" '
			cPEDItens += ' value="'+Alltrim(xValue)+'" title="'+Alltrim(xValue)+'">'
			cPEDItens += '</td>' 
		Next			
		cPEDItens += '</tr>'
		SC6->(dbSkip())	
	End	
	
	//Adiciona os botões da página
	cBotoes+='<input class="btn btn-primary" type="button" id="btVoltar" name="btVoltar" value="Voltar" onclick="javascript: location.href='+"'"+'u_PedVenda.apw?PR='+cCodLogin+"';"+'"/>'+chr(13)+chr(10)
	
	//Retorna o HTML para construção da página 
	cHtml := H_ViewPedido()
	
Web Extended End

Return (cHTML) 
