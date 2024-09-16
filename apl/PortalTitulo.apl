#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "RWMAKE.CH"
#include "APWEBEX.CH"
#INCLUDE "TOPCONN.CH"

/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! WEB                                                     !
+------------------+---------------------------------------------------------+
!Nome              ! Portal                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Portal Web para Aprovação de Workflow                   !
+------------------+---------------------------------------------------------+
!Autor             ! Anderson José Zelenski                                  !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 08/12/2010                                              !

/****************************************************************************
Fun��o chamada diretamente pelo browser
****************************************************************************/

User Function PortalTitulo()
Local cHtml
Private cFulano := HttpSession->NomeFull


Web Extended Init cHtml // Start U_inSite()
	cHtml := H_PortalTitulo()
Web Extended end

return (cHTML)