codeunit 6150875 "NPR POS Action: Raptor"
{

    var
        ActionDescription: Label 'An action to run Raptor integration functions';

    local procedure ActionCode(): Code[20]
    begin
        exit('RAPTOR');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('2.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction20(
            ActionCode(),
            ActionDescription,
            ActionVersion())
        then begin
            Sender.RegisterWorkflow20(
              'await workflow.respond(); ' +
              'if ($context.ActionFailed) {if ($context.ActionFailReasonMsg.length > 0) {await popup.message($context.ActionFailReasonMsg);};}');
            Sender.RegisterTextParameter('RaptorActionCode', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        if not TryToRunAction(Context, POSSession) then begin
            Context.SetContext('ActionFailed', true);
            Context.SetContext('ActionFailReasonMsg', GetLastErrorText);
        end;
    end;

    [TryFunction]
    local procedure TryToRunAction(Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        RaptorAction: Record "NPR Raptor Action";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        RaptorMgt: Codeunit "NPR Raptor Management";
        RaptorActionCode: Code[20];
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("Customer No.");

        RaptorActionCode := CopyStr(Context.GetStringParameter('RaptorActionCode'), 1, MaxStrLen(RaptorActionCode));
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
}

