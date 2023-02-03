codeunit 6060111 "NPR POS Action: Change Loc." implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Change location for current POS sales line';
        ParamDefaultLocation_CptLbl: Label 'Default Location';
        ParamDefaultLocation_DescLbl: Label 'Specifies to which Location it will be changed.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('DefaultLocation', '', ParamDefaultLocation_CptLbl, ParamDefaultLocation_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'ChangeLocation':
                FrontEnd.WorkflowResponse(ChangeLocation(Context, SaleLine));
        end;
    end;

    local procedure ChangeLocation(Context: codeunit "NPR POS JSON Helper"; SaleLine: codeunit "NPR POS Sale Line"): JsonObject
    var
        POSActionChangeLocB: Codeunit "NPR POS Action: Change Loc-B";
        DefaultLocation: Code[10];
    begin
        DefaultLocation := copystr(Context.GetStringParameter('DefaultLocation'), 1, MaxStrLen(DefaultLocation));
        POSActionChangeLocB.ChangeLocation(SaleLine, DefaultLocation);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionChangeLoc.js###
'let main=async({})=>await workflow.respond("ChangeLocation");'
        )
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, true)]
    local procedure OnValidateDefaultLocation(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        Location: Record Location;
    begin
        if POSParameterValue."Action Code" <> FORMAT(ENUM::"NPR POS Workflow"::CHANGE_LOCATION) then
            exit;
        if POSParameterValue.Name <> 'DefaultLocation' then
            exit;
        if POSParameterValue.Value = '' then
            exit;

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        if not Location.Get(POSParameterValue.Value) then begin
            Location.SetFilter(Code, '%1', POSParameterValue.Value + '*');
            if Location.FindFirst() then
                POSParameterValue.Value := Location.Code;
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, true)]
    local procedure OnLookupDefaultLocation(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Location: Record Location;
    begin
        if POSParameterValue."Action Code" <> FORMAT(ENUM::"NPR POS Workflow"::CHANGE_LOCATION) then
            exit;
        if POSParameterValue.Name <> 'DefaultLocation' then
            exit;

        if PAGE.RunModal(0, Location) = ACTION::LookupOK then
            POSParameterValue.Value := Location.Code;
    end;
}
