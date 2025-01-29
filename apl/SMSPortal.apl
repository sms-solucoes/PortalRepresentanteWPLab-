#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"

#DEFINE SMSDEBUG
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ SMSPortal  ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦22.08.16  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Tela inicial do portal.    								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function SMSPortal(cVendLogin)
Local cHtml
// Local cLink		:= "" 
// Local cPerUser	:= ""
// Local cEmissao	:= ""
// Local cPerDe	:= ""
// Local cPerAte	:= ""
// Local cAnoMes   := ""
Local cCodVend	:= ""
Local cDataDe	:= ""
Local cDataAte	:= ""
Local cFilFlt	:= ""
// Local aMeses	:= {}
Local aWidGet	:= {}                  
// Local nI
Local nW
Local cFiltDe   := dtoc(FirstDay(date()))
Local cFilAte   := dtoc(LastDay(date()))
Local cFilGrp   := "T"    // Filtro de grupo de produtos
Local cFilLimRes:= ""    // Filtro de limite de resultados
Local cFilImport:= " "   // Filtro de importadora
local nVendaTotal:= 0.00 // Venda total => passada do widget de vendas para o de metas
Private cColunas:= ""
Private cItens	:= ""     
Private cSite	:= "u_PortalLogin.apw"
Private cPagina	  := ""
Private cMenus	  := ""
Private cTitle	  := "Portal SMS"
Private cWidgets  := ""
Private cTopo	  := ""
Private cWgMeta	  := ""
Private cMVendas  := ""
Private	cVendaMes := ""
Private cSaldoVendedor := ""
Private cListVend := ""
Private cListaMaioresVendedores := ""
Private cListaComissao := ""
Private cListaInadimplentesFilial := ""
Private cCodLogin := ""
Private cMFiliais  := ""
Private cMEstados  := ""
Private cListaSaldo:= ""

default cVendLogin:= ""
Web Extended Init cHtml Start U_inSite(Empty(cVendLogin))
	// #ifDEF SMSDEBUG
	// 	conOut(Procname()+"("+ltrim(str(procline()))+") *** Portal ")
	// 	aInfo := HttpGet->aGets
	// 	For nI := 1 to len(aInfo)
	// 		conout('GET '+str(nI,3)+' = '+aInfo[nI]+' -> '+&("HTTPGET->"+aInfo[nI]))
	// 	Next
	// 	aInfo := HttpPost->aPost
	// 	For nI := 1 to len(aInfo)
	// 		conout('POST '+str(nI,3)+' = '+aInfo[nI]+' -> '+&("HTTPPOST->"+aInfo[nI]))
	// 	Next
	// #endif
	if Empty(cVendLogin)
		cVendLogin := u_GetUsrPR()
	endif
	
	cCodVend	:= cVendLogin
	cCodLogin 	:= U_SetParPR(cCodVend)

	// TODO - Pedro 20210208 - Remover???
	if Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL='+cSite+'">'	
		Return cHtml
	else
		if !Empty(HttpSession->Superv) .and. HttpSession->Superv <> HttpSession->CodVend
			HttpSession->CodVend:= HttpSession->Superv
		endif
	endif
		
	//cCodVend := HttpSession->CodVend
	
	// Pega do parâmetro com o Titulo do Portal
	cTitle	:= SuperGetMV("PS_TITLE", .T., "Portal SMS")
	
	// Define a funcao a ser chama no link
	cSite	:= Procname()+".apw?PR="+cCodLogin
	
	// Monta o cabeçalho para a pagina
//	cHeader := U_PSHeader(cTitle, cSite) 	
	
	//Função que atualiza os menus
	HttpSession->aMenu:= {}

	// ==== Tratamento para Diretor
	// Carrega o menu se for Diretor
	cMenus := u_GetMenus(AllTrim(Upper(Procname())), cCodVend,  HttpSession->Tipo)
	if HttpSession->Tipo <> "D"
		// cMenus := u_GetMenus(AllTrim(Upper(Procname())), cCodVend)

		// Recupera as rotinas que possuem WidGet
		aWidGet := HttpSession->aWidGet
	endif

 	// Rotina para montar os Widgets
	For nW := 1 To Len(aWidGet)
		// Verificar se a função do WidGet está compilado no PRO
		if ExistBlock(aWidGet[nW,3])
			// Executa a função do WidGet	
			aParam := aWidGet[nW]
			lGravou := ExecBlock(aWidGet[nW,3],.F.,.F.,aParam)
		endif
	Next
	
	/*
	if type("HttpPost->Periodo") <> "U"
		cPerUser:= HttpPost->Periodo
	endif
		
	//Calcula a quantidade de meses do período
	dDataDe:= date()- GetNewPar("AA_DIASDAS",180) //Qtd de dias para exibição do dashboard
	nMeses:= DateDiffMonth(dDataDe,date())+1
	
	For i:= 1 to nMeses
   		dMesAtu:= MonthSub(Date(),i-1)
   		cMesAtu:= AnoMes(dMesAtu)
   		cDtIni:= dtoc(FirstDay(dMesAtu))
   		cDtFim:= Iif(i==1,dtoc(date()),dtoc(LastDay(dMesAtu)))
		aAdd(aMeses,{cDtIni+' à '+cDtFim,cMesAtu})
	Next 
	*/

	//Tratamento dos filtros
	if type("HttpPost->DataDe") <> "U"
		//Se vazio, usa as datas padrão para evitar erro na query
		if Empty(HttpPost->DataDe) .or. Empty(HttpPost->DataAte)
			cDataDe:= dtos(FirstDay(date()))
			cDataAte:= dtos(LastDay(date()))
		else
			cDataDe:= dtos(ctod(HttpPost->DataDe))
			cDataAte:= dtos(ctod(HttpPost->DataAte))
		endif
		//Atualiza as variáveis no valor do filtro
		cFiltDe:= dtoc(stod(cDataDe))
		cFilAte:= dtoc(stod(cDataAte))
		cFilFlt:= Iif(!Empty(HttpPost->FilFiltro),HttpPost->FilFiltro,"")
		if !Empty(HttpPost->FilGrupo)
			cFilGrp := HttpPost->FilGrupo
		endif
		if !Empty(HttpPost->FilLimite)
			cFilLimRes := HttpPost->FilLimite
		endif
		if !Empty(HttpPost->FilImport)
			cFilImport := HttpPost->FilImport
		endif
	else
		//Variáveis dos input dos filtros
		cFiltDe:= dtoc(FirstDay(date()))
		cFilAte:= dtoc(LastDay(date()))
		//Variáveis de filtro da query
		cDataDe:= dtos(FirstDay(date()))
		cDataAte:= dtos(LastDay(date()))
	endif
	

	//Filtro período
	cTopo := wgFrmTopo(procname(), cCodLogin, cFiltDe, cFilAte, cCodvend, cFilFlt, cFilGrp, cFilLimRes, cFilImport)

	/*
	cWidGets+= '<ul class="simple-card-list mb-xlg">'
	cWidGets+= '	<li class="primary">'
	cWidGets+= '		<h3>488</h3>'
	cWidGets+= '		<p>Nullam quris ris.</p>'
	cWidGets+= '	</li>	
	cWidGets+= '</ul>' 
	  */
	  
	//WidGet Ticket Médio
	//cEmissao:= Iif(Empty(cPerUser),AnoMes(date()),cPerUser)
	cWidgets += wgVendas(cFilFlt, cCodVend, cDataDe, cDataAte, cFilGrp, @nVendaTotal, cFilImport)

	
	//WidGet Meta
	cWgMeta := wgMeta(cCodVend, cDataDe, cDataAte, nVendaTotal)

	//WidGet Mais Vendidos
	cMVendas := wgTopProd(cFilFlt, cCodVend, cDataDe, cDataAte, cFilGrp, cFilLimRes, cFilImport)

	//Vendas Mês a Mês
	cVendaMes := wgMesAMes(cFilFlt, cCodVend, cDataDe, cDataAte, cFilGrp, cFilImport)

	//Lista de Vendas por Vendedor - Acesso do Supervisor
	// cListVend := wgTopVend(cFilFlt, cCodVend, cDataDe, cDataAte, cFilGrp, cFilLimRes, lPneus, cFilImport)

	//Lista de Vendas por Vendedor Sem Categoria- Acesso do Supervisor
	// cListaMaioresVendedores := wgTopVendSemCategoria(cFilFlt, cCodVend, cDataDe, cDataAte, cFilGrp, cFilLimRes, cFilImport)

	//Lista de Comissões Por Ranking - Acesso do Diretor
	// cListaComissao := wgTopComissao(cFilFlt, cCodVend, cDataDe, cDataAte, cFilGrp, cFilLimRes, lPneus, cFilImport)

	//LISTA DE INADIMPLENTES POR RANKING DE VALOR E POR FILIAL * SOMENTE SUPERVISOR,GERENTE E DIRETOR
	// cListaInadimplentesFilial := wgTopInadimplentes(cFilFlt, cCodVend, cDataDe, cDataAte, cFilGrp, cFilLimRes, cFilImport)

	//maiores filiais
	// cMFiliais := wgTopFiliais(cFilFlt, cCodVend, cDataDe, cDataAte, cFilGrp, cFilLimRes, cFilImport)

	//maiores estados
	// cMEstados := wgTopEstados(cFilFlt, cCodVend, cDataDe, cDataAte, cFilGrp, cFilLimRes, cFilImport)

	//Retorna o HTML para construção da página 
	cHtml := H_SMSPortal()
		
