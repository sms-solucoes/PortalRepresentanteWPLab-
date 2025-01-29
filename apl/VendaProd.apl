#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ VendaProd   ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦08.12.20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Grid com o estoque de itens por tabela de preço.	  		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function VendaProd()
Local cHtml
Local cFiltro	:= ""
Local cVend	 	:= HttpSession->CodVend
Local cProduto  := ""
Local lPneu		:= .F. 

Private cColunas:= ""
Private cItens	:= ""  
Private cTopo	:= ""  
Private cSite	:= "u_PortalLogin.apw"
Private cPagina	  := "Venda por Produto"
Private cTitle	  := "" 
Private lTableTools:= .T.
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
	lPneu:= .F.
	// Pega do parâmetro com o Titulo do Portal
	cTitle	:= SuperGetMV("PS_TITLE", .T., "Portal SMS")
	
	// Define a funcao a ser chama no link
	cSite	:= Procname()+".apw?PR="+cCodLogin
	
	// Monta o cabeçalho para a pagina
	cHeader := U_PSHeader(cTitle, cSite) 	
	
	//Função que atualiza os menus
	cMenus := U_GetMenus(AllTrim(Upper(Procname())), cVendLogin)
	 
//Tratamento dos filtros
	If type("HttpPost->DataDe") <> "U"
		//Se vazio, usa as datas padrão para evitar erro na query
		If Empty(HttpPost->DataDe) .or. Empty(HttpPost->DataAte)
			cDataDe:= dtos(MonthSub(date(),12))
			cDataAte:= dtos(date())
		Else
			cDataDe:= dtos(ctod(HttpPost->DataDe))
		    cDataAte:= dtos(ctod(HttpPost->DataAte))
		Endif
		//Atualiza as variáveis no valor do filtro
		cFiltDe:= dtoc(stod(cDataDe))
		cFilAte:= dtoc(stod(cDataAte)) 
        cProduto:= Alltrim(HttpPost->produto)
	Else
	    //Variáveis dos input dos filtros
		cFiltDe:= dtoc(MonthSub(date(),1))
		cFilAte:= dtoc(date())
		//Variáveis de filtro da query
		cDataDe:= dtos(MonthSub(date(),1))
		cDataAte:= dtos(date())
	Endif
	
    //Filtros
    cTopo:= '<div class="row form-group">'
    cTopo+= '	<div class="col-sm-12" align="right">'
    cTopo+= '	<form name="formGrid" id="formGrid" method="POST" action="U_VendaProd.apw?PR='+cCodLogin+'">'

    //Data de  	
  	cTopo+= '		<label class="col-md-1 control-label">De:</label>'
    cTopo+= '  		<div class="col-md-2">'
	cTopo+= '		 	<div class="input-group">'
    cTopo+= '    			<span class="input-group-addon">'
    cTopo+= '					<i class="fa fa-calendar"></i>'
    cTopo+= '			    </span>'   
    cTopo+= '				<input data-plugin-datepicker="" data-plugin-options='+"'"+'{"autoclose": "true", "language": "pt-BR",'
	cTopo+= '					"daysOfWeekDisabled": "","daysOfWeekHighlighted":"[0]"}'+"'"+' value="'+cFiltDe+'" ' 
    cTopo+= '					placeholder="__/__/____" id="datade" name="datade" class="form-control only-numbers" type="text"></input>'
    cTopo+= '			</div>'
    cTopo+= '		</div>'       
    
    //Data até
    cTopo+= '		<label class="col-md-1 control-label">Até:</label>'
	cTopo+= '		<div class="col-md-2">'
	cTopo+= '			<div class="input-group">'
    cTopo+= '				<span class="input-group-addon">'
    cTopo+= '					<i class="fa fa-calendar"></i>'
    cTopo+= '				</span>'   
    cTopo+= '				<input data-plugin-datepicker="" data-plugin-options='+"'"+'{"autoclose": "true", "language": "pt-BR",'
	cTopo+= '					"daysOfWeekDisabled": "","daysOfWeekHighlighted":"[0]"}'+"'"+' value="'+cFilAte+'" '
    cTopo+= '					placeholder="__/__/____" id="dataate" name="dataate" class="form-control only-numbers" type="text"></input>'
    cTopo+= '			</div>'
    cTopo+= '		</div>' 
    
    //Produto
    cTopo+= '		<label class="col-md-1 control-label">Produto:</label>'
	cTopo+= '		<div class="col-md-3">'
	cTopo+= '			<select data-plugin-selectTwo class="form-control populate placeholder mb-md" data-plugin-options='+"'"
	cTopo+= '			{ "placeholder": "Selecione...", "allowClear": false }'+"'"+' name="PRODUTO" id="PRODUTO" '
	cTopo+= '			required="" aria-required="true">'
	cTopo+= u_GetProdTB(cProduto)
	cTopo+= '			</select>'
	cTopo+= '		</div>'

	//Botão 
    cTopo+= '		<div class="col-md-2">'
    cTopo+= '			<button class="btn btn-primary" id="btFiltro" value="" onclick="this.value= '+"'"+'Aguarde...'+"'"+';this.disabled= '+"'"+'disabled'+"'"+';Filtro()" name="btFiltro">'
    cTopo+= '			<i class="fa fa-filter"></i> Buscar</button>' 
    cTopo+= '		</div>' 
    cTopo+= '	</form>'
	cTopo+= '	</div>'
	cTopo+= '</div>'
	
	 
	
	//Cabeçalho do grid
	cColunas+='<th>Filial</th>'
	cColunas+='<th>Nota Fiscal</th>'
	cColunas+='<th>Produto</th>'
	cColunas+='<th>Emissão</th>'
	cColunas+='<th>Quantidade</th>'
	cColunas+='<th>Valor Unitário</th>'
	cColunas+='<th>Valor Total</th>'
	cColunas+='<th>Cliente</th>'
	cColunas+='<th>Telefone</th>'
	If HttpSession->Tipo = 'S'
		cColunas+='<th>Vendedor</th>'
	Endif
	


	//Busca as vendas do produto para o período
    cQry := " SELECT D2_FILIAL, D2_EMISSAO, D2_DOC, D2_SERIE, D2_COD, B1_DESC, D2_QUANT, D2_PRCVEN, D2_TOTAL, D2_VALBRUT, "
	cQry += " D2_CLIENTE, D2_LOJA, A1_NOME, A1_NREDUZ, A1_DDD, A1_TEL, F2_VEND1 "
	cQry += " FROM "+RetSqlName("SD2")+"  SD2 "
	cQry += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND SA1.D_E_L_E_T_ = ' ' "
	cQry += " INNER JOIN "+RetSqlName("SF2")+" SF2 ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE "
	cQry += " 	AND F2_LOJA = D2_LOJA AND SF2.D_E_L_E_T_ = ' ' "
    If HttpSession->Tipo = "S" //Supervisor
		cQry += "   AND F2_VEND1 in "+FormatIn(HttpSession->Equipe,"|")+" "
	Else
		cQry += "   AND F2_VEND1 = '"+cVendLogin+"' "
	Endif
	cQry += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_COD = D2_COD AND SB1.D_E_L_E_T_ = ' ' "
	cQry += " WHERE D2_EMISSAO BETWEEN '"+cDataDe+"' and '"+cDataAte+"' " 
	
		cQry += " AND D2_COD = '"+cProduto+"' "
	
	cQry += " AND SD2.D_E_L_E_T_ = ' ' "
	cQry += " Order by D2_EMISSAO, D2_DOC, D2_ITEM " 

	conout("@@@ query6:" + cQry)
	
	cQry := ChangeQuery(cQry)
		
	If Select("QRP") > 0
		QRP->(dbCloseArea())
	Endif	 	
	APWExOpenQuery(ChangeQuery(cQry),'QRP',.T.)
	 
	// Preenche o select de produtos
	While QRP->(!Eof())
        
		cItens+='<tr>'
	    cItens+='	<td>'+Alltrim(QRP->D2_FILIAL)+'</td>'
	    cItens+='	<td>'+Alltrim(QRP->D2_DOC)+"/"+Alltrim(QRP->D2_SERIE)+'</td>'
	    cItens+='	<td>'+Alltrim(QRP->D2_COD)+" - "+Alltrim(QRP->B1_DESC)+'</td>'
        cItens+='	<td>'+DTOC(STOD(QRP->D2_EMISSAO))+'</td>'
	    cItens+='	<td>'+cValtoChar(QRP->D2_QUANT)+'</td>'
		cItens+='	<td>'+Transform(QRP->D2_PRCVEN,PesqPict("SD2","D2_PRCVEN"))+'</td>'
		cItens+='	<td>'+Transform(QRP->D2_TOTAL,PesqPict("SD2","D2_TOTAL"))+'</td>'
        cItens+='	<td>'+Alltrim(QRP->D2_CLIENTE)+"/"+Alltrim(QRP->D2_LOJA)+" - "+Alltrim(QRP->A1_NOME)+'</td>'
        cItens+='	<td>('+Alltrim(QRP->A1_DDD)+") "+Alltrim(QRP->A1_TEL)+'</td>'
        If HttpSession->Tipo = 'S'
	    	cItens+='	<td>'+QRP->F2_VEND1+' - '+Posicione("SA3",1,xFilial("SA3")+QRP->F2_VEND1,"A3_NREDUZ")+'</td>'
	    Endif
		cItens+='</tr>'


		QRP->(dbSkip())
    End
	

	//Retorna o HTML para construção da página 
	cHtml := H_SMSGrid()	
	
