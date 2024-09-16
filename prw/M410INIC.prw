/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ M410INIC    ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦21.05.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦            	
¦¦¦Descriçäo ¦ Chamado antes da abertura da tela de inclusão  			  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function M410INIC()
Local nSaldo    := 0
Local nSldPed   := 0
Local nPercVend := GetNewPar("RB_SLDVEND",50) 
Local nPercDir  := (100 - nPercVend) /100
Local cDiretor  := GetNewPar("RB_VNDINT","000013")

If isInCallStack("MATA416")
    nPercVend:= nPercVend/100

    //Verifica o saldo de desconto
    If SCJ->CJ_XSALDO <> 0
        If ZYF->(dbSeek(xFilial("ZYF")+SCJ->CJ_VEND+cValtoChar(Year(dDataBase))+"/"+StrZero(Month(dDataBase),2)))
            nSaldo:= ZYF->ZYF_SALDO
        Endif
        If SCJ->CJ_XSALDO > 0
            nSldPed:= nSaldo + (SCJ->CJ_XSALDO * Iif(SCJ->CJ_VEND = cDiretor, nPercDir, nPercVend)) //Saldo do vendedor passa a ser 50%. O restante vai para o diretor Lucilene SMSTI 29/08/22
        Else
            nSldPed:= nSaldo + SCJ->CJ_XSALDO 
        Endif
        If nSldPed < 0
            If 2 = Aviso("Atenção - Saldo Negativo","Com esse pedido o saldo do vendedor ficará negativo: R$"+Alltrim(Transform(nSldPed,PesqPict("SE1","E1_VALOR")))+". Deseja gerar o pedido?",{"Sim","Não"})
                Return
            Endif    
        Endif   
    Endif

Endif

Return