Web Extended End

Return (cHTML)  

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ WidGetPC      ¦ Autor ¦ Anderson Zelenski ¦ Data ¦14.08.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ PE para gerar o WidGet de Pedido de Compra para o Portal   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function GetWdGet(nTipo, aParWid)
Local cWidget := ""

	if nTipo == 1
		cWidget += '<div class="col-md-12 col-lg-6 col-xl-6">'
		cWidget += '<section class="panel panel-featured-left panel-featured-primary">'
		cWidget += 	'<div class="panel-body">'
		cWidget += 		'<div class="widget-summary">'
		cWidget += 			'<div class="widget-summary-col widget-summary-col-icon">'
		cWidget += 				'<div class="summary-icon bg-primary">'
		cWidget +=					'<i class="'+aParWid[1]+'"></i>'
		cWidget += 				'</div>'
		cWidget += 			'</div>'
		cWidget += 			'<div class="widget-summary-col">'
		cWidget += 				'<div class="summary">'
		cWidget += 					'<h4 class="title">'+aParWid[3]+'</h4>'
		cWidget += 					'<div class="info">'
		cWidget += 						'<strong class="amount" style="font-size: larger">'+aParWid[2]+'</strong>'
		cWidget += 						'<br>'
		cWidget += 						'<span class="text-primary">'+aParWid[4]+'</span><br>'
		cWidget += 						'<span class="text-primary">'+aParWid[5]+'</span>'
		cWidget += 					'</div>'
		cWidget += 				'</div>'
		/*
		cWidget += 				'<div class="summary-footer">'
		cWidget += 					'<a href="'+aParWid[5]+'" class="text-muted text-uppercase">(Visualizar)</a>'
		cWidget += 				'</div>'
		*/
		cWidget += 			'</div>'
		cWidget += 		'</div>'
		cWidget += 	'</div>'
		cWidget += '</section>'
		cWidget += '</div>'
	endif

Return cWidGet


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ NoAcMI        ¦ Autor ¦ Anderson Zelenski ¦ Data ¦23.08.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Função para tratar caracteres acentuados                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function NoAcMI(cString)
	Local cChar  := ""
	Local nX     := 0
	Local nY     := 0
	Local cVogal := "aeiouAEIOU"
	Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
	Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
	Local cTrema := "äëïöü"+"ÄËÏÖÜ"
	Local cCrase := "àèìòù"+"ÀÈÌÒÙ"
	Local cTio   := "ãõ"
	Local cCecid := "çÇ"
	Local cMaior := "&lt;"
	Local cMenor := "&gt;"

	For nX:= 1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		if cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
			nY:= At(cChar,cAgudo)
			if nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			endif
			nY:= At(cChar,cCircu)
			if nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			endif
			nY:= At(cChar,cTrema)
			if nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			endif
			nY:= At(cChar,cCrase)
			if nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			endif
			nY:= At(cChar,cTio)
			if nY > 0
				cString := StrTran(cString,cChar,SubStr("ao",nY,1))
			endif
			nY:= At(cChar,cCecid)
			if nY > 0
				cString := StrTran(cString,cChar,SubStr("cC",nY,1))
			endif
		endif
	Next

	if cMaior$ cString
		cString := strTran( cString, cMaior, "" )
	endif
	if cMenor$ cString
		cString := strTran( cString, cMenor, "" )
	endif

	For nX:=1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		if Asc(cChar) < 32 .Or. Asc(cChar) > 123
			cString:=StrTran(cString,cChar,".")
		endif
	Next nX
Return cString
 
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ UniGrCom      ¦ Autor ¦ Pedro de Souza ¦ Data 13.03.18     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Retorna um array com grupos de compra                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
user function UniGrCom()
	Local cQryTracke
	Local cAlTmp := GetNextAlias()
	Local aRet  := {{"000000","TODOS"}}
	Local aArea := GetArea()
	Local lComprador := HttpSession->Perfil = "Comprador"
	
	if lComprador
		aRet  := {}
	endif
	
	cQryTracke := " select distinct aj_grcom, aj_desc "
	cQryTracke += " FROM "+RetSqlName("SAJ")+" SAJ "
	cQryTracke += " WHERE SAJ.AJ_FILIAL = '" + xFilial('SAJ') + "' "
	cQryTracke +=   " AND SAJ.D_E_L_E_T_ = ' ' "
	if lComprador //Se for comprador, permite ver apenas os grupos que tem acesso
	 	cQryTracke +=   " AND SAJ.AJ_USER = "+HttpSession->UserId
	endif
	cQryTracke += " ORDER BY 1 "
	
	APWExOpenQuery(ChangeQuery(cQryTracke),cAlTmp,.T.)
	
	While !(cAlTmp)->(EOF())
		aadd(aRet, { (cAlTmp)->aj_grcom, trim((cAlTmp)->aj_desc) }) 
		(cAlTmp)->(dbSkip())
	EndDo
	
	(cAlTmp)->(dbCloseArea())
	RestArea(aArea)
return aRet

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ wgFrmTopo       ¦ Autor ¦ Pedro de Souza ¦ Data 15.09.2021 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Monta o formulario ao topo da tela                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
static function wgFrmTopo(cNomeForm, cCodLogin, cFiltDe, cFilAte, cCodvend, cFilFlt, cFilGrp, cFilLimRes, cFilImport)
	local cTopo := ""
	cTopo:= '<div class="row form-group">'
	cTopo+= '	<div class="col-sm-12">'
	cTopo+= '	<form name="formGrid" id="formGrid" method="POST" action="'+cNomeForm+'.apw?PR='+cCodLogin+'">'
	
	cTopo+= '		<label class="col-md-1 control-label">De:</label>'
	cTopo+= '		<div class="col-md-3">'
	cTopo+= '		 	<div class="input-group">'
	cTopo+= '				<span class="input-group-addon">'
	cTopo+= '					<i class="fa fa-calendar"></i>'
	cTopo+= '				</span>'   
	cTopo+= '				<input data-plugin-datepicker="" data-plugin-options='+"'"+'{"autoclose": "true", "language": "pt-BR",'
	cTopo+= '					"daysOfWeekDisabled": "","daysOfWeekHighlighted":"[0]"}'+"'"+' value="'+cFiltDe+'" ' 
	cTopo+= '					placeholder="__/__/____" id="datade" name="datade" class="form-control only-numbers" type="text"></input>'
	cTopo+= '			</div>'
	cTopo+= '		</div>'
  
	cTopo+= '		<label class="col-md-1 control-label">Até:</label>'
	cTopo+= '		<div class="col-md-3">'
	cTopo+= '			<div class="input-group">'
	cTopo+= '				<span class="input-group-addon">'
	cTopo+= '					<i class="fa fa-calendar"></i>'
	cTopo+= '				</span>'   
	cTopo+= '				<input data-plugin-datepicker="" data-plugin-options='+"'"+'{"autoclose": "true", "language": "pt-BR",'
	cTopo+= '					"daysOfWeekDisabled": "","daysOfWeekHighlighted":"[0]"}'+"'"+' value="'+cFilAte+'" '
	cTopo+= '					placeholder="__/__/____" id="dataate" name="dataate" class="form-control only-numbers" type="text"></input>'
	cTopo+= '			</div>'
	cTopo+= '		</div>'

	// cTopo+= '		<label class="col-md-1 control-label">Filial:</label>'
	// cTopo+= '		<div class="col-md-5">'
	// cTopo+= '			<select data-plugin-selectTwo class="form-control populate mb-md" name="FILFILTRO" id="FILFILTRO" '
	// cTopo+= '			required="" aria-required="true">'
	// cTopo+= '				<option value=" ">Todas</option>'
	// if HttpSession->Tipo == "D" .or. cCodvend $ GetMv("AA_PRFILGR",,"")
	// 	// Monta a lista de filiais para os diretores
	// 	cTopo+= fFilDir(cCodvend,cFilFlt)
	// else
	// 	cTopo+= u_fFilVend(cCodvend,cFilFlt)
	// endif
	// cTopo+= '			</select>'
	// cTopo+= '		</div>'
	/*
	cTopo+= '		<div class="col-md-3">'
	cTopo+= '			<select data-plugin-selectTwo class="form-control populate mb-md" name="PERIODO" id="PERIODO" '
	cTopo+= '			required="" aria-required="true">'
	For y:= 1 to Len(aMeses)
		if !Empty(cPerUser) .and. aMeses[y,2] == cPerUser
			cTopo+= '				<option value="'+aMeses[y,2]+'" selected>'+aMeses[y,1]+'</option>'
		else	
			cTopo+= '				<option value="'+aMeses[y,2]+'">'+aMeses[y,1]+'</option>'
		endif
	Next	

	cTopo+= '			</select>'
	cTopo+= '		</div>'	
	*/
	cTopo+= '		<div class="col-sm-2">'
	cTopo+= '			<button class="btn btn-primary" id="btFiltroD" value="" onclick="this.value= '+"'"+'Aguarde...'+"'"+';this.disabled= '+"'"+'disabled'+"'"+';Filtro()" name="btFiltro">'
	cTopo+= '			<i class="fa fa-refresh"></i> Atualizar</button>' 
	cTopo+= '		</div>'
	cTopo+= '	</form>'
	cTopo+= '	</div>'
	cTopo+= '</div>'
