codeunit 6151140 "NPR POS Action: Change UOM" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        ActionDescription: Label 'Change unit of measure for POS sales line';
        DefaultUOM_CptLbl: Label 'Default UOM';
        DefaultUOM_DescLbl: Label 'Specifies to which UOM it will be changed.';

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('DefaultUOM', '', DefaultUOM_CptLbl, DefaultUOM_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'ChangeUOM':
                FrontEnd.WorkflowResponse(ChangeUOM(Context, SaleLine));
        end;
    end;

    local procedure ChangeUOM(Context: Codeunit "NPR POS JSON Helper"; SaleLine: Codeunit "NPR POS Sale Line"): JsonObject
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActionChangeUOMB: Codeunit "NPR POS Action: Change UOM-B";
        DefaultUOM: Code[10];
    begin
        DefaultUOM := CopyStr(Context.GetStringParameter('DefaultUOM'), 1, MaxStrLen(SaleLinePOS."Unit of Measure Code"));
        POSActionChangeUOMB.SetUoM(DefaultUOM, SaleLine);
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
        if POSParameterValue."Action Code" <> Format(Enum::"NPR POS Workflow"::CHANGE_UOM) then
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
        if POSParameterValue."Action Code" <> Format(Enum::"NPR POS Workflow"::CHANGE_UOM) then
            exit;
        if POSParameterValue.Name <> 'DefaultUOM' then
            exit;

        if Page.RunModal(0, UnitofMeasure) = Action::LookupOK then
            POSParameterValue.Value := UnitofMeasure.Code;
    end;
}
