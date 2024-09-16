#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "topconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE IMP_SPOOL 2


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ BOLPDF  ¦ Autor ¦ Lucilene Mendes     	 ¦ Data ¦19.07.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Geração da Boleto em pdf              					  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function BOLPDF(nRecSE1, cDirDoc, cFilePrint)

	Local lRet             	:=.T.
	local cErro := ""
	Local nQtdBol := 0
	Private oImpBol
	Private oSetup 
	//Posiciona na NF
	dbSelectArea("SE1")
	SE1->(dbGoTo(nRecSE1))

	//Se já existir o arquivo, apaga para recriar
	If File(cDirDoc+cFilePrint+'.pdf')
		fErase(cDirDoc+cFilePrint+'.pdf')
	Endif 

	//gera o arquivo .pdf
	Conout(TIME()+"INICIANDO GERAÇÃO BOLETO "+cValToChar(SE1->(recno())))
	// lRet := U_PrtNfeSef(cIdEnt, mv_par01, mv_par01, oDanfe,oSetup, cDirDoc+cFilePrint	, .T.)   //passado .T. para que não abra a tela de perguntas, depois e retornado para .F.
	if SE1->E1_PORTADO == "422" // Safra (Tratamento novo modelo desenvolvido)
		nQtdBol := 0
		lRet := .f.
		U_BOLSAFRA(SE1->E1_NUM, SE1->E1_PREFIXO, @oImpBol, SE1->E1_CLIENTE, SE1->E1_LOJA , nil, @nQtdBol, .f., SE1->E1_PARCELA, Substr(SE1->E1_FILORIG,1,6), nRecSE1, cDirDoc+cFilePrint)
		If nQtdBol > 0
			lRet := file(cDirDoc+cFilePrint+'.pdf')
			// if file(cDirDoc+cFilePrint+'.pdf')
			// 	conout("Ja imprimiu")
			// endif

			// while file(oImpBol:cFilePrint)
			// 	oImpBol:cFileName  := cFilePrint+".rel"
			// 	oImpBol:cFilePrint := oImpBol:cPathPrint + oImpBol:cFileName
			// endDo
			// oImpBol:Preview()
		endif
		FreeObj(oImpBol)
		oImpBol := Nil
	else
		//lRet := U_BolPDFE1(cDirDoc+cFilePrint+'.pdf', @cErro, (date() > SE1->E1_VENCREA)) //atualiza vencimento
		lRet := U_BolPDFE1(cDirDoc+cFilePrint+'.pdf', @cErro, .F.) //não atualiza vencto
		
		conout("Erro da geracao do pdf boleto: "+cErro)
	endif

	Conout(TIME()+"FIM GERAÇÃO BOLETO "+cValToChar(SE1->(recno())))
	// SpedPExp( cIdEnt,cSerie       ,cNotaIni   ,cNotaFim   ,cDirDest,lEnd,dDataDe           ,dDataAte          ,cCnpjDIni       ,cCnpjDFim        ,nTipo,lCTe,cSerMax)
Return lRet

