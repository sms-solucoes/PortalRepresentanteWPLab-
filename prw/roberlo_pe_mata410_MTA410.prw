#include "protheus.ch"
User Function MTA410
Local lRet := .T.

If lRet
	lRet := ValidaVend()
EndIf

If lRet
	lRet := TabPreco()
EndIf

If lRet
	lRet := CTrExp()
EndIf

If lRet
	lRet := ChecaNCE()
EndIf

If lRet
	lRet:= fVldSaldo()
Endif	

// este trecho deve NECESSARIAMENTE ficar logo antes do return!
// coloque quaisquer outras validacoes antes deste trecho
If lRet
//	If (lRet := StaticCall(ROBERLO_PE_MATA410_MT410ROD, DescProg, 2))
		lRet := DescAcres()
//	EndIf
EndIf
Return lRet

Static Function ValidaVend
Local lRet := .T.
Local nI, nJ, nK

For nI := 1 To 4
	If !Empty(&("M->C5_VEND" + Str(nI, 1)))
		nK := nI + 1
		For nJ := nK To 5
			If &("M->C5_VEND" + Str(nI, 1)) == &("M->C5_VEND" + Str(nJ, 1))
				APMsgStop("Há vendedores repetidos no pedido (Vend" + Str(nI, 1) + " = Vend" + Str(nJ, 1) + ")! Verifique.", "VENDEDOR REPETIDO")
				lRet := .F.
				nI += 5
				nJ += 5
			EndIf
		Next
	EndIf
Next
Return lRet

Static Function DescAcres
Local nValMin := If(SE4->(FieldPos("E4_VALMIN"))  > 0, Posicione("SE4", 1, xFilial("SE4") + M->C5_CONDPAG, "E4_VALMIN") , 0)
Local nDesc   := If(SE4->(FieldPos("E4_DESCPED")) > 0, Posicione("SE4", 1, xFilial("SE4") + M->C5_CONDPAG, "E4_DESCPED"), 0)
Local nTotal  := 0
Local lRet    := .T.
Local cLogins := GetNewPar("MV_USMINCP", "000000")
Local cModCC  := GetNewPar("MV_MODCART", "005,006")

If lRet .and. nValMin > 0 .and. !(__cUserId $ cLogins .or. (SC5->(FieldPos("C5_MODAL")) > 0 .and. M->C5_MODAL $ cModCC)) 
	aEval(aCols, {|aLin, nLin| If(GDDeleted(nLin), Nil, (nTotal += GDFieldGet("C6_VALPON", nLin)))})
	nTotal += Ma410Impos(0, .T.) //StaticCall(MATA410, Ma410Impos, 0, .T.)
	If nTotal < nValMin
		APMsgStop("O valor mínimo de pedido para esta condição de pagamento é R$ " + AllTrim(Transform(nValMin, "@E 999,999,999,999.99")) + ".", "PEDIDO ABAIXO DO VALOR MÍNIMO")
		lRet := .F.
	EndIf
EndIf

If lRet .and. nDesc # 0 .and. (lRet := APMsgYesNo("Será aplicado " + If(nDesc < 0, "acréscimo", "desconto") + " de " + AllTrim(Transform(Abs(nDesc), "@E 99.99")) + "%. O pedido não deve ser alterado após a aplicação. Continua?", "ALTERAÇÃO DE VALORES"))
	Desconto(nDesc)
	M->C5_MODVALT := "1"	 
EndIf
Return lRet

Static Function Desconto(nDesc)
Local aAux      := Array(5)
//Local aCom      := {} 
Local nI, nJ    := 0
Local nVal      := 0
Private n       := 1
Private lMTA410 := .T.

For nJ := 1 To Len(aCols)
	n := nJ
	If !GDDeleted()
		For nI := 1 To 5
			aAux[nI] := GDFieldGet("C6_COMIS" + Str(nI, 1)) * GDFieldGet("C6_VALOR") / 100
		Next
		GDFieldPut("C6_DESCIT", nDesc)
		nVal := NoRound(GDFieldGet("C6_PRECLI") * (1 - (nDesc / 100)), aHeader[GDFieldPos("C6_PRECLI")][5])
		GDFieldPut("C6_PRECLI", nVal)
		nVal := NoRound(GDFieldGet("C6_PRCVEN") * (1 - (nDesc / 100)), aHeader[GDFieldPos("C6_PRCVEN")][5])
		GDFieldPut("C6_PRCVEN", nVal)
		GDFieldPut("C6_PRUNIT", nVal)
		A410MultT ("C6_PRCVEN", nVal)
		nVal := NoRound(GDFieldGet("C6_PRECLI") * GDFieldGet("C6_QTDVEN") - GDFieldGet("C6_VALOR"), aHeader[GDFieldPos("C6_VALPON")][5])
		GDFieldPut("C6_VALPON", nVal)
		For nI := 1 To 5
			nVal := NoRound(aAux[nI] * 100 / GDFieldGet("C6_VALOR"), aHeader[GDFieldPos("C6_COMIS" + Str(nI, 1))][5])
			GDFieldPut("C6_COMIS" + Str(nI, 1), nVal)
		Next	
	EndIf
Next
Return

