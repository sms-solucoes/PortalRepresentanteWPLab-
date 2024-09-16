#include 'protheus.ch'
#include 'parmtype.ch'
#include 'rwmake.ch'
#INCLUDE "topconn.ch"
#INCLUDE "font.ch"
#INCLUDE "colors.ch"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Funçäo    ¦ AcresOrcto  ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦12.08.23 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Alteração do acrescimo no orçamento						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function AcresOrcto()
// Variaveis que controlam a interface
Local nSuperior 	:= 030
Local nEsquerda 	:= 001
Local nInferior 	:= 299//150
Local nDireita		:= 680//243
Local nX			:= 0
Local cLinOk		:= "AllwaysTrue"
Local cTudoOk		:= "AllwaysTrue"
Local cDelOk		:= "AllwaysFalse"
Local cFieldOk		:= "AllwaysTrue"
Local cPermissao	:= GetNewPar("RB_REVJUR","000001/000000")
Local oSay1
Local bRefresh		:= {|| oDlg1:Refresh() }
Local bGDRefresh  	:= {|| oGetDad:oBrowse:Refresh() }
Local aHeader		:= {}
Local aSize			:= MsAdvSize()		//Tamanhos da tela

Local aFields 		:= {"CJ_NUM","CJ_EMISSAO","CJ_CLIENTE","CJ_LOJA","A1_NOME","CJ_CONDPAG","CK_VALOR","CJ_XACRESC","CK_PRCVEN","CK_PRUNIT"}
Local aAlter		:= {"CJ_XACRESC"}
Local aCols  		:= {}
Private oGetDad
Private oDlg1

If !__cUserId $ cPermissao
	Aviso("Atenção","Usuário sem acesso à rotina!",{"OK"})
	Return
Endif

//Abre a tela para selecionar os parâmetros
CriaPerg("REVORCTO")
If !Pergunte("REVORCTO",.T.)      
	Return
Endif

//Localiza os orçamentos
cQry:= "SELECT CJ_NUM, CJ_EMISSAO, CJ_CLIENTE, CJ_LOJA, A1_NOME,  CONCAT(E4_CODIGO,' - ',E4_DESCRI) COND, CJ_XACRESC, SUM(CK_VALOR)* (CJ_XACRESC/100) JUROS, SUM(CK_VALOR) VALOR "
cQry+= "From "+RetSqlName("SCJ")+" SCJ "
cQry+= "Inner Join "+RetSqlName("SCK")+" SCK on CK_FILIAL = CJ_FILIAL AND CK_NUM = CJ_NUM AND SCK.D_E_L_E_T_ = ' ' "
cQry+= "Inner Join "+RetSqlName("SA1")+" SA1 on A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = CJ_CLIENTE AND A1_LOJA = CJ_LOJA AND SA1.D_E_L_E_T_ = ' ' "
cQry+= "Inner Join "+RetSqlName("SE4")+" SE4 on E4_FILIAL = '"+xFilial("SE4")+"' AND E4_CODIGO = CJ_CONDPAG AND SE4.D_E_L_E_T_ = ' ' "
cQry+= "Where CJ_FILIAL = '"+xFilial("SCJ")+"' "
If !Empty(mv_par02)
	cQry+= "And CJ_EMISSAO between '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' "
Endif
If !Empty(mv_par04)
	cQry+= "And CJ_NUM between '"+mv_par03+"' and '"+mv_par04+"' "
Endif
cQry+= "And CJ_STATUS = 'A' "
cQry+= "And SCJ.D_E_L_E_T_ = ' ' "
cQry+= "Group by CJ_NUM, CJ_EMISSAO, CJ_CLIENTE, CJ_LOJA, A1_NOME,  CONCAT(E4_CODIGO,' - ',E4_DESCRI), CJ_XACRESC "
cQry+= "Order by CJ_NUM "
If Select("QRY") > 0
	QRY->(dbCloseArea())
Endif
TcQuery cQry New Alias "QRY"	

While QRY->(!Eof()) 
	
	//Monta o aCols com os campos da SE2
	aAdd(aCols, {QRY->CJ_NUM, dtoc(stod(QRY->CJ_EMISSAO)), QRY->CJ_CLIENTE, QRY->CJ_LOJA, QRY->A1_NOME, QRY->COND,  QRY->VALOR, QRY->CJ_XACRESC, QRY->JUROS, QRY->VALOR+QRY->JUROS, .F.})
	
	QRY->(dbSkip())
End
QRY->(dbCloseArea())

If Len(aCols) = 0
	Aviso("Atenção","Não foram encontrados registros para os parâmetros informados!",{"OK"})
	Return
Endif


//Monta o aHeader buscando na SX3 as propriedades dos campos do array aFields
dbSelectArea("SX3")
SX3->(dbSetOrder(2))
For nX := 1 to Len(aFields) 
	If SX3->(dbSeek(aFields[nX]))
		If aFields[nx] = "CK_PRCVEN"
			cTitulo:= "Vlr Acréscimo"
		Elseif aFields[nx] = "CK_PRUNIT"
			cTitulo:= "Novo Total"
		Else
			cTitulo:= AllTrim(X3_Titulo)
		Endif

		Aadd(aHeader,{ cTitulo,SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,; //"AllwaysTrue()" 
		SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO}) 
	Endif
