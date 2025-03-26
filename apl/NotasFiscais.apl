#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ NotasFiscais ¦ Autor ¦ Lucilene Mendes    ¦ Data ¦03.12.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Grid com as notas fiscais do vendedor.  			  		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function NotasFiscais()
Local cHtml
Local cLink	:= ""                      
Local cCliente	:= ""
Local cDataDe	:= ""
Local cDataAte	:= ""
Local cFiltDe	:= ""
Local cFiltDe	:= ""
Local cEndServ	:= ""
Local aClientes	:= {}
                      
Private cColunas:= ""
Private cItens	:= ""  
Private cTopo	:= ""  
Private cSite	:= "u_PortalLogin.apw"
Private cPagina	  := "Notas Fiscais"
Private cTitle	  := "" 
Private lTableTools:= .T.
Private lSidebar:= .F.
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
	
	//Atualiza variáveis
	cEndServ := GetMv('MV_WFBRWSR')
	
	//Tratamento dos filtros
	If type("HttpPost->DataDe") <> "U"
		//Se vazio, usa as datas padrão para evitar erro na query
		If Empty(HttpPost->DataDe) .or. Empty(HttpPost->DataAte)
			cDataDe:= dtos(date()-10)
			cDataAte:= dtos(date())
		Else
			cDataDe:= dtos(ctod(HttpPost->DataDe))
		    cDataAte:= dtos(ctod(HttpPost->DataAte))
		Endif
		//Atualiza as variáveis no valor do filtro
		cFiltDe:= dtoc(stod(cDataDe))
		cFilAte:= dtoc(stod(cDataAte)) 
		cCliente:= HttpPost->cliente   
	Else
	    //Variáveis dos input dos filtros
		cFiltDe:= dtoc(date()-10)
		cFilAte:= dtoc(date())
		//Variáveis de filtro da query
		cDataDe:= dtos(date()-10)
		cDataAte:= dtos(date())
		cCliente:= '1'   
	Endif
	
	
	//Filtros
    cTopo:= '<div class="row form-group">'
    cTopo+= '	<div class="col-sm-12" align="left">'
    cTopo+= '	<form name="formGrid" id="formGrid" method="POST" action="U_NotasFiscais.apw?PR='+cCodLogin+'">'
     /*
    cTopo+= '		<label class="col-md-2 control-label">Cliente:</label>'
    cTopo+= '  		<div class="col-sm-2">'
	cTopo+= '		 	<div class="input-group">'
	cTopo+= '				<select data-plugin-selectTwo class="form-control populate mb-md" name="tipofiltro" id="tipofiltro" '
	cTopo+= ' 				data-plugin-options='+"'"+'{"minimumResultsForSearch": "-1"}'+"'"+' required="" aria-required="true" value="'+cFiltro+'">'
	cTopo+= '					<option value="1"'+Iif(cFiltro='1',' selected','')+'>Emissão</option>'
	cTopo+= '					<option value="2"'+Iif(cFiltro='2',' selected','')+'>Vencimento</option>'
    cTopo+= '				</select>'
    cTopo+= '			</div>'
    cTopo+= '		</div>'
  	*/
  	cTopo+= '		<label class="col-md-2 control-label">Emissão De:</label>'
    cTopo+= '  		<div class="col-md-3">'
	cTopo+= '		 	<div class="input-group">'
    cTopo+= '    			<span class="input-group-addon">'
    cTopo+= '					<i class="fa fa-calendar"></i>'
    cTopo+= '			    </span>'   
    cTopo+= '				<input data-plugin-datepicker="" data-plugin-options='+"'"+'{"autoclose": "true", "language": "pt-BR",'
	cTopo+= '					"daysOfWeekDisabled": "","daysOfWeekHighlighted":"[0]"}'+"'"+' value="'+cFiltDe+'" ' 
    cTopo+= '					placeholder="__/__/____" id="datade" name="datade" class="form-control only-numbers" type="text"></input>'
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
    cTopo+= '					placeholder="__/__/____" id="dataate" name="dataate" class="form-control only-numbers" type="text"></input>'
    cTopo+= '			</div>'
    cTopo+= '		</div>' 
    cTopo+= '		<div class="col-md-2">'
    cTopo+= '			<button class="btn btn-primary" id="btFiltro" value="" onclick="this.value= '+"'"+'Aguarde...'+"'"+';this.disabled= '+"'"+'disabled'+"'"+';Filtro()" name="btFiltro">'
    cTopo+= '			<i class="fa fa-filter"></i> Filtrar</button>' 
    cTopo+= '		</div>' 
    cTopo+= '	</form>'
	cTopo+= '	</div>'
	cTopo+= '</div>'
	
	
	// Busca as notas fiscais
	cQry := " SELECT DISTINCT F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, A1_NREDUZ, F2_EMISSAO, F2_VALMERC, F2_VALFAT, F2_CHVNFE, D2_PEDIDO, F2_VEND1 VEND, SF2.R_E_C_N_O_ RECSF2 "
	cQry += " FROM "+RetSqlName("SF2")+" SF2 "
	cQry += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND SA1.D_E_L_E_T_ = ' ' "
	cQry += " INNER JOIN "+RetSqlName("SD2")+" SD2 ON D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND SD2.D_E_L_E_T_ = ' ' "
	cQry += " WHERE " // AND F2_FILIAL = '"+xFilial("SF2")+"'
	// If HttpSession->Tipo = 'S' //Supervisor acessa todas as informações da sua equipe
    // 	cQry+= " F2_VEND1 in "+FormatIn(HttpSession->Equipe,"|")+" "
	// Else
