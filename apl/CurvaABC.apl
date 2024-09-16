#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ CurvaABC    ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦24.06.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Curva ABC das vendas do período.	         				  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function CurvaABC()
Local cHtml
Local cDataDe	:= ""
Local cDataAte	:= ""
Local cFiltDe	:= ""
Local cFilAte	:= ""
Local cCliente	:= ""
Local nTotal	:= 0
Local nAcum		:= 0
Local nPerAcum	:= 0
Local nPercA	:= 80
Local nPercB	:= 15
Local nPercC	:= 5
                   
Private cColunas:= ""
Private cItens	:= ""  
Private cTopo	:= ""  
Private cSite	:= "u_PortalLogin.apw"
Private cPagina	:= "Curva ABC"
Private cTitle	:= "" 
Private lTableTools:= .F.
Private lSidebar:= .F.
Private lNoSorting:= .T.
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
	cSite	:= "u_SMSPortal.apw?PR="+cCodLogin
	
	// Monta o cabeçalho para a pagina
	cHeader := U_PSHeader(cTitle, cSite) 	
	
	//Função que atualiza os menus
	cMenus := U_GetMenus(AllTrim(Upper(Procname())), cVendLogin)
	 
	//Tratamento dos filtros de Data
	If type("HttpPost->DataDe") <> "U"
		//Se vazio, usa as datas padrão para evitar erro na query
		If Empty(HttpPost->DataDe) .or. Empty(HttpPost->DataAte)
			cDataDe:= dtos(date()-30)
			cDataAte:= dtos(date())
		Else
			cDataDe:= dtos(ctod(HttpPost->DataDe))
		    cDataAte:= dtos(ctod(HttpPost->DataAte))
		Endif
		//Atualiza as variáveis no valor do filtro
		cFiltDe:= dtoc(stod(cDataDe))
		cFilAte:= dtoc(stod(cDataAte)) 
	Else
	    //Variáveis dos input dos filtros
		cFiltDe:= dtoc(date()-30)
		cFilAte:= dtoc(date())
		//Variáveis de filtro da query
		cDataDe:= dtos(date()-30)
		cDataAte:= dtos(date())
	Endif
	
	
	If type("HttpPost->PERC_A") <> "U"
		If !Empty(HttpPost->PERC_A) .and. !Empty(HttpPost->PERC_B) .and. !Empty(HttpPost->PERC_C)
	 	 	nPercA:= Val(HttpPost->PERC_A)
	 	 	nPercB:= Val(HttpPost->PERC_B)
	 	 	nPercC:= Val(HttpPost->PERC_C)
	 	Endif
	Endif
	
	
    //Filtros
    cTopo:= '<div class="row form-group">'
    cTopo+= '	<div class="col-sm-12" align="right">'
    cTopo+= '	<form name="formGrid" id="formGrid" method="POST" action="U_CurvaABC.apw?PR='+cCodLogin+'">'
      	
  	cTopo+= '		<label class="col-sm-1 control-label">De:</label>'
    cTopo+= '  		<div class="col-sm-3">'
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
	cTopo+= '		<div class="col-md-3">'
	cTopo+= '			<div class="input-group">'
    cTopo+= '				<span class="input-group-addon">'
    cTopo+= '					<i class="fa fa-calendar"></i>'
    cTopo+= '				</span>'   
    cTopo+= '				<input data-plugin-datepicker="" data-plugin-options='+"'"+'{"autoclose": "true", "language": "pt-BR",'
	cTopo+= '					"daysOfWeekDisabled": "","daysOfWeekHighlighted":"[0]"}'+"'"+' value="'+cFilAte+'" '
    cTopo+= '					placeholder="__/__/____" id="dataate" name="dataate" class="form-control only-numbers" type="text"></input>'
    cTopo+= '			</div>'
    cTopo+= '		</div>' 

    cTopo+= '		<br>'       
    cTopo+= '		<br>'       
    cTopo+= '		<div class="col-sm-10" align="right">'       
  
    cTopo+= '			<label class="col-sm-1 control-label">% A:</label>'
	cTopo+= '			<div class="col-md-2">'
	cTopo+= '				<input class="form-control text-right only-numbers" id="PERC_A" name="PERC_A" type="text" value="'+cValtoChar(nPercA)+'"></input>'
    cTopo+= '			</div>'   
	
    cTopo+= '			<label class="col-sm-1 control-label">% B:</label>'
	cTopo+= '			<div class="col-md-2">'
	cTopo+= '				<input class="form-control text-right only-numbers" id="PERC_B" name="PERC_B" type="text" value="'+cValtoChar(nPercB)+'"></input>'
    cTopo+= '			</div>'     
    
    cTopo+= '			<label class="col-sm-1 control-label">% C:</label>'
	cTopo+= '			<div class="col-md-2">'
	cTopo+= '				<input class="form-control text-right only-numbers" id="PERC_C" name="PERC_C" type="text" value="'+cValtoChar(nPercC)+'"></input>'
    cTopo+= '			</div>' 
    cTopo+= '		</div>' 
       
    cTopo+= '		<div class="col-sm-2">'
    cTopo+= '			<button class="btn btn-primary" id="btFiltroP" value="" onclick="this.value= '+"'"+'Aguarde...'+"'"+';this.disabled= '+"'"+'disabled'+"'"+';Filtro()" name="btFiltro">'
    cTopo+= '			<i class="fa fa-filter"></i> Filtrar</button>' 
    cTopo+= '		</div>' 
    cTopo+= '	</form>'
	cTopo+= '	</div>'
	cTopo+= '</div>'
	
	
	// Busca as vendas
	cQry := " SELECT F2_CLIENTE, F2_LOJA, A1_NOME, SUM(F2_VALFAT) VALOR, A1_VEND VEND "
	cQry += " FROM "+RetSqlName("SF2")+"  SF2 "
	cQry += " INNER JOIN "+RetSqlName("SA1")+"  SA1 ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND SA1.D_E_L_E_T_ = ' ' "
	If HttpSession->Tipo = 'S' //Supervisor acessa todas as informações da sua equipe
    	cQry+= " WHERE F2_VEND1 in "+FormatIn(HttpSession->Equipe,"|")+" "
	Else
