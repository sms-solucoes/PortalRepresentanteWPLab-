#include 'protheus.ch'
#include 'totvs.ch'
#include 'rwmake.ch'
#include 'tbiconn.ch'
#include 'fileio.ch'


/*/{Protheus.doc} LogSMS
(long_description)
@author    Pedro.Souza
@since     15/09/2020
@version   ${version}
@example
(examples)
@see Classe para gerar arquivo de log
/*/
class LogSMS
    Data cFileName        As String
    Data cHora            As String
    Data cGrava           As String
    Method new(cPrefixo) constructor
    Method getFileName()
    Method setFileName(cFileName)
    Method eraseLog()
    Method saveMsg(cMsg)
    Method readLog()
    Method setSaveTime(lSave)
    Method setSaveLog(lSave)
    Method copyLocal(cPasta)
endclass

/*/{Protheus.doc} new
Metodo construtor
@author    Pedro.Souza
@since     15/09/2020
@version   ${version}
@param  cPrefixo, caracter, opcional prefixo do nome do arquivo (padrão err_)
@example
(examples)
@see (links_or_references)
/*/
Method New(cPrefixo) class LogSMS
    Default cPrefixo := "log_"
    ::cFileName := "\temp\"+cPrefixo+dtos(date())+"_"+strtran(time(),":","")+"_"+cValToChar(ThreadId())+".txt"
    ::cHora := "S"
    ::cGrava := "S"
return self

/*/{Protheus.doc} getFileName
Metodo que retorna o nome do arquivo de log
@author    Pedro.Souza
@since     15/09/2020
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
Method getFileName() class LogSMS
return ::cFileName

/*/{Protheus.doc} setFileName
Metodo que salva o nome do arquivo de log
@author    Pedro.Souza
@since     15/09/2020
@version   ${version}
@param  cFileName, caracter, nome do arquivo
@example
(examples)
@see (links_or_references)
/*/
Method setFileName(cFileName) class LogSMS
    Default cFileName:= ::cFileName
    ::cFileName := cFileName
return ::cFileName


/*/{Protheus.doc} eraseLog
Metodo que apaga o arquivo de log
@author    Pedro.Souza
@since     15/09/2020
@version 1.0
@example
/*/
Method eraseLog() class LogSMS
    if file(::cFileName)
        ferase(::cFileName)
    Endif
Return self


/*/{Protheus.doc} saveMsg
Metodo que salva a mensagem no arquivo de log
@author    Pedro.Souza
@since     15/09/2020
@param  cMsg, caracter, mensagem para salvar no arquivo de log
@version 1.0
@example
/*/
Method saveMsg(cMsg) class LogSMS
    Local nLaco  := 1
    Local nHdl   := -1
    Local cPref  := ""
    Default cMsg:= ""

    if (::cGrava == "S")
        // Tenta criar / abrir o arquivo para o log
        while nLaco <= 5 .and. nHdl < 0
            If !File(::cFileName)
                nHdl := FCreate(::cFileName)
            Else
                nHdl := FOpen(::cFileName, FO_READWRITE)
            Endif
            nLaco++
        enddo
        if nHdl >= 0
            FSeek(nHdl,0,FS_END)
            if (::cHora == "S")
                cPref := time()+", "+cValToChar(ThreadId())+", "
            endif
            FWrite(nHdl,cPref+cMsg+CRLF)
            FClose(nHdl)
        Endif
    Endif
return self


/*/{Protheus.doc} readLog
Metodo que retorna um array das mensagens do log
@author    Pedro.Souza
@since     17/09/2020
@param  cMsg, caracter, mensagem para salvar no arquivo de log
@version 1.0
@example
/*/
Method readLog() class LogSMS
    Local aLinhas := {}
    Local nHandle
    Local cLine
    BEGIN SEQUENCE
        if file(::cFileName)
            nHandle := FT_FUse(::cFileName)
            if nHandle = -1
                conout("Problema ao ler o arquivo de log. "+::cFileName+". Erro:"+cValToChar(ferror())+CRLF)
                break
            endif
            // posiciona na primeira linha
            ft_fgotop()
            While !FT_FEOF()
                cLine := FT_FReadLn()
                aadd(aLinhas, cLine)
                FT_FSKIP()
            End
            // Fecha o Arquivo
            FT_FUSE()
        endif   // if file(::cFileName)
    RECOVER
//        cRet := "Erro"
    END SEQUENCE
return aLinhas


Method setSaveTime(lSave) class LogSMS
    default lSave := .f.
    ::cHora := iif(lSave, "S", "N")
return self

Method setSaveLog(lSave) class LogSMS
    default lSave := .t.
    ::cGrava := iif(lSave, "S", "N")
return self

Method copyLocal(cPasta) class LogSMS
    if (file(self:getFileName()))
        cpys2t(self:getFileName(), cPasta, .t.)
    Endif
return self
