#include 'protheus.ch'
#include 'parmtype.ch'
#include 'rwmake.ch'
#include "topconn.ch"
#INCLUDE "font.ch"
#INCLUDE "colors.ch"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦  CADZYG    ¦ Autor ¦ Lucilene Mendes    ¦ Data ¦29.08.22   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Cadastro de regiões de Vendas                             ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function CadZYG()
Local cAlias	:= "ZYG"
Private aRotina	:= {}
Private oBrowse
Private cCadastro := "Regiões de Venda"

//Opções de menu disponíveis
aAdd(aRotina, {"Visualizar"	 , "u_MntZYG(2)", 0, 2})
aAdd(aRotina, {"Incluir", "u_MntZYG(3)", 0, 3})
aAdd(aRotina, {"Alterar", "u_MntZYG(4)", 0, 4})
//aAdd(aRotina, {"Excluir", "AxDeleta", 0, 5})

//Monta o browse
oBrowse := FWmBrowse():New()
oBrowse:SetAlias(cAlias)
oBrowse:SetDescription( cCadastro )  
oBrowse:DisableDetails()

//Abre a tela
oBrowse:Activate() 


Return


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦  MntZYG    ¦ Autor ¦ Lucilene Mendes    ¦ Data ¦08.09.22   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Manutenção de regiões de Vendas                           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function MntZYG(nOpc)
// Variaveis que controlam a interface
Local nSuperior 	:= 020
Local nEsquerda 	:= 005
Local nInferior 	:= 150
Local nDireita		:= 389
Local nX 			:= 0
Local cLinOk		:= "AllwaysTrue"
Local cTudoOk		:= "AllwaysTrue"
Local cDelOk		:= "AllwaysFalse"
Local cFieldOk		:= "AllwaysTrue"
Local cItem		    := "000" 
Local nStyle 		:= Iif(nOpc = 2,0,(GD_INSERT + GD_UPDATE + GD_DELETE))

Local oDlg1
Local oSay1
Local bRefresh		:= {|| oDlg1:Refresh() }
Local bGDRefresh  	:= {|| oGetDad:oBrowse:Refresh() }
Local aHeader		:= {}
Local aFields 		:= {"ZYG_ITEM","ZYG_EST","ZYG_CODIGO"}
Local aAlter		:= {}
Local aCols  		:= {}
Private oGetDad
Private cCodigo		:= ""
Private cDescri		:= space(30)

dbSelectArea("ZYG")

dbSelectArea("SX3")
SX3->(dbSetOrder(2))

//Monta o aHeader buscando na SX3 as propriedades dos campos do array aFields
For nX := 1 to Len(aFields)
    If SX3->(dbSeek(aFields[nX]))
        Aadd(aHeader,{Iif(nX=Len(aFields),"RECNO",AllTrim(X3_Titulo)),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,; //"AllwaysTrue()" 
        SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO}) 
    Endif
Next nX

If nOpc = 4 .or. nOpc = 3
	aAlter:= {"ZYG_EST"}
Endif	
If nOpc = 4 .or. nOpc = 2

	cCodigo:= ZYG->ZYG_CODIGO
	cDescri:= ZYG->ZYG_DESCRI

	cQry:= " Select ZYG.R_E_C_N_O_ RECZYG, ZYG.* "
	cQry+= " From  "+RetSqlName("ZYG")+" ZYG "
	cQry+= " Where ZYG_FILIAL = '"+ZYG->ZYG_FILIAL+"' "
	cQry+= " And ZYG_CODIGO = '"+ZYG->ZYG_CODIGO+"' "
	cQry+= " And ZYG.D_E_L_E_T_ = ' ' "
	If Select("QZYG") > 0
		QZYG->(dbCloseArea())
	Endif
	TcQuery cQry New Alias "QZYG"

	//Preenche o array com os itens
	While QZYG->(!Eof()) 
		
		//Monta o aCols
		aAdd(aCols, {QZYG->ZYG_ITEM,QZYG->ZYG_EST,QZYG->RECZYG, .F.})
		
		QZYG->(dbSkip())
	End
Else	
	cCodigo:= GetSxeNum("ZYG","ZYG_CODIGO")
	aAdd(aCols,Array(Len(aHeader)+1))
	For nX := 1 To Len(aHeader)
		aCols[Len(aCols)][nX]:= CriaVar(aHeader[nX][2])
	Next nX
	aCols[Len(aCols)][Len(aHeader)+1]:= .F.
	aCols[Len(aCols)][1]:= Soma1(cItem)
Endif	


DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD

//Monta a tela
DEFINE MSDIALOG oDlg1 TITLE "Regiões de Vendas" FROM 000, 000  TO 350, 780 COLORS 0,16777215 PIXEL Style 128//retira o [x] da janela
	@ 005,005 SAY oSay1 PROMPT "Código:   "+ cCodigo 	 SIZE 250, 030 OF oDlg1 FONT oBold COLORS CLR_BLUE, 16777215 PIXEL 
	@ 005,070 Say "Descrição:" SIZE 040, 010 OF oDlg1 COLORS 0, 16777215 PIXEL 
	@ 005,100 MsGet cDescri Picture "@!" SIZE 200, 008 Valid NaoVazio() When nOpc = 3 OF oDlg1 COLORS CLR_BLUE, 16777215 PIXEL   
	
	// Ação a ser executada nos botões OK ou CANCELA
	@ 157,280 BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 ACTION(u_GRVZYG(nOpc,aCols),oDlg1:End()) OF oDlg1 PIXEL
	@ 157,340 BUTTON oButton1 PROMPT "Fechar"    SIZE 037, 012 ACTION(oDlg1:End()) OF oDlg1 PIXEL

	//Criação do Grid
	oGetDad := MsNewGetDados():New(nSuperior, nEsquerda, nInferior, nDireita, nStyle, cLinOk, cTudoOk,"+ZYG_ITEM" , aAlter,, 30, "AllwaysTrue", "", "AllwaysTrue", oDlg1, aHeader, aCols)
	
	Eval(bGDRefresh)//Atualiza Grid    
	Eval(bRefresh)  //Atualiza Tela 
		
ACTIVATE MSDIALOG oDlg1 CENTERED 		

Return

User Function GrvZYG(nOpc,aCols)
Local aColsGrv:= oGetDad:aCols
Local lInc:= .T.
Local i:= 0
For i:= 1 to Len(aColsGrv) 
	lInc:= .T.
	If !aColsGrv[i,len(aColsGrv[i])] // se não estiver deletado em tela
		If !Empty(aColsGrv[i,len(aColsGrv[i])-1])
			ZYG->(dbGoto(aColsGrv[i,len(aColsGrv[i])-1]))
			lInc:= .F.
		Endif	
		RecLock("ZYG", lInc)
			ZYG->ZYG_FILIAL:= xFilial("ZYG")
			ZYG->ZYG_CODIGO:= cCodigo
			ZYG->ZYG_DESCRI:= cDescri
			ZYG->ZYG_ITEM:= aColsGrv[i,1]
			ZYG->ZYG_EST:= aColsGrv[i,2]
		MsUnlock()
	Else
		If !Empty(aColsGrv[i,len(aColsGrv[i])-1])
			ZYG->(dbGoto(aColsGrv[i,len(aColsGrv[i])-1]))
			RecLock("ZYG", .F.)
				dbDelete()
			MsUnlock()
		Endif	
		
	Endif
Next

Return
