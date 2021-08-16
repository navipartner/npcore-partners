codeunit 6151287 "NPR SS Action: Idle Timeout"
{
    var
        ActionDescription: Label 'This built in function handles idle timeout in self service POS';

    local procedure ActionCode(): Text[20]
    begin

        exit('SS-IDLE-TIMEOUT');
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
            Sender.RegisterWorkflow20('workflow.respond();');
            Sender.SetWorkflowTypeUnattended();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        ChangeToLoginScreen(POSSession);
    end;

    procedure ChangeToLoginScreen(POSSession: Codeunit "NPR POS Session")
    var
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSSetup: Codeunit "NPR POS Setup";
    begin

        POSSession.GetSetup(POSSetup);
        POSCreateEntry.InsertUnitLockEntry(POSSetup.GetPOSUnitNo(), POSSetup.Salesperson());

        POSSession.ChangeViewLogin();
    end;
}