return cTopo

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ wgVendas      ¦ Autor ¦ Pedro de Souza    ¦ Data 15.09.21  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Retorna o Widget de vendas                                 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
static function wgVendas(cFilFlt, cCodVend, cDataDe, cDataAte, cFilGrp, nVendaTotal, cFilImport)
	local cRet := ""
	Local cVlrNfs	:= ""
	Local cQtdNfs	:= ""
	Local cVTicket	:= ""
	Local cITicket	:= ""
	local cQry
	local cMods:=""

	cQry:= " With VENDAS as ( " 
	cQry+= " Select ( SUM(D2_VALBRUT) - SUM(D2_ICMSRET) - SUM(D2_VALIPI) - SUM(CASE WHEN F2_TPFRETE = 'C' THEN F2_FRETE else 0 END ) ) AS F2_VALFAT, 1 AS NFS, F2_DOC "
	cQry+= " From "+RetSqlName("SF2")+" SF2 "
	cQry+= " INNER JOIN "+RetSqlName("SA1")+" SA1 "
	cQry+= " ON SF2.F2_FILIAL = SA1.A1_FILIAL AND F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = ' ' "
	cQry+= " INNER JOIN SD2010 SD2 ON SD2.D2_FILIAL = SF2.F2_FILIAL "
	cQry+= " AND F2_DOC = D2_DOC "
	cQry+= " AND F2_SERIE = D2_SERIE "
	cQry+= " AND SD2.D_E_L_E_T_ = ' ' "
	cQry+= " And F2_TIPO = 'N' "
	cQry+= " AND F2_VEND1 = '"+cCodVend+"' 
	cQry+= " And F2_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"' " 
	cQry+= " AND SF2.F2_VALFAT > 0"
	cQry+= " And SF2.D_E_L_E_T_ = ' '  GROUP BY F2_DOC ), "
	
	cQry+= " ITENS as ( "	
	cQry+= " Select D2_COD, 1 AS QTD, D2_QUANT "
	cQry+= " From "+RetSqlName("SD2")+" SD2 "
	cQry+= " Inner Join "+RetSqlName("SF2")+" SF2 ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE "
	cQry+= " And F2_TIPO = 'N' And F2_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"' And SF2.D_E_L_E_T_ = ' ' AND SF2.F2_VALFAT > 0"
	cQry+= " INNER JOIN "+RetSqlName("SA1")+" SA1 "
	cQry+= " ON F2_FILIAL = A1_FILIAL AND F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = ' ' "
	cQry+= " And SD2.D_E_L_E_T_ = ' '), "	

	cQry+= "TOTAL_ITENS as (Select SUM(QTD) ITENS, SUM(D2_QUANT) AS SOMAQTD FROM ITENS),"
	cQry+= "TOTAL_VENDAS as (Select SUM(F2_VALFAT) VALOR, SUM(NFS) AS NOTAS FROM VENDAS) "

	cQry+= "Select TOTAL_VENDAS.VALOR, TOTAL_VENDAS.NOTAS, TOTAL_ITENS.ITENS, TOTAL_ITENS.SOMAQTD "
	cQry+= " FROM TOTAL_VENDAS, TOTAL_ITENS "
	
	if Select("QTM") > 0
		QTM->(dbCloseArea())
	endif	
	APWExOpenQuery(cQry,'QTM',.T.) 

	if select("QTM") <> 0
		cVTicket:= Iif(QTM->NOTAS > 0,Transform(QTM->VALOR / QTM->NOTAS,PesqPict("SF2","F2_VALFAT")),"0,00")
		cITicket:= Iif(QTM->NOTAS > 0,cValtoChar(Int(QTM->ITENS / QTM->NOTAS)),"0") 
		
		cRet += U_GetWdGet(1, {"fa fa-dashboard", "R$ "+cVTicket, "Ticket Médio", " por pedido. "	,"", "60", "55"})

		//WidGet Pedidos Realizados
		cVlrNfs:= Iif(QTM->VALOR > 0,Transform(QTM->VALOR,PesqPict("SF2","F2_VALFAT")),"0,00")
		cQtdNfs:= Iif(QTM->NOTAS > 0,cValtoChar(QTM->NOTAS),"0") 
		cRet += U_GetWdGet(1, {"fa fa-shopping-basket", "R$ "+cVlrNfs, "Pedidos Realizados", cQtdNfs+Iif(QTM->NOTAS > 1," pedidos"," pedido")+;
			", "+Alltrim(transform(QTM->ITENS,"@e 999,999"))+" itens, ",Alltrim(transform(QTM->SOMAQTD,"@e 9,999,999"))+" unid.", "50", "50"})
		nVendaTotal := QTM->VALOR
		QTM->(dbCloseArea())
	endif
	
return cRet

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ wgMeta            ¦ Autor ¦ Pedro de Souza ¦ Data 15.09.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Retorna os Widget de metas                                 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
static function wgMeta(cCodVend, cDataDe, cDataAte, nVendaTotal)
	local cQry
	local cAtingido := ""
	local cFalta    := ""
	local cRet      := ""
	local nMeta
	local cMeta

	if HttpSession->Tipo <> 'D' // Visao do diretor nao tem meta
		//Variáveis para o quadro de meta
		cQry:= "Select SUM(CT_VALOR) VALOR "
		cQry+= " From "+RetSqlName("SCT")+" SCT "
		cQry+= " Where "
		cQry+= " CT_DATA between '"+Left(cDataDe,6)+'01'+"' and '"+Left(cDataAte,6)+'01'+"' "
		cQry+= " and CT_VEND = '"+cCodVend+"' "
		cQry+= " And SCT.D_E_L_E_T_ = ' ' "

		if Select("QRM") > 0
			QRM->(dbCloseArea())
		endif
		APWExOpenQuery(cQry,'QRM',.T.) 

		nMeta:= QRM->VALOR

		cAtingido:= cValtoChar(Int((nVendaTotal/nMeta) * 100))+ "%"
		cFalta:= cValtoChar(Iif(100 - val(cAtingido) < 0,0,100 - val(cAtingido)))+"%" 
		cMeta:= Transform(nMeta,PesqPict("SCT","CT_VALOR"))	

		cRet:= '	<!-- META -->'
		cRet+= '	<div class="text-center panel-body ">'
		cRet+= '		<h2 class="panel-title">Meta de Venda</h2>'
		cRet+= '		<h2 class="panel-title mt-sm">R$ '+cMeta+'</h2>'
		cRet+= '		<div class="liquid-meter-wrapper liquid-meter-sm mt-sm">'
		cRet+= '			<div class="liquid-meter">'
		cRet+= '				<meter min="0" max="100" value="'+cAtingido+'" id="meterSales"></meter>'
		cRet+= '			</div>'
		cRet+= '			<div class="liquid-meter-selector" id="meterSalesSel">'
		cRet+= '				<a href="#" data-val="'+cAtingido+'" class="active">Atingido</a>'
		cRet+= '				<a href="#" data-val="'+cFalta+'">Falta</a>'
		cRet+= '			</div>'
		cRet+= '		</div>'
		cRet+= '	</div>'
	endif
