codeunit 6150684 "NPR NPRE RVA: Set WPad Status"
{
    local procedure ActionCode(): Code[20]
    begin
        exit('RV_SET_W/PAD_STATUS');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action");
    var
        ActionDescription: Label 'This built-in action sets Waiter Pad status/serving step from Restaurant View';
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescription, ActionVersion()) then begin
            Sender.RegisterWorkflow20(
              'await workflow.respond();');

            Sender.RegisterTextParameter('WaiterPadCode', '');
            Sender.RegisterTextParameter('StatusCode', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20(Action: Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        NewStatusCode: Code[10];
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        WaiterPad."No." := CopyStr(Context.GetStringParameterOrFail('WaiterPadCode', ActionCode()), 1, MaxStrLen(WaiterPad."No."));
        NewStatusCode := CopyStr(Context.GetStringParameter('StatusCode'), 1, MaxStrLen(NewStatusCode));
        if NewStatusCode = '' then
            exit;

        WaiterPad.Find();

        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::WaiterPad, FlowStatus."Status Object"::WaiterPadLineMealFlow);
        FlowStatus.SetRange(Code, NewStatusCode);
        FlowStatus.FindFirst();
        if FlowStatus."Status Object" = FlowStatus."Status Object"::WaiterPadLineMealFlow then
            RestaurantPrint.RequestRunServingStepToKitchen(WaiterPad, false, NewStatusCode)
        else begin
            WaiterPad.Status := NewStatusCode;
            WaiterPad.Modify();
        end;
    end;
}