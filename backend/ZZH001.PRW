#Include "TOTVS.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "FWMVCDef.ch"

User Function ZZH001()
	FWFormRun("ZZH001")
Return

// ---------------------------
// MODELDEF
// ---------------------------
Static Function ModelDef()
	Local oModel := FWFormModel():New()

	oModel:AddFields("ZZH", /* Alias da tabela de subtarefas */, NIL, NIL, .T.)

	oModel:SetPrimaryKey({"ZZH_FILIAL", "ZZH_CODIGO"})
	oModel:CreateView("VIEW_ZZH", "ZZH")

	oModel:GetField("ZZH.ZZH_CODTAR"):SetRequired(.T.)
	oModel:GetField("ZZH.ZZH_DESCRI"):SetRequired(.T.)
	oModel:GetField("ZZH.ZZH_RESPON"):SetRequired(.T.)
	oModel:GetField("ZZH.ZZH_STATUS"):SetRequired(.T.)

	oModel:SetBeforePost({|oModel| ValidaSubTarefa(oModel)})

Return oModel

// ---------------------------
// VIEWDEF
// ---------------------------
Static Function ViewDef()
	Local oView := FWFormView():New()
	Local oGroup := oView:AddGroup("Subtarefa")

	oGroup:AddField("ZZH.ZZH_CODIGO", "Código")
	oGroup:AddField("ZZH.ZZH_CODTAR", "Tarefa Relacionada")
	oGroup:AddField("ZZH.ZZH_DESCRI", "Descrição")
	oGroup:AddField("ZZH.ZZH_RESPON", "Responsável")
	oGroup:AddField("ZZH.ZZH_STATUS", "Status")
	oGroup:AddField("ZZH.ZZH_DTCONC", "Data Conclusão")

Return oView

// ---------------------------
// MENUDEF
// ---------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Subtarefas" ACTION "ZZH001" OPERATION 1 ACCESS 0

Return aRotina

// ---------------------------
// VALIDAÇÃO DE SUBTAREFA
// ---------------------------
Static Function ValidSub(oModel)
	Local cStatus := oModel:GetValue("ZZH_STATUS")
	Local dData := oModel:GetValue("ZZH_DTCONC")

	If cStatus == "3" // Concluída
		If Empty(dData)
			MSGAlert("Data de conclusão é obrigatória para subtarefa concluída.")
			Return .F.
		EndIf
	EndIf

Return .T.
