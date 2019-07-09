codeunit 6150835 "POS Action - Lock POS"
{
    // NPR5.37/TSA /20171024 CASE 293905 POS Action - Lock POS, initial version
    // NPR5.38/TSA /20171123 CASE 297087 Added Lock Entry System Event


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This built in function locks the POS';

    local procedure ActionCode(): Code[20]
    begin

        exit ('LOCK_POS');
    end;

    local procedure ActionVersion(): Code[10]
    begin

        exit ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode (),
            ActionDescription,
            ActionVersion (),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflow(false);
            RegisterDataBinding();
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        Confirmed: Boolean;
        POSCreateEntry: Codeunit "POS Create Entry";
        POSSetup: Codeunit "POS Setup";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        Handled := true;

        //+NPR5.38 [297087]
        POSSession.GetSetup (POSSetup);
        POSCreateEntry.InsertUnitLockEntry (POSSetup.Register (), POSSetup.Salesperson ());
        //-NPR5.38 [297087]

        POSSession.ChangeViewLocked ();
    end;
}

