#Include "PROTHEUS.CH"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo     ¦ MailCM   ¦ Autor ¦  Lucilene Mendes   ¦ Data ¦29.07.2015  ¦¦¦
¦¦+-----------+-----------------------------------------------------------¦¦¦
¦¦¦Descriçäo  ¦ Programa padrão para de envio de emails de comunicados    ¦¦¦
¦¦+-----------+-----------------------------------------------------------¦¦¦
¦¦¦Parametros ¦ cTipo 	  - Tipo do comunicado. Ex: Aviso de Inadimplencia¦¦¦
¦¦¦           ¦ aDest 	  - Array com os e-mails dos Destinatários        ¦¦¦
¦¦¦           ¦ aDestCpy  - Array com os e-mails de cópia do email        ¦¦¦
¦¦¦           ¦ cAssunto  - Assunto do E-mail                             ¦¦¦
¦¦¦           ¦ cMsg      - Mensagem do corpo do E-mail                   ¦¦¦
¦¦¦           ¦ cTracker  - Tabela com os itens do documento              ¦¦¦
¦¦¦           ¦ cLink  - Tabela com os itens do documento                 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function MailCM(cTipo,aDest,aDestCpy,cAssunto,cMsg,cTracker,cLink,aAnexo)
  
Local cDirWF  	:= Alltrim(GetMv('MV_WFDIR'))
Local cCompLink := ""
Local cDestMail := ""
Local cDestCC	:= ""
Local i			:= 0
Private cEndServ:= GetMv('MV_WFBRWSR') // Endereço do servidor da pagina do Portal
Private cLFRC	:= chr(13)+chr(10)
Private cCSS	:= ""
Private cLogoSMS:= ""
Default aAnexo	:= {}

If !Empty(aDest)                  
	If Empty(cDirWF)
		cDirWf := '\WORKFLOW\'
	Else
		If Right(cDirWF,1) <> '\'
			cDirWF += '\'
		Endif
	Endif
	cDirWF += 'PortalWF\'
	
	cCSS := MontaCSS()
	cLogoSMS := '<img src="http://'+cEndServ+'/images/logoSMS.png" alt="Desenvolvido por SMS Tecnologia da Informação" title="Desenvolvido por SMSTI Tecnologia da Informação">'
	//cLogoAero:= '<img src="http://'+cEndServ+'/images/logoAero.png">'
    
    If !Empty(cLink)
		cCompLink:='<div class="divLink" align="center">'
		cCompLink+='	<a href="'+cLink+'" target="_blank">Clique aqui para acessar este processo no Portal.</a>'
		cCompLink+='</div>
    Endif
	oProcAprov := TWFProcess():New('MAILCM','Workflow SMS')
	oProcAprov:cSubject := cAssunto
	oProcAprov:NewTask('WFOK',cDirWF+'MAILCM.HTM')
	
	cDestMail:= ""
	For i:= 1 to Len(aDest)
		If !Empty(aDest[i]) .and. "@" $ aDest[i]
			cDestMail+= aDest[i]+';'
		Endif	
	Next
	oProcAprov:cTo := cDestMail
	
	cDestCC:= ""
	For i:= 1 to Len(aDestCpy)
		If !Empty(aDestCpy[i]) .and. "@" $ aDestCpy[i]
			cDestCC+= aDestCpy[i]+';'
		Endif	
	Next
	If !Empty(cDestCC)
 		oProcAprov:cCC := cDestCC
    Endif

	If Len(aAnexo) > 0
		For i:= 1 to Len(aAnexo)
			oProcAprov:AttachFile(aAnexo[i])
		Next
	Endif
	oProcAprov:oHtml:ValByName('cTipo',Upper(cTipo))
	oProcAprov:oHtml:ValByName('cMsg',cMsg)
	oProcAprov:oHtml:ValByName('cCSS',cCSS)
	oProcAprov:oHtml:ValByName('TRACKER',cTracker)
	oProcAprov:oHtml:ValByName('cLogoSms',cLogoSms)
	oProcAprov:oHtml:ValByName('LINK',cCompLink)
	
	oProcAprov:Start()
	oProcAprov:Finish()
Endif

