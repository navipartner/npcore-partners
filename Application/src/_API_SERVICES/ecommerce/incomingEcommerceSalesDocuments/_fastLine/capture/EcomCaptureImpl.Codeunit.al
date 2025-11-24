#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248646 "NPR EcomCaptureImpl"
{
    Access = Internal;
    TableNo = "NPR Ecom Sales Header";

    internal procedure Process(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var Success: Boolean; var ErrorText: Text)
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        EcomLineCaptureProcess: Codeunit "NPR EcomLineCaptureProcess";
        AmountToCapture: Decimal;
        AmountToCaptureForPaymentLineCreation: Decimal;
        TotalProcessingPaymentAmount: Decimal;
        CaptureSuccess: Boolean;
        CaptureErrorText: Text;
        VirtualItemsAlreadyCapturedLbl: Label 'Virtual items in document: %1 have already been captured.', Comment = '%1 - recordid';
    begin
        if EcomSalesHeader."Creation Status" = EcomSalesHeader."Creation Status"::Created then
            EcomSalesHeader.FieldError("Creation Status");

        EcomSalesHeader.CalcFields("Captured Payment Amount");
        AmountToCapture := CalculateAmountToCapture(EcomSalesHeader) - EcomSalesHeader."Captured Payment Amount";
        AmountToCaptureForPaymentLineCreation := AmountToCapture;
        if EcomSalesHeader."Capture Processing Status" = EcomSalesHeader."Capture Processing Status"::Processed then
            Error(VirtualItemsAlreadyCapturedLbl, EcomSalesHeader.RecordId);

        MagentoPaymentLine.Reset();
        MagentoPaymentLine.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        MagentoPaymentLine.CalcSums(Amount);
        TotalProcessingPaymentAmount := MagentoPaymentLine.Amount;

        if TotalProcessingPaymentAmount < AmountToCapture then begin
            EcomSalesPmtLine.Reset();
            EcomSalesPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
            EcomSalesPmtLine.SetRange("Payment Method Type", EcomSalesPmtLine."Payment Method Type"::Voucher);
            EcomSalesPmtLine.SetFilter(Amount, '>0');
            EcomSalesPmtLine.SetAutoCalcFields("Processing Payment Amount");
            if EcomSalesPmtLine.FindSet() then
                repeat
                    InsertPaymentLineVoucherPmt(EcomSalesHeader, EcomSalesPmtLine, AmountToCaptureForPaymentLineCreation);
                until (EcomSalesPmtLine.Next() = 0) or (AmountToCaptureForPaymentLineCreation <= 0);

            if AmountToCaptureForPaymentLineCreation > 0 then begin
                EcomSalesPmtLine.Reset();
                EcomSalesPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
                EcomSalesPmtLine.SetRange("Payment Method Type", EcomSalesPmtLine."Payment Method Type"::"Payment Method");
                EcomSalesPmtLine.SetFilter(Amount, '>0');
                EcomSalesPmtLine.SetAutoCalcFields("Processing Payment Amount");
                if EcomSalesPmtLine.FindSet(true) then
                    repeat
                        InsertPaymentLinePaymentMethod(EcomSalesHeader, EcomSalesPmtLine, AmountToCaptureForPaymentLineCreation);
                    until (EcomSalesPmtLine.Next() = 0) or (AmountToCaptureForPaymentLineCreation <= 0);
            end;
        end;

        Success := true;

        if AmountToCapture > 0 then begin
            Commit();
            MagentoPaymentLine.Reset();
            MagentoPaymentLine.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
            MagentoPaymentLine.SetFilter(Amount, '<>0');
            MagentoPaymentLine.SetRange("Date Captured", 0D);
            if MagentoPaymentLine.FindSet() then
                repeat
                    Clear(EcomLineCaptureProcess);
                    EcomLineCaptureProcess.SetSkipHandleResponse(true);
                    EcomLineCaptureProcess.Run(MagentoPaymentLine);
                    EcomLineCaptureProcess.GetResponse(CaptureSuccess, CaptureErrorText);
                    if not CaptureSuccess then begin
                        Success := false;
                        ErrorText := CaptureErrorText;
                    end;
                until MagentoPaymentLine.Next() = 0;
        end;
    end;

    local procedure InsertPaymentLinePaymentMethod(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; var AmountToCapture: Decimal)
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        PaymentMethod: Record "Payment Method";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        EcomVirtualItemEvents: Codeunit "NPR EcomVirtualItemEvents";
        CardPaymentInstrumentTypeLbl: Label 'Card';
    begin
        if EcomSalesPmtLine."Payment Method Type" <> EcomSalesPmtLine."Payment Method Type"::"Payment Method" then
            exit;

        if EcomSalesPmtLine.Amount = 0 then
            exit;

        if EcomSalesPmtLine."Captured Amount" = EcomSalesPmtLine.Amount then
            exit;

        PaymentMapping.Reset();
        PaymentMapping.SetRange("External Payment Method Code", EcomSalesPmtLine."External Payment Method Code");
        PaymentMapping.SetRange("External Payment Type", EcomSalesPmtLine."External Payment Type");
        PaymentMapping.SetLoadFields("Allow Adjust Payment Amount", "Payment Gateway Code", "Payment Method Code", "Captured Externally");
        if not PaymentMapping.FindFirst() then begin
            PaymentMapping.SetRange("External Payment Type");
            PaymentMapping.FindFirst();
        end;

        PaymentMapping.TestField("Payment Method Code");
        PaymentMethod.Get(PaymentMapping."Payment Method Code");

        PaymentLine.Init();
        PaymentLine."Document Table No." := DATABASE::"NPR Ecom Sales Header";
        PaymentLine."Document Type" := EcomSalesPmtLine."Document Type";
        PaymentLine."Document No." := EcomSalesPmtLine."External Document No.";
        PaymentLine."Line No." := EcomSalesDocUtils.GetInternalEcomDocumentPaymentLastLineNo(EcomSalesHeader) + 10000;
        PaymentLine.Description := CopyStr(PaymentMethod.Description + ' ' + EcomSalesPmtLine."External Document No.", 1, MaxStrLen(PaymentLine.Description));
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::"Payment Method";
        PaymentLine."Account Type" := PaymentMethod."Bal. Account Type";
        PaymentLine."Account No." := PaymentMethod."Bal. Account No.";
        PaymentLine."No." := CopyStr(EcomSalesPmtLine."Payment Reference", 1, MaxStrLen(PaymentLine."No."));
        PaymentLine."Transaction ID" := EcomSalesPmtLine."Payment Reference";
        PaymentLine."Posting Date" := EcomSalesHeader."Created Date";
        PaymentLine."Source Table No." := DATABASE::"Payment Method";
        PaymentLine."Source No." := PaymentMethod.Code;
        if AmountToCapture > EcomSalesPmtLine.Amount then
            PaymentLine.Amount := EcomSalesPmtLine.Amount
        else
            PaymentLine.Amount := AmountToCapture;
        PaymentLine."Allow Adjust Amount" := PaymentMapping."Allow Adjust Payment Amount";
        PaymentLine."Payment Gateway Code" := PaymentMapping."Payment Gateway Code";
        PaymentLine."Payment Gateway Shopper Ref." := EcomSalesPmtLine."PAR Token";
        PaymentLine."Payment Token" := EcomSalesPmtLine."PSP Token";
        PaymentLine."Expiry Date Text" := EcomSalesPmtLine."Card Expiry Date";
        PaymentLine.Brand := EcomSalesPmtLine."Card Brand";
        PaymentLine."Payment Instrument Type" := CopyStr(CardPaymentInstrumentTypeLbl, 1, MaxStrLen(PaymentLine."Payment Instrument Type"));
        PaymentLine."Masked PAN" := EcomSalesPmtLine."Masked Card Number";
#pragma warning disable AA0139
        if Strlen(PaymentLine."Masked PAN") >= 4 then
            PaymentLine."Card Summary" := CopyStr(PaymentLine."Masked PAN", Strlen(PaymentLine."Masked PAN") - 3)
        else
            PaymentLine."Card Summary" := PaymentLine."Masked PAN";
#pragma warning restore AA0139
        PaymentLine."Card Alias Token" := EcomSalesPmtLine."Card Alias Token";
        PaymentLine."NPR Inc Ecom Sales Pmt Line Id" := EcomSalesPmtLine.SystemId;
        PaymentLine."NPR Inc Ecom Sale Id" := EcomSalesHeader.SystemId;
        if PaymentMapping."Captured Externally" then
            PaymentLine."Date Captured" := EcomSalesHeader."Created Date";

        EcomVirtualItemEvents.OnBeforeInsertPaymentLinePaymentMethod(PaymentLine, EcomSalesHeader, EcomSalesPmtLine);
        PaymentLine.Insert(true);

        AmountToCapture -= PaymentLine.Amount;
    end;

    local procedure InsertPaymentLineVoucherPmt(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; var TotalAmountToCapture: Decimal)
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        PaymentLine: Record "NPR Magento Payment Line";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        ReservedRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        POSPmtMethodItemMgt: Codeunit "NPR POS Pmt. Method Item Mgt.";
        EcomVirtualItemEvents: Codeunit "NPR EcomVirtualItemEvents";
        NpRvGlobalVoucherWebservice: Codeunit "NPR NpRv Global Voucher WS";
        ProcessVoucher: Boolean;
        InvalidVoucherLbl: Label 'Invalid Voucher Reference No. %1';
        VirtualItemSalesAmount: Decimal;
        VirtualItemPaidAmount: Decimal;
        AvailableAmountToCapture: Decimal;
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        AvailableVoucherAmount: Decimal;
    begin
        if EcomSalesPmtLine."Payment Method Type" <> EcomSalesPmtLine."Payment Method Type"::Voucher then
            exit;

        if EcomSalesPmtLine.Amount = 0 then
            exit;

        if EcomSalesPmtLine."Captured Amount" = EcomSalesPmtLine.Amount then
            exit;


        if EcomSalesPmtLine."Processing Payment Amount" >= EcomSalesPmtLine.Amount then
            exit;

        if not NpRvGlobalVoucherWebservice.FindVoucher('', CopyStr(EcomSalesPmtLine."Payment Reference", 1, MaxStrLen(NpRvSalesLine."Reference No.")), NpRvVoucher) then
            Error(InvalidVoucherLbl, EcomSalesPmtLine."Payment Reference");

        VoucherType.Get(NpRvVoucher."Voucher Type");
        if POSPmtMethodItemMgt.HasPOSPaymentMethodItemFilter(VoucherType."Payment Type") then begin
            VirtualItemSalesAmount := NpRvSalesDocMgt.CalcEcomOrderPaymentMethodItemSalesAmount(EcomSalesHeader, VoucherType."Payment Type");
            VirtualItemPaidAmount := NpRvSalesDocMgt.CalcEcomSalesOrderPaymentMethodItemPaymentAmount(EcomSalesHeader, VoucherType.Code, VoucherType."Payment Type");
            AvailableAmountToCapture := VirtualItemSalesAmount - VirtualItemPaidAmount;

            if AvailableAmountToCapture > TotalAmountToCapture then
                AvailableAmountToCapture := TotalAmountToCapture;
        end else
            AvailableAmountToCapture := EcomSalesPmtLine.Amount - EcomSalesPmtLine."Processing Payment Amount";

        if AvailableAmountToCapture > TotalAmountToCapture then
            AvailableAmountToCapture := TotalAmountToCapture;

        if not NpRvVoucherMgt.ValidateAmount(NpRvVoucher, AvailableAmountToCapture, AvailableVoucherAmount) then
            if AvailableAmountToCapture > AvailableVoucherAmount then
                AvailableAmountToCapture := AvailableVoucherAmount;

        ProcessVoucher := AvailableAmountToCapture <> 0;
        EcomVirtualItemEvents.OnCalculateVoucherCaptureAmountCanProcessVoucher(EcomSalesHeader, EcomSalesPmtLine, VoucherType, NpRvVoucher, TotalAmountToCapture, AvailableAmountToCapture, ProcessVoucher);
        if ProcessVoucher then begin
            NpRvSalesLine.Init();
            NpRvSalesLine.Id := CreateGuid();
            NpRvSalesLine."External Document No." := EcomSalesHeader."External No.";
            NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
            case EcomSalesHeader."Document Type" of
                EcomSalesHeader."Document Type"::Order:
                    NpRvSalesLine."Document Type" := NpRvSalesLine."Document Type"::Order;
                EcomSalesHeader."Document Type"::"Return Order":
                    NpRvSalesLine."Document Type" := NpRvSalesLine."Document Type"::"Credit Memo";
            end;
            NpRvSalesLine."Document No." := EcomSalesHeader."External No.";
            NpRvSalesLine.Type := NpRvSalesLine.Type::Payment;
            NpRvSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
            NpRvSalesLine."Voucher No." := NpRvVoucher."No.";
            NpRvSalesLine."Reference No." := NpRvVoucher."Reference No.";
            NpRvSalesLine.Description := NpRvVoucher.Description;
            NpRvSalesLine."NPR Inc Ecom Sale Id" := EcomSalesHeader.SystemId;
            NpRvSalesLine."NPR Inc Ecom Sales Pmt Line Id" := EcomSalesPmtLine.SystemId;
            NpRvSalesLine.Insert(true);

            Clear(PaymentLine);
            PaymentLine.Init();
            PaymentLine."Document Table No." := DATABASE::"NPR Ecom Sales Header";
            PaymentLine."Document Type" := EcomSalesPmtLine."Document Type";
            PaymentLine."Document No." := EcomSalesPmtLine."External Document No.";
            PaymentLine."Line No." := EcomSalesDocUtils.GetInternalEcomDocumentPaymentLastLineNo(EcomSalesHeader) + 10000;
            PaymentLine."Payment Type" := PaymentLine."Payment Type"::Voucher;
            PaymentLine.Description := NpRvVoucher.Description;
            PaymentLine."Account No." := NpRvVoucher."Account No.";
            PaymentLine."No." := NpRvVoucher."Reference No.";
            PaymentLine."Posting Date" := EcomSalesHeader."Received Date";
            PaymentLine."Source Table No." := DATABASE::"NPR NpRv Voucher";
            PaymentLine."Source No." := NpRvVoucher."No.";
            if TotalAmountToCapture > AvailableAmountToCapture then
                PaymentLine.Amount := AvailableAmountToCapture
            else
                PaymentLine.Amount := TotalAmountToCapture;
            PaymentLine."NPR Inc Ecom Sales Pmt Line Id" := EcomSalesPmtLine.SystemId;
            PaymentLine."NPR Inc Ecom Sale Id" := EcomSalesHeader.SystemId;
            EcomVirtualItemEvents.OnBeforeInsertPaymentLineVoucher(PaymentLine, EcomSalesHeader, EcomSalesPmtLine);
            PaymentLine.Insert();

            NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Payment Line";
            NpRvSalesLine."Document Line No." := PaymentLine."Line No.";
            NpRvSalesLine.Amount := PaymentLine.Amount;
            NpRvSalesLine."Reservation Line Id" := PaymentLine.SystemId;
            EcomVirtualItemEvents.OnBeforeModifyVoucherReference(NpRvSalesLine, PaymentLine);
            NpRvSalesLine.Modify(true);

            ReservedRvSalesLine.Reset();
            ReservedRvSalesLine.SetRange("Document Source", ReservedRvSalesLine."Document Source"::"Sales Document");
            ReservedRvSalesLine.SetRange("External Document No.", EcomSalesHeader."External No.");
            ReservedRvSalesLine.SetRange("Voucher Type", NpRvSalesLine."Voucher Type");
            ReservedRvSalesLine.SetRange("Voucher No.", NpRvSalesLine."Voucher No.");
            ReservedRvSalesLine.SetRange(Type, ReservedRvSalesLine.Type::Payment);
            ReservedRvSalesLine.SetRange("Document Line No.", 0);
            if ReservedRvSalesLine.FindFirst() then begin
                ReservedRvSalesLine.Amount -= NpRvSalesLine.Amount;
                if ReservedRvSalesLine.Amount <= 0 then
                    ReservedRvSalesLine.Delete(true)
                else
                    ReservedRvSalesLine.Modify(true);
            end;

            TotalAmountToCapture -= PaymentLine.Amount;
        end;
    end;

    local procedure CalculateAmountToCapture(EcomSalesHeader: Record "NPR Ecom Sales Header") AmountToCapture: Decimal
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetFilter(Type, '%1', EcomSalesLine.Type::Voucher);
        EcomSalesLine.SetFilter(Quantity, '<>%1', 0);
        EcomSalesLine.SetFilter("Unit Price", '<>%1', 0);
        EcomSalesLine.SetLoadFields("Line Amount", "VAT %");
        if not EcomSalesLine.FindSet() then
            exit;

        repeat
            if not EcomSalesHeader."Price Excl. VAT" then
                AmountToCapture += EcomSalesLine."Line Amount" * (1 + (EcomSalesLine."VAT %" / 100))
            else
                AmountToCapture += EcomSalesLine."Line Amount";
        until EcomSalesLine.Next() = 0;
    end;
}
#endif