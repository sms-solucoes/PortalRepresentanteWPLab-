#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ Vendas      ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦25.06.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Grid com as vendas dos últimos 12 meses do vendedor.		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function Vendas()
Local cHtml
Local cDataDe	:= ""
Local cDataAte	:= ""
Local cFiltDe	:= ""
Local cFilAte	:= ""
Local cFiltro	:= ""
Local nMesAtu	:= 0
Local nMeses	:= 0
Local nPos		:= 0
Local aMeses	:= {}
Local aVendas	:= {}
Local i,x 
                   
Private cColunas:= ""
Private cItens	:= ""  
Private cTopo	:= ""  
Private cDetCol	:= ""  
Private cDetItm	:= ""  
Private cOrdem	:= ""  
Private cSite	:= "u_PortalLogin.apw"
Private cPagina	:= "Vendas 12 meses"
Private cTitle	:= "" 
Private	nColOrd	:= 0
Private	nOrdDet	:= 0
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
	// Else
	// 	If !Empty(HttpSession->Superv) .and. HttpSession->Superv <> HttpSession->CodVend
	// 		HttpSession->CodVend:= HttpSession->Superv
	// 	Endif
	
	// Pega do parâmetro com o Titulo do Portal
	cTitle	:= SuperGetMV("PS_TITLE", .T., "Portal SMS")
	
	// Define a funcao a ser chama no link
	cSite	:= "u_SMSPortal.apw?PR="+cCodLogin
	
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
		cFiltro:= HttpPost->tipoFiltro 
	Else
	    //Variáveis dos input dos filtros
		cFiltDe:= dtoc(MonthSub(date(),12))
		cFilAte:= dtoc(date())
		//Variáveis de filtro da query
		cDataDe:= dtos(MonthSub(date(),12))
		cDataAte:= dtos(date())
		cFiltro:= '1'   //1=Nota Fiscal, 2=Produto
	Endif
	 
	//Define a ordem da tabela de detalhes
	If cFiltro = '1'
		nOrdDet:=  1
		cOrdem:=  "'asc'"
	Else
		nOrdDet:=  3
		cOrdem:=  "'desc'"
	Endif
			
    //Filtros
    cTopo:= '<div class="row form-group">'
    cTopo+= '	<div class="col-sm-12" align="right">'
    cTopo+= '	<form name="formGrid" id="formGrid" method="POST" action="U_Vendas.apw?PR='+cCodLogin+'">'
      	
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
    
    cTopo+= '		<label class="col-md-1 control-label">Detalhar:</label>'
	cTopo+= '  		<div class="col-sm-2">'
	cTopo+= '		 	<div class="input-group">'
	cTopo+= '				<select data-plugin-selectTwo class="form-control populate mb-md" name="tipofiltro" id="tipofiltro" '
	cTopo+= ' 				data-plugin-options='+"'"+'{"minimumResultsForSearch": "-1"}'+"'"+' required="" aria-required="true" value="'+cFiltro+'">'
	cTopo+= '					<option value="1"'+Iif(cFiltro='1',' selected','')+'>Nota Fiscal</option>'
	cTopo+= '					<option value="2"'+Iif(cFiltro='2',' selected','')+'>Produto</option>'
    cTopo+= '				</select>'
    cTopo+= '			</div>'
    cTopo+= '		</div>' 
     
    cTopo+= '		<div class="col-md-2">'
    cTopo+= '			<button class="btn btn-primary" id="btFiltro" value="" onclick="this.value= '+"'"+'Aguarde...'+"'"+';this.disabled= '+"'"+'disabled'+"'"+';Filtro(this)" name="btFiltro">'
    cTopo+= '			<i class="fa fa-filter"></i> Filtrar</button>' 
    cTopo+= '		</div>' 
    cTopo+= '	</form>'
	cTopo+= '	</div>'
	cTopo+= '</div>'
	
	
	//Calcula a quantidade de meses do período
	nMeses:= DateDiffMonth(stod(cDataDe),stod(cDataAte))+1
	
	For i:= 1 to nMeses
   		dMesAtu:= MonthSum(stod(cDataDe),i-1)
   		nMesAtu:= Month(dMesAtu)
		aAdd(aMeses,Substr(dtos(dMesAtu),1,6))
	Next
	    
	//Cabeçalho do grid
	cColunas+='<th>Cliente</th>'
	cColunas+='<th'+Iif(HttpSession->Tipo = "V",' hidden','')+'>Vendedor</th>'
	cColunas+= '<th>Total</th>'
    For x:= 1 to Len(aMeses)
    	cColunas+= '<th>'+Substr(Upper(MesExtenso(stod(aMeses[x]+'01'))),1,3) +"/"+ Alltrim(str(Year(stod(aMeses[x]+'01'))))+'</th>'
    Next
	cColunas+= '<th hidden></th>'
	nColOrd:=  Len(aMeses)+3  //Coluna oculta para ordenação
	
	If type("HttpPost->DataDe") <> "U"
	
		//Busca o acumulado de vendas para o período
		cQryA := " SELECT F2_CLIENTE CLIENTE, F2_LOJA LOJA, A1_NOME NOME, SUM(F2_VALFAT) VALOR, A1_VEND "
		cQryA += " FROM "+RetSqlName("SF2")+"  SF2 "
		cQryA += " INNER JOIN "+RetSqlName("SA1")+"  SA1 ON A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND SA1.D_E_L_E_T_ = ' ' "
		If HttpSession->Tipo = 'S' //Supervisor acessa todas as informações da sua equipe
	    	cQryA+= " WHERE F2_VEND1 in "+FormatIn(HttpSession->Equipe,"|")+" "
		Else
			cQryA += " WHERE F2_VEND1 = '"+cVendLogin+ "' "
		Endif
		cQryA += " AND F2_EMISSAO BETWEEN '"+cDataDe+"' and '"+cDataAte+"' " 
		cQryA += " AND SF2.D_E_L_E_T_ = ' ' "
		cQryA += " Group by F2_CLIENTE, F2_LOJA, A1_NOME, A1_VEND "
		cQryA += " Order by SUM(F2_VALFAT) DESC "
		cQryA := ChangeQuery(cQryA)
		If Select("QRA") > 0
			QRA->(dbCloseArea())
		Endif	

		conout("@@@ query5:" + cQryA)

		APWExOpenQuery(ChangeQuery(cQryA),'QRA',.T.)
		
		nLin:= 0
		
		//Linha com totais
		//aAdd(aVendas,array(nMeses+3))
		//aVendas[1,1]:= "TOTAIS"
		
		While QRA->(!Eof())
			nLin++
			
		    //Adiciona um array vazio com a qtde de meses
		 	aAdd(aVendas,array(nMeses+4)) 
		 	
		 	//Adiciona o cliente na primeira posição
		 	aVendas[nLin,1]:= QRA->CLIENTE+"/"+QRA->LOJA +" - "+ Alltrim(QRA->NOME) 
		 	aVendas[nLin,2]:= QRA->A1_VEND+" - "+Posicione("SA3",1,xFilial("SA3")+QRA->A1_VEND,"A3_NOME")
		 	
			// Busca as vendas para este cliente
			cQry := " SELECT SUBSTRING(F2_EMISSAO,1,6) ANOMES, SUM(F2_VALFAT) VALOR "
			cQry += " FROM "+RetSqlName("SF2")+"  SF2 "
			If HttpSession->Tipo = 'S' //Supervisor acessa todas as informações da sua equipe
	    		cQry+= " WHERE F2_VEND1 in "+FormatIn(HttpSession->Equipe,"|")+" "
	    	Else	
