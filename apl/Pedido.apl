#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ PedVenda  ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦28.08.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Grid com os pedidos de venda                 			  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function PedVenda()
Local cHtml
Local cLink		:= ""                      
// Local cCombo	:= ""                      
Local cDataDe	:= ""
Local cDataAte	:= ""
Local cFiltDe	:= ""
Local cFilAte	:= ""                      
Local aStatus:= {} 
Local cLinkDet  := ""
Local cCookie   := ""
Local aValCookie:= {}
// Local cCliente	:= ""
Local cFilCli   := ""
Local aClientes	:= {}
// local oObjLog := LogSMS():new()
local aLinItens := {}     // Linhas de itens
local nCnt      := 0	  // Contador de itens
local nIt
Private cColunas:= ""
Private cItens	:= ""  
Private cTopo	:= ""  
Private cSite	:= "u_PortalLogin.apw"
Private cPagina	  := "Pedidos de Venda"
Private cTitle	  := "" 
Private lTableTools:= .T.
Private lSidebar:= .F.
Private cCodLogin := ""
Private cVendLogin:= ""

Web Extended Init cHtml Start U_inSite()

	// TODO - Pedro 20210208 - Remover???
	conout("@@@ CodVend: " + HttpSession->CodVend)
	If Empty(HttpSession->CodVend)
		conout("@@@ CodVend: entrou no redirecionamento")
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL='+cSite+'">'	
		Return cHtml
	Endif
	
	cVendLogin := u_GetUsrPR()
	cCodLogin  := U_SetParPR(cVendLogin)

	// Pega do parâmetro com o Titulo do Portal
	//cTitle	:= SuperGetMV("PS_TITLE", .T., "Portal SMS")
	cTitle := "Portal SMS"
	// Define a funcao a ser chama no link
	cSite	:= "u_SMSPortal.apw?PR="+cCodLogin
	
	// Monta o cabeçalho para a pagina
	cHeader := U_PSHeader(cTitle, cSite, cCodLogin) 	
	
	//Função que atualiza os menus
	cMenus := U_GetMenus(AllTrim(Upper(Procname())), cVendLogin)
	
	//Tratamento dos filtros
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
		// cCliente:= HttpPost->cliente
		cFilCli := HttpPost->filcliente
	Else
	    //Variáveis dos input dos filtros
		cFiltDe:= dtoc(date()-30)
		cFilAte:= dtoc(date())
		//Variáveis de filtro da query
		cDataDe:= dtos(date()-30)
		cDataAte:= dtos(date())
		// cCliente:= '1'
		cFilCli := "T"
		// Parametros de cookie
		if !empty(&("HttpCookies->F"+procname()))
			cCookie := decode64(&("HttpCookies->F"+procname()))
		endif
		if left(cCookie, len("usuario:"+cVendLogin)) == "usuario:"+cVendLogin
			aValCookie := strtokarr(cCookie, "|");
			// for nIt := 2 to len(aValCookie)
			nIt := 2
			while nIt <= len(aValCookie)
				do case
				case aValCookie[nIt] = "filcliente"
					cFilCli := subs(aValCookie[nIt], at(":", aValCookie[nIt])+1)
				case aValCookie[nIt] = "datade"
					cFiltDe := subs(aValCookie[nIt], at(":", aValCookie[nIt])+1)
					cDataDe := dtos(ctod(cFiltDe))
				case aValCookie[nIt] = "dataate"
					cFilAte  := subs(aValCookie[nIt], at(":", aValCookie[nIt])+1)
					cDataAte := dtos(ctod(cFilAte))
				endcase
				nIt++
			enddo
			// next
		endif
	Endif

	// aClientes := u_getClientes(cVendLogin)

	// Se usuario nao tem acesso a clientes - volta a tela inicial
	// if empty(len(aClientes))
	// 	cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL='+cSite+'">'	
	// 	Return cHtml
	// endif
	// Formatacao de cookie para salvamento
	// cCookie := Encode64(cVendLogin+"|"+cFilCli+"|"+cDataDe+"|"+cDataAte)

	//HTTPHEADOUT->Set-Cookie := "PedVenda="+cCookie
	//Topo da janela
	//Botão incluir novo orçamento

	cLink:= "U_AddPed.apw?PR="+cCodLogin

	cTopo:= '<div class="row form-group">'
	cTopo+= '	<div class="col-sm-3" style="padding: 20px;">'
	cTopo+= '		<button class="btn btn-primary" id="btAddOrc" name="btAddPed" onclick="javascript: getFilVend();">'
    // cTopo+= '		<button class="btn btn-primary" id="btAddOrc" name="btAddOrc" onclick="window.document.location='+"'"+cLink+"'"+'";>'
    cTopo+= '		  <i class="fa fa-plus"></i> Novo Pedido</button>'
    cTopo+= '  	</div>'
	cTopo+= '  	<br>'
    //Filtros
    cTopo+= '	<div class="col-sm-12">'
    cTopo+= '	<form name="formGrid" id="formGrid" method="POST" action="U_PedVenda.apw?PR='+cCodLogin+'">'
    // cTopo+= '		<label class="col-md-1 control-label">Empresa</label>'
    // cTopo+= '  		<div class="col-sm-2">'
	// cTopo+= '		 	<div class="input-group">'
	// cTopo+= '				<select data-plugin-selectTwo class="form-control populate mb-md" name="filcliente" id="filcliente" '
	// cTopo+= ' 				data-plugin-options='+"'"+'{"minimumResultsForSearch": "-1"}'+"'"+' required="" aria-required="true" value="'+cFilCli+'">'
	// cTopo+= '					<option value="T"'+Iif(cFilCli=='T',' selected','')+'>Todos</option>'
	// for nIt := 1 to len(aClientes)
	// 	cTopo+= 					'<option value="'+aClientes[nIt, 1]+aClientes[nIt, 2]+'"'+Iif(cFilCli==aClientes[nIt, 1]+aClientes[nIt, 2],' selected','')+'>'+aClientes[nIt, 3]+'</option>'
	// next
    // cTopo+= '				</select>'
    // cTopo+= '			</div>'
    // cTopo+= '		</div>'
  	cTopo+= '		<label class="col-md-2 control-label">Emissão De:</label>'
    cTopo+= '  		<div class="col-md-3">'
	cTopo+= '		 	<div class="input-group">'
    cTopo+= '    			<span class="input-group-addon">'
    cTopo+= '					<i class="fa fa-calendar"></i>'
    cTopo+= '			    </span>'   
    cTopo+= '				<input data-plugin-datepicker="" data-plugin-options='+"'"+'{"autoclose": "true", "language": "pt-BR",'
	cTopo+= '					"daysOfWeekDisabled": "","daysOfWeekHighlighted":"[0]"}'+"'"+' value="'+cFiltDe+'" ' 
    cTopo+= '					placeholder="__/__/____" id="datade" name="datade" class="form-control only-numbers" type="text">'
    cTopo+= '			</div>'
    cTopo+= '		</div>'       
  
    cTopo+= '		<label class="col-md-2 control-label">Emissão Até:</label>'
	cTopo+= '		<div class="col-md-3">'
	cTopo+= '			<div class="input-group">'
    cTopo+= '				<span class="input-group-addon">'
    cTopo+= '					<i class="fa fa-calendar"></i>'
    cTopo+= '				</span>'   
    cTopo+= '				<input data-plugin-datepicker="" data-plugin-options='+"'"+'{"autoclose": "true", "language": "pt-BR",'
	cTopo+= '					"daysOfWeekDisabled": "","daysOfWeekHighlighted":"[0]"}'+"'"+' value="'+cFilAte+'" '
    cTopo+= '					placeholder="__/__/____" id="dataate" name="dataate" class="form-control only-numbers" type="text">'
    cTopo+= '			</div>'
    cTopo+= '		</div>'       
    cTopo+= '		<button class="btn btn-primary" id="btFiltro" value="" onclick="this.value= '+"'"+'Aguarde...'+"'"+';this.disabled= '+"'"+'disabled'+"'"+';Filtro()" name="btFiltro">'
    cTopo+= '			<i class="fa fa-filter"></i> Filtrar</button>'  
    cTopo+= '	</form>'
	cTopo+= '	</div>'
	cTopo+= '</div>'

	cQry := " SELECT DISTINCT SC5.C5_FILIAL, "
	cQry += " SC5.C5_NUM, "
	cQry += " SC5.C5_CLIENTE, "
	cQry += " SC5.C5_LOJACLI, "
	cQry += " SA1.A1_NOME, "
	cQry += " SA1.A1_EMAIL, "
	cQry += " SA1.A1_CGC, "
	cQry += " SC5.C5_EMISSAO, "
	cQry += " SC5.C5_NOTA , SC5.R_E_C_N_O_ C5RECNO "
	cQry += " FROM "+RetSqlName("SC5")+" SC5 " 
	cQry += " INNER Join "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = SC5.C5_FILIAL AND A1_COD = SC5.C5_CLIENTE AND A1_LOJA = SC5.C5_LOJACLI AND SA1.D_E_L_E_T_ = ' ' " 
	cQry += " WHERE C5_TIPO = 'N'" // AND F2_FILIAL = '"+xFilial("SF2")+"'
	cQry += " AND SC5.D_E_L_E_T_ = ' ' "
	cQry += " AND SC5.C5_VEND1 = '"+cVendLogin+"' "
	cQry += " AND C5_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"' ""
    cQry += " ORDER BY SC5.C5_EMISSAO DESC , SC5.C5_NUM DESC"

	conout("@@@ query1:" + cQry)
	
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	Endif	

	APWExOpenQuery(ChangeQuery(cQry),'QRY',.T.)

	//Cabeçalho do grid
	cColunas+='<th>Filial</th>'
	cColunas+='<th>Pedido</th>'
	// cColunas+='<th>Status</th>'
	cColunas+='<th>Emissão</th>'
	cColunas+='<th>Cliente</th>'
	cColunas+='<th>Nome</th>'

	cColunas+='<th></th>'
	
	// aStatus:= RetSx3Box(Posicione('SX3',2,'CJ_STATUS','X3CBox()'),,,1)
	
	While QRY->(!Eof())
		// if cVendLogin == "000207"
		// 	oObjLog:saveMsg("Registro "+QRY->CJ_NUM)
		// endif
		//Atualiza os controles do grid
		cLink:= "U_ViewPedido.apw?PR="+cCodLogin+"&rec="+cvaltochar(QRY->C5RECNO)
		// clink:="#"
		cLinkDet  := '"onclick="window.document.location='+"'"+cLink+"&opc=view'"+';"'
		cItens+='<tr>'
	    cItens+='	<td role="button" onclick="window.document.location='+"'"+cLink+"&opc=view'"+';">'+QRY->C5_FILIAL+'</td>'
	    cItens+='	<td role="button" onclick="window.document.location='+"'"+cLink+"&opc=view'"+';">'+QRY->C5_NUM+'</td>'
	    // If (nSeek := Ascan(aStatus, { |x| x[ 2 ] == QRY->CJ_STATUS })) > 0
  		// 	cCombo := AllTrim( aStatus[nSeek,3])

		// 	If QRY->CJ_STATUS $ 'Q|C'
		// 		cCombo:= 'Cancelado'
		// 	Elseif QRY->CJ_XTPORC == '3' .and. QRY->CJ_STATUS <> 'B'
		// 		cCombo:= 'Em Elaboração'
		// 	Endif
		// Elseif QRY->CJ_STATUS $ 'Q|C'
		// 	cCombo:= 'Cancelado'
		// elseif QRY->CJ_XTPORC == '3' .and. QRY->CJ_STATUS <> 'B'
		// 	cCombo:= 'Em Elaboração'
  		// Endif
	    // cItens+='	<td role="button" onclick="window.document.location='+"'"+cLink+"&opc=view'"+';">'+Iif(Empty(QRY->C5_NOTA),cCombo,"NF Gerada")+'</td>'
	    cItens+='	<td role="button" onclick="window.document.location='+"'"+cLink+"&opc=view'"+';" data-order="'+(QRY->C5_EMISSAO)+'">'+dtoc(stod(QRY->C5_EMISSAO))+'</td>'
	    cItens+='	<td role="button" onclick="window.document.location='+"'"+cLink+"&opc=view'"+';">'+QRY->C5_CLIENTE+'/'+QRY->C5_LOJACLI+'</td>'
	    cItens+='	<td role="button" onclick="window.document.location='+"'"+cLink+"&opc=view'"+';">'+Alltrim(QRY->A1_NOME)+" - " + right(trim(QRY->A1_CGC),6) + '</td>'
		// if !empty(SC5->(fieldpos("C5_XOCCLI")))
		// 	cItens+='	<td role="button" onclick="window.document.location='+"'"+cLink+"&opc=view'"+';">'+QRY->C5_XOCCLI+'</td>'
		// endif
	    // cItens+='	<td role="button" onclick="window.document.location='+"'"+cLink+"&opc=view'"+';">'+QRY->CK_NUMPV+'</td>'
