#INCLUDE 'protheus.ch'
#INCLUDE "restful.ch"
#INCLUDE "TOTVSWebSrv.ch"
#include "apwebsrv.ch"
#INCLUDE "PRTOPDEF.CH"

/*                                           
+------------------+-------------------------------------------------------------------------------+
! Nome             ! WSTAREFAS                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração do WebService WSTAREFAS                                            !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! ALAN NONATO                                                                   !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 09/06/2025                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/  

WsRestful Tarefas Description 'MANIPULAÇÃO DE TAREFAS.'

	WSDATA codigo AS STRING
	WSDATA titulo AS STRING
	WSDATA descric AS STRING
	WSDATA situac  AS STRING
	WSDATA usuinc AS STRING
	WSDATA dtconc AS STRING
	WSDATA dtinc  AS STRING

	WSMETHOD GET TAREFAS 	DESCRIPTION "BUSCA TAREFAS"   		WSSYNTAX "/tarefas" 		PATH "/TAREFAS"	TTalk "v1" PRODUCES APPLICATION_JSON
	WSMETHOD POST TAREFA   DESCRIPTION "INSERINDO UMA TAREFA"  WSSYNTAX "/novatarefa"      PATH "/NOVATAREFA" TTalk "v1" CONSUMES APPLICATION_JSON PRODUCES APPLICATION_JSON

END WsRestful

// Método GET para buscar tarefas (exemplo simplificado)
WSMETHOD GET WSSERVICE Tarefas
	Local oResponse := JsonObject():New()

	oResponse:Add("tarefas", Array())

	// Defina a resposta do serviço em JSON
	Self:SetResponse(oResponse:ToString())
Return

// Método POST para incluir nova tarefa com subtarefas
WSMETHOD POST WSSERVICE NovaTarefa
	Local oRequest := Self:GetRequestBody() // Obtem o corpo da requisição JSON
	Local oResponse := JsonObject():New()
	Local lSuccess := .F.
	Local cMsg := ""
	Local cCodigo := ""

	// Campos da tarefa
	Local cTitulo, cDescric, cSituac, cUsuInc, cDtConc, cDtInc
	Local aSubtarefas := {}

	//campos da requisição
	cTitulo := IIF(oRequest:Has("titulo"), oRequest:Get("titulo"), "")
	cDescric := IIF(oRequest:Has("descric"), oRequest:Get("descric"), "")
	cSituac  := IIF(oRequest:Has("situac"), oRequest:Get("situac"), "")
	cUsuInc  := IIF(oRequest:Has("usuinc"), oRequest:Get("usuinc"), "")
	cDtConc  := IIF(oRequest:Has("dtconc"), oRequest:Get("dtconc"), "")
	cDtInc   := IIF(oRequest:Has("dtinc"), oRequest:Get("dtinc"), "")
	aSubtarefas := IIF(oRequest:Has("subtarefas"), oRequest:Get("subtarefas"), {})

	// Validação simples
	If Empty(cTitulo)
		oResponse:Add("success", False)
		oResponse:Add("message", "Campo 'titulo' é obrigatório.")
		Self:SetResponse(oResponse:ToString())
		Return
	EndIf

	// Gera código único para a tarefa
	cCodigo := StrZero( Int(TotpDateTime()), 14 ) // número único para código

	// Chama a função para inserir a tarefa e subtarefas
	lSuccess := newTaref(cCodigo, cTitulo, cDescric, cSituac, cUsuInc, cDtConc, cDtInc, aSubtarefas, @cMsg)

	oResponse:Add("success", lSuccess)
	oResponse:Add("message", cMsg)
	oResponse:Add("codigo", cCodigo)

	Self:SetResponse(oResponse:ToString())
Return

// Função moderna para inserir tarefa e subtarefas
USER FUNCTION newTaref(cCodigo, cTitulo, cDescric, cSituac, cUsuInc, cDtConc, cDtInc, aSubtarefas, @cMsg)
	Local lSuccess := .F.
	Local lOpenedZZG := .F.
	Local lOpenedZZH := .F.
	Local nAreaZZG := NIL
	Local nAreaZZH := NIL
	Local nCount := Len(aSubtarefas)
	Local lInTransaction := .F.


	// Abre área ZZG e posiciona por código
	nAreaZZG := DbUseArea(.T.,, "ZZG", "ZZG", .F.)
	If nAreaZZG == NIL
		cMsg := "Falha ao abrir tabela ZZG."
		Return .F.
	EndIf
	lOpenedZZG := .T.

	DbSetOrder(1) // Ajuste para o índice correto de "CODIGO"
	If DbSeek(cCodigo)
		// Já existe essa tarefa
		cMsg := "Já existe uma tarefa com este código."
		DbCloseArea()
		Return .F.
	EndIf

	// Abre área ZZH para subtarefas
	nAreaZZH := DbUseArea(.T.,, "ZZH", "ZZH", .F.)
	If nAreaZZH == NIL
		cMsg := "Falha ao abrir tabela ZZH."
		Return .F.
	EndIf
	lOpenedZZH := .T.

	// Inicia transação
	BEGIN TRANSACTION
		lInTransaction := .T.

		// Insere tarefa em ZZG
		DbSelectArea(nAreaZZG)
		DbAppend()
		FieldPut(OrdField("CODIGO"), cCodigo)
		FieldPut(OrdField("TITULO"), cTitulo)
		FieldPut(OrdField("DESCRIC"), cDescric)
		FieldPut(OrdField("SITUAC"),  cSituac)
		FieldPut(OrdField("USUINC"), cUsuInc)
		FieldPut(OrdField("DTCONC"), cDtConc)
		FieldPut(OrdField("DTINC"),  cDtInc)
		// Bloqueia registro atual para evitar concorrência
		If !FieldLock(OrdField("CODIGO"))
			DbRollback()
			cMsg := "Erro ao bloquear registro da tarefa."
			Return .F.
		EndIf
		DbCommit()

		// Insere subtarefas em ZZH
		If nCount > 0
			DbSelectArea(nAreaZZH)
			For Local nI := 1 To nCount
				DbAppend()
				FieldPut(OrdField("CODIGO"), cCodigo)
				// Assumindo que as subtarefas vêm com "titulo" e "situac"
				FieldPut(OrdField("SUBTITULO"), aSubtarefas[nI]["titulo"])
				FieldPut(OrdField("SITSUBT"), aSubtarefas[nI]["situac"])
				// Bloqueia para prevenir concorrência
				If !FieldLock(OrdField("CODIGO"))
					DbRollback()
					cMsg := "Erro ao bloquear registro da subtarefa."
					Return .F.
				EndIf
			Next
		EndIf

		// Confirma transação
		DbCommit()
		cMsg := "Tarefa e subtarefas inseridas com sucesso."
		lSuccess := .T.

	Catch oErr
		// Em caso de erro, faz rollback se estiver em transação
		If lInTransaction
			DbRollback()
		EndIf
		cMsg := "Erro ao inserir tarefa: " + oErr:Description
		lSuccess := .F.

		Finally
		// Fecha áreas abertas
		If lOpenedZZH
			DbCloseArea()
		EndIf
		If lOpenedZZG
			DbCloseArea()
		EndIf

	END TRANSACTION

Return lSuccess

return