//				cQry += " WHERE F2_VEND1 = '"+HttpSession->CodVend+"' "
				cQry += " WHERE F2_VEND1 = '"+cVendLogin+"' "
			Endif
			cQry += " AND F2_EMISSAO BETWEEN '"+cDataDe+"' and '"+cDataAte+"' " 
			cQry += " AND F2_CLIENTE = '"+QRA->CLIENTE+"' " 
			cQry += " AND F2_LOJA = '"+QRA->LOJA+"' " 
			cQry += " AND SF2.D_E_L_E_T_ = ' ' "
			cQry += " Group by SUBSTRING(F2_EMISSAO,1,6) "
			cQry += " Order by SUBSTRING(F2_EMISSAO,1,6) "
			cQry := ChangeQuery(cQry)

			conout("@@@ query6:" + cQry)
			
			If Select("QRY") > 0
				QRY->(dbCloseArea())
			Endif	
	   		APWExOpenQuery(ChangeQuery(cQry),'QRY',.T.)
		    
		
		    //Percorre as vendas do cliente e preenche a coluna do mês
			While QRY->(!Eof())
			
				nPos:= aScan(aMeses,{|x| x == QRY->ANOMES})+3
				If nPos > 0
					aVendas[nLin,nPos] := TransForm(QRY->VALOR ,"@E 999,999,999.99")
					
				   //	aVendas[1,nPos] := TransForm(QRY->VALOR ,"@E 999,999,999.99")
				Endif 
			
				QRY->(dbSkip())
			End
			aVendas[nLin,3]:= TransForm(QRA->VALOR,"@E 999,999,999.99")  // total  
			aVendas[nLin,Len(aVendas[nLin])]:= cvaltochar(nLin)     
		
			QRA->(dbSkip())
		End
			
		For i:= 1 to Len(aVendas)
			cCliente:= Alltrim(Substr(aVendas[i,1],1,At("/",aVendas[i,1])-1)) 
			cLoja:= Alltrim(Substr(aVendas[i,1],At("/",aVendas[i,1])+1,4))
