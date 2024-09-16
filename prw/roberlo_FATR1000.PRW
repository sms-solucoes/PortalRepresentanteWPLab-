//--------------------------------------------------------
//Impressão Pedido Vendas                                 
//--------------------------------------------------------
#include "totvs.ch"
#include "protheus.ch"                     
#include "topconn.ch"

User Function FATR1000(cAlias, nRecno, nOpc)

Local aArea := GetArea()

Private aImpostos := {}
Private aImp      := {0,0}

Private	oFonte08  := TFont():New('Arial',08,08,,.F.,,,,.T.,.F.,.F.)
Private	oFonte08N := TFont():New('Arial',08,08,,.T.,,,,.T.,.F.,.F.)
Private	oFonte10  := TFont():New('Arial',10,10,,.F.,,,,.T.,.F.,.F.)
Private	oFonte10N := TFont():New('Arial',10,10,,.T.,,,,.T.,.F.,.F.)
Private	oFonte11N := TFont():New('Arial',11,11,,.T.,,,,.T.,.F.,.F.)
Private	oFonte12N := TFont():New('Arial',12,12,,.T.,,,,.T.,.F.,.F.)
Private	oFonte14N := TFont():New('Arial',14,14,,.T.,,,,.T.,.F.,.F.)
Private	oFonte20N := TFont():New('Arial',20,20,,.T.,,,,.T.,.F.,.F.)
Private	oFonte28  := TFont():New('Arial',28,28,,.F.,,,,.T.,.F.,.F.)

Private	oBrWhite  := TBrush():New2(,fRGB(255,255,255))
Private	oBrGray   := TBrush():New2(,fRGB(240,240,240))
Private	oBrBlack  := TBrush():New2(,fRGB(0,0,0))

Private lPrim     := .T.
Private nLin      := 5000
Private nLinAux   := 0
Private nLinAux2  := 0
Private nLinAux3  := 0
Private nPag      := 0
Private nTotItens := 0
Private cPedido	  := ""
Private cEmpresa
Private cVendedor

Do Case
	Case cAlias == "SC9"
		Posicione("SC5", 1, xFilial("SC5") + SC9->C9_PEDIDO, "C5_NUM")
EndCase

cPedido := SC5->C5_NUM
nTotItens := FGETNUMIT()

If MOD(nTotItens,15) == 0
	nTotPag := INT(nTotItens/15)
Else
	nTotPag := INT(nTotItens/15)+1
Endif

oPrint := ReportDef()
oPrint:PrintDialog()	

RestArea(aArea)

Return

//-------------------------
Static Function REPORTDEF()

Local cRelato := "PV"+Alltrim(SC5->C5_NUM)

oPrint := TReport():New(cRelato,"Pedido Vendas",,{|oPrint| PrintReport()},"Impressão Pedido Vendas")
oPrint:HideHeader()
oPrint:HideFooter()
oPrint:SetPortrait()

Return oPrint

//---------------------------
Static Function PRINTREPORT()
Local nCurrentLine

If nLin >= 2500
	FQUEBRA()
Endif

Private nSubTot := 0
Private nTotIpi := 0
Private nTotSt  := 0
Private nTotIcm := 0
Private nIcms   := 0
Private nTotal  := 0    
Private nvIPI	:= 0
Private nvST    := 0
Private nTotEnc := 0    
Private nTotGer := 0    
Private nAcresc	:= 0   

dbSelectArea("SC5")
SC5->(dbSetOrder(1))
dbSelectArea("SC6")
SC6->(dbSetOrder(1))

If dbSeek(xFilial("SC6")+SC5->C5_NUM)
	nLinN := 1600
	
//	oPrint:Line(nLinN,0050,nLinAux,0050)
//	oPrint:Line(nLinN,0120,nLinAux,0120)
//	oPrint:Line(nLinN,0250,nLinAux,0250)
//	oPrint:Line(nLinN,0450,nLinAux,0450)
//	oPrint:Line(nLinN,1190,nLinAux,1190)
//	oPrint:Line(nLinN,1390,nLinAux,1390)
//	oPrint:Line(nLinN,1590,nLinAux,1590)
//	oPrint:Line(nLinN,1790,nLinAux,1790)
//	oPrint:Line(nLinN,2030,nLinAux,2030)
//	oPrint:Line(nLinN,2320,nLinAux,2320)
	