Web Extended End

Return (cHTML) 


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetProd    ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦17.07.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Busca os produtos das tabelas de preço  					  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function GetProdTB(cFiltro)
Local cRet:= ""
Local cEstVend:= ""

cRet+='<option value=""></option>'
	//Busca os itens da tabela de preço
	cQry:="Select DA1_CODPRO, B1_DESC " 
	cQry+=" From "+RetSqlName("DA0")+" DA0"
	cQry+=" Inner Join "+RetSqlName("DA1")+" DA1 ON DA1_FILIAL = DA0_FILIAL AND DA1_CODTAB = DA0_CODTAB AND DA1.D_E_L_E_T_ = ' ' "
	cQry+=" Inner Join "+RetSqlName("SB1")+" SB1 ON B1_COD = DA1_CODPRO AND SB1.D_E_L_E_T_ = ' ' "
	cQry+=" INNER JOIN "+RetSqlName("SA1")+" SA1 ON "
	// If HttpSession->Tipo = "S" //Supervisor
	// 	cQry+=" A1_VEND in "+FormatIn(HttpSession->Equipe,"|")+" "
	// Else
		cQry+=" A1_VEND = '"+HttpSession->CodVend+"'
	// Endif
	cQry+=" AND A1_MSBLQL <> '1' AND SA1.D_E_L_E_T_ = ' ' "
	cQry+=" Where "
	cQry+="  DA0_CODTAB = A1_TABELA "
	cQry+=" AND DA0_ATIVO = '1' "
	cQry+=" AND DA0.D_E_L_E_T_ = ' ' "

	cQry+=" UNION ALL "	
	
	//Tabela de preço de campanha
	cQry:= "SELECT DA1_CODPRO, B1_DESC "
	cQry+= "FROM "+RetSqlName("DA0")+" DA0 "
	cQry+=" Inner Join "+RetSqlName("DA1")+" DA1 ON DA1_FILIAL = DA0_FILIAL AND DA1_CODTAB = DA0_CODTAB AND DA1.D_E_L_E_T_ = ' ' "
	cQry+=" Inner Join "+RetSqlName("SB1")+" SB1 ON B1_COD = DA1_CODPRO AND SB1.D_E_L_E_T_ = ' ' "
	cQry+= "WHERE '
	cQry+= "SUBSTRING(DA0_CODTAB,1,1) = 'C' "
	cQry+= "AND DA0_DATDE <= '"+DTOS(dDataBase)+"' "
	cQry+= "AND DA0_DATATE >= '"+DTOS(dDataBase)+"' "
	cQry+= "AND DA0.D_E_L_E_T_ = ' ' "

	cQry+=" UNION ALL "	
	
	//Tabela de preço do grupo de vendas
	cQry:= "SELECT DA1_CODPRO, B1_DESC "
	cQry+= "FROM "+RetSqlName("DA0")+" DA0 "
	cQry+=" Inner Join "+RetSqlName("DA1")+" DA1 ON DA1_FILIAL = DA0_FILIAL AND DA1_CODTAB = DA0_CODTAB AND DA1.D_E_L_E_T_ = ' ' "
	cQry+=" Inner Join "+RetSqlName("SB1")+" SB1 ON B1_COD = DA1_CODPRO AND SB1.D_E_L_E_T_ = ' ' "
	
	
	//Busca os estados dos clientes
	cQryEst:= "Select DISTINCT A1_EST "
	cQryEst+= "FROM "+RetSqlName("SA1")+" SA1 "
	cQryEst+= "Where SA1.D_E_L_E_T_ = ' ' "
	// If HttpSession->Tipo = "S" //Supervisor
	// 	cQryEst+=" A1_VEND in "+FormatIn(HttpSession->Equipe,"|")+" "
	// Else
		cQryEst+=" AND A1_VEND = '"+HttpSession->CodVend+"'
	// Endif

	conout("@@@ query2:" + cQryEst)

	If Select("QEST") > 0
		QEST->(dbCloseArea())
	Endif
	TcQuery cQryEst New Alias "QEST"	

	While QEST->(!Eof())
		cEstVend+= QEST->A1_EST+"/"
		QEST->(dbSkip())
	End			

	cQry+= "WHERE "
	cQry+= " DA0_ATIVO = '1' " 
	cQry+= "AND DA0.D_E_L_E_T_ = ' ' "
	

	cQry+=" Group by DA1_CODPRO, B1_DESC " 

	conout("@@@ query3:" + cQry)
	
	If Select("QRT") > 0
		QRT->(dbCloseArea())
	Endif	 	
	APWExOpenQuery(ChangeQuery(cQry),'QRT',.T.)

	While QRT->(!Eof())
		cRet+= '<option value="'+Alltrim(QRT->DA1_CODPRO)+'" '+Iif(Alltrim(QRT->DA1_CODPRO) = cFiltro,"selected","")+'>'+Alltrim(QRT->DA1_CODPRO)+" - "+Alltrim(QRT->B1_DESC)+'</option>' 
		QRT->(dbSkip())
	End


Return cRet	
