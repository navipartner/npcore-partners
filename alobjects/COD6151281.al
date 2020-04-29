codeunit 6151281 "SS Action - Qty Decrease"
{
    // NPR5.54/TSA /20200205 CASE 387912 Initial Version


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a build in function to change quantity.';

    local procedure ActionCode(): Text
    begin

        exit ('SS-QTY-');
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
            RegisterDecimalParameter ('decreaseBy', 1.0);

            SetWorkflowTypeUnattended ();
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150733, 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "POS Action";WorkflowStep: Text;Context: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";State: Codeunit "POS Workflows 2.0 - State";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Qty: Decimal;
    begin

        if not Action.IsThisAction(ActionCode) then
          exit;

        Handled := true;

        Qty := Context.GetDecimalParameter('decreaseBy',true);
        DecreaseSalelineQuantity (POSSession, Qty);
    end;

    procedure DecreaseSalelineQuantity(POSSession: Codeunit "POS Session";DecreaseBy: Decimal)
    var
        SaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
        POSSaleLine: Codeunit "POS Sale Line";
    begin

        // This function should be "not local", so test framework can invoke it

        POSSession.GetSaleLine (SaleLine);
        SaleLine.GetCurrentSaleLine (SaleLinePOS);

        if (SaleLinePOS.Quantity - DecreaseBy < 0) then
          SaleLine.SetQuantity (0)
        else
          SaleLine.SetQuantity (SaleLinePOS.Quantity - DecreaseBy);

        POSSession.RequestRefreshData();
    end;
}