//	oPrint:Line(nLinN,0050,nLinN,2320)
	
	While !Eof() .and. xFilial("SC6") == xFilial("SC5") .and. SC6->C6_NUM == SC5->C5_NUM

		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))

		If dbSeek(xFilial("SB1")+SC6->C6_PRODUTO)
			dbSelectArea("SF4")
			SF4->(dbSetOrder(1))
			cCliente := SC6->C6_CLI
			cLojCli  := SC6->C6_LOJA   
			cTipCli  := Posicione("SA1",1,xFilial("SA1")+cCliente+cLojCli,"A1_TIPO")

			If dbSeek(xFilial("SF4")+SC6->C6_TES)
				aImposto := fImpostos(cCliente,cLojCli,cTipCli,SC6->C6_PRODUTO,SC6->C6_TES,SC6->C6_QTDVEN,SC6->C6_PRCVEN,SC6->C6_VALOR)
				/*
				oPrint:Say(nLin,0062, SC6->C6_ITEM, oFonte10)
				oPrint:Say(nLin,0240, Transform(SC6->C6_QTDVEN,"@E 99,999.99"), oFonte10,,,,1)
				oPrint:Say(nLin,0260, SC6->C6_PRODUTO, oFonte10)
				oPrint:Say(nLin,0465, Substr(SB1->B1_DESC,1,40), oFonte10)
				oPrint:Say(nLin,1380, Transform(SC6->C6_PRCVEN,"@E 99,999.99"), oFonte10,,,,1)
				*/    
				oPrint:Say(nLin,0062, SC6->C6_ITEM, oFonte10)
				oPrint:Say(nLin,0240, Transform(SC6->C6_QTDVEN,"@E 99,999.99"), oFonte10,,,,1)
				oPrint:Say(nLin,0262, SC6->C6_LOCAL, oFonte10)
				oPrint:Say(nLin,0330, SC6->C6_PRODUTO, oFonte10)
				oPrint:Say(nLin,0535, Left(If(Left(SB1->B1_DESC, 5) == "PNEU ", SubStr(SB1->B1_DESC, 6), SB1->B1_DESC), 40), oFonte10)
				oPrint:Say(nLin,1450, Transform(SC6->C6_PRCVEN,"@E 99,999.99"), oFonte10,,,,1)

				nvIPI := ((SC6->C6_VALOR * aImposto[2]) / 100)
				nvST  := aImposto[1]
				/*				
				oPrint:Say(nLin,1580, Transform(nvIPI,"@E 99,999.99"), oFonte10,,,,1)
				oPrint:Say(nLin,1780, Transform(nvST,"@E 99,999.99"), oFonte10,,,,1)
				oPrint:Say(nLin,2000, Transform(nIcms,"@E 9,999,999.99"), oFonte10,,,,1)
				oPrint:Say(nLin,2300, Transform(SC6->C6_VALOR+nvIPI+nvST,"@E 9,999,999.99"), oFonte10,,,,1)
				*/
				oPrint:Say(nLin,1650, Transform(nvIPI,"@E 99,999.99"), oFonte10,,,,1)
				oPrint:Say(nLin,1850, Transform(nvST,"@E 99,999.99"), oFonte10,,,,1)
				oPrint:Say(nLin,2058, Transform(nIcms,"@E 9,999,999.99"), oFonte10,,,,1)
				oPrint:Say(nLin,2310, Transform(SC6->C6_VALOR+nvIPI+nvST,"@E 9,999,999.99"), oFonte10,,,,1)
				nLin+=50
			Endif       
			If nLin >= 2500
				FQUEBRA()
			Endif
		Endif
		
		If nLin >= 2500
			FQUEBRA()
		Endif
		
		nSubTot += (SC6->C6_QTDVEN * SC6->C6_PRCVEN)
		nTotIpi += ((SC6->C6_VALOR * aImposto[2]) / 100)
		nTotSt  += aImposto[1]
		nTotal  += SC6->C6_VALOR
		nTotEnc += SC6->C6_VALPON
		nTotIcm += nIcms
		dbSelectArea("SC6")
		SC6->(dbSkip())
	Enddo
Endif

