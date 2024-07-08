codeunit 6060012 "NPR POS Act.: Layaway Create-B"
{
    Access = Internal;

    var
        ErrorDownpayment: Label 'Downpayment invoice was posted correctly but balancing line could not be automatically created:\ %1';
        ErrorLayaway: Label 'Order was created but layaway invoices could not automatically be posted:\ %1';
        ErrorNoInstalments: Label 'Cannot create layaway with zero instalments';
        ErrorNoSaleLines: Label 'Cannot create layaway with no sales lines';

    procedure CreateLayaway(var POSSession: Codeunit "NPR POS Session"; DownpaymentPct: Decimal; Instalments: Integer; CreationFeeItemNo: Text; OrderPaymentTerms: Text; PrepaymentPaymentTerms: Text; ReserveItems: Boolean; OpenSalesOrder: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
        PaymentTerms: Record "Payment Terms";
        SalesHeader: Record "Sales Header";
        POSLayawayMgt: Codeunit "NPR POS Layaway Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalesOrder: Page "Sales Order";
        DownpaymentInvoiceNo: Text;
    begin
        if Instalments < 1 then
            Error(ErrorNoInstalments);

        POSSession.GetSaleLine(POSSaleLine);
        if POSSaleLine.IsEmpty() then
            Error(ErrorNoSaleLines);

        PaymentTerms.Get(PrepaymentPaymentTerms);
        PaymentTerms.TestField("Due Date Calculation");

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if not SelectCustomer(SalePOS) then
            SalePOS.TestField("Customer No.");
        if not SalePOS."Prices Including VAT" then begin
            SalePOS.Validate("Prices Including VAT", true);
            SalePOS.Modify(true);
        end;
        POSSale.RefreshCurrent();

        InsertCreationFeeItem(POSSession, CreationFeeItemNo);
        ExportToOrderAndEndSale(SalesHeader, POSSession, ReserveItems, OrderPaymentTerms);

        Commit();
        ClearLastError();
        Clear(POSLayawayMgt);
        POSLayawayMgt.SetRunCreateAndPostDownpmtAndLayawayInvoices(DownpaymentPct, PrepaymentPaymentTerms, Instalments);
        if POSLayawayMgt.Run(SalesHeader) then begin
            DownpaymentInvoiceNo := POSLayawayMgt.GetDownpaymentInvoiceNo();
            Commit();
            if OpenSalesOrder then begin
                SalesOrder.SetRecord(SalesHeader);
                SalesOrder.Run();
            end;
        end else
            Message(ErrorLayaway, GetLastErrorText);

        StartNewSale(POSSession, DownpaymentInvoiceNo);
    end;

    local procedure InsertCreationFeeItem(var POSSession: Codeunit "NPR POS Session"; CreationFeeItemNo: Text)
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        if CreationFeeItemNo = '' then
            exit;

        Item.Get(CreationFeeItemNo);
        Item.TestField(Type, Item.Type::Service);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
        SaleLinePOS.Validate("No.", CreationFeeItemNo);
        SaleLinePOS.Validate(Quantity, 1);
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
    end;


    local procedure ExportToOrderAndEndSale(var SalesHeaderOut: Record "Sales Header"; POSSession: Codeunit "NPR POS Session"; ReserveItems: Boolean; OrderPaymentTerms: Text)
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Payment Terms Code", OrderPaymentTerms);
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        RetailSalesDocMgt.SetDocumentTypeOrder();
        RetailSalesDocMgt.SetTransferSalesPerson(true);
        RetailSalesDocMgt.SetTransferPostingsetup(true);
        RetailSalesDocMgt.SetTransferDimensions(true);
        RetailSalesDocMgt.SetTransferTaxSetup(true);
        RetailSalesDocMgt.SetAutoReserveSalesLine(ReserveItems);
        RetailSalesDocMgt.SetAsk(false);
        RetailSalesDocMgt.SetPrint(false);
        RetailSalesDocMgt.SetInvoice(false);
        RetailSalesDocMgt.SetReceive(false);
        RetailSalesDocMgt.SetShip(false);
        RetailSalesDocMgt.SetSendPostedPdf2Nav(false);
        RetailSalesDocMgt.SetRetailPrint(true);
        RetailSalesDocMgt.SetOpenSalesDocAfterExport(false);
        RetailSalesDocMgt.ProcessPOSSale(POSSale);
        RetailSalesDocMgt.GetCreatedSalesHeader(SalesHeaderOut);
    end;

    local procedure StartNewSale(POSSession: Codeunit "NPR POS Session"; DownpaymentInvoiceNo: Text)
    var
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);

        if DownpaymentInvoiceNo <> '' then begin
            //End sale, auto start new sale and insert downpayment line.
            POSSession.StartTransaction();
            POSSession.ChangeViewSale();
            HandleDownpayment(POSSession, DownpaymentInvoiceNo);
        end else
            //End sale
            POSSale.SelectViewForEndOfSale()
    end;

    local procedure HandleDownpayment(var POSSession: Codeunit "NPR POS Session"; DownpaymentInvoiceNo: Text)
    var
        DummySalesHdr: Record "Sales Header";
        POSLayawayMgt: Codeunit "NPR POS Layaway Mgt.";
    begin
        Commit();
        ClearLastError();
        Clear(POSLayawayMgt);
        POSLayawayMgt.SetRunHandleDownpayment(POSSession, DownpaymentInvoiceNo);
        if not POSLayawayMgt.Run(DummySalesHdr) then
            Message(ErrorDownpayment, GetLastErrorText);
    end;

    local procedure SelectCustomer(var SalePOS: Record "NPR POS Sale"): Boolean
    var
        Customer: Record Customer;
    begin
        if SalePOS."Customer No." <> '' then begin
            Customer.Get(SalePOS."Customer No.");
            Customer.TestField("Application Method", Customer."Application Method"::Manual);
            exit(true);
        end;

        if Page.RunModal(0, Customer) <> Action::LookupOK then
            exit(false);

        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        Customer.Get(SalePOS."Customer No.");
        Customer.TestField("Application Method", Customer."Application Method"::Manual);
        Commit();
        exit(true);
    end;
}