#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ Financeiro  ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦03.12.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Grid com os títulos em aberto do vendedor.		  		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function Financeiro()
Local cHtml
Local cValTit	:= ""
Local cValPag	:= ""
Local cSldTit	:= ""
Local cFiltro	:= ""
Local cDataDe	:= ""
Local cDataAte	:= ""
Local cFiltDe	:= ""
Local cFilAte	:= ""
Local cFilSit   := "A"
Local cFilBol   := "T"
Local _nVlrJuros:= 0                      
Local _nVlrDoc	:= 0
Local _nVlrAbat	:= 0
                      
Private cColunas:= ""
Private cItens	:= ""  
Private cTopo	:= ""  
Private cSite	:= "u_PortalLogin.apw"
Private cPagina	  := "Financeiro"
Private cTitle	  := "" 
Private lTableTools:= .T.
Private lSidebar:= .F.
Private cCodLogin := ""
Private cVendLogin:= ""
Private cJavaScr:= ""

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
	cMenus := cMenus := U_GetMenus(AllTrim(Upper(Procname())), cVendLogin)
	 
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
		cFiltro:= HttpPost->tipoFiltro   
	Else
	    //Variáveis dos input dos filtros
		cFiltDe:= dtoc(date()-30)
		cFilAte:= dtoc(date())
		//Variáveis de filtro da query
		cDataDe:= dtos(date()-30)
		cDataAte:= dtos(date())
		cFiltro:= '1'   //1=Emissao, 2=Vencto
	Endif
	
    //Filtros
    cTopo:= '<div class="row form-group">'
    cTopo+= '	<div class="col-sm-12" align="right">'
    cTopo+= '	<form name="formGrid" id="formGrid" method="POST" action="U_Financeiro.apw?PR='+cCodLogin+'">'
    
    cTopo+= '		<label class="col-md-2 control-label">Tipo Data:</label>'
    cTopo+= '  		<div class="col-sm-2">'
	cTopo+= '		 	<div class="input-group">'
	cTopo+= '				<select data-plugin-selectTwo class="form-control populate mb-md" name="tipofiltro" id="tipofiltro" '
	cTopo+= ' 				data-plugin-options='+"'"+'{"minimumResultsForSearch": "-1"}'+"'"+' required="" aria-required="true" value="'+cFiltro+'">'
	cTopo+= '					<option value="1"'+Iif(cFiltro='1',' selected','')+'>Emissão</option>'
	cTopo+= '					<option value="2"'+Iif(cFiltro='2',' selected','')+'>Vencimento</option>'
    cTopo+= '				</select>'
    cTopo+= '			</div>'
    cTopo+= '		</div>'
  	
  	cTopo+= '		<label class="col-md-1 control-label">De:</label>'
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
    cTopo+= '		<div class="col-md-2">'
    cTopo+= '			<button class="btn btn-primary" id="btFiltro" value="" onclick="this.value= '+"'"+'Aguarde...'+"'"+';this.disabled= '+"'"+'disabled'+"'"+';Filtro()" name="btFiltro">'
    cTopo+= '			<i class="fa fa-filter"></i> Filtrar</button>' 
    cTopo+= '		</div>' 
    cTopo+= '	</form>'
	cTopo+= '	</div>'
	cTopo+= '</div>'
	
	
	// Buscar os Títulos
	cQry := " SELECT DISTINCT case when e1_saldo>0 then 'ABERTO' else 'BAIXADO' end STATUS, E1_FILIAL, E1_NUM, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_PARCELA, E1_EMISSAO, "
	cQry += " E1_VENCREA, E1_TIPO, E1_VALOR, E1_SALDO, E1_NUMBCO, E1_PORTADO, E1_ACRESC, E1_VALJUR, E1_DECRESC, SE1.R_E_C_N_O_ NUMREC, A1_CGC, A1_NREDUZ, A1_VEND VEND "
	cQry += "FROM "+RetSqlName("SE1")+" SE1 "
	cQry += " JOIN " + RetSqlName("SA1")+" SA1 ON (E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = ' ')"
	If HttpSession->Tipo = 'S' //Supervisor acessa todas as informações da sua equipe
    	cQry+= " WHERE A1_VEND in "+FormatIn(HttpSession->Equipe,"|")+" "
	Else	
