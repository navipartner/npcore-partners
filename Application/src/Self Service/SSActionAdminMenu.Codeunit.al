codeunit 6151290 "NPR SS Action: Admin Menu"
{
    Access = Internal;
    var
        ActionDescription: Label 'This built- in action displays the self-service admin menu.';

    local procedure ActionCode(): Text[20]
    begin

        exit('SS-ADMIN-MENU');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction20(
          ActionCode(),
          ActionDescription,
          ActionVersion())
        then begin
            Sender.RegisterWorkflow20(
              'await popup.menu({source: $parameters.AdminMenuName, rows: $parameters.Rows, columns: $parameters.Columns});'
              );

            Sender.RegisterTextParameter('AdminMenuName', 'SS-ADMIN');
            Sender.RegisterIntegerParameter('Rows', 4);
            Sender.RegisterIntegerParameter('Columns', 2);
            Sender.SetWorkflowTypeUnattended();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin

        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;
    end;
}

