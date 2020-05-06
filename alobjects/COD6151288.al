codeunit 6151288 "SS Action - Sale Screen"
{
    // 
    // NPR5.54/TSA /20200205 CASE 387912 Initial Version


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This built in function changes to sale view';

    local procedure ActionCode(): Text
    begin

        exit ('SS-SALE-SCREEN');
    end;

    local procedure ActionVersion(): Text
    begin

        exit ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin

        with Sender do
          if DiscoverAction20(
            ActionCode(),
            ActionDescription,
            ActionVersion())
          then begin
            RegisterWorkflow20('workflow.respond();');
            SetWorkflowTypeUnattended ();
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150733, 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "POS Action";WorkflowStep: Text;Context: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";State: Codeunit "POS Workflows 2.0 - State";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        Handled := true;

        ChangeToSaleView (POSSession);
    end;

    procedure ChangeToSaleView(POSSession: Codeunit "POS Session")
    begin

        POSSession.ChangeViewSale();
    end;
}

