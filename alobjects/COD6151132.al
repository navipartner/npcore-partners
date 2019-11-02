codeunit 6151132 "TM POS Action - Seating"
{
    // TM1.43/TSA /20190618 CASE 357359 Initial Version


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for running the ticket seating functionality';
        POSSetup: Codeunit "POS Setup";

    local procedure ActionCode(): Text
    begin
        exit ('TM_SEATING');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode,
            ActionDescription,
            ActionVersion,
            Type::Generic,
            "Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflowStep ('1','respond();');
            RegisterWorkflow (false);
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', false, false)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Context: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction (ActionCode) then
          exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
    begin

        if not Action.IsThisAction (ActionCode) then
          exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope('parameters',true);
        // MenuFilterCode := JSON.GetString('MenuFilterCode', TRUE);

        ShowSeating (FrontEnd);
    end;

    local procedure "-- Locals --"()
    begin
    end;

    local procedure ShowSeating(FrontEnd: Codeunit "POS Front End Management")
    var
        SeatingUI: Codeunit "TM Seating UI";
    begin
        // FrontEnd.PauseWorkflow ();
        //SeatingUI.ShowSelectSeatUI (FrontEnd);
    end;
}