Return


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ MontaCSS  ¦ Autor ¦  Lucilene Mendes   ¦ Data ¦08.05.2015  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Monta o CSS para envio nos emails.                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function MontaCSS()
Local _cCSS := ""

	// Montagem do CSS para formatação do HTML
	_cCSS += 'BODY { margin:0; padding:0;background:#ECF0FF url(http://'+cEndServ+'/images/fundo.gif) repeat-x top;font-family: Tahoma, Arial, Helvetica, sans-serif;font-size:13px;color:#333; }'
	_cCSS += 'form{margin:0; padding:0; overflow:hidden;}'
	_cCSS += 'P { margin:0 0 15px 0; }'
	_cCSS += 'TD { font-size: 13px; vertical-align: top;}'
	
	_cCSS += 'A { text-decoration:none; color:#000; }'
	_cCSS += 'A:hover { color:#15568C; }'

	_cCSS += 'h1 { font-size:16px; }'
	_cCSS += 'h2 { font-size:14px; }'
	_cCSS += 'h3 { font-size:14px; }'
	_cCSS += 'h4 { font-size:14px; }'
	_cCSS += 'h5 { font-size:14px; }'
	_cCSS += 'h6 { font-size:14px; }'

	_cCSS += '#d_topo { margin:0 auto 0 auto; width:750px; margin-left: auto; margin-right: auto; text-align: center; }'

	_cCSS += '#d_corpo { width:980px; background:#f2f2f2; text-align: center; position:relative; width:750px; margin-top: 10px; margin-left: auto; margin-right: auto; }'
	_cCSS += '#d_rodape { width:100%; }'
	_cCSS += '#d_rodape_creditos { float: left; width:100%; text-align:center; height:40px; }'

	_cCSS += '#d_logo { float:left; background:url(http://'+cEndServ+'/images/logomailaero.png); width:187px; height:87px; margin-top:20px; }'
	_cCSS += '#d_intranet { margin:0 auto; background:url(http://'+cEndServ+'/imagens/intranet.png); width:247px; height:99px; }'

	_cCSS += '#d_esquerda { width:750px; text-align: left; }'

	_cCSS += '#d_noticias #d_noticias_titulo, '
	_cCSS += '#d_noticias #d_noticias_rodape { width:100%; height:33px; background: #393939; url(http://'+cEndServ+'/imagens/bg_noticias_titulo.png) no-repeat; }'
	_cCSS += '#d_noticias #d_noticias_rodape { background: #393939; url(http://'+cEndServ+'/imagens/bg_noticias_rodape.png) no-repeat; }'

	_cCSS += '#d_noticias #d_noticias_titulo img{ float:left; top:50%; margin-top: -13px; margin-left:10px; position:relative; } '
	_cCSS += '#d_noticias #d_noticias_titulo h2, #d_direita  { float:left; margin-top:9px; margin-left:10px; font-family:Arial, Helvetica, sans-serif; font-size:12px; color:#fff; text-transform:uppercase; } '
	_cCSS += '#d_noticias_conteudo { background:none; } '
	_cCSS += '#d_noticias_conteudo { padding:10px 10px 10px 10px; position:relative; background-color: #fff; } '
	_cCSS += '#d_noticias_conteudo h3 { margin:0px; font-family:Arial, Helvetica, sans-serif; font-size:14px; font-weight:normal; } '
	_cCSS += '#d_noticias_conteudo h3 strong { color:#0858A4; } '
	_cCSS += '#d_noticias_conteudo p { margin:0px; padding:7px 7px 7px 0; color:#818181; } '
	_cCSS += '#d_noticias_conteudo a:hover p { color:#000; } '
	_cCSS += '#d_noticias_conteudo p strong { font-family:Arial, Helvetica, sans-serif; font-size:13px; color:#F90; } '
	_cCSS += '#d_rodape1 { margin: 0 auto; height: 3px; background-color: #ff661b; } '
	_cCSS += '#d_rodape2 { margin: 0 auto; height: 4px; background-color: #ffb200; } '
	_cCSS += '#d_rodape_creditos span { margin:0 auto; font-family:Arial, Helvetica, sans-serif; font-size:11px; font-style:italic; color:#7E7E7E; display:block; } '
	_cCSS += '.centro { text-align:center; } '
	_cCSS += '.direita { text-align: right; } '
	_cCSS += '.negrito { font-weight: bold; } '
	_cCSS += '.sublinhado { text-decoration: underline; } '
	_cCSS += '.cls50porcento { float: left; clear: none; width: 49%; } '
	_cCSS += '#divFaturamento, #divPosicaoCliente { height: 420px; } '

	_cCSS += '.clsQuebra  { clear: none; height: 1px; margin: 0px; padding: 0px; width: 1px; } '
	_cCSS += '.divEmpilhavel, .divEmpilhavelQuebra { width: 50%; float: left; clear: right; height: 50px; } '
	_cCSS += '.divEmpilhavelQuebra { clear: right; } '
	_cCSS += '#tblFaturamento, #tblPosicaoCliente, #tblTracker { border-colapse: colapse; border-top: 1px solid #111; border-left: 1px solid #111; padding: 0px; margin: 0px; background-color: #E9E9E6; } '
	_cCSS += '#tblFaturamento td, #tblPosicaoCliente td, #tblTracker td { padding: 3px; border-right: 1px solid #111; border-bottom: 1px solid #111; border-colapse: colapse; } '
	_cCSS += '#tblPosicaoCliente { background-color: #F0FEFF; } '
	_cCSS += '#divPosicaoCliente { float: right; clear: right; height:420px; } '
	_cCSS += '.linhavermelha { border-bottom: 2px solid #324e8a; width: 100%; padding-bottom: 5px; margin-bottom: 5px; } '
	_cCSS += '.titulo { font-weight: bold; font-size: 16px; } '
	_cCSS += '.vermelho-escuro { color: #800000; } '
	_cCSS += '.vermelho { color: #C00303; } '
	_cCSS += '.branco { color: #FFF; } '
	_cCSS += '.verde { color: #008000; } '
	_cCSS += '.azul { color:#103090; } '

	_cCSS += '* html img/**/ { '
	_cCSS += '	filter:expression( '
	_cCSS += '	this.alphaxLoaded?"": ( '
	_cCSS += '		this.src.substr(this.src.length-4)==".png" ? ( '
	_cCSS += '			(!this.complete)?"": ( '
	_cCSS += '				this.runtimeStyle.filter= '
	_cCSS += '				("progid:DXImageTransform.Microsoft.AlphaImageLoader(src="+this.src+")")+ '
	_cCSS += '				String(this.onbeforeprint=this.runtimeStyle.filter="";this.src="+this.src+"").substr(0,0)+ '
	_cCSS += '					String(this.alphaxLoaded=true).substr(0,0)+ '
	_cCSS += '				String(this.src="'+cEndServ+'/imagens/spacer.gif").substr(0,0) '
	_cCSS += '			) '
	_cCSS += '		) : '
	_cCSS += '		this.runtimeStyle.filter="" '
	_cCSS += '	)); '
	_cCSS += '} '

Return _cCSS
