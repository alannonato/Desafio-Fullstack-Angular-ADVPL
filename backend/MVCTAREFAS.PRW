#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'PRTOPDEF.Ch'

User Function MVCTAREF()
	Local oBrowse as object

	//Criação do objeoto Browse
	oBrowse := FWMBrowse():New()

	//Seta o Alias Browse
	oBrowse:SetAlias('ZZG')

	//Seta a descrição do Browse
	oBrowse:SetDescription('Gerenciador de tarefas')

	//Adicao de legendas
	//oBrowse:AddLegend( "U01_STATUS =='A'", "GREEN" , "Aluno Ativo")

	//Grafico
	oBrowse:SetAttach(.T.)

	oBrowse:SetCanSaveArea(.T.)

	//Ativa o Browse
	oBrowse:Activate()

Return

Static Function MenuDef()
	Local aRotina := {}

	//ADD OPTION aRotina TITLE "Pesquisar" 	ACTION "PesqBrw" 			OPERATION 1 ACCESS 0 // "Pesquisar"
	//ADD OPTION aRotina TITLE "Incluir"		ACTION "VIEWDEF.MVCTAREF" 	OPERATION 3	ACCESS 0 // "Incluir"
	//ADD OPTION aRotina TITLE "Alterar"		ACTION "VIEWDEF.MVCTAREF" 	OPERATION 4	ACCESS 0 // "Alterar"
	//ADD OPTION aRotina TITLE "Excluir"		ACTION "VIEWDEF.MVCTAREF" 	OPERATION 5	ACCESS 0 // "Excluir"
	//ADD OPTION aRotina TITLE "Visualizar"	ACTION "VIEWDEF.MVCTAREF" 	OPERATION 2	ACCESS 0 // "Visualizar"
	//ADD OPTION aRotina TITLE "Imprimir"		ACTION "VIEWDEF.MVCTAREF" 	OPERATION 8 ACCESS 0 // "Imprimir"

	//AAdd(aRotina,{"Visualizar"	, "VIEWDEF.MVCTAREF" , 0, 2, 0, Nil } )
	//AAdd(aRotina,{"Incluir" 	, "VIEWDEF.MVCTAREF" , 0, 3, 0, Nil } )
	//AAdd(aRotina,{"Alterar" 	, "VIEWDEF.MVCTAREF" , 0, 4, 0, Nil } )
	//AAdd(aRotina,{"Excluir" 	, "VIEWDEF.MVCTAREF" , 0, 5, 0, Nil } )
	//AAdd(aRotina,{"Imprimir" 	, "VIEWDEF.MVCTAREF" , 0, 8, 0, Nil } )

	ADD OPTION aRotina TITLE 'Pesquisar' 	ACTION 'PesqBrw' 			OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.MVCTAREF' 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir' 		ACTION 'VIEWDEF.MVCTAREF' 	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar' 		ACTION 'VIEWDEF.MVCTAREF' 	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir' 		ACTION 'VIEWDEF.MVCTAREF' 	OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir' 	ACTION 'VIEWDEF.MVCTAREF' 	OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar' 		ACTION 'VIEWDEF.MVCTAREF' 	OPERATION 9 ACCESS 0

Return aRotina

Static Function ModelDef() as Object
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruZZG as array
	Local oStruZZH as array
	Local oModel as object

	oStruZZG := FWFormStruct( 1, 'ZZG', /*bAvalCampo*/,/*lViewUsado*/ )
	oStruZZH := FWFormStruct( 1, 'ZZH', /*bAvalCampo*/,/*lViewUsado*/ )


	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('MODELZZG', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'ZZGMASTER', /*cOwner*/, oStruZZG, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:AddGrid( 'ZZHDETAIL','ZZGMASTER', oStruZZH )


	//Chave Primaria
	oModel:SetPrimaryKey( {"ZZG_FILIAL", "ZZG_CODIGO"})
	oModel:SetRelation('ZZHDETAIL', { { 'ZZH_FILIAL', "xFilial('ZZH')" }, { 'ZZH_CODTAR','ZZG_CODIGO' }}, ZZH->(IndexKey(1)) )


	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Gerenciador de tarefas' )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'ZZGMASTER' ):SetDescription( 'Gerenciador de tarefas' )

Return oModel

Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel as object
	// Cria a estrutura a ser usada na View
	Local oStruZZG as array
	Local oStruZZH as array
	Local oView as object

	oModel := FWLoadModel( 'MVCTAREF' )
	oStruZZG := FWFormStruct( 2, 'ZZG', /*bAvalCampo*/)
	oStruZZH := FWFormStruct( 2, 'ZZH', /*bAvalCampo*/)


	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_ZZG', oStruZZG, 'ZZGMASTER' )
	oView:AddGrid( 'VIEW_ZZH' , oStruZZH, 'ZZHDETAIL' )


	// Criar um "box" horizontal para receber algum elemento da view
	//oView:CreateHorizontalBox( 'SUPERIOR' , 100 )
	oView:CreateHorizontalBox( 'BOXFORM03', 50)
	oView:CreateHorizontalBox( 'BOXFORM13', 50)


	// Relaciona o ID da View com o "box" para exibicao
	//oView:SetOwnerView( 'VIEW_ZZG', 'SUPERIOR' )
	oView:SetOwnerView('VIEW_ZZG','BOXFORM03')
	oView:SetOwnerView('VIEW_ZZH','BOXFORM13')


	// Liga a identificacao do componente
	//oView:EnableTitleView('VIEW_ZZG','Gerenciador de tarefas')

	//Indica se a janela deve ser fechada ao final da operação. Se ele retornar .T. (verdadeiro) fecha a janela
	oView:bCloseOnOK := {|| .T.}

Return oView