return cRet

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ wgTopProd         ¦ Autor ¦ Pedro de Souza ¦ Data 15.09.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Retorna os Widget top x de produtos                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
static function wgTopProd(cFilFlt, cCodVend, cDataDe, cDataAte, cFilGrp, cFilLimRes, cFilImport)
	local cRet := ""
	local cQry := ""

	// Itens mais vendidos
	cQry:= "Select TOP 10 D2_COD,  B1_DESC, SUM(D2_QUANT) AS QTD "
	cQry+= "From "+RetSqlName("SD2")+" SD2 " 
	cQry+= "Inner Join "+RetSqlName("SF2")+" SF2 ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE " 
	cQry+= "And F2_TIPO = 'N' And F2_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"' And SF2.D_E_L_E_T_ = ' ' "
	If HttpSession->Tipo = 'S' //Supervisor acessa informações da sua equipe
		If !Empty(cVndFlt)
			cQry+= "		AND F2_VEND1 = '"+cVndFlt+"' "
		Else	
			cQry+= "		AND F2_VEND1 in "+FormatIn(HttpSession->Equipe,"|")+" "
		Endif
	Else 
		cQry+= "		AND F2_VEND1 = '"+cCodVend+"' 
	Endif    
    cQry+= "    Inner Join "+RetSqlName("SB1")+" SB1 ON B1_FILIAL =  SUBSTRING(D2_FILIAL,1,4) AND B1_COD = D2_COD AND  SB1.D_E_L_E_T_ = ' ' "
	cQry+= "	Where D2_FILIAL  <> '' "
	cQry+= "And SD2.D_E_L_E_T_ = ' ' "
	cQry+= "Group by D2_COD, B1_DESC "
	cQry+= "Order by SUM(D2_QUANT) DESC "
	conout("Qry top vendas --->> "+cqry)
	If Select("QTV") > 0
		QTV->(dbCloseArea())
	Endif	
    APWExOpenQuery(cQry,'QTV',.T.)

	While QTV->(!Eof())
		cRet+= '<li>'
		cRet+= '	<figure class="image rounded">'
		cRet+= '	<img src="/images/prod.jpg" alt="" class="img-circle">'
		cRet+= '	</figure>'
		cRet+= '	<div class="profile-info">'
		cRet+= '		<span class="title">'+QTV->B1_DESC+'</span>'
		cRet+= '		<span class="message truncate">'+cvaltochar(QTV->QTD)+Iif(QTV->QTD > 1,' itens vendidos',' item vendido')+'</span>'
		cRet+= '	</div>'
		cRet+= '</li>'
	    QTV->(dbSkip())
	End
	QTV->(dbCloseArea())
return cRet

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ wgMesAMes         ¦ Autor ¦ Pedro de Souza ¦ Data 15.09.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Retorna o Widget mes a mes                                 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
static function wgMesAMes(cFilFlt, cCodVend, cDataDe, cDataAte, cFilGrp, cFilImport)
	local cRet := ""
	local cLista := ""
	local cQry
	local cPerDe
	local cPerAte
	local cAnoMes
	cPerDe:= dtos(MonthSub(stod(cDataDe+'01'),5))
	cPerAte:= dtos(LastDay(stod(cDataDe+'01')))

	cQry:= " Select SUM( D2_VALBRUT - D2_ICMSRET - D2_VALIPI - CASE WHEN F2_TPFRETE = 'C' THEN F2_FRETE else 0 END) VALOR, substring(F2_EMISSAO,1,6) PERIODO " 
	cQry+= " From "+RetSqlName("SF2")+" SF2 "
	cQry+= " INNER JOIN SD2010 SD2 ON SD2.D2_FILIAL = SF2.F2_FILIAL "
	cQry+= " AND F2_DOC = D2_DOC "
	cQry+= " AND F2_SERIE = D2_SERIE "
	cQry+= " AND SD2.D_E_L_E_T_ = ' '  "
	cQry+= " INNER JOIN "+RetSqlName("SA1")+" SA1 "
	cQry+= " ON A1_COD = F2_CLIENTE AND F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = ' ' AND SF2.F2_FILIAL = SA1.A1_FILIAL "
	cQry+= " And F2_TIPO = 'N' And SF2.F2_VALFAT > 0 "
	cQry+= " AND F2_VEND1 = '"+cCodVend+"' 
	cQry+= " And F2_EMISSAO between '"+cPerDe+"' and '"+cPerAte+"' "
	cQry+= " And SF2.D_E_L_E_T_ = ' ' " 
	cQry+= " Group by substring(F2_EMISSAO,1,6)" 
	cQry+= " Order by substring(F2_EMISSAO,1,6)" 
	
	if Select("QMM") > 0
		QMM->(dbCloseArea())
	endif	
	APWExOpenQuery(cQry,'QMM',.T.)
	
	While QMM->(!Eof())
		cAnoMes:= Substr(MesExtenso(stod(QMM->PERIODO+'01')),1,3) +'/'+ Right(cValtochar(Year(stod(QMM->PERIODO+'01'))),2)
	   	cLista+= '["'+cAnoMes+'", '+cvaltochar(Int(QMM->VALOR / 1000))+'],'
	   	QMM->(dbSkip())
	End
	QMM->(dbCloseArea())
	//Remove a última vírgula
	cLista:= Substr(cLista,1,Len(alltrim(cLista))-1)

	cRet +='<section class="panel">'
	cRet +='	<header class="panel-heading">'
	cRet +='		<h2 class="panel-title">'
	cRet +='			<span class="va-middle">Vendas Mês a Mês (x R$1.000,00)</span>'
	cRet +='		</h2>'
	cRet +='	</header>'
	cRet +='	<div class="panel-body">'
	cRet +='		<div class="chart-data-selector" id="salesSelectorWrapper">'
	cRet +='			<div id="salesSelectorItems" class="chart-data-selector-items mt-sm">'
	cRet +='				<!-- Flot: Sales Porto Admin -->'
	cRet +='				<div class="chart chart-sm" data-sales-rel="Porto Admin" id="flotDashSales1" class="chart-active"></div>'
	cRet +='				<script>'
	cRet +='					var flotDashSales1Data = [{'
	cRet +='						data: [ '+cLista+' ],'
	cRet +='						color: "#0088cc"'
	cRet +='					}];'
	cRet +='				</script>'
	cRet +='			</div>'
	cRet +='		</div>'
	cRet +='	</div>'
	cRet +='</section>'
return cRet

