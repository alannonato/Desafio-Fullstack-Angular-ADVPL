#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.CH"
#INCLUDE "FWMVCDEF.CH"

User Function ZZG001()
	FWFormRun("ZZG001")
Return

// ---------------------------
// MODELDEF - LÓGICA
// ---------------------------
Static Function ModelDef()
	Local oModel := FWFormModel():New()

	oModel:AddFields("ZZG", /* Alias da tabela de tarefas */, NIL, NIL, .T.)
	oModel:AddFields("ZZH", /* Alias da subtabela */, NIL, NIL, .T.)

	oModel:SetPrimaryKey({"ZZG_FILIAL", "ZZG_CODIGO"})
	oModel:CreateView("VIEW_ZZG", "ZZG")

	//Validação de campos
	oModel:GetField("ZZG_TITULO"):SetRequired(.T.)
	oModel:GetField("ZZG_DESCRI"):SetRequired(.T.)
	oModel:GetField("ZZG_SITUAC"):SetRequired(.T.)
	oModel:GetField("ZZG_USUINC"):SetRequired(.T.)
	oModel:GetField("ZZG_DTINC"):SetRequired(.T.)

	// Validação de conclusão
	oModel:SetBeforePost({|oModel| ValidConc(oModel)})

Return oModel

// ---------------------------
// VIEWDEF - INTERFACE
// ---------------------------
Static Function ViewDef()
	Local oView := FWFormView():New()
	Local oGroup := oView:AddGroup("Tarefa")

	oGroup:AddField("ZZG.ZZG_CODIGO", "Código")
	oGroup:AddField("ZZG.ZZG_TITULO", "Título")
	oGroup:AddField("ZZG.ZZG_DESCRI", "Descrição")
	oGroup:AddField("ZZG.ZZG_SITUAC", "Situação")
	oGroup:AddField("ZZG.ZZG_USUINC", "Usuário")
	oGroup:AddField("ZZG.ZZG_DTINC", "Data de Inclusão")
	oGroup:AddField("ZZG.ZZG_DTCONC", "Data de Conclusão")

Return oView
// ---------------------------
// MENUDEF - MENU
// ---------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Tarefas" ACTION "ZZG001" OPERATION 1 ACCESS 0

Return aRotina

// ---------------------------
// VALIDAÇÕES
// ---------------------------
Static Function ValidConc(oModel)
	Local cStatus := oModel:GetValue("ZZG_SITUAC")
	Local dInclusao := oModel:GetValue("ZZG_DTINC")
	Local dConclusao := oModel:GetValue("ZZG_DTCONC")

	// Verifica se está concluindo
	If cStatus == "3" // 3 = Concluída
		If !SubtarConc(oModel:GetValue("ZZG_CODIGO"))
			MSGAlert("Não é possível concluir a tarefa com subtarefas pendentes.")
			Return .F.
		EndIf
	EndIf

	//Valida data
	If !Empty(dConclusao) .And. dConclusao < dInclusao
		MSGAlert("Data de Conclusão não pode ser menor que a de Inclusão.")
		Return .F.
	EndIf

Return .T.

Static Function SubtarConc(cCodigoTarefa)
	Local lOK := .T.
	Local cAlias := GetNextAlias()

	DbUseArea(.T., , "ZZH", cAlias, .F., .F.)
	DbSelectArea(cAlias)
	DbSetOrder(1)
	DbSeek(xFilial("ZZH") + cCodigoTarefa)

	While !EOF() .And. (ZZH->ZZH_CODTAR == cCodigoTarefa)
		If ZZH->ZZH_STATUS != "3"
			lOK := .F.
			Exit
		EndIf
		DbSkip()
	EndDo
	DbCloseArea()

Return lOK
