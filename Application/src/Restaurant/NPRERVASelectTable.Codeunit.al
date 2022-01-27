codeunit 6150687 "NPR NPRE RVA: Select Table"
{
    Access = Internal;
    local procedure ActionCode(): Code[20]
    begin
        exit('RV_SELECT_TABLE');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action");
    var
        ActionDescription: Label 'This built-in action can be run when a table is selected in Restaurant View';
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescription, ActionVersion()) then begin
            Sender.RegisterWorkflow20(
                'let WaiterPadSelected = await workflow.respond("SelectWaiterPad");' +
                'if (WaiterPadSelected)' +
                '{' +
                //'    console.log("Selected waiter pad no.: " + $context.waiterPadNo);' +
                '    workflow.queue("RV_GET_WAITER_PAD", {parameters: {WaiterPadCode: $context.waiterPadNo}})' +
                '} else {' +
                '    workflow.queue("RV_NEW_WAITER_PAD", {parameters: {SeatingCode: $parameters.SeatingCode, SwitchToSaleView: true}})' +
                '};'
            );

            Sender.RegisterTextParameter('SeatingCode', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20(Action: Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        SeatingCode: Code[20];
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        case WorkflowStep of
            'SelectWaiterPad':
                begin
                    SeatingCode := CopyStr(Context.GetStringParameterOrFail('SeatingCode', ActionCode()), 1, MaxStrLen(SeatingCode));
                    Seating.Get(SeatingCode);

                    SeatingWaiterPadLink.SetCurrentKey(Closed);
                    SeatingWaiterPadLink.SetRange("Seating Code", Seating.Code);
                    SeatingWaiterPadLink.SetRange(Closed, false);
                    if SeatingWaiterPadLink.IsEmpty then begin
                        FrontEnd.WorkflowResponse(false);
                        exit;
                    end;

                    if WaiterPadPOSMgt.SelectWaiterPad(Seating, WaiterPad) then begin
                        Context.SetContext('waiterPadNo', WaiterPad."No.");
                        FrontEnd.WorkflowResponse(true);
                    end else
                        Error('');
                end;
        end;
    end;
}
