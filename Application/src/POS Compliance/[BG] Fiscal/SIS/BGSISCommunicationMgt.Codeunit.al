codeunit 6184476 "NPR BG SIS Communication Mgt."
{
    Access = Internal;

    var
        BGFiscalReceiptNotFiscalisedLbl: Label 'BG Fiscal Receipt Error';
        FinishEventIdTok: Label 'NPR_BG_SIS', Locked = true;

    #region Process Response Procedures
    internal procedure ProcessFiscalPrinterInfoResponse(POSUnitNo: Code[10]; ResponseText: Text)
    var
        TempJsonBuffer: Record "JSON Buffer" temporary;
        BGSISPOSUnitMapping: Record "NPR BG SIS POS Unit Mapping";
    begin
        BGSISPOSUnitMapping.Get(POSUnitNo);
        if IsResponseSuccessfulAndThrowErrorIfNot(TempJsonBuffer, ResponseText) then
            FillFiscalPrinterInfo(BGSISPOSUnitMapping, TempJsonBuffer);
    end;

    internal procedure ProcessPrintSaleAndRefundResponse(var BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux."; POSUnitNo: Code[10]; ResponseText: Text; RequestText: Text; ExtendedReceipt: Boolean)
    var
        TempJsonBuffer: Record "JSON Buffer" temporary;
        BGSISPOSUnitMapping: Record "NPR BG SIS POS Unit Mapping";
    begin
        if IsResponseSuccessfulAndThrowErrorIfNot(TempJsonBuffer, ResponseText) then begin
            BGSISPOSUnitMapping.Get(POSUnitNo);
            UpdateBGSISAuditLogForSaleAndRefund(BGSISPOSAuditLogAux, BGSISPOSUnitMapping, TempJsonBuffer, RequestText, ExtendedReceipt);
        end else begin
            ErrorLogReceiptFiscalisated(ResponseText);
            UpdateBGSISAuditLogRequestContent(BGSISPOSAuditLogAux, RequestText, ExtendedReceipt);
        end;
    end;

    internal procedure ProcessPrintXReportResponse(ResponseText: Text)
    begin
        ThrowErrorIfResponseNotSuccessful(ResponseText);
    end;

    internal procedure ProcessPrintZReportResponse(ResponseText: Text)
    begin
        ThrowErrorIfResponseNotSuccessful(ResponseText);
    end;

    internal procedure ProcessPrintDuplicateResponse(ResponseText: Text)
    begin
        ThrowErrorIfResponseNotSuccessful(ResponseText);
    end;

    internal procedure ProcessPrintReportFromFiscalMemoryResponse(ResponseText: Text)
    begin
        ThrowErrorIfResponseNotSuccessful(ResponseText);
    end;

    internal procedure ProcessExportDataFromElectronicJournalResponse(ResponseText: Text)
    begin
        ThrowErrorIfResponseNotSuccessful(ResponseText);
    end;

    internal procedure ProcessReprintFromElectronicJournalResponse(ResponseText: Text)
    begin
        ThrowErrorIfResponseNotSuccessful(ResponseText);
    end;

    internal procedure ProcessCashHandlingResponse(ResponseText: Text)
    begin
        ThrowErrorIfResponseNotSuccessful(ResponseText);
    end;

    internal procedure ProcessGetCashBalanceResponse(ResponseText: Text)
    var
        TempJsonBuffer: Record "JSON Buffer" temporary;
        CashBalanceMsg: Label 'Cash balance is %1.', Comment = '%1 - cash balance value';
        CashBalance: Text;
    begin
        if IsResponseSuccessfulAndThrowErrorIfNot(TempJsonBuffer, ResponseText) then begin
            CashBalance := GetPropertyValueWithCheck(TempJsonBuffer, 'cashBalance');
            Message(CashBalanceMsg, CashBalance);
        end;
    end;

    internal procedure ProcessGetCashierDataResponse(ResponseText: Text)
    begin
        ThrowErrorIfResponseNotSuccessful(ResponseText);
    end;

    internal procedure ProcessIsCashierSetResponse(SalespersonCode: Code[20]; ResponseText: Text)
    var
        TempJsonBuffer: Record "JSON Buffer" temporary;
    begin
        if IsResponseSuccessfulAndThrowErrorIfNot(TempJsonBuffer, ResponseText) then
            ThrowErrorIfCashierIsNotSet(SalespersonCode, TempJsonBuffer);
    end;

    internal procedure ProcessSetCashierResponse(ResponseText: Text)
    begin
        ThrowErrorIfResponseNotSuccessful(ResponseText);
    end;

    [TryFunction]
    internal procedure TryProcessSetCashierResponse(ResponseText: Text)
    begin
        ThrowErrorIfResponseNotSuccessful(ResponseText);
    end;

    internal procedure ProcessDeleteCashierResponse(ResponseText: Text)
    begin
        ThrowErrorIfResponseNotSuccessful(ResponseText);
    end;

    // TO-DO this will be finished in one of the future tasks
    // internal procedure ProcessGetReceiptResponse(var BGSISPOSAuditLogAux: Record "NPR BG POS SIS Audit Log Aux."; ResponseText: Text)
    // var
    //     TempJsonBuffer: Record "JSON Buffer" temporary;
    // begin
    //     if IsResponseSuccessfulAndThrowErrorIfNot(TempJsonBuffer, ResponseText) then
    //         UpdateBGSISAuditLogReceipt(BGSISPOSAuditLogAux, TempJsonBuffer);
    // end;
    #endregion

    #region JSON Fiscal Creators
    local procedure InitJSONBody(var JsonTextReaderWriter: Codeunit "Json Text Reader/Writer")
    begin
        JsonTextReaderWriter.WriteStartObject('');
        JsonTextReaderWriter.WriteRawProperty('id', 1);
        JsonTextReaderWriter.WriteStringProperty('jsonrpc', '2.0');
    end;

    internal procedure CreateJSONBodyForRefreshFiscalPrinterInfo() JsonBody: Text
    var
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
    begin
        InitJSONBody(JsonTextReaderWriter);
        JsonTextReaderWriter.WriteStringProperty('method', 'getMfcInfo');
        JsonTextReaderWriter.WriteEndObject();
        JsonBody := JsonTextReaderWriter.GetJSonAsText();
    end;

    internal procedure CreateJSONBodyForSaleAndRefund(BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux."; var ExtendedReceipt: Boolean) JsonBody: Text
    var
        POSEntry: Record "NPR POS Entry";
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
        Refund: Boolean;
    begin
        POSEntry.Get(BGSISPOSAuditLogAux."POS Entry No.");
        Refund := BGSISPOSAuditLogAux."Transaction Type" = BGSISPOSAuditLogAux."Transaction Type"::Refund;

        InitJSONBody(JsonTextReaderWriter);
        JsonTextReaderWriter.WriteStringProperty('method', 'printReceipt');
        JsonTextReaderWriter.WriteStartObject('params');

        AddBeginFiscalReceiptInputJSONObjectForSaleAndRefund(JsonTextReaderWriter, POSEntry);
        if ExtendedReceipt then
            AddInvoiceDataJSONObjectForSaleAndRefund(JsonTextReaderWriter, POSEntry, ExtendedReceipt, Refund);

        AddReceiptItemsJSONArrayForSaleAndRefund(JsonTextReaderWriter, POSEntry."Entry No.", Refund);
        AddReceiptPaymentsJSONArrayForSaleAndRefund(JsonTextReaderWriter, POSEntry."Entry No.", Refund);
        if Refund then
            AddStornoInputJSONObjectForRefund(JsonTextReaderWriter, ExtendedReceipt, POSEntry."Entry No.");

        JsonTextReaderWriter.WriteEndObject(); // params
        JsonTextReaderWriter.WriteEndObject();
        JsonBody := JsonTextReaderWriter.GetJSonAsText();
    end;

    local procedure AddBeginFiscalReceiptInputJSONObjectForSaleAndRefund(var JsonTextReaderWriter: Codeunit "Json Text Reader/Writer"; POSEntry: Record "NPR POS Entry")
    var
        BGFiscalizationSetup: Record "NPR BG Fiscalization Setup";
        OperatorNumber: Integer;
    begin
        JsonTextReaderWriter.WriteStartObject('beginFiscalReceiptInput');

        BGFiscalizationSetup.Get();
        if BGFiscalizationSetup."BG SIS on PDF" then
            JsonTextReaderWriter.WriteRawProperty('onPdf', 1);
        Evaluate(OperatorNumber, POSEntry."Salesperson Code");
        JsonTextReaderWriter.WriteRawProperty('operatorNumber', OperatorNumber);
        JsonTextReaderWriter.WriteStringProperty('posId', POSEntry."POS Unit No.");
        JsonTextReaderWriter.WriteEndObject();
    end;

    local procedure AddInvoiceDataJSONObjectForSaleAndRefund(var JsonTextReaderWriter: Codeunit "Json Text Reader/Writer"; POSEntry: Record "NPR POS Entry"; var ExtendedReceipt: Boolean; Refund: Boolean)
    var
        Customer: Record Customer;
        BGSISPOSUnitMapping: Record "NPR BG SIS POS Unit Mapping";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        ExtendedReceiptNo: Code[20];
        CustomerIDNumberType: Integer;
        CustomerAddress: Text;
        CustomerCity: Text;
        CustomerID: Text;
        CustomerName: Text;
        CustomerVATNumber: Text;
    begin
        if POSEntry."Customer No." <> '' then
            if Customer.Get(POSEntry."Customer No.") then begin
                CustomerAddress := Customer.Address;
                CustomerCity := Customer.City;
                CustomerID := GetCustomerIdentificationNo(Customer);
                CustomerName := Customer.Name;
                CustomerVATNumber := Customer."VAT Registration No.";
            end;

        if not EnterInvoiceDataForSaleAndRefund(CustomerIDNumberType, CustomerAddress, CustomerCity, CustomerID, CustomerName, CustomerVATNumber) then begin
            ExtendedReceipt := false;
            exit;
        end;

        BGSISPOSUnitMapping.Get(POSEntry."POS Unit No.");
        if Refund then
            ExtendedReceiptNo := NoSeriesManagement.GetNextNo(BGSISPOSUnitMapping."Extended Receipt Cr. Memo No.", WorkDate(), false)
        else
            ExtendedReceiptNo := NoSeriesManagement.GetNextNo(BGSISPOSUnitMapping."Extended Receipt Invoice No.", WorkDate(), false);

        JsonTextReaderWriter.WriteStartObject('invoiceData');
        JsonTextReaderWriter.WriteStringProperty('invNumber', ExtendedReceiptNo);
        JsonTextReaderWriter.WriteStringProperty('city', CopyStr(CustomerCity, 1, 30));
        JsonTextReaderWriter.WriteStringProperty('identNumber', CopyStr(CustomerID, 1, 30));
        JsonTextReaderWriter.WriteRawProperty('identNumberType', CustomerIDNumberType);
        JsonTextReaderWriter.WriteStringProperty('recipientAddress', CopyStr(CustomerAddress, 1, 30));
        JsonTextReaderWriter.WriteStringProperty('recipientName', CopyStr(CustomerName, 1, 30));
        if CustomerVATNumber <> '' then
            JsonTextReaderWriter.WriteStringProperty('vatIdentNumber', CopyStr(CustomerVATNumber, 1, 15));
        JsonTextReaderWriter.WriteEndObject();
    end;

    local procedure GetCustomerIdentificationNo(Customer: Record Customer) IdentificationNo: Text
    var
        Handled: Boolean;
    begin
        OnGetCustomerIdentificationNo(Customer, IdentificationNo, Handled);
    end;

    local procedure EnterInvoiceDataForSaleAndRefund(var CustomerIDNumberType: Integer; var CustomerAddress: Text; var CustomerCity: Text; var CustomerID: Text; var CustomerName: Text; var CustomerVATNumber: Text): Boolean
    var
        InputDialog: Page "NPR Input Dialog";
        ActionOK: Boolean;
        AllInvoiceDataCorrect, AllInvoiceDataEntered, AllInvoiceDataEnteredSuccessfully : Boolean;
        AbortCreationOfExtendedReceiptQst: Label 'Are you sure that you do not want to create extended fiscal receipt?';
        CustomerAddressLbl: Label 'Customer Address';
        CustomerCityLbl: Label 'Customer City';
        CustomerIDLbl: Label 'Customer ID';
        CustomerIDMsg: Label 'Customer ID does not have allowed value.';
        CustomerIDNumberTypeLbl: Label 'Customer ID Number Type (0 - BG Company; 1 - BG Physical Person; 2 - Foreign Company or Physical Person)';
        CustomerIDNumberTypeMsg: Label 'Customer ID Number Type does not have allowed value.';
        CustomerNameLbl: Label 'Customer Name';
        CustomerVATNumberLbl: Label 'Customer VAT Number';
        CustomerVATNumberMsg: Label 'Customer VAT Number does not have allowed value.';
        MustEnterNecessaryExtendedReceiptDataMsg: Label 'You must enter all the necessary data for extended receipt.';
    begin
        while not AllInvoiceDataEnteredSuccessfully do begin
            Clear(InputDialog);
            InputDialog.SetInput(1, CustomerCity, CustomerCityLbl);
            InputDialog.SetInput(2, CustomerID, CustomerIDLbl);
            InputDialog.SetInput(3, CustomerIDNumberType, CustomerIDNumberTypeLbl);
            InputDialog.SetInput(4, CustomerAddress, CustomerAddressLbl);
            InputDialog.SetInput(5, CustomerName, CustomerNameLbl);
            InputDialog.SetInput(6, CustomerVATNumber, CustomerVATNumberLbl);

            if InputDialog.RunModal() = Action::OK then
                ActionOK := true
            else begin
                ActionOK := false;
                if Confirm(AbortCreationOfExtendedReceiptQst) then
                    exit(false);

                AllInvoiceDataEnteredSuccessfully := false;
            end;

            if ActionOK then begin
                InputDialog.InputText(1, CustomerCity);
                InputDialog.InputText(2, CustomerID);
                InputDialog.InputInteger(3, CustomerIDNumberType);
                InputDialog.InputText(4, CustomerAddress);
                InputDialog.InputText(5, CustomerName);
                InputDialog.InputText(6, CustomerVATNumber);

                Clear(AllInvoiceDataCorrect);
                AllInvoiceDataEntered := (CustomerCity <> '') and (CustomerID <> '') and (CustomerAddress <> '') and (CustomerName <> '');
                if not AllInvoiceDataEntered then
                    Message(MustEnterNecessaryExtendedReceiptDataMsg)
                else begin
                    AllInvoiceDataCorrect := IsCustomerIDNumberTypealueAllowed(CustomerIDNumberType);
                    if not AllInvoiceDataCorrect then
                        Message(CustomerIDNumberTypeMsg)
                    else begin
                        AllInvoiceDataCorrect := IsCustomerIDNumberAllowed(CustomerIDNumberType, CustomerID);
                        if not AllInvoiceDataCorrect then
                            Message(CustomerIDMsg)
                        else begin
                            AllInvoiceDataCorrect := IsCustomerVATNumberValueAllowed(CustomerIDNumberType, CustomerVATNumber);
                            if not AllInvoiceDataCorrect then
                                Message(CustomerVATNumberMsg);
                        end;
                    end;

                    AllInvoiceDataEnteredSuccessfully := AllInvoiceDataEntered and AllInvoiceDataCorrect;
                end;
            end;
        end;

        exit(true);
    end;

    local procedure IsCustomerIDNumberTypealueAllowed(CustomerIDNumberType: Integer): Boolean
    begin
        if not (CustomerIDNumberType in [0, 1, 2]) then
            exit(false);

        exit(true);
    end;

    local procedure IsCustomerIDNumberAllowed(CustomerIDNumberType: Integer; CustomerID: Text): Boolean
    var
        CharPos: Integer;
        CustomerIDLenght: Integer;
    begin
        CustomerIDLenght := StrLen(CustomerID);

        case CustomerIDNumberType of
            0, 1:
                begin
                    if not (CustomerIDLenght in [9, 10, 13, 15]) then
                        exit(false);

                    for CharPos := 1 to CustomerIDLenght do
                        if not IsDigit(CopyStr(CustomerID, CharPos, 1)) then
                            exit(false);

                    exit(true);
                end;
            2:
                begin
                    if not (CustomerIDLenght in [1 .. 13]) then
                        exit(false);

                    for CharPos := 1 to CustomerIDLenght do
                        if not IsAlphanumeric(CopyStr(CustomerID, CharPos, 1)) then
                            exit(false);

                    exit(true);
                end;
        end;
    end;

    local procedure IsCustomerVATNumberValueAllowed(CustomerIDNumberType: Integer; CustomerVATNumber: Text): Boolean
    var
        CharPos: Integer;
        CustomerVATNumberLenght: Integer;
    begin
        if CustomerIDNumberType <> 0 then
            exit(true);

        CustomerVATNumberLenght := StrLen(CustomerVATNumber);

        if CustomerVATNumberLenght = 0 then
            exit(true);

        if not (CustomerVATNumberLenght in [1 .. 15]) then
            exit(false);

        for CharPos := 1 to CustomerVATNumberLenght do
            if not IsAlphanumeric(CopyStr(CustomerVATNumber, CharPos, 1)) then
                exit(false);

        exit(true);
    end;

    local procedure AddReceiptItemsJSONArrayForSaleAndRefund(var JsonTextReaderWriter: Codeunit "Json Text Reader/Writer"; POSEntryNo: Integer; Refund: Boolean)
    var
        BGSISVATPostSetupMap: Record "NPR BG SIS VAT Post. Setup Map";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        TotalsRoundingDifference: Decimal;
        UnitPrice: Decimal;
    begin
        JsonTextReaderWriter.WriteStartArray('receiptItems');

        POSEntrySalesLine.SetRange("POS Entry No.", POSEntryNo);
        POSEntrySalesLine.SetFilter(Type, '%1|%2', POSEntrySalesLine.Type::Item, POSEntrySalesLine.Type::Voucher);
        POSEntrySalesLine.SetFilter(Quantity, '<>0');
        if POSEntrySalesLine.FindSet() then
            repeat
                Clear(TotalsRoundingDifference);
                JsonTextReaderWriter.WriteStartObject('');
                JsonTextReaderWriter.WriteStringProperty('description', CopyStr(POSEntrySalesLine.Description, 1, 64));
                BGSISVATPostSetupMap.Get(POSEntrySalesLine."VAT Bus. Posting Group", POSEntrySalesLine."VAT Prod. Posting Group");
                BGSISVATPostSetupMap.CheckIsBGSISVATCategoryPopulated();
                JsonTextReaderWriter.WriteRawProperty('enumVatCategory', BGSISVATPostSetupMap."BG SIS VAT Category".AsInteger());
                if Refund then begin
                    if POSEntrySalesLine."Line Discount Amount Incl. VAT" = 0 then
                        JsonTextReaderWriter.WriteStringProperty('price', Format(Abs(Round(POSEntrySalesLine."Unit Price", 0.01)), 0, '<Sign><Precision,2:2><Integer><Decimals>'))
                    else begin
                        CalculateUnitPriceAndTotalsRoundingDifference(POSEntrySalesLine, UnitPrice, TotalsRoundingDifference);
                        JsonTextReaderWriter.WriteStringProperty('price', Format(UnitPrice, 0, '<Sign><Precision,2:2><Integer><Decimals>'));
                    end;
                    JsonTextReaderWriter.WriteStringProperty('quantity', Format(Abs(Round(POSEntrySalesLine.Quantity, 0.01)), 0, '<Sign><Precision,2:2><Integer><Decimals>'));
                end else begin
                    JsonTextReaderWriter.WriteStringProperty('price', Format(Abs(Round(POSEntrySalesLine."Unit Price", 0.01)), 0, '<Sign><Precision,2:2><Integer><Decimals>'));
                    JsonTextReaderWriter.WriteStringProperty('quantity', Format(Abs(Round(POSEntrySalesLine.Quantity, 0.01)), 0, '<Sign><Precision,2:2><Integer><Decimals>'));
                    if POSEntrySalesLine."Line Discount Amount Incl. VAT" <> 0 then
                        JsonTextReaderWriter.WriteStringProperty('surchargeAmount', Format(-Round(POSEntrySalesLine."Line Discount Amount Incl. VAT", 0.01), 0, '<Sign><Precision,2:2><Integer><Decimals>'));
                end;
                JsonTextReaderWriter.WriteEndObject();

                if TotalsRoundingDifference <> 0 then
                    AddRoundingCorrectionToReceiptItemsJSONArrayForSaleAndRefund(JsonTextReaderWriter, BGSISVATPostSetupMap, TotalsRoundingDifference);
            until POSEntrySalesLine.Next() = 0;

        JsonTextReaderWriter.WriteEndArray();
    end;

    local procedure CalculateUnitPriceAndTotalsRoundingDifference(POSEntrySalesLine: Record "NPR POS Entry Sales Line"; var UnitPrice: Decimal; var TotalsRoundingDifference: Decimal)
    var
        AmountInclVATCalculated: Decimal;
    begin
        UnitPrice := Abs(Round(POSEntrySalesLine."Amount Incl. VAT" / POSEntrySalesLine.Quantity, 0.01));
        AmountInclVATCalculated := POSEntrySalesLine.Quantity * UnitPrice;
        TotalsRoundingDifference := Abs(Round(POSEntrySalesLine."Amount Incl. VAT", 0.01)) - Abs(Round(AmountInclVATCalculated, 0.01));
        if TotalsRoundingDifference >= 0 then
            exit;

        UnitPrice := Abs(Round(POSEntrySalesLine."Amount Incl. VAT" / POSEntrySalesLine.Quantity, 0.01, '<'));
        AmountInclVATCalculated := POSEntrySalesLine.Quantity * UnitPrice;
        TotalsRoundingDifference := Abs(Round(POSEntrySalesLine."Amount Incl. VAT", 0.01)) - Abs(Round(AmountInclVATCalculated, 0.01));

        if TotalsRoundingDifference > 0 then
            exit;

        UnitPrice := UnitPrice - 0.01;
        AmountInclVATCalculated := POSEntrySalesLine.Quantity * UnitPrice;
        TotalsRoundingDifference := Abs(Round(POSEntrySalesLine."Amount Incl. VAT", 0.01)) - Abs(Round(AmountInclVATCalculated, 0.01));
    end;

    local procedure AddRoundingCorrectionToReceiptItemsJSONArrayForSaleAndRefund(var JsonTextReaderWriter: Codeunit "Json Text Reader/Writer"; BGSISVATPostSetupMap: Record "NPR BG SIS VAT Post. Setup Map"; TotalsRoundingDifference: Decimal)
    var
        RoundingCorrectionLbl: Label 'Rounding Correction';
    begin
        JsonTextReaderWriter.WriteStartObject('');
        JsonTextReaderWriter.WriteStringProperty('description', CopyStr(RoundingCorrectionLbl, 1, 64));
        JsonTextReaderWriter.WriteRawProperty('enumVatCategory', BGSISVATPostSetupMap."BG SIS VAT Category".AsInteger());
        JsonTextReaderWriter.WriteStringProperty('price', Format(TotalsRoundingDifference, 0, '<Sign><Precision,2:2><Integer><Decimals>'));
        JsonTextReaderWriter.WriteStringProperty('quantity', Format(Abs(Round(1, 0.01)), 0, '<Sign><Precision,2:2><Integer><Decimals>'));
        JsonTextReaderWriter.WriteEndObject();
    end;

    local procedure AddReceiptPaymentsJSONArrayForSaleAndRefund(var JsonTextReaderWriter: Codeunit "Json Text Reader/Writer"; POSEntryNo: Integer; Refund: Boolean)
    var
        BGSISPOSPaymMethMap: Record "NPR BG SIS POS Paym. Meth. Map";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        PaymentAmount: Decimal;
        ReceiptPayments: Dictionary of [Integer, Decimal];
        CashBGSISPaymentMethod: Enum "NPR BG SIS Payment Method";
        PaymentMedium: Integer;
    begin
        CashBGSISPaymentMethod := Enum::"NPR BG SIS Payment Method"::Cash;

        JsonTextReaderWriter.WriteStartArray('receiptPayments');

        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntryNo);
        POSEntryPaymentLine.SetFilter(Amount, '<>0');
        if POSEntryPaymentLine.FindSet() then
            repeat
                BGSISPOSPaymMethMap.Get(POSEntryPaymentLine."POS Payment Method Code");
                BGSISPOSPaymMethMap.CheckIsBGSISPaymentMethodPopulated();
                if ReceiptPayments.Get(BGSISPOSPaymMethMap."BG SIS Payment Method".AsInteger(), PaymentAmount) then
                    ReceiptPayments.Set(BGSISPOSPaymMethMap."BG SIS Payment Method".AsInteger(), PaymentAmount + Round(POSEntryPaymentLine.Amount, 0.01))
                else
                    ReceiptPayments.Add(BGSISPOSPaymMethMap."BG SIS Payment Method".AsInteger(), Round(POSEntryPaymentLine.Amount, 0.01));
            until POSEntryPaymentLine.Next() = 0
        else
            ReceiptPayments.Add(CashBGSISPaymentMethod.AsInteger(), Round(0, 0.01));

        foreach PaymentMedium in ReceiptPayments.Keys() do begin
            PaymentAmount := ReceiptPayments.Get(PaymentMedium);
            if (PaymentAmount <> 0) or ((PaymentAmount = 0) and (PaymentMedium = CashBGSISPaymentMethod.AsInteger())) then begin
                JsonTextReaderWriter.WriteStartObject('');
                if Refund then
                    JsonTextReaderWriter.WriteStringProperty('amount', Format(-(Round(PaymentAmount, 0.01)), 0, '<Sign><Precision,2:2><Integer><Decimals>'))
                else
                    JsonTextReaderWriter.WriteStringProperty('amount', Format(Round(PaymentAmount, 0.01), 0, '<Sign><Precision,2:2><Integer><Decimals>'));
                JsonTextReaderWriter.WriteRawProperty('medium', PaymentMedium);
                JsonTextReaderWriter.WriteEndObject();
            end;
        end;

        JsonTextReaderWriter.WriteEndArray();
    end;

    local procedure AddStornoInputJSONObjectForRefund(var JsonTextReaderWriter: Codeunit "Json Text Reader/Writer"; ExtendedReceipt: Boolean; POSEntryNo: Integer)
    var
        BGSISPOSAuditLogAuxToRefund: Record "NPR BG SIS POS Audit Log Aux.";
        BGSISReturnReasonMap: Record "NPR BG SIS Return Reason Map";
        OriginalPOSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntryNo);
        POSEntrySalesLine.FindFirst();

        OriginalPOSEntrySalesLine.GetBySystemId(POSEntrySalesLine."Orig.POS Entry S.Line SystemId");
        BGSISPOSAuditLogAuxToRefund.FindAuditLog(OriginalPOSEntrySalesLine."POS Entry No.");

        JsonTextReaderWriter.WriteStartObject('stornoInput');
        JsonTextReaderWriter.WriteStringProperty('documentDate', BGSISPOSAuditLogAuxToRefund."Receipt Timestamp");
        BGSISReturnReasonMap.Get(POSEntrySalesLine."Return Reason Code");
        BGSISReturnReasonMap.CheckIsBGSISReturnReasonPopulated();
        JsonTextReaderWriter.WriteRawProperty('enumStornoType', BGSISReturnReasonMap."BG SIS Return Reason".AsInteger());
        JsonTextReaderWriter.WriteStringProperty('fiscMemNumber', BGSISPOSAuditLogAuxToRefund."Fiscal Printer Memory No.");

        if ExtendedReceipt then begin
            JsonTextReaderWriter.WriteStringProperty('fiscDevNumber', BGSISPOSAuditLogAuxToRefund."Fiscal Printer Device No.");
            JsonTextReaderWriter.WriteStringProperty('invoiceNumber', BGSISPOSAuditLogAuxToRefund."Extended Receipt Counter");
        end;

        JsonTextReaderWriter.WriteStringProperty('receiptNumber', BGSISPOSAuditLogAuxToRefund."Grand Receipt No.".PadLeft(10, '0'));

        JsonTextReaderWriter.WriteEndObject();
    end;

    internal procedure CreateJSONBodyForPrintXReport() JsonBody: Text
    var
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
    begin
        InitJSONBody(JsonTextReaderWriter);
        JsonTextReaderWriter.WriteStringProperty('method', 'printXReport');
        JsonTextReaderWriter.WriteEndObject();
        JsonBody := JsonTextReaderWriter.GetJSonAsText();
    end;

    internal procedure CreateJSONBodyForPrintZReport() JsonBody: Text
    var
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
    begin
        InitJSONBody(JsonTextReaderWriter);
        JsonTextReaderWriter.WriteStringProperty('method', 'printZReport');
        JsonTextReaderWriter.WriteEndObject();
        JsonBody := JsonTextReaderWriter.GetJSonAsText();
    end;

    internal procedure CreateJSONBodyForPrintFromFiscalMemory(TypeOfReport: Option FD2D,SD2D,FZ2Z,SZ2Z; FromAsText: Text; ToAsText: Text) JsonBody: Text
    var
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
        DataPlaceholderLbl: Label '%1, %2', Comment = '%1 - placeholder 1, %2 - placeholder 2', Locked = true;
    begin
        InitJSONBody(JsonTextReaderWriter);
        JsonTextReaderWriter.WriteStringProperty('method', 'printMFReport');
        JsonTextReaderWriter.WriteStringProperty('type', Format(TypeOfReport));
        JsonTextReaderWriter.WriteStringProperty('data', StrSubstNo(DataPlaceholderLbl, FromAsText, ToAsText));
        JsonTextReaderWriter.WriteEndObject();
        JsonBody := JsonTextReaderWriter.GetJSonAsText();
    end;

    internal procedure CreateJSONBodyForPrintDuplicate() JsonBody: Text
    var
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
    begin
        InitJSONBody(JsonTextReaderWriter);
        JsonTextReaderWriter.WriteStringProperty('method', 'printDuplicate');
        JsonTextReaderWriter.WriteEndObject();
        JsonBody := JsonTextReaderWriter.GetJSonAsText();
    end;

    internal procedure CreateJSONBodyForExportDataFromElectronicJournal(TypeOfExport: Option D2D,T2T,EOD2EOD; Param1: Text; Param2: Text) JsonBody: Text
    var
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
    begin
        InitJSONBody(JsonTextReaderWriter);
        JsonTextReaderWriter.WriteStringProperty('method', 'ejExportData');
        JsonTextReaderWriter.WriteStringProperty('type', Format(TypeOfExport));
        JsonTextReaderWriter.WriteStringProperty('param1', Param1);
        JsonTextReaderWriter.WriteStringProperty('param2', Param2);
        JsonTextReaderWriter.WriteEndObject();
        JsonBody := JsonTextReaderWriter.GetJSonAsText();
    end;

    internal procedure CreateJSONBodyForReprintFromElectronicJournal(TypeOfReprint: Option EOD,T2TEOD,T2TDATE; Param1: Text; Param2: Text; Param3: Text; Param4: Text) JsonBody: Text
    var
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
    begin
        InitJSONBody(JsonTextReaderWriter);
        JsonTextReaderWriter.WriteStringProperty('method', 'ejReprint');
        JsonTextReaderWriter.WriteStringProperty('type', Format(TypeOfReprint));

        case TypeOfReprint of
            TypeOfReprint::EOD:
                JsonTextReaderWriter.WriteStringProperty('param1', Param1);
            TypeOfReprint::T2TDATE:
                begin
                    JsonTextReaderWriter.WriteStringProperty('param1', Param1);
                    JsonTextReaderWriter.WriteStringProperty('param2', Param2);
                end;
            TypeOfReprint::T2TEOD:
                begin
                    JsonTextReaderWriter.WriteStringProperty('param1', Param1);
                    JsonTextReaderWriter.WriteStringProperty('param2', Param2);
                    JsonTextReaderWriter.WriteStringProperty('param3', Param3);
                    JsonTextReaderWriter.WriteStringProperty('param4', Param4);
                end;
        end;

        JsonTextReaderWriter.WriteEndObject();
        JsonBody := JsonTextReaderWriter.GetJSonAsText();
    end;

    internal procedure CreateJSONBodyForCashHandling(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint") JsonBody: Text
    var
        POSEntry: Record "NPR POS Entry";
        POSPaymentBinCheckp: Record "NPR POS Payment Bin Checkp.";
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
        OperatorNumber: Integer;
    begin
        POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");

        InitJSONBody(JsonTextReaderWriter);
        JsonTextReaderWriter.WriteStringProperty('method', 'cashHandling');

        JsonTextReaderWriter.WriteStartObject('params');

        JsonTextReaderWriter.WriteStartObject('beginFiscalReceiptInput');
        Evaluate(OperatorNumber, POSEntry."Salesperson Code");
        JsonTextReaderWriter.WriteStringProperty('terminalNumber', POSEntry."POS Unit No.");
        JsonTextReaderWriter.WriteRawProperty('operatorNumber', OperatorNumber);
        JsonTextReaderWriter.WriteEndObject(); // beginFiscalReceiptInput

        POSPaymentBinCheckp.SetCurrentKey("Workshift Checkpoint Entry No.");
        POSPaymentBinCheckp.SetRange("Workshift Checkpoint Entry No.", POSWorkshiftCheckpoint."Entry No.");
        POSPaymentBinCheckp.CalcSums("Move to Bin Amount");
        JsonTextReaderWriter.WriteStringProperty('amount', Format(-Round(POSPaymentBinCheckp."Move to Bin Amount", 0.01), 0, '<Sign><Precision,2:2><Integer><Decimals>'));

        JsonTextReaderWriter.WriteEndObject(); // params
        JsonTextReaderWriter.WriteEndObject();
        JsonBody := JsonTextReaderWriter.GetJSonAsText();
    end;

    internal procedure CreateJSONBodyForCashHandling(POSUnitNo: Code[10]; SalespersonCode: Code[20]; AmountToHandle: Decimal) JsonBody: Text
    var
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
        OperatorNumber: Integer;
    begin
        InitJSONBody(JsonTextReaderWriter);
        JsonTextReaderWriter.WriteStringProperty('method', 'cashHandling');

        JsonTextReaderWriter.WriteStartObject('params');

        JsonTextReaderWriter.WriteStartObject('beginFiscalReceiptInput');
        Evaluate(OperatorNumber, SalespersonCode);
        JsonTextReaderWriter.WriteStringProperty('terminalNumber', POSUnitNo);
        JsonTextReaderWriter.WriteRawProperty('operatorNumber', OperatorNumber);
        JsonTextReaderWriter.WriteEndObject(); // beginFiscalReceiptInput

        JsonTextReaderWriter.WriteStringProperty('amount', Format(Round(AmountToHandle, 0.01), 0, '<Sign><Precision,2:2><Integer><Decimals>'));

        JsonTextReaderWriter.WriteEndObject(); // params
        JsonTextReaderWriter.WriteEndObject();
        JsonBody := JsonTextReaderWriter.GetJSonAsText();
    end;

    internal procedure CreateJSONBodyForGetCashBalance() JsonBody: Text
    var
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
    begin
        InitJSONBody(JsonTextReaderWriter);
        JsonTextReaderWriter.WriteStringProperty('method', 'getCashBalance');
        JsonTextReaderWriter.WriteEndObject();
        JsonBody := JsonTextReaderWriter.GetJSonAsText();
    end;

    internal procedure CreateJSONBodyForGetCashierData(SalespersonCode: Code[20]) JsonBody: Text
    var
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
        SalespersonCodeAsInteger: Integer;
    begin
        Evaluate(SalespersonCodeAsInteger, SalespersonCode);
        InitJSONBody(JsonTextReaderWriter);
        JsonTextReaderWriter.WriteStringProperty('method', 'getCashierData');
        JsonTextReaderWriter.WriteRawProperty('operatorNumber', SalespersonCodeAsInteger);
        JsonTextReaderWriter.WriteEndObject();
        JsonBody := JsonTextReaderWriter.GetJSonAsText();
    end;

    internal procedure CreateJSONBodyForSetCashier(Salesperson: Record "Salesperson/Purchaser") JsonBody: Text
    var
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
        SalespersonCodeAsInteger: Integer;
    begin
        Evaluate(SalespersonCodeAsInteger, Salesperson.Code);
        InitJSONBody(JsonTextReaderWriter);
        JsonTextReaderWriter.WriteStringProperty('method', 'setCashier');
        JsonTextReaderWriter.WriteRawProperty('operatorNumber', SalespersonCodeAsInteger);
        JsonTextReaderWriter.WriteStringProperty('operatorName', Salesperson.Name);
        JsonTextReaderWriter.WriteEndObject();
        JsonBody := JsonTextReaderWriter.GetJSonAsText();
    end;

    internal procedure CreateJSONBodyForDeleteCashier(Salesperson: Record "Salesperson/Purchaser") JsonBody: Text
    var
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
        SalespersonCodeAsInteger: Integer;
    begin
        Evaluate(SalespersonCodeAsInteger, Salesperson.Code);
        InitJSONBody(JsonTextReaderWriter);
        JsonTextReaderWriter.WriteStringProperty('method', 'deleteCashier');
        JsonTextReaderWriter.WriteRawProperty('operatorNumber', SalespersonCodeAsInteger);
        JsonTextReaderWriter.WriteEndObject();
        JsonBody := JsonTextReaderWriter.GetJSonAsText();
    end;

    // TO-DO this will be finished in one of the future tasks
    // internal procedure CreateJSONBodyForGetReceipt(BGSISPOSAuditLogAux: Record "NPR BG POS SIS Audit Log Aux.") JsonBody: Text
    // var
    //     JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
    // begin
    //     InitJSONBody(JsonTextReaderWriter);
    //     JsonTextReaderWriter.WriteStringProperty('method', 'getReceipt');
    //     JsonTextReaderWriter.WriteStringProperty('bonno', BGSISPOSAuditLogAux."Grand Receipt No.".PadLeft(10, '0'));
    //     JsonTextReaderWriter.WriteEndObject();
    //     JsonBody := JsonTextReaderWriter.GetJSonAsText();
    // end;
    #endregion

    #region JSON Fiscal Parsers
#pragma warning disable AA0139
    internal procedure FillFiscalPrinterInfo(var BGSISPOSUnitMapping: Record "NPR BG SIS POS Unit Mapping"; var TempJsonBuffer: Record "JSON Buffer" temporary)
    begin
        BGSISPOSUnitMapping."Fiscal Printer Device No." := GetPropertyValueWithCheck(TempJsonBuffer, 'FDNumber');
        BGSISPOSUnitMapping."Fiscal Printer Memory No." := GetPropertyValueWithCheck(TempJsonBuffer, 'FMNumber');

        BGSISPOSUnitMapping."Fiscal Printer Info Refreshed" := CurrentDateTime();
        BGSISPOSUnitMapping.Modify();
    end;

    internal procedure UpdateBGSISAuditLogForSaleAndRefund(var BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux."; BGSISPOSUnitMapping: Record "NPR BG SIS POS Unit Mapping"; var TempJsonBuffer: Record "JSON Buffer" temporary; RequestText: Text; ExtendedReceipt: Boolean)
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        if ExtendedReceipt then
            RemoveCustomerIDWhenNotBGCompany(RequestText);

        BGSISPOSAuditLogAux.SetRequestText(RequestText);

        BGSISPOSAuditLogAux."Grand Receipt No." := GetPropertyValueWithCheck(TempJsonBuffer, 'grandReceiptNum');
        BGSISPOSAuditLogAux."Receipt Timestamp" := GetPropertyValueWithCheck(TempJsonBuffer, 'receiptTimestamp');
        BGSISPOSAuditLogAux."Extended Receipt" := ExtendedReceipt;

        if ExtendedReceipt then
            if BGSISPOSAuditLogAux."Transaction Type" = BGSISPOSAuditLogAux."Transaction Type"::Refund then
                BGSISPOSAuditLogAux."Extended Receipt Counter" := NoSeriesManagement.GetNextNo(BGSISPOSUnitMapping."Extended Receipt Cr. Memo No.", WorkDate(), true)
            else
                BGSISPOSAuditLogAux."Extended Receipt Counter" := NoSeriesManagement.GetNextNo(BGSISPOSUnitMapping."Extended Receipt Invoice No.", WorkDate(), true);

        BGSISPOSAuditLogAux."Fiscal Printer Device No." := BGSISPOSUnitMapping."Fiscal Printer Device No.";
        BGSISPOSAuditLogAux."Fiscal Printer Memory No." := BGSISPOSUnitMapping."Fiscal Printer Memory No.";
        if ExtendedReceipt then
            PopulateExtendedReceiptInfo(BGSISPOSAuditLogAux, RequestText);
        BGSISPOSAuditLogAux.Modify();
    end;

    internal procedure UpdateBGSISAuditLogRequestContent(var BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux."; RequestText: Text; ExtendedReceipt: Boolean)
    begin
        if ExtendedReceipt then
            RemoveCustomerIDWhenNotBGCompany(RequestText);

        BGSISPOSAuditLogAux.SetRequestText(RequestText);
        BGSISPOSAuditLogAux.Modify();
    end;

    local procedure RemoveCustomerIDWhenNotBGCompany(var RequestText: Text)
    var
        InvoiceDataJsonObject, MainJsonObject : JsonObject;
        JsonToken: JsonToken;
    begin
        MainJsonObject.ReadFrom(RequestText);
        MainJsonObject.SelectToken('$.params.invoiceData', JsonToken);
        InvoiceDataJsonObject := JsonToken.AsObject();

        InvoiceDataJsonObject.Get('identNumberType', JsonToken);
        if JsonToken.AsValue().AsInteger() = 0 then
            exit;

        InvoiceDataJsonObject.Replace('identNumber', '**********');

        MainJsonObject.WriteTo(RequestText);
    end;

    local procedure PopulateExtendedReceiptInfo(var BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux."; RequestText: Text)
    var
        InvoiceDataJsonObject, MainJsonObject : JsonObject;
        JsonToken: JsonToken;
    begin
        MainJsonObject.ReadFrom(RequestText);
        MainJsonObject.SelectToken('$.params.invoiceData', JsonToken);
        InvoiceDataJsonObject := JsonToken.AsObject();

        InvoiceDataJsonObject.Get('identNumberType', JsonToken);
        if JsonToken.AsValue().AsInteger() <> 0 then
            exit;

        InvoiceDataJsonObject.Get('identNumber', JsonToken);
        BGSISPOSAuditLogAux."Customer Identification No." := JsonToken.AsValue().AsText();

        InvoiceDataJsonObject.Get('vatIdentNumber', JsonToken);
        BGSISPOSAuditLogAux."Customer VAT Registration No." := JsonToken.AsValue().AsText();

        InvoiceDataJsonObject.Get('recipientName', JsonToken);
        BGSISPOSAuditLogAux."Customer Name" := JsonToken.AsValue().AsText();

        InvoiceDataJsonObject.Get('recipientAddress', JsonToken);
        BGSISPOSAuditLogAux."Customer Address" := JsonToken.AsValue().AsText();

        InvoiceDataJsonObject.Get('city', JsonToken);
        BGSISPOSAuditLogAux."Customer City" := JsonToken.AsValue().AsText();
    end;

    local procedure ThrowErrorIfCashierIsNotSet(ThisSalespersonCode: Code[20]; var TempJsonBuffer: Record "JSON Buffer" temporary)
    var
        CashierNotSetErr: Label 'Cashier %1 is not set on related fiscal printer.', Comment = '%1 - Cashier Code value';
        SalespersonCode: Text;
    begin
        SalespersonCode := GetPropertyValueWithCheck(TempJsonBuffer, 'operatorNumber');
        if SalespersonCode = '' then
            Error(CashierNotSetErr, ThisSalespersonCode);
    end;

    // TO-DO this will be finished in one of the future tasks
    // internal procedure UpdateBGSISAuditLogReceipt(var BGSISPOSAuditLogAux: Record "NPR BG POS SIS Audit Log Aux."; var TempJsonBuffer: Record "JSON Buffer" temporary)
    // var
    //     ReceiptData: Text;
    // begin
    //     ReceiptData := GetPropertyValueWithCheck(TempJsonBuffer, 'data');
    //     BGSISPOSAuditLogAux.SetReceiptData(ReceiptData);
    //     BGSISPOSAuditLogAux.Modify();
    // end;
#pragma warning restore

    local procedure GetPropertyValueWithCheck(var TempJsonBuffer: Record "JSON Buffer" temporary; PropertyName: Text): Text
    var
        PropertyNotFoundErr: Label 'Property with name %1 is not found.', Comment = '%1 - Property Name value';
        PropertyValue: Text;
    begin
        if not TempJsonBuffer.GetPropertyValue(PropertyValue, PropertyName) then
            Error(PropertyNotFoundErr, PropertyName);

        exit(PropertyValue);
    end;
    #endregion

    #region Http Requests - Misc
    internal procedure IsResponseSuccessfulAndThrowErrorIfNot(var TempJsonBuffer: Record "JSON Buffer" temporary; ResponseText: Text) ResponseSuccessful: Boolean
    begin
        ResponseSuccessful := IsRepsonseSuccessful(TempJsonBuffer, ResponseText);

        if not ResponseSuccessful and GuiAllowed then
            ThrowErrorForNotSuccessfulResponse(TempJsonBuffer);
    end;

    internal procedure ThrowErrorIfResponseNotSuccessful(ResponseText: Text)
    var
        TempJsonBuffer: Record "JSON Buffer" temporary;
    begin
        if not IsRepsonseSuccessful(TempJsonBuffer, ResponseText) and GuiAllowed then
            ThrowErrorForNotSuccessfulResponse(TempJsonBuffer);
    end;

    local procedure IsRepsonseSuccessful(var TempJsonBuffer: Record "JSON Buffer" temporary; ResponseText: Text) ResponseSuccessful: Boolean
    var
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
        PropertyValue: Text;
    begin
        ResponseSuccessful := true;
        JsonTextReaderWriter.ReadJSonToJSonBuffer(ResponseText, TempJsonBuffer);
        if TempJsonBuffer.GetPropertyValue(PropertyValue, 'result') then
            ResponseSuccessful := PropertyValue.ToUpper() = 'OK';
        if TempJsonBuffer.GetPropertyValue(PropertyValue, 'mfc_error') then
            ResponseSuccessful := PropertyValue.ToUpper() = '0';
    end;

    local procedure ThrowErrorForNotSuccessfulResponse(var TempJsonBuffer: Record "JSON Buffer" temporary)
    var
        ErrorText: Text;
        PropertyValue: Text;
    begin
        ErrorText := PropertyValue;
        if TempJsonBuffer.GetPropertyValue(PropertyValue, 'mfc_error_message') then
            ErrorText += ': ' + PropertyValue;

        Error(CopyStr(ErrorText, 1, 1000));
    end;
    #endregion

    #region Procedures/Helper Functions
    local procedure IsDigit(CharToCheck: Code[1]) Digit: Boolean
    begin
        Digit := CharToCheck in ['0' .. '9'];
    end;

    local procedure IsAlpha(CharToCheck: Code[1]) Alpha: Boolean
    begin
        Alpha := CharToCheck in ['A' .. 'Z'];
    end;

    local procedure IsAlphanumeric(CharToCheck: Code[1]) Alphanumeric: Boolean
    begin
        Alphanumeric := IsDigit(CharToCheck) or IsAlpha(CharToCheck);
    end;
    #endregion

    #region event publishers
    [IntegrationEvent(false, false)]
    local procedure OnGetCustomerIdentificationNo(Customer: Record Customer; var IdentificationNo: Text; var Handled: Boolean)
    begin
    end;
    #endregion

    #region Telemetry
    internal procedure ErrorLogReceiptFiscalisated(Error: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
    begin
        CustomDimensions.Add('NPR_Error', Error);
        Session.LogMessage(FinishEventIdTok, BGFiscalReceiptNotFiscalisedLbl, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;
    #endregion
}