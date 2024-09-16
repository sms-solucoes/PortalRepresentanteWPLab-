#include "RWMAKE.CH"
#include "TOPCONN.CH"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ M410AGRV    ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦21.05.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦            	
¦¦¦Descriçäo ¦ Chamado após a gravação do pedido de vendas  			  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function M410AGRV()
Local nOpc:= Paramixb[1]
Local nPercVend := GetNewPar("RB_SLDVEND",50) 
Local nPercDir  := (100 - nPercVend)/100
Local nSaldo    := 0
Local cDiretor  := GetNewPar("RB_VNDINT","000013")

nPercVend  := nPercVend/100

If nOpc = 1 //Inclusão do pedido

    //Grava o saldo do pedido
    If !Empty(M->C5_XSALDO)
        nSaldo:= Iif(M->C5_XSALDO > 0,M->C5_XSALDO * nPercVend,M->C5_XSALDO)
        If ZYF->(dbSeek(xFilial("ZYF")+M->C5_VEND1+cValtoChar(Year(M->C5_EMISSAO))+"/"+StrZero(Month(M->C5_EMISSAO),2) )) 
            Reclock("ZYF",.F.)
            ZYF->ZYF_SALDO+= nSaldo
            ZYF->(msUnlock())
        Else
            Reclock("ZYF",.T.)
            ZYF->ZYF_FILIAL:= xFilial("ZYF")
            ZYF->ZYF_VEND:= M->C5_VEND1
            ZYF->ZYF_NOME:= Posicione("SA3",1,xFilial("SA3")+M->C5_VEND1,"A3_NOME")
            ZYF->ZYF_DATA:= cValtoChar(Year(M->C5_EMISSAO))+"/"+StrZero(Month(M->C5_EMISSAO),2)
            ZYF->ZYF_SALDO:= nSaldo
            ZYF->(msUnlock())
        Endif

        //Gravação do saldo do diretor
        If nPercDir > 0 .and. M->C5_XSALDO > 0
            If ZYF->(dbSeek(xFilial("ZYF")+cDiretor+cValtoChar(Year(M->C5_EMISSAO))+"/"+StrZero(Month(M->C5_EMISSAO),2) )) 
                Reclock("ZYF",.F.)
                ZYF->ZYF_SALDO+= (M->C5_XSALDO * nPercDir)
                ZYF->(msUnlock())
            Else
                Reclock("ZYF",.T.)
                ZYF->ZYF_FILIAL:= xFilial("ZYF")
                ZYF->ZYF_VEND:= cDiretor
                ZYF->ZYF_NOME:= Posicione("SA3",1,xFilial("SA3")+cDiretor,"A3_NOME")
                ZYF->ZYF_DATA:= cValtoChar(Year(M->C5_EMISSAO))+"/"+StrZero(Month(M->C5_EMISSAO),2)
                ZYF->ZYF_SALDO:= (M->C5_XSALDO * nPercDir)
                ZYF->(msUnlock())
            Endif
        Endif

    Endif 
Elseif nOpc = 2 //Alteração
    If Type("nSaldoDev") == "N" 
        If ZYF->(dbSeek(xFilial("ZYF")+M->C5_VEND1+cValtoChar(Year(M->C5_EMISSAO))+"/"+StrZero(Month(M->C5_EMISSAO),2) )) 
            Reclock("ZYF",.F.)
            ZYF->ZYF_SALDO+= (nSaldoDev * nPercVend)
            ZYF->(msUnlock())    
        Endif 

        //Gravação do saldo do diretor
        If nPercDir > 0
            If ZYF->(dbSeek(xFilial("ZYF")+cDiretor+cValtoChar(Year(M->C5_EMISSAO))+"/"+StrZero(Month(M->C5_EMISSAO),2) )) 
                Reclock("ZYF",.F.)
                ZYF->ZYF_SALDO+= (nSaldoDev * nPercDir)
                ZYF->(msUnlock())    
            Endif
        Endif   
    Endif    
Elseif nOpc = 3 //Exclusão
    //Grava o saldo do pedido
    If !Empty(M->C5_XSALDO)
        nSaldo:= Iif(M->C5_XSALDO > 0,M->C5_XSALDO * nPercVend,M->C5_XSALDO)
        If ZYF->(dbSeek(xFilial("ZYF")+M->C5_VEND1+cValtoChar(Year(M->C5_EMISSAO))+"/"+StrZero(Month(M->C5_EMISSAO),2) )) 
            Reclock("ZYF",.F.)
            ZYF->ZYF_SALDO-= nSaldo
            ZYF->(msUnlock())
        Endif

        //Gravação do saldo do diretor
        If nPercDir > 0 .and. M->C5_XSALDO > 0
            If ZYF->(dbSeek(xFilial("ZYF")+cDiretor+cValtoChar(Year(M->C5_EMISSAO))+"/"+StrZero(Month(M->C5_EMISSAO),2) )) 
                Reclock("ZYF",.F.)
                ZYF->ZYF_SALDO-= (M->C5_XSALDO * nPercDir)
                ZYF->(msUnlock())    
            Endif
        Endif

        //Reabre o orçamento
        Reclock("SCJ",.F.)
            SCJ->CJ_STATUS:= 'A'
        SCJ->(msUnlock())
    Endif        
Endif 

Return
