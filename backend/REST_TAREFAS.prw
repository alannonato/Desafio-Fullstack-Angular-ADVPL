#Include "TOTVS.CH"
#Include "RESTFul.ch"

WsRestFul tarefas Description 'API PARA MANIPULAR AS TAREFAS'

	WsMethod GET tarefa Description 'retorna a tarefa' path '/'
	WsMethod POST tarefa Description 'retorna a tarefa' path '/tarefa'
End WsRestFul

WSMETHOD POST tarefa WsService tarefas
	LOCAL oRequest     := FWGetRequest()
	LOCAL oResponse    := FWGetResponse()
	LOCAL oJson        := JsonObject():New()
	LOCAL cTitulo      := ""
	LOCAL cDescricao   := ""
	LOCAL cSituacao    := ""
	LOCAL dDtConclusao := Ctod("")
	LOCAL dDtInclusao  := DtoS(Date()) // Data atual como padrão
	LOCAL cUsuario     := __cUserId
	LOCAL cCodigo      := ""
	LOCAL lSucesso     := .F.
	LOCAL cMsgErro     := ""

	BEGIN SEQUENCE

		// Lê o JSON do corpo da requisição
		oJson := JsonObject():New(oRequest:GetBody())

		cTitulo      := AllTrim(oJson:GetValue("titulo"))
		cDescricao   := AllTrim(oJson:GetValue("descricao"))
		cSituacao    := AllTrim(oJson:GetValue("situacao"))
		dDtConclusao := CTOD(oJson:GetValue("dataConclusao"))
		dDtInclusao  := CTOD(oJson:GetValue("dataInclusao"))

		// Validações obrigatórias
		IF Empty(cTitulo)
			cMsgErro := "Campo Titulo é obrigatório."
			BREAK
		ENDIF

		IF Empty(cDescricao)
			cMsgErro := "Campo Descrição é obrigatório."
			BREAK
		ENDIF

		IF !(cSituacao $ "1234")
			cMsgErro := "Campo Situação inválido. Use 1, 2, 3 ou 4."
			BREAK
		ENDIF

		IF Empty(cUsuario)
			cMsgErro := "Usuário não identificado."
			BREAK
		ENDIF

		IF Empty(dDtInclusao)
			dDtInclusao := Date()
		ENDIF

		// Gera código automático (usando controle de numeração)
		cCodigo := FWGerarCodigo("ZZG") // Requer controle cadastrado no SIGACFG

		dbUseArea(.T., "TOPCONN", "ZZG", "ZZG", .F., .F.)
		dbAppend()

		ZZG->ZZG_CODIGO := cCodigo
		ZZG->ZZG_TITULO := cTitulo
		ZZG->ZZG_DESCRI := cDescricao
		ZZG->ZZG_SITUAC := cSituacao
		ZZG->ZZG_DTINC  := dDtInclusao
		ZZG->ZZG_DTCONC := dDtConclusao
		ZZG->ZZG_USUINC := cUsuario


		dbCommit()
		dbCloseArea()

		lSucesso := .T.

	END SEQUENCE

	// Resposta
	IF lSucesso
		oResponse:SetStatus(201)
		oResponse:SetContentType("application/json")
		oResponse:SendResponse( '{"mensagem":"Tarefa salva com sucesso","codigo":"' + cCodigo + '"}' )
	ELSE
		oResponse:SetStatus(400)
		oResponse:SetContentType("application/json")
		oResponse:SendResponse( '{"erro":"' + cMsgErro + '"}' )
	ENDIF

RETURN .T.
