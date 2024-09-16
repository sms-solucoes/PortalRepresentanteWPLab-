#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ ImprOrcto   ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦14.09.20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Impressão de orçamento para o portal     				  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function ImprOrcto(nRecOrc)
Local oPrint
Local cFilePrint    := ""
Local cFilePdf      := ""
Local cContinua     := ""
Local cNewDir       := "\anexosPortal\orcamentos\"
Local cFileLogo     := "\web\PortalSMS\images\logo.png"
Local nRow          := 0
Local nPosFrete     := 0
Local nUnitario     := 0
Local nTQtdItem     := 0
Local nImpostos     := 0
Local nTotal        := 0
Local nPosDescri    := 0
Local aTpFrete      := {}
Local aTipoOrc      := {}


dbSelectArea("SCJ")
SCJ->(dbGoto(nRecOrc))

cFilePrint	:='orcamento_'+SCJ->CJ_FILIAL+"_"+SCJ->CJ_NUM+"_"+dtos(date())+StrTran(time(),":","")+'.REL'
cFilePdf	:= substr(cFilePrint,1,len(cFilePrint)-4)+".pdf"

oPrint := FWMSPrinter():New(cFilePrint,IMP_PDF, .t.,cNewDir , .t.,,,,,.f.)
oPrint:SetResolution(78) //Tamanho estipulado para a Danfe
oPrint:SetPortrait()
oPrint:SetPaperSize(9)
oPrint:SetMargin(60,60,60,60)
oPrint:setDevice(IMP_PDF)
oPrint:lServer 	:= .t.
oPrint:cPrinter	:= ""

oPrint:nDevice := IMP_PDF
oPrint:cPathPDF := cNewDir

WFFORCEDIR(cNewDir)
oPrint:SetViewPDF(.F.)