/*_________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ wgTopVendSemCategoria ¦ Autor ¦ Ewerton Vinicius ¦ Data 25.10.24 ¦¦¦
¦¦+----------+------------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Retorna os Widget top x de produtos                              ¦¦¦
¦¦+-----------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯------*/
static function wgTopVendSemCategoria(cFilFlt, cCodVend, cDataDe, cDataAte, cFilGrp, cFilLimRes, cFilImport)
	local cRet := ""
	local cQry
	local cLista
	local nLimDado := 10
	local nCntLin  := 0

	//Lista de Vendas por Vendedor - Acesso do Supervisor e Diretor
	if HttpSession->Tipo $ 'SD'
	 
		if !Empty(cFilLimRes) // Visao do diretor
			nLimDado := val(cFilLimRes)
		endif
		cQry:= "Select TOP("+cvaltochar(nLimDado)+") SUM( D2_VALBRUT - D2_ICMSRET - D2_VALIPI - CASE WHEN F2_TPFRETE = 'C' THEN F2_FRETE else 0 END) VALOR, F2_VEND1 VENDEDOR, A3_NOME NOME "
		cQry+= "From "+RetSqlName("SF2")+" SF2 "
		cQry+= " INNER JOIN SD2010 SD2 ON SD2.D2_FILIAL = SF2.F2_FILIAL "
		cQry+= " AND F2_DOC = D2_DOC "
		cQry+= " AND F2_SERIE = D2_SERIE "
		cQry+= " AND SD2.D_E_L_E_T_ = ' '  "

		 if HttpSession->Tipo = 'D' .or. cFilGrp <> 'T'// Visao do diretor
		 	if cFilGrp <> 'T'
				cQry+= " INNER JOIN "+RetSqlName("SBM")+" SBM ON SBM.BM_GRUPO = SD2.D2_GRUPO AND SBM.D_E_L_E_T_ = ' ' "
		 	endif
		 endif

		if HttpSession->Tipo = 'S'  //Supervisor acessa informações da sua equipe
			cQry+= " INNER JOIN "+RetSqlName("ZDV")+" ZDV "
			cQry+=  " ON SF2.F2_FILIAL = ZDV.ZDV_FILIAL AND ZDV_TABELA = 'SF2' AND F2_DOC+F2_SERIE = ZDV_CODERP AND ZDV.D_E_L_E_T_ = ' ' AND ZDV.ZDV_CODVEN = '"+cCodVend+"'"
		endif
		
		cQry+= "Inner Join "+RetSqlName("SA3")+" SA3 ON A3_FILIAL = '"+xFilial("SA3")+"' and A3_COD = F2_VEND1 AND SA3.D_E_L_E_T_ = ' ' "
		cQry+= " INNER JOIN "+RetSqlName("SA1")+" SA1 "
		cQry+=  " ON SA1.A1_FILIAL = F2_FILIAL AND F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA AND SA1.A1_GRPAUTO <> '1' AND SA1.D_E_L_E_T_ = ' ' "
		
		if !Empty(cFilFlt)
			cQry+= "	Where F2_FILIAL  = '"+cFilFlt+"' "
		else
			if !Empty(cFilImport)
				cQry+= " INNER JOIN "+RetSqlName("ZC2")+" ZC2 "
				cQry+=  " ON SF2.F2_FILIAL = ZC2.ZC2_FILVEN AND ZC2_FILIMP = '" + cFilImport + "' AND ZC2.D_E_L_E_T_ = ' ' "
			endif
			cQry+= "	Where F2_FILIAL  <> ' ' "
		endif

		cQry+= "And F2_TIPO = 'N' And SF2.F2_VALFAT > 0 "
		if HttpSession->Tipo = 'D' .or. cFilGrp <> 'T' // Visao do diretor
			if cFilGrp <> 'T'
				cQry+= " AND SBM.BM_XPRDVE = '"+cFilGrp+"' "
			endif
		endif
		cQry+= "And F2_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"' "
		cQry+= "And SF2.D_E_L_E_T_ = ' ' " 
		cQry+= "Group by F2_VEND1, A3_NOME "
		cQry+= "Order by SUM( D2_VALBRUT - D2_ICMSRET - D2_VALIPI - CASE WHEN F2_TPFRETE = 'C' THEN F2_FRETE else 0 END) DESC " 
		
		if Select("QVV") > 0
			QVV->(dbCloseArea())
		endif
		APWExOpenQuery(cQry,'QVV',.T.)
		
		cLista:= ""
		While QVV->(!Eof())
			 nCntLin++
			 cLista+= '<li>'
			 cLista+= '	<div class="row show-grid">'
			 cLista+= '		<div class="col-md-8"><span class="text">'+QVV->VENDEDOR+"-"+QVV->NOME+'</span></div>'
			 cLista+= '		<div class="col-md-3" align="right"><span class="text-primary">R$'+Transform(QVV->VALOR,PesqPict("SF2","F2_VALFAT"))+'</span></div>'
			 cLista+= '	</div>'
			 cLista+= '</li>'
			 if HttpSession->Tipo = 'D' .and. nCntLin = nLimDado
			 	exit
			 endif
			 QVV->(dbSkip())

			End

		cRet += '<section class="panel">'
		cRet += '	<header class="panel-heading">'
		cRet += '		<h2 class="panel-title">'
		cRet += '			<span class="va-middle">Maiores Vendedores</span>'
		cRet += '		</h2>'
		cRet += '	</header>'
		cRet += '	<div class="panel-body">'
		cRet += '		<div class="content">'
		cRet += '			<ul class="simple-user-list">'
		cRet +=					cLista
		cRet += '			</ul>'
		cRet += '		</div>'
		cRet += '	</div>'
		cRet += '</section>'
	endif
return cRet

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ wgTopVend         ¦ Autor ¦ Pedro de Souza ¦ Data 15.09.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Retorna os Widget top x de produtos                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
static function wgTopVend(cFilFlt, cCodVend, cDataDe, cDataAte, cFilGrp, cFilLimRes, lPneus, cFilImport)
	local cRet := ""
	local cQry
	local cLista
	local nLimDado := 10
	// local nCntLin  := 0
	local cCabTabs := ""
	local cDetTabs := ""
	local nIndGrp  := 1
	//Lista de Vendas por Vendedor - Acesso do Supervisor e Diretor
	if HttpSession->Tipo $ 'SD'
	 
		if !Empty(cFilLimRes) // Visao do diretor
			nLimDado := val(cFilLimRes)
		endif

		cQry:= "WITH QRYTOP AS ( Select SUM( D2_VALBRUT - D2_ICMSRET - D2_VALIPI - CASE WHEN F2_TPFRETE = 'C' THEN F2_FRETE else 0 END) AS VALOR, F2_VEND1 VENDEDOR, A3_NOME NOME, BM_XGRPPOR, " 
		cQry+= " ROW_NUMBER() OVER (PARTITION BY BM_XGRPPOR ORDER BY SUM(D2_VALBRUT - D2_ICMSRET - D2_VALIPI - CASE WHEN F2_TPFRETE = 'C' THEN F2_FRETE ELSE 0 END) DESC) AS POSICAO "
		cQry+= "From "+RetSqlName("SF2")+" SF2 "
		cQry+= " INNER JOIN SD2010 SD2 ON SD2.D2_FILIAL = SF2.F2_FILIAL "
		cQry+= " AND F2_DOC = D2_DOC "
		cQry+= " AND F2_SERIE = D2_SERIE "
		cQry+= " AND SD2.D_E_L_E_T_ = ' '  "

		// if HttpSession->Tipo = 'D' .or. cFilGrp <> 'T'// Visao do diretor
		// 	if cFilGrp <> 'T'
		cQry+= " INNER JOIN "+RetSqlName("SBM")+" SBM ON SBM.BM_GRUPO = SD2.D2_GRUPO AND SBM.D_E_L_E_T_ = ' ' "
		// 	endif
		// endif

		if HttpSession->Tipo = 'S'  //Supervisor acessa informações da sua equipe
			cQry+= " INNER JOIN "+RetSqlName("ZDV")+" ZDV "
			cQry+=  " ON SF2.F2_FILIAL = ZDV.ZDV_FILIAL AND ZDV_TABELA = 'SF2' AND F2_DOC+F2_SERIE = ZDV_CODERP AND ZDV.D_E_L_E_T_ = ' ' AND ZDV.ZDV_CODVEN = '"+cCodVend+"'"
		endif
		
		cQry+= "Inner Join "+RetSqlName("SA3")+" SA3 ON A3_FILIAL = '"+xFilial("SA3")+"' and A3_COD = F2_VEND1 AND SA3.D_E_L_E_T_ = ' ' "
		cQry+= " INNER JOIN "+RetSqlName("SA1")+" SA1 "
		cQry+=  " ON SA1.A1_FILIAL = F2_FILIAL AND F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA AND SA1.A1_GRPAUTO <> '1' AND SA1.D_E_L_E_T_ = ' ' "
		
		if !Empty(cFilFlt)
			cQry+= "	Where F2_FILIAL  = '"+cFilFlt+"' "
		else
			if !Empty(cFilImport)
				cQry+= " INNER JOIN "+RetSqlName("ZC2")+" ZC2 "
				cQry+=  " ON SF2.F2_FILIAL = ZC2.ZC2_FILVEN AND ZC2_FILIMP = '" + cFilImport + "' AND ZC2.D_E_L_E_T_ = ' ' "
			endif
			cQry+= "	Where F2_FILIAL  <> ' ' "
		endif

		cQry+= "And F2_TIPO = 'N' And SF2.F2_VALFAT > 0 "
		if HttpSession->Tipo = 'D' .or. cFilGrp <> 'T' // Visao do diretor
			if cFilGrp <> 'T'
				cQry+= " AND SBM.BM_XPRDVE = '"+cFilGrp+"' "
			endif
		endif
		cQry+= "And F2_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"' "
		cQry+= "And SF2.D_E_L_E_T_ = ' ' " 
		cQry+= "Group by F2_VEND1, A3_NOME, BM_XGRPPOR ) " 
		// cQry+= "Order by BM_XGRPPOR , SUM( D2_VALBRUT - D2_ICMSRET - D2_VALIPI - CASE WHEN F2_TPFRETE = 'C' THEN F2_FRETE else 0 END) DESC " 
		cQry+= " SELECT * FROM QRYTOP WHERE POSICAO <= '"+cvaltochar(nLimDado)+"' ORDER BY BM_XGRPPOR, VALOR DESC " 
		
		if Select("QVV") > 0
			QVV->(dbCloseArea())
		endif
		APWExOpenQuery(cQry,'QVV',.T.)
		
		cLista:= ""
		While QVV->(!Eof())
			// nCntLin++
			// cLista+= '<li>'
			// cLista+= '	<div class="row show-grid">'
			// cLista+= '		<div class="col-md-8"><span class="text">'+QVV->VENDEDOR+"-"+QVV->NOME+'</span></div>'
			// cLista+= '		<div class="col-md-3" align="right"><span class="text-primary">R$'+Transform(QVV->VALOR,PesqPict("SF2","F2_VALFAT"))+'</span></div>'
			// cLista+= '	</div>'
			// cLista+= '</li>'
			// if HttpSession->Tipo = 'D' .and. nCntLin = nLimDado
			// 	exit
			// endif
			// QVV->(dbSkip())
			cGrpProd := QVV->BM_XGRPPOR
			cCabTabs+= '<li' + iif(Empty(cCabTabs),' class="active"','') + '>'
			cCabTabs+= '<a href="#tbVend' + cValToChar(nIndGrp) + '" data-toggle="tab"></i>' + iif(Empty(QVV->BM_XGRPPOR), "OUTROS", trim(QVV->BM_XGRPPOR)) + '</a>'
			cCabTabs+= '</li>' + CRLF
			cDetTabs +='<div id="tbVend' + cValToChar(nIndGrp++) + '" class="tab-pane ' + iif(Empty(cDetTabs),' active','') + '">'
			While QVV->(!Eof()) .and. QVV->BM_XGRPPOR == cGrpProd
				cDetTabs+= '<li>' + CRLF
				cDetTabs+= '	<figure class="image rounded">'
				if lPneus
					cDetTabs+= '	<img src="assets/images/pneu.jpg" alt="pneu" class="img-circle">'
				else
					cDetTabs+= '	<img src="assets/images/auto.jpg" alt="autoamerica" class="img-circle">'
				endif
				cDetTabs+= '	</figure>'
				cDetTabs+= '	<div class="profile-info">'
				cDetTabs+= '		<span class="title">'+QVV->VENDEDOR+" - "+QVV->NOME+'</span>'
				// cDetTabs+= '		<span class="message truncate">'+cvaltochar(QVV->QTD)+Iif(QVV->QTD > 1,' itens vendidos',' item vendido')
				cDetTabs+= '&nbsp; valor R$ '+ltrim(transform(QVV->VALOR, "@e 9,999,999.99"))+'</span>'
				cDetTabs+= '	</div>'
				cDetTabs+= '</li>' + CRLF
				QVV->(dbSkip())
			enddo
			cDetTabs +='</div>' + CRLF 
		End
		QVV->(dbCloseArea())

		cRet += '<section class="panel">'
		cRet += '	<header class="panel-heading">'
		cRet += '		<h2 class="panel-title">'
		cRet += '			<span class="va-middle">Maiores Vendedores Por Categoria</span>'
		cRet += '		</h2>'
		cRet += '	</header>'
		cRet += '	<div class="panel-body">'
		// cRet += '		<div class="content">'
		// cRet += '			<ul class="simple-user-list">'
		// cRet +=					cLista
		// cRet += '			</ul>'
		// cRet += '		</div>'
		cRet += '		<div class="content">'
		cRet += '			<ul class="simple-user-list">'
		cRet += '				<div class="tabs">'
		cRet += '					<ul class="nav nav-tabs">' + CRLF
		cRet += 						cCabTabs
		cRet += '					</ul>' + CRLF
		cRet += '					<div class="tab-content">'
		cRet += 						cDetTabs
		cRet += '					</div>'
		cRet += 				'</div>'
		cRet += '			</ul>'
		cRet += '		</div>'
		cRet += '	</div>'
		cRet += '</section>'
	endif
