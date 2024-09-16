#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "topconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ DANFEPDF  ¦ Autor ¦ Lucilene Mendes     	 ¦ Data ¦19.07.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Geração da DANFE em pdf              					  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function DANFEPDF(nRecSF2,cDirDoc, cFilePrint)

	Local lRet             	:=.T.
	Local oSetup
	Local oDanfe
	Local lAdjustToLegacy  	:= .F.   //DEFAULT .F., NAO CALCULA
	Local lDisableSetup  	:= .T.
	Local cIdEnt			:= ""

	//Posiciona na NF
	dbSelectArea("SF2")
	SF2->(dbGoTo(nRecSF2))

	nFlags := PD_DISABLEORIENTATION
	//nFlags := PD_ISTOTVSPRINTER+ PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN

	// inicio - define impressão
	oDanfe     := FWMSPrinter():New(cFilePrint+'.pdf', IMP_PDF, lAdjustToLegacy, cDirDoc, lDisableSetup, , ,"PDF", , , , .F.)

	oDanfe:SetResolution(78) //Tamanho estipulado para a Danfe
	oDanfe:SetPortrait()
	oDanfe:SetPaperSize(9)
	oDanfe:cPathPDF := cDirDoc

	MV_PAR01 := SF2->F2_DOC
	MV_PAR02 := SF2->F2_DOC
	MV_PAR03 := SF2->F2_SERIE
	MV_PAR04 := 2 							//2 [Operacao] NF de Saida
	MV_PAR05 := 2									//Imprime no verso ?      1=sim, 2=nao
	MV_PAR06 := 2									//2[DANFE simplificado] Nao

	//Se já existir o arquivo, apaga para recriar
	If File(cDirDoc+cFilePrint+'.pdf')
		fErase(cDirDoc+cFilePrint+'.pdf')
	Endif

	cIdEnt:= GetIdEnt()

	Conout("cIdEnt: "+cIdEnt)

	aSf2:= (GetArea())

	//gera o arquivo .xml
	SpedPExp(cIdEnt,MV_PAR03,mv_par01,MV_PAR02,cDirDoc,.f.  ,SF2->F2_EMISSAO-30,SF2->F2_EMISSAO+30,Space(14),Space(14),,,,cFilePrint)

	RestArea(aSf2)
	//gera o arquivo .pdf
	lRet := U_PrtNfeSef(cIdEnt, mv_par01, mv_par01, oDanfe,oSetup, cDirDoc+cFilePrint	, .T.)   //passado .T. para que não abra a tela de perguntas, depois e retornado para .F.

	// SpedPExp( cIdEnt,cSerie       ,cNotaIni   ,cNotaFim   ,cDirDest,lEnd,dDataDe           ,dDataAte          ,cCnpjDIni       ,cCnpjDFim        ,nTipo,lCTe,cSerMax)
Return lRet

Static Function GetIdEnt(lUsaColab)

	local cIdEnt := ""
	local cError := ""

	Default lUsaColab := .F.

	cIdEnt := getCfgEntidade(@cError)

	if(empty(cIdEnt))
		//Aviso("SPED", cError, {STR0114}, 3)
		Conout("GetIdEnt - Entidade não encontrada")
	endif

Return(cIdEnt)

