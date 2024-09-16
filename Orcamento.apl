#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ Orcamento   ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦28.08.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Grid com os orçamentos em aberto do vendedor.			  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function Orcamento()
Local cHtml
Local cLink	:= ""                      
Local cCombo	:= ""                      
Local cDataDe	:= ""
Local cDataAte	:= ""
Local cFiltDe	:= ""
Local cFilAte	:= ""                      
Local aStatus:= {} 
Local cLinkDet  := ""
Private cColunas:= ""
Private cItens	:= ""  
Private cTopo	:= ""  
Private cSite	:= "u_PortalLogin.apw"
Private cPagina	  := "Orçamentos"
Private cTitle	  := "" 
Private lTableTools:= .T.
Private lSidebar:= .F.
Private cCodLogin := ""
Private cVendLogin:= ""

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
	    
	//Topo da janela
	//Botão incluir novo orçamento
	cTopo:= '<div class="row form-group">'
  	cTopo+= '	<div class="col-sm-3">'
//    cTopo+= '		<button class="btn btn-primary" id="btAddOrc" name="btAddOrc" onclick="javascript: getFilVend();">'
    cTopo+= '		<button class="btn btn-primary" id="btAddOrc" name="btAddOrc" onclick="javascript: location.href='+"'"+'u_AddOrc.apw?PR='+cCodLogin+"'"+';">'
    cTopo+= '		  <i class="fa fa-plus"></i> Novo Orçamento</button>'
    cTopo+= '  	</div>'
    
    //Filtros
    cTopo+= '	<div class="col-sm-9" align="right">'
    cTopo+= '	<form name="formGrid" id="formGrid" method="POST" action="U_Orcamento.apw?PR='+cCodLogin+'">'
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
	 	
	cQry:= " Select DISTINCT SCJ.CJ_FILIAL, SCJ.CJ_NUM, SCJ.CJ_CLIENTE, SCJ.CJ_LOJA, A1_NOME, A1_EMAIL, SCJ.CJ_EMISSAO, SCJ.CJ_STATUS, CK_NUMPV, SCJ.CJ_VEND, SCJ.CJ_XTPORC, SCJ.R_E_C_N_O_ RECSCJ, "
	cQry+= " C5_NOTA, SCJ.CJ_COTCLI "
	cQry+= " From "+RetSqlName("SCJ")+" SCJ " 
	cQry+= " Inner Join "+RetSqlName("SA1")+" SA1 On A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = SCJ.CJ_CLIENTE AND A1_LOJA = SCJ.CJ_LOJA AND SA1.D_E_L_E_T_ = ' ' " 
	cQry+= " Inner Join "+RetSqlName("SCK")+" SCK On CK_FILIAL = SCJ.CJ_FILIAL AND CK_NUM = SCJ.CJ_NUM AND SCK.D_E_L_E_T_ = ' ' "
	cQry+= " Left Join "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = CK_FILIAL AND C5_NUM = CK_NUMPV AND SC5.D_E_L_E_T_ = ' ' "
	cQry+= " Where  SCJ.D_E_L_E_T_ = ' ' "  //SCJ.CJ_FILIAL = '"+xFilial("SCJ")+"' AND
    If HttpSession->Tipo = 'S' //Supervisor acessa todos os orçamentos da sua equipe
    	cQry+= " AND SCJ.CJ_VEND in "+FormatIn(HttpSession->Equipe,"|")+" "
    Else
		cQry+= " AND SCJ.CJ_VEND = '"+cVendLogin+"' "
    Endif
    If !Empty(cDataAte)
    	cQry+= " And SCJ.CJ_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"' "
    Endif
    cQry+= " Order by SCJ.CJ_EMISSAO, SCJ.CJ_NUM, SCJ.CJ_CLIENTE, SCJ.CJ_LOJA "
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	Endif	
	APWExOpenQuery(ChangeQuery(cQry),'QRY',.T.)
	
	
	//Cabeçalho do grid
	cColunas+='<th>Filial</th>'
	cColunas+='<th>Orçamento</th>'
	cColunas+='<th>Status</th>'
	cColunas+='<th>Emissão</th>'
	cColunas+='<th>Hora</th>'
	cColunas+='<th>Cliente</th>'
	cColunas+='<th>Nome</th>'
	cColunas+='<th>Pedido</th>'
	If HttpSession->Tipo = 'S'
		cColunas+='<th>Vendedor</th>'
	Endif
	cColunas+='<th></th>'         
	
	aStatus:= RetSx3Box(Posicione('SX3',2,'CJ_STATUS','X3CBox()'),,,1)
	
	While QRY->(!Eof())
		//Atualiza os controles do grid
		cLink:= "U_MntOrc.apw?PR="+cCodLogin+"&rec="+cValtoChar(QRY->RECSCJ)
		cLinkDet  := '"onclick="window.document.location='+"'"+cLink+"&opc=view'"+';"'
		cItens+='<tr>'
	    cItens+='	<td role="button" onclick="window.document.location='+"'"+cLink+"&opc=view'"+';">'+QRY->CJ_FILIAL+'</td>'
	    cItens+='	<td role="button" onclick="window.document.location='+"'"+cLink+"&opc=view'"+';">'+QRY->CJ_NUM+'</td>'
	    If (nSeek := Ascan(aStatus, { |x| x[ 2 ] == QRY->CJ_STATUS })) > 0
  			cCombo := AllTrim( aStatus[nSeek,3])

			If QRY->CJ_STATUS $ 'Q|C'
				cCombo:= 'Cancelado'
			Elseif QRY->CJ_XTPORC == '3' .and. QRY->CJ_STATUS <> 'B'
				cCombo:= 'Em Elaboração'		
			Endif	
  		Endif
	    cItens+='	<td role="button" onclick="window.document.location='+"'"+cLink+"&opc=view'"+';">'+Iif(Empty(QRY->C5_NOTA),cCombo,"NF Gerada")+'</td>'
	    cItens+='	<td role="button" onclick="window.document.location='+"'"+cLink+"&opc=view'"+';" data-order="'+(QRY->CJ_EMISSAO)+QRY->CJ_COTCLI+'">'+dtoc(stod(QRY->CJ_EMISSAO))+'</td>'
		cItens+='	<td role="button" onclick="window.document.location='+"'"+cLink+"&opc=view'"+';" data-order="'+(QRY->CJ_EMISSAO)+QRY->CJ_COTCLI+'">'+QRY->CJ_COTCLI+'</td>'
	    cItens+='	<td role="button" onclick="window.document.location='+"'"+cLink+"&opc=view'"+';">'+QRY->CJ_CLIENTE+'/'+QRY->CJ_LOJA+'</td>'
	    cItens+='	<td role="button" onclick="window.document.location='+"'"+cLink+"&opc=view'"+';">'+Alltrim(QRY->A1_NOME)+'</td>'
	    cItens+='	<td role="button" onclick="window.document.location='+"'"+cLink+"&opc=view'"+';">'+QRY->CK_NUMPV+'</td>'
	    If HttpSession->Tipo = 'S'
	    	cItens+='	<td role="button" onclick="window.document.location='+"'"+cLink+"&opc=view'"+';">'+QRY->CJ_VEND+' - '+Posicione("SA3",1,xFilial("SA3")+QRY->CJ_VEND,"A3_NREDUZ")+'</td>'
	    Endif
	    cItens+='	<td class="actions">' 
	    
	    cItens+=	' <a href="'+cLink+'&opc=copy" class="on-default" data-toggle="tooltip" data-original-title="Copiar Orçamento"><i class="fa fa-files-o"></i></a>'
	    If QRY->CJ_STATUS $ "AF"
	    	cItens+=' <a href="'+cLink+'&opc=edit" class="on-default" data-toggle="tooltip" data-original-title="Alterar Orçamento"><i class="fa fa-pencil"></i></a>'
	    	cItens+=' <a href="'+cLink+'&opc=dele" class="on-default" data-toggle="tooltip" data-original-title="Excluir Orçamento"><i class="fa fa-trash-o"></i></a>'
	    EndIf
		cItens+='   	<a class="modal-email" href="#" data-toggle="tooltip" data-original-title="Enviar orçamento por e-mail" title="" onClick="javascript:abreEmail('+cValtoChar(QRY->RECSCJ)+');">'
		cItens+='			<i class="fa fa-envelope-o"></i></a>'
	    cItens+='   <a href="#" data-toggle="tooltip" data-original-title="Imprimir Orçamento" title="" onClick="javascript:PrtOrc('+cValtoChar(QRY->RECSCJ)+');"><i class="fa fa-print"></i></a>'
	    cItens+='	</td>'
	    cItens+='</tr>'
	 
		QRY->(dbSkip())
	End
    cItens+= montarForm("Orçamento","MailOrc.apw?PR="+cCodLogin)
	
	//Retorna o HTML para construção da página 
	cHtml := H_SMSGrid()	
	
