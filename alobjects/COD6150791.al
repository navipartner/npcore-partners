codeunit 6150791 "POS Action - Toggle Large Rcpt"
{

    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for setting receipt print to large format before ending transaction.';

    local procedure ActionCode(): Text
    begin
        exit('TOGGLE_RECEIPT_LARGE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode,
            ActionDescription,
            ActionVersion,
            Type::Button,
            "Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflow(false);
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);

        //TODO: if we can set a custom transaction flag in the local JS and keep it until the Post Processing codeunit, do that instead of SQL for a simple sale flag.

        Message('Toggled Large Receipt');

        Handled := true;
    end;
}