// 	    If HttpSession->Tipo = 'S'
// //	    	cItens+='	<td role="button" onclick="window.document.location='+"'"+cLink+"&opc=view'"+';">'+QRY->CJ_VEND+' - '+trim(Posicione("SA3",1,xFilial("SA3")+QRY->CJ_VEND,"A3_NREDUZ"))+'</td>'
// 	    	cItens+='	<td role="button" onclick="window.document.location='+"'"+cLink+"&opc=view'"+';">'+QRY->CJ_VEND+' - '+trim(QRY->A3_NREDUZ)+'</td>'
// 	    Endif
	    cItens+='	<td class="actions">' 
	    
	    // cItens+=	' <a href="'+cLink+'&opc=copy" class="on-default" data-toggle="tooltip" data-original-title="Copiar Orçamento"><i class="fa fa-files-o"></i></a>'
	    // If QRY->CJ_STATUS $ "AF" .and. Iif(!Empty(QRY->STATUSB),QRY->STATUSB $ "AF",.T.)
	    // 	cItens+=' <a href="'+cLink+'&opc=edit" class="on-default" data-toggle="tooltip" data-original-title="Alterar Orçamento"><i class="fa fa-pencil"></i></a>'
	    // 	cItens+=' <a href="'+cLink+'&opc=dele" class="on-default" data-toggle="tooltip" data-original-title="Excluir Orçamento"><i class="fa fa-trash-o"></i></a>'
	    // EndIf
		// cItens+='   	<a class="modal-email" href="#" data-toggle="tooltip" data-original-title="Enviar orçamento por e-mail" title="" onClick="javascript:abreEmail('+cValtoChar(QRY->RECSCJ)+');">'
		// cItens+='			<i class="fa fa-envelope-o"></i></a>'
	    // cItens+='   <a href="#" data-toggle="tooltip" data-original-title="Imprimir Pedido" title="" onClick="javascript:PrtOrc('+cValtoChar(QRY->RECSCJ)+');"><i class="fa fa-print"></i></a>'
	    cItens+='	</td>'
	    cItens+='</tr>'
		nCnt++	  // Contador de itens
		// Quebra da string em 500 itens
		if nCnt = 500 
			aadd(aLinItens, cItens)     // Linhas de itens
			cItens := ""
			nCnt := 0
		endif
	 
		QRY->(dbSkip())
	End
	// Quebra da string em 500 itens
	aadd(aLinItens, cItens)     // Linhas de itens
	cItens := ""
	for nCnt := 1 to len(aLinItens)
		cItens += aLinItens[nCnt]
	next
	// if cVendLogin == "000207"
	// 	oObjLog:saveMsg("Fim while")
	// endif
    cItens+= montarForm("Pedido Venda","MailOrc.apw?PR="+cCodLogin)
	// if cVendLogin == "000207"
	// 	oObjLog:saveMsg("Fim montarForm")
	// endif
	
	//Retorna o HTML para construção da página 
	cHtml := H_SMSGrid()	
	// if cVendLogin == "000207"
	// 	oObjLog:saveMsg("Fim H_SMSGrid")
	// endif
	