return cRet

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ wgTopComissao ¦ Autor ¦ Matheus Bientinezi ¦ Data 17.07.24 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Retorna os Widget de Vendedores por Ranking de Comissão    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
static function wgTopComissao(cFilFlt, cCodVend, cDataDe, cDataAte,cFilGrp, cFilLimRes, lPneus, cFilImport)
	local cRet := ''
	local cQry
	local cLista
	local nLimDado := 10
	local nCntLin  := 0
	//Lista de Vendas por Vendedor - Acesso do Supervisor e Diretor
	if HttpSession->Tipo $ 'D'
	 
		if !Empty(cFilLimRes) // Visao do diretor
			nLimDado := val(cFilLimRes)
		endif
		
		cQry := " Select TOP("+cvaltochar(nLimDado)+") E3_VEND, A3_NOME, FORMAT(SUM(E3_COMIS), 'C', 'pt-br') AS VALOR "
		cQry += " FROM "+RetSqlName("SE3")+" SE3 "
		cQry += " INNER JOIN "+ RetSqlName("SA1")+" SA1 ON A1_FILIAL = E3_FILIAL And A1_COD = E3_CODCLI "
		cQry += " AND A1_LOJA = E3_LOJA And SA1.D_E_L_E_T_= ' ' "
		cQry += " INNER JOIN SA3010 SA3 ON A3_COD = E3_VEND AND SA3.D_E_L_E_T_ = '' "
		cQry += " LEFT JOIN "+ RetSqlName("SE1")+" SE1 ON E1_FILIAL = E3_FILIAL and E1_PREFIXO = E3_PREFIXO and E1_NUM = E3_NUM "
		cQry += " AND E1_PARCELA = E3_PARCELA and E1_TIPO = E3_TIPO and SE1.D_E_L_E_T_ = ' ' "
		cQry += " WHERE SE3.D_E_L_E_T_ = ' ' ""
		cQry += " AND E3_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"' "
		if !Empty(cFilFlt)
			cQry+= "	AND E3_FILIAL  = '"+cFilFlt+"' "
		endif
		if cFilGrp == '1'
			cQry += " AND A3_XPRDVEN = '1' "
		else
			cQry += " AND A3_XPRDVEN <> '1' "
		endif
		cQry += " GROUP BY E3_VEND, A3_NOME "
		cQry += " ORDER BY SUM(E3_COMIS) DESC "

		if Select("QVV") > 0
			QVV->(dbCloseArea())
		endif	
		APWExOpenQuery(cQry,'QVV',.T.)
		
		cLista:= ""
		While QVV->(!Eof())
			nCntLin++
			cLista+= '<li>'
			cLista+= '	<div class="row show-grid">'
			cLista+= '		<div class="col-md-8"><span class="text">'+QVV->E3_VEND+' - '+trim(QVV->A3_NOME)+'</span></div>'
			cLista+= '		<div class="col-md-3" align="right"><span class="text-primary">'+ltrim(TransForm(QVV->VALOR,"@E 999,999,999.99"))+'</span></div>' 
			cLista+= '	</div>'
			cLista+= '</li>'
			if HttpSession->Tipo = 'D' .and. nCntLin = nLimDado
				exit
			endif
			QVV->(dbSkip())
		End
		QVV->(dbCloseArea())	

		cRet += '<section class="panel">'
		cRet += '	<header class="panel-heading">'
		cRet += '		<h2 class="panel-title">'
		cRet += '			<span class="va-middle">Maiores Comissionados</span>'
		cRet += '		</h2>'
		cRet += '	</header>'
		cRet += '	<div class="panel-body">'
		cRet += '		<div class="content">'
		cRet += '			<ul class="simple-user-list">'
		cRet += 				cLista
		cRet += '			</ul>'
		cRet += '		</div>'
		cRet += '	</div>'
		cRet += '</section>'
	endif
