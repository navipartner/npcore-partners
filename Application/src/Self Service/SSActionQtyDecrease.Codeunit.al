codeunit 6151281 "NPR SS Action - Qty Decrease"
{

    var
        ActionDescription: Label 'This is a build in function to change quantity.';

    local procedure ActionCode(): Text
    begin

        exit('SS-QTY-');
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
            Sender.RegisterDecimalParameter('decreaseBy', 1.0);

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

        Qty := Context.GetDecimalParameterOrFail('decreaseBy', ActionCode());
        DecreaseSalelineQuantity(POSSession, Qty);
    end;

    procedure DecreaseSalelineQuantity(POSSession: Codeunit "NPR POS Session"; DecreaseBy: Decimal)
    var
        SaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR Sale Line POS";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin

        // This function should be "not local", so test framework can invoke it

        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        if (SaleLinePOS.Quantity - DecreaseBy < 0) then
            SaleLine.SetQuantity(0)
        else
            SaleLine.SetQuantity(SaleLinePOS.Quantity - DecreaseBy);

        POSSession.RequestRefreshData();
    end;
}

