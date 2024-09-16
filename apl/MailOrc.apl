#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
#include "Fileio.ch"
#DEFINE SMSDEBUG
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ MailOrc   ¦ Autor ¦ Lucilene Mendes     	 ¦ Data ¦28.08.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Envio do orcamento por e-mail                              ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function MailOrc()
Local cHtml
Local nTFil := FWSizeFilial()
Local cItem := ""
Local cTr   := ""
Local cTrHid:= ""
Local cDoc	:= ""
Local nLin	:= 0
Local a		:= 0
Local nTNum := 0
Local nTPro := 0
Local nDiasEnt := 0 
Local nPosFrete:= 0
Local lDigitado:= .F.
Local lMoeda    := .F.
Local lNumber   := .F.
Local aTpFrete  := {}
Local aTipoOrc  := {}
Local _cArq
Local nHandle
Local cFileLoc

Private cFilVen     := ""
Private cDirOrc     := "anexosPortal\orcamentos\"
Private cDirPortal  := ""
Private cEndServ    := "" // Endereço do servidor da pagina de Portal
Private cNumOrc 	:= ""
Private cEmissao 	:= ""
Private cOrcCabec   := ""
Private cOrcItens   := ""
Private cItensHid   := ""
Private cBotoes     := ""
Private cTpFrete    := ""
Private cValFre     := ""
Private cTransp     := ""
Private cCliente    := ""
Private cTabela     := ""
Private cTipoOrc    := ""
Private cFaixaDesc  := ""
Private cEntrega    := ""
Private cBtnItens   := ""
Private cTblDesc    := ""
Private cObsInterna := ""
Private cObsNota    := ""
Private cCss		:= ""
Private cdivComis	:= ""
Private nTVlrUnit   := 0
Private nTQtdItem   := 0
Private nTTotal     := 0
Private nTImpostos  := 0
Private nTFrete     := 0
Private nTComiss	:= 0

Private nItens      := 0
Private aAnexos     := {}
Private lEdit       := .F.                              
Private lMail	  	:= .F.
                
