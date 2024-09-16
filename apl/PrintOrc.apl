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

User Function PrintOrc()
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
	cSite	:= Procname()+".apw"
    
	// Monta o cabeçalho para a pagina
	cHeader := GetHeader(cTitle, cSite) 
	
    //Atualiza as variáveis
    cEndServ := GetMv('MV_WFBRWSR')
    cCodVend := HttpSession->CodVend
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
    
    //Posiciona no Orçamento
    dbSelectArea("SCJ")
    SCJ->(dbGoTo(nDoc))           
    cNumOrc:= SCJ->CJ_NUM
    cEmissao:= dtoc(SCJ->CJ_EMISSAO)
    
    dbSelectArea("SCK")
    SCK->(dbSeek(xFilial("SCK")+SCJ->CJ_NUM))
    
    //Monta o CSS do email
    cCss:= MntCSSOrc(lMail)
    
    /*             
    aItens - array que define o cabeçalho da tabela de produtos
    [1] - Nome da coluna
    [2] - Nome do campo
    [3] - Tamanho
    [4] - Alinhamento
    [5] - Tipo
    [6] - Editável
    [7] - Obrigatório
    [8] - Moeda
    [9] - Placeholder
    */          
    aItens := { {"Produto","CK_PRODUTO","50%","left","C",lEdit,.T.,.F.,"Selecione..."},;
                {"Quantidade","CK_QTDVEN","*","right","N",lEdit,.T.,.F.,"0"},;
                {"Vlr de Venda","iCK_PRCVEN","*","","N",lEdit,.F.,.T.,"0,00000"},;
                {"Total","CK_VALOR","150px","right","N",lEdit,.F.,.T.,"0,00"}}              
    
        
    // Cria o cabeçalho dos Itens
    For nLin := 1 to Len(aItens)
        cOrcCabec += '<th'+Iif(aItens[nLin,2] == "CK_VALOR",' width="'+aItens[nLin,3]+'"',Iif(aItens[nLin,2] == "CK_PRODUTO",' width="'+aItens[nLin,3]+'"',''))+'>'+aItens[nLin][1]+'</th>'
    Next 
    
    //Tipo do Orçamento                 
    aTipoOrc:= {{"1","Previsto"},{"2","Firme"},{"3","Em elaboração"}}
    cTipoOrc:='<select class="form-control mb-md" name="CJ_XTPORC" id="CJ_XTPORC" required="" aria-required="true" value="'+SCJ->CJ_XTPORC+'" '
    cTipoOrc+= Iif(!lEdit,'disabled','')+'>'
    
    For a:= 1 to Len(aTipoOrc)
        cTipoOrc+=' <option value="'+aTipoOrc[a,1]+'">'+aTipoOrc[a,2]+'</option>'
    Next
    cTipoOrc+='</select>'
    
    //Tipo de frete
    aTpFrete:= {{"S","Sem Frete"},{"C","CIF"},{"F","FOB"}}
    cTpFrete:='<select class="form-control mb-md" name="CJ_TPFRETE" id="CJ_TPFRETE" onchange="javascript:VldFrete()" value="'+SCJ->CJ_TPFRETE+'"'
    cTpFrete+= Iif(!lEdit,'disabled','')+'>'
    nPosFrete:= aScan(aTpFrete,{|x|x[1]==SCJ->CJ_TPFRETE})
    If nPosFrete = 0
        nPosFrete:= 1
    Endif   
    cTpFrete+=' <option value="'+SCJ->CJ_TPFRETE+'">'+aTpFrete[nPosFrete,2]+'</option>' 
    cTpFrete+='</select>' 
    
    cValFre:= Transform(SCJ->CJ_FRETE,"@E 999,999,999.99")
    
    
    //Transportadora
    cTransp:= SCJ->CJ_XTRANSP+' - '+Alltrim(Posicione("SA4",1,xFilial("SA4")+SCJ->CJ_XTRANSP,"A4_NOME"))
    
    //Faixas de Desconto
    aAdd(aFaixaDesc, {"0","   ","0"}) // Sem desconto.
    
    
    //Seleciona as modalidades
	cModali:= '<select class="form-control mb-md" name="CJ_XMODALI" id="CJ_XMODALI" required="" aria-required="true" '
	cModali+= 'onchange="javascript:condPag()" '+Iif(!lEdit,'disabled','')+'>' 
	cModali+='	<option value="'+AllTrim(SCJ->CJ_XMODALI)+'">'+Alltrim(Posicione("SX5",1,xFilial("SX5")+'ZE'+SCJ->CJ_XMODALI,"X5_DESCRI"))+'</option>'
	cModali+='</select>'
    
    
    //Seleciona as condições de pagamento disponíveis no combo 
    cCondPag:='<select class="form-control mb-md" name="CJ_CONDPAG" id="CJ_CONDPAG" required="" aria-required="true"'
    cCondPag+=Iif(!lEdit,'disabled','')+'>'
    cCondPag+=' <option value="'+SCJ->CJ_CONDPAG+'">'+Posicione("SE4",1,xFilial("SE4")+SCJ->CJ_CONDPAG,"E4_DESCRI")+'</option>'     
    cCondPag+='</select>'                                
      
    
    //Operadora
    cOperadora:= '<select data-plugin-selectTwo class="form-control populate placeholder mb-md" data-plugin-options='+"'" '
	cOperadora+= '{ "placeholder": "Selecione...", "allowClear": false }'+"'"+' name="OPERADORA" id="OPERADORA" '
	cOperadora+= 'required="" aria-required="true" onchange="javascript:bandeira()" disabled> ' 
    cOperadora+= '	<option value="'+Alltrim(SCJ->CJ_CLIOPER)+'">'+Alltrim(Posicione("SA1",1,xFilial("SA1")+SCJ->CJ_CLIOPER,"A1_NREDUZ"))+'</option>'
	cOperadora+= '</select>'
	 
	//Select da bandeira
	cBandeira:= '<select data-plugin-selectTwo class="form-control populate placeholder mb-md" data-plugin-options='+"'" '
	cBandeira+= '{ "placeholder": "Selecione...", "allowClear": false }'+"'"+' name="BANDEIRA" id="BANDEIRA" '
	cBandeira+= 'required="" aria-required="true" disabled> ' 	
	
	//Seleciona as operadoras   SAE-- BANDEIRA / ZYD -- METODO / SX5 -- MODALIDADE
	cQry:= " Select ZYD_METODO, AE_DESC"
	cQry+= " From "+RetSqlName("ZYD")+" ZYD, "+RetSqlName("SAE")+" SAE, "+RetSqlName("SX5")+" SX5 "
	cQry+= " Where AE_CODCLI = '"+SCJ->CJ_CLIOPER+"' "  
	cQry+= " And AE_COD = ZYD_ADMFIN "     
	cQry+= " And X5_TABELA = 'ZE' AND X5_CHAVE = '"+SCJ->CJ_XMODALI+"' "     
	cQry+= " And AE_TIPO = X5_DESCENG "     
	cQry+= " And AE_FILIAL = '"+xFilial("SA3")+"' "  
	cQry+= " And ZYD_FILIAL = '"+xFilial("ZYD")+"' " 
	cQry+= " And X5_FILIAL = '"+xFilial("SX5")+"' " 
	cQry+= " And SAE.D_E_L_E_T_ = '' "   
	cQry+= " And ZYD.D_E_L_E_T_ = '' "      
	cQry+= " And SX5.D_E_L_E_T_ = '' "      
	
	If Select("QRB") > 0
		QRB->(dbCloseArea())
	Endif
	APWExOpenQuery(ChangeQuery(cQry),'QRB',.T.)	
	 
	//Preenche o select da tabela
	While QRB->(!Eof())
		cBandeira+='	<option value="'+Alltrim(QRB->ZYD_METODO)+'" '+Iif(Alltrim(QRB->ZYD_METODO)==Alltrim(SCJ->CJ_XCODPAG),' selected','')+'>'+Alltrim(QRB->AE_DESC)+'</option>'
	    QRB->(dbSkip())
    End
	cBandeira+= '</select>'   
	
	    	
    //Cliente
    cCliente:='<select class="form-control populate placeholder" name="CJ_CLIENTE" id="CJ_CLIENTE" '
    cCliente+=' disabled >' 
    cCliente+=' <option value='+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA+'>'+SCJ->CJ_CLIENTE+'/'+SCJ->CJ_LOJA+' - '+Alltrim(Posicione("SA1",1,xFilial("SA1")+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA,"A1_NOME"))+'</option>'
    cCliente+='</select>'
    
    //Combo da tabela de preço
    cTabela:='<select class="form-control populate placeholder" name="CJ_TABELA" id="CJ_TABELA" '
    cTabela+='onchange="javascript:selProd()" disabled >'
    cTabela+='  <option value='+SCJ->CJ_TABELA+'>'+Alltrim(Posicione("DA0",1,xFilial("DA0")+SCJ->CJ_TABELA,"DA0_DESCRI"))+'</option>'
    cTabela+='</select>'
    
    //Data Prevista de Entrega
    nDiasEnt:= GetNewPar("AA_DTENT",'0')
    cEntrega:='<input type="text" id="CK_ENTREG" name="CK_ENTREG" data-plugin-datepicker data-plugin-options='+"'"+'{ "startDate": "+'+nDiasEnt+'d", "language": "pt-BR",'
    cEntrega+='"daysOfWeekDisabled": "[0]","daysOfWeekHighlighted":"[0]"}'+"'"+' class="form-control only-numbers" placeholder="__/__/____"'
    cEntrega+='value='+DTOC(SCK->CK_ENTREG) 
    cEntrega+=Iif(!lEdit,' disabled','')+'>'


	//Observações
    cObsIntern:= Alltrim(SCJ->CJ_XNOTAIN)
    cObsNota:= Alltrim(SCJ->CJ_XMSGNF)
    
    //Preenchimento dos itens   
    nTTotal+= SCJ->CJ_FRETE
    nTFrete:= nTTotal
    dbSelectArea("SCK")
    SCK->(dbSeek(xFilial("SCK")+SCJ->CJ_NUM))
    While SCK->(!Eof()) .and. SCK->CK_NUM = SCJ->CJ_NUM
        nItens++
        Posicione("SB1",1,xFilial("SB1")+SCK->CK_PRODUTO,"B1_DESC")     
        cOrcItens += '<tr class="odd" id="linha'+StrZero(nItens,2)+'">'
          
        nTImpostos += SCK->(CK_XICMST+CK_XVALIPI)
        nTQtdItem += SCK->CK_QTDVEN
        nTVlrUnit +=  Round(SCK->CK_QTDVEN * SCK->CK_PRCVEN,2)
        nTTotal +=  SCK->(CK_VALOR+CK_XVALIPI+CK_XICMST) 
               
        For nLin := 1 to Len(aItens)
         
                cOrcItens += '<td'+Iif(!Empty(aItens[nLin][4]),' align="'+aItens[nLin][4]+'"',"")+'>'
                
                lMoeda:= aItens[nLin,8] //Indica se é Moeda             
                lNumber:= aItens[nLin,5] = "N" //Indica que é numérico              
                xValue:= ""
                Do Case
                    Case aItens[nLin][5] == 'C'
                        If aItens[nLin,2] == "CK_PRODUTO"
                            xValue := AllTrim(SCK->&(aItens[nLin][2]))+'/'+Alltrim(SB1->B1_DESC)
                        Else
                            xValue := AllTrim(SCK->&(aItens[nLin][2]))
                        Endif
                    Case aItens[nLin][5] == 'N'
                        If aItens[nLin,2] == "CK_QTDVEN"
                            xValue := Alltrim(TransForm(SCK->&(aItens[nLin][2]),"@E 999,999.999"))
                        Else    
                            If aItens[nLin,2] == "iCK_PRCVEN"   
                                xValue := Alltrim(PadR(TransForm(SCK->CK_PRCVEN,"@E 999,999,999.99"),14))
                            Elseif aItens[nLin,2] == "CK_PRCVEN"    
                                xValue := Alltrim(PadR(TransForm(SCK->CK_PRUNIT,"@E 999,999,999.99"),14))
                            Elseif aItens[nLin,2] == "CK_VALOR"    
                                xValue := Alltrim(PadR(TransForm(SCK->CK_VALOR,"@E 999,999,999.99"),14))
                                //xValue := Alltrim(PadR(TransForm(SCK->CK_VALOR+SCK->CK_XVALIPI+SCK->CK_XICMST,"@E 999,999,999.99"),14))
                            Else
                                xValue := Alltrim(PadR(TransForm(SCK->&(aItens[nLin][2]),"@E 999,999,999.99"),14))
                            Endif   
                        Endif   
                EndCase  
               
                If aItens[nLin,6] //Campo Editável
                    If aItens[nLin,2] == "CK_PRODUTO"
                       //Cria o select para o produto
                        cOrcItens +='<select data-plugin-selectTwo class="form-control populate placeholder" data-plugin-options='+"'"
                        cOrcItens +='{ "placeholder": "Selecione...", "allowClear": false }'+"'"+' data-prop="CK_PRODUTO" name="CK_PRODUTO'+cItem+'" id="CK_PRODUTO'+cItem+'" '
                        cOrcItens += Iif(aItens[nLin][7],'required="" aria-required="true" ','')                                           
                        cOrcItens +='onchange="javascript:gatProduto($(this))">'
                        cOrcItens +='   <option value="">'+"Selecione..."+'</option>'
        
                        cOrcItens+='</select>'
                    Else
                        cOrcItens += '<input id="'+aItens[nLin][2]+cItem+'" data-prop="'+aItens[nLin][2]+'" name="'+aItens[nLin][2]+cItem+'" class="form-control'
                        cOrcItens +=If(lMoeda," money",If(lNumber," only-numbers",""))+'" type="text" '
                        cOrcItens += 'placeholder="'+aItens[nLin,9]+'" '
                        //Atribui as funções javascript 
                        If aItens[nLin,2] == "CK_QTDVEN"
                            cOrcItens+='onblur="javascript:VldQtd('+"'"+cItem+"'"+') "'
                        Endif
                        If aItens[nLin,2] == "iCK_PRCVEN"
                            cOrcItens+='onblur="javascript:VldValor('+"'"+cItem+"'"+') "'
                        Endif
                        If aItens[nLin,2] == "CK_DESCONT"
					 		cOrcItens+='onblur="javascript:VldValor('+"'"+cItem+"'"+') "'
	//				 		cOrcItens+='onkeyup="maskPerc()" onblur="javascript:VldValor('+"'"+cItem+"'"+') "'
				 		Endif 
                        If aItens[nLin,2] $ ("CK_QTDVEN|iCK_PRCVEN|CK_DESCONT")
                            cOrcItens+='onkeyup="javascript:TotalItem('+"'"+cItem+"'"+') "'
                        Endif   
                        //Campo obrigatório
                        cOrcItens += Iif(aItens[nLin][7],'required="" aria-required="true" ','')
                        //Inicia todos os campos desabilitados
                        cOrcItens += 'disabled '
                        cOrcItens += 'value="'+Alltrim(xValue)+'">'
                    Endif
                    
                
                Else
                    cOrcItens += '<input id="'+aItens[nLin][2]+cItem+'" data-prop="'+aItens[nLin][2]+'" name="'+aItens[nLin][2]+cItem+'" class="form-control input-block" type="text" disabled width="" '
                    cOrcItens += 'value="'+Alltrim(xValue)+'">'
                Endif
                       
                    
            cOrcItens += '</td>' 
        Next                                                                            
            
        cOrcItens += '</tr>'
        SCK->(dbSkip()) 
    End                                                                                                                                     
    
    //Retorna o HTML para construção da página 
    cHtml := H_MailOrc()
    
    If lMail
	    If !Empty(Alltrim(HttpPost->email)) .and. At("@",Alltrim(HttpPost->email)) > 0
	        /*
	        If !ExistDir(cDirOrc)
	            MakeDir (cDirOrc)
	        Endif
	        */
	        cFileLoc:= cDirOrc
	        
			If Empty(SCJ->CJ_NUM)
				cHtml := 'Houve falha no envio do e-mail. Tente novamente.'+CRLF
			Endif	
	        _cArq := cFileLoc+"orcamento_"+SCJ->CJ_FILIAL+SCJ->CJ_NUM+"_"+dtos(date())+StrTran(time(),":","")+'.html' // Arquivo a ser gerado para envio do html no e-mail
	
	        // criar arquivo texto vazio a partir do root path no servidor
	        nHandle := FCREATE(_cArq)
	        IF nHandle = -1
	            conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
	        ELSE
	            // escreve a hora atual do servidor em string no arquivo
	            FWrite(nHandle, cHtml)
	            FClose(nHandle)
	        ENDIF
	
	        If EnvOrcMail('\'+_cArq,HttpPost->email)
	            cHtml := 'E-mail enviado com sucesso.'+CRLF
	        Else
	            cHtml := 'Houve falha no envio do e-mail. Tente novamente.'+CRLF
	        EndIf
	    Else
	        cHtml := 'E-mail invalido!'+CRLF
	    EndIf
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
    _cMsgem := 'Segue anexo orçamento nº'+SCJ->CJ_FILIAL+"/"+SCJ->CJ_NUM+'. '

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
