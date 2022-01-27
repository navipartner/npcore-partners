codeunit 6150835 "NPR POS Action: Lock POS"
{
    Access = Internal;
    var
        ActionDescription: Label 'This built in function locks the POS';

    local procedure ActionCode(): Code[20]
    begin

        exit('LOCK_POS');
    end;

    local procedure ActionVersion(): Code[10]
    begin

        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflow(false);
            Sender.RegisterDataBinding();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        POSSession.GetSetup(POSSetup);
        POSCreateEntry.InsertUnitLockEntry(POSSetup.GetPOSUnitNo(), POSSetup.Salesperson());

        POSSession.ChangeViewLocked();
    end;
}

