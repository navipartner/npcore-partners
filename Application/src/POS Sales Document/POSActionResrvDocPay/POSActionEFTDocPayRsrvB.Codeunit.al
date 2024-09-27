codeunit 6184941 "NPR POSActionEFTDocPayRsrvB"
{
    Access = Internal;
    internal procedure CheckCustomer(var SalePOS: Record "NPR POS Sale"; POSSale: Codeunit "NPR POS Sale"; SelectCustomer: Boolean) CustomerSelected: Boolean
    var
        Customer: Record Customer;
    begin
        CustomerSelected := SalePOS."Customer No." <> '';
        if CustomerSelected then
            exit;

        CustomerSelected := not SelectCustomer;
        if CustomerSelected then
            exit;


        CustomerSelected := Page.RunModal(0, Customer) = Action::LookupOK;
        if not CustomerSelected then
            exit;

        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        POSSale.RefreshCurrent();

        Commit();
    end;

    internal procedure SelectDocument(SalePOS: Record "NPR POS Sale"; var SalesHeader: Record "Sales Header") DocumentSelected: Boolean
    var
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
        SalesDocumentFilterText: Text;
    begin
        SalesDocumentFilterText := CreateSalesHeaderFilterFromSalePOS(SalePOS);
        SalesHeader.SetFilter("Bill-to Customer No.", SalePOS."Customer No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetFilter("No.", SalesDocumentFilterText);

        DocumentSelected := RetailSalesDocImpMgt.SelectSalesDocument(SalesHeader.GetView(false), SalesHeader);
    end;

    internal procedure ConfirmDocument(SalesHeader: Record "Sales Header"; OpenDocument: Boolean) Success: Boolean
    var
        PageMgt: Codeunit "Page Management";
    begin
        Success := not OpenDocument;
        if Success then
            exit;

        Success := Page.RunModal(PageMgt.GetPageID(SalesHeader), SalesHeader) = Action::LookupOK;
    end;

    local procedure CreateSalesHeaderFilterFromSalePOS(SalePOS: Record "NPR POS Sale") SalesHeaderFilterText: Text;
    var
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        POSSaleLine.Reset();
        POSSaleLine.SetRange("Register No.", SalePOS."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        POSSaleLine.SetFilter("Sales Document No.", '<>%1', '');
        POSSaleLine.SetLoadFields("Register No.", "Sales Ticket No.", "Sales Document No.");
        if not POSSaleLine.FindSet() then
            exit;

        repeat
            SalesHeaderFilterText += '&<>' + POSSaleLine."Sales Document No.";
        until POSSaleLine.Next() = 0;

        SalesHeaderFilterText := CopyStr(SalesHeaderFilterText, 2);
    end;

    internal procedure CreateDocumentReservationAmountSalesLine(POSSession: Codeunit "NPR POS Session"; SalePOS: Record "NPR POS Sale"; SalesHeader: Record "Sales Header"; POSPaymentMethodCode: Code[10])
    var
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
        ReservationAmount: Decimal;
        NothingToReserverErrorLbl: Label 'The whole amount of document %1 %2 has already been reserved - %3.', Comment = '%1 - Document Type, %2 - Document No., %3 - Amount Including VAT';
    begin
        SalesHeader.CalcFields("Amount Including VAT");
        ReservationAmount := GetReservationAmount(POSPaymentMethodCode, SalePOS, SalesHeader);
        if ReservationAmount = 0 then
            Error(NothingToReserverErrorLbl, SalesHeader."Document Type", SalesHeader."No.", SalesHeader."Amount Including VAT");

        RetailSalesDocImpMgt.SalesDocumentAmountToPOS(POSSession, SalesHeader, false, false, false, SalesHeader."Print Posted Documents", false, false, Enum::"NPR POS Sales Document Post"::No, ReservationAmount);
    end;

    internal procedure GetSalesHeaderFromPOSSale(SalePOs: Record "NPR POS Sale"; var SalesHeader: Record "Sales Header") Found: Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.Reset();
        SaleLinePOS.Setrange("Register No.", SalePOs."Register No.");
        SaleLinePOS.Setrange("Sales Ticket No.", SalePOs."Sales Ticket No.");
        SaleLinePOS.Setfilter("Sales Document No.", '<>%1', '');
        SaleLinePOS.SetLoadFields("Register No.", "Sales Ticket No.", "Sales Document No.", "Sales Document Type");
        Found := SaleLinePOS.FindFirst();
        if not found then
            exit;

        Found := SalesHeader.Get(SaleLinePOS."Sales Document Type", SaleLinePOS."Sales Document No.");
    end;

    internal procedure ValidateReservationMethod(SalePOS: Record "NPR POS Sale"; POSPaymentReservationMethod: Code[10])
    var
        POSPaymentMethodFromLine: Record "NPR POS Payment Method";
        SaleLinePOS: Record "NPR POS Sale Line";
        OriginalPOSPaymentMethodCode: Code[10];
        NotAuthorizedReservationMethodExistsLbl: Label 'A line with unauthorized pos payment reservation method exits - %1. The allowed reservation method is %2.', Comment = '%1 - POS Payment Reservation Method, %2 - Allowed POS Payment Reservation Method';
    begin
        ValidatePOSPaymentMethod(POSPaymentReservationMethod, SalePOS."Register No.");

        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::"POS Payment");
        SaleLinePOS.SetFilter("No.", '<>%1', POSPaymentReservationMethod);
        SaleLinePOS.SetLoadFields("Register No.", "Sales Ticket No.", "Line Type", "No.");
        if not SaleLinePOS.FindSet() then
            exit;

        repeat
            POSPaymentMethodFromLine.Get(SaleLinePOS."No.");
            if POSPaymentMethodFromLine."Processing Type" <> POSPaymentMethodFromLine."Processing Type"::EFT then
                Error(NotAuthorizedReservationMethodExistsLbl, SaleLinePOS."No.", POSPaymentMethodFromLine.Code)
            else begin
                OriginalPOSPaymentMethodCode := GetOriginalPaymentMethodCodeFromPaymentLine(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.");
                if OriginalPOSPaymentMethodCode <> POSPaymentReservationMethod then
                    Error(NotAuthorizedReservationMethodExistsLbl, SaleLinePOS."No.", POSPaymentMethodFromLine.Code)
            end;
        until SaleLinePOS.Next() = 0;

    end;

    local procedure ValidatePOSaleEmpty(SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        NotEmptyPOSSaleLbl: Label 'The document payment reservation must be done in a new sale.';
    begin
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.IsEmpty then
            exit;

        Error(NotEmptyPOSSaleLbl);
    end;

    internal procedure ValidatePOSSale(SalePOS: Record "NPR POS Sale"; POSPaymentReservationMethod: Code[10])
    begin
        ValidatePOSaleEmpty(SalePOS);
        ValidateReservationMethod(SalePOS, POSPaymentReservationMethod);
    end;

    local procedure GetEFTDocumentReservationTypeFromPOSPaymentMethod(POSPaymentMethodCode: Code[10]; POSUnitNo: Code[10]) EFTDocPayRsrvType: Enum "NPR EFT Doc Pay Rsrv Type";
    var
        TempEFTIntegrationType: Record "NPR EFT Integration Type" temporary;
        EFTSetup: Record "NPR EFT Setup";
        EFTInterface: Codeunit "NPR EFT Interface";
    begin
        EFTSetup.FindSetup(POSUnitNo, POSPaymentMethodCode);
        EFTInterface.OnDiscoverIntegrations(TempEFTIntegrationType);
        TempEFTIntegrationType.Get(EFTSetup."EFT Integration Type");

        EFTDocPayRsrvType := Enum::"NPR EFT Doc Pay Rsrv Type".FromInteger(TempEFTIntegrationType."Codeunit ID");
    end;

    internal procedure CreateDocumentPaymentReservationLines(SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
    begin
        GetSalesHeaderFromPOSSale(SalePOS, SalesHeader);

        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::"POS Payment");
        SaleLinePOS.SetFilter("Amount Including VAT", '>%1', 0);
        if not SaleLinePOS.FindSet() then
            exit;

        repeat
            ProcessPOSPayment(SaleLinePOS, SalesHeader);
        until SaleLinePOS.Next() = 0;
    end;

    internal procedure ReservePOSPaymentLine(SaleLinePOS: Record "NPR POS Sale Line"; SalesHeader: Record "Sales Header"; var MagentoPaymentLine: Record "NPR Magento Payment Line") Reserved: Boolean;
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        EFTDocPayReservation: Interface "NPR EFT Doc Pay Reservation";
        OriginalPOSPaymentMethodCode: Code[10];
    begin
        Clear(MagentoPaymentLine);
        OriginalPOSPaymentMethodCode := GetOriginalPaymentMethodCodeFromPaymentLine(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.");

        if not POSPaymentMethod.Get(OriginalPOSPaymentMethodCode) then
            exit;

        if POSPaymentMethod."Processing Type" <> POSPaymentMethod."Processing Type"::EFT then
            exit;

        EFTDocPayReservation := GetEFTDocumentReservationTypeFromPOSPaymentMethod(OriginalPOSPaymentMethodCode, SaleLinePOS."Register No.");
        Reserved := EFTDocPayReservation.Reserve(SaleLinePOS, SalesHeader, MagentoPaymentLine);
    end;

    internal procedure GetReservationAmount(PaymentMethodCode: Code[10]; SalePOS: Record "NPR POS Sale"; SalesHeader: Record "Sales Header") ReservationAmount: Decimal;
    var
        EFTDocPayReservation: Interface "NPR EFT Doc Pay Reservation";
    begin
        EFTDocPayReservation := GetEFTDocumentReservationTypeFromPOSPaymentMethod(PaymentMethodCode, SalePOS."Register No.");
        ReservationAmount := EFTDocPayReservation.GetReservationAmount(SalesHeader);
    end;

    local procedure GetOriginalPaymentMethodCodeFromPaymentLine(SalesTicketNo: Code[20]; SalesLineNo: Integer) POSPaymentMethodCode: Code[10]
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.Reset();
        EFTTransactionRequest.SetCurrentKey("Sales Ticket No.", "Sales Line No.");
        EFTTransactionRequest.SetRange("Sales Ticket No.", SalesTicketNo);
        EFTTransactionRequest.SetRange("Sales Line No.", SalesLineNo);
        EFTTransactionRequest.SetLoadFields("Sales Ticket No.", "Sales Line No.", "Original POS Payment Type Code");
        if not EFTTransactionRequest.FindFirst() then
            exit;

        POSPaymentMethodCode := EFTTransactionRequest."Original POS Payment Type Code";
    end;

    internal procedure ValidatePOSPaymentMethod(POSPaymentMethodCode: Code[10]; POSUnitNo: Code[10])
    var
        EFTDocPayReservation: Interface "NPR EFT Doc Pay Reservation";
    begin
        if POSPaymentMethodCode = '' then
            exit;

        EFTDocPayReservation := GetEFTDocumentReservationTypeFromPOSPaymentMethod(POSPaymentMethodCode, POSUnitNo);
        EFTDocPayReservation.ValidatePOSPaymentMethod(POSPaymentMethodCode, POSUnitNo);
    end;

    internal procedure CheckPOSEFTPaymentReservationSetup()
    var
        AdyenSetup: Record "NPR Adyen Setup";
        EFTPayReservSetupUtils: Codeunit "NPR EFT Pay Reserv Setup Utils";
    begin
        AdyenSetup.Get();
        EFTPayReservSetupUtils.CheckPaymentServationSetup(AdyenSetup);
    end;

    local procedure ProcessVouchers(SalesHeader: Record "Sales Header"; SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        VoucherSaleLinePOS: Record "NPR NpRv Sales Line";
        NPRNpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
    begin
        if SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::"POS Payment" then
            exit;

        if not POSPaymentMethod.Get(SaleLinePOS."No.") then
            exit;

        if POSPaymentMethod."Processing Type" <> POSPaymentMethod."Processing Type"::VOUCHER then
            exit;

        VoucherSaleLinePOS.Reset();
        VoucherSaleLinePOS.SetCurrentKey("Retail ID");
        VoucherSaleLinePOS.SetRange("Retail ID", SaleLinePOS.SystemId);
        VoucherSaleLinePOS.SetRange(Type, VoucherSaleLinePOS.Type::Payment);
        if not VoucherSaleLinePOS.FindFirst() then
            exit;

        NPRNpRvSalesDocMgt.RedeemVoucher(SalesHeader, VoucherSaleLinePOS, SaleLinePOS."Amount Including VAT");
    end;

    internal procedure ProcessPOSPayment(SaleLinePOS: Record "NPR POS Sale Line"; SalesHeader: Record "Sales Header")
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
    begin
        ReservePOSPaymentLine(SaleLinePOS, SalesHeader, MagentoPaymentLine);
        ProcessVouchers(SalesHeader, SaleLinePOS);
    end;

    internal procedure DeletePaymentLines()
    var
        POSSession: Codeunit "NPR POS Session";
        DeletePOSLineB: Codeunit "NPR POSAct:Delete POS Line-B";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        while not POSPaymentLine.IsEmpty() do
            DeletePOSLineB.DeletePaymentLine(POSPaymentLine);
    end;
}