//	
			cItens+='<tr>' //role="button" data-toggle="modal" data-target="#myModal"
		    cItens+='	<td>'+aVendas[i,1]+'</td>'
		    cItens+='	<td'+Iif(HttpSession->Tipo = "V",' hidden','')+'>'+aVendas[i,2]+'</td>'
		    For x:= 3 to nMeses+4    // x-> gera os TD a partir da segunda posição do aVendas 
		    	If x = 3 //Total do período
		    		cOnClick:= 'onclick="detVendas('+"'"+cCliente+"|"+cLoja+"|"+cDataDe+"|"+cDataAte+"|"+cFiltro+"'"+');"' 
		    	Elseif (x > 3 .and. x < nMeses+3) .or. x = nMeses+3 // Valores dos meses
		    		cPerDe:= Iif(x=4,cDataDe,dtos(FirstDay(stod(aMeses[x-3]+'01')))) //Se mes inicial, utiliza dia informado no parametro	
		    		cPerAte:= Iif(x=nMeses+3,cDataAte,dtos(LastDay(stod(aMeses[x-3]+'01'))))	 //Se mês final, utiliza dia informado no parametro
		    		cOnClick:= 'onclick="detVendas('+"'"+cCliente+"|"+cLoja+"|"+cPerDe+"|"+cPerAte+"|"+cFiltro+"'"+');"' 
		    	Else
		    		cOnClick:= ""
		    	Endif	
		    	cItens+='	<td align="right" '+Iif(x = Len(aVendas[i]),'hidden',cOnClick)+'>'+Iif(aVendas[i,x] == nil,"0,00",aVendas[i,x])+'</td>'
		    Next	   
		    cItens+='</tr>'
		Next
		
		//Detalhe das vendas 
		If cFiltro = '1' //Detalhamento por nota fiscal
			cDetCol+= '			<th>Filial</th>'
			cDetCol+= '			<th>Emissao</th>'
			cDetCol+= '			<th>Nota</th>'
			cDetCol+= '			<th>Valor</th>'
			cDetCol+= '			<th>Quantidade</th>'
	    Else
		    cDetCol+= '			<th>Produto</th>'
			cDetCol+= '			<th>Descrição</th>'
			cDetCol+= '			<th>Valor</th>'
			cDetCol+= '			<th>Quantidade</th>'
	    Endif
		    
	Endif
		
	//Retorna o HTML para construção da página 
	cHtml := H_Vendas()	
	
Web Extended End

Return (cHTML) 


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetDetVen   ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦25.06.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Detalhe das vendas do período.		  					  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function GetDetVen()
Local cHtml		:= ""
Local cRet		:= ""
Local cParam	:= Alltrim(HttpPost->parametros)
Local cCliente	:= ""
Local cLoja		:= ""
Local cDataDe	:= ""
Local cDataAte	:= ""
Local cFiltro	:= ""
Local cNf		:= ""
Local cDetNf	:= ""
Local aParam	:= {}
Local nItem		:= 0
Local nQtdNfs	:= 0
Local nValNf	:= 0
Local nQtdNf	:= 0
Private cDetItm	:= ""
Private cCodLogin := ""
Private cVendLogin:= ""