Static Function SpedPExp(cIdEnt,cSerie,cNotaIni,cNotaFim,cDirDest,lEnd,dDataDe,dDataAte,cCnpjDIni,cCnpjDFim,nTipo,lCTe,cSerMax,cFilePrint)

	Local aDeleta  := {}

	Local cAlias	:= GetNextAlias()
	Local cAnoInut  := ""
	Local cAnoInut1 := ""
	Local cCanc		:= ""
	Local cChvIni  	:= ""
	Local cChvFin	:= ""
	Local cChvNFe  	:= ""
	Local cCNPJDEST := Space(14)
	Local cCondicao	:= ""
	Local cDestino 	:= ""
	Local cDrive   	:= ""
	Local cIdflush  := cSerie+cNotaIni
	Local cModelo  	:= ""
	Local cNFes     := ""
	Local cPrefixo 	:= ""
	Local cURL     	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local cXmlInut  := ""
	Local cXml		:= ""
	Local cWhere	:= ""
	Local cXmlProt	:= ""
	local cAviso    := ""
	local cErro     := ""
	local cTab		  := ""
	local cCmpNum	  := ""
	local cCmpSer	  := ""
	local cCmpTipo  := ""
	local cCmpLoja  := ""
	local cCmpCliFor:= ""
	local cCnpj	  := ""
	Local cEventoCTe	:= ""
	Local cRetEvento	:= ""
	Local cRodapCTe  :=""
	local cCabCTe    :=""
	Local cIdEven	   := ""
	local cVerMDfe		:= ""
	local cNumMdfe		:= ""

	Local lOk      	:= .F.
	Local lFlush  	:= .T.
	Local lFinal   	:= .F.
	Local lClearFilter:= .F.
	Local lExporta 	:= .F.
	Local lUsaColab	:= .F.
	Local lSdoc     := TamSx3("F2_SERIE")[1] == 14

	Local nHandle  	:= 0
	Local nX        := 0
	Local nY		:= 0
	local nZ		:= 0

	Local aInfXml	:= {}

	Local oRetorno
	Local oWS
	Local oXML

	Local lOkCanc		:= .f.

	Default nTipo	:= 1
	Default cNotaIni:=""
	Default cNotaFim:=""
	Default dDataDe:=CtoD("  /  /  ")
	Default dDataAte:=CtoD("  /  /  ")
	Default lCTe	:= IIf (FunName()$"SPEDCTE,TMSA200,TMSAE70,TMSA500,TMSA050",.T.,.F.)
	Default cSerMax := cSerie

	lUsaColab := UsaColaboracao( IIF(lCte,"2","1") )

	If nTipo == 3
		If !Empty( GetNewPar("MV_NFCEURL","") )
			cURL := PadR(GetNewPar("MV_NFCEURL","http://"),250)
		Endif
	Endif

	If IntTMS() .and. lCTe//Altera o conteúdo da variavel quando for carta de correção para o CTE
		cTipoNfe := "SAIDA"
	EndIf
	ProcRegua(Val(cNotaFim)-Val(cNotaIni))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Corrigi diretorio de destino                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SplitPath(cDirDest,@cDrive,@cDestino,"","")
	cDestino := cDrive+cDestino
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia processamento                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If ( nTipo == 1 .And. !lUsaColab ).Or. nTipo == 3 .Or. nTipo == 4 .Or. nTipo == 5
		oWS:= WSNFeSBRA():New()
		oWS:cUSERTOKEN        := "TOTVS"
		oWS:cID_ENT           := cIdEnt
		oWS:_URL              := AllTrim(cURL)+"/NFeSBRA.apw"
		oWS:cIdInicial        := IIf(nTipo==4,'58'+cIdflush,cIdflush) // cNotaIni
		oWS:cIdFinal          := IIf(nTipo==4,'58'+cSerMax+cNotaFim,cSerMax+cNotaFim)
		oWS:dDataDe           := dDataDe
		oWS:dDataAte          := dDataAte
		oWS:cCNPJDESTInicial  := cCnpjDIni
		oWS:cCNPJDESTFinal    := cCnpjDFim
		oWS:nDiasparaExclusao := 0
		lOk:= oWS:RETORNAFX()
		oRetorno := oWS:oWsRetornaFxResult
		lOk := iif( valtype(lOk) == "U", .F., lOk )

		If lOk
			ProcRegua(Len(oRetorno:OWSNOTAS:OWSNFES3))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exporta as notas                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			For nX := 1 To Len(oRetorno:OWSNOTAS:OWSNFES3)

				//Ponto de Entrada para permitir filtrar as NF
				If ExistBlock("SPDNFE01")
					If !ExecBlock("SPDNFE01",.f.,.f.,{oRetorno:OWSNOTAS:OWSNFES3[nX]})
						loop
					Endif
				Endif

				oXml    := oRetorno:OWSNOTAS:OWSNFES3[nX]
				oXmlExp := XmlParser(oRetorno:OWSNOTAS:OWSNFES3[nX]:OWSNFE:CXML,"","","")
				cXML	:= ""
				If Type("oXmlExp:_NFE:_INFNFE:_DEST:_CNPJ")<>"U"
					cCNPJDEST := AllTrim(oXmlExp:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
				ElseIF Type("oXmlExp:_NFE:_INFNFE:_DEST:_CPF")<>"U"
					cCNPJDEST := AllTrim(oXmlExp:_NFE:_INFNFE:_DEST:_CPF:TEXT)
				Else
					cCNPJDEST := ""
				EndIf
				cVerNfe := IIf(Type("oXmlExp:_NFE:_INFNFE:_VERSAO:TEXT") <> "U", oXmlExp:_NFE:_INFNFE:_VERSAO:TEXT, '')
				cVerCte := Iif(Type("oXmlExp:_CTE:_INFCTE:_VERSAO:TEXT") <> "U", oXmlExp:_CTE:_INFCTE:_VERSAO:TEXT, '')
				cVerMDfe:= Iif(Type("oXmlExp:_MDFE:_INFMDFE:_VERSAO:TEXT") <> "U", oXmlExp:_MDFE:_INFMDFE:_VERSAO:TEXT, '')

				If !Empty(oXml:oWSNFe:cProtocolo)
					cNotaIni := oXml:cID
					cIdflush := cNotaIni
					cNFes := cNFes+cNotaIni+CRLF
					cChvNFe  := NfeIdSPED(oXml:oWSNFe:cXML,"Id")
					cModelo := cChvNFe
					cModelo := StrTran(cModelo,"NFe","")
					cModelo := StrTran(cModelo,"CTe","")
					cModelo := StrTran(cModelo,"MDFe","")
					cModelo := SubStr(cModelo,21,02)

					Do Case
						Case cModelo == "57"
						cPrefixo := "CTe"
						Case cModelo == "65"
						cPrefixo := "NFCe"
						Case cModelo == "58"
						cPrefixo := "MDFe"
						OtherWise
						if '<cStat>301</cStat>' $ oXml:oWSNFe:cxmlPROT .or. '<cStat>302</cStat>' $ oXml:oWSNFe:cxmlPROT
							cPrefixo := "den"
						else
							cPrefixo := "NFe"
						endif
					EndCase

					cChvNFe	:= iif( cModelo == "58", SubStr(cChvNFe,5,44), SubStr(cChvNFe,4,44) )
					//--------------------------------------------------
					// Exporta MDFe - (Autorizada)
					//--------------------------------------------------
					if ( (cModelo=="58") .and. alltrim(FunName()) == 'SPEDMDFE' )
						nHandle	:= 0
						nHandle := FCreate(cDestino+cChvNFe+"-"+cPrefixo+".xml")
						if nHandle > 0
							cCab1 := '<?xml version="1.0" encoding="UTF-8"?>'
							cCab1 	+= '<mdfeProc xmlns="http://www.portalfiscal.inf.br/mdfe" versao="'+cVerMDfe+'">'
							cRodap	:= '</mdfeProc>
							FWrite(nHandle,AllTrim(cCab1))
							FWrite(nHandle,AllTrim(oXml:oWSNFe:cXML))
							FWrite(nHandle,AllTrim(oXml:oWSNFe:cXMLPROT))
							FWrite(nHandle,AllTrim(cRodap))
							FClose(nHandle)
							aadd(aDeleta,oXml:cID)
							cNumMdfe += cIdflush+CRLF
						endif
						//--------------------------------------------------
						// Exporta Legado
						//--------------------------------------------------
					elseif alltrim(FunName()) <> 'SPEDMDFE'

						nHandle := FCreate(cDestino+cFilePrint+".xml")
						If nHandle > 0
							cCab1 := '<?xml version="1.0" encoding="UTF-8"?>'
							If cModelo == "57"
								//cCab1  += '<cteProc xmlns="http://www.portalfiscal.inf.br/cte" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/cte procCTe_v'+cVerCte+'.xsd" versao="'+cVerCte+'">'
								cCab1  += '<cteProc xmlns="http://www.portalfiscal.inf.br/cte" versao="'+cVerCte+'">'
								cRodap := '</cteProc>'
							Else
								Do Case
									Case cVerNfe <= "1.07"
									cCab1 += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/nfe procNFe_v1.00.xsd" versao="1.00">'
									Case cVerNfe >= "2.00" .And. "cancNFe" $ oXml:oWSNFe:cXML
									cCab1 += '<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">'
									OtherWise
									cCab1 += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">'
								EndCase
								cRodap := '</nfeProc>'
							EndIf
							FWrite(nHandle,AllTrim(cCab1))
							FWrite(nHandle,AllTrim(oXml:oWSNFe:cXML))
							FWrite(nHandle,AllTrim(oXml:oWSNFe:cXMLPROT))
							FWrite(nHandle,AllTrim(cRodap))
							FClose(nHandle)
							aadd(aDeleta,oXml:cID)

							cXML := AllTrim(cCab1)
							cXML += AllTrim(oXml:oWSNFe:cXML)
							cXML += AllTrim(oXml:oWSNFe:cXMLPROT)
							cXML += AllTrim(cRodap)
							If !Empty(cXML)
								If ExistBlock("FISEXPNFE")
									ExecBlock("FISEXPNFE",.f.,.f.,{cXML})
								Endif
							EndIF
						EndIf
					endif
				EndIf

				//----------------------------------------
				// Exporta MDF-e (Eventos)
				//----------------------------------------
				if (alltrim(FunName()) == 'SPEDMDFE')
					if ( (cModelo=="58") .and. (!empty(cChvNFe)) )
						//----------------------------------------
						// Executa o metodo NfeRetornaEvento()
						//----------------------------------------
						oWS:= WSNFeSBRA():New()
						oWS:cUSERTOKEN	:= "TOTVS"
						oWS:cID_ENT		:= cIdEnt
						oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
						oWS:cEvenChvNFE	:= cChvNFe
						lOk				:= oWS:NFERETORNAEVENTO()

						if lOk
							if valType(oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento) <> "U"
								aDados := oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento

								for nZ := 1 to len( aDados )
									//Zerando variaveis
									nHandle := 0
									nHandle := FCreate(cDestino + cChvNFe + "-" + cPrefixo + "_evento_" + alltrim(str(nZ)) + ".xml")
									if nHandle > 0
										cCab1 	:= '<?xml version="1.0" encoding="UTF-8"?>'
										cCab1 	+= '<mdfeProc xmlns="http://www.portalfiscal.inf.br/mdfe" versao="'+cVerMDfe+'">'
										cRodap	:= '</mdfeProc>
										fWrite(nHandle,allTrim(cCab1))
										fWrite(nHandle,allTrim(aDados[nZ]:cXML_RET))
										fWrite(nHandle,allTrim(aDados[nZ]:cXML_SIG))
										fWrite(nHandle,allTrim(cRodap))
										fClose(nHandle)
										aAdd(aDeleta,oXml:cID)
									endif
								next nZ
							endif
						endif
					endif
				else
					If ( oXml:OWSNFECANCELADA <> Nil .And. !Empty(oXml:oWSNFeCancelada:cProtocolo) )
						cChave 	  := oXml:OWSNFECANCELADA:CXML
						If cModelo == "57" .and. cVerCte >='2.00'
							cChaveCc1 := At("<chCTe>",cChave)+7
						else
							cChaveCc1 := At("<chNFe>",cChave)+7
						endif
						cChaveCan := SubStr(cChave,cChaveCc1,44)

						oWS:= WSNFeSBRA():New()
						oWS:cUSERTOKEN	:= "TOTVS"
						oWS:cID_ENT		:= cIdEnt
						oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
						oWS:cID_EVENTO	:= "110111"
						oWS:cChvInicial	:= cChaveCan
						oWS:cChvFinal	:= cChaveCan
						lOkCanc			:= oWS:NFEEXPORTAEVENTO()
						oRetEvCanc 	:= oWS:oWSNFEEXPORTAEVENTORESULT

						if lOkCanc

							ProcRegua(Len(oRetEvCanc:CSTRING))
							//---------------------------------------------------------------------------
							//| Exporta Cancelamento do Evento da Nf-e                                  |
							//---------------------------------------------------------------------------

							For nY := 1 To Len(oRetEvCanc:CSTRING)
								cXml    := SpecCharc(oRetEvCanc:CSTRING[nY])
								oXmlExp := XmlParser(cXml,"_",@cErro,@cAviso)
								If cModelo == "57" .and. cVerCte >='2.00'
									if Type("oXmlExp:_PROCEVENTONFE:_RETEVENTO:_CTERECEPCAOEVENTORESULT:_RETEVENTOCTE:_INFEVENTO:_CHCTE")<>"U"
										cIdEven	:= 'ID'+oXmlExp:_PROCEVENTONFE:_RETEVENTO:_CTERECEPCAOEVENTORESULT:_RETEVENTOCTE:_INFEVENTO:_CHCTE:TEXT
									elseIf Type("oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE:_INFEVENTO:_CHCTE")<>"U"
										cIdEven	:= 'ID'+oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE:_INFEVENTO:_CHCTE:TEXT
									endif

									If (Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE")<>"U") .and. (Type("oXmlExp:_PROCEVENTONFE:_RETEVENTO:_CTERECEPCAOEVENTORESULT:_RETEVENTOCTE")<>"U")
										cCabCTe   := '<procEventoCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="'+cVerCte+'">'
										cEventoCTe:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE,.F.)
										cRetEvento:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_RETEVENTO:_CTERECEPCAOEVENTORESULT:_RETEVENTOCTE,.F.)
										cRodapCTe := '</procEventoCTe>'
										CxML:= cCabCTe+cEventoCTe+cRetEvento+cRodapCTe
									ElseIf (Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE")<>"U") .and. (Type("oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE:_INFEVENTO")<>"U")
										cCabCTe   := '<procEventoCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="'+cVerCte+'">'
										cEventoCTe:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE,.F.)
										cRetEvento:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE,.F.)
										cRodapCTe := '</procEventoCTe>'
										CxML:= cCabCTe+cEventoCTe+cRetEvento+cRodapCTe
									EndIf

								else
									if Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_ID")<>"U"
										cIdEven	:= oXmlExp:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_ID:TEXT
									else
										if Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID")<>"U"
											cIdEven  := oXmlExp:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT
										EndIf
									endif
								endif

								nHandle := FCreate(cDestino+SubStr(cIdEven,3)+"-Canc.xml")
								if nHandle > 0
									FWrite(nHandle,AllTrim(cXml))
									FClose(nHandle)
								endIf
							Next nY
						Else
							cChvNFe  := NfeIdSPED(oXml:oWSNFeCancelada:cXML,"Id")
							cNotaIni := oXml:cID
							cIdflush := cNotaIni
							cNFes := cNFes+cNotaIni+CRLF
							If !"INUT"$oXml:oWSNFeCancelada:cXML
								nHandle := FCreate(cDestino+SubStr(cChvNFe,3,44)+"-ped-can.xml")
								If nHandle > 0
									cCanc := oXml:oWSNFeCancelada:cXML
									If cModelo == "57"
										oXml:oWSNFeCancelada:cXML := '<procCancCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="' + cVerCte + '">' + oXml:oWSNFeCancelada:cXML + "</procCancCTe>"
									Else
										oXml:oWSNFeCancelada:cXML := '<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">' + oXml:oWSNFeCancelada:cXML + "</procCancNFe>"
									EndIf
									FWrite(nHandle,oXml:oWSNFeCancelada:cXML)
									FClose(nHandle)
									aadd(aDeleta,oXml:cID)
								EndIf
								nHandle := FCreate(cDestino+"\"+SubStr(cChvNFe,3,44)+"-can.xml")
								If nHandle > 0
									If cModelo == "57"
										FWrite(nHandle,'<procCancCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="' + cVerCte + '">' + cCanc + oXml:oWSNFeCancelada:cXMLPROT + "</procCancCTe>")
									Else
										FWrite(nHandle,'<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">' + cCanc + oXml:oWSNFeCancelada:cXMLPROT + "</procCancNFe>")
									EndIF
									FClose(nHandle)
								EndIf
							Else

								//						If Type("oXml:OWSNFECANCELADA:CXML")<>"U"
								cXmlInut  := oXml:OWSNFECANCELADA:CXML
								cAnoInut1 := At("<ano>",cXmlInut)+5
								cAnoInut  := SubStr(cXmlInut,cAnoInut1,2)
								cXmlProt  := EncodeUtf8(oXml:oWSNFeCancelada:cXMLPROT)
								//					 	EndIf
								nHandle := FCreate(cDestino+SubStr(cChvNFe,3,2)+cAnoInut+SubStr(cChvNFe,5,39)+"-ped-inu.xml")
								If nHandle > 0
									FWrite(nHandle,oXml:OWSNFECANCELADA:CXML)
									FClose(nHandle)
									aadd(aDeleta,oXml:cID)
								EndIf
								nHandle := FCreate(cDestino+"\"+cAnoInut+SubStr(cChvNFe,5,39)+"-inu.xml")
								If nHandle > 0
									FWrite(nHandle,cXmlProt)
									FClose(nHandle)
								EndIf
							EndIf
						EndIf
					EndIf
				endif
				IncProc()
			Next nX

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui as notas                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aDeleta) .And. GetNewPar("MV_SPEDEXP",0)<>0
				oWS:= WSNFeSBRA():New()
				oWS:cUSERTOKEN        := "TOTVS"
				oWS:cID_ENT           := cIdEnt
				oWS:nDIASPARAEXCLUSAO := GetNewPar("MV_SPEDEXP",0)
				oWS:_URL              := AllTrim(cURL)+"/NFeSBRA.apw"
				oWS:oWSNFEID          := NFESBRA_NFES2():New()
				oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
				For nX := 1 To Len(aDeleta)
					aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
					Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aDeleta[nX]
				Next nX
				If !oWS:RETORNANOTAS()
					//Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0046},3)
					lFlush := .F.
				EndIf
			EndIf
			aDeleta  := {}
			If ( Len(oRetorno:OWSNOTAS:OWSNFES3) == 0 .And. Empty(cNfes) )
				//Aviso("SPED",STR0106,{"Ok"})	// "Não há dados"
				lFlush := .F.
			EndIf
		Else
			//Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))+CRLF+STR0046,{"OK"},3)
			lFinal := .T.
		EndIf

		If lSdoc
			cIdflush := AllTrim(Substr(cIdflush,1,14) + Soma1(AllTrim(substr(cIdflush,15))))
		Else
			cIdflush :=  AllTrim(Substr(cIdflush,1,3) + Soma1(AllTrim(substr(cIdflush,4))))
		EndIf

		If lOk
			lFlush := .F.

			/*If cIdflush <= AllTrim(cNotaIni) .Or. Len(oRetorno:OWSNOTAS:OWSNFES3) == 0 .Or. Empty(cNfes) .Or. ;
			cIdflush <= If(lSdoc,Substr(cNotaIni,1,14)+Replicate('0',Len(AllTrim(mv_par02))-Len(Substr(Rtrim(cNotaIni),15)))+Substr(Rtrim(cNotaIni),15),;
			Substr(cNotaIni,1,3)+Replicate('0',Len(AllTrim(mv_par02))-Len(Substr(Rtrim(cNotaIni),4)))+Substr(Rtrim(cNotaIni),4))// Importou o range completo
			lFlush := .F.
			If !Empty(cNfes)
			If Aviso("SPED",STR0152,{"Sim","Não"}) == 1	//"Solicitação processada com sucesso."
			if alltrim(FunName()) == 'SPEDMDFE'
			if empty(cNumMdfe)
			Aviso("SPED",STR0106,{"Ok"})	// "Não há dados"
			else
			Aviso(STR0126,STR0151+" "+Upper(cDestino)+CRLF+CRLF+cNumMdfe,{"Ok"})
			endif
			else
			// Exporta Legado
			Aviso(STR0126,STR0151+" "+Upper(cDestino)+CRLF+CRLF+cNFes,{"Ok"})//STR0151-"XML Exportados para", "XML's Exportados para"
			endif
			EndIf
			else
			Aviso("SPED",STR0106,{"Ok"})	// "Não há dados"
			EndIf

			EndIf
			*/
		Else
			lFlush := .F.
		Endif
		delclassintf()
	ElseIf nTipo == 2  .Or. lUsaColab //Carta de Correcao e NF-e(QUANDO FOR TOTVS COLABORAÇÃO 2.0)

		cWhere:="D_E_L_E_T_=' '"
		If !Empty(cSerie)

			If lSdoc
				If cTipoNfe == "SAIDA"
					cWhere		+= " AND F2_SDOC ='"+SubStr(cSerie,1,3)+"'"
					cCondicao	+= AllTrim("F2_SDOC ='"+SubStr(cSerie,1,3)+"'")
				Else
					cWhere		+= " AND F1_SDOC ='"+SubStr(cSerie,1,3)+"'"
					cCondicao	+= AllTrim("F1_SDOC ='"+SubStr(cSerie,1,3)+"'")
				Endif
			Else
				If cTipoNfe == "SAIDA"
					cWhere		+= " AND F2_SERIE ='"+cSerie+"'"
					cCondicao	+= AllTrim("F2_SERIE ='"+cSerie+"'")
				Else
					cWhere		+= " AND F1_SERIE ='"+cSerie+"'"
					cCondicao	+= AllTrim("F1_SERIE ='"+cSerie+"'")
				Endif
			EndIf

		EndIf
		If !Empty(cNotaIni)
			If cTipoNfe == "SAIDA"
				cWhere		+= " AND F2_DOC >='"+cNotaIni+"'"
				cCondicao 	+= AllTrim(" .AND. F2_DOC >='"+cNotaIni+"'")
			Else
				cWhere		+= " AND F1_DOC >='"+cNotaIni+"'"
				cCondicao 	+= AllTrim(" .AND. F1_DOC >='"+cNotaIni+"'")
			Endif
		EndIf
		If !Empty(cNotaFim)
			If cTipoNfe == "SAIDA"
				cWhere		+= " AND F2_DOC <='"+cNotaFim+"'"
				cCondicao 	+= AllTrim(" .AND. F2_DOC <='"+cNotaFim+"'")
			Else
				cWhere		+= " AND F1_DOC <='"+cNotaFim+"'"
				cCondicao 	+= AllTrim(" .AND. F1_DOC <='"+cNotaFim+"'")
			Endif
		EndIf
		If !Empty(dDataDe)
			If cTipoNfe == "SAIDA"
				cWhere		+= " AND F2_EMISSAO >='"+DtoS(dDataDe)+"'"
				cCondicao 	+= " .AND. DTOS(F2_EMISSAO) >='"+DtoS(dDataDe)+"'"
			Else
				cWhere		+= " AND F1_EMISSAO >='"+DtoS(dDataDe)+"'"
				cCondicao 	+= " .AND. DTOS(F1_EMISSAO) >='"+DtoS(dDataDe)+"'"
			Endif
		EndIf
		If !Empty(dDataAte)
			If cTipoNfe == "SAIDA"
				cWhere		+= " AND F2_EMISSAO <='"+DtoS(dDataAte)+"'"
				cCondicao	+= " .AND. DTOS(F2_EMISSAO) <='"+DtoS(dDataAte)+"'"
			Else
				cWhere		+= " AND F1_EMISSAO <='"+DtoS(dDataAte)+"'"
				cCondicao	+= " .AND. DTOS(F1_EMISSAO) <='"+DtoS(dDataAte)+"'"
			Endif
		EndiF
		cWhere:="%"+cWhere+"%"
		#IFDEF TOP
		If cTipoNfe == "SAIDA"
			if lUsaColab
				BeginSql Alias cAlias
					SELECT F2_DOC, F2_SERIE, F2_TIPO, F2_CLIENTE, F2_LOJA
					FROM %Table:SF2%
					WHERE F2_FILIAL= %xFilial:SF2%
					AND	%Exp:cWhere%
				EndSql
				lExporta:=!(cAlias)->(Eof())
			else
				BeginSql Alias cAlias
					SELECT MIN(R_E_C_N_O_) AS RECINI,MAX(R_E_C_N_O_) AS RECFIN
					FROM %Table:SF2%
					WHERE F2_FILIAL= %xFilial:SF2%
					AND	%Exp:cWhere%
				EndSql
				SF2->(dbGoTo((cAlias)->RECINI))
				cChvIni := SF2->F2_CHVNFE
				SF2->(dbGoTo((cAlias)->RECFIN))
				cChvFin := SF2->F2_CHVNFE
				lExporta:=!(cAlias)->(Eof())
			endif
		Else
			if lUsaColab
				BeginSql Alias cAlias
					SELECT F1_DOC, F1_SERIE, F1_TIPO, F1_FORNECE, F1_LOJA
					FROM %Table:SF1%
					WHERE F1_FILIAL= %xFilial:SF1%
					AND	%Exp:cWhere%
				EndSql
				lExporta:=!(cAlias)->(Eof())
			else
				BeginSql Alias cAlias
					SELECT MIN(R_E_C_N_O_) AS RECINI,MAX(R_E_C_N_O_) AS RECFIN
					FROM %Table:SF1%
					WHERE F1_FILIAL= %xFilial:SF1%
					AND	%Exp:cWhere%
				EndSql
				SF1->(dbGoTo((cAlias)->RECINI))
				cChvIni := SF1->F1_CHVNFE
				SF1->(dbGoTo((cAlias)->RECFIN))
				cChvFin := SF1->F1_CHVNFE
				lExporta:=!(cAlias)->(Eof())
			endif
		Endif
		#ELSE
		If cTipoNfe == "SAIDA"
			cAlias := "SF2"
			dbSetFilter({|| &cCondicao},cCondicao)
			if !lUsaColab
				(cAlias)->(dbGotop())
				cChvIni := SF2->F2_CHVNFE
				(cAlias)->(DbGoBottom())
				cChvFin := SF2->F2_CHVNFE
				lExporta:=!SF2->(Eof())
				(cAlias)->(dbClearFilter())
			else
				lClearFilter := .T.
				lExporta:=!SF2->(Eof())
			endif
		Else
			cAlias := "SF1"
			dbSetFilter({|| &cCondicao},cCondicao)
			If !lUsaColab
				(cAlias)->(dbGotop())
				cChvIni := SF1->F1_CHVNFE
				(cAlias)->(DbGoBottom())
				cChvFin := SF1->F1_CHVNFE
				lExporta:=!SF1->(Eof())
				(cAlias)->(dbClearFilter())
			else
				lClearFilter := .T.
				lExporta:=!SF1->(Eof())
			endif
		Endif
		#ENDIF

		If lExporta
			If lUsaColab

				cCnpjDFim := iif(empty(cCnpjDFim),"99999999999999", cCnpjDFim)

				(cAlias)->(dbGoTop())

				While !(cAlias)->(Eof())

					if cTipoNfe == "SAIDA"
						cTab := 'F2_'
						cCmpCliFor := cTab+'CLIENTE'
					else
						cTab := 'F1_'
						cCmpCliFor := cTab+'FORNECE'
					endif

					cCmpNum 	:= cTab+'DOC'
					cCmpSer 	:= cTab+'SERIE'
					cCmpTipo	:= cTab+'TIPO'
					cCmpLoja	:= cTab+'LOJA'
					cPrefix := iif(nTipo == 1,IIF(lCTe,"CTe","NFe"),"CCe")

					//Tratamento para verificar se o CNPJ está no range inserido pelo usuário.
					lCnpj :=	.F.

					if cPrefix $ "CCe"
						lCnpj := .T.
					else

						If cTipoNfe == "SAIDA"
							if (cAlias)->&cCmpTipo $ 'D|B'
								cCnpj := Posicione("SA2",1,xFilial("SA2")+(cAlias)->&cCmpCliFor+(cAlias)->&cCmpLoja,"A2_CGC")
							else
								cCnpj := Posicione("SA1",1,xFilial("SA1")+(cAlias)->&cCmpCliFor+(cAlias)->&cCmpLoja,"A1_CGC")
							endif
						else
							if (cAlias)->&cCmpTipo $ 'D|B'
								cCnpj := Posicione("SA1",1,xFilial("SA1")+(cAlias)->&cCmpCliFor+(cAlias)->&cCmpLoja,"A1_CGC")
							else
								cCnpj := Posicione("SA2",1,xFilial("SA2")+(cAlias)->&cCmpCliFor+(cAlias)->&cCmpLoja,"A2_CGC")
							endif
						endif

						if cCnpj >= cCnpjDIni .And. cCnpj <= cCnpjDFim
							lCnpj := .T.
						endif
					endif

					If lCnpj
						cXML := ""

						aInfXml	:= {}
						aInfXml := ColExpDoc((cAlias)->&cCmpSer,(cAlias)->&cCmpNum,iif(nTipo == 1,IIF(lCTe,"CTE","NFE"),"CCE"),@cXml)
						/*
						aInfXml
						[1] - Logico se encotra documento .T.
						[2] - Chave do documento
						[3] - XML autorização - someente se autorizado
						[4] - XML Cancelamento Evento- somente se autorizado
						[5] - XML Ped. Inutilização - somente se autorizado
						[6] - XML Prot. Inutilização - somente se autorizado
						*/
						//Ponto de Entrada para permitir filtrar as NF
						If ExistBlock("SPDNFE01")
							If !ExecBlock("SPDNFE01",.f.,.f.,{aInfXml})
								(cAlias)->(dbSkip())
								loop
							Endif
						Endif
						//Encontrou documento
						if aInfXMl[1]

							if cPrefix == "CCe" .And. !Empty( aInfXMl[3] )
								nHandle := FCreate(cDestino+SubStr(aInfXMl[2],3)+"-CCe.xml")
								cXML := aInfXMl[3]

								If nHandle > 0
									FWrite(nHandle,AllTrim(cXml))
									FClose(nHandle)
								EndIf
								cNFes+=SubStr((cAlias)->&cCmpSer,1,3)+"/"+(cAlias)->&cCmpNum+CRLF

							elseif cPrefix $ "NFe|CTe"
								//Iinutilização
								if !Empty( aInfXMl[5] )
									cXmlInut  := aInfXMl[5]
									cAnoInut1 := At("<ano>",cXmlInut)+5
									cAnoInut  := SubStr(cXmlInut,cAnoInut1,2)
									cXmlProt  := aInfXMl[6]

									nHandle := FCreate(cDestino+SubStr(aInfXMl[2],3,2)+cAnoInut+SubStr(aInfXMl[2],5,39)+"-ped-inu.xml")
									If nHandle > 0
										FWrite(nHandle,oXml:OWSNFECANCELADA:CXML)
										FClose(nHandle)
										aadd(aDeleta,oXml:cID)
									EndIf
									nHandle := FCreate(cDestino+"\"+cAnoInut+SubStr(aInfXMl[2],5,39)+".xml")
									If nHandle > 0
										FWrite(nHandle,cXmlProt)
										FClose(nHandle)
									EndIf
									cNFes+=SubStr((cAlias)->&cCmpSer,1,3)+"/"+(cAlias)->&cCmpNum+CRLF
								endif
								//Cancelamento
								if !Empty( aInfXMl[4] )
									cXml    := SpecCharc(aInfXMl[4])
									nHandle := FCreate(cDestino+SubStr(aInfXMl[2],3)+"-canc.xml")
									if nHandle > 0
										FWrite(nHandle,AllTrim(cXml))
										FClose(nHandle)
									endIf
									cNFes+=SubStr((cAlias)->&cCmpSer,1,3)+"/"+(cAlias)->&cCmpNum+CRLF
								endif

								if !Empty( aInfXML[3] )
									cXml    := SpecCharc(aInfXMl[3])

									If ExistBlock("FISEXPNFE")
										ExecBlock("FISEXPNFE",.f.,.f.,{cXML})
									EndIF

									nHandle := FCreate(cDestino+cFilePrint+".xml")
									if nHandle > 0
										FWrite(nHandle,AllTrim(cXml))
										FClose(nHandle)
									endIf

									cNFes+=SubStr((cAlias)->&cCmpSer,1,3)+"/"+(cAlias)->&cCmpNum+CRLF
								endif
							endif
							IncProc()
						endif
					endif
					(cAlias)->(dbSkip())
				enddo
				If !Empty(cNfes)
					//If Aviso("SPED",STR0152,{"Sim","Não"}) == 1	//"Solicitação processada com sucesso."
					//	Aviso(STR0126,STR0151+" "+Upper(cDestino)+CRLF+CRLF+cNFes,{STR0114},3)//STR0151-"XML Exportados para", "XML's Exportados para"
					//EndIf
				endif
				delclassintf()
			else
				oWS:= WSNFeSBRA():New()
				oWS:cUSERTOKEN	:= "TOTVS"
				oWS:cID_ENT		:= cIdEnt
				oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
				oWS:cChvInicial	:= cChvIni
				oWS:cChvFinal	:= cChvFin
				lOk:= oWS:NFEEXPORTAEVENTO()
				oRetorno := oWS:oWSNFEEXPORTAEVENTORESULT

				If lOk

					ProcRegua(Len(oRetorno:CSTRING))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Exporta as cartas                                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					For nX := 1 To Len(oRetorno:CSTRING)
						cXml    := oRetorno:CSTRING[nX]
						cXml	 := EncodeUTF8(cXml)
						oXmlExp := XmlParser(cXml,"_",@cErro,@cAviso)
						If Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_ID")<>"U"
							cIdCCe	:= oXmlExp:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_ID:TEXT
						Elseif Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT")<> "U"
							cIdCCe  := oXmlExp:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT
						Else
							cIdCCe  := oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE:_INFEVENTO:_ID:TEXT
						Endif

						If (Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE")<>"U") .and. (Type("oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE:_INFEVENTO")<>"U")
							cVerCte := Iif(Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE:_VERSAO:TEXT ") <> "U", oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE:_VERSAO:TEXT , '')
							cCabCTe   := '<procEventoCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="'+cVerCte+'">'
							cEventoCTe:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE,.F.)
							cRetEvento:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE,.F.)
							cRodapCTe := '</procEventoCTe>'
							cXml:= cCabCTe+cEventoCTe+cRetEvento+cRodapCTe
						EndIf

						nHandle := FCreate(cDestino+SubStr(cIdCCe,3)+"-CCe.xml")
						If nHandle > 0
							FWrite(nHandle,AllTrim(cXml))
							FClose(nHandle)
						EndIf
						IncProc()
						cNFes+=SubStr(cIdCCe,31,3)+"/"+SubStr(cIdCCe,34,9)+CRLF
					Next nX

					//If Aviso("SPED",STR0152,{"Sim","Não"}) == 1	//"Solicitação processada com sucesso."
					//	Aviso(STR0126,STR0151+" "+Upper(cDestino)+CRLF+CRLF+cNFes,{STR0114},3) //STR0151-"XML Exportados para", "XML's Exportados para"
					//EndIf
				Else
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
					lFinal := .T.
				EndIF
				delclassintf()
			endif
		EndIf
		#IFDEF TOP
		If select (cAlias)>0
			(cAlias)->(dbCloseArea())
		EndIf
		#ENDIF
		lFlush := .F.
	EndIF

Return(.T.)