//		cQry += " WHERE F2_VEND1 = '"+HttpSession->CodVend+ "' "
		cQry += " WHERE F2_VEND1 = '"+cVendLogin+ "' "
	Endif
	cQry += " AND F2_EMISSAO BETWEEN '"+cDataDe+"' and '"+cDataAte+"' " 
	cQry += " AND SF2.D_E_L_E_T_ = ' ' "
	cQry += " Group by F2_CLIENTE, F2_LOJA, A1_NOME, A1_VEND "
	cQry += " Order by SUM(F2_VALFAT) DESC "
	cQry := ChangeQuery(cQry)
	
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	Endif	
	APWExOpenQuery(ChangeQuery(cQry),'QRY',.T.)
	
	//Cabeçalho do grid
	cColunas+='<th></th>'
	cColunas+='<th>Cliente</th>'
	cColunas+='<th>Nome</th>'
	cColunas+='<th>Valor</th>' 
	cColunas+='<th>%</th>' 
	cColunas+='<th>% Acumulado</th>' 
	If HttpSession->Tipo = 'S' //Supervisor 
    	cColunas+='<th>Vendedor</th>'
	Endif
	     
	While QRY->(!Eof())
		nTotal+= QRY->VALOR
		QRY->(dbSkip())
	End	
	
	QRY->(dbGoTop())
	
	nAcum:= QRY->VALOR
	While QRY->(!Eof())
	
		nPerAcum:= Round((nAcum/nTotal)*100,2)
		
		If nPerAcum <= nPercA //a <= 80
			cCliente:= 'A'
		Elseif nPerAcum > nPercA  .and. nPerAcum <= nPercA+nPercB  //b > 80 <=95
			cCliente:= 'B'
		Elseif nPerAcum > nPercA+nPercB //c > 95	
			cCliente:= 'C'
		Endif
				
		cItens+='<tr>'
	    cItens+='	<td><img src="images/cliente'+cCliente+'.png" width="20"></td>'
	    cItens+='	<td>'+trim(QRY->F2_CLIENTE+"/"+QRY->F2_LOJA)+'</td>'
	    cItens+='	<td>'+QRY->A1_NOME+'</td>'
	    cItens+='	<td align="right">'+TransForm(QRY->VALOR ,"@E 999,999,999.99")+'</td>'
		cItens+='   <td align="right">'+TransForm((QRY->VALOR/nTotal)*100,"@E 999.99")+'</td>'  
		cItens+='   <td align="right">'+TransForm(nPerAcum,"@E 999.99")+'</td>' 
		If HttpSession->Tipo = 'S' //Supervisor
	    	cItens+='	<td>'+QRY->VEND+' - '+Posicione("SA3",1,xFilial("SA3")+QRY->VEND,"A3_NREDUZ")+'</td>'
	    Endif 
	    cItens+='</tr>'
	 
		QRY->(dbSkip())
		//Atualiza o valor Acumulado
		nAcum+= QRY->VALOR
	End
	
	//Retorna o HTML para construção da página 
	cHtml := H_SMSGrid()	
	
Web Extended End

Return (cHTML) 