Web Extended End

Return (cHTML) 

// Montar o formulário para mandar por e-mail
static function montarForm(cTitulo, cSubm)
Local cRet:=""
// Local cEmail:= ""

cRet+= '<!-- Modal Form -->'+CRLF
cRet+= '         <div id="modalEmail" class="modal-block modal-block-primary mfp-hide">'+CRLF
cRet+= '            <section class="panel">'+CRLF
cRet+= '                <header class="panel-heading">'+CRLF
cRet+= '                    <h2 class="panel-title">Enviar '+cTitulo+' por e-mail</h2>'+CRLF
cRet+= '                </header>'+CRLF
cRet+= '                <div class="panel-body">'+CRLF
cRet+= '                    <form id="formEmail" class="form-horizontal mb-lg" novalidate="novalidate">'+CRLF
cRet+= '                        <span><i>Para enviar para mais de um destinatário, separe os e-mails com ;</i></span>'+CRLF
cRet+= '                        <br><br>'+CRLF
cRet+= '                        <div class="form-group">'+CRLF
cRet+= '                            <label class="col-sm-3 control-label">E-mail</label>'+CRLF
cRet+= '                            <div class="col-sm-9">'+CRLF
cRet+= '                                <input type="hidden" name="nrdoc"/>'+CRLF
cRet+= '                                <input type="hidden" name="formDest" value="'+cSubm+'"/>'+CRLF
cRet+= '                                <input type="email" name="email" class="form-control" placeholder="Insira seu email..." required/>'+CRLF
cRet+= '                            </div>'+CRLF
cRet+= '                        </div>'+CRLF
cRet+= '                    </form>'+CRLF
cRet+= '                </div>'+CRLF
cRet+= '                <footer class="panel-footer">'+CRLF
cRet+= '                    <div class="row">'+CRLF
cRet+= '                        <div class="col-md-12 text-right">'+CRLF
cRet+= '                            <button class="btn btn-primary modal-confirm" onclick="javascript:enviarEmail();">Enviar</button>'+CRLF
cRet+= '                            <button class="btn btn-default modal-dismiss" onclick="javascript:fecharEmail();">Cancelar</button>'+CRLF
cRet+= '                        </div>'+CRLF
cRet+= '                    </div>'+CRLF
cRet+= '                </footer>'+CRLF
cRet+= '            </section>'+CRLF
cRet+= '         </div>'+CRLF
	
