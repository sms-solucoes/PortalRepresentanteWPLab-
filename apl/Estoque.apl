#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ Estoque     ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦17.07.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Grid com o estoque de itens por tabela de preço.	  		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function Estoque()
Local cHtml
Local cFiltro	:= ""
Local cTabela	:= ""
Local cArmazem  := ""
Local cVend	 	:= HttpSession->CodVend
local oObjLog   := LogSMS():new()
local nCnt      := 0                      
Private cColunas:= ""
Private cItens	:= ""  
Private cTopo	:= ""  
Private cSite	:= "u_PortalLogin.apw"
Private cPagina	  := "Tabela de Preço"
Private cTitle	  := "" 
Private lTableTools:= .T.
Private lSidebar:= .F.
Private cCodLogin := ""
Private cVendLogin:= ""

oObjLog:setFileName("\temp\"+Procname()+"_"+dtos(date())+".txt")

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
	cSite	:= "u_SMSPortal.apw?PR="+cCodLogin
	
	// Monta o cabeçalho para a pagina
	cHeader := U_PSHeader(cTitle, cSite) 	
	
	//Função que atualiza os menus
	cMenus := U_GetMenus(AllTrim(Upper(Procname())), cVendLogin)
	 
	//Armazéns considerados para busca do estoque
    cArmazem:= GetNewPar("AA_LOCALP","'01'") //deve estar no formato '01','02' 

	
	//Tratamento dos filtros
	If type("HttpPost->Tabela") <> "U"
		//Atualiza as variáveis no valor do filtro
		cTabela:= Alltrim(HttpPost->Tabela)
		cFilTab:= Alltrim(HttpPost->FilTab)
		cFiltro:= HttpPost->tipoFiltro  
		
		//Troca de filial
   		u_PTChgFil('010101') // estava u_PtChgFil(cFilTab)
		 
	Else
		cFiltro:= 'R'   //1=Revenda, 2=Consumidor
	Endif
	
	if cFiltro == "R"
		cCli:= GetNewPar("AA_PCLIREV","04140399")
		cLoj:= GetNewPar("AA_PLOJREV","0001")
	Else
		cCli:= GetNewPar("AA_PCLIFIN","04140399")
		cLoj:= GetNewPar("AA_PLOJFIN","0001")
	Endif
		
    //Filtros
    cTopo:= '<div class="row form-group">'
    cTopo+= '	<div class="col-sm-12" align="right">'
    cTopo+= '	<form name="formGrid" id="formGrid" method="POST" action="U_Estoque.apw?PR='+cCodLogin+'">'
    
    // cTopo+= '		<label class="col-md-1 control-label">Tipo:</label>'
    // cTopo+= '  		<div class="col-sm-2">'
	// cTopo+= '		 	<div class="input-group">'
	// cTopo+= '				<select data-plugin-selectTwo class="form-control populate mb-md" name="tipofiltro" id="tipofiltro" '
	// cTopo+= ' 				data-plugin-options='+"'"+'{"minimumResultsForSearch": "-1"}'+"'"+' required="" aria-required="true" value="'+cFiltro+'">'
	// cTopo+= '					<option value="R"'+Iif(cFiltro='R',' selected','')+'>Revenda</option>'
	// cTopo+= '					<option value="F"'+Iif(cFiltro='F',' selected','')+'>Consumidor</option>'
    // cTopo+= '				</select>'
    // cTopo+= '			</div>'
    // cTopo+= '		</div>'
 
    //Tabela de preço
    cTopo+= '		<label class="col-md-2 control-label">Tabela de Preço:</label>'
	cTopo+= '		<div class="col-md-4">'
	cTopo+= '			<select data-plugin-selectTwo class="form-control populate placeholder mb-md" data-plugin-options='+"'"
	cTopo+= '			{ "placeholder": "Selecione...", "allowClear": false }'+"'"+' name="TABELA" id="TABELA" '
	cTopo+= '			required="" aria-required="true">'
	If !Empty(cTabela) 
		cTopo+= '				<option value="'+cTabela+'" selected>'+xFilial("DA0")+"/"+cTabela+' - '+Upper(Posicione("DA0",1,xFilial("DA0")+cTabela,"DA0_DESCRI"))+'</option>' 
	Else
		cTopo+= '				<option value=""></option>'
	Endif 
	cTopo+= u_GetTabela(cTabela,.t.,cVendLogin)
	cTopo+= '			</select>'
	cTopo+= '		</div>'
	
	cTopo += '<input type="hidden" name="FILTAB" id="FILTAB" value="" />'
	
	//Botão 
    cTopo+= '		<div class="col-md-2">'
    cTopo+= '			<button class="btn btn-primary" id="btFiltro" value="" onclick="this.value= '+"'"+'Aguarde...'+"'"+';this.disabled= '+"'"+'disabled'+"'"+';Filtro()" name="btFiltro">'
    cTopo+= '			<i class="fa fa-filter"></i> Buscar</button>' 
    cTopo+= '		</div>' 
    cTopo+= '	</form>'
	cTopo+= '	</div>'
	cTopo+= '</div>'
	
	 
	
	//Cabeçalho do grid
	cColunas+='<th>Código</th>'
	cColunas+='<th>Descrição</th>'
	cColunas+='<th>% Desconto 1</th>'
	cColunas+='<th>% Desconto 2</th>'
	cColunas+='<th>% Desconto 3</th>'
	cColunas+='<th>Qtd Mínima</th>'
	cColunas+='<th>Qtd Disponível</th>'
	If HttpSession->Tipo = 'S' 
		//cColunas+='<th>Qtd Disponível</th>' --Removido conforme solicitação do André -Lucilene SMSTI 19/11/21
		cColunas+='<th>Qtd Empenhada</th>'
	Endif
	cColunas+='<th>Preço de Venda</th>'
	
	if !empty(cTabela)
		//Busca os itens da tabela de preço
		cQry:="WITH QRYPRECO AS ("
		cQry+="Select DA1_CODTAB, DA1_CODPRO, B1_DESC, DA1_PRCVEN, DA1_XDESC1, DA1_XDESC2, DA1_XDESC3, DA1_XQTMIN " 
		cQry+=" From "+RetSqlName("DA1")+" DA1"
		cQry+=" INNER JOIN "+RetSqlName("DA0")+" DA0 ON DA0_FILIAL = DA1_FILIAL AND DA0_CODTAB = DA1_CODTAB AND DA0_ATIVO = '1' AND DA0.D_E_L_E_T_ = ' ' "
		cQry+=" INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = DA1_CODPRO AND B1_MSBLQL <> '1' AND SB1.D_E_L_E_T_ = ' ' "
		cQry+=" Where DA1_FILIAL = '"+xFilial("DA1")+"' "
		cQry+=" And DA1_CODTAB = '"+cTabela+"' "
		cQry+=" AND DA1_ATIVO = '1' "
		cQry+=" AND DA1.D_E_L_E_T_ = ' ' " 
		// cQry+=" Order by DA1_CODTAB, B1_COD " 
		cQry+="), QRYESTOQUE AS ("
		cQry+="Select B2_COD, SUM(B2_QATU) EST , SUM(B2_QEMP) + SUM(B2_RESERVA) + SUM(B2_QPEDVEN) EMPENHO "
		cQry+=" From "+RetSqlName("SB2")+" SB2 " 
		cQry+=" Where B2_FILIAL = '"+Alltrim(SM0->M0_CODFIL)+"' "
		cQry+=" And SB2.D_E_L_E_T_ = ' ' "
		cQry+=" And B2_COD IN (SELECT DA1_CODPRO FROM QRYPRECO) "
		If !Empty(cArmazem)
			cQry+= "AND B2_LOCAL in ("+cArmazem+") " 
		Endif
		cQry+=" GROUP BY B2_COD"
		cQry+=") "
		cQry+=" SELECT QRYPRECO.*, QRYESTOQUE.* "
		cQry+="  FROM QRYPRECO "
		cQry+= " LEFT JOIN QRYESTOQUE "
		cQry+=   " ON QRYPRECO.DA1_CODPRO = QRYESTOQUE.B2_COD "
		cQry+= " ORDER BY DA1_CODPRO "
		// cQry+=""
		oObjLog:saveMsg("Antes query")
		
		If Select("QRP") > 0
			QRP->(dbCloseArea())
		Endif	 	
		// APWExOpenQuery(ChangeQuery(cQry),'QRP',.T.)
		APWExOpenQuery(cQry,'QRP',.T.)
		oObjLog:saveMsg("Executou query")
		
		//Preenche o select de produtos
		While QRP->(!Eof())
			
			//Busca a quantidade disponível em estoque
			// cQry:= "Select SUM(B2_QATU) EST , SUM(B2_QEMP) + SUM(B2_RESERVA) + SUM(B2_QPEDVEN) EMPENHO " 
			// cQry+= "From "+RetSqlName("SB2")+" SB2 " 
			// cQry+= "Where B2_FILIAL = '"+Alltrim(SM0->M0_CODFIL)+"' And B2_COD = '"+QRP->DA1_CODPRO+"' And SB2.D_E_L_E_T_ = ' ' "
			// If !Empty(cArmazem)
			// 	cQry+= "AND B2_LOCAL in ("+cArmazem+") " 
			// Endif
			
			// If Select("QRS") > 0
			// 	QRS->(dbCloseArea())
			// Endif	 	
			// APWExOpenQuery(cQry,'QRS',.T.)
					
			cItens+='<tr>'
			cItens+='	<td>'+Alltrim(QRP->DA1_CODPRO)+'</td>'
			cItens+='	<td>'+Alltrim(QRP->B1_DESC)+'</td>'
			cItens+='	<td>'+Transform(QRP->DA1_XDESC1,"@E 999.99")+'</td>'
			cItens+='	<td>'+Transform(QRP->DA1_XDESC2,"@E 999.99")+'</td>'
			cItens+='	<td>'+Transform(QRP->DA1_XDESC3,"@E 999.99")+'</td>'
			cItens+='	<td>'+cValtoChar(QRP->DA1_XQTMIN)+'</td>'
			cItens+='	<td>'+cValtoChar(Iif(!empty(QRP->EST) .and. QRP->EST > 0, QRP->EST, 0))+'</td>'
			If HttpSession->Tipo = 'S' 
				//cItens+='	<td>'+cValtoChar(Iif(QRS->EST > 0, QRS->EST, 0))+'</td>' --Removido conforme solicitação do André -Lucilene SMSTI 19/11/21
				cItens+='	<td>'+cValtoChar(Iif(!empty(QRP->EMPENHO) .and. QRP->EMPENHO > 0, QRP->EMPENHO, 0))+'</td>'
			Endif
			cItens+='	<td>'+Transform(QRP->DA1_PRCVEN,PesqPict("DA1","DA1_PRCVEN"))+'</td>'
			cItens+='</tr>'

			nCnt++
			// oObjLog:saveMsg("Montando resposta "+cValToChar(nCnt))
			QRP->(dbSkip())
		EndDo
    EndIf
	
	oObjLog:saveMsg("Vai chamar H_SMSGrid")
	//Retorna o HTML para construção da página 
	cHtml := H_SMSGrid()	
	
	oObjLog:saveMsg("Vai retornar")
Web Extended End

Return (cHTML) 


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GImpEstq    ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦17.07.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Busca o valor de impostos por item.	  					  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function GImpEstq(cProd,cTipoCli,nPreco,nValIcms,nBaseIcms,cAliqICMS,nValST,nBaseST,cAliqST,nValIPI,nBaseIPI,cAliqIPI,cCli,cLoja)
Local _nItem:= 0
Local cTes	:= ""

MaFisEnd()

MaFisIni(cCli,;// 1-Codigo Cliente/Fornecedor
		cLoja,;// 2-Loja do Cliente/Fornecedor
		"C",; // 3-C:Cliente , F:Fornecedor
		"N",; // 4-Tipo da NF
		cTipoCli,;// 5-Tipo do Cliente/Fornecedor
		MaFisRelImp("MTR700",{"SC5","SC6"}),; // 6-Relacao de Impostos que suportados no arquivo
		,;// 7-Tipo de complemento
		,;// 8-Permite Incluir Impostos no Rodape .T./.F.
		"SB1",; // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
		"MTR700")
		

dbSelectArea("SE4")
SE4->(DbSetOrder(1))

dbSelectArea("SB1")
SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1")+cProd))

cTes:= Iif(cTipoCli = "R",GetNewPar("AA_TESREV","511"),GetNewPar("AA_TESCFI",'511'))
conout("tes -->"+cTes)
conout("prod -->"+SB1->B1_COD)
_nItem := MaFisAdd(SB1->B1_COD,; // 1-Codigo do Produto ( Obrigatorio )
					cTes,;// 2-Codigo do TES ( Opcional )
					1,; // 3-Quantidade ( Obrigatorio )
					nPreco,; // 4-Preco Unitario ( Obrigatorio )
					0,; // 5-Valor do Desconto ( Opcional )
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
					
Return		
