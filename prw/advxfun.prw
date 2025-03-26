#include "protheus.ch"
#include "ap5mail.ch"
#include "topconn.ch"
#include "fileio.ch"
User Function CliFor(cBrowse)
Local cNome  := ""
Local cAlias := "SA"
Local cChave := ""
Local cTipo  := ""
Default cBrowse := Alias()

If (cBrowse $ "SF1/SC7/SZA")
	If (cBrowse == "SC7")
		cChave := SC7->C7_FORNECE + SC7->C7_LOJA
		cTipo  := "N"
	ElseIf (cBrowse == "SF1")
		cChave := SF1->F1_FORNECE + SF1->F1_LOJA
		cTipo  := SF1->F1_TIPO
	Else
		cChave := SZA->ZA_FORNECE + SZA->ZA_LOJA
		cTipo  := SZA->ZA_TIPO
	EndIf
	
	cAlias += If(cTipo $ "BD", "1", "2")
ElseIf (cBrowse $ "SF2/SC5")
	If (cBrowse == "SC5")
		cChave := SC5->C5_CLIENTE + SC5->C5_LOJACLI
		cTipo  := SC5->C5_TIPO
	Else
		cChave := SF2->F2_CLIENTE + SF2->F2_LOJA
		cTipo  := SF2->F2_TIPO
	EndIf
	
	cAlias += If(cTipo $ "BD", "2", "1")
EndIf
cNome := Posicione(cAlias, 1, xFilial(cAlias) + cChave, PrefixoCpo(cAlias) + "_NOME")
Return cNome

User Function DateDif(dIni, cIni, dFim, cFim)
Local nDias := 0
Local nHrs  := 0
Local nMin  := 0
Local nSeg  := 0
Local aIni  := {}
Local aFim  := {}

cIni := PadR(cIni, 8)
cFim := PadR(cFim, 8)

aAdd(aIni, Val(SubStr(cIni, 1, 2)))
aAdd(aIni, Val(SubStr(cIni, 4, 2)))
aAdd(aIni, Val(SubStr(cIni, 7, 2)))

aAdd(aFim, Val(SubStr(cFim, 1, 2)))
aAdd(aFim, Val(SubStr(cFim, 4, 2)))
aAdd(aFim, Val(SubStr(cFim, 7, 2)))

nDias := dFim - dIni
nHrs  := aFim[1] - aIni[1]
nMin  := aFim[2] - aIni[2]
nSeg  := aFim[3] - aIni[3]

If nSeg < 0
	nMin--
	nSeg += 60
EndIf

If nMin < 0
	nHrs--
	nMin += 60
EndIf

If nHrs < 0
	nDias--
	nHrs += 24
EndIf

If nDias < 0
	nDias := 0
EndIf

nHrs += nDias * 24

Return {nHrs, nMin, nSeg}

User Function Mod3Alt(cTit, cCab, cIts, aCab, cLin, cAll, nCab, nIts, cFld, lVir, nLin, aAlt, nFrz, aBut, xPar15, xPar16, aAltGD)
Local lRet := .F.
Local nOpc := 0
Local cSav := ""
Local nReg := (cCab)->(Recno())
Local oDlg := Nil
Local aSize:= {}
Local aObjs:= {}
Local aInfo:= {}
Local aPos := {}

Private Inclui   := nCab == 3
Private Altera   := nCab == 4
Private Exclui   := nCab == 5
Private lRefresh := .T.
Private aTELA    := Array(0,0)
Private aGets    := Array(0)
Private bCampo   := {|nCpo| Field(nCpo)}
Private nPosAnt  := 9999
Private nColAnt  := 9999
Private cSavScrVT
Private cSavScrVP
Private cSavScrHT
Private cSavScrHP
Private CurLen
Private nPosAtu  := 0
Private oGD     := Nil

nCab := If(nCab == Nil, 003, nCab)
nIts := If(nIts == Nil, 003, nIts)
lVir := If(lVir == Nil, .F., lVir)
nLin := If(nLin == Nil, 999, nLin)

aSize := MsAdvSize()
aObjs := {}
aAdd(aObjs, {100, 100, .T., .T.})
aAdd(aObjs, {100, 100, .T., .T.})
aInfo := {aSize[1], aSize[2], aSize[3], aSize[4], 3, 3}
aPos := MsObjSize(aInfo, aObjs)

