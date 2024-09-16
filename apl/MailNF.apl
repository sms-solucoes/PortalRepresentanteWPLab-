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
���Fun��o    � MailNF   � Autor � Lucilene Mendes     	 � Data �09.12.17 ���
��+----------+------------------------------------------------------------���
���Descri��o � Envio da DANFE por e-mail  		                          ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function MailNF()
Local cHtml
Local cFilePrint:= ''
Local cDirDoc	:= ''
Local cTipo     := ''
Local cArqXML   := ''
Local lEmail	:= .F.

Web Extended Init cHtml Start U_inSite()
    
    lEmail:= !Empty(Alltrim(HttpPost->email))
    If lEmail .and. At("@",Alltrim(HttpPost->email)) <= 0 
    	cHtml:= 'E-mail invalido!'+CRLF
    	Return cHtml
    Endif
    
    nRecF2 := Val(Iif(Type("HttpPost->DOC") == "U",HttpGet->DOC,HttpPost->DOC))
    cTipo :=Iif(Type("HttpPost->TIPO") == "U",Iif(Type("HttpGet->TIPO") == "U","A",HttpGet->TIPO),HttpPost->TIPO)

    If nRecF2 <= 0
    	cHtml:= 'DANFE n�o dispon�vel!'+CRLF	
	    Return cHtml
	Endif    
	    
    //Posiciona na NF
    dbSelectArea("SF2")
    SF2->(dbGoto(nRecF2))
	
	//Troca de filial
	u_PTChgFil(SF2->F2_FILIAL)
	
	dbSelectArea("SF2")
    SF2->(dbGoto(nRecF2))
	
	cDirDoc	:= '\anexosportal\danfe\'
    //Composicao do nome do arquivo: DANFE + nr nf + DATA EMISSAO
    cFilePrint := "DANFE_"+AllTrim(SF2->F2_DOC)+"_"+DTOS(SF2->F2_EMISSAO)
    
    If cTipo = '2'
        cArqXML:= cDirDoc+cFilePrint+".xml"   
        u_zSpedXML(SF2->F2_DOC, SF2->F2_SERIE, cArqXML, .f.) 
        Sleep( 4000 ) //aguarda 4 segundos para gera��o do arquivo pdf
        If !File(cArqXML)
            cHtml:= 'Falha ao gerar o XML!'+CRLF	
            Return cHtml
        Else
            cHtml:= cFilePrint+'.xml'
        Endif  
          
	Else
        //Gera��o da DANFE em PDF
        U_DANFEPDF(nRecF2,cDirDoc, cFilePrint)
        Sleep( 4000 ) //aguarda 4 segundos para gera��o do arquivo pdf
        If !File(cDirDoc+cFilePrint+'.pdf')
            cHtml:= 'Falha ao gerar a DANFE!'+CRLF	
            Return cHtml
        Else
            cHtml:= cFilePrint+'.pdf' 
        Endif  
    Endif

	If lEmail
        If MailDanfe(cDirDoc+cFilePrint,HttpPost->email, SF2->F2_DOC, SF2->F2_SERIE)
            cHtml := 'E-mail enviado com sucesso.'+CRLF
        Else
            cHtml := 'Houve falha no envio do e-mail. Tente novamente.'+CRLF
        EndIf
	Else

    Endif 
    
Web Extended End

Return (cHTML) 


Static Function MailDanfe(cAnexo,cMail,cDoc, cSerie)
    Local _cMsgem   := ''
    Local _cStyle   := ''
    Local _cDirWF   := ""
    Local _lRet     := .F.

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
    oProcAprov:cSubject :=  'Roberlo - Envio de Danfe NF '+cDoc+"/"+cSerie

    // Crio uma task. Um Processo pode ter v�rias Tasks(tarefas). Para cada Task
    // informo um nome para ela e o HTML envolvido. Repare que o path do HTML � sempre abaixo do RootPath do AP7.
    // aqui usarei uma task para cada PC enviada
    oProcAprov:NewTask('ORCMAIL', _cDirWF+'OrcMail.HTM' )

    oProcAprov:AttachFile(cAnexo+'.pdf')
    oProcAprov:AttachFile(cAnexo+'.xml')


    //Destinat�rio

    oProcAprov:cTo := cMail
    _cMsgem := 'Prezado Cliente,<br><br>Segue anexo DANFE referente a nota fiscal '+cDoc+' s�rie '+cSerie+'.'+chr(10)+chr(13)

    oProcAprov:oHtml:ValByName('MSGEM',_cMsgem)
    oProcAprov:oHtml:ValByName('TITULO',"DANFE")

    _cStyle := ""
    // Endere�o dos CSS e Imagens da Pagina
    oProcAprov:oHtml:ValByName('cCSS',_cStyle)
   

    // Envio do email 
    oProcAprov:Start()
    oProcAprov:Finish()
    
Return .T.


/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � ExecBat       � Autor � Lucilene Mendes	 � Data �09.12.17 ���
��+----------+------------------------------------------------------------���
���Descri��o � Executa bat para evitar erro em fun��o de gera��o da danfe ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function ExecBat()
      
Local cCommand      := ""
Local cPath     := ""
Local lWait      := .F.

cCommand := "D\totvs\microsiga\Protheus12\ambientes\Teste\web\Portal SMS\danfe.bat"
cPath     := "D\totvs\microsiga\Protheus12\ambientes\Teste\web\Portal SMS\"

WaitRunSrv( @cCommand , @lWait , @cPath )

Return .T.
