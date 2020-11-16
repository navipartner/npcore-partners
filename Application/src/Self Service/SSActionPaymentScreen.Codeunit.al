codeunit 6151284 "NPR SS Action: Payment Screen"
{
    // 
    // NPR5.54/TSA /20200205 CASE 387912 Initial Version


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This built in function changes to payment view';

    local procedure ActionCode(): Text
    begin

        exit('SS-PAY-SCREEN');
    end;

    local procedure ActionVersion(): Text
    begin

        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin

        with Sender do
            if DiscoverAction20(
              ActionCode(),
              ActionDescription,
              ActionVersion())
            then begin
                RegisterWorkflow20('workflow.respond();');
                SetWorkflowTypeUnattended();
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150733, 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        ChangeToPaymentView(POSSession);
    end;

    procedure ChangeToPaymentView(POSSession: Codeunit "NPR POS Session")
    begin

        POSSession.ChangeViewPayment();
    end;
}