//nLin := 1600
/*  
oPrint:Line(nLin,0050,nLinAux,0050)
oPrint:Line(nLin,0120,nLinAux,0120)
oPrint:Line(nLin,0250,nLinAux,0250)
oPrint:Line(nLin,0450,nLinAux,0450)
oPrint:Line(nLin,1190,nLinAux,1190)
oPrint:Line(nLin,1390,nLinAux,1390)
oPrint:Line(nLin,1590,nLinAux,1590)
oPrint:Line(nLin,1790,nLinAux,1790)
oPrint:Line(nLin,2030,nLinAux,2030)
oPrint:Line(nLin,2320,nLinAux,2320)
*/
oPrint:Line(nLin,0050,nLinAux,0050)
oPrint:Line(nLin,0120,nLinAux,0120)
oPrint:Line(nLin,0250,nLinAux,0250)
oPrint:Line(nLin,0320,nLinAux,0320)
oPrint:Line(nLin,0520,nLinAux,0520)
oPrint:Line(nLin,1260,nLinAux,1260)
oPrint:Line(nLin,1460,nLinAux,1460)
oPrint:Line(nLin,1660,nLinAux,1660)
oPrint:Line(nLin,1860,nLinAux,1860)
oPrint:Line(nLin,2068,nLinAux,2068)
oPrint:Line(nLin,2320,nLinAux,2320)

oPrint:Line(nLin,0050,nLin,2320)
nLin += 20

If !Empty(cVendedor)
	oPrint:Say(nLin,0050, "Vendedor: " + cVendedor, oFonte10)
Else
	oPrint:Say(nLin,0050, "Vendedor: " + Alltrim(Posicione("SM0",1,cEmpAnt+SC5->C5_FILIAL,"M0_NOMECOM")), oFonte10)
Endif

oPrint:Say(nLin,1400, "Total Produtos: ", oFonte10,,,,1)
oPrint:Say(nLin,1700, Transform(nSubTot,"@E 999,999.99"), oFonte10,,,,1)
oPrint:Say(nLin,2040, "Total IPI: ", oFonte10,,,,1)
oPrint:Say(nLin,2300, Transform(nTotIpi,"@E 99,999.99"), oFonte10,,,,1)
nLin += 50
oPrint:Say(nLin,1400, "Total ICMS: ", oFonte10,,,,1)
oPrint:Say(nLin,1700, Transform(nTotIcm ,"@E 99,999.99"), oFonte10,,,,1)
oPrint:Say(nLin,2040, "Total ICMS ST: ", oFonte10,,,,1)
oPrint:Say(nLin,2300, Transform(nTotSt ,"@E 99,999.99"), oFonte10,,,,1)
nLin += 50
oPrint:Say(nLin,1400, "Total Frete: ", oFonte10,,,,1)
oPrint:Say(nLin,1700, Transform(SC5->C5_FRETE ,"@E 99,999.99"), oFonte10,,,,1)
oPrint:Say(nLin,2040, "Total Outros: ", oFonte10,,,,1)
oPrint:Say(nLin,2300, Transform(nTotEnc ,"@E 999,999.99"), oFonte10,,,,1)
nLin += 50
oPrint:Say(nLin,2040, "Acréscimo: ", oFonte10,,,,1)
If SC5->C5_ACRSFIN > 0
	nAcresc:= Round((nTotal+nTotIpi+nTotSt+nTotEnc+SC5->C5_FRETE) * (SC5->C5_ACRSFIN/100),2)
Else
	nAcresc:= 0
Endif
oPrint:Say(nLin,2300, Transform(nAcresc ,"@E 999,999.99"), oFonte10,,,,1)
nLin += 70

oPrint:Say(nLin,2040, "Total Geral: ", oFonte10N,,,,1)
oPrint:Say(nLin,2300, Transform(nTotal+nTotIpi+nTotSt+nTotEnc+SC5->C5_FRETE+nAcresc ,"@E 9,999,999.99"), oFonte11N,,,,1)

nTotGer := nTotal+nTotIpi+nTotSt+SC5->C5_FRETE

nLinAux := nLin
nLin += 50

oPrint:Line(nLin,0050,nLin,2320)

FPARCELA()

nLin += 100