Web Extended Init cHtml Start U_inSite()

	cVendLogin := u_GetUsrPR()
	cCodLogin  := U_SetParPR(cVendLogin)

	//Ajusta os parametros
    aParam:= StrTokArr(cParam,"|")
    cCliente:= Alltrim(aParam[1])
    cLoja:= Alltrim(aParam[2])
    cDataDe := Alltrim(aParam[3])
    cDataAte := Alltrim(aParam[4]) 
    cFiltro := Alltrim(aParam[5]) 


	// Busca as vendas para este cliente
	If cFiltro = '1'    //detalhe por nota fiscal
		cQry := " SELECT D2_FILIAL, D2_EMISSAO, D2_DOC, D2_ITEM, D2_COD, B1_DESC, D2_QUANT, D2_TOTAL, D2_VALBRUT "
	Else   //detalhe por produto
		cQry := " SELECT D2_COD, B1_DESC, sum(D2_QUANT) D2_QUANT, SUM(D2_TOTAL) D2_TOTAL, SUM(D2_VALBRUT) D2_VALBRUT "
	Endif
	cQry += " FROM "+RetSqlName("SD2")+"  SD2 "
	cQry += " INNER JOIN "+RetSqlName("SF2")+" SF2 ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE "
	cQry += " 	AND F2_LOJA = D2_LOJA  AND SF2.D_E_L_E_T_ = ' ' "
	If HttpSession->Tipo = "S" //Supervisor
	 	cQry += "   AND F2_VEND1 in "+FormatIn(HttpSession->Equipe,"|")+" "
	Else
		cQry += "   AND F2_VEND1 = '"+cVendLogin+"' "
	Endif
	cQry += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = SUBSTRING(D2_FILIAL,1,4) AND B1_COD = D2_COD AND SB1.D_E_L_E_T_ = ' ' "
	cQry += " WHERE D2_EMISSAO BETWEEN '"+cDataDe+"' and '"+cDataAte+"' " 
	cQry += " AND D2_CLIENTE = '"+cCliente+"' " 
	cQry += " AND D2_LOJA = '"+cLoja+"' " 
	cQry += " AND SD2.D_E_L_E_T_ = ' ' "
	If cFiltro = '1'
		cQry += " Order by D2_EMISSAO, D2_DOC, D2_ITEM " 
	Else
		cQry += " Group by D2_COD, B1_DESC " 
		cQry += " Order by SUM(D2_QUANT) DESC " 
	Endif
	
	cQry := ChangeQuery(cQry)
	conout("@@@ query7:" + cQry)

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	Endif	
 	APWExOpenQuery(ChangeQuery(cQry),'QRY',.T.)
 	
 	nQtdQry:= Contar("QRY","!Eof()")
 	QRY->(dbGoTop())
	
	cDetItm := "["

 	//Detlhamento por nota fiscal
 	If cFiltro = '1'
	 	cNf:= QRY->D2_FILIAL+QRY->D2_DOC
	 	cEmissao:= dtoc(stod(QRY->D2_EMISSAO))
 	
 	
	 	While QRY->(!Eof()) 
	 		nItem++
	        
	        
	      	nValNf+=QRY->D2_VALBRUT
	      	nQtdNf+= QRY->D2_QUANT
	      	
	      	If nItem > 1
				cDetNF+= ','
			Endif
		 	cDetNF+= ' {'
		 	cDetNF+= '  "codigo":"'+alltrim(QRY->D2_COD)+'",'
		 	cDetNF+= '  "descricao":"'+alltrim(QRY->B1_DESC)+'",'
		 	cDetNF+= '  "valor":"'+TransForm(QRY->D2_VALBRUT,"@E 999,999,999.99")+'",'
		 	cDetNF+= '  "qtd":"'+cvaltochar(QRY->D2_QUANT)+'"'
		 	cDetNF+= ' }'
		 	
		 	QRY->(dbSkip())
		 	
		 	
		 	If cNf <> QRY->D2_FILIAL+QRY->D2_DOC .or. nItem == nQtdQry
	      
	      		nQtdNfs++
	      		
				If nQtdNfs > 1
					cDetItm+= ','
				Endif
			 	cDetItm+= '	{"cel": "",'
			 	cDetItm+= '  "filial": "'+Substr(cNf,1,6)+'",'
			 	cDetItm+= '  "emissao": "'+cEmissao+'",'
			 	cDetItm+= '  "doc": "'+SubStr(cNf,7)+'",'
			 	cDetItm+= '  "total": "'+TransForm(nValNf,"@E 999,999,999.99")+'",'
			 	cDetItm+= '  "quant": "'+cvaltochar(nQtdNf)+'",'
			 	cDetItm+= '  "detalhe": ['
			 	cDetItm+= cDetNF
			 	cDetItm+= ' ]'
			 	cDetItm+= '	}' 
			 	
			 	nValNf:= 0
	      		nQtdNf:= 0
	      		nItem := 0
			 	cDetNF:= ""
	      		cNf:= QRY->D2_FILIAL+QRY->D2_DOC
	      		cEmissao:= dtoc(stod(QRY->D2_EMISSAO))
		 	Endif
		 	
	 	End
 	
 	Else //Detalhaento por produto 
 		nItem:= 0
 		While QRY->(!Eof())
 			nItem++
 			
 			If nItem > 1
				cDetItm+= ','
			Endif
		 	cDetItm+= '	{"cel": "",'
		 	cDetItm+= '  "produto": "'+alltrim(QRY->D2_COD)+'",'
		 	cDetItm+= '  "descricao": "'+alltrim(QRY->B1_DESC)+'",
		 	cDetItm+= '  "total": "'+TransForm(QRY->D2_VALBRUT,"@E 999,999,999.99")+'",'
		 	cDetItm+= '  "quant": "'+cvaltochar(QRY->D2_QUANT)+'",'
		 	cDetItm+= '  "detalhe": ['
		 	cDetItm+= cDetNF
		 	cDetItm+= ' ]'
		 	cDetItm+= '	}' 
 			
 			
 	    	QRY->(dbSkip())
 	    End
 	Endif                  
 	
 	cDetItm+=']'
						 	 
Web Extended End
	   		
Return cDetItm
