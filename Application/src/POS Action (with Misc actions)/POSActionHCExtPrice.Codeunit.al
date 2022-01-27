codeunit 6150909 "NPR POS Action: HC Ext. Price"
{
    Access = Internal;
    var
        ActionDescription: Label 'This action makes remote call to aquire item price information ';

    local procedure ActionCode(): Code[20]
    begin
        exit('HC_EXTERNALPRICE');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('1', 'respond();');
            Sender.RegisterWorkflow(false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CustomerPriceManagement: Codeunit "NPR POS HC Ext. Price";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        TempSalesLine: Record "Sales Line" temporary;
        GeneralLedgerSetup: Record "General Ledger Setup";
        EndpointSetup: Record "NPR POS HC Endpoint Setup";
        PrevRec: Text;
    begin
        if not Action.IsThisAction(ActionCode()) then
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
            TempSalesLine."Document Type" := TempSalesLine."Document Type"::Quote;
            TempSalesLine."Document No." := SaleLinePOS."Sales Ticket No.";
            TempSalesLine."Line No." := SaleLinePOS."Line No.";
            TempSalesLine.Type := TempSalesLine.Type::Item;
            TempSalesLine."No." := SaleLinePOS."No.";
            TempSalesLine."Variant Code" := SaleLinePOS."Variant Code";
            TempSalesLine.Quantity := SaleLinePOS.Quantity;
            TempSalesLine."Unit of Measure Code" := SaleLinePOS."Unit of Measure Code";
            TempSalesLine.Insert();
        until (SaleLinePOS.Next() = 0);

        CustomerPriceManagement.GetCustomerPrice(EndpointSetup.Code, SalePOS."Customer No.", SalePOS."Sales Ticket No.", GeneralLedgerSetup."LCY Code", TempSalesLine);

        SaleLinePOS.FindSet();
        repeat
            TempSalesLine.Get(TempSalesLine."Document Type"::Quote, SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.");
            PrevRec := Format(SaleLinePOS);

            CustomerPriceManagement.UpdateSaleLinePOS(TempSalesLine, SaleLinePOS);
            SaleLinePOS.UpdateAmounts(SaleLinePOS);

            if PrevRec <> Format(SaleLinePOS) then
                SaleLinePOS.Modify();
        until (SaleLinePOS.Next() = 0);

        POSSaleLine.RefreshCurrent();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        POSSaleLine.OnAfterSetQuantity(SaleLinePOS);
        POSSession.RequestRefreshData();
    end;
}