return cRet  


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ FilVend	     ¦ Autor ¦ Lucilene Mendes   ¦ Data ¦30.07.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Lista as filiais que o vendedor tem acesso		  		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function FilVend()
Local cHtml
Local cRet		:= ""
Private cSite	:= "u_PortalLogin.apw"
Private cCodLogin := ""
Private cVendLogin:= ""
Private cFilFiltro:= ""

Web Extended Init cHtml Start U_inSite()

	// TODO - Pedro 20210208 - Remover???
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
	
	//Retorna o HTML para construção da página 
	cHtml := u_fFilVend(cVendLogin,cFilFiltro)
	                                                        		
Web Extended End

Return (cHTML)

User Function fFilVend(cCodVend,cFilFiltro)
	Local cRet:= ""
	Local cQry:= ""

	cQry:= " SELECT M0_CODFIL, M0_FILIAL "
	cQry+= " FROM SYS_COMPANY "
	cQry+= " WHERE D_E_L_E_T_ = ' ' "

	If Select("QRF") > 0
		QRF->(dbCloseArea())
	Endif
	APWExOpenQuery(ChangeQuery(cQry),'QRF',.T.)	
	
	While QRF->(!Eof())
		if QRF->M0_CODFIL = '030103' .or.  QRF->M0_CODFIL = '030104' .or.  QRF->M0_CODFIL = '040101'
			cRet+= '	<option value="'+Alltrim(QRF->M0_CODFIL)+'" '+Iif(Alltrim(QRF->M0_CODFIL)= cFilFiltro,' selected ','')+'>'+Alltrim(QRF->M0_CODFIL)+" - "+Alltrim(QRF->M0_FILIAL)+'</option>'
		endif
		QRF->(dbSkip())
	End

