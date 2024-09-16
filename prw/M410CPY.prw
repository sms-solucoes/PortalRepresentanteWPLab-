#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦  MT410CPY   ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦22.08.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Ponto de Entrada para alteração dos dados COPIADOS no PV   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
USER FUNCTION MT410CPY()

Local aArea := GetArea()
Local lRet := .T.
Local nPosNumOrc := GDFIELDPOS("C6_NUMORC")
Local nPosItem := GDFIELDPOS("C6_ITEM")
Local nx := 0

If nPosNumOrc > 0
	For nx := 1 To Len(aCols)
    		aCols[nx][nPosNumOrc] = Posicione("SC6",1,xFilial("SC6")+SC5->C5_NUM+aCols[nx,nPosItem],"C6_NUMORC")
    Next nx
Endif

RestArea(aArea)

RETURN lRet

