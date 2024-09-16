#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ Comissoes   ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦24.02.20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Grid com as comissoes do vendedor.				  		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function Comissoes()
Local cHtml
//Local cFiltro	:= ""
Local cDataDe	:= ""
Local cDataAte	:= ""
Local cVendedor := ""
Local nValTit	:= 0
Local nTotalCom := 0
                      
Private cColunas:= ""
Private cItens	:= ""  
Private cTopo	:= ""  
Private cSite	:= "u_PortalLogin.apw"
Private cPagina	  := "Comissões"
Private cTitle	  := "" 
Private lTableTools:= .T.
Private lSidebar:= .T.
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
	
	//Função que atualiza os menus
	cMenus := U_GetMenus(AllTrim(Upper(Procname())), cVendLogin)
	 
	//Tratamento dos filtros
	If type("HttpPost->DataDe") <> "U"
		//Se vazio, usa as datas padrão para evitar erro na query
		If Empty(HttpPost->DataDe) .or. Empty(HttpPost->DataAte)
			cDataDe:= dtos(FirstDay(date()))
			cDataAte:= dtos(LastDay(date()))
		Else
			cDataDe:= dtos(ctod(HttpPost->DataDe))
		    cDataAte:= dtos(ctod(HttpPost->DataAte))
		Endif
		//Atualiza as variáveis no valor do filtro
		cFiltDe:= dtoc(stod(cDataDe))
		cFilAte:= dtoc(stod(cDataAte)) 
		cVendedor:= HttpPost->vendedor   
	Else
	    //Variáveis dos input dos filtros
		cFiltDe:= dtoc(FirstDay(date()))
		cFilAte:= dtoc(LastDay(date()))
		//Variáveis de filtro da query
		cDataDe:= dtos(FirstDay(date()))
		cDataAte:= dtos(LastDay(date()))
		//cFiltro:= '1'   //1=Pagas, 2=Vencto
	Endif
	
    //Filtros
    cTopo:= '<div class="row form-group">'
    cTopo+= '	<div class="col-sm-12" align="right">'
    cTopo+= '	<form name="formGrid" id="formGrid" method="POST" action="U_Comissoes.apw?PR='+cCodLogin+'">'
  	
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

	//Supervisor habilita o campo de vendedores
	If HttpSession->Tipo = 'S'
		cTopo+= '<div class="row form-group">'
		cTopo+= '	<div class="col-lg-4">'
		//cTopo+= '		<label class="control-label">Representante</label>'
	 	cTopo+= '		<select data-plugin-selectTwo class="form-control populate placeholder" data-plugin-options='+"'"
		cTopo+= '{ "placeholder": "Selecione um Representante", "allowClear": false }'+"'"+' name="vendedor" id="vendedor" value="'+cVendedor+'"'
		cTopo+= 'required="" aria-required="true"> '
		If !Empty(cVendedor)
			cTopo+= '				<option value="'+cVendedor+'" selected>'+cVendedor+' - '+Upper(Alltrim(Posicione("SA3",1,xFilial("SA3")+cVendedor,"A3_NOME")))+'</option>' 
		Else
			cTopo+= '				<option value=""></option>'
		Endif 
		
		aVends:= Separa(HttpSession->Representantes,"|")
		//Adiciona o supervisor
		If !Empty(HttpSession->Superv) .and. cVendedor <> HttpSession->Superv
			cTopo+='		<option value="'+Alltrim(HttpSession->CodVend)+'">'+Alltrim(HttpSession->CodVend)+' - '+HttpSession->Nome+'</option>'
		Endif
		For v:= 1 to Len(aVends)
			If Alltrim(Substr(aVends[v],1,At("-",aVends[v])-1)) <> cVendedor
				cTopo+='		<option value="'+Alltrim(Substr(aVends[v],1,At("-",aVends[v])-1))+'">'+aVends[v]+'</option>'
			Endif
		Next
		
		cTopo+= '		</select'													
		cTopo+= '	</div>'													
		cTopo+= '</div>'

	Endif

    cTopo+= '		<div class="col-md-2">'
    cTopo+= '			<button class="btn btn-primary" id="btFiltro" value="" onclick="this.value= '+"'"+'Aguarde...'+"'"+';this.disabled= '+"'"+'disabled'+"'"+';Filtro()" name="btFiltro">'
    cTopo+= '			<i class="fa fa-filter"></i> Filtrar</button>' 
    cTopo+= '		</div>' 
 
    
	
	
	// Buscar os Títulos
	cQry := " Select E3_FILIAL, E3_VEND, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_CODCLI, E3_LOJA, A1_NREDUZ, E3_EMISSAO, "
	cQry += "E3_VENCTO, E1_BAIXA, E3_DATA, E3_PEDIDO, E1_VALOR, E3_BASE, E3_PORC, E3_COMIS, E1_NUM, E3_SERIE, E3_TIPO "
	cQry += "FROM "+RetSqlName("SE3")+" SE3 "
	cQry += " INNER JOIN "+ RetSqlName("SA1")+" SA1 ON A1_FILIAL = '"+xFilial("SA1")+"' And A1_COD = E3_CODCLI "
	cQry += "  AND A1_LOJA = E3_LOJA And SA1.D_E_L_E_T_= ' ' "
	cQry += " Left Join "+ RetSqlName("SE1")+" SE1 ON E1_FILIAL = E3_FILIAL and E1_PREFIXO = E3_PREFIXO and E1_NUM = E3_NUM "
	cQry += "  and E1_PARCELA = E3_PARCELA and E1_TIPO = E3_TIPO and SE1.D_E_L_E_T_ = ' ' "
	If HttpSession->Tipo = 'S' //Supervisor acessa todas as informações da sua equipe
		If !Empty(cVendedor)
			cQry+= " WHERE E3_VEND = '"+cVendedor+"' "
		Else	
    		cQry+= " WHERE E3_VEND in "+FormatIn(HttpSession->Equipe,"|")+" "
		Endif	
	Else	