return cRet

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ wgTopInadimplentes¦ Autor ¦ Ewerton Vinicius ¦Data 31.07.24¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Retorna os Widget de Clientes por Ranking de inadimplencia ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
static function wgTopInadimplentes(cFilFlt, cCodVend, cDataDe, cDataAte,cFilGrp, cFilLimRes, cFilImport)
	local cQry := ''
	local cRet := ''
	local cLista
	local nLimDado := 10
	local nCntLin  := 0
	//Lista de Vendas por Vendedor - Acesso do Supervisor e Diretor
	if HttpSession->Tipo $ 'DSGV'
	 
		if !Empty(cFilLimRes) // Visao do diretor
			nLimDado := val(cFilLimRes)
		endif

		// Buscar os Títulos
		cQry += " SELECT TOP("+cvaltochar(nLimDado)+") E1_CLIENTE, A1_CGC, E1_NOMCLI, SUM(E1_SALDO) AS E1_SALDO, A1_EST "
		cQry += " FROM "+RetSqlName("SE1")+" SE1 "
		cQry += " INNER JOIN "+ RetSqlName("SA1")+" SA1 ON A1_FILIAL = E1_FILIAL AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		If HttpSession->Tipo $ 'SG' //Supervisor acessa todos os clientes da sua equipe
			cQry+= " AND A1_VEND in "+FormatIn(HttpSession->Equipe,"|")+" "
		Elseif  HttpSession->Tipo $ 'V'
			cQry+= " AND A1_VEND = '"+cCodVend+"' "
		else
			cQry+= " AND A1_VEND <> '' "
		Endif
		cQry += " WHERE "
		cQry += " E1_TIPO NOT IN ('NCC', 'RA') "
		cQry += " AND E1_SALDO > 0 "
		cQry += " AND DATEADD(DAY, 3, CONVERT(DATE, E1_VENCREA , 112)) <  CONVERT(DATE, '"+cValToChar(dDataBase)+"', 103) "
		cQry += " AND A1_GRPAUTO <> 1 "
		cQry += " AND A1_CGC <> '' "
		if cFilFlt == "" 
			cQry += " AND E1_FILIAL <> '' "
		else 
			cQry += " AND E1_FILIAL = '"+cFilFlt+"' "
		endif
		cQry += " AND SE1.D_E_L_E_T_ = '' "
		cQry += " AND SA1.D_E_L_E_T_ = '' "
		cQry += " GROUP BY E1_CLIENTE, A1_CGC, E1_NOMCLI, A1_EST "
		cQry += " ORDER BY E1_SALDO DESC "
		
		if Select("QVV") > 0
			QVV->(dbCloseArea())
		endif	
		APWExOpenQuery(cQry,'QVV',.T.)
		
		cLista:= ""
		While QVV->(!Eof())
			nCntLin++
			cLista+= '<li>'
			cLista+= '	<div class="row show-grid">'
			cLista+= '		<div class="col-md-8"><span class="text">'+QVV->A1_CGC+' - '+trim(QVV->E1_NOMCLI)+ ' - ' +trim(QVV->A1_EST)+ '</span></div>'
			cLista+= '		<div class="col-md-3" align="right"><span class="text-primary">R$'+ltrim(TransForm(QVV->E1_SALDO,"@E 999,999,999.99"))+'</span></div>' 
			cLista+= '	</div>'
			cLista+= '</li>'
			if HttpSession->Tipo = 'D' .and. nCntLin = nLimDado
				exit
			endif
			QVV->(dbSkip())
		End
		QVV->(dbCloseArea())
	
		cRet += '<section class="panel">'
		cRet += '	<header class="panel-heading">'
		cRet += '		<h2 class="panel-title">'
		cRet += '			<span class="va-middle">Maiores Inadimplentes</span>'
		cRet += '		</h2>'
		cRet += '	</header>'
		cRet += '	<div class="panel-body">'
		cRet += '		<div class="content">'
		cRet += '			<ul class="simple-user-list">'
		cRet += 				cLista
		cRet += '			</ul>'
		cRet += '		</div>'
		cRet += '	</div>'
		cRet += '</section>'
	endif
return cRet

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ wgTopFiliais      ¦ Autor ¦ Pedro de Souza ¦ Data 15.09.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Retorna os Widget top x de filiais                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
static function wgTopFiliais(cFilFlt, cCodVend, cDataDe, cDataAte, cFilGrp, cFilLimRes, cFilImport)
	local cRet := ""
	local cQry
	local cLista
	local nLimDado := 10
	local nCntLin  := 0
	//Lista de Vendas por Filiais - Acesso do Diretor
	if HttpSession->Tipo $ 'D' .or. cCodvend $ GetMv("AA_PRFILGR",,"")
	 
		if !Empty(cFilLimRes) // Visao do diretor
			nLimDado := val(cFilLimRes)
		endif

		cQry:= "Select SUM( D2_VALBRUT - D2_ICMSRET - D2_VALIPI - CASE WHEN F2_TPFRETE = 'C' THEN F2_FRETE else 0 END) VALOR, F2_FILIAL AS CODIGO, Z00_NOMEMP AS NOME " 
		cQry+= "From "+RetSqlName("SF2")+" SF2 "

		cQry+= " INNER JOIN SD2010 SD2 ON SD2.D2_FILIAL = SF2.F2_FILIAL "
		cQry+= " AND F2_DOC = D2_DOC "
		cQry+= " AND F2_SERIE = D2_SERIE "
		cQry+= " AND SD2.D_E_L_E_T_ = ' '  "

		if HttpSession->Tipo = 'D' .or. cFilGrp <> 'T'// Visao do diretor
			if cFilGrp <> 'T'
				cQry+= " INNER JOIN "+RetSqlName("SBM")+" SBM ON SBM.BM_GRUPO = SD2.D2_GRUPO AND SBM.D_E_L_E_T_ = ' ' "
			endif
		endif

		if HttpSession->Tipo = 'S' //Supervisor acessa informações da sua equipe
			cQry+= " INNER JOIN "+RetSqlName("ZDV")+" ZDV "
			cQry+=  " ON SF2.F2_FILIAL = ZDV.ZDV_FILIAL AND ZDV_TABELA = 'SF2' AND F2_DOC+F2_SERIE = ZDV_CODERP AND ZDV.D_E_L_E_T_ = ' ' AND ZDV.ZDV_CODVEN = '"+cCodVend+"'"
		endif

		cQry+= " INNER JOIN "+RetSqlName("SA1")+" SA1 "
		cQry+=  " ON SA1.A1_FILIAL = F2_FILIAL AND F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA AND SA1.A1_GRPAUTO <> '1' AND SA1.D_E_L_E_T_ = ' ' "
		cQry+= "Inner Join "+RetSqlName("SA3")+" SA3 ON A3_FILIAL = '"+xFilial("SA3")+"' and A3_COD = F2_VEND1 AND SA3.D_E_L_E_T_ = ' ' "
		cQry+= "Inner Join "+RetSqlName("Z00")+" Z00 ON Z00_FILIAL = F2_FILIAL and Z00.D_E_L_E_T_ = ' ' "
		
		if !Empty(cFilFlt)
			cQry+= "	Where F2_FILIAL  = '"+cFilFlt+"' "
		else
			if !Empty(cFilImport)
				cQry+= " INNER JOIN "+RetSqlName("ZC2")+" ZC2 "
				cQry+=  " ON SF2.F2_FILIAL = ZC2.ZC2_FILVEN AND ZC2_FILIMP = '" + cFilImport + "' AND ZC2.D_E_L_E_T_ = ' ' "
			endif
			cQry+= "	Where F2_FILIAL  <> ' ' "
		endif
		
		cQry+= "And F2_TIPO = 'N' And SF2.F2_VALFAT > 0 "
		
		if HttpSession->Tipo = 'D' .or. cFilGrp <> 'T' // Visao do diretor
			if cFilGrp <> 'T'
				cQry+= " AND SBM.BM_XPRDVE = '"+cFilGrp+"' "
			endif
		endif

		cQry+= "And F2_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"' "
		cQry+= "And SF2.D_E_L_E_T_ = ' ' " 
		cQry+= "Group by F2_FILIAL, Z00_NOMEMP " 
		cQry+= "Order by SUM( D2_VALBRUT - D2_ICMSRET - D2_VALIPI - CASE WHEN F2_TPFRETE = 'C' THEN F2_FRETE else 0 END) DESC " 
		
		if Select("QVV") > 0
			QVV->(dbCloseArea())
		endif
		APWExOpenQuery(cQry,'QVV',.T.)
		
		cLista:= ""
		While QVV->(!Eof())
			nCntLin++
			cLista+= '<li>'
			cLista+= '	<div class="row show-grid">'
			cLista+= '		<div class="col-md-9"><span class="text">'+QVV->CODIGO+"-"+FWFilialName(SM0->M0_CODIGO, QVV->CODIGO,2)+'</span></div>'
			cLista+= '		<div class="col-md-3" align="right"><span class="text-primary">R$'+Transform(QVV->VALOR,PesqPict("SF2","F2_VALFAT"))+'</span></div>'
			cLista+= '	</div>'
			cLista+= '</li>'
			if HttpSession->Tipo = 'D' .and. nCntLin = nLimDado
				exit
			endif
			QVV->(dbSkip())
		End
		QVV->(dbCloseArea())

		cRet += '<section class="panel">'
		cRet += '	<header class="panel-heading">'
		cRet += '		<h2 class="panel-title">'
		cRet += '			<span class="va-middle">Filiais</span>'
		cRet += '		</h2>'
		cRet += '	</header>'
		cRet += '	<div class="panel-body">'
		cRet += '		<div class="content">'
		cRet += '			<ul class="simple-user-list">'
		cRet +=  				cLista
		cRet += '			</ul>'
		cRet += '		</div>'
		cRet += '	</div>'
		cRet += '</section>'
	endif