Define msDialog oDlg Title cTit From aSize[7], 0 To aSize[6], aSize[5] Of oMainWnd Pixel
EnChoice(cCab, nReg, nCab, Nil, Nil, Nil, aCab, aPos[1], aAlt, 3, Nil, Nil, Nil, Nil, Nil, lVir)
oGD := msGetDados():New(aPos[2][1], aPos[2][2], aPos[2][3], aPos[2][4], nIts, cLin, cAll, "", .T., aAltGD, nFrz, Nil, nLin, cFld)
Activate Dialog oDlg Centered On Init EnchoiceBar(oDlg, {|| nOpc := 1, If(oGD:TudoOk(), If(!Obrigatorio(aGets, aTela), nOpc := 0, oDlg:End()), nOpc := 0)}, {|| oDlg:End()}, Nil, aBut)

lRet := (nOpc == 1)
Return lRet

User Function MandaEml(cTo, cSubj, cBody, aAttach, lHtml, cCC, cBCC, cFrom, cRepTo, lConf)
Local cConta    := "SISTEMA"
Local cTipo
Local aHeader   := {}
Default cCc     := ""
Default cBcc    := ""
Default cSubj   := ""
Default cBody   := ""
Default aAttach := {}
Default cFrom   := ""
Default cRepTo  := ""
Default lConf   := .F.
Default lHtml   := .T.

If !Empty(cRepTo)
	aAdd(aHeader, {"Reply-To", cRepTo})
EndIf

If !lHtml
	cTipo := "text"
EndIf


WFNewMsg(cConta, cTo, cCC, cBCC, cSubj, cBody, aAttach, aHeader, cTipo)
WFSndMsg(cConta)
Return

User Function QrySX3(cAliasQry)
Local nI    := 0
Local cCpo  := ""
Local aDesc := {}

cAliasQry := If(cAliasQry == Nil, Alias(), cAliasQry)
SX3->(dbSetOrder(2))

