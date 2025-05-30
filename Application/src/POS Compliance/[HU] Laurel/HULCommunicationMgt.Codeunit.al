codeunit 6248367 "NPR HU L Communication Mgt."
{
    Access = Internal;

    #region HU L Communication Mgt. - Request Creation
    internal procedure OpenFiscalDay(POSSale: Record "NPR POS Sale"): Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('command', 'openDay');

        AddPaymentBinCheckpointInformation(JsonTextWriter, POSSale);

        JsonTextWriter.WriteEndObject();

        exit(JsonTextWriter.GetJSonAsText());
    end;

    internal procedure CloseFiscalDay(): Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('command', 'closeDay');
        JsonTextWriter.WriteEndObject();
        exit(JsonTextWriter.GetJSonAsText());
    end;

    internal procedure PrintCashierFCUReport(): Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('command', 'autoCashReport');
        JsonTextWriter.WriteEndObject();
        exit(JsonTextWriter.GetJSonAsText());
    end;

    internal procedure GetDailyTotal(): Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('command', 'getDailyTotal');
        JsonTextWriter.WriteEndObject();
        exit(JsonTextWriter.GetJSonAsText());
    end;

    internal procedure ResetPrinter(): Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('command', 'resetPrinter');
        JsonTextWriter.WriteStartObject('data');
        JsonTextWriter.WriteStringProperty('iLevel', '1');
        JsonTextWriter.WriteEndObject(); // data
        JsonTextWriter.WriteEndObject();
        exit(JsonTextWriter.GetJSonAsText());
    end;

    internal procedure SetEuroRate(): Text
    var
        HULPOSPaymMethMapp: Record "NPR HU L POS Paym. Meth. Mapp.";
        POSPaymentMethod: Record "NPR POS Payment Method";
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
        InputDialog: Page "NPR Input Dialog";
        EuroRate: Decimal;
        PrepDate: Date;
        EuroRateLbl: Label 'Euro Rate';
        PrepDateLbl: Label 'Preparation Date';
    begin
        InputDialog.SetInput(1, EuroRate, EuroRateLbl);
        InputDialog.SetInput(2, PrepDate, PrepDateLbl);
        if InputDialog.RunModal() <> Action::OK then
            Error('');
        InputDialog.InputDecimal(1, EuroRate);
        InputDialog.InputDate(2, PrepDate);

        HULPOSPaymMethMapp.SetRange("Payment Currency Type", HULPOSPaymMethMapp."Payment Currency Type"::EUR);
        if HULPOSPaymMethMapp.FindSet() then
            repeat
                POSPaymentMethod.Get(HULPOSPaymMethMapp."POS Payment Method Code");
                POSPaymentMethod.Validate("Fixed Rate", EuroRate);
                POSPaymentMethod.Modify();
            until HULPOSPaymMethMapp.Next() = 0;

        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('command', 'setEuroParams');
        JsonTextWriter.WriteStartObject('data');
        JsonTextWriter.WriteStringProperty('dPrepRate', EuroRate);
        JsonTextWriter.WriteStringProperty('sPrepDate', Format(PrepDate, 0, '<Year4>.<Month,2>.<Day,2>'));
        JsonTextWriter.WriteEndObject(); // data
        JsonTextWriter.WriteEndObject();
        exit(JsonTextWriter.GetJSonAsText());
    end;

    internal procedure PrintReceiptCopy(): Text
    var
        HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.";
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
        HULPOSAuditLogAuxPage: Page "NPR HU L POS Audit Log Aux.";
    begin
        HULPOSAuditLogAux.SetFilter("FCU Document No.", '<>%1', 0);
        HULPOSAuditLogAux.SetFilter("Transaction Type", '%1|%2', HULPOSAuditLogAux."Transaction Type"::Return, HULPOSAuditLogAux."Transaction Type"::"Simple Invoice");
        HULPOSAuditLogAuxPage.LookupMode(true);
        HULPOSAuditLogAuxPage.SetTableView(HULPOSAuditLogAux);
        if (HULPOSAuditLogAuxPage.RunModal() <> Action::LookupOK) then
            Error('');
        HULPOSAuditLogAuxPage.GetRecord(HULPOSAuditLogAux);

        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('command', 'printVoucherCopy');
        JsonTextWriter.WriteStartObject('data');

        case HULPOSAuditLogAux."Transaction Type" of
            HULPOSAuditLogAux."Transaction Type"::Return:
                JsonTextWriter.WriteStringProperty('iType', '2');
            HULPOSAuditLogAux."Transaction Type"::"Simple Invoice":
                JsonTextWriter.WriteStringProperty('iType', '0');
            else
                Error('');
        end;

        JsonTextWriter.WriteStringProperty('iClosure', HULPOSAuditLogAux."FCU Closure No.");
        JsonTextWriter.WriteStringProperty('iNumber', HULPOSAuditLogAux."FCU Document No.");
        JsonTextWriter.WriteEndObject(); // data
        JsonTextWriter.WriteEndObject();

        exit(JsonTextWriter.GetJSonAsText());
    end;

    internal procedure VoidCurrentSale(var VoidAuditEntryNo: Integer; POSSale: Record "NPR POS Sale") Request: Text
    var
        HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.";
        ReturnPOSEntry: Record "NPR POS Entry";
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
        Change: Decimal;
        Rounding: Decimal;
        PaymentCnt: Integer;
    begin
        SelectReturnHULPOSAuditLogAndInsertNewAuditLog(ReturnPOSEntry, HULPOSAuditLogAux);
        VoidAuditEntryNo := HULPOSAuditLogAux."Audit Entry No.";

        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('command', 'void');
        JsonTextWriter.WriteStartObject('data');

        AddOriginalInvoiceData(HULPOSAuditLogAux, JsonTextWriter);

        AddCustomerData(HULPOSAuditLogAux, JsonTextWriter, ReturnPOSEntry);

        AddPOSStoreInfoHeader(JsonTextWriter, POSSale."Register No.", POSSale."Sales Ticket No.");

        AddPOSEntrySalesLines(JsonTextWriter, ReturnPOSEntry, true);

        Change := CalculateChangeAmount(ReturnPOSEntry);
        Rounding := RoundRoundingAmount(CalculateRoundingAmount(ReturnPOSEntry));
        HULPOSAuditLogAux."Change Amount" := Change;
        HULPOSAuditLogAux."Rounding Amount" := Rounding;
        HULPOSAuditLogAux.Modify();

        PaymentCnt := 1;
        if Change <> 0 then
            PaymentCnt += 1;
        if Rounding <> 0 then
            PaymentCnt += 1;

        JsonTextWriter.WriteStringProperty('iPaymentCnt', PaymentCnt);
        JsonTextWriter.WriteStartArray('payments');
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStartObject('stPayment');
        JsonTextWriter.WriteStringProperty('sName', Format(Enum::"NPR HU L Payment Fiscal Type"::CASH));
        JsonTextWriter.WriteStringProperty('fAmount', FormatDecimalValue(Round(ReturnPOSEntry."Amount Incl. Tax", 5, '=')));
        JsonTextWriter.WriteStringProperty('iFiscalType', Enum::"NPR HU L Payment Fiscal Type"::CASH.AsInteger());
        JsonTextWriter.WriteEndObject(); // stPayment
        JsonTextWriter.WriteEndObject();

        if Change <> 0 then begin
            JsonTextWriter.WriteStartObject('');
            JsonTextWriter.WriteStartObject('stPayment');
            JsonTextWriter.WriteStringProperty('sName', Format(Enum::"NPR HU L Payment Fiscal Type"::CHANGE));
            JsonTextWriter.WriteStringProperty('fAmount', FormatDecimalValue(Change));
            JsonTextWriter.WriteStringProperty('iFiscalType', Enum::"NPR HU L Payment Fiscal Type"::CHANGE.AsInteger());
            JsonTextWriter.WriteEndObject(); // stPayment
            JsonTextWriter.WriteEndObject();
        end;
        if Rounding <> 0 then begin
            JsonTextWriter.WriteStartObject('');
            JsonTextWriter.WriteStartObject('stPayment');
            JsonTextWriter.WriteStringProperty('sName', Format(Enum::"NPR HU L Payment Fiscal Type"::ROUNDING));
            JsonTextWriter.WriteStringProperty('fAmount', FormatDecimalValue(-1 * Rounding));
            JsonTextWriter.WriteStringProperty('iFiscalType', Enum::"NPR HU L Payment Fiscal Type"::ROUNDING.AsInteger());
            JsonTextWriter.WriteEndObject(); // stPayment
            JsonTextWriter.WriteEndObject();
        end;

        JsonTextWriter.WriteEndArray(); // payments

        JsonTextWriter.WriteEndObject(); // data
        JsonTextWriter.WriteEndObject();

        Request := JsonTextWriter.GetJSonAsText();
        HULAuditMgt.InsertHULPOSAuditLogAuxInfoRequestData(HULPOSAuditLogAux, Request);
    end;

    local procedure AddOriginalInvoiceData(var HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux."; var JsonTextWriter: Codeunit "Json Text Reader/Writer")
    begin
        JsonTextWriter.WriteStringProperty('sOrigDate', Format(HULPOSAuditLogAux."Original Date", 0, '<Year4>.<Month,2>.<Day,2>'));
        JsonTextWriter.WriteStringProperty('sOrigType', HULPOSAuditLogAux."Original Type");
        JsonTextWriter.WriteStringProperty('sOrigBBOXID', HULPOSAuditLogAux."Original BBOX ID");
        JsonTextWriter.WriteStringProperty('iOrigClosure', HULPOSAuditLogAux."Original Closure No.");
        JsonTextWriter.WriteStringProperty('iOrigNr', HULPOSAuditLogAux."Original Document No.");
        JsonTextWriter.WriteStringProperty('sReasonCode', Enum::"NPR HU L Return Reason Code".Names().Get(Enum::"NPR HU L Return Reason Code".Ordinals().IndexOf(HULPOSAuditLogAux."Return Reason".AsInteger())));
    end;

    local procedure AddCustomerData(var HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux."; var JsonTextWriter: Codeunit "Json Text Reader/Writer"; ReturnPOSEntry: Record "NPR POS Entry")
    var
        Customer: Record Customer;
        InputDialog: Page "NPR Input Dialog";
        CustomerName: Text;
        CustomerAddress: Text;
        CustomerCity: Text;
        CustomerPostCode: Text;
        CustomerVATNumber: Text;
        CustomerNameLbl: Label 'Customer Name';
        CustomerAddressLbl: Label 'Customer Address';
        CustomerCityLbl: Label 'Customer City';
        CustomerPostCodeLbl: Label 'Customer Post Code';
        CustomerVATRegistrationNoLbl: Label 'Customer VAT Number';
        InsufficientDataErr: Label 'Insufficient data entered, please input all neccessary data.';
        CustomerInfoMandatoryErr: Label 'You must input customer information for this sale.';
    begin
        if ReturnPOSEntry."Customer No." <> '' then begin
            Customer.Get(ReturnPOSEntry."Customer No.");
            CustomerName := Customer.Name;
            CustomerAddress := Customer.Address;
            CustomerCity := Customer."City";
            CustomerPostCode := Customer."Post Code";
            CustomerVATNumber := Customer."VAT Registration No.";
        end;
        InputDialog.SetInput(1, CustomerName, CustomerNameLbl);
        InputDialog.SetInput(2, CustomerAddress, CustomerAddressLbl);
        InputDialog.SetInput(3, CustomerCity, CustomerCityLbl);
        InputDialog.SetInput(4, CustomerPostCode, CustomerPostCodeLbl);
        InputDialog.SetInput(5, CustomerVATNumber, CustomerVATRegistrationNoLbl);

        Commit();
        if InputDialog.RunModal() <> Action::OK then
            Error(CustomerInfoMandatoryErr);

        InputDialog.InputText(1, CustomerName);
        InputDialog.InputText(2, CustomerAddress);
        InputDialog.InputText(3, CustomerCity);
        InputDialog.InputText(4, CustomerPostCode);
        InputDialog.InputText(5, CustomerVATNumber);

        if (CustomerName = '') or (CustomerAddress = '') or (CustomerCity = '') or (CustomerPostCode = '') then
            Error(InsufficientDataErr);

        JsonTextWriter.WriteStartObject('customerData');
        JsonTextWriter.WriteStringProperty('sCustomerName', CustomerName);
        JsonTextWriter.WriteStringProperty('sCustZip', CustomerPostCode);
        JsonTextWriter.WriteStringProperty('sCustCity', CustomerCity);
        JsonTextWriter.WriteStringProperty('sCustPublicPlace', CustomerAddress);

        if CustomerVATNumber <> '' then begin
            JsonTextWriter.WriteStringProperty('iPrivatePerson', 0);
            JsonTextWriter.WriteStringProperty('sCustTaxId', CustomerVATNumber);
        end else
            JsonTextWriter.WriteStringProperty('iPrivatePerson', 1);
        JsonTextWriter.WriteEndObject(); // customerData

        HULPOSAuditLogAux."Customer Name" := CopyStr(CustomerName, 1, MaxStrLen(HULPOSAuditLogAux."Customer Name"));
        HULPOSAuditLogAux."Customer Post Code" := CopyStr(CustomerPostCode, 1, MaxStrLen(HULPOSAuditLogAux."Customer Post Code"));
        HULPOSAuditLogAux."Customer City" := CopyStr(CustomerCity, 1, MaxStrLen(HULPOSAuditLogAux."Customer City"));
        HULPOSAuditLogAux."Customer Address" := CopyStr(CustomerAddress, 1, MaxStrLen(HULPOSAuditLogAux."Customer Address"));
        HULPOSAuditLogAux."Customer VAT Number" := CopyStr(CustomerVATNumber, 1, MaxStrLen(HULPOSAuditLogAux."Customer VAT Number"));
        HULPOSAuditLogAux.Modify();
    end;

    internal procedure RefiscalizeAuditLog(var AuditLogEntryNo: Integer): Text
    var
        HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.";
        POSEntry: Record "NPR POS Entry";
    begin
        Commit();
        HULPOSAuditLogAux.SetFilter("POS Entry No.", '<>%1', 0);
        HULPOSAuditLogAux.SetRange("FCU Document No.", 0);
        if Page.RunModal(0, HULPOSAuditLogAux) <> Action::LookupOK then
            Error('');
        AuditLogEntryNo := HULPOSAuditLogAux."Audit Entry No.";
        POSEntry.Get(HULPOSAuditLogAux."POS Entry No.");

        case HULPOSAuditLogAux."Transaction Type" of
            HULPOSAuditLogAux."Transaction Type"::"Standard Receipt":
                exit(CreatePrintReceiptRequest(POSEntry, HULPOSAuditLogAux));
            HULPOSAuditLogAux."Transaction Type"::"Simple Invoice":
                exit(CreateSimplifiedInvoiceRequest(POSEntry, HULPOSAuditLogAux));
            HULPOSAuditLogAux."Transaction Type"::Return:
                exit(CreateReturnSaleRequest(POSEntry, HULPOSAuditLogAux));
            HULPOSAuditLogAux."Transaction Type"::Void:
                exit(CreateVoidSaleRequest(POSEntry, HULPOSAuditLogAux));
        end;
    end;

    internal procedure MoneyTransaction(HULCashMgtReason: Record "NPR HU L Cash Mgt. Reason"; HULPOSPaymMethMapp: Record "NPR HU L POS Paym. Meth. Mapp."; Method: Option moneyIn,moneyOut; Amount: Decimal; RoundingAmount: Decimal): Text
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');

        if Method = Method::moneyOut then
            JsonTextWriter.WriteStringProperty('command', 'moneyOut')
        else
            JsonTextWriter.WriteStringProperty('command', 'moneyIn');
        JsonTextWriter.WriteStartObject('data');
        JsonTextWriter.WriteStringProperty('iReasonCode', HULCashMgtReason."Cash Mgt Reason".AsInteger());
        JsonTextWriter.WriteStringProperty('sReasonText', Format(HULCashMgtReason."Cash Mgt Reason"));

        if RoundingAmount <> 0 then
            JsonTextWriter.WriteStringProperty('iPaymentCnt', 2)
        else
            JsonTextWriter.WriteStringProperty('iPaymentCnt', 1);

        JsonTextWriter.WriteStartArray('payments');

        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStartObject('stPayment');
        POSPaymentMethod.Get(HULPOSPaymMethMapp."POS Payment Method Code");
        JsonTextWriter.WriteStringProperty('sName', POSPaymentMethod.Description);
        JsonTextWriter.WriteStringProperty('fAmount', FormatDecimalValue(Amount));
        JsonTextWriter.WriteStringProperty('iFiscalType', HULPOSPaymMethMapp."Payment Fiscal Type".AsInteger());
        if HULPOSPaymMethMapp."Payment Fiscal Type" = HULPOSPaymMethMapp."Payment Fiscal Type"::OTHER then
            JsonTextWriter.WriteStringProperty('iFiscalSubType', HULPOSPaymMethMapp."Payment Fiscal Subtype".AsInteger());
        if HULPOSPaymMethMapp."Payment Currency Type" <> HULPOSPaymMethMapp."Payment Currency Type"::"Ft." then
            JsonTextWriter.WriteStringProperty('iType', HULPOSPaymMethMapp."Payment Currency Type".AsInteger());
        if HULPOSPaymMethMapp."Payment Fiscal Type" = HULPOSPaymMethMapp."Payment Fiscal Type"::FOREIGN then
            AddForeignCurrencyExchRate(JsonTextWriter, POSPaymentMethod."Currency Code");
        if HULPOSPaymMethMapp."Payment Currency Type" = HULPOSPaymMethMapp."Payment Currency Type"::Foreign then
            AddForeignCurrencyInformation(JsonTextWriter, POSPaymentMethod."Currency Code");
        JsonTextWriter.WriteEndObject(); // stPayment
        JsonTextWriter.WriteEndObject(); // data

        if RoundingAmount <> 0 then begin
            JsonTextWriter.WriteStartObject('');
            JsonTextWriter.WriteStartObject('stPayment');
            JsonTextWriter.WriteStringProperty('sName', 'Rounding');
            JsonTextWriter.WriteStringProperty('fAmount', RoundingAmount);
            JsonTextWriter.WriteStringProperty('iFiscalType', Enum::"NPR HU L Payment Fiscal Type"::ROUNDING.AsInteger());
            JsonTextWriter.WriteEndObject(); // stPayment
            JsonTextWriter.WriteEndObject();
        end;

        JsonTextWriter.WriteEndArray(); // payments

        if Method = Method::moneyOut then
            JsonTextWriter.WriteStringProperty('iTextCnt', 0); //This is a bug in the printer, it requires this property always

        JsonTextWriter.WriteEndObject(); // data
        JsonTextWriter.WriteEndObject();
        exit(JsonTextWriter.GetJSonAsText());
    end;

    internal procedure CreatePrintReceiptRequest(POSEntry: Record "NPR POS Entry"; var HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.") Request: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('command', 'printReceipt');
        JsonTextWriter.WriteStartObject('data');

        AddPOSStoreInfoHeader(JsonTextWriter, POSEntry."POS Unit No.", POSEntry."Document No.");

        AddPOSEntrySalesLines(JsonTextWriter, POSEntry, HULPOSAuditLogAux."Original Document No." <> 0);

        AddPOSEntryPaymentLines(JsonTextWriter, POSEntry, HULPOSAuditLogAux);

        AddSalesTicketNoBarcode(JsonTextWriter, POSEntry);

        JsonTextWriter.WriteEndObject(); // data
        JsonTextWriter.WriteEndObject();

        Request := JsonTextWriter.GetJSonAsText();

        HULAuditMgt.InsertHULPOSAuditLogAuxInfoRequestData(HULPOSAuditLogAux, Request);
    end;

    internal procedure CreateSimplifiedInvoiceRequest(POSEntry: Record "NPR POS Entry"; var HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.") Request: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('command', 'printInvoice');
        JsonTextWriter.WriteStartObject('data');

        AddCustomerData(JsonTextWriter, HULPOSAuditLogAux);

        AddPOSStoreInfoHeader(JsonTextWriter, POSEntry."POS Unit No.", POSEntry."Document No.");

        AddPOSEntrySalesLines(JsonTextWriter, POSEntry, HULPOSAuditLogAux."Original Document No." <> 0);

        AddPOSEntryPaymentLines(JsonTextWriter, POSEntry, HULPOSAuditLogAux);

        AddSalesTicketNoBarcode(JsonTextWriter, POSEntry);

        JsonTextWriter.WriteEndObject(); // data
        JsonTextWriter.WriteEndObject();

        Request := JsonTextWriter.GetJSonAsText();

        HULAuditMgt.InsertHULPOSAuditLogAuxInfoRequestData(HULPOSAuditLogAux, Request);
    end;

    internal procedure CreateReturnSaleRequest(POSEntry: Record "NPR POS Entry"; var HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.") Request: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('command', 'return');
        JsonTextWriter.WriteStartObject('data');

        JsonTextWriter.WriteStringProperty('iType', 0);
        JsonTextWriter.WriteStringProperty('sOrigDate', Format(HULPOSAuditLogAux."Original Date", 0, '<Year4>.<Month,2>.<Day,2>'));
        JsonTextWriter.WriteStringProperty('sOrigType', HULPOSAuditLogAux."Original Type");
        JsonTextWriter.WriteStringProperty('sOrigBBOXID', HULPOSAuditLogAux."Original BBOX ID");
        JsonTextWriter.WriteStringProperty('iOrigClosure', HULPOSAuditLogAux."Original Closure No.");
        JsonTextWriter.WriteStringProperty('iOrigNr', HULPOSAuditLogAux."Original Document No.");
        JsonTextWriter.WriteStringProperty('sReasonCode', Enum::"NPR HU L Return Reason Code".Names().Get(Enum::"NPR HU L Return Reason Code".Ordinals().IndexOf(HULPOSAuditLogAux."Return Reason".AsInteger())));

        AddCustomerData(JsonTextWriter, HULPOSAuditLogAux);

        AddPOSStoreInfoHeader(JsonTextWriter, POSEntry."POS Unit No.", POSEntry."Document No.");

        AddPOSEntrySalesLines(JsonTextWriter, POSEntry, HULPOSAuditLogAux."Original Document No." <> 0);

        AddPOSEntryPaymentLines(JsonTextWriter, POSEntry, HULPOSAuditLogAux);

        JsonTextWriter.WriteEndObject(); // data
        JsonTextWriter.WriteEndObject();

        Request := JsonTextWriter.GetJSonAsText();

        HULAuditMgt.InsertHULPOSAuditLogAuxInfoRequestData(HULPOSAuditLogAux, Request);
    end;

    internal procedure CreateVoidSaleRequest(POSEntry: Record "NPR POS Entry"; var HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.") Request: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('command', 'void');
        JsonTextWriter.WriteStartObject('data');

        JsonTextWriter.WriteStringProperty('iType', 0);
        JsonTextWriter.WriteStringProperty('sOrigDate', Format(HULPOSAuditLogAux."Original Date", 0, '<Year4>.<Month,2>.<Day,2>'));
        JsonTextWriter.WriteStringProperty('sOrigType', HULPOSAuditLogAux."Original Type");
        JsonTextWriter.WriteStringProperty('sOrigBBOXID', HULPOSAuditLogAux."Original BBOX ID");
        JsonTextWriter.WriteStringProperty('iOrigClosure', HULPOSAuditLogAux."Original Closure No.");
        JsonTextWriter.WriteStringProperty('iOrigNr', HULPOSAuditLogAux."Original Document No.");
        JsonTextWriter.WriteStringProperty('sReasonCode', Enum::"NPR HU L Return Reason Code".Names().Get(Enum::"NPR HU L Return Reason Code".Ordinals().IndexOf(HULPOSAuditLogAux."Return Reason".AsInteger())));

        AddCustomerData(JsonTextWriter, HULPOSAuditLogAux);

        AddPOSStoreInfoHeader(JsonTextWriter, POSEntry."POS Unit No.", POSEntry."Document No.");

        AddPOSEntrySalesLines(JsonTextWriter, POSEntry, HULPOSAuditLogAux."Original Document No." <> 0);

        AddPOSEntryPaymentLines(JsonTextWriter, POSEntry, HULPOSAuditLogAux);

        JsonTextWriter.WriteEndObject(); // data
        JsonTextWriter.WriteEndObject();

        Request := JsonTextWriter.GetJSonAsText();

        HULAuditMgt.InsertHULPOSAuditLogAuxInfoRequestData(HULPOSAuditLogAux, Request);
    end;

    local procedure AddCustomerData(var JsonTextWriter: Codeunit "Json Text Reader/Writer"; HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.")
    begin
        JsonTextWriter.WriteStartObject('customerData');
        JsonTextWriter.WriteStringProperty('sCustomerName', HULPOSAuditLogAux."Customer Name");
        JsonTextWriter.WriteStringProperty('sCustZip', HULPOSAuditLogAux."Customer Post Code");
        JsonTextWriter.WriteStringProperty('sCustCity', HULPOSAuditLogAux."Customer City");
        JsonTextWriter.WriteStringProperty('sCustPublicPlace', HULPOSAuditLogAux."Customer Address");

        if HULPOSAuditLogAux."Customer VAT Number" <> '' then begin
            JsonTextWriter.WriteStringProperty('iPrivatePerson', 0);
            JsonTextWriter.WriteStringProperty('sCustTaxId', HULPOSAuditLogAux."Customer VAT Number");
        end else
            JsonTextWriter.WriteStringProperty('iPrivatePerson', 1);
        JsonTextWriter.WriteEndObject(); // customerData
    end;

    local procedure AddPOSStoreInfoHeader(var JsonTextWriter: Codeunit "Json Text Reader/Writer"; POSUnitNo: Code[10]; DocumentNo: Code[20])
    var
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        CityFormatLbl: Label '%1, %2', Locked = true;
        DocumentNoLbl: Label 'Document No: %1', Comment = '%1 = POS Entry Document No.';
        POSUnitLbl: Label 'POS Unit: %1', Comment = '%1 = POS Unit No.';
    begin
        POSUnit.Get(POSUnitNo);
        POSStore.Get(POSUnit."POS Store Code");

        JsonTextWriter.WriteStringProperty('iHeadCnt', 5); //Increase number upon adding FreePrintLines
        JsonTextWriter.WriteStartArray('heads');

        AddFreePrintLine(JsonTextWriter, POSStore.Name, 1, 1);
        AddFreePrintLine(JsonTextWriter, POSStore.Address, 1, 1);
        AddFreePrintLine(JsonTextWriter, StrSubstNo(CityFormatLbl, POSStore."Post Code", POSStore.City), 1, 1);
        AddFreePrintLine(JsonTextWriter, StrSubstNo(DocumentNoLbl, DocumentNo), 1, 1);
        AddFreePrintLine(JsonTextWriter, StrSubstNo(POSUnitLbl, POSUnitNo), 1, 1);

        JsonTextWriter.WriteEndArray();
    end;

    local procedure AddPOSEntrySalesLines(var JsonTextWriter: Codeunit "Json Text Reader/Writer"; POSEntry: Record "NPR POS Entry"; ReturnSale: Boolean)
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        JsonTextWriter.WriteStringProperty('iItemCnt', GetPOSSalesLinesCount(POSEntry));
        JsonTextWriter.WriteStartArray('items');
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetFilter(Type, '%1|%2', POSEntrySalesLine.Type::Item, POSEntrySalesLine.Type::Voucher);
        if POSEntrySalesLine.FindSet() then
            repeat
                JsonTextWriter.WriteStartObject('');
                JsonTextWriter.WriteStartObject('stItem');
                JsonTextWriter.WriteStringProperty('sName', POSEntrySalesLine.Description);
                JsonTextWriter.WriteStringProperty('iVATIndex', GetVATPostSetupMappingIndex(POSEntrySalesLine."VAT Bus. Posting Group", POSEntrySalesLine."VAT Prod. Posting Group"));
                JsonTextWriter.WriteStringProperty('sArtNr', POSEntrySalesLine."No.");

                if ReturnSale then begin
                    JsonTextWriter.WriteStringProperty('fPrice', FormatDecimalValue((Abs(POSEntrySalesLine."Amount Incl. VAT") + Abs(POSEntrySalesLine."Line Discount Amount Incl. VAT")) / Abs(POSEntrySalesLine.Quantity)));
                    JsonTextWriter.WriteStringProperty('fQuantity', FormatQuantityValue(Abs(POSEntrySalesLine.Quantity)));
                end else begin
                    JsonTextWriter.WriteStringProperty('fPrice', FormatDecimalValue((POSEntrySalesLine."Amount Incl. VAT" + POSEntrySalesLine."Line Discount Amount Incl. VAT") / POSEntrySalesLine.Quantity));
                    JsonTextWriter.WriteStringProperty('fQuantity', FormatQuantityValue(POSEntrySalesLine.Quantity));
                end;

                if POSEntrySalesLine."Line Discount %" <> 0 then
                    AddItemDiscountArray(JsonTextWriter, POSEntrySalesLine);

                JsonTextWriter.WriteEndObject(); // stItem
                JsonTextWriter.WriteEndObject();
            until POSEntrySalesLine.Next() = 0;

        JsonTextWriter.WriteEndArray(); // items
    end;

    local procedure AddItemDiscountArray(var JsonTextWriter: Codeunit "Json Text Reader/Writer"; POSEntrySalesLine: Record "NPR POS Entry Sales Line")
    begin
        JsonTextWriter.WriteStartArray('itemDsc');
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('iDscCnt', 1);
        JsonTextWriter.WriteStartObject('stDiscount');
        JsonTextWriter.WriteStringProperty('sName', StrSubstNo(DiscountValueFormatLbl, POSEntrySalesLine."Line Discount %"));
        JsonTextWriter.WriteStringProperty('fAmount', FormatDecimalValue(-Abs(POSEntrySalesLine."Line Discount Amount Incl. VAT")));
        JsonTextWriter.WriteEndObject(); // stDiscount
        JsonTextWriter.WriteEndObject();
        JsonTextWriter.WriteEndArray(); // itemDsc
    end;

    local procedure AddPOSEntryPaymentLines(var JsonTextWriter: Codeunit "Json Text Reader/Writer"; POSEntry: Record "NPR POS Entry"; HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.")
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntryPaymentLineDict: Dictionary of [Code[10], Decimal];
        POSEntryPaymentLineDictKey: Code[10];
    begin
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryPaymentLine.SetFilter(Amount, '<>%1', 0);
        if POSEntryPaymentLine.FindSet() then
            repeat
                if not POSEntryPaymentLineDict.Add(POSEntryPaymentLine."POS Payment Method Code", POSEntryPaymentLine.Amount) then
                    POSEntryPaymentLineDict.Set(POSEntryPaymentLine."POS Payment Method Code", POSEntryPaymentLineDict.Get(POSEntryPaymentLine."POS Payment Method Code") + POSEntryPaymentLine.Amount);
            until POSEntryPaymentLine.Next() = 0;

        AddPaymentCountProperty(JsonTextWriter, POSEntryPaymentLineDict.Count(), HULPOSAuditLogAux."Rounding Amount" <> 0);

        if POSEntryPaymentLineDict.Count() = 0 then begin
            JsonTextWriter.WriteStartArray('payments');
            JsonTextWriter.WriteStartObject('');
            JsonTextWriter.WriteStartObject('stPayment');
            JsonTextWriter.WriteStringProperty('sName', Format(Enum::"NPR HU L Payment Fiscal Type"::CASH));
            JsonTextWriter.WriteStringProperty('fAmount', FormatDecimalValue(0));
            JsonTextWriter.WriteStringProperty('iFiscalType', Enum::"NPR HU L Payment Fiscal Type"::CASH.AsInteger());
            JsonTextWriter.WriteEndObject(); // stPayment
            JsonTextWriter.WriteEndObject();
        end else
            JsonTextWriter.WriteStartArray('payments');

        foreach POSEntryPaymentLineDictKey in POSEntryPaymentLineDict.Keys do begin
            JsonTextWriter.WriteStartObject('');
            AddPaymentLineInformation(JsonTextWriter, POSEntryPaymentLineDictKey, POSEntryPaymentLineDict.Get(POSEntryPaymentLineDictKey), HULPOSAuditLogAux."Original Document No." <> 0);
            JsonTextWriter.WriteEndObject();
        end;

        if HULPOSAuditLogAux."Rounding Amount" <> 0 then
            AddPaymentRoundingObj(JsonTextWriter, HULPOSAuditLogAux);

        JsonTextWriter.WriteEndArray(); // payments
    end;

    local procedure AddPaymentCountProperty(var JsonTextWriter: Codeunit "Json Text Reader/Writer"; POSEntryPaymentLineDictCount: Integer; RoundingExists: Boolean)
    var
        PaymentLineCount: Integer;
    begin
        PaymentLineCount := POSEntryPaymentLineDictCount;

        if PaymentLineCount = 0 then
            PaymentLineCount := 1;
        if RoundingExists then
            PaymentLineCount += 1;

        JsonTextWriter.WriteStringProperty('iPaymentCnt', PaymentLineCount);
    end;

    local procedure AddPaymentRoundingObj(var JsonTextWriter: Codeunit "Json Text Reader/Writer"; HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.")
    var
        RoundingDescLbl: Label 'Rounding';
    begin
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStartObject('stPayment');
        JsonTextWriter.WriteStringProperty('sName', RoundingDescLbl);
        JsonTextWriter.WriteStringProperty('fAmount', FormatDecimalValue(-1 * HULPOSAuditLogAux."Rounding Amount"));
        JsonTextWriter.WriteStringProperty('iFiscalType', Enum::"NPR HU L Payment Fiscal Type"::ROUNDING.AsInteger());
        JsonTextWriter.WriteEndObject(); // stPayment
        JsonTextWriter.WriteEndObject();
    end;

    local procedure AddPaymentLineInformation(var JsonTextWriter: Codeunit "Json Text Reader/Writer"; PaymentMethodCode: Code[10]; Amount: Decimal; ReturnSale: Boolean)
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        HULPOSPaymMethMapp: Record "NPR HU L POS Paym. Meth. Mapp.";
    begin
        POSPaymentMethod.Get(PaymentMethodCode);

        JsonTextWriter.WriteStartObject('stPayment');
        JsonTextWriter.WriteStringProperty('sName', POSPaymentMethod.Description);

        if ReturnSale then
            JsonTextWriter.WriteStringProperty('fAmount', FormatDecimalValue(Abs(Round(Amount, 1, '='))))
        else
            JsonTextWriter.WriteStringProperty('fAmount', FormatDecimalValue(Round(Amount, 1, '=')));

        if (not ReturnSale) and (Amount < 0) then
            JsonTextWriter.WriteStringProperty('iFiscalType', Enum::"NPR HU L Payment Fiscal Type"::CHANGE.AsInteger())
        else begin
            HULPOSPaymMethMapp.Get(PaymentMethodCode);
            JsonTextWriter.WriteStringProperty('iFiscalType', HULPOSPaymMethMapp."Payment Fiscal Type".AsInteger());
            if HULPOSPaymMethMapp."Payment Fiscal Type" = HULPOSPaymMethMapp."Payment Fiscal Type"::OTHER then
                JsonTextWriter.WriteStringProperty('iFiscalSubType', HULPOSPaymMethMapp."Payment Fiscal Subtype".AsInteger());
            if HULPOSPaymMethMapp."Payment Currency Type" <> HULPOSPaymMethMapp."Payment Currency Type"::"Ft." then
                JsonTextWriter.WriteStringProperty('iType', HULPOSPaymMethMapp."Payment Currency Type".AsInteger());
            if HULPOSPaymMethMapp."Payment Fiscal Type" = HULPOSPaymMethMapp."Payment Fiscal Type"::FOREIGN then
                AddForeignCurrencyExchRate(JsonTextWriter, POSPaymentMethod."Currency Code");
            if HULPOSPaymMethMapp."Payment Currency Type" = HULPOSPaymMethMapp."Payment Currency Type"::Foreign then
                AddForeignCurrencyInformation(JsonTextWriter, POSPaymentMethod."Currency Code");
        end;

        JsonTextWriter.WriteEndObject(); // stPayment
    end;

    internal procedure AddForeignCurrencyInformation(var JsonTextWriter: Codeunit "Json Text Reader/Writer"; CurrencyCode: Code[10])
    var
        Currency: Record "Currency";
    begin
        Currency.Get(CurrencyCode);
        JsonTextWriter.WriteStringProperty('sNotation', Currency."ISO Code");
        JsonTextWriter.WriteStringProperty('sSymbol', Currency.GetCurrencySymbol());
    end;

    local procedure AddForeignCurrencyExchRate(var JsonTextWriter: Codeunit "Json Text Reader/Writer"; CurrencyCode: Code[10])
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        CurrencyExchangeRate.SetRange("Currency Code", CurrencyCode);
        CurrencyExchangeRate.SetRange("Starting Date", 0D, Today());
        CurrencyExchangeRate.FindLast();
        JsonTextWriter.WriteStringProperty('fRate', FormatCurrExchRateValue(CurrencyExchangeRate."Relational Exch. Rate Amount"));
    end;

    local procedure AddSalesTicketNoBarcode(var JsonTextWriter: Codeunit "Json Text Reader/Writer"; POSEntry: Record "NPR POS Entry")
    begin
        JsonTextWriter.WriteStringProperty('iBarcodeCnt', 1);
        JsonTextWriter.WriteStartArray('barcodes');
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStartObject('stBarcode');
        JsonTextWriter.WriteStringProperty('iType', 7);
        JsonTextWriter.WriteStringProperty('iWidth', 2);
        JsonTextWriter.WriteStringProperty('iHeight', 40);
        JsonTextWriter.WriteStringProperty('iHRI', 1);
        JsonTextWriter.WriteStringProperty('iAlign', 1);
        JsonTextWriter.WriteStringProperty('data', POSEntry."Document No.");
        JsonTextWriter.WriteEndObject(); // stBarcode
        JsonTextWriter.WriteEndObject();
        JsonTextWriter.WriteEndArray(); // barcodes
    end;

    local procedure AddFreePrintLine(var JsonTextWriter: Codeunit "Json Text Reader/Writer"; PrintLineText: Text; Format: Integer; Alignment: Integer)
    begin
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStartObject('stFreePrint');
        JsonTextWriter.WriteStringProperty('sText', PrintLineText);
        JsonTextWriter.WriteStringProperty('iDouble', Format);
        JsonTextWriter.WriteStringProperty('iAlign', Alignment);
        JsonTextWriter.WriteEndObject(); // stFreePrint
        JsonTextWriter.WriteEndObject();
    end;

    local procedure AddPaymentBinCheckpointInformation(var JsonTextWriter: Codeunit "Json Text Reader/Writer"; POSSale: Record "NPR POS Sale")
    var
        CurrentZReport: Record "NPR POS Workshift Checkpoint";
        POSPaymentBinCheckp: Record "NPR POS Payment Bin Checkp.";
    begin
        CurrentZReport.SetRange("POS Unit No.", POSSale."Register No.");
        CurrentZReport.SetRange(Open, false);
        CurrentZReport.SetRange(Type, CurrentZReport.Type::ZREPORT);
        CurrentZReport.FindLast();

        POSPaymentBinCheckp.SetRange("Workshift Checkpoint Entry No.", CurrentZReport."Entry No.");
        if POSPaymentBinCheckp.Count() = 0 then
            exit;
        JsonTextWriter.WriteStartObject('data');
        JsonTextWriter.WriteStringProperty('iPaymentCnt', POSPaymentBinCheckp.Count());
        JsonTextWriter.WriteStartArray('payments');
        if POSPaymentBinCheckp.FindSet() then
            repeat
                JsonTextWriter.WriteStartObject('');
                AddPaymentLineInformation(JsonTextWriter, POSPaymentBinCheckp."Payment Method No.", POSPaymentBinCheckp."Counted Amount Incl. Float", false);
                JsonTextWriter.WriteEndObject();
            until POSPaymentBinCheckp.Next() = 0;

        JsonTextWriter.WriteEndArray(); // payments
        JsonTextWriter.WriteEndObject(); // data
    end;
    #endregion HU L Communication Mgt. - Request Creation

    #region HU L Communication Mgt. - Response Handling
    internal procedure SetOpenDayOnPOSUnitMapping(POSUnitNo: Code[10])
    var
        HULPOSUnitMapping: Record "NPR HU L POS Unit Mapping";
    begin
        HULPOSUnitMapping.Get(POSUnitNo);
        HULPOSUnitMapping."POS FCU Day Status" := HULPOSUnitMapping."POS FCU Day Status"::OPEN;
        HULPOSUnitMapping.Modify();
    end;

    internal procedure SetCloseDayOnPOSUnitMapping(POSUnitNo: Code[10])
    var
        HULPOSUnitMapping: Record "NPR HU L POS Unit Mapping";
    begin
        HULPOSUnitMapping.Get(POSUnitNo);
        HULPOSUnitMapping."POS FCU Day Status" := HULPOSUnitMapping."POS FCU Day Status"::CLOSED;
        HULPOSUnitMapping.Modify();
    end;

    internal procedure SaveDailyTotalsToPOSUnitMapping(Response: JsonObject; POSUnitNo: Code[10])
    var
        HULPOSUnitMapping: Record "NPR HU L POS Unit Mapping";
        DailyTotals: Text;
    begin
        HULPOSUnitMapping.Get(POSUnitNo);
        ParseDailyTotalResponse(DailyTotals, Response);
        HULPOSUnitMapping.SetDailyTotalsText(DailyTotals);
        Message(HULPOSUnitMapping.GetDailyTotalsText());
    end;

    internal procedure HandleMoneyOutTransactionResponse(Response: JsonObject)
    begin
        InsertMoneyTransactionResponseData(Response);
    end;
    #endregion HU L Communication Mgt. - Response Handling

    #region HU L Communication Mgt. - Error Handling
    internal procedure ThrowErrorMsgFromResponseIfCommunicationNotSuccessful(Response: JsonObject)
    var
        SuccessToken: JsonToken;
        ErrorMsgToken: JsonToken;
    begin
        Response.Get('Success', SuccessToken);
        if (SuccessToken.AsValue().AsBoolean()) then
            exit;
        Response.Get('ErrorMessage', ErrorMsgToken);
        Error(ErrorMsgToken.AsValue().AsText());
    end;

    internal procedure ThrowErrorMsgFromResponseMessageIfNotSuccessful(ResponseMessage: JsonObject)
    var
        ResultObj: JsonObject;
        JsonTok: JsonToken;
        ErrCodeTok: JsonToken;
        ErrMsgTok: JsonToken;
        ErrorText: Text;
    begin
        ResponseMessage.Get('result', JsonTok);
        ResultObj := JsonTok.AsObject();
        ResultObj.Get('iErrCode', ErrCodeTok);
        if (ErrCodeTok.AsValue().AsText() = '0') then
            exit;
        ResultObj.Get('sErrMsg', ErrMsgTok);
        ErrorText := ErrCodeTok.AsValue().AsText() + ': ' + ErrMsgTok.AsValue().AsText();

        if (ErrCodeTok.AsValue().AsText() = '531') then // Handles low printer paper error, doesn't obstruct flow of receiving receipt data from response
            Message(ErrorText)
        else
            Error(ErrorText);
    end;
    #endregion HU L Communication Mgt. - Error Handling

    #region HU L Communication Mgt. - Helper Procedures

    local procedure GetPOSSalesLinesCount(POSEntry: Record "NPR POS Entry"): Integer
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetFilter(Type, '%1|%2', POSEntrySalesLine.Type::Item, POSEntrySalesLine.Type::Voucher);
        exit(POSEntrySalesLine.Count());
    end;

    local procedure GetVATPostSetupMappingIndex(VATBusPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20]): Integer
    var
        HULVATPostSetupMapp: Record "NPR HU L VAT Post. Setup Mapp.";
    begin
        HULVATPostSetupMapp.Get(VATBusPostingGroupCode, VATProdPostingGroupCode);
        exit(HULVATPostSetupMapp."Laurel VAT Index".AsInteger());
    end;

    local procedure SelectReturnHULPOSAuditLogAndInsertNewAuditLog(var ReturnPOSEntry: Record "NPR POS Entry"; var HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.")
    var
        ReturnHULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.";
        HULReturnReasonCode: Enum "NPR HU L Return Reason Code";
        DateList: List of [Text];
        Day: Integer;
        Month: Integer;
        Year: Integer;
    begin
        Commit();
        if Page.RunModal(0, ReturnHULPOSAuditLogAux) <> Action::LookupOK then
            Error('');
        ReturnPOSEntry.Get(ReturnHULPOSAuditLogAux."POS Entry No.");
        HULPOSAuditLogAux.Init();
        HULPOSAuditLogAux."Audit Entry Type" := HULPOSAuditLogAux."Audit Entry Type"::"POS Entry";
        HULPOSAuditLogAux."Transaction Type" := HULPOSAuditLogAux."Transaction Type"::Void;
        HULPOSAuditLogAux."Entry Date" := ReturnPOSEntry."Entry Date";
        HULPOSAuditLogAux."POS Store Code" := ReturnPOSEntry."POS Store Code";
        HULPOSAuditLogAux."POS Unit No." := ReturnPOSEntry."POS Unit No.";
        HULPOSAuditLogAux."Amount Incl. Tax" := ReturnPOSEntry."Amount Incl. Tax";
        HULPOSAuditLogAux."Salesperson Code" := ReturnPOSEntry."Salesperson Code";
        DateList := ReturnHULPOSAuditLogAux.GetReceiptDateAsText().Split('.');
        Evaluate(Day, DateList.Get(3));
        Evaluate(Month, DateList.Get(2));
        Evaluate(Year, DateList.Get(1));
        HULPOSAuditLogAux."Original Date" := DMY2Date(Day, Month, Year);
        case ReturnHULPOSAuditLogAux."Transaction Type" of
            ReturnHULPOSAuditLogAux."Transaction Type"::"Standard Receipt":
                HULPOSAuditLogAux."Original Type" := 'NY';
            ReturnHULPOSAuditLogAux."Transaction Type"::"Simple Invoice":
                HULPOSAuditLogAux."Original Type" := 'SZ';
        end;
        HULPOSAuditLogAux."Original BBOX ID" := ReturnHULPOSAuditLogAux."FCU BBOX ID";
        HULPOSAuditLogAux."Original Document No." := ReturnHULPOSAuditLogAux."FCU Document No.";
        HULPOSAuditLogAux."Original Closure No." := ReturnHULPOSAuditLogAux."FCU Closure No.";
        HULPOSAuditLogAux."Return Reason" := HULReturnReasonCode::S2;
        HULPOSAuditLogAux.Insert();
    end;

    local procedure CalculateChangeAmount(ReturnPOSEntry: Record "NPR POS Entry") ChangeToGive: Decimal
    var
        PaidAmount: Decimal;
        TotalAmount: Decimal;
    begin
        TotalAmount := CalculateTotalRoundedSaleLines(ReturnPOSEntry);

        if TotalAmount < 0 then
            exit;

        PaidAmount := Round(ReturnPOSEntry."Amount Incl. Tax", 5, '=');

        ChangeToGive := Round(PaidAmount - TotalAmount, 5, '=');

        if Round(PaidAmount - ChangeToGive - TotalAmount, 1, '=') > 2 then
            ChangeToGive := Round(PaidAmount - TotalAmount, 5, '>');

        if Round(PaidAmount - ChangeToGive - TotalAmount, 1, '=') < -2 then
            ChangeToGive := Round(PaidAmount - TotalAmount, 5, '<');
    end;

    local procedure CalculateRoundingAmount(ReturnPOSEntry: Record "NPR POS Entry") RoundAmount: Decimal;
    begin
        RoundAmount := (Abs(Round(ReturnPOSEntry."Amount Incl. Tax", 5, '=')) - Abs(CalculateChangeAmount(ReturnPOSEntry)) - CalculateTotalNotRoundedSaleLines(ReturnPOSEntry));
    end;

    local procedure CalculateTotalRoundedSaleLines(ReturnPOSEntry: Record "NPR POS Entry") TotalAmount: Decimal
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        TotalDiscountAmount: Decimal;
    begin
        POSEntrySalesLine.SetLoadFields("Amount Incl. VAT", "Line Discount Amount Incl. VAT", "VAT %");
        POSEntrySalesLine.SetRange("POS Entry No.", ReturnPOSEntry."Entry No.");
        POSEntrySalesLine.SetRange("Type", POSEntrySalesLine."Type"::Item);
        if POSEntrySalesLine.FindSet() then
            repeat
                TotalDiscountAmount += Round(POSEntrySalesLine."Line Discount Amount Incl. VAT", 1, '=');
                TotalAmount += Round(POSEntrySalesLine."Amount Incl. VAT" + POSEntrySalesLine."Line Discount Amount Incl. VAT", 1, '=');
            until POSEntrySalesLine.Next() = 0;

        TotalAmount -= TotalDiscountAmount;
    end;

    local procedure CalculateTotalNotRoundedSaleLines(ReturnPOSEntry: Record "NPR POS Entry"): Decimal
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntrySalesLine.SetLoadFields("Amount Incl. VAT");
        POSEntrySalesLine.SetRange("POS Entry No.", ReturnPOSEntry."Entry No.");
        POSEntrySalesLine.SetRange("Type", POSEntrySalesLine."Type"::Item);
        POSEntrySalesLine.CalcSums("Amount Incl. VAT");
        exit(POSEntrySalesLine."Amount Incl. VAT");
    end;

    local procedure ParseDailyTotalResponse(var DailyTotals: Text; Response: JsonObject)
    var
        ResultObj: JsonObject;
        JsonTok: JsonToken;
        TempResult: Text;
    begin
        Response.Get('result', JsonTok);
        ResultObj := JsonTok.AsObject();

        ResultObj.Get('pTotal', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'Total', TempResult);

        ResultObj.Get('iVoids', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'Void Count', TempResult);

        ResultObj.Get('iRefunds', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'Refund Count', TempResult);

        ResultObj.Get('iNonFis', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'Non Fisc. Count', TempResult);

        ResultObj.Get('iNonFisAb', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'Non Fisc. Cancelled Count', TempResult);

        ResultObj.Get('sBBOXID', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'BBOX Printer ID', TempResult);

        ResultObj.Get('iClosureNr', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'Closure No.', TempResult);

        ResultObj.Get('iReceiptNr', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'Receipt No.', TempResult);

        ResultObj.Get('iInvNr', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'Invoice No.', TempResult);

        ResultObj.Get('pVoidTotal', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'Total Void', TempResult);

        ResultObj.Get('pRefundTotal', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'Total Refund', TempResult);

        ResultObj.Get('iCancelledVoids', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'Cancelled Void Count', TempResult);

        ResultObj.Get('iCancelledRefunds', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'Cancelled Refunds Count', TempResult);

        ResultObj.Get('iMoneyIn', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'In-Payment Voucher Count', TempResult);

        ResultObj.Get('iMoneyInAb', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'In-Payment Voucher Cancelled Count', TempResult);

        ResultObj.Get('iMoneyOut', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'Out-Payment Voucher Count', TempResult);

        ResultObj.Get('iMoneyOutAb', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'Out-Payment Voucher Cancelled Count', TempResult);

        ResultObj.Get('iMediaEx', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'Media Exchange Voucher Count', TempResult);

        ResultObj.Get('iMediaExAb', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'Media Exchange Voucher Cancelled Count', TempResult);

        ResultObj.Get('iCancelledReceipts', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'Cancelled Receipts Count', TempResult);

        ResultObj.Get('iCancelledInvoices', JsonTok);
        JsonTok.WriteTo(TempResult);
        AppendDailyTotalsText(DailyTotals, 'Cancelled Invoices Count', TempResult);
    end;

    local procedure InsertMoneyTransactionResponseData(Response: JsonObject)
    var
        ReceiptDataObj: JsonObject;
        JsonTok: JsonToken;
        ResponseText: Text;
        HULCashTransaction: Record "NPR HU L Cash Transaction";
    begin
        HULCashTransaction.FindLast();
        Response.Get('result', JsonTok);
        Response := JsonTok.AsObject();
        Response.Get('receiptData', JsonTok);
        ReceiptDataObj := JsonTok.AsObject();

#pragma warning disable AA0139
        ReceiptDataObj.Get('sBBOXID', JsonTok);
        HULCashTransaction."FCU ID" := JsonTok.AsValue().AsCode();

        ReceiptDataObj.Get('iClosureNr', JsonTok);
        HULCashTransaction."FCU Closure No." := JsonTok.AsValue().AsInteger();

        ReceiptDataObj.Get('iNr', JsonTok);
        HULCashTransaction."FCU Document No." := JsonTok.AsValue().AsInteger();

        ReceiptDataObj.Get('sTimestamp', JsonTok);
        HULCashTransaction."FCU Timestamp" := JsonTok.AsValue().AsText();

        ReceiptDataObj.Get('sDocumentNumber', JsonTok);
        HULCashTransaction."FCU Full Document No." := JsonTok.AsValue().AsText();
#pragma warning restore AA0139

        ReceiptDataObj.WriteTo(ResponseText);
        HULCashTransaction.SetResponseText(ResponseText);

        HULCashTransaction.Modify();
    end;

    local procedure AppendDailyTotalsText(var DailyTotals: Text; Caption: Text; Value: Text)
    begin
        DailyTotals += Caption + ': ' + Value + '\';
    end;
    #endregion HU L Communication Mgt. - Helper Procedures

    #region HU L Communication Mgt. - Formatting Values
    local procedure FormatDecimalValue(Value: Decimal): Text
    begin
        exit(Format(Value, 0, '<Precision,2:2><Sign><Integer><Decimals><Comma,.>'))
    end;

    local procedure FormatQuantityValue(Value: Decimal): Text
    begin
        exit(Format(Value, 0, '<Precision,3:3><Sign><Integer><Decimals><Comma,.>'))
    end;

    local procedure FormatCurrExchRateValue(Value: Decimal): Text
    begin
        exit(Format(Value, 0, '<Precision,3:8><Integer><Decimals><Comma,.>'))
    end;

    local procedure RoundRoundingAmount(Amount: Decimal): Decimal
    begin
        if (Round(Amount, 1, '=') > 2) or (Round(Amount, 1, '=') < -2) then
            exit(Round(Amount, 1, '<'))
        else
            exit(Round(Amount, 1, '='));
    end;
    #endregion HU L Communication Mgt. - Formatting Values

    #region HU L Communication Mgt. - HWC Integration Parameters
    internal procedure SetBaseHwcRequestValues(var HwcRequest: JsonObject; POSUnitNo: Code[20])
    var
        HULPOSUnitMapping: Record "NPR HU L POS Unit Mapping";
    begin
        HULPOSUnitMapping.Get(POSUnitNo);
        HwcRequest.Add('HwcName', HwcIntegrationName());
        HwcRequest.Add('License', HULPOSUnitMapping."Laurel License");
        HwcRequest.Add('TimeoutMs', 2000);
    end;

    local procedure HwcIntegrationName(): Text
    begin
        exit('LaurelMiniPOS');
    end;
    #endregion HU L Communication Mgt. - HWC Integration Parameters

    var
        HULAuditMgt: Codeunit "NPR HU L Audit Mgt.";
        DiscountValueFormatLbl: Label 'Discount %1', Comment = '%1 = Discount Percentage';
}