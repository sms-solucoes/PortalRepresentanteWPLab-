#include 'protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} fBuscaCep
Função para buscar o CEP, via webserce com retorno em JSON.
@author     Jerfferson Silva
@since      15.03.2019
@version	1.0
@param      cCEP, caracter, Cep sem o '-' apenas os numeros.
/*/
//-------------------------------------------------------------------
User Function fBuscaCep(cCEP,lJob)
Local cUrl			:= "http://viacep.com.br/ws/"
Local cGetParams	:= ""
Local nTimeOut		:= 200
Local aHeadStr		:= {"Content-Type: application/json"}
Local cHeaderGet	:= ""
Local cRetWs		:= ""
Local oObjJson		:= Nil
Local cStrResul		:= ""
Local aRet          := {}
Local xRet          := nil
Default lJob        := .F.

	If fValidarCep(cCep,@cUrl) .or. lJob
		cRetWs	:= HttpGet(cUrl, cGetParams, nTimeOut, aHeadStr, @cHeaderGet)
		If !FWJsonDeserialize(cRetWs, @oObjJson)
			If lJob
                aAdd(aRet,.F.)
                aAdd(aRet,"Falha na consulta do CEP!")
                Return aRet
            Else
                MsgStop("Ocorreu erro no processamento do Json.")
                Return Nil
			Endif
            
		ElseIf AttIsMemberOf(oObjJson,"ERRO")
			If lJob
                aAdd(aRet,.F.)
                aAdd(aRet,"CEP não encontrado na base de dados.")
                Return aRet
            Else
                MsgStop("CEP inexistente na base de dados.")
                Return Nil
            Endif 
		Else
			If lJob
                aAdd(aRet,.T.)
                aAdd(aRet,DecodeUTF8(oObjJson:uf))
                aAdd(aRet,DecodeUTF8(oObjJson:ibge))
                aAdd(aRet,DecodeUTF8(oObjJson:localidade))
                aAdd(aRet,DecodeUTF8(oObjJson:logradouro))
                aAdd(aRet,DecodeUTF8(oObjJson:bairro))
                xRet:= aRet
            Else        
                cStrResult := DecodeUTF8(oObjJson:logradouro) + ", "
                cStrResult += DecodeUTF8(oObjJson:complemento) + ", "
                cStrResult += DecodeUTF8(oObjJson:bairro) + ", "
                cStrResult += DecodeUTF8(oObjJson:localidade) + "/"
                cStrResult += DecodeUTF8(oObjJson:uf) + ",  CEP: "
                cStrResult += DecodeUTF8(oObjJson:cep) + ", Cód. IBGE: "
                cStrResult += DecodeUTF8(oObjJson:ibge) + ", "
                AVISO("Consulta CEP - WS ViaCEP", cStrResult, {"Fechar"}, 2)
                xRet:= cStrResult
            Endif    
		EndIf
	EndIf
Return (xRet)
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} fValidarCep
Função para validação do cep
@author     Jerfferson Silva
@since      15.03.2019
@param 		cCep, caracter, Cep pra consulta
@param 		cUrl, caracter, Url do serviço
@return 	lRet, logico, Retorno .T. (true) se cep valido ou .F. (false) se invalido.
/*/
//-------------------------------------------------------------------------------------
Static Function fValidarCep(cCep,cUrl)
	Local lRet := .F.
	If Empty(Alltrim(cCep)) //Validar se foi passado conteudo é vazio.
		MsgStop("Favor informar o CEP.")
		Return (lRet)
	ElseIf Len(Alltrim(cCep)) < 8 //Validar se o CEP informado tem menos 8 digitos.
		MsgStop("O CEP informado não contem a quantidade de dígito correta, favor informe um CEP válido.")
		Return (lRet)
	ElseIf At("-",cCep,) > 0 //Validar se o CEP está separado por "-".
		If Len(StrTran(AllTrim(cCep),"-")) == 8 //Validar se o CEP informado tem 8 digitos.
			cUrl += StrTran(AllTrim(cCep),"-")+"/json/"
			lRet := .T.
		Else
			MsgStop("O CEP informado não contem a quantidade de dígito correta, favor informe um CEP válido.")
			Return (lRet)
		EndIf
	Else
		cUrl += AllTrim(cCep)+"/json/"
		lRet := .T.
	EndIf
Return (lRet)
