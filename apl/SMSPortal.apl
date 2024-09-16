#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"

#DEFINE SMSDEBUG
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ SMSPortal  ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦22.08.16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Tela inicial do portal.    								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function SMSPortal(cVendLogin)
Local cHtml
Local cPerDe	:= ""
Local cPerAte	:= ""
Local cAnoMes   := ""
Local cCodVend	:= ""
Local cDataDe	:= ""
Local cDataAte	:= ""
Local cVndFlt	:= ""
Local aMeses	:= {}
Local aWidGet	:= {} 
Local nI
Local nW

Private cColunas  := ""
Private cItens	  := ""     
Private cSite	  := "u_PortalLogin.apw"
Private cPagina	  := ""
Private cMenus	  := ""
Private cTitle	  := "Portal SMS"
Private cWidgets  := ""                      
Private cTopo	  := ""
Private cMeta	  := ""
Private cAtingido := ""
Private cFalta    := ""
Private cMVendas  := ""
Private cMDevedor := ""
Private	cVendaMes := ""
Private cListVend := ""
Private nMeta	  := 0
Private cCodLogin := ""
Private cCampanhas:= ""

default cVendLogin:= ""
Web Extended Init cHtml Start U_inSite(empty(cVendLogin))

	if empty(cVendLogin)
		cVendLogin := u_GetUsrPR()
	endif
	
	cCodVend	:= cVendLogin
	cCodLogin 	:= U_SetParPR(cCodVend)

	If Empty(HttpSession->CodVend)
		cHtml:= '<META HTTP-EQUIV="Refresh" CONTENT="0 ; URL='+cSite+'">'	
		Return cHtml
	Else
		If !Empty(HttpSession->Superv) .and. HttpSession->Superv <> HttpSession->CodVend
			HttpSession->CodVend:= HttpSession->Superv
		Endif
	Endif
	
	// Pega do parâmetro com o Titulo do Portal
	cTitle	:= SuperGetMV("PS_TITLE", .T., "Portal SMS")
	
	// Define a funcao a ser chama no link
	cSite	:= Procname()+".apw?PR="+cCodLogin
		
	//Função que atualiza os menus
	HttpSession->aMenu:= {}
	cMenus := u_GetMenus(AllTrim(Upper(Procname())), cCodVend)

	// Recupera as rotinas que possuem WidGet
	aWidGet := HttpSession->aWidGet
	
	// Rotina para montar os Widgets
	For nW := 1 To Len(aWidGet)
		// Verificar se a função do WidGet está compilado no PRO
		If ExistBlock(aWidGet[nW,3])
			// Executa a função do WidGet	
			aParam := aWidGet[nW]
			lGravou := ExecBlock(aWidGet[nW,3],.F.,.F.,aParam)
		EndIf
	Next
	
	//Tratamento dos filtros
	If type("HttpPost->DataDe") <> "U"
		//Se vazio, usa as datas padrão para evitar erro na query
		If Empty(HttpPost->DataDe) .or. Empty(HttpPost->DataAte)
			cDataDe:= dtos(FirstDay(date()))
			cDataAte:= dtos(LastDay(date()))
		Else
			cDataDe:= dtos(ctod(HttpPost->DataDe))
		    cDataAte:= dtos(ctod(HttpPost->DataAte))
		Endif
		//Atualiza as variáveis no valor do filtro
		cFiltDe:= dtoc(stod(cDataDe))
		cFilAte:= dtoc(stod(cDataAte))
		cVndFlt:= Iif(!Empty(HttpPost->VenFiltro),HttpPost->VenFiltro,"")   
	Else
	    //Variáveis dos input dos filtros
		cFiltDe:= dtoc(FirstDay(date()))
		cFilAte:= dtoc(LastDay(date()))
		//Variáveis de filtro da query
		cDataDe:= dtos(FirstDay(date()))
		cDataAte:= dtos(LastDay(date()))
	Endif
	
	//Filtro período
	cTopo:= '<div class="row form-group">'
    cTopo+= '	<div class="col-sm-12">'
    cTopo+= '	<form name="formGrid" id="formGrid" method="POST" action="'+procname()+'.apw?PR='+cCodLogin+'">'
	
	cTopo+= '		<label class="col-md-1 control-label">De:</label>'
    cTopo+= '  		<div class="col-md-3">'
	cTopo+= '		 	<div class="input-group">'
    cTopo+= '    			<span class="input-group-addon">'
    cTopo+= '					<i class="fa fa-calendar"></i>'
    cTopo+= '			    </span>'   
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
	
	If HttpSession->Tipo = 'S' //Supervisor acessa informações da sua equipe
		cTopo+= '		<label class="col-md-1 control-label">Repr.:</label>'
		cTopo+= '		<div class="col-md-3">'
		cTopo+= '			<select data-plugin-selectTwo class="form-control populate mb-md" name="VENFILTRO" id="VENFILTRO" '
		cTopo+= '			required="" aria-required="true">'
		cTopo+= '				<option value=" ">Todos</option>'
		cTopo+= u_fEqpSup(cVndFlt)
		cTopo+= '			</select>'
		cTopo+= '		</div>'
	Endif
	
	cTopo+= '<div><br><br></div>'
	cTopo+= '		<div class="col-sm-2">'
    cTopo+= '			<button class="btn btn-primary" id="btFiltroD" value="" onclick="this.value= '+"'"+'Aguarde...'+"'"+';this.disabled= '+"'"+'disabled'+"'"+';Filtro()" name="btFiltro">'
    cTopo+= '			<i class="fa fa-refresh"></i> Atualizar</button>' 
    cTopo+= '		</div>'
    cTopo+= '	</form>'
	cTopo+= '	</div>'
	cTopo+= '</div>'
	
	/*
	cWidGets+= '<ul class="simple-card-list mb-xlg">'
	cWidGets+= '	<li class="primary">'
	cWidGets+= '		<h3>488</h3>'
	cWidGets+= '		<p>Nullam quris ris.</p>'
	cWidGets+= '	</li>	
	cWidGets+= '</ul>' 
	  */

	//Widget Saldos
	cQry:= "Select SUM(ZYF_SALDO) SALDO "
	cQry+= "From "+RetSqlName("ZYF")+" ZYF "
	cQry+= "Where ZYF_FILIAL = '"+xFilial("ZYF")+"' "
	cQry+= "And ZYF_DATA = '"+cValtoChar(Year(dDataBase))+"/"+StrZero(Month(dDataBase),2)+"' "
	If HttpSession->Tipo = 'S' //Supervisor acessa informações da sua equipe
		If !Empty(cVndFlt)
			cQry+= "		AND ZYF_VEND = '"+cVndFlt+"' "
		Else
			cQry+= "		AND ZYF_VEND = '"+cCodVend+"' "
			//cQry+= "		AND ZYF_VEND in "+FormatIn(HttpSession->Equipe,"|")+" "
		Endif	
	Else 
		cQry+= "		AND ZYF_VEND = '"+cCodVend+"' "
	Endif
	cQry+= " And ZYF.D_E_L_E_T_ = ' ' "
	APWExOpenQuery(cQry,'QSAL',.T.)

	cSaldo:= Alltrim(Transform(QSAL->SALDO,PesqPict("SE1","E1_SALDO")))
	cWidgets += U_GetWdGet(1, {"fa fa-dashboard", "R$ "+cSaldo, "Saldos", ""})
	QSAL->(dbCloseArea())
	//Widget Inadimplência 
	/*
	cQry:= "With FAT_ANOS_ANT as ("
	cQry+= " SELECT SUM(E1_VALOR) FAT_ANOS_ANT "
	cQry+= " FROM "+RetSqlName("SE1")+" SE1 "
	cQry+= " WHERE "
	cQry+= " SUBSTRING(E1_EMISSAO,1,4) = '"+cValtochar(Year(dDataBase)-2)+"' "
	cQry+= " AND SUBSTRING(E1_VENCTO,1,4) = '"+cValtochar(Year(dDataBase)-1)+"' "  
	If HttpSession->Tipo = 'S' //Supervisor acessa informações da sua equipe
		If !Empty(cVndFlt)
			cQry+= "		AND E1_VEND1 = '"+cVndFlt+"' "
		Else
			cQry+= "		AND E1_VEND1 in "+FormatIn(HttpSession->Equipe,"|")+" "
		Endif	
	Else 
		cQry+= "		AND E1_VEND1 = '"+cCodVend+"' 
	Endif
	cQry+= " AND E1_TIPO = 'NF' "
	cQry+= " AND E1_DESCONT <> E1_VALOR "
	cQry+= " AND SE1.D_E_L_E_T_ = ' ' "
	cQry+= "), "
	
	cQry+= "FAT_ANT AS ( "
	cQry+= " SELECT SUM(F2_VALFAT) FAT_ANT "
	cQry+= " FROM "+RetSqlName("SF2")+" SF2 "
	cQry+= " WHERE SUBSTRING(F2_EMISSAO,1,4) = '"+cValtochar(Year(dDataBase)-1)+"'
	If HttpSession->Tipo = 'S' //Supervisor acessa informações da sua equipe
		If !Empty(cVndFlt)
			cQry+= "		AND F2_VEND1 = '"+cVndFlt+"' "
		Else
			cQry+= "		AND F2_VEND1 in "+FormatIn(HttpSession->Equipe,"|")+" "
		Endif	
	Else 
		cQry+= "		AND F2_VEND1 = '"+cCodVend+"' 
	Endif
	cQry+= " AND SF2.D_E_L_E_T_ = ' ' "
	cQry+= "), "
	
	cQry+= "FAT_ATU AS ( "
	cQry+= " SELECT SUM(F2_VALFAT) FAT_ATU "
	cQry+= " FROM "+RetSqlName("SF2")+" SF2 "
	cQry+= " WHERE SUBSTRING(F2_EMISSAO,1,4) = '"+cValtochar(Year(dDataBase)-1)+"' "
	If HttpSession->Tipo = 'S' //Supervisor acessa informações da sua equipe
		If !Empty(cVndFlt)
			cQry+= "		AND F2_VEND1 = '"+cVndFlt+"' "
		Else
			cQry+= "		AND F2_VEND1 in "+FormatIn(HttpSession->Equipe,"|")+" "
		Endif	
	Else 
		cQry+= "		AND F2_VEND1 = '"+cCodVend+"' 
	Endif
	cQry+= " AND SF2.D_E_L_E_T_ = ' ' "
	cQry+= "), "
	
	cQry+= "PERDA AS ( "
	cQry+= " SELECT SUM(E5_VALOR) PERDA "
	cQry+= " FROM "+RetSqlName("SE5")+" SE5 "
	cQry+= " INNER JOIN "+RetSqlName("SE1")+" SE1 ON E1_FILIAL = E5_FILIAL AND E1_PREFIXO = E5_PREFIXO "
	cQry+= "	AND E1_NUM = E5_NUMERO AND E1_PARCELA = E5_PARCELA AND E1_TIPO = E5_TIPO AND SE1.D_E_L_E_T_ = ' ' "
	If HttpSession->Tipo = 'S' //Supervisor acessa informações da sua equipe
		If !Empty(cVndFlt)
			cQry+= "		AND E1_VEND1 = '"+cVndFlt+"' "
		Else
			cQry+= "		AND E1_VEND1 in "+FormatIn(HttpSession->Equipe,"|")+" "
		Endif	
	Else 
		cQry+= "		AND E1_VEND1 = '"+cCodVend+"' 
	Endif 
	cQry+= " WHERE E5_MOTBX = 'PER' "
	cQry+= " AND SUBSTRING(E5_VENCTO,1,4) = '"+cValtochar(Year(dDataBase)-1)+"' "
	cQry+= " AND SE5.D_E_L_E_T_ = ' ' "
	cQry+= "), "

	cQry+= "VENCIDOS AS ( "
	cQry+= " SELECT SUM(E1_SALDO) VENCIDOS "
	cQry+= " FROM "+RetSqlName("SE1")+" SE1 "
	cQry+= " WHERE E1_SALDO > 0 "
	If HttpSession->Tipo = 'S' //Supervisor acessa informações da sua equipe
		If !Empty(cVndFlt)
			cQry+= "		AND E1_VEND1 = '"+cVndFlt+"' "
		Else
			cQry+= "		AND E1_VEND1 in "+FormatIn(HttpSession->Equipe,"|")+" "
		Endif	
	Else 
		cQry+= "		AND E1_VEND1 = '"+cCodVend+"' 
	Endif
	cQry+= " AND E1_EMISSAO BETWEEN '"+cValtochar(Year(dDataBase)-2)+"0101' AND '"+cValtochar(Year(dDataBase)-1)+"1231' "
	cQry+= " AND E1_TIPO = 'NF' "
	cQry+= " AND SE1.D_E_L_E_T_= ' ' "
	cQry+= ") "
	cQry+= " Select * From FAT_ANOS_ANT, FAT_ANT, FAT_ATU, PERDA, VENCIDOS "
	If Select("QIN") > 0
		QIN->(dbCloseArea())
	Endif	
    APWExOpenQuery(cQry,'QIN',.T.)
	cInad:=  cValtochar(Round( (QIN->PERDA+QIN->VENCIDOS) / (QIN->FAT_ANOS_ANT+ QIN->FAT_ANT+ QIN->FAT_ATU),2))
	cWidgets += U_GetWdGet(1, {"fa fa-dollar", Alltrim(cInad)+"%", "Inadimplência", ""})
	*/

	//Maiores Devedores
	cQry:= " SELECT E1_CLIENTE, E1_LOJA, E1_NOMCLI, A1_NOME, SUM(E1_VALOR) VALOR "
	cQry+= " FROM "+RetSqlName("SE1")+" SE1 "
	cQry+= " INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = ' ' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND SA1.D_E_L_E_T_ = ' ' "
	cQry+= " WHERE E1_FILIAL = '"+xFilial("SE1")+"' "
	cQry+= " AND E1_SALDO > 0 "
	cQry+= " AND E1_TIPO = 'NF' "
	cQry+= " AND E1_VENCTO BETWEEN '"+ cvaltochar(Val(Left(cDataAte,4))-2) +'0101'+"' and '"+cDataAte+"' " 
	If HttpSession->Tipo = 'S' //Supervisor acessa informações da sua equipe
		If !Empty(cVndFlt)
			cQry+= "		AND E1_VEND1 = '"+cVndFlt+"' "
		Else	
			cQry+= "		AND E1_VEND1 in "+FormatIn(HttpSession->Equipe,"|")+" "
		Endif
	Else 
		cQry+= "		AND E1_VEND1 = '"+cCodVend+"' 
	Endif
	cQry+= " AND SE1.D_E_L_E_T_ = ' ' "
	cQry+= " GROUP BY E1_CLIENTE, E1_LOJA, E1_NOMCLI, A1_NOME "
	cQry+= " ORDER BY SUM(E1_VALOR) DESC " 
	If Select("QRD") > 0
		QRD->(dbCloseArea())
	Endif
	TcQuery cQry New Alias "QRD"
	
	nCont:= 0
	While QRD->(!Eof())
		nCont++
		If nCont > 5
			Exit 
		Endif	
		cMDevedor+= '<li>'
		cMDevedor+= '	<div class="profile-info">'
		cMDevedor+= '		<span class="title">'+QRD->A1_NOME+'</span>'
		cMDevedor+= '		<span class="message truncate">R$'+Transform(QRD->VALOR,"@E 999,999,999,999.99")+'</span>'
		cMDevedor+= '	</div>'
		cMDevedor+= '</li>'
	    QRD->(dbSkip())
	End



	//WidGet Ticket Médio
	cQry:= "With VENDAS as ( " 
	cQry+= "	Select F2_VALFAT, 1 AS NFS "
	cQry+= "	From "+RetSqlName("SF2")+" SF2 "
	cQry+= "	Where F2_FILIAL  <> ' ' "
	cQry+= "	And F2_TIPO = 'N' "
	If HttpSession->Tipo = 'S' //Supervisor acessa informações da sua equipe
		If !Empty(cVndFlt)
			cQry+= "		AND F2_VEND1 = '"+cVndFlt+"' "
		Else	
			cQry+= "		AND F2_VEND1 in "+FormatIn(HttpSession->Equipe,"|")+" "
		Endif
	Else 
		cQry+= "		AND F2_VEND1 = '"+cCodVend+"' 
	Endif
	//cQry+= "	And substring(F2_EMISSAO,1,6) = '"+cEmissao+"' " 
	cQry+= "	And F2_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"' " 
	cQry+= "	And SF2.D_E_L_E_T_ = ' ' ), "
	
	cQry+= "ITENS as ( "	
	cQry+= "	Select D2_COD, 1 AS QTD "
	cQry+= "	From "+RetSqlName("SD2")+" SD2 "
	cQry+= "	Inner Join "+RetSqlName("SF2")+" SF2 ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE "
	cQry+= "		And F2_TIPO = 'N' And F2_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"' And SF2.D_E_L_E_T_ = ' '
	
	If HttpSession->Tipo = 'S' //Supervisor acessa informações da sua equipe
		If !Empty(cVndFlt)
			cQry+= "		AND F2_VEND1 = '"+cVndFlt+"' "
		Else	
			cQry+= "		AND F2_VEND1 in "+FormatIn(HttpSession->Equipe,"|")+" "
		Endif
	Else 
		cQry+= "		AND F2_VEND1 = '"+cCodVend+"' 
	Endif
	cQry+= "	Where D2_FILIAL  <> ' ' "
	cQry+= "	And SD2.D_E_L_E_T_ = ' '), "	
	
	cQry+= "TOTAL_ITENS as (Select SUM(QTD) QTD FROM ITENS) "

	cQry+= "Select SUM(F2_VALFAT) VALOR, SUM(NFS) NOTAS, avg(QTD) ITENS "
	cQry+= "FROM VENDAS, TOTAL_ITENS "

	
	If Select("QTM") > 0
		QTM->(dbCloseArea())
	Endif	
    APWExOpenQuery(cQry,'QTM',.T.) 

	//Variáveis para o quadro de meta
	cQry:= "Select SUM(CT_VALOR) VALOR "
	cQry+= " From "+RetSqlName("SCT")+" SCT "
	cQry+= " Where CT_FILIAL = '"+xFilial("SCT")+"' "
	cQry+= " and CT_DATA between '"+Left(cDataDe,6)+'01'+"' and '"+Left(cDataAte,6)+'01'+"' "
	
	If HttpSession->Tipo = 'S' //Supervisor acessa informações da sua equipe
		If !Empty(cVndFlt)
			cQry+= "		AND CT_VEND = '"+cVndFlt+"' "
		Else	
			cQry+= "		AND CT_VEND in "+FormatIn(HttpSession->Equipe,"|")+" "
		Endif
	Else 
		cQry+= " and CT_VEND = '"+cCodVend+"' "
	Endif

	cQry+= " And SCT.D_E_L_E_T_ = ' ' "
	If Select("QRM") > 0
		QRM->(dbCloseArea())
	Endif
	APWExOpenQuery(cQry,'QRM',.T.) 

	nMeta:= QRM->VALOR

	cAtingido:= cValtoChar(Int((QTM->VALOR/nMeta) * 100))+ "%"
	cFalta:= cValtoChar(Iif(100 - val(cAtingido) < 0,0,100 - val(cAtingido)))+"%" 
	cMeta:= Transform(nMeta,PesqPict("SCT","CT_VALOR"))	
	
	// Itens mais vendidos
	cQry:= "Select D2_COD,  B1_DESC, SUM(D2_QUANT) AS QTD "
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
    cQry+= "    Inner Join "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = D2_COD AND  SB1.D_E_L_E_T_ = ' ' "
	cQry+= "	Where D2_FILIAL  <> ' ' "
	cQry+= "And SD2.D_E_L_E_T_ = ' ' "
	cQry+= "Group by D2_COD, B1_DESC "
	cQry+= "Order by SUM(D2_QUANT) DESC "
	cQry+= "Fetch first 10 rows only "
	
	If Select("QTV") > 0
		QTV->(dbCloseArea())
	Endif	
    APWExOpenQuery(cQry,'QTV',.T.)	
	
	While QTV->(!Eof())
		cMVendas+= '<li>'
		cMVendas+= '	<figure class="image rounded">'
		cMVendas+= '	<img src="/images/prod.jpg" alt="" class="img-circle">'
		cMVendas+= '	</figure>'
		cMVendas+= '	<div class="profile-info">'
		cMVendas+= '		<span class="title">'+QTV->B1_DESC+'</span>'
		cMVendas+= '		<span class="message truncate">'+cvaltochar(QTV->QTD)+Iif(QTV->QTD > 1,' itens vendidos',' item vendido')+'</span>'
		cMVendas+= '	</div>'
		cMVendas+= '</li>'
	    QTV->(dbSkip())
	End
	
	//Campanhas
	cQry:= "SELECT DA0_CODTAB, DA0_DESCRI, DA0_DATATE "
	cQry+= "FROM "+RetSqlName("DA0")+" DA0 "
	cQry+= "WHERE DA0_FILIAL = '"+xFilial("DA0")+"'
	cQry+= "AND SUBSTRING(DA0_CODTAB,1,1) = 'C' "
	cQry+= "AND DA0_DATDE <= '"+DTOS(dDataBase)+"' "
	cQry+= "AND DA0_DATATE >= '"+DTOS(dDataBase)+"' "
	cQry+= "AND D_E_L_E_T_ = ' ' "
	If Select("QCAMP") > 0
		QCAMP->(dbCloseArea())
	Endif	
	TcQuery cQry New Alias "QCAMP"

	cLista:= ""
	While QCAMP->(!Eof())
		cLista+= '<li>'
		cLista+= '	<div class="row show-grid">'
		cLista+= '		<div class="col-md-8"><span class="text">'+QCAMP->DA0_CODTAB+"-"+QCAMP->DA0_DESCRI+'</span></div>'
		cLista+= '		<div class="col-md-3" align="right"><span class="text-primary">Validade '+dtoc(stod(QCAMP->DA0_DATATE))+'</span></div>'
		cLista+= '	</div>'
		cLista+= '</li>'
		QCAMP->(dbSkip())
	End	
	
	cCampanhas+='<div class="col-lg-5">'
	cCampanhas+='	<section class="panel">'
	cCampanhas+='		<header class="panel-heading">'
	cCampanhas+='			<h2 class="panel-title">'
	cCampanhas+='				<span class="va-middle">Campanhas</span>'
	cCampanhas+='			</h2>'
	cCampanhas+='		</header>'
	cCampanhas+='		<div class="panel-body">'
	cCampanhas+='			<div class="content">'	
	cCampanhas+='				<ul class="simple-user-list">'
	cCampanhas+= cLista					
	cCampanhas+='				</ul>'
	cCampanhas+='			</divl>'
	cCampanhas+='		</div>'					
	cCampanhas+='	</section>'
	cCampanhas+='</div>'







	//Vendas Mês a Mês
	cPerDe:= dtos(MonthSub(stod(cDataDe+'01'),5))
	cPerAte:= dtos(LastDay(stod(cDataDe+'01')))
	cQry:= "Select SUM(F2_VALFAT) VALOR, substring(F2_EMISSAO,1,6) PERIODO " 
	cQry+= "From "+RetSqlName("SF2")+" SF2 "
	cQry+= "	Where F2_FILIAL  <> ' ' "
	cQry+= "And F2_TIPO = 'N' "
	If HttpSession->Tipo = 'S' //Supervisor acessa informações da sua equipe
		If !Empty(cVndFlt)
			cQry+= "		AND F2_VEND1 = '"+cVndFlt+"' "
		Else	
			cQry+= "		AND F2_VEND1 in "+FormatIn(HttpSession->Equipe,"|")+" "
		Endif
	Else 
		cQry+= " AND F2_VEND1 = '"+cCodVend+"' 
	Endif
	//cQry+= "And F2_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"' "
	cQry+= "And F2_EMISSAO between '"+cPerDe+"' and '"+cPerAte+"' "
	cQry+= "And SF2.D_E_L_E_T_ = ' ' " 
	cQry+= "Group by substring(F2_EMISSAO,1,6)" 
	cQry+= "Order by substring(F2_EMISSAO,1,6)" 
	
	If Select("QMM") > 0
		QMM->(dbCloseArea())
	Endif	
    APWExOpenQuery(cQry,'QMM',.T.)
	
	While QMM->(!Eof())
		cAnoMes:= Substr(MesExtenso(stod(Alltrim(QMM->PERIODO)+'01')),1,3) +'/'+ Right(cValtochar(Year(stod(Alltrim(QMM->PERIODO)+'01'))),2)
	   	cVendaMes+= '["'+cAnoMes+'", '+cvaltochar(Int(QMM->VALOR / 1000))+'],'
	   	QMM->(dbSkip())
	End
	//Remove a última vírgula
	cVendaMes:= Substr(cVendaMes,1,Len(alltrim(cVendaMes))-1)
	

	//Lista de Vendas por Vendedor - Acesso do Supervisor
	If HttpSession->Tipo = 'S'
	 

		cQry:= "Select SUM(F2_VALFAT) VALOR, F2_VEND1 VENDEDOR, A3_NOME NOME " 
		cQry+= "From "+RetSqlName("SF2")+" SF2 "
		cQry+= "Inner Join "+RetSqlName("SA3")+" SA3 ON A3_FILIAL = '"+xFilial("SA3")+"' and A3_COD = F2_VEND1 AND SA3.D_E_L_E_T_ = ' ' "
		cQry+= "	Where F2_FILIAL  <> ' ' "
		cQry+= "And F2_TIPO = 'N' "
		cQry+= " AND F2_VEND1 in "+FormatIn(HttpSession->Equipe,"|")+" "
		cQry+= "And F2_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"' "
		cQry+= "And SF2.D_E_L_E_T_ = ' ' " 
		cQry+= "Group by F2_VEND1, A3_NOME " 
		cQry+= "Order by SUM(F2_VALFAT) DESC " 
		
		If Select("QVV") > 0
			QVV->(dbCloseArea())
		Endif	
		APWExOpenQuery(cQry,'QVV',.T.)
		
		cLista:= ""
		While QVV->(!Eof())
			cLista+= '<li>'
			cLista+= '	<div class="row show-grid">'
			cLista+= '		<div class="col-md-8"><span class="text">'+QVV->VENDEDOR+"-"+QVV->NOME+'</span></div>'
			cLista+= '		<div class="col-md-3" align="right"><span class="text-primary">R$'+Transform(QVV->VALOR,PesqPict("SF2","F2_VALFAT"))+'</span></div>'
			cLista+= '	</div>'
			cLista+= '</li>'

			QVV->(dbSkip())
		End
		cListVend+='<div class="col-lg-8">'
		cListVend+='	<section class="panel">'
		cListVend+='		<header class="panel-heading">'
		cListVend+='			<h2 class="panel-title">'
		cListVend+='				<span class="va-middle">Maiores Vendedores</span>'
		cListVend+='			</h2>'
		cListVend+='		</header>'
		cListVend+='		<div class="panel-body">'
		cListVend+='			<div class="content">'	
		cListVend+='				<ul class="simple-user-list">'
		cListVend+= cLista					
		cListVend+='				</ul>'
		cListVend+='			</divl>'
		cListVend+='		</div>'					
		cListVend+='	</section>'
		cListVend+='</div>'
	
	Endif				



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

	If nTipo == 1
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
		cWidget += 						'<span class="text-primary">'+aParWid[4]+'</span>'
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
	EndIf

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
		IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
			nY:= At(cChar,cAgudo)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCircu)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cTrema)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCrase)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cTio)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("ao",nY,1))
			EndIf
			nY:= At(cChar,cCecid)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("cC",nY,1))
			EndIf
		Endif
	Next

	If cMaior$ cString
		cString := strTran( cString, cMaior, "" )
	EndIf
	If cMenor$ cString
		cString := strTran( cString, cMenor, "" )
	EndIf

	For nX:=1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		If Asc(cChar) < 32 .Or. Asc(cChar) > 123
			cString:=StrTran(cString,cChar,".")
		Endif
	Next nX
