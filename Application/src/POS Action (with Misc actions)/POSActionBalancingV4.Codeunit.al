codeunit 6014600 "NPR POS Action: Bal. v4 POC"
{
    var
        ActionDescription: Label 'TODO';

    local procedure ActionCode(): Text
    begin
        exit('BALANCE_V4');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
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

    [EventSubscriber(ObjectType::Codeunit, 6150733, 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Request: Codeunit "NPR Front-End: Generic";
        BalancingContext: JsonObject;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        BalancingContext.Add('endOfDayCheckpointEntryNo', 'TBD');

        Request.SetMethod('BalanceSetContext');
        Request.GetContent().Add('balancingContext', BalancingContext);
        FrontEnd.InvokeFrontEndMethod(Request);

        POSSession.ChangeViewBalancing();
    end;
}

