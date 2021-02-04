codeunit 6150686 "NPR NPRE RVA: Set No.of Guests"
{
    local procedure ActionCode(): Text;
    begin
        exit('RV_SET_PARTYSIZE');
    end;

    local procedure ActionVersion(): Text;
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action");
    var
        ActionDescription: Label 'This built-in action sets number of guests for a waiter pad from Restaurant View';
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescription, ActionVersion()) then begin
            Sender.RegisterWorkflow20(
              'await workflow.respond();');

            Sender.RegisterTextParameter('SeatingCode', '');
            Sender.RegisterTextParameter('WaiterPadCode', '');
            Sender.RegisterIntegerParameter('NoOfGuests', 0);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20(Action: Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        SeatingCode: Code[20];
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        WaiterPad."No." := Context.GetStringParameter('WaiterPadCode', true);
        SeatingCode := Context.GetStringParameter('SeatingCode', true);
    end;
}