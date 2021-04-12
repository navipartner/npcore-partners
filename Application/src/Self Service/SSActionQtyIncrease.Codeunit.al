codeunit 6151280 "NPR SS Action - Qty Increase"
{
    var
        ActionDescription: Label 'This is a build in function to change quantity.';

    local procedure ActionCode(): Text
    begin

        exit('SS-QTY+');
    end;

    local procedure ActionVersion(): Text
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
            Sender.RegisterDecimalParameter('increaseBy', 1.0);

            Sender.SetWorkflowTypeUnattended();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Qty: Decimal;
    begin

        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        Qty := Context.GetDecimalParameterOrFail('increaseBy', ActionCode());
        IncreaseSalelineQuantity(POSSession, Qty);
    end;

    procedure IncreaseSalelineQuantity(POSSession: Codeunit "NPR POS Session"; IncreaseBy: Decimal)
    var
        SaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin

        // This function should be "not local", so test framework can invoke it

        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLine.SetQuantity(SaleLinePOS.Quantity + IncreaseBy);

        POSSession.RequestRefreshData();
    end;
}

