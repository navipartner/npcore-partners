codeunit 6150875 "NPR POS Action: Raptor" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'An action to run Raptor integration functions.';
        ParamRaptorActionCode_CptLbl: Label 'Raptor Action Code';
        ParamRaptorActionCode_DescLbl: Label 'Raptor action code that should be run.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('RaptorActionCode', '', ParamRaptorActionCode_CptLbl, ParamRaptorActionCode_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        if not TryToRunAction(Context, POSSession) then begin
            Context.SetContext('ActionFailed', true);
            Context.SetContext('ActionFailReasonMsg', GetLastErrorText);
        end;
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit(FORMAT("NPR POS workflow"::RAPTOR));
    end;

    [TryFunction]
    local procedure TryToRunAction(Context: Codeunit "NPR POS JSON Helper"; POSSession: Codeunit "NPR POS Session")
    var
        RaptorAction: Record "NPR Raptor Action";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        RaptorMgt: Codeunit "NPR Raptor Management";
        RaptorActionCode: Code[20];
        ResultOut: Text;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("Customer No.");

        if not Context.GetStringParameter('RaptorActionCode', ResultOut) then
            ResultOut := '';
        RaptorActionCode := CopyStr(ResultOut, 1, MaxStrLen(RaptorActionCode));
        if RaptorActionCode <> '' then
            RaptorAction.Get(RaptorActionCode)
        else
            if not RaptorMgt.SelectRaptorAction('', false, RaptorAction) then
                Error('');
        RaptorMgt.ShowRaptorData(RaptorAction, SalePOS."Customer No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        RaptorAction: Record "NPR Raptor Action";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'RaptorActionCode':
                begin
                    if POSParameterValue.Value <> '' then begin
                        RaptorAction.Code := CopyStr(POSParameterValue.Value, 1, MaxStrLen(RaptorAction.Code));
                        if RaptorAction.Find('=><') then;
                    end;
                    if PAGE.RunModal(0, RaptorAction) = ACTION::LookupOK then
                        POSParameterValue.Value := RaptorAction.Code;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        RaptorAction: Record "NPR Raptor Action";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'RaptorActionCode':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    RaptorAction.Code := CopyStr(POSParameterValue.Value, 1, MaxStrLen(RaptorAction.Code));
                    RaptorAction.Find();
                end;
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionRaptor.js###
'let main=async({workflow:i,context:a,popup:s})=>{await i.respond(),a.ActionFailed&&a.ActionFailReasonMsg.length>0&&await s.message(a.ActionFailReasonMsg)};'
        )
    end;
}