//		cQry+= " WHERE A1_VEND ='"+HttpSession->CodVend+ "' "
		cQry+= " WHERE A1_VEND ='"+cVendLogin+ "' "
	Endif	
	If cFiltro = '1' //Emissão
		cQry+= " AND E1_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"' "
	Else
		cQry+= " AND E1_VENCREA between '"+cDataDe+"' and '"+cDataAte+"' "
	Endif
	cQry += " AND E1_TIPO NOT IN ('NCC') "
	cQry += " AND SE1.D_E_L_E_T_ = ' ' "
	cQry += " ORDER BY 1, E1_VENCREA, SE1.R_E_C_N_O_ "
	cQry := ChangeQuery(cQry)
	
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	Endif	
	APWExOpenQuery(ChangeQuery(cQry),'QRY',.T.)
	
	TcSetField("QRY","E1_EMISSAO","D")
	TcSetField("QRY","E1_VENCREA","D")

	
	//Cabeçalho do grid
	cColunas+='<th>Número</th>'
	cColunas+='<th>Parcela</th>'
	cColunas+='<th>Tipo</th>'
	cColunas+='<th>Cliente</th>'
	cColunas+='<th>CPF/CNPJ</th>'
	cColunas+='<th>Emissão</th>'
	cColunas+='<th>Vencimento</th>'
	cColunas+='<th>Valor</th>'
	cColunas+='<th>Valor Pago</th>'
	cColunas+='<th>Saldo</th>'
	cColunas+='<th>Status</th>'
	cColunas+='<th></th>'
	If HttpSession->Tipo = 'S' //Supervisor 
    	cColunas+='<th>Vendedor</th>'
	Endif
	    
	While QRY->(!Eof())
		
		If dDatabase > QRY->E1_VENCREA
			_nVlrJuros:= Round(QRY->E1_VALJUR * (dDatabase - QRY->E1_VENCREA),2)
		Else
			_nVlrJuros:= 0
		Endif
		
		_nVlrDoc := 0
		
		//Calcula o valor do título somente se o título possuir saldo
		If QRY->E1_SALDO > 0
			cFilAnt:= QRY->E1_FILIAL
			_nVlrAbat :=SomaAbat(QRY->E1_PREFIXO,QRY->E1_NUM,QRY->E1_PARCELA,"R",1,dDatabase,QRY->E1_CLIENTE,QRY->E1_LOJA)
			_nVlrDoc := Round((((QRY->E1_SALDO+_nVlrJuros+QRY->E1_ACRESC)- QRY->E1_DECRESC)*100)-(_nVlrAbat*100),0)/100 
		Endif
         
		If QRY->E1_TIPO $ "NCC,IN-,IR-,CS-,PI-,CF-,IS-"
			cValTit:= TransForm(QRY->E1_VALOR*-1,"@E 999,999,999.99")
			cValPag:= TransForm((QRY->E1_VALOR-QRY->E1_SALDO)*-1,"@E 999,999,999.99")
			cSldTit:= TransForm(_nVlrDoc,"@E 999,999,999.99")
		Else
			cValTit:= TransForm(QRY->E1_VALOR ,"@E 999,999,999.99")
			cValPag:= TransForm(QRY->E1_VALOR-QRY->E1_SALDO ,"@E 999,999,999.99")
			cSldTit:= TransForm(_nVlrDoc,"@E 999,999,999.99")
		Endif
		
		cItens+='<tr role="button" onclick="window.document.location='+"'#'"+';">'
	    cItens+='	<td>'+trim(QRY->E1_PREFIXO)+'/'+QRY->E1_NUM+'</td>'
	    cItens+='	<td>'+QRY->E1_PARCELA+'</td>'
	    cItens+='	<td>'+QRY->E1_TIPO+'</td>'
	    cItens+='	<td>'+QRY->E1_CLIENTE+"/"+QRY->E1_LOJA+" - "+Alltrim(QRY->A1_NREDUZ)+'</td>'  
	    cItens+='	<td>'+Transform(QRY->A1_CGC,"@R 99.999.999/9999-99")+'</td>'  
	    cItens+='	<td data-order="'+dtos(QRY->E1_EMISSAO)+'">'+DTOC(QRY->E1_EMISSAO)+'</td>'  
	    cItens+='	<td data-order="'+dtos(QRY->E1_VENCREA)+'">'+DTOC(QRY->E1_VENCREA)+'</td>'  
	    cItens+='	<td>'+cValTit+'</td>'  
	    cItens+='	<td>'+cValPag+'</td>'  
	    cItens+='	<td>'+cSldTit+'</td>'  
	    cItens+='	<td>'+QRY->STATUS+'</td>'
	    cItens+='	<td class="actions">'
	    If QRY->STATUS = "ABERTO" .and. !Empty(QRY->E1_PORTADO) .and. !empty(QRY->E1_NUMBCO) // .and. QRY->E1_PORTADO == "422"
        	cItens+='   	<a class="modal-email" href="#" data-toggle="tooltip" data-original-title="Enviar BOLETO por e-mail" title="" onClick="javascript:abreEmail('+cValtoChar(QRY->NUMREC)+');">'
        	cItens+='			<i class="fa fa-envelope-o"></i>'
        	cItens+='		</a>'
        	cItens+='   	<a href="#" data-toggle="tooltip" data-original-title="Abrir BOLETO" title="" onClick="javascript:ViewBoleto('+cValtoChar(QRY->NUMREC)+');">'
        	cItens+='			<i class="fa fa-file-pdf-o"></i>'
        	cItens+='		</a>'
	    Endif
	    cItens+='	</td>'
	    If HttpSession->Tipo = 'S' //Supervisor
	    	cItens+='	<td>'+QRY->VEND+' - '+Posicione("SA3",1,xFilial("SA3")+QRY->VEND,"A3_NREDUZ")+'</td>'
	    Endif	 
	    cItens+='</tr>'
	 
		QRY->(dbSkip())
	End
	


	cItens+= montarForm("Boleto", "MaiPBol.apw?PR="+cCodLogin)

	cJavaScr += 'var aBolImp = [];' + CRLF
	cJavaScr += 'function ViewBoleto(idBoleto){' + CRLF
	cJavaScr += '	if (! aBolImp.includes(idBoleto))  {' + CRLF
	cJavaScr += '   	aBolImp.push(idBoleto); ' + CRLF
	cJavaScr += '   	$.ajax({  ' + CRLF
	cJavaScr += '   		url: "U_MaiPBol.apw?PR='+cCodLogin+'",' + CRLF
	cJavaScr += '   		type: "POST",' + CRLF
	cJavaScr += '   		data: "email=&doc="+idBoleto,' + CRLF
	cJavaScr += '   		cache: false, ' + CRLF
	cJavaScr += '   		success: ' + CRLF
	cJavaScr += '   	   		function(docBoleto) {' + CRLF
	cJavaScr += '   				if (docBoleto.indexOf("HTTP-EQUIV") > 0 ) {' + CRLF
	cJavaScr += '   					$("html").html(docBoleto);' + CRLF
	cJavaScr += '   					return;' + CRLF
	cJavaScr += '   				}' + CRLF
	cJavaScr += '   	   			if (docBoleto == "" ) {' + CRLF
	cJavaScr += '   					bootbox.alert("Falha ao gerar o arquivo. Tente novamente mais tarde.");' + CRLF
	cJavaScr += '   				}' + CRLF
	cJavaScr += '   				if (docBoleto.substr(0,6) == "BOLETO") {' + CRLF
	cJavaScr += '   	   				window.open("/anexos/boleto/"+docBoleto,"_blank")' + CRLF
	cJavaScr += '   	   			}' + CRLF
	cJavaScr += '   	   			for( var i = 0; i < aBolImp.length; i++){ ' + CRLF
	cJavaScr += '   	   				if ( aBolImp[i] == idBoleto) { ' + CRLF
	cJavaScr += '   	   					aBolImp.splice(i, 1); ' + CRLF
	cJavaScr += '   	   					i--; ' + CRLF
	cJavaScr += '   	   				}' + CRLF
	cJavaScr += '   	   			}' + CRLF
	cJavaScr += '   	   		}' + CRLF
	cJavaScr += '   	});' + CRLF
	cJavaScr += '   }' + CRLF
	cJavaScr += '}' + CRLF

	
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
// conout(cret)	
return cRet  