//Parametros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
oFont8   := TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
oFont24  := TFont():New("Arial",9,24,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24n := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:StartPage()   // Inicia uma nova página

//Imprime a logo
nRow+= 50
oPrint:SayBitmap  (nRow,100,cFileLogo,390,090)
nRow+= 080
oPrint:Say(nRow,800,"ORÇAMENTO DE VENDA "+SCJ->CJ_NUM,oFont24n)
nRow+= 30
oPrint:Line (nRow,100,nRow, 2300)
nRow+= 120
oPrint:Say(nRow,100,"Emissão:",oFont14n)
oPrint:Say(nRow,300,DTOC(SCJ->CJ_EMISSAO),oFont14)

oPrint:Say(nRow,0730,"Previsão Faturamento:",oFont14n)
oPrint:Say(nRow,1150,DTOC(SCK->CK_ENTREG),oFont14)

oPrint:Say(nRow,1580,"Tipo do Orçamento:",oFont14n)
aTipoOrc:= {{"1","Previsto"},{"2","Firme"},{"3","Em elaboração"}}
oPrint:Say(nRow,1960,Upper(aTipoOrc[aScan(aTipoOrc,{|x|x[1]==SCJ->CJ_XTPORC}),2]),oFont14)


nRow+= 050
oPrint:Say(nRow,100,"Cliente:",oFont14n)
oPrint:Say(nRow,300,SCJ->CJ_CLIENTE+'/'+SCJ->CJ_LOJA+' - '+Upper(Posicione("SA1",1,xFilial("SA1")+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA,"A1_NOME")),oFont14)
nRow+= 050
oPrint:Say(nRow,100,"Endereço:",oFont14n)
oPrint:Say(nRow,300,Upper(Alltrim(SA1->A1_END)+" "+Alltrim(SA1->A1_COMPLEM)+" - "+Alltrim(SA1->A1_MUN)+" / "+Alltrim(SA1->A1_EST)),oFont14)
nRow+= 050
oPrint:Say(nRow,100,"Telefone:",oFont14n)
oPrint:Say(nRow,300,"("+Alltrim(SA1->A1_DDD)+") "+SA1->A1_TEL,oFont14)
nRow+= 050
oPrint:Say(nRow,100,"E-mail:",oFont14n)
oPrint:Say(nRow,300,Lower(SA1->A1_EMAIL),oFont14)
nRow+= 30
oPrint:Line (nRow,100,nRow, 2300)

nRow+= 050
oPrint:Say(nRow,100,"Modalidade:",oFont14n)
oPrint:Say(nRow,370,Upper(Posicione("SX5",1,xFilial("SX5")+'ZE'+SCJ->CJ_XMODALI,"X5_DESCRI")),oFont14)

oPrint:Say(nRow,1000,"Condição de Pagamento:",oFont14n)
oPrint:Say(nRow,1500,Upper(Posicione("SE4",1,xFilial("SE4")+SCJ->CJ_CONDPAG,"E4_DESCRI")),oFont14)

nRow+= 050
oPrint:Say(nRow,100,"Tipo de Frete:",oFont14n)
aTpFrete:= {{"S","Sem Frete"},{"C","CIF"},{"F","FOB"}}
nPosFrete:= aScan(aTpFrete,{|x|x[1]==SCJ->CJ_TPFRETE})
oPrint:Say(nRow,370,Upper(aTpFrete[nPosFrete,2]),oFont14)

oPrint:Say(nRow,1000,"Tranportadora:",oFont14n)
oPrint:Say(nRow,1500,Upper(Posicione("SA4",1,xFilial("SA4")+SCJ->CJ_XTRANSP,"A4_NOME")),oFont14)

nRow+= 100
//Tabela com os itens
oPrint:Line (nRow,100,nRow, 2300)//--
oPrint:Line (nRow,100,nRow+60, 100)//|__
oPrint:Line (nRow+60,100,nRow+60, 2300) //__
oPrint:Line (nRow,2300,nRow+60, 2300) //__|

oPrint:Say(nRow+40,110,"ITEM",oFont12)
oPrint:Line (nRow,220,nRow+60, 220)//|

oPrint:Say(nRow+40,230,"CÓDIGO",oFont12)
oPrint:Line (nRow,400,nRow+60, 400)//|

oPrint:Say(nRow+40,410,"DESCRIÇÃO",oFont12)
//oPrint:Line (nRow,1200,nRow+60, 1200)//|

oPrint:Say(nRow+40,1360,"QUANT.",oFont12)
oPrint:Line (nRow,1350,nRow+60, 1350)//|

oPrint:Say(nRow+40,1520,"VLR.UNIT.",oFont12)
oPrint:Line (nRow,1500,nRow+60, 1500)//|

oPrint:Say(nRow+40,1715,"ICMS ST",oFont12)
oPrint:Line (nRow,1690,nRow+60, 1690)//|

oPrint:Say(nRow+40,1950,"IPI",oFont12)
oPrint:Line (nRow,1880,nRow+60, 1880)//|

oPrint:Say(nRow+40,2120,"TOTAL",oFont12)
oPrint:Line (nRow,2070,nRow+60, 2070)//|

nRow+= 40
//Itens
SCK->(dbSetOrder(1))
SCK->(dbSeek(SCJ->CJ_FILIAL+SCJ->CJ_NUM))
While SCK->(!Eof() .and. SCK->CK_FILIAL+SCK->CK_NUM = SCJ->CJ_FILIAL+SCJ->CJ_NUM)
    
    cContinua:= ""
    oPrint:Line (nRow,100,nRow+60, 100)//|__
    oPrint:Line (nRow,220,nRow+60, 220)//|
    oPrint:Line (nRow,2300,nRow+60, 2300) //__|
    oPrint:Line (nRow,400,nRow+60, 400)//|
    oPrint:Line (nRow,1350,nRow+60, 1350)//|
    oPrint:Line (nRow,1500,nRow+60, 1500)//|
    oPrint:Line (nRow,1690,nRow+60, 1690)//|
    oPrint:Line (nRow,1880,nRow+60, 1880)//|
    oPrint:Line (nRow,2070,nRow+60, 2070)//|

    nRow+= 50
    oPrint:Say(nRow,110,SCK->CK_ITEM,oFont12)
    oPrint:Say(nRow,230,SCK->CK_PRODUTO,oFont12)
    
    If Len(Alltrim(SCK->CK_DESCRI)) > 40
        nPosDescri:= At(" ",Substr(Alltrim(SCK->CK_DESCRI),40))
        oPrint:Say(nRow,410,Substr(SCK->CK_DESCRI,1,40+nPosDescri),oFont12)
        cContinua:= Substr(Alltrim(SCK->CK_DESCRI),41+nPosDescri)
    Else
        oPrint:Say(nRow,410,SCK->CK_DESCRI,oFont12)
    Endif    
    oPrint:Say(nRow,1360,Cvaltochar(SCK->CK_QTDVEN),oFont12)
    oPrint:Say(nRow,1510,TransForm(SCK->CK_PRCVEN,"@E 999,999,999.99"),oFont12)

    oPrint:Say(nRow,1700,TransForm(SCK->CK_XICMST,"@E 999,999,999.99"),oFont12)
    oPrint:Say(nRow,1890,TransForm(SCK->CK_XVALIPI,"@E 999,999,999.99"),oFont12)
    oPrint:Say(nRow,2080,TransForm(SCK->CK_VALOR+SCK->CK_XVALIPI+SCK->CK_XICMST,"@E 999,999,999.99"),oFont12)
    
    If !Empty(cContinua) //Imprime a continuação da descrição
        
        oPrint:Line (nRow,100,nRow+60, 100)//|__
        oPrint:Line (nRow,220,nRow+60, 220)//|
        oPrint:Line (nRow,2300,nRow+60, 2300) //__|
        oPrint:Line (nRow,400,nRow+60, 400)//|
        oPrint:Line (nRow,1350,nRow+60, 1350)//|
        oPrint:Line (nRow,1500,nRow+60, 1500)//|
        oPrint:Line (nRow,1690,nRow+60, 1690)//|
        oPrint:Line (nRow,1880,nRow+60, 1880)//|
        oPrint:Line (nRow,2070,nRow+60, 2070)//|
        nRow+= 40
        oPrint:Say(nRow,410,cContinua,oFont12)
    Endif
    nUnitario+= Round(SCK->CK_QTDVEN * SCK->CK_PRCVEN,2)
    nTQtdItem += SCK->CK_QTDVEN
    nImpostos+=  SCK->(CK_XICMST+CK_XVALIPI)
    nTotal+= SCK->(CK_VALOR+CK_XVALIPI+CK_XICMST) 
    SCK->(dbSkip())

    If nRow >= 3050
        nRow+= 10
        oPrint:Line (nRow,100,nRow, 2300) //__ linha final da tabela
        oPrint:EndPage()
        oPrint:StartPage()
        nRow:= 100
        
        //Tabela com os itens
        oPrint:Line (nRow,100,nRow, 2300)//--
        oPrint:Line (nRow,100,nRow+60, 100)//|__
        oPrint:Line (nRow+60,100,nRow+60, 2300) //__
        oPrint:Line (nRow,2300,nRow+60, 2300) //__|

        oPrint:Say(nRow+40,110,"ITEM",oFont12)
        oPrint:Line (nRow,220,nRow+60, 220)//|

        oPrint:Say(nRow+40,230,"CÓDIGO",oFont12)
        oPrint:Line (nRow,400,nRow+60, 400)//|

        oPrint:Say(nRow+40,410,"DESCRIÇÃO",oFont12)
        //oPrint:Line (nRow,1200,nRow+60, 1200)//|

        oPrint:Say(nRow+40,1360,"QUANT.",oFont12)
        oPrint:Line (nRow,1350,nRow+60, 1350)//|

        oPrint:Say(nRow+40,1520,"VLR.UNIT.",oFont12)
        oPrint:Line (nRow,1500,nRow+60, 1500)//|

        oPrint:Say(nRow+40,1715,"ICMS ST",oFont12)
        oPrint:Line (nRow,1690,nRow+60, 1690)//|

        oPrint:Say(nRow+40,1950,"IPI",oFont12)
        oPrint:Line (nRow,1880,nRow+60, 1880)//|

        oPrint:Say(nRow+40,2120,"TOTAL",oFont12)
        oPrint:Line (nRow,2070,nRow+60, 2070)//|

        nRow+= 40

    Endif

End 
nRow+= 10
oPrint:Line (nRow,100,nRow, 2300) //__ linha final da tabela

//Totais
nRow+= 50
oPrint:Say(nRow,100,"Qtde. de Itens:",oFont14n)
oPrint:Say(nRow,380,TransForm(nTQtdItem,"@E 9,999,999.99"),oFont14)

nRow+= 50

oPrint:Say(nRow,100,"Total de Itens:",oFont14n)
oPrint:Say(nRow,380,"R$ "+TransForm(nUnitario,"@E 999,999,999.99"),oFont14)

oPrint:Say(nRow,0730,"Total de Impostos:",oFont14n)
oPrint:Say(nRow,1085,"R$ "+TransForm(nImpostos,"@E 999,999,999.99"),oFont14)

oPrint:Say(nRow,1580,"Total do Orçamento:",oFont14n)
oPrint:Say(nRow,1960,"R$ "+TransForm(nTotal,"@E 999,999,999.99"),oFont14)

oPrint:Print()
FreeObj(oPrint)
oPrint := Nil


Return cNewDir+cFilePdf