//		cQry += "  F2_VEND1 = '"+HttpSession->CodVend+ "' "
		cQry += "  F2_VEND1 = '"+cVendLogin+ "' "
	// Endif
	cQry += " AND F2_TIPO = 'N' "
	cQry += " AND F2_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"' "
	cQry += " AND SF2.D_E_L_E_T_ = ' ' "
	cQry += " ORDER BY F2_DOC, F2_EMISSAO "

	conout("@@@ query4:" + cQry)
	
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	Endif	
	APWExOpenQuery(ChangeQuery(cQry),'QRY',.T.)
	

	TcSetField("QRY","F2_EMISSAO","D")

	
	//Cabeçalho do grid
	cColunas+='<th>Filial</th>'
	cColunas+='<th>Nota Fiscal</th>'
	cColunas+='<th>Série</th>'
	cColunas+='<th>Emissão</th>'
	cColunas+='<th>Cliente</th>'
	cColunas+='<th>Nome</th>'
	cColunas+='<th>Valor</th>'    
	cColunas+='<th>Pedido</th>'
	If HttpSession->Tipo = 'S' //Supervisor 
    	cColunas+='<th>Vendedor</th>'
	Endif    
	cColunas+='<th></th>'         
	    
	While QRY->(!Eof())
		//Atualiza os controles do grid
		cLink:= "U_ViewNF.apw?PR="+cCodLogin+"&rec="+cValtoChar(QRY->RECSF2)"
		cLink+= ' onclick="window.document.location='+"'"+cLink+"&opc=view'"+';"' 
		
		cItens+='<tr>'+CRLF
	    cItens+='	<td role="button" '+cLink+'>'+QRY->F2_FILIAL+'</td>'
	    cItens+='	<td role="button" '+cLink+'>'+QRY->F2_DOC+'</td>'
	    cItens+='	<td role="button" '+cLink+'>'+QRY->F2_SERIE+'</td>'
	    cItens+='	<td role="button" '+cLink+' data-order="'+dtos(QRY->F2_EMISSAO)+'">'+DTOC(QRY->F2_EMISSAO)+'</td>'
	    cItens+='	<td role="button" '+cLink+'>'+QRY->F2_CLIENTE+'/'+QRY->F2_LOJA+'</td>'
	    cItens+='	<td role="button" '+cLink+'>'+Alltrim(QRY->A1_NREDUZ)+'</td>' 
	    cItens+='	<td role="button" '+cLink+'>'+Transform(QRY->F2_VALFAT,PesqPicT("SF2","F2_VALMERC"))+'</td>'   
	    cItens+='	<td role="button" '+cLink+'>'+QRY->D2_PEDIDO+'</td>'
	    If HttpSession->Tipo = 'S' //Supervisor
	    	cItens+='	<td role="button" '+cLink+'>'+QRY->VEND+' - '+Posicione("SA3",1,xFilial("SA3")+QRY->VEND,"A3_NREDUZ")+'</td>'
	    Endif	   
	    cItens+='	<td class="actions">'
	    If !Empty(QRY->F2_CHVNFE)
        	// cItens+='   	<a class="modal-email" href="#modalEmail" id="oc'+cValtoChar(QRY->RECSF2)+'" data-toggle="tooltip" data-original-title="Enviar DANFE por e-mail" title="">'
        	cItens+='   	<a class="modal-email" href="#" data-toggle="tooltip" data-original-title="Enviar DANFE por e-mail" title="" onClick="javascript:abreEmail('+cValtoChar(QRY->RECSF2)+');">'
        	cItens+='			<i class="fa fa-envelope-o"></i>'
        	cItens+='		</a>'
        	cItens+='   	<a href="#" data-toggle="tooltip" data-original-title="Abrir DANFE" title="" onClick="javascript:ViewDanfe('+cValtoChar(QRY->RECSF2)+',1);">'
        	cItens+='			<i class="fa fa-file-pdf-o"></i>'
        	cItens+='		</a>'
			// cItens+='   	<a href="#" data-toggle="tooltip" data-original-title="Abrir XML" title="" onClick="javascript:ViewDanfe('+cValtoChar(QRY->RECSF2)+',2);">'
        	// cItens+='			<i class="fa fa-file-excel-o"></i>'
        	// cItens+='		</a>'
	    Endif
	    cItens+='	</td>'
	    cItens+='</tr>'+CRLF
	 
		QRY->(dbSkip())
	End
	
	cItens+= montarForm("Danfe", "MailNF.apw?PR="+cCodLogin)
//    cItens+= staticcall(orcamento, montarForm, "Danfe", "MailNF.apw")

	//Retorna o HTML para construção da página 
	cHtml := H_SMSGrid()	
	
Web Extended End

Return (cHTML) 


// Montar o formulário para mandar por e-mail
static function montarForm(cTitulo, cSubm)
Local cRet:=""
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
conout(cret)	
return cRet  
