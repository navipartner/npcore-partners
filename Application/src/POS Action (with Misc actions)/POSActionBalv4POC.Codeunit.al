﻿codeunit 6014600 "NPR POS Action: Bal. v4 POC"
{
    Access = Internal;

    var
        ActionDescription: Label 'TODO';

    local procedure ActionCode(): Code[20]
    begin
        exit('BALANCE_V4');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
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
              'workflow.respond();'
            );
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Request: Codeunit "NPR Front-End: Generic";
        BalancingContext: JsonObject;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        BalancingContext.Add('endOfDayCheckpointEntryNo', '35');

        Request.SetMethod('BalanceSetContext');
        Request.GetContent().Add('balancingContext', BalancingContext);
        FrontEnd.InvokeFrontEndMethod(Request);

        POSSession.ChangeViewBalancing();
    end;
}