Web Extended End

Return (cHTML) 

// Montar o formulário para mandar por e-mail
static function montarForm(cTitulo, cSubm)
Local cRet:=""
Local cEmail:= ""

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
¦¦¦Funçäo    ¦ WidGetOrc     ¦ Autor ¦ Lucilene Mendes   ¦ Data ¦23.08.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ PE para gerar o WidGet de Cotações para o Portal  		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function WidGetOrc()
Local cQry := ""

	cQry:= " SELECT COUNT(DISTINCT C8_NUM) AS SC8_NUM  " 
	cQry+= " FROM "+RetSqlName("SC8")+" SC8 "     
	cQry+= " Where C8_FILIAL = '"+xFilial("SC8")+"' AND C8_FORNECE = '"+HttpSession->Fornece+"' AND C8_LOJA = '"+HttpSession->Loja+"' AND SC8.D_E_L_E_T_ = ' ' " 
	cQry+= " AND C8_NUMPED = ' ' " 

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	Endif
	
	APWExOpenQuery(ChangeQuery(cQry),'QRY',.T.)

	cWidgets += U_GetWdGet(1, {aParam[4], QRY->SC8_NUM, aParam[2], "Em processo de cotação", aParam[5]+".apw"})

Return  

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
	//Busca as filiais que o vendedor tem acesso
	cQry:= "Select DISTINCT ZTV_FILIAL "
	cQry+= "From "+RetSqlName("ZTV")+" ZTV "
//	cQry+= "Where ZTV_VEND = '"+HttpSession->CodVend+"' "
	cQry+= "Where ZTV_VEND = '"+cCodVend+"' "
	cQry+= "And ZTV.D_E_L_E_T_ = ' ' "
	If Select("QRF") > 0
		QRF->(dbCloseArea())
	Endif
	APWExOpenQuery(ChangeQuery(cQry),'QRF',.T.)	
	
	While QRF->(!Eof())
		cRet+= '	<option value="'+Alltrim(QRF->ZTV_FILIAL)+'" '+Iif(Alltrim(QRF->ZTV_FILIAL)= cFilFiltro,' selected ','')+'>'+Alltrim(QRF->ZTV_FILIAL)+" - "+FWFilialName(SM0->M0_CODIGO,QRF->ZTV_FILIAL,2)+'</option>'
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
	Else
		If !Empty(HttpSession->Superv) .and. HttpSession->Superv <> HttpSession->CodVend
			HttpSession->CodVend:= HttpSession->Superv
		Endif
	Endif
	
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
