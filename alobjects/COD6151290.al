codeunit 6151290 "SS Action - Admin Menu"
{
    // NPR5.55/TSA /20200417 CASE 400734 Initial Version


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This built- in action displays the self-service admin menu.';

    local procedure ActionCode(): Text
    begin

        exit ('SS-ADMIN-MENU');
    end;

    local procedure ActionVersion(): Text
    begin

        exit ('1.1');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin

        with Sender do
          if DiscoverAction20 (
            ActionCode(),
            ActionDescription,
            ActionVersion())
          then begin
            RegisterWorkflow20 (
              'await popup.menu({source: $parameters.AdminMenuName, rows: $parameters.Rows, columns: $parameters.Columns});'
              );

            RegisterTextParameter ('AdminMenuName', 'SS-ADMIN');
            RegisterIntegerParameter ('Rows', 4);
            RegisterIntegerParameter ('Columns', 2);
            SetWorkflowTypeUnattended ();
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150733, 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "POS Action";WorkflowStep: Text;Context: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";State: Codeunit "POS Workflows 2.0 - State";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin

        if not Action.IsThisAction(ActionCode) then
          exit;

        Handled := true;
    end;
}