Private cSite     := "u_PortalLogin.apw"
Private cPagina   := "Orçamento de Venda"
Private cMenus    := ""
Private cTitle    := "Portal SMS"
Private cAnexos   := ""
Private cCodLogin := ""
Private cVendLogin:= ""
Private aItens    := {}
Private aFaixaDesc:= {}
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
	cSite	:= Procname()+".apw?PR="+cCodLogin
    
	// Monta o cabeçalho para a pagina
	cHeader := GetHeader(cTitle, cSite) 
	
    //Atualiza as variáveis
    cEndServ := GetMv('MV_WFBRWSR')
    cCodVend := cVendLogin //HttpSession->CodVend
    cNomeVend:= HttpSession->Nome
    cItem := StrZero(1,TamSX3("CK_ITEM")[1])
    lEdit := .F.     
    lMail := !HttpGet->opc = 'print'
    nDoc := val(Iif(Type("HttpPost->DOC") == "U",HttpGet->DOC,HttpPost->DOC))
     
    //Posiciona no Orçamento
    dbSelectArea("SCJ")
    SCJ->(dbGoTo(nDoc))
    
    //Troca de filial
	u_PTChgFil(SCJ->CJ_FILIAL)


    //Gera o pdf
    _cArq:= u_ImprOrcto(nDoc)
    
    If lMail
	    If !Empty(Alltrim(HttpPost->email)) .and. At("@",Alltrim(HttpPost->email)) > 0
	       
	        cFileLoc:= cDirOrc
	        
            If !File(_cArq)
                cHtml := 'Houve falha na geração do PDF. Tente novamente.'+CRLF
            Endif


			If Empty(SCJ->CJ_NUM)
				cHtml := 'Houve falha no envio do e-mail. Tente novamente.'+CRLF
			Endif	
	
	        If EnvOrcMail(_cArq,HttpPost->email)
	            cHtml := 'E-mail enviado com sucesso.'+CRLF
	        Else
	            cHtml := 'Houve falha no envio do e-mail. Tente novamente.'+CRLF
	        EndIf
	    Else
	        cHtml := 'E-mail invalido!'+CRLF
	    EndIf
	Else
        cArquivo:= Alltrim(Substr(_cArq, Rat('\',_cArq)+1))
        Return cArquivo
        //cHtml:= 'http://'+cEndServ+'/anexos/orcamentos/'+cArquivo
    Endif 
    
    
Web Extended End

Return (cHTML) 


Static Function EnvOrcMail(cAnexo,cMail)
    Local _cMsgem   := ''
    Local _cStyle   := ''
    Local _cDirWF       := ""
    Local _lRet         := .F.

    Private oProcAprov

    //Diretório onde está o arquivo HTML
    If Empty(_cDirWF)
        _cDirWf := '\WORKFLOW\'
    Endif

    If Right(_cDirWF,1) <> '\'
        _cDirWF += '\'
    Endif

    _cDirWF += 'PortalWF\'
    
    // Crio o objeto oProcAprov, que recebe a inicialização da classe TWFProcess.
    // Repare que o primeiro Parâmetro é o código do processo cadastrado no configurador
    oProcAprov := TWFProcess():New( 'ORCMAIL','FN' )

    //Informo o título do email.
    oProcAprov:cSubject :=  'Envio de Orcamento '//+cPedido

    // Crio uma task. Um Processo pode ter várias Tasks(tarefas). Para cada Task
    // informo um nome para ela e o HTML envolvido. Repare que o path do HTML é sempre abaixo do RootPath do AP7.
    // aqui usarei uma task para cada PC enviada
    oProcAprov:NewTask('ORCMAIL', _cDirWF+'OrcMail.HTM' )

    oProcAprov:AttachFile(cAnexo)


    //Destinatário
    oProcAprov:cTo := cMail
    _cMsgem := 'Segue anexo orçamento nº '+SCJ->CJ_FILIAL+"/"+SCJ->CJ_NUM+'. '

    oProcAprov:oHtml:ValByName('MSGEM',_cMsgem)
    oProcAprov:oHtml:ValByName('TITULO',"Orçamento de Venda")

    _cStyle := ""
    // Endereço dos CSS e Imagens da Pagina
    oProcAprov:oHtml:ValByName('cCSS',_cStyle)
   

    // Envio do email 
    oProcAprov:Start()
    oProcAprov:Finish()
Return .T.
/*
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++-------------------------------------------------------------------------++
++ Função    | MntCSSOrc | Autor  | Lucilene Mendes | Data | 05/12/2017     ++
++-------------------------------------------------------------------------++
++ Descrição | Montagem do CSS do HTML do Orcamento                         ++
++-------------------------------------------------------------------------++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/
Static Function MntCSSOrc(lMail)
    Local _cCSS := ""

    if lMail
		_cCSS := "<style>"+CRLF
        _cCSS += leArqCSS("assets/vendor/bootstrap/css/bootstrap.css")+CRLF
        _cCSS += leArqCSS("assets/stylesheets/theme.css")+CRLF
        _cCSS += leArqCSS("assets/stylesheets/skins/default.css")+CRLF
        _cCSS += leArqCSS("assets/vendor/jquery-datatables-bs3/assets/css/datatables.css")+CRLF
        _cCSS += leArqCSS("assets/stylesheets/theme-custom.css")+CRLF
		_cCSS += "</style>"+CRLF
    Else

        _cCSS := '<link rel="stylesheet" href="assets/vendor/bootstrap/css/bootstrap.css" />'+CRLF
        _cCSS += '<link rel="stylesheet" href="assets/stylesheets/theme.css" />'+CRLF
        _cCSS += '<link rel="stylesheet" href="assets/stylesheets/skins/default.css" />'+CRLF
        _cCSS += '<link rel="stylesheet" href="assets/vendor/jquery-datatables-bs3/assets/css/datatables.css" />'+CRLF
    EndIf
return _cCSS



/*
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++-------------------------------------------------------------------------++
++ Função    | leArqCSS | Autor  | Lucilene Mendes | Data | 05/12/2017     ++
++-------------------------------------------------------------------------++
++ Descrição | Le arquivo CSS e retorna como string                        ++
++-------------------------------------------------------------------------++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/
static function leArqCSS(cArq)
    Local cRet := ""
    Local nHdl
    Local cStr
    Local cBase := GetNewPar("AA_DIRCSS","\web\PortalSMS\")

    if file(cBase+cArq)
        nHdl := fopen(cBase+cArq, FC_NORMAL)
        cStr := ""
        if ferror() <> 0
            Conout("Erro de abertura: " + cValToChar(ferror())+ " " + cArq)
        else
            while .t.
                cStr := freadstr(nHdl, 4096*4)
                if empty(cStr)
                    exit
                EndIf
                cRet += cStr
            enddo
            fclose(nHdl)
        endif
    endif

return cRet


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ GetHeader     ¦ Autor ¦ Anderson Zelenski ¦ Data ¦15.08.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Gera o cabeçalho das paginas para o portal                 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function GetHeader(cTitle, cSite)
Local cHeader := ""
Local cFim := Chr(13)+Chr(10)
Local cEndServ := GetMv('MV_WFBRWSR') // Endereço do servidor da pagina de Portal
 
	cHeader := '<div class="logo-container">'+cFim
	cHeader += '	<a href="" class="logo pull-left">'+cFim
	cHeader += '		<img src="http://'+cEndServ+'/imagens/logo.png" alt="'+cTitle+'" height="35"/>'+cFim
	cHeader += '	</a>'+cFim
	cHeader += '	<div class="visible-xs toggle-sidebar-left" data-toggle-class="sidebar-left-opened" data-target="html" data-fire-event="sidebar-left-opened">'+cFim
	cHeader += '		<i class="fa fa-bars" aria-label="Toggle sidebar"></i>'+cFim
	cHeader += '	</div>'+cFim
	cHeader += '</div>'+cFim
	
Return cHeader
