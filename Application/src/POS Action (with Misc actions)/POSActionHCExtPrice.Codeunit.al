codeunit 6150909 "NPR POS Action: HC Ext. Price"
{
    var
        ActionDescription: Label 'This action makes remote call to aquire item price information ';

    local procedure ActionCode(): Text
    begin
        exit('HC_EXTERNALPRICE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Type::Generic,
              "Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('1', 'respond();');
                RegisterWorkflow(false);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CustomerPriceManagement: Codeunit "NPR POS HC Ext. Price";
        SaleLinePOS: Record "NPR Sale Line POS";
        SalePOS: Record "NPR Sale POS";
        TmpSalesLine: Record "Sales Line" temporary;
        GeneralLedgerSetup: Record "General Ledger Setup";
        EndpointSetup: Record "NPR POS HC Endpoint Setup";
        PrevRec: Text;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        GeneralLedgerSetup.Get();
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);

        POSSale.GetCurrentSale(SalePOS);

        EndpointSetup.SetFilter(Active, '=%1', true);
        EndpointSetup.FindFirst();

        SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter(Type, '=%1', SaleLinePOS.Type::Item);
        if (not SaleLinePOS.FindSet()) then
            exit;

        repeat
            TmpSalesLine."Document Type" := TmpSalesLine."Document Type"::Quote;
            TmpSalesLine."Document No." := SaleLinePOS."Sales Ticket No.";
            TmpSalesLine."Line No." := SaleLinePOS."Line No.";
            TmpSalesLine.Type := TmpSalesLine.Type::Item;
            TmpSalesLine."No." := SaleLinePOS."No.";
            TmpSalesLine."Variant Code" := SaleLinePOS."Variant Code";
            TmpSalesLine.Quantity := SaleLinePOS.Quantity;
            TmpSalesLine."Unit of Measure Code" := SaleLinePOS."Unit of Measure Code";
            TmpSalesLine.Insert();
        until (SaleLinePOS.Next() = 0);

        CustomerPriceManagement.GetCustomerPrice(EndpointSetup.Code, SalePOS."Customer No.", SalePOS."Sales Ticket No.", GeneralLedgerSetup."LCY Code", TmpSalesLine);

        SaleLinePOS.FindSet();
        repeat
            TmpSalesLine.Get(TmpSalesLine."Document Type"::Quote, SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.");
            PrevRec := Format(SaleLinePOS);

            CustomerPriceManagement.UpdateSaleLinePOS(TmpSalesLine, SaleLinePOS);
            SaleLinePOS.UpdateAmounts(SaleLinePOS);

            if PrevRec <> Format(SaleLinePOS) then
                SaleLinePOS.Modify;
        until (SaleLinePOS.Next() = 0);

        POSSaleLine.RefreshCurrent();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        POSSaleLine.OnAfterSetQuantity(SaleLinePOS);
        POSSession.RequestRefreshData();
    end;
}
