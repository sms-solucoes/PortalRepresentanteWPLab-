#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
#include "Fileio.ch"
#DEFINE SMSDEBUG
/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � MaiPBol   � Autor � Lucilene Mendes     	 � Data �09.12.17 ���
��+----------+------------------------------------------------------------���
���Descri��o � Envio da BOLETO por e-mail no Portal                       ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function MaiPBol()
Local cHtml
Local cFilePrint:= ''
Local cDirDoc	:= ''
Local lEmail	:= .F.
Local i
Local nRecSE1

Web Extended Init cHtml Start U_inSite()
    
    lEmail:= !Empty(Alltrim(HttpPost->email))
    If lEmail .and. At("@",Alltrim(HttpPost->email)) <= 0 
    	cHtml:= 'E-mail invalido!'+CRLF
    	Return cHtml
    Endif
    
    nRecSE1 := Val(Iif(Type("HttpPost->DOC") == "U",HttpGet->DOC,HttpPost->DOC))
    If nRecSE1 <= 0
    	cHtml:= 'Boleto n�o dispon�vel!'+CRLF	
	    Return cHtml
	Endif    
	    
    //Posiciona na NF
    dbSelectArea("SE1")
    SE1->(dbGoto(nRecSE1))
	
	//Troca de filial
	u_PTChgFil(SE1->E1_FILIAL)
	
    dbSelectArea("SE1")
    SE1->(dbGoto(nRecSE1))
	
	cDirDoc	:= '\anexosportal\boleto\'
    makedir(cDirDoc)
	//Composicao do nome do arquivo: DANFE + nr nf + DATA EMISSAO
	cFilePrint := "BOLETO_"+SE1->E1_FILIAL+"_"+AllTrim(SE1->E1_NUM)+"_"+alltrim(SE1->E1_PARCELA)+"_"+DTOS(SE1->E1_EMISSAO) //+'.rel'
		
    //TODO - Gera��o do BOLETO em PDF
    U_BOLPDF(nRecSE1, cDirDoc, cFilePrint)
	//Sleep( 4000 ) //aguarda 4 segundos para gera��o do arquivo pdf
	for i:=1 to 10
    	Sleep( 500 )
        Conout("AGUARDE PDF..."+cValtochar(i))
        if File(cDirDoc+cFilePrint+'.pdf')
            Exit
        Endif
    Next

    If !File(cDirDoc+cFilePrint+'.pdf')
		cHtml:= 'Falha ao gerar a BOLETO!'+CRLF	
		Conout("ERRO BOLETO:"+cHtml)
        if !lEmail
            cHtml := ""
        endif
        Return cHtml
	Endif    
	    
	If lEmail
        If envBol(cDirDoc+cFilePrint,HttpPost->email, SE1->E1_NUM, SE1->E1_PARCELA)
            cHtml := 'E-mail enviado com sucesso.'+CRLF
        Else
            cHtml := 'Houve falha no envio do e-mail. Tente novamente.'+CRLF
        EndIf
	Endif 
    
    If !lEmail 
    	If File(cDirDoc+cFilePrint+'.pdf')
	    	cHtml:= cFilePrint+'.pdf'
    	Else
    		cHtml:= 'Falha ao gerar o arquivo. Tente novamente.'
            Conout("ERRO BOLETO:"+cHtml)
            cHtml := ""
    	Endif	
    Endif  
    
Web Extended End

Return (cHTML) 


Static Function envBol(cAnexo,cMail,cDoc, cParcela)
    Local _cMsgem   := ''
    Local _cStyle   := ''
    Local _cDirWF   := ""
    // Local _lRet     := .F.

    Private oProcAprov

    //Diret�rio onde est� o arquivo HTML
    If Empty(_cDirWF)
        _cDirWf := '\WORKFLOW\'
    Endif

    If Right(_cDirWF,1) <> '\'
        _cDirWF += '\'
    Endif

    _cDirWF += 'PortalWF\'
    
    // Crio o objeto oProcAprov, que recebe a inicializa��o da classe TWFProcess.
    // Repare que o primeiro Par�metro � o c�digo do processo cadastrado no configurador
    oProcAprov := TWFProcess():New( 'ORCMAIL','FN' )

    //Informo o t�tulo do email.
    oProcAprov:cSubject :=  'Roberlo - Envio de Boleto '+cDoc+"/"+cParcela

    // Crio uma task. Um Processo pode ter v�rias Tasks(tarefas). Para cada Task
    // informo um nome para ela e o HTML envolvido. Repare que o path do HTML � sempre abaixo do RootPath do AP7.
    // aqui usarei uma task para cada PC enviada
    oProcAprov:NewTask('ORCMAIL', _cDirWF+'OrcMail.HTM' )

    oProcAprov:AttachFile(cAnexo+'.pdf')
    

    //Destinat�rio

    oProcAprov:cTo := cMail
    _cMsgem := 'Prezado Cliente,<br><br>Segue anexo BOLETO referente a nota fiscal '+cDoc+' parcela '+cParcela+'.' + CRLF

    oProcAprov:oHtml:ValByName('MSGEM',_cMsgem)
    oProcAprov:oHtml:ValByName('TITULO',"BOLETO")

    _cStyle := ""
    // Endere�o dos CSS e Imagens da Pagina
    oProcAprov:oHtml:ValByName('cCSS',_cStyle)
   

    // Envio do email 
    oProcAprov:Start()
    oProcAprov:Finish()
    
Return .T.


