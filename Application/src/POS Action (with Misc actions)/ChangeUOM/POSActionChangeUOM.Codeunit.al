codeunit 6151140 "NPR POS Action: Change UOM" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        ActionDescription: Label 'Change unit of measure for POS sales line';
        DefaultUOM_CptLbl: Label 'Default UOM';
        DefaultUOM_DescLbl: Label 'Specifies to which UOM it will be changed.';

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var

    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('DefaultUOM', '', DefaultUOM_CptLbl, DefaultUOM_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'ChangeUOM':
                FrontEnd.WorkflowResponse(ChangeUOM(Context, SaleLine));
        end;
    end;

    local procedure ChangeUOM(Context: codeunit "NPR POS JSON Helper"; SaleLine: codeunit "NPR POS Sale Line"): JsonObject
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        ItemUnitsofMeasure: Page "Item Units of Measure";
        DefaultUOM: Code[10];
    begin
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        DefaultUOM := copystr(Context.GetStringParameter('DefaultUOM'), 1, MaxStrLen(SaleLinePOS."Unit of Measure Code"));
        IF DefaultUOM = '' THEN begin
            ItemUnitofMeasure.SetRange("Item No.", SaleLinePOS."No.");
            ItemUnitofMeasure.SetRange("NPR Block on POS Sale", false);
            ItemUnitsofMeasure.Editable(false);
            ItemUnitsofMeasure.LookupMode(true);
            ItemUnitsofMeasure.SetTableView(ItemUnitofMeasure);
            if ItemUnitsofMeasure.RunModal() <> ACTION::LookupOK then
                exit;
            ItemUnitsofMeasure.GetRecord(ItemUnitofMeasure);
        end else
            ItemUnitofMeasure.Get(SaleLinePOS."No.", DefaultUOM);

        if SaleLinePOS."Unit of Measure Code" = ItemUnitofMeasure.Code then
            exit;

        SaleLine.SetUoM(ItemUnitofMeasure.Code);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionChangeUOM.js###
'let main=async({})=>await workflow.respond("ChangeUOM");'
        )
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, true)]
    local procedure OnValidateDefaultUOM(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        if POSParameterValue."Action Code" <> FORMAT(ENUM::"NPR POS Workflow"::CHANGE_UOM) then
            exit;
        if POSParameterValue.Name <> 'DefaultUOM' then
            exit;
        if POSParameterValue.Value = '' then
            exit;

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        if not UnitofMeasure.Get(POSParameterValue.Value) then begin
            UnitofMeasure.SetFilter(Code, '%1', POSParameterValue.Value + '*');
            if UnitofMeasure.FindFirst() then
                POSParameterValue.Value := UnitofMeasure.Code;
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, true)]
    local procedure OnLookupDefaultUOM(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        if POSParameterValue."Action Code" <> FORMAT(ENUM::"NPR POS Workflow"::CHANGE_UOM) then
            exit;
        if POSParameterValue.Name <> 'DefaultUOM' then
            exit;

        if PAGE.RunModal(0, UnitofMeasure) = ACTION::LookupOK then
            POSParameterValue.Value := UnitofMeasure.Code;
    end;
}
