#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MA030TOK
Valida��o altera��o/inclus�o de clientes

@return 
@author Lucilene Mendes - SMSTI
@since 07/05/2021
/*/
//-------------------------------------------------------------------------------
User Function MA030TOK()
Local lExecuta	:= .T.
Local cMsg		:= "Um ou mais campos obrigat�rios n�o foram preenchidos: " + CRLF

	If ALTERA
		If Empty(M->A1_TABELA)
			lExecuta	:= .F.
			cMsg		+= "Aba Vendas -> Tabela Pre�o" + CRLF
		Endif
	Endif

	If !lExecuta
		Aviso("Campo obrigat�rio",cMsg,{"Ok"},2)
	EndIf	

Return lExecuta
