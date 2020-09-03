codeunit 6150909 "NPR POS Action: HC Ext. Price"
{
    // NPR5.38/TSA /20171201  CASE 297859 Initial Version
    // NPR5.43/MHA /20180628  CASE 318396 Added missing UpdateAmounts() in OnAction()
    // NPR5.44/MHA /20180724  CASE 323000 Discount Code is set to 'HC' to enable detection of actual Manually applied Discount
    // NPR5.44/MHA /20180724  CASE 323006 Added trigger OnAfterSetQuantity() in OnAction()
    // NPR5.45/MHA /20180803  CASE 323705 UpdateSaleLinePOS() moved to Codeunit 6150910


    trigger OnRun()
    begin
    end;

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
        // JSON.SetScope('parameters',TRUE);
        // XX := JSON.GetString('xx', TRUE);

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
            //-NPR5.44 [323000]
            //SaleLinePOS."Unit Price" := TmpSalesLine."Unit Price";
            //
            // IF (TmpSalesLine."Line Discount %" <> 0) THEN BEGIN
            //  SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Manual;
            //  SaleLinePOS.VALIDATE ("Discount %", TmpSalesLine."Line Discount %");
            // END;
            ////-NPR5.43 [318396]
            //SaleLinePOS.UpdateAmounts(SaleLinePOS);
            ////+NPR5.43 [318396]
            //SaleLinePOS.MODIFY ();
            PrevRec := Format(SaleLinePOS);

            //-NPR5.45 [323705]
            //UpdateSaleLinePOS(TmpSalesLine,SaleLinePOS);
            CustomerPriceManagement.UpdateSaleLinePOS(TmpSalesLine, SaleLinePOS);
            //+NPR5.45 [323705]
            SaleLinePOS.UpdateAmounts(SaleLinePOS);

            if PrevRec <> Format(SaleLinePOS) then
                SaleLinePOS.Modify;
        //+NPR5.44 [323000]
        until (SaleLinePOS.Next() = 0);

        POSSaleLine.RefreshCurrent();
        //-NPR5.44 [323006]
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        POSSaleLine.OnAfterSetQuantity(SaleLinePOS);
        //+NPR5.44 [323006]
        POSSession.RequestRefreshData();
    end;
}