Return cString
 



/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Retorna um array com grupos de compra                   !
+------------------+---------------------------------------------------------+
!Modulo            !                                                      	 !
+------------------+---------------------------------------------------------+
!Nome              ! UniGrCom                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Retorna um array com grupos de compra                   !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro de Souza                                          !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 13/03/2018                                              !
+----------------------------------------------------------------------------+
*/

user function UniGrCom()
    Local cQryTracke
    Local cAlTmp := GetNextAlias()
    Local aRet  := {{"000000","TODOS"}}
    Local aArea := GetArea()
    Local lComprador := HttpSession->Perfil = "Comprador"
    
    If lComprador
    	aRet  := {}
    Endif
    
    cQryTracke := " select distinct aj_grcom, aj_desc "
    cQryTracke += " FROM "+RetSqlName("SAJ")+" SAJ "
    cQryTracke += " WHERE SAJ.AJ_FILIAL = '" + xFilial('SAJ') + "' "
    cQryTracke +=   " AND SAJ.D_E_L_E_T_ = ' ' "
    If lComprador //Se for comprador, permite ver apenas os grupos que tem acesso
     	cQryTracke +=   " AND SAJ.AJ_USER = "+HttpSession->UserId
    Endif
    cQryTracke += " ORDER BY 1 "
    
    APWExOpenQuery(ChangeQuery(cQryTracke),cAlTmp,.T.)
    
    While !(cAlTmp)->(EOF())
        aadd(aRet, { (cAlTmp)->aj_grcom, trim((cAlTmp)->aj_desc) }) 
        (cAlTmp)->(dbSkip())
    EndDo
    
    (cAlTmp)->(dbCloseArea())
    RestArea(aArea)
//    conout('resultado da pesquisa de alcadas')
//    varinfo('aRet', aRet)
return aRet


user Function fEqpSup(cVendFiltro)
Local i:= 0
Local cRet:= ""
Local cVend:= ""
Local aEquipe:= Separa(HttpSession->Equipe,"|")	
	
For i:= 1 to Len(aEquipe)
	cVend:= Upper(Posicione("SA3",1,xFilial("SA3")+aEquipe[i],"A3_NOME"))
	cRet+= '	<option value="'+Alltrim(aEquipe[i])+'" '+Iif(Alltrim(aEquipe[i])= cVendFiltro,' selected ','')+'>'+Alltrim(aEquipe[i])+" - "+cVend+'</option>'
Next

Return cRet
