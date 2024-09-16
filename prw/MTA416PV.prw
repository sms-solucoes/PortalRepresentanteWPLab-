#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦  MTA416PV   ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦15.05.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Ponto de Entrada para alteração dos dados gerados no PV.   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function MTA416PV()
Local nItem		:= PARAMIXB
Local nPosPedCli := aScan(_aHeader,{|x| AllTrim(x[2])=="C6_PEDCLI"})
Local nPosItem 	:= aScan(_aHeader,{|x| AllTrim(x[2])=="C6_NUMORC"})
Local nPosQtd 	:= aScan(_aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPosProd 	:= aScan(_aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local cOrcto	:= Left(_aCols[nItem,nPosItem],6)
Local cItemOrc	:= Right(_aCols[nItem,nPosItem],2)
Local p         := 0
Local nQtdVol   := 0

/* Variáveis vindas da rotina padrão
_aCols
_aHeader
*/

M->C5_TRANSP := SCJ->CJ_XTRANSP
M->C5_MENNOTA:= SCJ->CJ_XMSGNF
M->C5_OBSINT := SCJ->CJ_XNOTAIN
M->C5_VEND1	 := SCJ->CJ_VEND
M->C5_VEND2	 := POSICIONE("SA3",1,xFilial("SA3")+SCJ->CJ_VEND,"A3_SUPER")
M->C5_VEND3	 := POSICIONE("SA3",1,xFilial("SA3")+SCJ->CJ_VEND,"A3_GEREN")
M->C5_TPFRETE:= SCJ->CJ_TPFRETE
M->C5_MODAL  := SCJ->CJ_XMODALI
M->C5_NCLIENT:= SA1->A1_NOME
M->C5_TIPLIB := '2' //Liberação por pedido
M->C5_XRETIRA:= Iif(SCJ->CJ_XRETIRA = '1','1','2')
M->C5_XSALDO := SCJ->CJ_XSALDO 
M->C5_ACRSFIN:= SCJ->CJ_XACRESC
M->C5_PORTADO:= GetNewPar("RB_PORTPV",'033')

//Busca a quantidade de volumes
For p:= 1 to Len(_aCols)
    nQuant:= _aCols[p,nPosQtd]
    nQtdEmb:= Posicione("SB1",1,xFilial("SB1")+_aCols[p,nPosProd],"B1_QE")
    If nQtdEmb > 0
        nQtdVol += Round(nQuant / nQtdEmb, 0)
    Else
        nQtdVol+= nQuant
    Endif
Next

M->C5_VOLUME1:= nQtdVol
M->C5_ESPECI1:= 'CAIXAS'
	
_aCols[nItem,nPosPedCli]:= SCK->CK_XPEDCLI+SCK->CK_XITEMCL

//Zera o campo desconto
GdFieldPut("C6_DESCONT",0,nItem,_aHeader,_aCols)
GdFieldPut("C6_VALDESC",0,nItem,_aHeader,_aCols)

//grava o campo desconto personalizado
GdFieldPut("C6_DESCIT",SCK->CK_DESCONT,nItem,_aHeader,_aCols)
GdFieldPut("C6_PRECLI",SCK->CK_PRCVEN ,nItem,_aHeader,_aCols)
GdFieldPut("C6_PRUNIT",SCK->CK_PRCVEN ,nItem,_aHeader,_aCols)

GdFieldPut("C6_XDESC01",SCK->CK_XDESC01 ,nItem,_aHeader,_aCols)
GdFieldPut("C6_XDESC02",SCK->CK_XDESC02 ,nItem,_aHeader,_aCols)
GdFieldPut("C6_XDESC03",SCK->CK_XDESC03 ,nItem,_aHeader,_aCols)

//Saldo
GdFieldPut("C6_XSALDO",SCK->CK_XSALDO ,nItem,_aHeader,_aCols)


//Grava o desconto à vista
//GdFieldPut("C6_DESCONT",SCJ->CJ_DESC1,nItem,_aHeader,_aCols)

//Trata desconto à vista
If SCJ->CJ_DESC1 > 0
 	M->C5_DESC1 := 0
//  	M->C5_MODVALT := "1" //não recalcula a comissão
Endif
 
//Atualiza a quantidade liberada
//GdFieldPut("C6_QTDLIB",_aCols[nItem,nPosQtd],nItem,_aHeader,_aCols) --Removido 05/02/2020 conf. solicitação Simony

Return
