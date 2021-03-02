codeunit 6150685 "NPR NPRE RVA: Set Table Status"
{
    local procedure ActionCode(): Text;
    begin
        exit('RV_SET_TABLE_STATUS');
    end;

    local procedure ActionVersion(): Text;
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action");
    var
        ActionDescription: Label 'This built-in action sets table (seating) status from Restaurant View';
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescription, ActionVersion()) then begin
            Sender.RegisterWorkflow20(
              'await workflow.respond();');

            Sender.RegisterTextParameter('SeatingCode', '');
            Sender.RegisterTextParameter('StatusCode', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20(Action: Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
        NewStatusCode: Code[10];
        SeatingCode: Code[20];
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        SeatingCode := Context.GetStringParameterOrFail('SeatingCode', ActionCode());
        NewStatusCode := Context.GetStringParameter('StatusCode');
        if NewStatusCode = '' then
            exit;

        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::Seating);
        FlowStatus.SetRange(Code, NewStatusCode);
        FlowStatus.FindFirst;

        SeatingMgt.SetSeatingStatus(SeatingCode, NewStatusCode);
    end;
}