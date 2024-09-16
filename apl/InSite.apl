#INCLUDE "TOTVS.CH"  
#INCLUDE "APWEBEX.CH"  
#DEFINE  SESSHTTP "GlbSessions"
/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Portal SMS                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! Portal SMS - Insite                                     !
+------------------+---------------------------------------------------------+
!Nome              ! InSite                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Abre comunicacao com o servidor Protheus e as tabelas   !
!                  ! que serao utilizadas                                    !
+------------------+---------------------------------------------------------+
!Autor             ! Anderson Jose Zelenski                                  !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 19/09/2013                                              !
+----------------------------------------------------------------------------+
+------------------+---------------------------------------------------------+
!Descricao         ! Tratamento para verificar se a sessao do usuario esta ok!
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 08/02/2021                                              !
+----------------------------------------------------------------------------+
*/

User Function InSite(lCheckSess)
	Local cHtml := ""
	Local cSrvEmpresa := ""
	Local cSrvFilial := ""
	Local cWebModulo := "SIGAFIN"
	Local lConectar := .T.
    local oObjLog   := LogSMS():new()
    local oObjSess  := LogSMS():new()
    Local nI        := 0
    Local aInfo
    Local aDadSess
    Local lOk 
    default lCheckSess := .t.

	Public cEmpAnt
	Public cFilAnt

    cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL=u_PortalLogin.apw">'

	// Salvar o log da requisicao
    oObjLog:setFileName("\temp\"+Procname(1)+"_"+dtos(date())+".txt")
    oObjLog:saveMsg("("+ltrim(str(procline(1)))+") *** Portal ")
    if !empty(HTTPHEADIN->REMOTE_ADDR)
       oObjLog:saveMsg('HTTPHEADIN REMOTE_ADDR -> '+HTTPHEADIN->REMOTE_ADDR)
    endif
    if !empty(HTTPHEADIN->REMOTE_PORT)
       oObjLog:saveMsg('HTTPHEADIN REMOTE_PORT -> '+cValToChar(HTTPHEADIN->REMOTE_PORT))
    endif
    if !empty(HTTPCOOKIES->SESSIONID)
       oObjLog:saveMsg('HTTPCOOKIES SESSIONID -> '+HTTPCOOKIES->SESSIONID)
    endif
    if !empty(HttpSession->SESSIONID)
       oObjLog:saveMsg('SESSION SESSIONID -> '+HttpSession->SESSIONID)
    endif
    aInfo := HttpGet->aGets
    if valtype(aInfo) = "A"
        For nI := 1 to len(aInfo)
            oObjLog:saveMsg('GET '+str(nI,3)+' = '+aInfo[nI]+' -> '+&("HTTPGET->"+aInfo[nI]))
        Next
    endif
    aInfo := HttpPost->aPost
    if valtype(aInfo) = "A"
        For nI := 1 to len(aInfo)
            oObjLog:saveMsg('POST '+str(nI,3)+' = '+aInfo[nI]+' -> '+&("HTTPPOST->"+aInfo[nI]))
        Next
    endif
    if !empty(HttpSession->Tipo)
       oObjLog:saveMsg('SESSION = Tipo -> '+HttpSession->Tipo)
    endif
    If !empty(HttpSession->Superv) 
       oObjLog:saveMsg('SESSION = Superv -> '+HttpSession->Superv)
    endif
    if !empty(HttpSession->CodVend)
       oObjLog:saveMsg('SESSION = CodVend -> '+HttpSession->CodVend)
    endif


	// Verificar filial logada
	if empty(HttpSession->Empresa)
		cSrvEmpresa := "02"
	else
		cSrvEmpresa := HttpSession->Empresa
	EndIf
	
	if empty(HttpSession->Filial)
		cSrvFilial := "010101"
	else
		cSrvFilial := HttpSession->Filial
	endIf

	if (cEmpAnt == cSrvEmpresa) .and. (cFilAnt == cSrvFilial) .and. Select("SX2") > 0 // valida se a empresa logada é a mesma passada
		lConectar := .F.
	endIf
	
	if lConectar
		RpcClearEnv()
	
		//Tabelas a serem abertas  
		aSrvTabelas:={"SC1","SCR","SC7","SCE","SA1","SA2","SA6","SAK","SAL","SC8","SE1","SEA","SY1","CTT","CT1","SE4","SZX","SZZ","SZW","ZC1","AFR","ZZZ","CTN","CTS","CT3","ZV0","ZV1","ZV2","ZV3","ZM2","ZM0"}

		RPCSetType(3) //Nao come licença
	    
		if !RPCSETENV(cSrvEmpresa, cSrvFilial, , , cWebModulo, , aSrvTabelas)
			conout("Falha ao conectar na empresa/filial "+cSrvEmpresa+"/"+cSrvFilial+" - "+DtoC(dDatabase)+" "+time())
			return (cHtml)
		else
			HttpSession->Empresa:= cSrvEmpresa
			HttpSession->Filial:= cSrvFilial
			cEmpAnt:= HttpSession->Empresa
			cFilAnt:= HttpSession->Filial
			conout("Logado na empresa/filial "+cSrvEmpresa+"/"+cSrvFilial+" - "+DtoC(dDatabase)+" "+time())
		endif
	endIf

	// Verificar se o vendedor da sessao esta correto
    if lCheckSess
        // if empty(HttpSession->SESSIONID)
        //    return cHtml
        // endif
        // if empty(HttpSession->CodVend)
        //    return cHtml
        // endif
        // oObjSess:setFileName(getArqSess())
        // aInfo := oObjSess:readLog()
        // lOk   := .f.
        // for nI := 1 to len(aInfo)
        //     aDadSess := StrTokArr(aInfo[nI], ";")
        //     if len(aDadSess) > 2
        //         if aDadSess[2] == HttpSession->SESSIONID .and. aDadSess[3] == HttpSession->CodVend
        //             lOk := .t.
        //             exit
        //         endif
        //     endif
        // next
        // if !lOk
        //    return cHtml
        // Endif
        if !checkSess()
            oObjLog:saveMsg('Deu Erro Vai Limpar -> HttpSession->CodVend')
            HttpSession->CodVend := nil
//            return cHtml
        endif
    endif

return

/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Portal SMS                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! Portal SMS - Insite                                     !
+------------------+---------------------------------------------------------+
!Nome              ! getArqSess                                              !
+------------------+---------------------------------------------------------+
!Descricao         ! Retorna o nome do arquivo de controle de session do dia !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 08/02/2021                                              !
+----------------------------------------------------------------------------+
*/
static function getArqSess()
return "\temp\session_"+dtos(date())+".txt"

/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Portal SMS                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! Portal SMS - Insite                                     !
+------------------+---------------------------------------------------------+
!Nome              ! svUsSes                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Salva o vendedor logado no arquivo de controle de       !
!                  !  session do dia                                         !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 08/02/2021                                              !
+----------------------------------------------------------------------------+
*/
user function svUsSes(cCodVend)
    local oObjSess  := LogSMS():new()
    local cSession  := cValToChar(HttpSession->SESSIONID)
    local aSessions := {}
    local dData     := ctod("")
    oObjSess:setFileName(getArqSess())
    oObjSess:saveMsg(";"+cSession+";"+cCodVend)

    // Tratamento por variáveis globais
    GetGlbVars(SESSHTTP, dData, aSessions)
    if empty(dData)
        aSessions := {}
        dData     := date()
    elseif dData <> date()
        ClearGlbValue(SESSHTTP)
        aSessions := {}
        dData     := date()
    Endif
    if valtype(aSessions) <> "A"
        aSessions := {}
    endif
    aadd(aSessions, {cSession, cCodVend})
    PutGlbVars(SESSHTTP, dData, aSessions)
return


/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Portal SMS                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! Portal SMS - Insite                                     !
+------------------+---------------------------------------------------------+
!Nome              ! checkSess                                               !
+------------------+---------------------------------------------------------+
!Descricao         ! Verificar se o vendedor logado no arquivo de controle de!
!                  !  session do dia                                         !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 08/02/2021                                              !
+----------------------------------------------------------------------------+
*/
static function checkSess()
    local lOk := .t.
    local aSessions := {}
    local dData     := ctod("")
    local aParm
    local cParm1 := cParm2 := ""
    if empty(HttpSession->SESSIONID)
        lOk := .f.
    endif
    if empty(HttpSession->CodVend)
        lOk := .f.
    endif
    if lOk
        // oObjSess:setFileName(getArqSess())
        // aInfo := oObjSess:readLog()
        // lOk   := .f.
        // for nI := 1 to len(aInfo)
        //     aDadSess := StrTokArr(aInfo[nI], ";")
        //     if len(aDadSess) > 2
        //         if aDadSess[2] == HttpSession->SESSIONID .and. aDadSess[3] == HttpSession->CodVend
        //             lOk := .t.
        //             exit
        //         endif
        //     endif
        // next

        // Tratamento por variáveis globais
        // GetGlbVars(SESSHTTP, dData, aSessions)
        // if empty(dData) .or. dData <> date() .or. valtype(aSessions) <> "A"
        //     lOk := .f.
        // Endif
        // if lOk
        //     lOk := !empty(ascan(aSessions, {|x| x[1] == HttpSession->SESSIONID .and. x[2] == HttpSession->CodVend}))
        // Endif
        lOk := .f.
        if !empty(HttpGet->PR)
            aParm := STRTOKARR(DECODE64(httpget->PR), "/")
            if len(aParm) >= 2
                cParm1 := aParm[1]
                cParm2 := aParm[2]
                if !empty(cParm2) .and. len(cParm1) = 16 .and. substr(cParm1, 11) = ":" .and. substr(cParm1, 14) = ":"
                    if left(cParm1,8) = dtos(date()) .and. elaptime(right(cParm1,8), time()) <= "00:60:00"
                        lOk := .t.
                    endif
                endif
            endif
        endif
    endif
return lOk

/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Portal SMS                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! Portal SMS - Insite                                     !
+------------------+---------------------------------------------------------+
!Nome              ! GetUsrPR                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Retorna o usuario do portal a partir do parametro get   !
!                  !  PR                                                     !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 08/02/2021                                              !
+----------------------------------------------------------------------------+
*/
user function GetUsrPR()
	local aParm
	local cRet := ""
    If Type("httpget->PR") <> "U"
        aParm :=  STRTOKARR(DECODE64(httpget->PR), "/")
        if len(aParm) >= 2
            cRet := aParm[2]
        endif
    endif
return cRet 

/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Portal SMS                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! Portal SMS - Insite                                     !
+------------------+---------------------------------------------------------+
!Nome              ! setParPR                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Setar o parametro de "session" do usuario vendedor      !
!                  !                                                         !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 08/02/2021                                              !
+----------------------------------------------------------------------------+
*/
user function SetParPR(cVend)
return ESCAPE(ENCODE64(DTOS(DATE())+TIME()+"/"+cVend))