Return cRet
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ TrocaFil	     ¦ Autor ¦ Lucilene Mendes   ¦ Data ¦30.07.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Altera a filial logada							  		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function TrocaFil()
Local cHtml
Local cRet		:= ""
Private cSite	:= "u_PortalLogin.apw"
Private cCodLogin := ""
Private cVendLogin:= ""

Web Extended Init cHtml Start U_inSite()

	// TODO - Pedro 20210208 - Remover???
	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL='+cSite+'">'	
		Return cHtml
	Endif
	// Else
	// 	If !Empty(HttpSession->Superv) .and. HttpSession->Superv <> HttpSession->CodVend
	// 		HttpSession->CodVend:= HttpSession->Superv
	// 	Endif
	
	cVendLogin := u_GetUsrPR()
	cCodLogin  := U_SetParPR(cVendLogin)

	//Altera a empresa para a filial de faturamento
	nRecSA3:= SA3->(Recno())
	If cFilAnt <> HttpPost->Filial
		HttpSession->Filial:= HttpPost->Filial //CEMPANT+CFILANT+CEMPFIL
		u_InSite(.f.)
	Endif
	
	//Posiciona na SA3 novamente, pois ao trocar a filial fecha a tabela
	dbSelectArea("SA3")
	SA3->(dbGoTo(nRecSA3))
	
	If cFilAnt == HttpPost->Filial
		cRet := cFilAnt
	Endif	     
	
	//Retorna o HTML para construção da página 
	cHtml := cRet	
	                                                        		
Web Extended End

Return (cHTML)