Next nX

DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD

//Monta a tela
DEFINE MSDIALOG oDlg1 TITLE "Revisão de Acréscimo" FROM aSize[7],0 To aSize[6],aSize[5]  COLORS 0,16777215 PIXEL Style 128//retira o [x] da janela
//DEFINE MSDIALOG oDlg1 TITLE "Revisão de Juros" FROM 000, 000  TO 700, 960 COLORS 0,16777215 PIXEL Style 128//retira o [x] da janela
	@ 005,005 SAY oSay1 PROMPT "Informe o novo percentual de acréscimo"	 SIZE 250, 030 OF oDlg1 FONT oBold COLORS CLR_BLUE, 16777215 PIXEL 
   	
	// Ação a ser executada nos botões OK ou CANCELA
	//@ 157,160 BmpButton Type 1 Action {U_GravaJur(), Close(oDlg1)}
	//@ 157,200 BmpButton Type 2 Action (Close(oDlg1))

	//Criação do Grid
	oGetDad := MsNewGetDados():New(nSuperior, nEsquerda, nInferior, nDireita, GD_INSERT+GD_UPDATE, cLinOk, cTudoOk, , aAlter,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg1, aHeader, aCols)
	
	Eval(bGDRefresh)//Atualiza Grid    
	Eval(bRefresh)  //Atualiza Tela 
		
//ACTIVATE MSDIALOG oDlg1 CENTERED 	
ACTIVATE DIALOG oDlg1 CENTERED ON INIT EnchoiceBar(oDlg1,{|| U_GravaJur(),Close(oDlg1)},{||Close(oDlg1)})
	
Return


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------- ------------------------------------------+¦¦
¦¦¦Descriçäo ¦  Gravação do novo percentual de juros no orçamento		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function GravaJur()
Local i:= 0
Local aCols:= oGetDad:aCols
Local aHeader:= oGetDad:aHeader
Local nPosJur:= aScan(aHeader,{|x| AllTrim(x[2])=="CJ_XACRESC"})

For i:= 1 to Len(aCols)
	//Posiciona no registro
	SCJ->(dbSeek(xFilial("SCJ")+aCols[i,1]))
	If aCols[i,nPosJur] <> SCJ->CJ_XACRESC
		
		//Inclui novo registro
		Reclock("SCJ",.F.)
			SCJ->CJ_XACRESC:= aCols[i,nPosJur]
		SCJ->(msUnlock())			
	Endif
Next

Aviso("Revisão de Acréscimo","Atualização finalizada!",{"OK"})

Return


Static Function CriaPerg(cPerg)
Local aPergs:={} 

Aadd(aPergs,{cPerg,'01',"Emissão De:","Emissão De:","Emissão De:","mv_ch1","D",10,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})                    
Aadd(aPergs,{cPerg,'02',"Emissão Até:","Emissão Até:","Emissão Até:","mv_ch2","D",10,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})                    
Aadd(aPergs,{cPerg,'03',"Orçamento De:","Orçamento De:","Orçamento De:","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})                    
Aadd(aPergs,{cPerg,'04',"Orçamento Até:","Orçamento Até:","Orçamento Até:","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})                    

U_BuscaPerg(aPergs) 

Return

//Validação chamada no campo de acrescimo para atualizar os valores em tela
User Function CalcJrOrc()
Local bGDRefresh  	:= {|| oGetDad:oBrowse:Refresh() }
Local bRefresh		:= {|| oDlg1:Refresh() }
Local nJuros:= M->CJ_XACRESC //aScan(aHeader,{|x| AllTrim(x[2])=="CJ_XACRESC"})
Local nPosValJur:= aScan(aHeader,{|x| AllTrim(x[2])=="CK_PRCVEN"})
Local nPosTotal:= aScan(aHeader,{|x| AllTrim(x[2])=="CK_VALOR"})
Local nPosNTot:= aScan(aHeader,{|x| AllTrim(x[2])=="CK_PRUNIT"})

aCols[n,nPosNTot] := Round(aCols[n,nPosTotal]+(aCols[n,nPosTotal]*(nJuros/100)),2)
aCols[n,nPosValJur] := Round(aCols[n,nPosTotal]*(nJuros/100),2)

//GdFieldPut("CK_PRUNIT",Round(aCols[n,nPosTotal]+(aCols[n,nPosTotal]*(nJuros/100)),2),n,aHeader,aCols)
//GdFieldPut("CK_PRCVEN",Round(aCols[n,nPosTotal]*(nJuros/100),2),n,aHeader,aCols)

Eval(bGDRefresh)//Atualiza Grid
Eval(bRefresh)//Atualiza tela

Return .T.