oPrint:Say(nLin,0050, "TRANSPORTADORA: " + Alltrim(Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME")), oFonte10)        
nLin += 70
oPrint:Say(nLin,0050, "VOLUME: " + str(SC5->C5_VOLUME1), oFonte10)
nLin += 200

oPrint:Say(nLin,0060, "Observações: ", oFonte10)
oPrint:Box(nLin-10,0050,nLin+150,2320)

nTamLin := 150
nTab    := 3
lWrap   := .T.
cMemo   := Alltrim(SC5->C5_OBS)
nLines  := MLCOUNT(cMemo, nTamLin, nTab, lWrap)

For nCurrentLine := 1 To nLines
	oPrint:Say (nLin,0300,MEMOLINE(cMemo, nTamLin, nCurrentLine, nTab, lWrap),oFonte10)
	nLin += 50
Next nCurrentLine

nLinAux2 := nLin
nLin += 90
nLinAux3 := nLin

oPrint:EndPage(.T.)

Return

//-----------------------
Static Function FQUEBRA()
		
nPag++

If !lPrim
	nLin := 2550
 
	oPrint:Say(nLin,0050, "C O N T I N U A >>> Página "+Alltrim(Strzero(nPag,2))+" . . .", oFonte12N)
	oPrint:Say(nLin,1400, "Total Produtos: ", oFonte10,,,,1)
	nLin += 50
	oPrint:Say(nLin,1400, "Total ICMS: ", oFonte10,,,,1)
	nLin+= 50
	oPrint:Say(nLin,1400, "Total Frete: ", oFonte10,,,,1)
	nLin += 50
	oPrint:Say(nLin,2040, "Total IPI: ", oFonte10,,,,1)
	nLin += 50
	oPrint:Say(nLin,2040, "Total ICMS ST: ", oFonte10,,,,1)
	nLin += 50
	oPrint:Say(nLin,2040, "Total Outros: ", oFonte10,,,,1)
	nLin += 70
	oPrint:Say(nLin,2040, "Total Geral: ", oFonte10N,,,,1)

	oPrint:EndPage(.T.)
Endif

lPrim := .F.

oPrint:StartPage()
	                               
cEmpresa  := Alltrim(Posicione("SM0",1,cEmpAnt+SC5->C5_FILIAL,"M0_NOMECOM"))
cVendedor := Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NOME")
cEmail	  := Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_EMAIL")
	
oPrint:Say(100,0050, cEmpresa,oFonte20N)
oPrint:Say(120,1950, "Número: ",oFonte12N)
oPrint:Say(100,2320, SC5->C5_NUM,oFonte20N,,,,1)

If Empty(SC5->C5_NOTA)
	oPrint:Say(200,0050, "Emissão: " + Dtoc(ddatabase),oFonte12N)
Else
	oPrint:Say(200,0050, "Emissão: " + Dtoc(ddatabase) + " - Nota Fiscal "+Alltrim(SC5->C5_NOTA),oFonte12N)
Endif
oPrint:Say(200,2320, "Página: " + Strzero(nPag,2),oFonte12N,,,,1)
oPrint:Say(250,0050, "Fone: "   + Alltrim(SM0->M0_TEL)+" / FAX: " + Alltrim(SM0->M0_FAX),oFonte12N)
If !Empty(cEmail)
	oPrint:Say(250,2320, "E-mail: " + Alltrim(cEmail),oFonte12N,,,,1)
Else
	oPrint:Say(250,2320, "E-mail: " + "faturamento@autoamerica.com.br",oFonte12N,,,,1)
Endif

oPrint:Line(300,0050,300,2320)

dbSelectArea("SA1")
SA1->(dbSetOrder(1))

If dbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
	oPrint:Say(320,0050, "Cliente: " + Alltrim(SC5->C5_CLIENTE) + " / " + Alltrim(SC5->C5_LOJACLI) + " - " + Alltrim(SA1->A1_NOME),oFonte10)
	oPrint:Say(370,0050, "Endereço: " + Alltrim(SA1->A1_END) + " - " + Alltrim(SA1->A1_BAIRRO) + " - " + Alltrim(SA1->A1_MUN) + " - " + Alltrim(SA1->A1_EST),oFonte10)	
	oPrint:Say(420,0050, "Fone-Fax: " + IIF(Empty(SA1->A1_TEL)," ",Transform(SA1->A1_DDD+SA1->A1_TEL,"@R (99)9999-9999"))+ IIF(Empty(SA1->A1_FAX)," "," / " + Transform(SA1->A1_DDD+SA1->A1_FAX,"@R (99)9999-9999")),oFonte10)
	oPrint:Say(470,0050, "E-mail: " + Alltrim(SA1->A1_EMAIL),oFonte10)
Endif

oPrint:Box(520,0050,600,2320)
oPrint:Say(540,1200, "ORÇAMENTO PRODUTOS" , oFonte14N,,,,2)

nLin := 600
nLinAux := nLin

oPrint:FillRect({ nLin,050,nLin+70,2320}, oBrGray)
oPrint:Box(nLin,050,nLin+70,2320)
nLin += 20

/*
oPrint:Say(nLin,0070, "IT"          , oFonte10)
oPrint:Say(nLin,0140, "QTDE"        , oFonte10)
oPrint:Say(nLin,0285, "CODIGO"		, oFonte10)
oPrint:Say(nLin,0465, "DESCRICAO"   , oFonte10)
oPrint:Say(nLin,1220, "VALOR UN"    , oFonte10)
oPrint:Say(nLin,1420, "VALOR IPI"   , oFonte10)
oPrint:Say(nLin,1620, "VALOR ST"    , oFonte10)
oPrint:Say(nLin,1820, "VALOR ICMS"  , oFonte10)
oPrint:Say(nLin,2100, "VALOR TOTAL" , oFonte10)
*/

oPrint:Say(nLin,0070, "IT"			, oFonte10)
oPrint:Say(nLin,0240, "QTDE"		, oFonte10,,,,1)
oPrint:Say(nLin,0255, "ARM"			, oFonte10)
oPrint:Say(nLin,0355, "CÓDIGO"		, oFonte10)
oPrint:Say(nLin,0535, "DESCRIÇÃO"	, oFonte10)
oPrint:Say(nLin,1450, "VALOR UN"	, oFonte10,,,,1)
oPrint:Say(nLin,1650, "VALOR IPI"	, oFonte10,,,,1)
oPrint:Say(nLin,1850, "VALOR ST"	, oFonte10,,,,1)
oPrint:Say(nLin,2058, "VALOR ICMS"	, oFonte10,,,,1)
oPrint:Say(nLin,2310, "VALOR TOTAL"	, oFonte10,,,,1)
nLin += 65

Return

//-------------------------
Static Function FRGB(R,G,B)

Local nRGB := 0

nRGB = B * 65536 + G * 256 + R
	
Return(nRGB)

//-------------------------
Static Function FGETNUMIT()

Local nRet := 0

If ( Select("TRB") ) > 0
	dbSelectArea("TRB")
	TRB->(dbCloseArea())
Endif

cQuery := "SELECT COUNT(*) AS NUM_ITENS FROM " + RETSQLNAME("SC6") + " WHERE D_E_L_E_T_ = ' ' AND C6_NUM = '" + SC5->C5_NUM + "' "
cQuery := ChangeQuery(cQuery)
cQuery := ChangeQuery(cQuery)

TcQuery cQuery New Alias "TRB"

nRet := TRB->NUM_ITENS

Return(nRet)

//----------------------------------------------------------------------------
Static Function FIMPOSTOS(cCliente,cLoja,cTipo,cProduto,cTes,nQtd,nPrc,nValor)

	                     
MaFisIni(cCliente,;										//Codigo Cliente/Fornecedor
		 cLoja,;										//Loja do Cliente/Fornecedor
		 "C",;											//C:Cliente/F:Fornecedor
		 "N",;											//Tipo da NF
		 cTipo,;										//Tipo do Cliente/Fornecedor
 		 MaFisRelImp("MTR700",{"SC5","SC6"}),;			//Relacao de Impostos que suportados no arquivo
	 	 ,;												//""                                                                                                                                                          // 7-Tipo de complemento
		 ,;												//""                                                                                                                                                          // 8-Permite Incluir Impostos no Rodape .T./.F.
		 "SB1",;										//Alias do Cadastro de Produtos
		 "MTR700")  									//Nome da rotina que esta utilizando a funcao
		
	MaFisAdd(cProduto, cTes, nQtd, nPrc, 0, "", "",, 0, 0, 0, 0, nValor, 0)

	aadd(aImpostos,"IT_VALICM")                         //Valor ICMS
	aadd(aImpostos,"IT_ALIQICM") 						//Aliquota do ICMS
	aadd(aImpostos,"IT_ALIQIPI") 						//Aliquota do IPI
	aadd(aImpostos,"IT_ALIQISS")						//Aliquota de ISS do item
	aadd(aImpostos,"IT_ALIQIRR") 						//Aliquota de Calculo do IR do Item
	aadd(aImpostos,"IT_ALIQINS") 						//Aliquota de Calculo do INSS
	aadd(aImpostos,"IT_ALIQIV1") 						//Aliquota de Impostos Variaveis 1
	aadd(aImpostos,"IT_ALIQIV2")						//Aliquota de Impostos Variaveis 2
	aadd(aImpostos,"IT_ALIQIV3") 						//Aliquota de Impostos Variaveis 3
	aadd(aImpostos,"IT_ALIQIV4") 						//Aliquota de Impostos Variaveis 4
	aadd(aImpostos,"IT_ALIQIV5") 						//Aliquota de Impostos Variaveis 5
	aadd(aImpostos,"IT_ALIQIV6") 						//Aliquota de Impostos Variaveis 6
	aadd(aImpostos,"IT_ALIQIV7") 						//Aliquota de Impostos Variaveis 7
	aadd(aImpostos,"IT_ALIQIV8") 						//Aliquota de Impostos Variaveis 8
	aadd(aImpostos,"IT_ALIQIV9")						//Aliquota de Impostos Variaveis 9
	aadd(aImpostos,"IT_ALIQCOF")						//Aliquota de calculo do COFINS
	aadd(aImpostos,"IT_ALIQCSL")						//Aliquota de calculo do CSLL
	aadd(aImpostos,"IT_ALIQPIS")						//Aliquota de calculo do PIS
	aadd(aImpostos,"IT_ALIQPS2")						//Aliquota de calculo do PIS 2
	aadd(aImpostos,"IT_ALIQCF2")						//Aliquota de calculo do COFINS 2
	aadd(aImpostos,"IT_ALIQAFRMM")						//Aliquota de calculo do AFRMM ( Item )
	aadd(aImpostos,"IT_ALIQSES") 						//Aliquota de calculo do SEST          
	aadd(aImpostos,"IT_VALSOL")			                //Valor ICMS ST
	aadd(aImpostos,"NF_VALSOL")                         //Valor ICMS ST Livros
	aadd(aImpostos,"LF_ICMSRET")          				//ICMS Livros Fiscal

	aImp[1] := MaFisRet(1,"IT_VALSOL")
	
	dbSelectArea("SF4")
	SF4->(dbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+cTes,.T.))   
	
	aImp[2] := 0
	
	If SF4->F4_IPI == "S"
		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+cProduto,.T.))
		If SB1->B1_IPI > 0
			aImp[2] := SB1->B1_IPI
		Endif
	Endif
	
	MaFisSave()
	MaFisEnd()