For nI := 1 To (cAliasQry)->(FCount())
	cCpo := (cAliasQry)->(FieldName(nI))
	aAdd(aDesc, {cCpo, ""})
	If SX3->(dbSeek(cCpo))
		If (SX3->X3_TIPO # "C")
			TCSetField(cAliasQry, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL)
		EndIf
		aDesc[nI][1] := Trim(SX3->X3_TITULO)
		aDesc[nI][2] := Trim(SX3->X3_PICTURE)
	ElseIf "_RECNO" $ cCpo
		TCSetField(cAliasQry, cCpo, "N", 10, 0)
	EndIf
Next
Return aDesc

User Function DscCBox(cCpo, cItem, cDef)
Local cRet := If(cDef == Nil, "", cDef)
Local nI, nJ := 0
Local nCnt := 0
Local cBox := Posicione("SX3", 2, cCpo, "X3_CBOX")
Default cItem := &cCpo

While !Empty(cBox)
	nCnt := At(";", cBox)
	nJ   := At("=", cBox)
	nCnt := If(nCnt == 0, Len(cBox) + 1, nCnt)
	If Left(cBox, nJ - 1) == cItem
		cRet := SubStr(cBox, nJ + 1, nCnt - (nJ + 1))
		cBox := ""
	Else
		cBox := SubStr(cBox, nCnt + 1)
	EndIf
EndDo
cRet := AllTrim(cRet)
Return cRet

User Function ChecaDir(cFullPath)
Local cPathFil := ""
Local aTmpPath := {}
Local nPathNAt := 0
Local nFolders := 0
Local nI       := 0
Local lRet     := .F.

nPathNAt := At(":", cFullPath)
cPathFil := Left(cFullPath, nPathNAt)
aTmpPath := StrToKArr(Right(cFullPath, Len(cFullPath) - nPathNAt), "\")
nFolders := Len(aTmpPath)

For nI := 1 To nFolders
	cPathFil += "/" + aTmpPath[nI]
	If !ExistDir(cPathFil)
		MakeDir(cPathFil)
	EndIf
Next
lRet := ExistDir(cFullPath)
Return lRet

User Function ProcPerg(cPerg, aSX1)
Local lCombo := .F.
Local aPerg  := {}
Local aCombo := {}
Local aHelp  := {}
Local aAux   := {}
Local cAux   := ""
Local nAux   := 0
Local nI, nJ, nK := 0

For nI := 1 To Len(aSX1)
	If !Empty(aSX1[nI][7])
		aSX1[nI][3] := TamSXG(aSX1[nI][7])[1]
	EndIf

	If ValType(aSX1[nI][1]) == "A"
		aPerg := aClone(aSX1[nI][1])
	Else
		aPerg := {aSX1[nI][1], "", ""}
	EndIf
	
	aCombo := {{"", "", ""}, {"", "", ""}, {"", "", ""}, {"", "", ""}, {"", "", ""}}
	lCombo := .F.
	If ValType(aSX1[nI][8]) == "A"
		lCombo := .T.
		For nJ := 1 To Len(aSX1[nI][8])
			If ValType(aSX1[nI][8][nJ]) == "A"
				aAux := aClone(aSX1[nI][8][nJ])
			Else
				aAux := {aSX1[nI][8][nJ], "", ""}
			EndIf
			aCombo[nJ] := aClone(aAux)
		Next
	EndIf
	
	If ValType(aSX1[nI][9]) == "A"
		aHelp := {{aSX1[nI][9][1]}, {aSX1[nI][9][2]}, {aSX1[nI][9][3]}}
	Else
		aHelp := {{aSX1[nI][9]}, {""}, {""}}
	EndIf
	For nJ := 1 To 3
		aAux := {}
		cAux := aHelp[nJ][1]
		nAux := MLCount(cAux, 40)
		If !Empty(cAux)
			For nK := 1 To nAux
				aAdd(aAux, MemoLine(cAux, 40, nK))
			Next
			aHelp[nJ] := aClone(aAux)
		EndIf
	Next
	
	PutSX1(cPerg, StrZero(nI, 2), aPerg[1], aPerg[2], aPerg[3],;
	"mv_ch" + RetAsc(AllTrim(Str(nI)), 1, .T.), aSX1[nI][2],;
	aSX1[nI][3], aSX1[nI][4], If(lCombo, 1, 0), If(lCombo, "C", "G"),;
	aSX1[nI][5], aSX1[nI][6], aSX1[nI][7], "S", "mv_par" + StrZero(nI, 2),;
	aCombo[1][1], aCombo[1][2], aCombo[1][3], "",;
	aCombo[2][1], aCombo[2][2], aCombo[2][3],;
	aCombo[3][1], aCombo[3][2], aCombo[3][3],;
	aCombo[4][1], aCombo[4][2], aCombo[4][3],;
	aCombo[5][1], aCombo[5][2], aCombo[5][3],;
	aHelp[1], aHelp[2], aHelp[3])
Next
Return

User Function Qry2HTM(cArq, cTit, aCpTot, cAlias, lDel)
Local cAtt     := ""
Local cTipo    := ""
Local cPict    := ""
Local nHdl, nI := 0
Local xCpo     := Nil
Local aCabs    := {}
Default cArq   := "\" + CriaTrab(Nil, .F.) + ".htm"
Default cAlias := Alias()
Default cTit   := cAlias
Default aCpTot := {}
Default lDel   := .T.

nHdl := fCreate(cArq)
If nHdl > 0
	If Type("nRegs") # "N"
		nRegs := 0
	EndIf
	If Type("aTotais") # "A"
		aTotais := Array(Len(aCpTot))
		aEval(aTotais, {|nTot, nPos| aTotais[nPos] := 0})
	EndIf
	dbSelectArea(cAlias)
	aCabs := U_QrySX3()
	If Empty(aCabs)
		For nI := 1 To FCount()
			aAdd(aCabs, {FieldName(nI), ""})
		Next
	EndIf
	
	cAtt := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><html><head><title>' + cTit + "</title></head><body>"
	cAtt += '<table border="1" summary="relatorio microsiga">'
	cAtt += '<tBody>'
	cAtt +=   '<tr>'
	aEval(aCabs, {|aCol| cAtt += '<th scope="col">' + Trim(aCol[1]) + '</th>'})
	cAtt +=   '</tr>'
	fWrite(nHdl, cAtt, Len(cAtt))
	While !Eof()
		nRegs++
		cAtt := '<tr>'
		For nI := 1 To FCount()
			xCpo  := &(FieldName(nI))
			cTipo := Type(FieldName(nI))
			cPict := aCabs[nI][2]
			cAtt += '<td>'
			If cTipo == "N"
				cAtt += '<div align="right">'
				If Empty(cPict)
					cPict := "@E 999,999,999" + If(xCpo - Int(xCpo) > 0, ".99", "")
				EndIf
				cAtt += AllTrim(Transform(xCpo, cPict))
				cAtt += '</div>'
			ElseIf cTipo == "D" .and. !Empty(xCpo)
				cAtt += DToC(xCpo)
			Else
				cAtt += AllTrim(If(Empty(cPict), xCpo, Transform(xCpo, cPict)))
				cAtt += "&nbsp;"
			EndIf
			cAtt += '</td>'
		Next
		cAtt += '</tr>'
		aEval(aCpTot, {|nTot, nPos| aTotais[nPos] += &(aCpTot[nPos])})
		
		fWrite(nHdl, cAtt, Len(cAtt))
		dbSkip()
	EndDo
	
	cAtt := '</tBody>'
	cAtt += '</table>'
	cAtt += '</body>'
	cAtt += '</html>'
	fWrite(nHdl, cAtt, Len(cAtt))
	fClose(nHdl)
	
	If lDel .and. Empty(nRegs)
		FErase(cArq)
		cArq := ""
	EndIf
Else
	cArq := ""
EndIf
dbSelectArea(cAlias)
Return cArq

User Function WoY(dData, lISO)
Local nSem  := 1
Local nDias := 0
Local dDia1 := SToD("")
Local nDDS  := 0
Local nDDS1 := 0
Default dData := dDataBase
Default lISO  := .F.

dDia1 := SToD(StrZero(Year(dData), 4) + "0101")
nDias := (dData - dDia1) + 1
nSem  := NoRound((nDias + 6) / 7, 0)
nDDS  := If(lISO, If(DoW(dData) == 1, 7, DoW(dData) - 1), DoW(dData))
nDDS1 := If(lISO, If(DoW(dDia1) == 1, 7, DoW(dDia1) - 1), DoW(dDia1))

If nDDS < nDDS1
	nSem++
EndIf
Return nSem

User Function ComboCpo(cCpo)
Local aRet := {{}, {}}
Local aAux := {}
Local cAux := ""
Local cCbo := Trim(Posicione("SX3", 2, cCpo, "X3_CBOX"))
Local nI, nJ

aAux := StrToKArr(cCbo, ";")

For nI := 1 To Len(aAux)
	nJ := At("=", aAux[nI])
	cAux := Left(aAux[nI], nJ - 1)
	aAdd(aRet[1], cAux)
	cAux := SubStr(aAux[nI], nJ + 1)
	aAdd(aRet[2], cAux)
Next
Return aRet

User Function VldPath(cPath, lBarra)
Local cBarra
Local cErro
Default cPath  := ""
Default lBarra := .T.

If IsSrvUnix()
	cBarra := "/"
	cErro  := "\"
Else	
	cBarra := "\"
	cErro  := "/"
EndIf

cPath := AllTrim(cPath) 
cPath := StrTran(cPath, cErro, cBarra)
cPath := StrTran(cPath, cBarra + cBarra, cBarra)

If lBarra .and. Right(cPath, 1) # cBarra
	cPath += cBarra
ElseIf !lBarra .and. Right(cPath, 1) == cBarra
	cPath := Left(cPath, Len(cPath) - 1)
EndIf
Return cPath

Static aSX1 := {}
User Function BkpSX1
Local cPerg := "mv_par01"
Local nI    := 1

aSX1 := {}
While nI < 100 .and. Type(cPerg) # "U" 
	aAdd(aSX1, &cPerg)
	nI++
	cPerg := "mv_par" + StrZero(nI, 2)
EndDo 
Return aSX1

User Function RecSX1(aPerg)
Default aPerg := aClone(aSX1)

aEval(aPerg, {|xPerg, nPerg| &("mv_par" + StrZero(nPerg, 2)) := xPerg})
Return

User Function BrwTemp(aCpos, aArq, aBrw)
Local nI
Default aArq := {}
Default aBrw := {}

dbSelectArea("SX3")
dbSetOrder(2)
For nI := 1 To Len(aCpos)
	If dbSeek(aCpos[nI])
		If X3_CONTEXT # "V"
			aAdd(aArq, {Trim(X3_CAMPO), X3_TIPO, X3_TAMANHO, X3_DECIMAL})
		EndIf
		aAdd(aBrw, {X3Titulo(), &("{|| " + Trim(If(X3_CONTEXT == "V", X3_INIBRW, X3_CAMPO)) + "}"), X3_TIPO, Trim(X3_PICTURE), If(X3_TIPO == "N", 2, Nil), X3_TAMANHO, X3_DECIMAL})
	EndIf
Next
Return {aArq, aBrw}