//		cQry+= " WHERE E3_VEND ='"+HttpSession->CodVend+ "' "
		cQry+= " WHERE E3_VEND ='"+cVendLogin+ "' "
	Endif
	/*	
	If cFiltro = '1' //Emissão
		cQry+= " AND E1_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"' "
	Else
		cQry+= " AND E1_VENCREA between '"+cDataDe+"' and '"+cDataAte+"' "
	Endif
	*/
	cQry += " AND E3_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"' "
	cQry += " AND SE3.D_E_L_E_T_ = ' ' "
	cQry := ChangeQuery(cQry)
	
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	Endif	
	APWExOpenQuery(ChangeQuery(cQry),'QRY',.T.)
	
	TcSetField("QRY","E3_EMISSAO","D")
	TcSetField("QRY","E3_VENCTO","D")
	TcSetField("QRY","E1_BAIXA","D")
	TcSetField("QRY","E3_DATA","D")
	
	//Cabeçalho do grid
	cColunas+='<th>Filial</th>'
	cColunas+='<th>Número</th>'
	//cColunas+='<th>Parcela</th>'
	cColunas+='<th>Cliente</th>'
	cColunas+='<th>Dt Comissão</th>'
	cColunas+='<th>Vencimento</th>'
	cColunas+='<th>Baixa</th>'
	cColunas+='<th>Pagamento</th>'
	cColunas+='<th>Pedido</th>'
	cColunas+='<th>Valor</th>'
	cColunas+='<th>Valor Base</th>'
	cColunas+='<th>%</th>'
	cColunas+='<th>Comissão</th>'
	If HttpSession->Tipo = 'S' //Supervisor 
    	cColunas+='<th>Vendedor</th>'
	Endif
	    
	While QRY->(!Eof())
	
		If QRY->E3_TIPO = 'NCC'
			nValTit:= Posicione("SF1",1,QRY->E3_FILIAL+QRY->E3_NUM+QRY->E3_PREFIXO+QRY->E3_CODCLI+QRY->E3_LOJA,"F1_VALBRUT") * -1
		Elseif Empty(QRY->E1_NUM)
			nValTit:= Posicione("SF2",1,QRY->E3_FILIAL+QRY->E3_NUM+QRY->E3_SERIE+QRY->E3_CODCLI+QRY->E3_LOJA,"F2_VALFAT")
		Else
			nValTit:= QRY->E1_VALOR
		Endif	
		
		cItens+='<tr role="button" onclick="window.document.location='+"'#'"+';">'
		cItens+='	<td>'+QRY->E3_FILIAL+'</td>'
	    cItens+='	<td>'+trim(QRY->E3_PREFIXO)+'/'+QRY->E3_NUM+'</td>'
	    //cItens+='	<td>'+QRY->E3_PARCELA+'</td>'
	    cItens+='	<td>'+QRY->E3_CODCLI+"/"+E3_LOJA+" - "+Alltrim(QRY->A1_NREDUZ)+'</td>'  
	    cItens+='	<td data-order="'+dtos(QRY->E3_EMISSAO)+'">'+DTOC(QRY->E3_EMISSAO)+'</td>' 
	    cItens+='	<td>'+DTOC(Iif(QRY->E3_TIPO = 'NCC',STOD(''),QRY->E3_VENCTO))+'</td>'  
	    cItens+='	<td data-order="'+dtos(QRY->E1_BAIXA)+'">'+DTOC(QRY->E1_BAIXA)+'</td>'  
	    cItens+='	<td data-order="'+dtos(QRY->E3_DATA)+'">'+DTOC(QRY->E3_DATA)+'</td>'  
	    cItens+='	<td>'+QRY->E3_PEDIDO+'</td>'  
	    cItens+='	<td>'+TransForm(nValTit,"@E 999,999,999.99")+'</td>'
	    cItens+='	<td>'+TransForm(QRY->E3_BASE,"@E 999,999,999.99")+'</td>'
	    cItens+='	<td>'+TransForm(QRY->E3_PORC,"@E 999.99")+'</td>'
	    cItens+='	<td>'+TransForm(QRY->E3_COMIS,"@E 999,999,999.99")+'</td>' 
	    If HttpSession->Tipo = 'S' //Supervisor
	    	cItens+='	<td>'+QRY->E3_VEND+' - '+Posicione("SA3",1,xFilial("SA3")+QRY->E3_VEND,"A3_NREDUZ")+'</td>'
	    Endif	
	    cItens+='</tr>'
	 
	    nTotalCom+= QRY->E3_COMIS
	 
		QRY->(dbSkip())
	End
	
	cTopo+= ' 		<br><br>'		
    cTopo+= '		<h3>'
    cTopo+= '		<label class="col-lg-6 control-label text-left">Total de Comissões: R$'+TransForm(nTotalCom,"@E 999,999,999.99")+'</label>'
    cTopo+= '		</h3>'

    cTopo+= '	</form>'
	cTopo+= '	</div>'
	cTopo+= '</div>'
	
	
	//Retorna o HTML para construção da página 
	cHtml := H_SMSGrid()	
	
Web Extended End

Return (cHTML) 