Return(aImp)

//------------------------
Static Function FPARCELA()
Local nI
Private aCond := Condicao(nTotGer, SC5->C5_CONDPAG, 0, SC5->C5_EMISSAO, 0, Nil, Nil, 0, Nil, Nil)

If nTotEnc > 0
	Private aPontos := Condicao(nTotEnc, SC5->C5_CONDPAG, 0, SC5->C5_EMISSAO, 0, Nil, Nil, 0, Nil, Nil)
Endif

nLin += 30

oPrint:Say(nLin,0050, "PC", oFonte10N)
oPrint:Say(nLin,0150, "VENCTO", oFonte10N)
oPrint:Say(nLin,0650, "VALOR", oFonte10N,,,,1)
oPrint:Say(nLin,0750, "FORMA PAGTO", oFonte10N)

oPrint:Say(nLin,1100, "PC", oFonte10N)
oPrint:Say(nLin,1250, "VENCTO", oFonte10N)
oPrint:Say(nLin,1750, "VALOR", oFonte10N,,,,1)
oPrint:Say(nLin,1850, "FORMA PAGTO", oFonte10N)
oPrint:Say(nLin,2150, "PORTADOR", oFonte10N)

For nI := 1 To Len(aCond)
	nLin += 50
	oPrint:Say(nLin,0050, StrZero(nI, 2), oFonte10)
	oPrint:Say(nLin,0150, Dtoc(aCond[nI][1]), oFonte10)
	oPrint:Say(nLin,0650, AllTrim(Transform(aCond[nI][2], "@E 9,999,999.99")), oFonte10,,,,1)
	oPrint:Say(nLin,0750, Substr(Posicione("SX5",1,xFilial("SX5")+"ZE"+SC5->C5_MODAL,"X5_DESCRI"),1,15), oFonte10)

	If nTotEnc > 0 .and. nI <= Len(aPontos)
		oPrint:Say(nLin,1100, StrZero(nI, 2), oFonte10)
		oPrint:Say(nLin,1250, Dtoc(aPontos[nI][1]), oFonte10)
		oPrint:Say(nLin,1750, AllTrim(Transform(aPontos[nI][2], "@E 9,999,999.99")), oFonte10,,,,1)
		oPrint:Say(nLin,1850, Substr(Posicione("SX5",1,xFilial("SX5")+"ZE"+SC5->C5_MODAL,"X5_DESCRI"),1,15), oFonte10)
	Endif
	
	oPrint:Say(nLin,2150, Substr(Posicione("SA6",1,xFilial("SA6")+SC5->C5_PORTADO,"A6_NREDUZ"),1,15), oFonte10)
Next nI                 
                   
Return