return cRet

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ wgTopEstados      ¦ Autor ¦ Pedro de Souza ¦ Data 15.09.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Retorna os Widget top x de estados                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
static function wgTopEstados(cFilFlt, cCodVend, cDataDe, cDataAte, cFilGrp, cFilLimRes, cFilImport)
	local cRet := ""
	local cQry
	local cLista
	local nLimDado := 10
	local nCntLin  := 0
	//Lista de Vendas por Filiais - Acesso do Diretor
	if HttpSession->Tipo $ 'D' .or. cCodvend $ GetMv("AA_PRFILGR",,"")
	
		if !Empty(cFilLimRes) // Visao do diretor
			nLimDado := val(cFilLimRes)
		endif
		cQry:= "Select SUM( D2_VALBRUT - D2_ICMSRET - D2_VALIPI - CASE WHEN F2_TPFRETE = 'C' THEN F2_FRETE else 0 END) VALOR, F2_EST ESTADO "
		cQry+= "From "+RetSqlName("SF2")+" SF2 "
		
		cQry+= " INNER JOIN SD2010 SD2 ON SD2.D2_FILIAL = SF2.F2_FILIAL "
		cQry+= " AND F2_DOC = D2_DOC "
		cQry+= " AND F2_SERIE = D2_SERIE "
		cQry+= " AND SD2.D_E_L_E_T_ = ' '  "
		
		if HttpSession->Tipo = 'D' .or. cFilGrp <> 'T'// Visao do diretor
			if cFilGrp <> 'T'
				cQry+= " INNER JOIN "+RetSqlName("SBM")+" SBM ON SBM.BM_GRUPO = SD2.D2_GRUPO AND SBM.D_E_L_E_T_ = ' ' "
			endif
		endif
		
		if HttpSession->Tipo = 'S' //Supervisor acessa informações da sua equipe
			cQry+= " INNER JOIN "+RetSqlName("ZDV")+" ZDV "
			cQry+=  " ON SF2.F2_FILIAL = ZDV.ZDV_FILIAL AND ZDV_TABELA = 'SF2' AND F2_DOC+F2_SERIE = ZDV_CODERP AND ZDV.D_E_L_E_T_ = ' ' AND ZDV.ZDV_CODVEN = '"+cCodVend+"'"
		endif
		
		cQry+= " INNER JOIN "+RetSqlName("SA1")+" SA1 "
		cQry+=  " ON SA1.A1_FILIAL = F2_FILIAL AND F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA AND SA1.A1_GRPAUTO <> '1' AND SA1.D_E_L_E_T_ = ' ' "
		cQry+= "Inner Join "+RetSqlName("SA3")+" SA3 ON A3_FILIAL = '"+xFilial("SA3")+"' and A3_COD = F2_VEND1 AND SA3.D_E_L_E_T_ = ' ' "
		
		if !Empty(cFilFlt)
			cQry+= "	Where F2_FILIAL  = '"+cFilFlt+"' "
		else
			if !Empty(cFilImport)
				cQry+= " INNER JOIN "+RetSqlName("ZC2")+" ZC2 "
				cQry+=  " ON SF2.F2_FILIAL = ZC2.ZC2_FILVEN AND ZC2_FILIMP = '" + cFilImport + "' AND ZC2.D_E_L_E_T_ = ' ' "
			endif
			cQry+= "	Where F2_FILIAL  <> ' ' "
		endif
		
		cQry+= "And F2_TIPO = 'N' And SF2.F2_VALFAT > 0 "
		
		if HttpSession->Tipo = 'D' .or. cFilGrp <> 'T'// Visao do diretor
			if cFilGrp <> 'T'
				cQry+= " AND SBM.BM_XPRDVE = '"+cFilGrp+"' "
			endif
		endif
		
		cQry+= "And F2_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"' "
		cQry+= "And SF2.D_E_L_E_T_ = ' ' " 
		cQry+= "Group by F2_EST " 
		cQry+= "Order by SUM( D2_VALBRUT - D2_ICMSRET - D2_VALIPI - CASE WHEN F2_TPFRETE = 'C' THEN F2_FRETE else 0 END) DESC " 
		
		if Select("QVV") > 0
			QVV->(dbCloseArea())
		endif	
		APWExOpenQuery(cQry,'QVV',.T.)
		
		cLista:= ""
		While QVV->(!Eof())
			nCntLin++
			cLista+= '<li>'
			cLista+= '	<div class="row show-grid">'
			cLista+= '		<div class="col-md-8"><span class="text">'+QVV->ESTADO+'</span></div>'
			cLista+= '		<div class="col-md-3" align="right"><span class="text-primary">R$'+Transform(QVV->VALOR,PesqPict("SF2","F2_VALFAT"))+'</span></div>'
			cLista+= '	</div>'
			cLista+= '</li>'
			if HttpSession->Tipo = 'D' .and. nCntLin = nLimDado
				exit
			endif
			QVV->(dbSkip())
		End
		QVV->(dbCloseArea())

		cRet += '<section class="panel">'
		cRet += '	<header class="panel-heading">'
		cRet += '		<h2 class="panel-title">'
		cRet += '			<span class="va-middle">Estados</span>'
		cRet += '		</h2>'
		cRet += '	</header>'
		cRet += '	<div class="panel-body">'
		cRet += '		<div class="content">'
		cRet += '			<ul class="simple-user-list">'
		cRet +=  				cLista	
		cRet += '			</ul>'
		cRet += '		</div>'
		cRet += '	</div>'
		cRet += '</section>'
	endif
return cRet

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ fFilDir           ¦ Autor ¦ Pedro de Souza ¦ Data 15.09.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Retorna Dados da combo de filiais para os diretores        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
static function fFilDir(cCodVend,cFilFiltro)
	local aAreaZ00
	local aArea := GetArea()
	local cRet := ""
	dbselectArea("Z00")
	aAreaZ00 := Z00->(GetArea())
	Z00->(dbSetOrder(1))
	Z00->(dbGoTop())
	While Z00->(!Eof())
		cRet+= ' <option value="'+Alltrim(Z00->Z00_FILIAL)+'" '+Iif(Alltrim(Z00->Z00_FILIAL)= cFilFiltro,' selected ','')+'>'+Alltrim(Z00->Z00_FILIAL)+" - "+FWFilialName(SM0->M0_CODIGO, Z00->Z00_FILIAL,2)+'</option>'
		Z00->(dbSkip())
	End
	Z00->(RestArea(aAreaZ00))
	RestArea(aArea)
Return cRet

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ fFilImport        ¦ Autor ¦ Pedro de Souza ¦ Data 15.09.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Retorna Dados da combo de importadoras                     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
static function fFilImport(cFilImport)
	local aArea := GetArea()
	local cRet := ""
	local aFilImp := {}
	dbselectArea("ZC2")
	ZC2->(dbSetOrder(1))  // ZC2_FILIAL, ZC2_FILIMP, ZC2_FILVEN, R_E_C_N_O_, D_E_L_E_T_
	ZC2->(dbSeek(xFilial("ZC2")))
	While ZC2->(!Eof()) .and. ZC2->ZC2_FILIAL = xFilial("ZC2")
		if Empty(ascan(aFilImp, ZC2->ZC2_FILIMP))
			aadd(aFilImp, ZC2->ZC2_FILIMP)
			cRet+= ' <option value="'+Alltrim(ZC2->ZC2_FILIMP)+'" '+Iif(Alltrim(ZC2->ZC2_FILIMP)== cFilImport,' selected ','')+'>'+Alltrim(ZC2->ZC2_FILIMP)+" - "+FWFilialName(cEmpAnt, ZC2->ZC2_FILIMP,2)+'</option>'
		endif
		ZC2->(dbSkip())
	End
	RestArea(aArea)
Return cRet