Static Function TabPreco
Local lRet    := .T.
//Local cFils   := GetMV("MV_FTABOBR")
Local cNaoObr := GetMV("MV_FTABNOB")
Local cLogins := GetMV("MV_UTABNOB")

If cEmpAnt == "01" .and. !(__cUserId $ cLogins) .and. Empty(M->C5_TABELA) .and. !(cFilAnt $ cNaoObr) //cFilAnt $ cFils
	APMsgStop("O uso de tabela de preço é obrigatório para esta filial!", "TABELA OBRIGATÓRIA")
	lRet := .F.
EndIf
Return lRet

Static Function CTrExp
Local cCF  := If(M->C5_TIPO $ "B,D", "2", "1")
Local lRet := .T. 

If SC5->(FieldPos("C5_TPCHC")) > 0 .and. Posicione("SA" + cCF, 1, xFilial("SA" + cCF) + M->C5_CLIENTE + M->C5_LOJACLI, "A" + cCF + "_EST") == "EX" .and. Empty(M->C5_TPCHC)
	lRet := .F.
	APMsgAlert("É obrigatório informar o tipo do conhecimento de transporte (C5_TPCHC) para notas de exportação.", "FALTA TIPO CONHECIMENTO")
EndIf
Return lRet

Static Function ChecaNCE
Local lRet := .T.
Local cTmp := ""
Local aNCE := {}
Local nTot := 0
Local nI   := 0

If cEmpAnt == "02" .and. AliasInDic("SZ0") // somente roberlo
	If M->C5_TIPOCLI == "X" // exportacao
		cTmp := GetNextAlias()
		BeginSQL Alias cTmp
		SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_SALDO, E1_SALDO, E1_MOEDA
		FROM %table:SE1% SE1
		WHERE SE1.%notdel%
		AND E1_FILIAL = %xfilial:SE1%
		AND E1_CLIENTE = %exp:M->C5_CLIENTE%
		AND E1_LOJA = %exp:M->C5_LOJACLI%
		AND E1_MOEDA = %exp:M->C5_MOEDA%
		AND E1_SALDO > 0
		AND E1_TIPO = 'NCC'
		AND E1_PREFIXO = 'NCE'
		ORDER BY E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
		EndSQL
		U_QrySX3()
		dbEval({|| aAdd(aNCE, {(cTmp)->E1_PREFIXO, (cTmp)->E1_NUM, (cTmp)->E1_PARCELA, (cTmp)->E1_TIPO, (cTmp)->E1_SALDO})})
		dbCloseArea()
		
		If !Empty(aNCE)
			aEval(aNCE, {|aTit| nTot += xMoeda(aTit[5], M->C5_MOEDA, 1, M->C5_EMISSAO, Nil, Nil, M->C5_TXMOEDA)})
			If APMsgYesNo("Há NCE(s) para este cliente no valor de R$ " + AllTrim(Transform(nTot, "@E 999,999,999.99")) + " . Usar este valor como desconto?", "NCE")
				dbSelectArea("SZ0")
				dbSetOrder(1)
				For nI := 1 To Len(aNCE)
					If !dbSeek(xFilial() + M->C5_NUM + aNCE[nI][1] + aNCE[nI][2] + aNCE[nI][3] + aNCE[nI][4])
						RecLock("SZ0", .T.)
						Z0_FILIAL  := xFilial()
						Z0_PEDIDO  := M->C5_NUM
						Z0_PREFIXO := aNCE[nI][1]
						Z0_NUM     := aNCE[nI][2]
						Z0_PARCELA := aNCE[nI][3]
						Z0_TIPO    := aNCE[nI][4]
						MSUnlock()
					EndIf
				Next
				M->C5_DESCONT := nTot
			EndIf
		EndIf
	EndIf
EndIf
Return lRet


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ fVldSaldo   ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦21.05.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦            	
¦¦¦Descriçäo ¦ Valida o saldo de desconto do vendedor		 			  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fVldSaldo()
Local nSaldo    := 0
Local nSldPed    := 0
Local nPercVend := GetNewPar("RB_SLDVEND",50) /100
Local nPercDir  := (100 - nPercVend) /100
Local cDiretor  := GetNewPar("RB_VNDINT","000013")

If isInCallStack("MATA416")
    //Verifica o saldo de desconto
    If SCJ->CJ_XSALDO <> 0
        If ZYF->(dbSeek(xFilial("ZYF")+SCJ->CJ_VEND+cValtoChar(Year(dDataBase))+"/"+StrZero(Month(dDataBase),2)))
            nSaldo:= ZYF->ZYF_SALDO
        Endif
        nSldPed:= nSaldo + SCJ->CJ_XSALDO * Iif(SCJ->CJ_VEND = cDiretor, nPercDir, nPercVend) //Saldo do vendedor passa a ser 50%. O restante vai para o diretor Lucilene SMSTI 29/08/22
        If nSldPed < 0
            If 2 = Aviso("Atenção - Saldo Negativo","Com esse pedido o saldo do vendedor ficará negativo: R$"+Alltrim(Transform(nSldPed,PesqPict("SE1","E1_VALOR")))+". Deseja gerar o pedido?",{"Sim","Não"})
                Return .F.
            Endif    
        Endif   
    Endif

Endif

Return .T.
