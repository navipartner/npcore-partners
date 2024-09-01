codeunit 6150982 "NPR RS Tax Communication Mgt."
{
    Access = Internal;

    #region COMMUNICATION REQUESTS with Tax Authority
    internal procedure CreateNormalSale(var RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info")
    var
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSPOSUnitMapping: Record "NPR RS POS Unit Mapping";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        IsHandled: Boolean;
        StartTime: DateTime;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        Url: Text;
    begin
        if not RSAuditMgt.IsRSFiscalActive() then
            exit;
        StartTime := CurrentDateTime;
        VerifyPIN(RSPOSAuditLogAuxInfo."POS Unit No.");
        RSFiscalizationSetup.Get();
        Content.WriteFrom(CreateJSONBodyForRSFiscalNormalSale(RSPOSAuditLogAuxInfo, false));

        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', 'application/json');
        RSPOSUnitMapping.Get(RSPOSAuditLogAuxInfo."POS Unit No.");
        Url := RSFiscalizationSetup."Sandbox URL" + GetSandboxToken(RSFiscalizationSetup."Exclude Token from URL", RSPOSUnitMapping."RS Sandbox Token") + GetApiVersionUrl() + 'invoices';

        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        IsHandled := false;
        OnBeforeSendHttpRequestForNormalSale(RequestMessage, ResponseText, RSPOSAuditLogAuxInfo, StartTime, IsHandled);
        if IsHandled then
            exit;
        if SendHttpRequest(RequestMessage, ResponseText, false) then
            FillRSAuditFromNormalSaleAndRefundResponse(RSPOSAuditLogAuxInfo, ResponseText, StartTime)
        else
            ErrorLogReceiptFiscalisated(ResponseText);
    end;

    internal procedure CreateNormalSale(SalesInvoiceNo: Code[20])
    var
        RSAuxSalesInvHeader: Record "NPR RS Aux Sales Inv. Header";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSPOSUnitMapping: Record "NPR RS POS Unit Mapping";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        IsHandled: Boolean;
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        StartTime: DateTime;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        Url: Text;
    begin
        if not RSAuditMgt.IsRSFiscalActive() then
            exit;
        StartTime := CurrentDateTime;
        RSAuxSalesInvHeader.Get(SalesInvoiceNo);
        VerifyPIN(RSAuxSalesInvHeader."NPR RS POS Unit");
        RSFiscalizationSetup.Get();
        SalesInvoiceHeader.Get(SalesInvoiceNo);
        CreatePrepaymentRefund(SalesInvoiceHeader);
        Content.WriteFrom(CreateJSONBodyForRSFiscalNormalSale(SalesInvoiceHeader, false));

        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', 'application/json');
        RSPOSUnitMapping.Get(RSAuxSalesInvHeader."NPR RS POS Unit");
        Url := RSFiscalizationSetup."Sandbox URL" + GetSandboxToken(RSFiscalizationSetup."Exclude Token from URL", RSPOSUnitMapping."RS Sandbox Token") + GetApiVersionUrl() + 'invoices';

        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        IsHandled := false;
        OnBeforeSendHttpRequestForPrepaymentSaleDocument(RequestMessage, ResponseText, SalesInvoiceHeader, StartTime, IsHandled);
        if IsHandled then
            exit;
        if SendHttpRequest(RequestMessage, ResponseText, false) then
            FillRSAuditFromNormalSaleAndRefundResponse(SalesInvoiceHeader, ResponseText, StartTime, false, true)
        else
            ErrorLogReceiptFiscalisated(ResponseText);
    end;

    internal procedure CreatePrepaymentSale(var RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info")
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSPOSUnitMapping: Record "NPR RS POS Unit Mapping";
        IsHandled: Boolean;
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        StartTime: DateTime;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        Url: Text;
    begin
        if not RSAuditMgt.IsRSFiscalActive() then
            exit;
        if not SalesInvoiceHeader.Get(RSPOSAuditLogAuxInfo."Source Document No.") then
            exit;
        if not SalesHeader.Get(SalesHeader."Document Type"::Order, SalesInvoiceHeader."Prepayment Order No.") then
            exit;
        StartTime := CurrentDateTime;
        VerifyPIN(RSPOSAuditLogAuxInfo."POS Unit No.");
        RSFiscalizationSetup.Get();
        Content.WriteFrom(CreateJSONBodyForRSFiscalAdvanceSale(RSPOSAuditLogAuxInfo, SalesInvoiceHeader, SalesHeader, false));

        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', 'application/json');
        RSPOSUnitMapping.Get(RSPOSAuditLogAuxInfo."POS Unit No.");
        Url := RSFiscalizationSetup."Sandbox URL" + GetSandboxToken(RSFiscalizationSetup."Exclude Token from URL", RSPOSUnitMapping."RS Sandbox Token") + GetApiVersionUrl() + 'invoices';

        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        IsHandled := false;
        OnBeforeSendHttpRequestForNormalSaleDocument(RequestMessage, ResponseText, SalesInvoiceHeader, StartTime, IsHandled);
        if IsHandled then
            exit;
        if SendHttpRequest(RequestMessage, ResponseText, false) then
            FillRSAuditFromNormalSaleAndRefundResponse(RSPOSAuditLogAuxInfo, ResponseText, StartTime)
        else
            ErrorLogReceiptFiscalisated(ResponseText);
    end;

    internal procedure CreatePrepaymentRefund(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        RSAuxSalesInvHeader: Record "NPR RS Aux Sales Inv. Header";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSPOSUnitMapping: Record "NPR RS POS Unit Mapping";
        RSPOSAuditLogAuxInfoReferent: Record "NPR RS POS Audit Log Aux. Info";
        // IsHandled: Boolean;
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        StartTime: DateTime;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        Url: Text;
    begin
        if not RSAuditMgt.IsRSFiscalActive() then
            exit;
        StartTime := CurrentDateTime;
        RSAuxSalesInvHeader.ReadRSAuxSalesInvHeaderFields(SalesInvoiceHeader);
        VerifyPIN(RSAuxSalesInvHeader."NPR RS POS Unit");
        RSFiscalizationSetup.Get();
        RSPOSAuditLogAuxInfoReferent.SetRange("RS Invoice Type", RSPOSAuditLogAuxInfoReferent."RS Invoice Type"::ADVANCE);
        RSPOSAuditLogAuxInfoReferent.SetRange("RS Transaction Type", RSPOSAuditLogAuxInfoReferent."RS Transaction Type"::SALE);
        RSPOSAuditLogAuxInfoReferent.SetRange("Prepayment Order No.", SalesInvoiceHeader."Order No.");
        if RSPOSAuditLogAuxInfoReferent.IsEmpty() then
            exit;
        Content.WriteFrom(CreateJSONBodyForRSFiscalAdvanceRefund(SalesInvoiceHeader, false));

        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', 'application/json');
        RSPOSUnitMapping.Get(RSAuxSalesInvHeader."NPR RS POS Unit");
        Url := RSFiscalizationSetup."Sandbox URL" + GetSandboxToken(RSFiscalizationSetup."Exclude Token from URL", RSPOSUnitMapping."RS Sandbox Token") + GetApiVersionUrl() + 'invoices';

        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        // IsHandled := false;
        // OnBeforeSendHttpRequestForNormalSaleDocument(RequestMessage, ResponseText, SalesInvoiceHeader, StartTime, IsHandled);
        // if IsHandled then
        //     exit;
        if SendHttpRequest(RequestMessage, ResponseText, false) then
            FillRSAuditFromNormalSaleAndRefundResponse(SalesInvoiceHeader, ResponseText, StartTime, true, true)
        else
            ErrorLogReceiptFiscalisated(ResponseText);
    end;

    internal procedure CreateProformaSale(var SalesHeader: Record "Sales Header")
    var
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSPOSUnitMapping: Record "NPR RS POS Unit Mapping";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        IsHandled: Boolean;
        StartTime: DateTime;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ProformaCreatedMsg: Label 'Sales Proforma has been created and RS Audit Log created for this Sales Document %1', Comment = '%1 - Sales Header Document No.';
        ResponseText: Text;
        Url: Text;
    begin
        if not RSAuditMgt.IsRSFiscalActive() then
            exit;
        RSFiscalizationSetup.Get();
        if not RSFiscalizationSetup."Fiscal Proforma on Sales Doc." then
            exit;

        StartTime := CurrentDateTime;
        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(SalesHeader);
        VerifyPIN(RSAuxSalesHeader."NPR RS POS Unit");
        Content.WriteFrom(CreateJSONBodyForRSFiscalNormalSale(SalesHeader, false));

        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', 'application/json');
        RSPOSUnitMapping.Get(RSAuxSalesHeader."NPR RS POS Unit");
        Url := RSFiscalizationSetup."Sandbox URL" + GetSandboxToken(RSFiscalizationSetup."Exclude Token from URL", RSPOSUnitMapping."RS Sandbox Token") + GetApiVersionUrl() + 'invoices';

        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        IsHandled := false;
        OnBeforeSendHttpRequestForProformaSale(RequestMessage, ResponseText, SalesHeader, StartTime, IsHandled);
        if IsHandled then
            exit;
        if SendHttpRequest(RequestMessage, ResponseText, false) then begin
            FillRSAuditFromNormalSaleAndRefundResponse(SalesHeader, ResponseText, false, true, StartTime);
            Message(ProformaCreatedMsg, SalesHeader."No.");
        end else
            ErrorLogReceiptFiscalisated(ResponseText);
    end;

    internal procedure CreateNormalRefund(var RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info")
    var
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSPOSUnitMapping: Record "NPR RS POS Unit Mapping";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        IsHandled: Boolean;
        StartTime: DateTime;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        Url: Text;
    begin
        if not RSAuditMgt.IsRSFiscalActive() then
            exit;
        StartTime := CurrentDateTime;
        VerifyPIN(RSPOSAuditLogAuxInfo."POS Unit No.");
        RSFiscalizationSetup.Get();
        Content.WriteFrom(CreateJSONBodyForRSFiscalNormalRefund(RSPOSAuditLogAuxInfo));

        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', 'application/json');
        RSPOSUnitMapping.Get(RSPOSAuditLogAuxInfo."POS Unit No.");
        Url := RSFiscalizationSetup."Sandbox URL" + GetSandboxToken(RSFiscalizationSetup."Exclude Token from URL", RSPOSUnitMapping."RS Sandbox Token") + GetApiVersionUrl() + 'invoices';

        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        IsHandled := false;
        OnBeforeSendHttpRequestForNormalRefund(RequestMessage, ResponseText, RSPOSAuditLogAuxInfo, StartTime, IsHandled);
        if IsHandled then
            exit;
        if SendHttpRequest(RequestMessage, ResponseText, false) then
            FillRSAuditFromNormalSaleAndRefundResponse(RSPOSAuditLogAuxInfo, ResponseText, StartTime)
        else
            ErrorLogReceiptFiscalisated(ResponseText);
    end;

    internal procedure CreateNormalRefund(SalesCrMemoNo: Code[20])
    var
        RSAuxSalesCrMemoHeader: Record "NPR RS Aux Sales CrMemo Header";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSPOSUnitMapping: Record "NPR RS POS Unit Mapping";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        StartTime: DateTime;
        IsHandled: Boolean;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        Url: Text;
    begin
        if not RSAuditMgt.IsRSFiscalActive() then
            exit;
        StartTime := CurrentDateTime;
        SalesCrMemoHeader.Get(SalesCrMemoNo);
        RSAuxSalesCrMemoHeader.ReadRSAuxSalesCrMemoHeaderFields(SalesCrMemoHeader);
        if (RSAuxSalesCrMemoHeader."NPR RS Refund Reference" = '') and ((RSAuxSalesCrMemoHeader."NPR RS Referent No." = '') or (RSAuxSalesCrMemoHeader."NPR RS Referent Date/Time" = 0DT)) then
            exit;
        VerifyPIN(RSAuxSalesCrMemoHeader."NPR RS POS Unit");
        RSFiscalizationSetup.Get();
        Content.WriteFrom(CreateJSONBodyForRSFiscalNormalRefund(SalesCrMemoHeader, false));

        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', 'application/json');
        RSPOSUnitMapping.Get(RSAuxSalesCrMemoHeader."NPR RS POS Unit");
        Url := RSFiscalizationSetup."Sandbox URL" + GetSandboxToken(RSFiscalizationSetup."Exclude Token from URL", RSPOSUnitMapping."RS Sandbox Token") + GetApiVersionUrl() + 'invoices';

        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        IsHandled := false;
        OnBeforeSendHttpRequestForNormalRefundDocument(RequestMessage, ResponseText, SalesCrMemoHeader, StartTime, IsHandled);
        if IsHandled then
            exit;
        if SendHttpRequest(RequestMessage, ResponseText, false) then
            FillRSAuditFromNormalSaleAndRefundResponse(SalesCrMemoHeader, ResponseText, StartTime, true)
        else
            ErrorLogReceiptFiscalisated(ResponseText);
    end;

    internal procedure CreateProformaRefund(var SalesHeader: Record "Sales Header"; ModifySalesHeader: Boolean)
    var
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSPOSUnitMapping: Record "NPR RS POS Unit Mapping";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        IsHandled: Boolean;
        StartTime: DateTime;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ProformaCreatedMsg: Label 'Sales Proforma Refund has been created and RS Audit Log created for this Sales Document %1', Comment = '%1 - Sales Header Document No.';
        ResponseText: Text;
        Url: Text;
    begin
        if not RSAuditMgt.IsRSFiscalActive() then
            exit;
        RSFiscalizationSetup.Get();
        if not RSFiscalizationSetup."Fiscal Proforma on Sales Doc." then
            exit;

        StartTime := CurrentDateTime;
        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(SalesHeader);
        VerifyPIN(RSAuxSalesHeader."NPR RS POS Unit");
        Content.WriteFrom(CreateJSONBodyForRSFiscalNormalRefund(SalesHeader));

        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', 'application/json');
        RSPOSUnitMapping.Get(RSAuxSalesHeader."NPR RS POS Unit");
        Url := RSFiscalizationSetup."Sandbox URL" + GetSandboxToken(RSFiscalizationSetup."Exclude Token from URL", RSPOSUnitMapping."RS Sandbox Token") + GetApiVersionUrl() + 'invoices';

        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        IsHandled := false;
        OnBeforeSendHttpRequestForProformaRefund(RequestMessage, ResponseText, SalesHeader, StartTime, IsHandled);
        if IsHandled then
            exit;
        if SendHttpRequest(RequestMessage, ResponseText, false) then begin
            FillRSAuditFromNormalSaleAndRefundResponse(SalesHeader, ResponseText, true, ModifySalesHeader, StartTime);
            if ModifySalesHeader then
                Message(ProformaCreatedMsg, SalesHeader."No.");
        end else
            ErrorLogReceiptFiscalisated(ResponseText);
    end;

    internal procedure CreateCopyFiscalReceipt(var RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info")
    var
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSPOSUnitMapping: Record "NPR RS POS Unit Mapping";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        StartTime: DateTime;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        Url: Text;
    begin
        if not RSAuditMgt.IsRSFiscalActive() then
            exit;
        StartTime := CurrentDateTime;
        VerifyPIN(RSPOSAuditLogAuxInfo."POS Unit No.");
        RSFiscalizationSetup.Get();
        if RSFiscalizationSetup.Training then
            exit;
        case RSPOSAuditLogAuxInfo."Audit Entry Type" of
            RSPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry":
                Content.WriteFrom(CreateJSONBodyForRSFiscalNormalSale(RSPOSAuditLogAuxInfo, true));
            RSPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Header":
                begin
                    SalesHeader.Get(RSPOSAuditLogAuxInfo."Source Document Type", RSPOSAuditLogAuxInfo."Source Document No.");
                    Content.WriteFrom(CreateJSONBodyForRSFiscalNormalSale(SalesHeader, true));
                end;
            RSPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Invoice Header":
                begin
                    SalesInvoiceHeader.Get(RSPOSAuditLogAuxInfo."Source Document No.");
                    Content.WriteFrom(CreateJSONBodyForRSFiscalNormalSale(SalesInvoiceHeader, true));
                end;
            RSPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Cr.Memo Header":
                begin
                    SalesCrMemoHeader.Get(RSPOSAuditLogAuxInfo."Source Document No.");
                    Content.WriteFrom(CreateJSONBodyForRSFiscalNormalRefund(SalesCrMemoHeader, true));
                end;
        end;
        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', 'application/json');
        RSPOSUnitMapping.Get(RSPOSAuditLogAuxInfo."POS Unit No.");
        Url := RSFiscalizationSetup."Sandbox URL" + GetSandboxToken(RSFiscalizationSetup."Exclude Token from URL", RSPOSUnitMapping."RS Sandbox Token") + GetApiVersionUrl() + 'invoices';

        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        if SendHttpRequest(RequestMessage, ResponseText, false) then
            FillRSAuditFromCopySaleAndRefundResponse(RSPOSAuditLogAuxInfo, ResponseText, StartTime)
        else
            ErrorLogReceiptFiscalisated(ResponseText);
    end;

    internal procedure VerifyPIN(POSUnitNo: Code[10]): Text
    var
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSPOSUnitMapping: Record "NPR RS POS Unit Mapping";
        RSPinStatusResponse: Enum "NPR RS Pin Status Response";
        IsHandled: Boolean;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        Url: Text;
    begin
        RSFiscalizationSetup.Get();
        RSPOSUnitMapping.Get(POSUnitNo);
        Content.WriteFrom('"' + Format(RSPOSUnitMapping."RS Sandbox PIN") + '"');

        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', 'application/json');
        Url := RSFiscalizationSetup."Sandbox URL" + GetSandboxToken(RSFiscalizationSetup."Exclude Token from URL", RSPOSUnitMapping."RS Sandbox Token") + GetApiVersionUrl() + 'pin';

        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        IsHandled := false;
        OnBeforeSendHttpRequestForVerifyPin(RequestMessage, ResponseText, IsHandled);
        if IsHandled then
            exit(ResponseText);
        SendHttpRequest(RequestMessage, ResponseText, false);
        ResponseText := DelChr(ResponseText, '=', '"');
        Evaluate(RSPinStatusResponse, ResponseText);
        exit(ResponseText + ' - ' + Format(RSPinStatusResponse));
    end;

    internal procedure PullAndFillSUFConfiguration(): Text
    var
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        IsHandled: Boolean;
        ResponseText: Text;
        Url: Text;
    begin
        RSFiscalizationSetup.Get();

        if RSFiscalizationSetup."Configuration URL".EndsWith('/') then
            Url := RSFiscalizationSetup."Configuration URL" + GetApiVersionUrl() + 'configuration'
        else
            Url := RSFiscalizationSetup."Configuration URL" + '/' + GetApiVersionUrl() + 'configuration';

        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('GET');
        RequestMessage.GetHeaders(Headers);
        IsHandled := false;
        OnBeforeSendHttpRequestForSUFConfiguration(RequestMessage, ResponseText, IsHandled);
        if IsHandled then
            exit;
        if SendHttpRequest(RequestMessage, ResponseText, true) then
            FillSUFConfigurationSetup(ResponseText)
        else
            ClearSUFConfigurationSetup();
    end;

    internal procedure PullAndFillAllowedTaxRates(): Text
    var
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        IsHandled: Boolean;
        ResponseText: Text;
        Url: Text;
    begin
        RSFiscalizationSetup.Get();

        if RSFiscalizationSetup."Configuration URL".EndsWith('/') then
            Url := RSFiscalizationSetup."Configuration URL" + GetApiVersionUrl() + 'tax-rates'
        else
            Url := RSFiscalizationSetup."Configuration URL" + '/' + GetApiVersionUrl() + 'tax-rates';

        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('GET');
        RequestMessage.GetHeaders(Headers);
        IsHandled := false;
        OnBeforeSendHttpRequestForAllowedTaxRates(RequestMessage, ResponseText, IsHandled);
        if IsHandled then
            exit;
        if SendHttpRequest(RequestMessage, ResponseText, true) then
            FillAllowedTaxRates(ResponseText, false)
        else
            ClearAllowedTaxRates();
    end;
    #endregion

    #region JSON Fiscal Creators
    local procedure CreateJSONBodyForRSFiscalNormalSale(RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info"; IsCopy: Boolean): Text
    var
        Item: Record Item;
        NpRvArchVoucherEntry: Record "NPR NpRv Arch. Voucher Entry";
        POSEntry: Record "NPR POS Entry";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        RSAllowedTaxRates: Record "NPR RS Allowed Tax Rates";
        RSPOSPaymMethMapping: Record "NPR RS POS Paym. Meth. Mapping";
        RSVATPostSetupMapping: Record "NPR RS VAT Post. Setup Mapping";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        HasArchVoucherEntry: Boolean;
        Certification: Dictionary of [Text, Text];
        JArray: JsonArray;
        JArray2: JsonArray;
        JObjectHeader: JsonObject;
        JObjectLines: JsonObject;
        ItemName: Text;
        JsonBodyTxt: Text;
    begin
        RSFiscalizationSetup.Get();
        POSEntry.Get(RSPOSAuditLogAuxInfo."POS Entry No.");
        JObjectHeader.Add('cashier', POSEntry."Salesperson Code");
        if RSPOSAuditLogAuxInfo."Customer Identification" <> '' then
            if StrLen(RSPOSAuditLogAuxInfo."Customer Identification") > 3 then
                JObjectHeader.Add('buyerId', RSPOSAuditLogAuxInfo."Customer Identification");
        if RSPOSAuditLogAuxInfo."Additional Customer Field" <> '' then
            JObjectHeader.Add('buyerCostCenterId', RSPOSAuditLogAuxInfo."Additional Customer Field");
        if IsCopy then
            JObjectHeader.Add('invoiceType', GetEnumValueName(Enum::"NPR RS Invoice Type"::COPY))
        else
            if RSFiscalizationSetup.Training then
                JObjectHeader.Add('invoiceType', GetEnumValueName(Enum::"NPR RS Invoice Type"::TRAINING))
            else
                JObjectHeader.Add('invoiceType', GetEnumValueName(RSPOSAuditLogAuxInfo."RS Invoice Type"));
        JObjectHeader.Add('transactionType', GetEnumValueName(RSPOSAuditLogAuxInfo."RS Transaction Type"));
        NpRvArchVoucherEntry.SetRange("Entry Type", NpRvArchVoucherEntry."Entry Type"::Payment);
        NpRvArchVoucherEntry.SetRange("Document No.", RSPOSAuditLogAuxInfo."Source Document No.");
        HasArchVoucherEntry := NpRvArchVoucherEntry.FindFirst();
        CalculatePaymentMethods(RSPOSAuditLogAuxInfo, POSEntryPaymentLine, JArray, JObjectLines);
        if RSPOSAuditLogAuxInfo."POS Entry Type" in [RSPOSAuditLogAuxInfo."POS Entry Type"::"Credit Sale"] then begin
            Clear(JObjectLines);
            if POSEntry."Amount Incl. Tax" = 0 then
                POSEntry."Amount Incl. Tax" += 0.01;
            JObjectLines.Add('amount', Round(POSEntry."Amount Incl. Tax", 0.01));
            JObjectLines.Add('paymentType', GetEnumValueName(RSPOSPaymMethMapping."RS Payment Method"::WireTransfer));
            JArray.Add(JObjectLines);
        end;
        JObjectHeader.Add('payment', JArray);
        RSAuditMgt.FillCertificationData(Certification);
        JObjectHeader.Add('invoiceNumber', Certification.Get('ESIRNo'));
        if not HasArchVoucherEntry then
            if IsCopy then begin
                JObjectHeader.Add('referentDocumentNumber', RSPOSAuditLogAuxInfo."Invoice Number");
                JObjectHeader.Add('referentDocumentDT', Format(RSPOSAuditLogAuxInfo."SDC DateTime"));
            end else
                JObjectHeader.Add('referentDocumentNumber', '');
        if IsCopy and HasArchVoucherEntry then
            CreateJsonForVoucherBasedOnReferenceDocument(RSPOSAuditLogAuxInfo, NpRvArchVoucherEntry, RSPOSPaymMethMapping, JObjectHeader)
        else begin
            Clear(JObjectLines);
            JObjectLines.Add('omitQRCodeGen', 1);
            JObjectLines.Add('omitTextualRepresentation', 0);
            JObjectHeader.Add('options', JObjectLines);
            POSEntrySalesLine.SetRange("POS Entry No.", RSPOSAuditLogAuxInfo."POS Entry No.");
            POSEntrySalesLine.SetFilter(Type, '%1|%2', POSEntrySalesLine.Type::Item, POSEntrySalesLine.Type::Voucher);
            if not IsCopy then
                POSEntrySalesLine.SetFilter(Quantity, '>%1', 0);
            Clear(JArray);
            if POSEntrySalesLine.FindSet() then
                repeat
                    Clear(ItemName);
                    Clear(JObjectLines);
                    Clear(JArray2);
                    if not (RSPOSAuditLogAuxInfo."POS Entry Type" in [RSPOSAuditLogAuxInfo."POS Entry Type"::"Credit Sale"]) and
                        RSPOSPaymMethMapping.Find() then
                        if RSPOSPaymMethMapping."RS Payment Method" in [RSPOSPaymMethMapping."RS Payment Method"::Other] then
                            ItemName := OtherPaymentItemPrefixLbl;

                    if RSFiscalizationSetup."Print Item No. on Receipt" then
                        ItemName += POSEntrySalesLine."No." + ',' + POSEntrySalesLine.Description
                    else
                        ItemName += POSEntrySalesLine.Description;

                    if (RSFiscalizationSetup."Print Item Desc. 2 on Receipt") and (StrLen(POSEntrySalesLine."Description 2") > 0) then
                        ItemName += ',' + POSEntrySalesLine."Description 2";

                    JObjectLines.Add('name', ItemName);
                    case POSEntrySalesLine.Type of
                        POSEntrySalesLine.Type::Item:
                            begin
                                POSEntrySalesLine.GetItem(Item);
                                if Item.GTIN <> '' then
                                    JObjectLines.Add('GTIN', Item.GTIN);
                            end;
                    end;
                    JObjectLines.Add('quantity', Abs(POSEntrySalesLine.Quantity));
                    if POSEntrySalesLine."Amount Incl. VAT" = 0 then
                        POSEntrySalesLine."Amount Incl. VAT" += 0.01;
                    JObjectLines.Add('unitPrice', Abs(Round((POSEntrySalesLine."Amount Incl. VAT" / POSEntrySalesLine.Quantity), 0.01)));
                    RSVATPostSetupMapping.Get(POSEntrySalesLine."VAT Bus. Posting Group", POSEntrySalesLine."VAT Prod. Posting Group");
                    RSAllowedTaxRates.Get(RSVATPostSetupMapping."RS Tax Category Name", RSVATPostSetupMapping."RS Tax Category Label");
                    JArray2.Add(RSAllowedTaxRates."Tax Category Rate Label");
                    JObjectLines.Add('labels', JArray2);
                    JObjectLines.Add('totalAmount', Abs(POSEntrySalesLine."Amount Incl. VAT"));
                    JArray.Add(JObjectLines);
                until POSEntrySalesLine.Next() = 0;
            JObjectHeader.Add('items', JArray);
        end;
        JObjectHeader.WriteTo(JsonBodyTxt);
        exit(JsonBodyTxt);
    end;

    local procedure CreateJSONBodyForRSFiscalNormalSale(SalesHeader: Record "Sales Header"; IsCopy: Boolean): Text
    var
        Item: Record Item;
        RSAllowedTaxRates: Record "NPR RS Allowed Tax Rates";
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
        RSPaymentMethodMapping: Record "NPR RS Payment Method Mapping";
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        RSVATPostSetupMapping: Record "NPR RS VAT Post. Setup Mapping";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        SalesLine: Record "Sales Line";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        Certification: Dictionary of [Text, Text];
        JArray: JsonArray;
        JArray2: JsonArray;
        JObjectHeader: JsonObject;
        JObjectLines: JsonObject;
        ItemName: Text;
        JsonBodyTxt: Text;
    begin
        RSFiscalizationSetup.Get();
        JObjectHeader.Add('cashier', SalesHeader."Salesperson Code");
        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(SalesHeader);
        if RSAuxSalesHeader."NPR RS Customer Ident." <> '' then
            JObjectHeader.Add('buyerId', Format(RSAuxSalesHeader."NPR RS Cust. Ident. Type".AsInteger()) + ':' + RSAuxSalesHeader."NPR RS Customer Ident.");
        if RSAuxSalesHeader."NPR RS Add. Cust. Ident." <> '' then
            JObjectHeader.Add('buyerCostCenterId', Format(RSAuxSalesHeader."NPR RS Add. Cust. Ident. Type".AsInteger()) + ':' + RSAuxSalesHeader."NPR RS Add. Cust. Ident.");
        if IsCopy then
            JObjectHeader.Add('invoiceType', GetEnumValueName(Enum::"NPR RS Invoice Type"::COPY))
        else
            if RSFiscalizationSetup.Training then
                JObjectHeader.Add('invoiceType', GetEnumValueName(Enum::"NPR RS Invoice Type"::TRAINING))
            else
                JObjectHeader.Add('invoiceType', GetEnumValueName(Enum::"NPR RS Invoice Type"::PROFORMA));
        if SalesHeader."Document Type" in [SalesHeader."Document Type"::"Credit Memo", SalesHeader."Document Type"::"Return Order"] then
            JObjectHeader.Add('transactionType', GetEnumValueName(Enum::"NPR RS Transaction Type"::REFUND))
        else
            JObjectHeader.Add('transactionType', GetEnumValueName(Enum::"NPR RS Transaction Type"::SALE));
        Clear(JObjectLines);
        if not (RSFiscalizationSetup.Training) and not IsCopy then
            JObjectLines.Add('amount', Format(0.00, 12, '<Precision,2:2><Integer Thousand><Decimals><Comma,,>'))
        else begin
            SalesHeader.CalcFields("Amount Including VAT");
            JObjectLines.Add('amount', SalesHeader."Amount Including VAT")
        end;
        if not IsCopy and not RSFiscalizationSetup.Training and (SalesHeader."Payment Method Code" <> '') then begin
            if RSPaymentMethodMapping.Get(SalesHeader."Payment Method Code") then
                JObjectLines.Add('paymentType', GetEnumValueName(RSPaymentMethodMapping."RS Payment Method"))
            else
                JObjectLines.Add('paymentType', GetEnumValueName(RSPaymentMethodMapping."RS Payment Method"::Other));
        end else
            JObjectLines.Add('paymentType', GetEnumValueName(RSPaymentMethodMapping."RS Payment Method"::Other));
        JArray.Add(JObjectLines);
        JObjectHeader.Add('payment', JArray);
        RSAuditMgt.FillCertificationData(Certification);
        JObjectHeader.Add('invoiceNumber', Certification.Get('ESIRNo'));
        if IsCopy then begin
            RSPOSAuditLogAuxInfo.Get(Enum::"NPR RS Audit Entry Type"::"Sales Header", RSAuxSalesHeader."NPR RS Audit Entry No.");
            JObjectHeader.Add('referentDocumentNumber', RSPOSAuditLogAuxInfo."Invoice Number");
            JObjectHeader.Add('referentDocumentDT', Format(RSPOSAuditLogAuxInfo."SDC DateTime"));
        end else
            JObjectHeader.Add('referentDocumentNumber', '');
        Clear(JObjectLines);
        JObjectLines.Add('omitQRCodeGen', 1);
        JObjectLines.Add('omitTextualRepresentation', 0);
        JObjectHeader.Add('options', JObjectLines);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        Clear(JArray);
        if SalesLine.FindSet() then
            repeat
                Clear(ItemName);
                Clear(JObjectLines);
                Clear(JArray2);

                if RSFiscalizationSetup."Print Item No. on Receipt" then
                    ItemName := SalesLine."No." + ',' + SalesLine.Description
                else
                    ItemName := SalesLine.Description;

                if (RSFiscalizationSetup."Print Item Desc. 2 on Receipt") and (StrLen(SalesLine."Description 2") > 0) then
                    ItemName += ',' + SalesLine."Description 2";

                JObjectLines.Add('name', ItemName);
                SalesLine.GetItem(Item);
                if Item.GTIN <> '' then
                    JObjectLines.Add('GTIN', Item.GTIN);
                JObjectLines.Add('quantity', Abs(SalesLine.Quantity));
                JObjectLines.Add('unitPrice', Abs(Round((SalesLine."Amount Including VAT" / SalesLine.Quantity), 0.01)));
                RSVATPostSetupMapping.Get(SalesLine."VAT Bus. Posting Group", SalesLine."VAT Prod. Posting Group");
                RSAllowedTaxRates.Get(RSVATPostSetupMapping."RS Tax Category Name", RSVATPostSetupMapping."RS Tax Category Label");
                JArray2.Add(RSAllowedTaxRates."Tax Category Rate Label");
                JObjectLines.Add('labels', JArray2);
                JObjectLines.Add('totalAmount', Abs(SalesLine."Amount Including VAT"));
                JArray.Add(JObjectLines);
            until SalesLine.Next() = 0;
        JObjectHeader.Add('items', JArray);
        JObjectHeader.WriteTo(JsonBodyTxt);
        exit(JsonBodyTxt);
    end;

    local procedure CreateJSONBodyForRSFiscalNormalSale(SalesInvoiceHeader: Record "Sales Invoice Header"; IsCopy: Boolean): Text
    var
        Item: Record Item;
        RSAllowedTaxRates: Record "NPR RS Allowed Tax Rates";
        RSAuxSalesInvHeader: Record "NPR RS Aux Sales Inv. Header";
        RSPaymentMethodMapping: Record "NPR RS Payment Method Mapping";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        RSPOSAuditLogAuxInfoReferent: Record "NPR RS POS Audit Log Aux. Info";
        RSVATPostSetupMapping: Record "NPR RS VAT Post. Setup Mapping";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        SalesInvoiceLine: Record "Sales Invoice Line";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        Certification: Dictionary of [Text, Text];
        JArray: JsonArray;
        JArray2: JsonArray;
        JObjectHeader: JsonObject;
        JObjectLines: JsonObject;
        ItemName: Text;
        JsonBodyTxt: Text;
    begin
        RSFiscalizationSetup.Get();
        JObjectHeader.Add('cashier', SalesInvoiceHeader."Salesperson Code");
        RSAuxSalesInvHeader.Get(SalesInvoiceHeader."No.");
        if RSAuxSalesInvHeader."NPR RS Customer Ident." <> '' then
            JObjectHeader.Add('buyerId', Format(RSAuxSalesInvHeader."NPR RS Cust. Ident. Type".AsInteger()) + ':' + RSAuxSalesInvHeader."NPR RS Customer Ident.");
        if RSAuxSalesInvHeader."NPR RS Add. Cust. Ident." <> '' then
            JObjectHeader.Add('buyerCostCenterId', Format(RSAuxSalesInvHeader."NPR RS Add. Cust. Ident. Type".AsInteger()) + ':' + RSAuxSalesInvHeader."NPR RS Add. Cust. Ident.");
        if IsCopy then
            JObjectHeader.Add('invoiceType', GetEnumValueName(Enum::"NPR RS Invoice Type"::COPY))
        else
            if RSFiscalizationSetup.Training then
                JObjectHeader.Add('invoiceType', GetEnumValueName(Enum::"NPR RS Invoice Type"::TRAINING))
            else
                JObjectHeader.Add('invoiceType', GetEnumValueName(Enum::"NPR RS Invoice Type"::NORMAL));
        JObjectHeader.Add('transactionType', GetEnumValueName(Enum::"NPR RS Transaction Type"::SALE));
        Clear(JObjectLines);
        SalesInvoiceHeader.CalcFields("Amount Including VAT");
        JObjectLines.Add('amount', Round(SalesInvoiceHeader."Amount Including VAT", 0.01));
        if RSPaymentMethodMapping.Get(SalesInvoiceHeader."Payment Method Code") then
            JObjectLines.Add('paymentType', GetEnumValueName(RSPaymentMethodMapping."RS Payment Method"))
        else
            JObjectLines.Add('paymentType', GetEnumValueName(RSPaymentMethodMapping."RS Payment Method"::Other));
        JArray.Add(JObjectLines);
        JObjectHeader.Add('payment', JArray);
        RSAuditMgt.FillCertificationData(Certification);
        JObjectHeader.Add('invoiceNumber', Certification.Get('ESIRNo'));
        if IsCopy then begin
            RSPOSAuditLogAuxInfo.Get(Enum::"NPR RS Audit Entry Type"::"Sales Invoice Header", RSAuxSalesInvHeader."NPR RS Audit Entry No.");
            JObjectHeader.Add('referentDocumentNumber', RSPOSAuditLogAuxInfo."Invoice Number");
            JObjectHeader.Add('referentDocumentDT', Format(RSPOSAuditLogAuxInfo."SDC DateTime"));
        end else begin
            SalesCrMemoHeader.SetRange("Prepayment Order No.", SalesInvoiceHeader."Order No.");
            if SalesCrMemoHeader.FindLast() then begin
                RSPOSAuditLogAuxInfoReferent.SetRange("RS Invoice Type", RSPOSAuditLogAuxInfoReferent."RS Invoice Type"::ADVANCE);
                RSPOSAuditLogAuxInfoReferent.SetRange("RS Transaction Type", RSPOSAuditLogAuxInfoReferent."RS Transaction Type"::REFUND);
                RSPOSAuditLogAuxInfoReferent.SetRange("Source Document No.", SalesCrMemoHeader."No.");
                if RSPOSAuditLogAuxInfoReferent.FindFirst() then begin
                    JObjectHeader.Add('referentDocumentNumber', RSPOSAuditLogAuxInfoReferent."Invoice Number");
                    JObjectHeader.Add('referentDocumentDT', Format(RSPOSAuditLogAuxInfoReferent."SDC DateTime"));
                end else
                    JObjectHeader.Add('referentDocumentNumber', '');
                SalesInvoiceHeader.CalcFields("Amount Including VAT");
                JObjectLines.Add('amount', SalesInvoiceHeader."Amount Including VAT" - RSPOSAuditLogAuxInfoReferent."Total Amount");
            end else
                JObjectHeader.Add('referentDocumentNumber', '');
        end;
        Clear(JObjectLines);
        JObjectLines.Add('omitQRCodeGen', 1);
        JObjectLines.Add('omitTextualRepresentation', 0);
        JObjectHeader.Add('options', JObjectLines);
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        Clear(JArray);
        if SalesInvoiceLine.FindSet() then
            repeat
                Clear(ItemName);
                Clear(JObjectLines);
                Clear(JArray2);
                if RSPaymentMethodMapping.Get(SalesInvoiceHeader."Payment Method Code") then begin
                    if RSPaymentMethodMapping."RS Payment Method" in [RSPaymentMethodMapping."RS Payment Method"::Other] then
                        ItemName := OtherPaymentItemPrefixLbl;
                end else
                    ItemName := OtherPaymentItemPrefixLbl;

                if RSFiscalizationSetup."Print Item No. on Receipt" then
                    ItemName += SalesInvoiceLine."No." + ',' + SalesInvoiceLine.Description
                else
                    ItemName += SalesInvoiceLine.Description;

                if (RSFiscalizationSetup."Print Item Desc. 2 on Receipt") and (StrLen(SalesInvoiceLine."Description 2") > 0) then
                    ItemName += ',' + SalesInvoiceLine."Description 2";

                JObjectLines.Add('name', ItemName);
                Item.Get(SalesInvoiceLine."No.");
                if Item.GTIN <> '' then
                    JObjectLines.Add('GTIN', Item.GTIN);
                JObjectLines.Add('quantity', Abs(SalesInvoiceLine.Quantity));
                JObjectLines.Add('unitPrice', Abs(Round((SalesInvoiceLine."Amount Including VAT" / SalesInvoiceLine.Quantity), 0.01)));
                RSVATPostSetupMapping.Get(SalesInvoiceLine."VAT Bus. Posting Group", SalesInvoiceLine."VAT Prod. Posting Group");
                RSAllowedTaxRates.Get(RSVATPostSetupMapping."RS Tax Category Name", RSVATPostSetupMapping."RS Tax Category Label");
                JArray2.Add(RSAllowedTaxRates."Tax Category Rate Label");
                JObjectLines.Add('labels', JArray2);
                JObjectLines.Add('totalAmount', Abs(SalesInvoiceLine."Amount Including VAT"));
                JArray.Add(JObjectLines);
            until SalesInvoiceLine.Next() = 0;
        JObjectHeader.Add('items', JArray);
        JObjectHeader.WriteTo(JsonBodyTxt);
        exit(JsonBodyTxt);
    end;

    local procedure CreateJSONBodyForRSFiscalAdvanceRefund(SalesInvoiceHeader: Record "Sales Invoice Header"; IsCopy: Boolean): Text
    var
        RSAllowedTaxRates: Record "NPR RS Allowed Tax Rates";
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        RSPOSAuditLogAuxInfoReferent: Record "NPR RS POS Audit Log Aux. Info";
        RSAuxSalesInvHeader: Record "NPR RS Aux Sales Inv. Header";
        RSPaymentMethodMapping: Record "NPR RS Payment Method Mapping";
        RSVATPostSetupMapping: Record "NPR RS VAT Post. Setup Mapping";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        SalesInvoiceLine: Record "Sales Invoice Line";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        Certification: Dictionary of [Text, Text];
        PrepaymentAmount: Decimal;
        JArray: JsonArray;
        JArray2: JsonArray;
        JObjectHeader: JsonObject;
        JObjectLines: JsonObject;
        ItemName: Text;
        JsonBodyTxt: Text;
    begin
        RSFiscalizationSetup.Get();
        JObjectHeader.Add('cashier', SalesInvoiceHeader."Salesperson Code");
        RSAuxSalesInvHeader.ReadRSAuxSalesInvHeaderFields(SalesInvoiceHeader);
        if RSAuxSalesInvHeader."NPR RS Customer Ident." <> '' then
            JObjectHeader.Add('buyerId', Format(RSAuxSalesInvHeader."NPR RS Cust. Ident. Type".AsInteger()) + ':' + RSAuxSalesInvHeader."NPR RS Customer Ident.");
        if RSAuxSalesInvHeader."NPR RS Add. Cust. Ident." <> '' then
            JObjectHeader.Add('buyerCostCenterId', Format(RSAuxSalesInvHeader."NPR RS Add. Cust. Ident. Type".AsInteger()) + ':' + RSAuxSalesInvHeader."NPR RS Add. Cust. Ident.");
        if IsCopy then
            JObjectHeader.Add('invoiceType', GetEnumValueName(Enum::"NPR RS Invoice Type"::COPY))
        else
            if RSFiscalizationSetup.Training then
                JObjectHeader.Add('invoiceType', GetEnumValueName(Enum::"NPR RS Invoice Type"::TRAINING))
            else
                JObjectHeader.Add('invoiceType', GetEnumValueName(Enum::"NPR RS Invoice Type"::ADVANCE));
        JObjectHeader.Add('transactionType', GetEnumValueName(Enum::"NPR RS Transaction Type"::REFUND));
        Clear(JObjectLines);
        RSPOSAuditLogAuxInfoReferent.SetRange("RS Invoice Type", RSPOSAuditLogAuxInfoReferent."RS Invoice Type"::ADVANCE);
        RSPOSAuditLogAuxInfoReferent.SetRange("RS Transaction Type", RSPOSAuditLogAuxInfoReferent."RS Transaction Type"::SALE);
        RSPOSAuditLogAuxInfoReferent.SetRange("Prepayment Order No.", SalesInvoiceHeader."Order No.");
        RSPOSAuditLogAuxInfoReferent.SetFilter(Signature, '<>%1', '');
        RSPOSAuditLogAuxInfoReferent.FindSet();
        repeat
            PrepaymentAmount += RSPOSAuditLogAuxInfoReferent."Total Amount";
        until RSPOSAuditLogAuxInfoReferent.Next() = 0;
        JObjectLines.Add('amount', Round(PrepaymentAmount, 0.01));
        if RSPaymentMethodMapping.Get(RSPOSAuditLogAuxInfoReferent."Payment Method Code") then
            JObjectLines.Add('paymentType', GetEnumValueName(RSPaymentMethodMapping."RS Payment Method"))
        else
            JObjectLines.Add('paymentType', GetEnumValueName(RSPaymentMethodMapping."RS Payment Method"::Other));
        JArray.Add(JObjectLines);
        JObjectHeader.Add('payment', JArray);
        RSAuditMgt.FillCertificationData(Certification);
        JObjectHeader.Add('invoiceNumber', Certification.Get('ESIRNo'));
        if IsCopy then begin
            RSPOSAuditLogAuxInfo.Get(Enum::"NPR RS Audit Entry Type"::"Sales Invoice Header", RSAuxSalesInvHeader."NPR RS Audit Entry No.");
            JObjectHeader.Add('referentDocumentNumber', RSPOSAuditLogAuxInfo."Invoice Number");
            JObjectHeader.Add('referentDocumentDT', Format(RSPOSAuditLogAuxInfo."SDC DateTime"));
        end else begin
            Clear(RSPOSAuditLogAuxInfoReferent);
            RSPOSAuditLogAuxInfoReferent.SetRange("RS Invoice Type", RSPOSAuditLogAuxInfoReferent."RS Invoice Type"::ADVANCE);
            RSPOSAuditLogAuxInfoReferent.SetRange("RS Transaction Type", RSPOSAuditLogAuxInfoReferent."RS Transaction Type"::SALE);
            RSPOSAuditLogAuxInfoReferent.SetRange("Prepayment Order No.", SalesInvoiceHeader."Order No.");
            RSPOSAuditLogAuxInfoReferent.SetFilter(Signature, '<>%1', '');
            if RSPOSAuditLogAuxInfoReferent.FindLast() then begin
                JObjectHeader.Add('referentDocumentNumber', RSPOSAuditLogAuxInfoReferent."Invoice Number");
                JObjectHeader.Add('referentDocumentDT', Format(RSPOSAuditLogAuxInfoReferent."SDC DateTime"));
            end else
                JObjectHeader.Add('referentDocumentNumber', '');
        end;
        Clear(JObjectLines);
        JObjectLines.Add('omitQRCodeGen', 1);
        JObjectLines.Add('omitTextualRepresentation', 0);
        JObjectHeader.Add('options', JObjectLines);
        SalesInvoiceLine.SetRange("Document No.", RSPOSAuditLogAuxInfoReferent."Source Document No.");
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::"G/L Account");
        Clear(JArray);
        if SalesInvoiceLine.FindSet() then
            repeat
                Clear(ItemName);
                Clear(JObjectLines);
                Clear(JArray2);
                ItemName := CustomerVATRegNoRSLabel;

                if RSFiscalizationSetup."Print Item No. on Receipt" then
                    ItemName += SalesInvoiceLine."No." + ',' + SalesInvoiceLine.Description
                else
                    ItemName += SalesInvoiceLine.Description;

                if (RSFiscalizationSetup."Print Item Desc. 2 on Receipt") and (StrLen(SalesInvoiceLine."Description 2") > 0) then
                    ItemName += ',' + SalesInvoiceLine."Description 2";

                JObjectLines.Add('name', ItemName);
                JObjectLines.Add('quantity', Abs(SalesInvoiceLine.Quantity));
                JObjectLines.Add('unitPrice', Abs(Round((GetSumAmountOfPrepaymentSales(SalesInvoiceLine) / SalesInvoiceLine.Quantity), 0.01)));
                RSVATPostSetupMapping.Get(SalesInvoiceLine."VAT Bus. Posting Group", SalesInvoiceLine."VAT Prod. Posting Group");
                RSAllowedTaxRates.Get(RSVATPostSetupMapping."RS Tax Category Name", RSVATPostSetupMapping."RS Tax Category Label");
                JArray2.Add(RSAllowedTaxRates."Tax Category Rate Label");
                JObjectLines.Add('labels', JArray2);
                JObjectLines.Add('totalAmount', Abs(GetSumAmountOfPrepaymentSales(SalesInvoiceLine)));
                JArray.Add(JObjectLines);
            until SalesInvoiceLine.Next() = 0;
        JObjectHeader.Add('items', JArray);
        JObjectHeader.WriteTo(JsonBodyTxt);
        exit(JsonBodyTxt);
    end;

    local procedure CreateJSONBodyForRSFiscalAdvanceSale(var RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info"; SalesInvoiceHeader: Record "Sales Invoice Header"; SalesHeader: Record "Sales Header"; IsCopy: Boolean): Text
    var
        RSAllowedTaxRates: Record "NPR RS Allowed Tax Rates";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
        POSEntry: Record "NPR POS Entry";
        RSPOSAuditLogAuxInfoReferent: Record "NPR RS POS Audit Log Aux. Info";
        RSPaymentMethodMapping: Record "NPR RS Payment Method Mapping";
        RSVATPostSetupMapping: Record "NPR RS VAT Post. Setup Mapping";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        SalesInvoiceLine: Record "Sales Invoice Line";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        Certification: Dictionary of [Text, Text];
        JArray: JsonArray;
        JArray2: JsonArray;
        JObjectHeader: JsonObject;
        JObjectLines: JsonObject;
        ItemName: Text;
        JsonBodyTxt: Text;
    begin
        RSFiscalizationSetup.Get();
        if RSPaymentMethodMapping.Get(SalesInvoiceHeader."Payment Method Code") then
            if (RSPaymentMethodMapping."RS Payment Method" in [RSPaymentMethodMapping."RS Payment Method"::WireTransfer]) and (SalesHeader."Order Date" <> Today()) then
                JObjectHeader.Add('dateAndTimeOfIssue', PadStr(Format(SalesHeader."Order Date", 0, '<Year4>-<Month,2>-<Day,2>') + 'T' + '13:42:53Z', 20));// Format(Time(), 0, '<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>') + 'Z', 20));
        JObjectHeader.Add('cashier', SalesInvoiceHeader."Salesperson Code");
        RSAuxSalesHeader.Get(SalesHeader.SystemId);
        if RSAuxSalesHeader."NPR RS Customer Ident." <> '' then
            JObjectHeader.Add('buyerId', Format(RSAuxSalesHeader."NPR RS Cust. Ident. Type".AsInteger()) + ':' + RSAuxSalesHeader."NPR RS Customer Ident.");
        if RSAuxSalesHeader."NPR RS Add. Cust. Ident." <> '' then
            JObjectHeader.Add('buyerCostCenterId', Format(RSAuxSalesHeader."NPR RS Add. Cust. Ident. Type".AsInteger()) + ':' + RSAuxSalesHeader."NPR RS Add. Cust. Ident.");
        if IsCopy then
            JObjectHeader.Add('invoiceType', GetEnumValueName(Enum::"NPR RS Invoice Type"::COPY))
        else
            if RSFiscalizationSetup.Training then
                JObjectHeader.Add('invoiceType', GetEnumValueName(Enum::"NPR RS Invoice Type"::TRAINING))
            else
                JObjectHeader.Add('invoiceType', GetEnumValueName(Enum::"NPR RS Invoice Type"::ADVANCE));
        JObjectHeader.Add('transactionType', GetEnumValueName(Enum::"NPR RS Transaction Type"::SALE));
        Clear(JObjectLines);
        SalesInvoiceHeader.CalcFields("Amount Including VAT");
        JObjectLines.Add('amount', SalesInvoiceHeader."Amount Including VAT");
        CalculatePaymentMethods(RSPOSAuditLogAuxInfo, POSEntryPaymentLine, JArray, JObjectLines);
        if RSPOSAuditLogAuxInfo."POS Entry Type" in [RSPOSAuditLogAuxInfo."POS Entry Type"::"Credit Sale"] then begin
            Clear(JObjectLines);
            POSEntry.Get(RSPOSAuditLogAuxInfo."POS Entry No.");
            if POSEntry."Amount Incl. Tax" = 0 then
                POSEntry."Amount Incl. Tax" += 0.01;
            JObjectLines.Add('amount', Round(POSEntry."Amount Incl. Tax", 0.01));
            JObjectLines.Add('paymentType', GetEnumValueName(RSPaymentMethodMapping."RS Payment Method"::WireTransfer));
            JArray.Add(JObjectLines);
        end else begin
            Clear(JObjectLines);
            SalesInvoiceHeader.CalcFields("Amount Including VAT");
            JObjectLines.Add('amount', Round(SalesInvoiceHeader."Amount Including VAT", 0.01));
            if RSPaymentMethodMapping.Get(SalesInvoiceHeader."Payment Method Code") then begin
                JObjectLines.Add('paymentType', GetEnumValueName(RSPaymentMethodMapping."RS Payment Method"));
                RSPOSAuditLogAuxInfo."Payment Method Code" := SalesInvoiceHeader."Payment Method Code";
            end else
                JObjectLines.Add('paymentType', GetEnumValueName(RSPaymentMethodMapping."RS Payment Method"::Other));
            JArray.Add(JObjectLines);
        end;
        JObjectHeader.Add('payment', JArray);
        RSAuditMgt.FillCertificationData(Certification);
        JObjectHeader.Add('invoiceNumber', Certification.Get('ESIRNo'));
        if IsCopy then begin
            RSPOSAuditLogAuxInfo.Get(Enum::"NPR RS Audit Entry Type"::"Sales Invoice Header", RSAuxSalesHeader."NPR RS Audit Entry No.");
            JObjectHeader.Add('referentDocumentNumber', RSPOSAuditLogAuxInfo."Invoice Number");
            JObjectHeader.Add('referentDocumentDT', Format(RSPOSAuditLogAuxInfo."SDC DateTime"));
        end else begin
            RSPOSAuditLogAuxInfoReferent.SetRange("RS Invoice Type", RSPOSAuditLogAuxInfoReferent."RS Invoice Type"::ADVANCE);
            RSPOSAuditLogAuxInfoReferent.SetRange("RS Transaction Type", RSPOSAuditLogAuxInfoReferent."RS Transaction Type"::SALE);
            RSPOSAuditLogAuxInfoReferent.SetRange("Prepayment Order No.", SalesInvoiceHeader."Prepayment Order No.");
            RSPOSAuditLogAuxInfoReferent.SetFilter(Signature, '<>%1', '');
            if RSPOSAuditLogAuxInfoReferent.FindLast() then begin
                JObjectHeader.Add('referentDocumentNumber', RSPOSAuditLogAuxInfoReferent."Invoice Number");
                JObjectHeader.Add('referentDocumentDT', Format(RSPOSAuditLogAuxInfoReferent."SDC DateTime"));
            end else
                JObjectHeader.Add('referentDocumentNumber', '');
        end;
        Clear(JObjectLines);
        JObjectLines.Add('omitQRCodeGen', 1);
        JObjectLines.Add('omitTextualRepresentation', 0);
        JObjectHeader.Add('options', JObjectLines);
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::"G/L Account");
        Clear(JArray);
        if SalesInvoiceLine.FindSet() then
            repeat
                Clear(ItemName);
                Clear(JObjectLines);
                Clear(JArray2);
                ItemName := CustomerVATRegNoRSLabel;

                if RSFiscalizationSetup."Print Item No. on Receipt" then
                    ItemName += SalesInvoiceLine."No." + ',' + SalesInvoiceLine.Description
                else
                    ItemName += SalesInvoiceLine.Description;

                if (RSFiscalizationSetup."Print Item Desc. 2 on Receipt") and (StrLen(SalesInvoiceLine."Description 2") > 0) then
                    ItemName += ',' + SalesInvoiceLine."Description 2";

                JObjectLines.Add('name', ItemName);
                JObjectLines.Add('quantity', Abs(SalesInvoiceLine.Quantity));
                JObjectLines.Add('unitPrice', Abs(Round((SalesInvoiceLine."Amount Including VAT" / SalesInvoiceLine.Quantity), 0.01)));
                RSVATPostSetupMapping.Get(SalesInvoiceLine."VAT Bus. Posting Group", SalesInvoiceLine."VAT Prod. Posting Group");
                RSAllowedTaxRates.Get(RSVATPostSetupMapping."RS Tax Category Name", RSVATPostSetupMapping."RS Tax Category Label");
                JArray2.Add(RSAllowedTaxRates."Tax Category Rate Label");
                JObjectLines.Add('labels', JArray2);
                JObjectLines.Add('totalAmount', Abs(SalesInvoiceLine."Amount Including VAT"));
                JArray.Add(JObjectLines);
            until SalesInvoiceLine.Next() = 0;
        JObjectHeader.Add('items', JArray);
        JObjectHeader.WriteTo(JsonBodyTxt);
        exit(JsonBodyTxt);
    end;

    local procedure CreateJSONBodyForRSFiscalNormalRefund(RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info"): Text
    var
        Item: Record Item;
        NpRvArchVoucherEntry: Record "NPR NpRv Arch. Voucher Entry";
        POSEntry: Record "NPR POS Entry";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        RSAllowedTaxRates: Record "NPR RS Allowed Tax Rates";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSPOSAuditLogAuxInfoReferent: Record "NPR RS POS Audit Log Aux. Info";
        RSPOSPaymMethMapping: Record "NPR RS POS Paym. Meth. Mapping";
        RSVATPostSetupMapping: Record "NPR RS VAT Post. Setup Mapping";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        HasArchVoucherEntry: Boolean;
        Certification: Dictionary of [Text, Text];
        OrigPOSEntry: Guid;
        JArray: JsonArray;
        JArray2: JsonArray;
        JObjectHeader: JsonObject;
        JObjectLines: JsonObject;
        ItemName: Text;
        JsonBodyTxt: Text;
    begin
        RSFiscalizationSetup.Get();
        POSEntry.Get(RSPOSAuditLogAuxInfo."POS Entry No.");
        JObjectHeader.Add('cashier', POSEntry."Salesperson Code");
        if RSPOSAuditLogAuxInfo."Customer Identification" <> '' then
            if StrLen(RSPOSAuditLogAuxInfo."Customer Identification") > 3 then
                JObjectHeader.Add('buyerId', RSPOSAuditLogAuxInfo."Customer Identification");
        if RSPOSAuditLogAuxInfo."Additional Customer Field" <> '' then
            JObjectHeader.Add('buyerCostCenterId', RSPOSAuditLogAuxInfo."Additional Customer Field");
        if RSFiscalizationSetup.Training then
            JObjectHeader.Add('invoiceType', GetEnumValueName(RSPOSAuditLogAuxInfo."RS Invoice Type"::TRAINING))
        else
            JObjectHeader.Add('invoiceType', GetEnumValueName(RSPOSAuditLogAuxInfo."RS Invoice Type"));
        JObjectHeader.Add('transactionType', GetEnumValueName(RSPOSAuditLogAuxInfo."RS Transaction Type"));
        NpRvArchVoucherEntry.SetRange("Entry Type", NpRvArchVoucherEntry."Entry Type"::Payment);
        NpRvArchVoucherEntry.SetRange("Document No.", RSPOSAuditLogAuxInfo."Source Document No.");
        HasArchVoucherEntry := NpRvArchVoucherEntry.FindFirst();
        if HasArchVoucherEntry then
            POSEntryPaymentLine.SetFilter(Amount, '<%1', 0);
        CalculatePaymentMethods(RSPOSAuditLogAuxInfo, POSEntryPaymentLine, JArray, JObjectLines);
        if RSPOSAuditLogAuxInfo."POS Entry Type" in [RSPOSAuditLogAuxInfo."POS Entry Type"::"Credit Sale"] then begin
            Clear(JObjectLines);
            if POSEntry."Amount Incl. Tax" = 0 then
                POSEntry."Amount Incl. Tax" += 0.01;
            JObjectLines.Add('amount', Round(POSEntry."Amount Incl. Tax", 0.01));
            JObjectLines.Add('paymentType', GetEnumValueName(RSPOSPaymMethMapping."RS Payment Method"::WireTransfer));
            JArray.Add(JObjectLines);
        end;
        JObjectHeader.Add('payment', JArray);
        RSAuditMgt.FillCertificationData(Certification);
        JObjectHeader.Add('invoiceNumber', Certification.Get('ESIRNo'));
        if HasArchVoucherEntry then
            CreateJsonForVoucherBasedOnReferenceDocument(RSPOSAuditLogAuxInfo, NpRvArchVoucherEntry, RSPOSPaymMethMapping, JObjectHeader)
        else begin
            if (RSPOSAuditLogAuxInfo."Return Reference No." <> '') and (RSPOSAuditLogAuxInfo."Return Reference Date/Time" <> '') then begin
                JObjectHeader.Add('referentDocumentNumber', RSPOSAuditLogAuxInfo."Return Reference No.");
                JObjectHeader.Add('referentDocumentDT', RSPOSAuditLogAuxInfo."Return Reference Date/Time");
            end
            else begin
                POSEntrySalesLine.SetRange("POS Entry No.", RSPOSAuditLogAuxInfo."POS Entry No.");
                POSEntrySalesLine.FindFirst();
                OrigPOSEntry := POSEntrySalesLine."Orig.POS Entry S.Line SystemId";
                POSEntrySalesLine.Reset();
                POSEntrySalesLine.SetRange(SystemId, OrigPOSEntry);
                POSEntrySalesLine.FindFirst();
                RSPOSAuditLogAuxInfoReferent.GetAuditFromPOSEntry(POSEntrySalesLine."POS Entry No.");
                JObjectHeader.Add('referentDocumentNumber', RSPOSAuditLogAuxInfoReferent."Invoice Number");
                JObjectHeader.Add('referentDocumentDT', RSPOSAuditLogAuxInfoReferent."SDC DateTime");
            end;
            Clear(JObjectLines);
            JObjectLines.Add('omitQRCodeGen', 1);
            JObjectLines.Add('omitTextualRepresentation', 0);
            JObjectHeader.Add('options', JObjectLines);
            POSEntrySalesLine.Reset();
            POSEntrySalesLine.SetRange("POS Entry No.", RSPOSAuditLogAuxInfo."POS Entry No.");
            POSEntrySalesLine.SetFilter(Type, '%1|%2', POSEntrySalesLine.Type::Item, POSEntrySalesLine.Type::Voucher);
            Clear(JArray);
            if POSEntrySalesLine.FindSet() then
                repeat
                    Clear(ItemName);
                    Clear(JObjectLines);
                    Clear(JArray2);
                    if not (RSPOSAuditLogAuxInfo."POS Entry Type" in [RSPOSAuditLogAuxInfo."POS Entry Type"::"Credit Sale"]) and
                        RSPOSPaymMethMapping.Find() then
                        if RSPOSPaymMethMapping."RS Payment Method" in [RSPOSPaymMethMapping."RS Payment Method"::Other] then
                            ItemName := OtherPaymentItemPrefixLbl;

                    if RSFiscalizationSetup."Print Item No. on Receipt" then
                        ItemName += POSEntrySalesLine."No." + ',' + POSEntrySalesLine.Description
                    else
                        ItemName += POSEntrySalesLine.Description;

                    if (RSFiscalizationSetup."Print Item Desc. 2 on Receipt") and (StrLen(POSEntrySalesLine."Description 2") > 0) then
                        ItemName += ',' + POSEntrySalesLine."Description 2";

                    JObjectLines.Add('name', ItemName);
                    case POSEntrySalesLine.Type of
                        POSEntrySalesLine.Type::Item:
                            begin
                                POSEntrySalesLine.GetItem(Item);
                                if Item.GTIN <> '' then
                                    JObjectLines.Add('GTIN', Item.GTIN);
                            end;
                    end;
                    JObjectLines.Add('quantity', Abs(POSEntrySalesLine.Quantity));
                    if POSEntrySalesLine."Amount Incl. VAT" = 0 then
                        POSEntrySalesLine."Amount Incl. VAT" += 0.01;
                    JObjectLines.Add('unitPrice', Abs(Round((POSEntrySalesLine."Amount Incl. VAT" / POSEntrySalesLine.Quantity), 0.01)));
                    RSVATPostSetupMapping.Get(POSEntrySalesLine."VAT Bus. Posting Group", POSEntrySalesLine."VAT Prod. Posting Group");
                    RSAllowedTaxRates.Get(RSVATPostSetupMapping."RS Tax Category Name", RSVATPostSetupMapping."RS Tax Category Label");
                    JArray2.Add(RSAllowedTaxRates."Tax Category Rate Label");
                    JObjectLines.Add('labels', JArray2);
                    JObjectLines.Add('totalAmount', Abs(POSEntrySalesLine."Amount Incl. VAT"));
                    JArray.Add(JObjectLines);
                until POSEntrySalesLine.Next() = 0;
            JObjectHeader.Add('items', JArray);
        end;
        JObjectHeader.WriteTo(JsonBodyTxt);
        exit(JsonBodyTxt);
    end;

    local procedure CreateJSONBodyForRSFiscalNormalRefund(SalesHeader: Record "Sales Header"): Text
    var
        Item: Record Item;
        RSAllowedTaxRates: Record "NPR RS Allowed Tax Rates";
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSPaymentMethodMapping: Record "NPR RS Payment Method Mapping";
        RSPOSAuditLogAuxInfoReferent: Record "NPR RS POS Audit Log Aux. Info";
        RSVATPostSetupMapping: Record "NPR RS VAT Post. Setup Mapping";
        SalesLine: Record "Sales Line";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        Certification: Dictionary of [Text, Text];
        JArray: JsonArray;
        JArray2: JsonArray;
        JObjectHeader: JsonObject;
        JObjectLines: JsonObject;
        ItemName: Text;
        JsonBodyTxt: Text;
    begin
        RSFiscalizationSetup.Get();
        JObjectHeader.Add('cashier', SalesHeader."Salesperson Code");
        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(SalesHeader);
        if RSAuxSalesHeader."NPR RS Customer Ident." <> '' then
            JObjectHeader.Add('buyerId', Format(RSAuxSalesHeader."NPR RS Cust. Ident. Type".AsInteger()) + ':' + RSAuxSalesHeader."NPR RS Customer Ident.");
        if RSAuxSalesHeader."NPR RS Add. Cust. Ident." <> '' then
            JObjectHeader.Add('buyerCostCenterId', Format(RSAuxSalesHeader."NPR RS Add. Cust. Ident. Type".AsInteger()) + ':' + RSAuxSalesHeader."NPR RS Add. Cust. Ident.");
        if RSFiscalizationSetup.Training then
            JObjectHeader.Add('invoiceType', GetEnumValueName(Enum::"NPR RS Invoice Type"::TRAINING))
        else
            JObjectHeader.Add('invoiceType', GetEnumValueName(Enum::"NPR RS Invoice Type"::PROFORMA));
        JObjectHeader.Add('transactionType', GetEnumValueName(Enum::"NPR RS Transaction Type"::REFUND));
        Clear(JObjectLines);
        SalesHeader.CalcFields("Amount Including VAT");
        JObjectLines.Add('amount', '0,00');
        if not RSFiscalizationSetup.Training and (SalesHeader."Payment Method Code" <> '') then begin
            if RSPaymentMethodMapping.Get(SalesHeader."Payment Method Code") then
                JObjectLines.Add('paymentType', GetEnumValueName(RSPaymentMethodMapping."RS Payment Method"))
            else
                JObjectLines.Add('paymentType', GetEnumValueName(RSPaymentMethodMapping."RS Payment Method"::Other));
        end else
            JObjectLines.Add('paymentType', GetEnumValueName(RSPaymentMethodMapping."RS Payment Method"::Other));
        JArray.Add(JObjectLines);
        JObjectHeader.Add('payment', JArray);
        RSAuditMgt.FillCertificationData(Certification);
        JObjectHeader.Add('invoiceNumber', Certification.Get('ESIRNo'));
        RSPOSAuditLogAuxInfoReferent.SetRange("Audit Entry Type", RSPOSAuditLogAuxInfoReferent."Audit Entry Type"::"Sales Header");
        RSPOSAuditLogAuxInfoReferent.SetRange("Source Document Type", SalesHeader."Document Type");
        RSPOSAuditLogAuxInfoReferent.SetRange("Source Document No.", SalesHeader."No.");
        RSPOSAuditLogAuxInfoReferent.FindLast();

        JObjectHeader.Add('referentDocumentNumber', RSPOSAuditLogAuxInfoReferent."Invoice Number");
        JObjectHeader.Add('referentDocumentDT', RSPOSAuditLogAuxInfoReferent."SDC DateTime");
        Clear(JObjectLines);
        JObjectLines.Add('omitQRCodeGen', 1);
        JObjectLines.Add('omitTextualRepresentation', 0);
        JObjectHeader.Add('options', JObjectLines);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        Clear(JArray);
        if SalesLine.FindSet() then
            repeat
                Clear(ItemName);
                Clear(JObjectLines);
                Clear(JArray2);

                if RSFiscalizationSetup."Print Item No. on Receipt" then
                    ItemName := SalesLine."No." + ',' + SalesLine.Description
                else
                    ItemName := SalesLine.Description;

                if (RSFiscalizationSetup."Print Item Desc. 2 on Receipt") and (StrLen(SalesLine."Description 2") > 0) then
                    ItemName += ',' + SalesLine."Description 2";

                JObjectLines.Add('name', ItemName);
                SalesLine.GetItem(Item);
                if Item.GTIN <> '' then
                    JObjectLines.Add('GTIN', Item.GTIN);
                JObjectLines.Add('quantity', Abs(SalesLine.Quantity));
                JObjectLines.Add('unitPrice', Abs(Round((SalesLine."Amount Including VAT" / SalesLine.Quantity), 0.01)));
                RSVATPostSetupMapping.Get(SalesLine."VAT Bus. Posting Group", SalesLine."VAT Prod. Posting Group");
                RSAllowedTaxRates.Get(RSVATPostSetupMapping."RS Tax Category Name", RSVATPostSetupMapping."RS Tax Category Label");
                JArray2.Add(RSAllowedTaxRates."Tax Category Rate Label");
                JObjectLines.Add('labels', JArray2);
                JObjectLines.Add('totalAmount', Abs(SalesLine."Amount Including VAT"));
                JArray.Add(JObjectLines);
            until SalesLine.Next() = 0;
        JObjectHeader.Add('items', JArray);
        JObjectHeader.WriteTo(JsonBodyTxt);
        exit(JsonBodyTxt);
    end;

    local procedure CreateJSONBodyForRSFiscalNormalRefund(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; IsCopy: Boolean): Text
    var
        Item: Record Item;
        RSAllowedTaxRates: Record "NPR RS Allowed Tax Rates";
        RSAuxSalesCrMemoHeader: Record "NPR RS Aux Sales CrMemo Header";
        RSPaymentMethodMapping: Record "NPR RS Payment Method Mapping";
        RSPOSAuditLogAuxInfoReferent: Record "NPR RS POS Audit Log Aux. Info";
        RSVATPostSetupMapping: Record "NPR RS VAT Post. Setup Mapping";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        Certification: Dictionary of [Text, Text];
        JArray: JsonArray;
        JArray2: JsonArray;
        JObjectHeader: JsonObject;
        JObjectLines: JsonObject;
        ItemName: Text;
        JsonBodyTxt: Text;
    begin
        RSFiscalizationSetup.Get();
        JObjectHeader.Add('cashier', SalesCrMemoHeader."Salesperson Code");
        RSAuxSalesCrMemoHeader.ReadRSAuxSalesCrMemoHeaderFields(SalesCrMemoHeader);
        if RSAuxSalesCrMemoHeader."NPR RS Customer Ident." <> '' then
            JObjectHeader.Add('buyerId', Format(RSAuxSalesCrMemoHeader."NPR RS Cust. Ident. Type".AsInteger()) + ':' + RSAuxSalesCrMemoHeader."NPR RS Customer Ident.");
        if RSAuxSalesCrMemoHeader."NPR RS Add. Cust. Ident." <> '' then
            JObjectHeader.Add('buyerCostCenterId', Format(RSAuxSalesCrMemoHeader."NPR RS Add. Cust. Ident. Type".AsInteger()) + ':' + RSAuxSalesCrMemoHeader."NPR RS Add. Cust. Ident.");
        if IsCopy then
            JObjectHeader.Add('invoiceType', GetEnumValueName(Enum::"NPR RS Invoice Type"::COPY))
        else
            if RSFiscalizationSetup.Training then
                JObjectHeader.Add('invoiceType', GetEnumValueName(Enum::"NPR RS Invoice Type"::TRAINING))
            else
                JObjectHeader.Add('invoiceType', GetEnumValueName(Enum::"NPR RS Invoice Type"::NORMAL));
        JObjectHeader.Add('transactionType', GetEnumValueName(Enum::"NPR RS Transaction Type"::REFUND));
        Clear(JObjectLines);
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        JObjectLines.Add('amount', SalesCrMemoHeader."Amount Including VAT");
        if RSPaymentMethodMapping.Get(SalesCrMemoHeader."Payment Method Code") then
            JObjectLines.Add('paymentType', GetEnumValueName(RSPaymentMethodMapping."RS Payment Method"))
        else
            JObjectLines.Add('paymentType', GetEnumValueName(RSPaymentMethodMapping."RS Payment Method"::Other));
        JArray.Add(JObjectLines);
        JObjectHeader.Add('payment', JArray);
        RSAuditMgt.FillCertificationData(Certification);
        JObjectHeader.Add('invoiceNumber', Certification.Get('ESIRNo'));

        if (RSAuxSalesCrMemoHeader."NPR RS Referent No." <> '') and (RSAuxSalesCrMemoHeader."NPR RS Referent Date/Time" <> 0DT) then begin
            JObjectHeader.Add('referentDocumentNumber', RSAuxSalesCrMemoHeader."NPR RS Referent No.");
            JObjectHeader.Add('referentDocumentDT', Format(RSAuxSalesCrMemoHeader."NPR RS Referent Date/Time", 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>'));
        end
        else begin
            RSPOSAuditLogAuxInfoReferent.SetRange("Audit Entry Type", RSPOSAuditLogAuxInfoReferent."Audit Entry Type"::"Sales Invoice Header");
            RSPOSAuditLogAuxInfoReferent.SetRange("Source Document No.", RSAuxSalesCrMemoHeader."NPR RS Refund Reference");
            RSPOSAuditLogAuxInfoReferent.FindLast();
            JObjectHeader.Add('referentDocumentNumber', RSPOSAuditLogAuxInfoReferent."Invoice Number");
            JObjectHeader.Add('referentDocumentDT', RSPOSAuditLogAuxInfoReferent."SDC DateTime");
        end;

        Clear(JObjectLines);
        JObjectLines.Add('omitQRCodeGen', 1);
        JObjectLines.Add('omitTextualRepresentation', 0);
        JObjectHeader.Add('options', JObjectLines);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        Clear(JArray);
        if SalesCrMemoLine.FindSet() then
            repeat
                Clear(ItemName);
                Clear(JObjectLines);
                Clear(JArray2);
                if RSPaymentMethodMapping.Get(SalesCrMemoHeader."Payment Method Code") then begin
                    if RSPaymentMethodMapping."RS Payment Method" in [RSPaymentMethodMapping."RS Payment Method"::Other] then
                        ItemName := OtherPaymentItemPrefixLbl;
                end else
                    ItemName := OtherPaymentItemPrefixLbl;

                if RSFiscalizationSetup."Print Item No. on Receipt" then
                    ItemName += SalesCrMemoLine."No." + ',' + SalesCrMemoLine.Description
                else
                    ItemName += SalesCrMemoLine.Description;

                if (RSFiscalizationSetup."Print Item Desc. 2 on Receipt") and (StrLen(SalesCrMemoLine."Description 2") > 0) then
                    ItemName += ',' + SalesCrMemoLine."Description 2";

                JObjectLines.Add('name', ItemName);
                Item.Get(SalesCrMemoLine."No.");
                if Item.GTIN <> '' then
                    JObjectLines.Add('GTIN', Item.GTIN);
                JObjectLines.Add('quantity', Abs(SalesCrMemoLine.Quantity));
                JObjectLines.Add('unitPrice', Abs(Round((SalesCrMemoLine."Amount Including VAT" / SalesCrMemoLine.Quantity), 0.01)));
                RSVATPostSetupMapping.Get(SalesCrMemoLine."VAT Bus. Posting Group", SalesCrMemoLine."VAT Prod. Posting Group");
                RSAllowedTaxRates.Get(RSVATPostSetupMapping."RS Tax Category Name", RSVATPostSetupMapping."RS Tax Category Label");
                JArray2.Add(RSAllowedTaxRates."Tax Category Rate Label");
                JObjectLines.Add('labels', JArray2);
                JObjectLines.Add('totalAmount', Abs(SalesCrMemoLine."Amount Including VAT"));
                JArray.Add(JObjectLines);
            until SalesCrMemoLine.Next() = 0;
        JObjectHeader.Add('items', JArray);
        JObjectHeader.WriteTo(JsonBodyTxt);
        exit(JsonBodyTxt);
    end;

    local procedure CreateJsonForVoucherBasedOnReferenceDocument(RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info"; NpRvArchVoucherEntry: Record "NPR NpRv Arch. Voucher Entry"; RSPOSPaymMethMapping: Record "NPR RS POS Paym. Meth. Mapping"; var JObjectHeader: JsonObject)
    var
        Item: Record Item;
        NpRvArchVoucherEntrySource: Record "NPR NpRv Arch. Voucher Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        RSAllowedTaxRates: Record "NPR RS Allowed Tax Rates";
        RSPOSAuditLogAuxInfoReferent: Record "NPR RS POS Audit Log Aux. Info";
        RSVATPostSetupMapping: Record "NPR RS VAT Post. Setup Mapping";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        JArray: JsonArray;
        JArray2: JsonArray;
        JObjectLines: JsonObject;
        ItemName: Text;
    begin
        RSFiscalizationSetup.Get();
        NpRvArchVoucherEntrySource.SetRange("Entry Type", NpRvArchVoucherEntry."Entry Type"::"Issue Voucher");
        NpRvArchVoucherEntrySource.SetRange("Arch. Voucher No.", NpRvArchVoucherEntry."Arch. Voucher No.");
        if NpRvArchVoucherEntrySource.FindFirst() then begin
            RSPOSAuditLogAuxInfoReferent.SetRange("Audit Entry Type", RSPOSAuditLogAuxInfoReferent."Audit Entry Type"::"POS Entry");
            RSPOSAuditLogAuxInfoReferent.SetRange("Source Document No.", NpRvArchVoucherEntrySource."Document No.");
            RSPOSAuditLogAuxInfoReferent.FindFirst();
            JObjectHeader.Add('referentDocumentNumber', RSPOSAuditLogAuxInfoReferent."Invoice Number");
            JObjectHeader.Add('referentDocumentDT', RSPOSAuditLogAuxInfoReferent."SDC DateTime");
            Clear(JObjectLines);
            JObjectLines.Add('omitQRCodeGen', 1);
            JObjectLines.Add('omitTextualRepresentation', 0);
            JObjectHeader.Add('options', JObjectLines);
            POSEntrySalesLine.Reset();
            POSEntrySalesLine.SetRange("POS Entry No.", RSPOSAuditLogAuxInfoReferent."POS Entry No.");
            POSEntrySalesLine.SetFilter(Type, '%1', POSEntrySalesLine.Type::Voucher);
            Clear(JArray);
            if POSEntrySalesLine.FindSet() then
                repeat
                    Clear(ItemName);
                    Clear(JObjectLines);
                    Clear(JArray2);
                    if not (RSPOSAuditLogAuxInfo."POS Entry Type" in [RSPOSAuditLogAuxInfo."POS Entry Type"::"Credit Sale"]) and
                        RSPOSPaymMethMapping.Find() then
                        if RSPOSPaymMethMapping."RS Payment Method" in [RSPOSPaymMethMapping."RS Payment Method"::Other] then
                            ItemName := OtherPaymentItemPrefixLbl;

                    if RSFiscalizationSetup."Print Item No. on Receipt" then
                        ItemName += POSEntrySalesLine."No." + ',' + POSEntrySalesLine.Description
                    else
                        ItemName += POSEntrySalesLine.Description;

                    if (RSFiscalizationSetup."Print Item Desc. 2 on Receipt") and (StrLen(POSEntrySalesLine."Description 2") > 0) then
                        ItemName += ',' + POSEntrySalesLine."Description 2";

                    JObjectLines.Add('name', ItemName);
                    case POSEntrySalesLine.Type of
                        POSEntrySalesLine.Type::Item:
                            begin
                                POSEntrySalesLine.GetItem(Item);
                                if Item.GTIN <> '' then
                                    JObjectLines.Add('GTIN', Item.GTIN);
                            end;
                    end;
                    JObjectLines.Add('quantity', Abs(POSEntrySalesLine.Quantity));
                    if POSEntrySalesLine."Amount Incl. VAT" = 0 then
                        POSEntrySalesLine."Amount Incl. VAT" += 0.01;
                    JObjectLines.Add('unitPrice', Abs(Round((POSEntrySalesLine."Amount Incl. VAT" / POSEntrySalesLine.Quantity), 0.01)));
                    RSVATPostSetupMapping.Get(POSEntrySalesLine."VAT Bus. Posting Group", POSEntrySalesLine."VAT Prod. Posting Group");
                    RSAllowedTaxRates.Get(RSVATPostSetupMapping."RS Tax Category Name", RSVATPostSetupMapping."RS Tax Category Label");
                    JArray2.Add(RSAllowedTaxRates."Tax Category Rate Label");
                    JObjectLines.Add('labels', JArray2);
                    JObjectLines.Add('totalAmount', Abs(POSEntrySalesLine."Amount Incl. VAT"));
                    JArray.Add(JObjectLines);
                until POSEntrySalesLine.Next() = 0;
            JObjectHeader.Add('items', JArray);
        end;
    end;
    #endregion

    #region JSON Fiscal Parsers
    local procedure FillRSAuditFromNormalSaleAndRefundResponse(var RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info"; ResponseText: Text; StartTime: DateTime)
    var
        JsonHeader: JsonObject;
        JsonTok: JsonToken;
        TempResult: Text;
    begin
        if not JsonHeader.ReadFrom(ResponseText) then
            Error(JSONReadErr);

#pragma warning disable AA0139
        JsonHeader.Get('requestedBy', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Requested By" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('sdcDateTime', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."SDC DateTime" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('invoiceCounter', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Invoice Counter" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('invoiceCounterExtension', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Invoice Counter Extension" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('invoiceNumber', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Invoice Number" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('verificationUrl', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Verification URL" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('journal', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.SetTextToJournal(DelChr(TempResult, '=', '"'));

        JsonHeader.Get('signedBy', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Signed By" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('encryptedInternalData', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Ecrypted Internal Data" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('signature', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.Signature := DelChr(TempResult, '=', '"');

        JsonHeader.Get('totalCounter', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(RSPOSAuditLogAuxInfo."Total Counter", DelChr(TempResult, '=', '"'));

        JsonHeader.Get('transactionTypeCounter', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(RSPOSAuditLogAuxInfo."Transaction Type Counter", DelChr(TempResult, '=', '"'));

        JsonHeader.Get('totalAmount', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(RSPOSAuditLogAuxInfo."Total Amount", DelChr(TempResult, '=', '"'));

        JsonHeader.Get('taxGroupRevision', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(RSPOSAuditLogAuxInfo."Tax Group Revision", DelChr(TempResult, '=', '"'));

        JsonHeader.Get('businessName', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Business Name" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('tin', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.Tin := DelChr(TempResult, '=', '"');

        JsonHeader.Get('locationName', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Location Name" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('address', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.Address := DelChr(TempResult, '=', '"');

        JsonHeader.Get('district', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.District := DelChr(TempResult, '=', '"');

        JsonHeader.Get('mrc', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.Mrc := DelChr(TempResult, '=', '"');
#pragma warning restore

        RSPOSAuditLogAuxInfo."Fiscal Processing Time" := CurrentDateTime - StartTime;

        RSPOSAuditLogAuxInfo.Modify();
        NormalLogReceiptFiscalisated(RSPOSAuditLogAuxInfo);
    end;

    local procedure FillRSAuditFromNormalSaleAndRefundResponse(var SalesHeader: Record "Sales Header"; ResponseText: Text; Refund: Boolean; ModifySalesHeader: Boolean; StartTime: DateTime)
    var
        Customer: Record Customer;
        POSUnit: Record "NPR POS Unit";
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        SalesLine: Record "Sales Line";
        JsonHeader: JsonObject;
        JsonTok: JsonToken;
        TempResult: Text;
    begin
        if not JsonHeader.ReadFrom(ResponseText) then
            Error(JSONReadErr);

        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(SalesHeader);

        RSPOSAuditLogAuxInfo.Init();
        RSPOSAuditLogAuxInfo."Audit Entry Type" := RSPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Header";
        RSPOSAuditLogAuxInfo."Entry Date" := SalesHeader."Order Date";
        RSPOSAuditLogAuxInfo."Source Document No." := SalesHeader."No.";
        RSPOSAuditLogAuxInfo."Source Document Type" := SalesHeader."Document Type";
        RSPOSAuditLogAuxInfo."POS Unit No." := RSAuxSalesHeader."NPR RS POS Unit";
        RSPOSAuditLogAuxInfo."Payment Method Code" := SalesHeader."Payment Method Code";
        RSPOSAuditLogAuxInfo."Email-To" := SalesHeader."Sell-to E-Mail";
        POSUnit.Get(RSAuxSalesHeader."NPR RS POS Unit");
        RSPOSAuditLogAuxInfo."POS Store Code" := POSUnit."POS Store Code";
        RSFiscalizationSetup.Get();
        case RSFiscalizationSetup.Training of
            true:
                RSPOSAuditLogAuxInfo."RS Invoice Type" := RSPOSAuditLogAuxInfo."RS Invoice Type"::TRAINING;
            false:
                RSPOSAuditLogAuxInfo."RS Invoice Type" := RSPOSAuditLogAuxInfo."RS Invoice Type"::PROFORMA;
        end;
        case Refund of
            true:
                begin
                    RSAuxSalesHeader."NPR RS Audit Entry" := RSAuxSalesHeader."NPR RS Audit Entry"::"Proforma Refund";
                    RSPOSAuditLogAuxInfo."RS Transaction Type" := RSPOSAuditLogAuxInfo."RS Transaction Type"::REFUND;
                end;
            false:
                begin
                    RSAuxSalesHeader."NPR RS Audit Entry" := RSAuxSalesHeader."NPR RS Audit Entry"::"Proforma Sales";
                    RSPOSAuditLogAuxInfo."RS Transaction Type" := RSPOSAuditLogAuxInfo."RS Transaction Type"::SALE;
                end;
        end;
        if SalesHeader."Sell-to Customer No." <> '' then begin
            Customer.Get(SalesHeader."Sell-to Customer No.");
            if Customer."VAT Registration No." <> '' then
                RSPOSAuditLogAuxInfo."Customer Identification" := CustomerVATRegNoRSLabel + Customer."VAT Registration No.";
        end;

#pragma warning disable AA0139
        JsonHeader.Get('requestedBy', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Requested By" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('sdcDateTime', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."SDC DateTime" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('invoiceCounter', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Invoice Counter" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('invoiceCounterExtension', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Invoice Counter Extension" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('invoiceNumber', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Invoice Number" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('verificationUrl', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Verification URL" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('journal', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.SetTextToJournal(DelChr(TempResult, '=', '"'));

        JsonHeader.Get('signedBy', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Signed By" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('encryptedInternalData', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Ecrypted Internal Data" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('signature', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.Signature := DelChr(TempResult, '=', '"');

        JsonHeader.Get('totalCounter', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(RSPOSAuditLogAuxInfo."Total Counter", DelChr(TempResult, '=', '"'));

        JsonHeader.Get('transactionTypeCounter', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(RSPOSAuditLogAuxInfo."Transaction Type Counter", DelChr(TempResult, '=', '"'));

        JsonHeader.Get('totalAmount', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(RSPOSAuditLogAuxInfo."Total Amount", DelChr(TempResult, '=', '"'));

        JsonHeader.Get('taxGroupRevision', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(RSPOSAuditLogAuxInfo."Tax Group Revision", DelChr(TempResult, '=', '"'));

        JsonHeader.Get('businessName', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Business Name" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('tin', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.Tin := DelChr(TempResult, '=', '"');

        JsonHeader.Get('locationName', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Location Name" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('address', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.Address := DelChr(TempResult, '=', '"');

        JsonHeader.Get('district', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.District := DelChr(TempResult, '=', '"');

        JsonHeader.Get('mrc', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.Mrc := DelChr(TempResult, '=', '"');

#pragma warning restore

        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindSet();
        repeat
            RSPOSAuditLogAuxInfo."Discount Amount" += SalesLine."Line Discount Amount";
        until SalesLine.Next() = 0;

        RSPOSAuditLogAuxInfo."Fiscal Processing Time" := CurrentDateTime - StartTime;

        RSPOSAuditLogAuxInfo.Insert();
        NormalLogReceiptFiscalisated(RSPOSAuditLogAuxInfo);

        RSAuxSalesHeader."NPR RS Audit Entry No." := RSPOSAuditLogAuxInfo."Audit Entry No.";

        if ModifySalesHeader then
            RSAuxSalesHeader.SaveRSAuxSalesHeaderFields();
    end;

    local procedure FillRSAuditFromNormalSaleAndRefundResponse(var SalesInvoiceHeader: Record "Sales Invoice Header"; ResponseText: Text; StartTime: DateTime; Prepayment: Boolean; PrintReceipt: Boolean)
    var
        Customer: Record Customer;
        POSUnit: Record "NPR POS Unit";
        RSAuxSalesInvHeader: Record "NPR RS Aux Sales Inv. Header";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        SalesInvoiceLine: Record "Sales Invoice Line";
        RSFiscalThermalPrint: Codeunit "NPR RS Fiscal Thermal Print";
        JsonHeader: JsonObject;
        JsonTok: JsonToken;
        TempResult: Text;
    begin
        if not JsonHeader.ReadFrom(ResponseText) then
            Error(JSONReadErr);

        RSAuxSalesInvHeader.Get(SalesInvoiceHeader."No.");

        RSPOSAuditLogAuxInfo.Init();
        RSPOSAuditLogAuxInfo."Entry Date" := SalesInvoiceHeader."Posting Date";
        SalesInvoiceHeader.CalcFields("Amount Including VAT");
        RSPOSAuditLogAuxInfo."POS Unit No." := RSAuxSalesInvHeader."NPR RS POS Unit";
        RSPOSAuditLogAuxInfo."Payment Method Code" := SalesInvoiceHeader."Payment Method Code";
        RSPOSAuditLogAuxInfo."Email-To" := SalesInvoiceHeader."Sell-to E-Mail";
        POSUnit.Get(RSAuxSalesInvHeader."NPR RS POS Unit");
        RSPOSAuditLogAuxInfo."POS Store Code" := POSUnit."POS Store Code";
        RSFiscalizationSetup.Get();
        case RSFiscalizationSetup.Training of
            true:
                RSPOSAuditLogAuxInfo."RS Invoice Type" := RSPOSAuditLogAuxInfo."RS Invoice Type"::TRAINING;
            false:
                RSPOSAuditLogAuxInfo."RS Invoice Type" := RSPOSAuditLogAuxInfo."RS Invoice Type"::NORMAL;
        end;

        if Prepayment then begin
            SalesCrMemoHeader.SetRange("Prepayment Order No.", SalesInvoiceHeader."Order No.");
            SalesCrMemoHeader.FindLast();
            RSPOSAuditLogAuxInfo."Audit Entry Type" := RSPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Cr.Memo Header";
            RSPOSAuditLogAuxInfo."Source Document No." := SalesCrMemoHeader."No.";
            RSPOSAuditLogAuxInfo."RS Invoice Type" := RSPOSAuditLogAuxInfo."RS Invoice Type"::ADVANCE;
            RSAuxSalesInvHeader."NPR RS Audit Entry" := RSAuxSalesInvHeader."NPR RS Audit Entry"::"Advance Refund";
            RSPOSAuditLogAuxInfo."RS Transaction Type" := RSPOSAuditLogAuxInfo."RS Transaction Type"::REFUND;
        end else begin
            RSPOSAuditLogAuxInfo."Source Document No." := SalesInvoiceHeader."No.";
            RSPOSAuditLogAuxInfo."Audit Entry Type" := RSPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Invoice Header";
            RSAuxSalesInvHeader."NPR RS Audit Entry" := RSAuxSalesInvHeader."NPR RS Audit Entry"::"Normal Sale";
            RSPOSAuditLogAuxInfo."RS Transaction Type" := RSPOSAuditLogAuxInfo."RS Transaction Type"::SALE;
        end;

        if SalesInvoiceHeader."Sell-to Customer No." <> '' then begin
            Customer.Get(SalesInvoiceHeader."Sell-to Customer No.");
            if Customer."VAT Registration No." <> '' then
                RSPOSAuditLogAuxInfo."Customer Identification" := CustomerVATRegNoRSLabel + Customer."VAT Registration No.";
        end;

#pragma warning disable AA0139
        JsonHeader.Get('requestedBy', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Requested By" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('sdcDateTime', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."SDC DateTime" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('invoiceCounter', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Invoice Counter" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('invoiceCounterExtension', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Invoice Counter Extension" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('invoiceNumber', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Invoice Number" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('verificationUrl', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Verification URL" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('journal', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.SetTextToJournal(DelChr(TempResult, '=', '"'));

        JsonHeader.Get('signedBy', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Signed By" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('encryptedInternalData', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Ecrypted Internal Data" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('signature', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.Signature := DelChr(TempResult, '=', '"');

        JsonHeader.Get('totalCounter', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(RSPOSAuditLogAuxInfo."Total Counter", DelChr(TempResult, '=', '"'));

        JsonHeader.Get('transactionTypeCounter', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(RSPOSAuditLogAuxInfo."Transaction Type Counter", DelChr(TempResult, '=', '"'));

        JsonHeader.Get('totalAmount', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(RSPOSAuditLogAuxInfo."Total Amount", DelChr(TempResult, '=', '"'));

        JsonHeader.Get('taxGroupRevision', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(RSPOSAuditLogAuxInfo."Tax Group Revision", DelChr(TempResult, '=', '"'));

        JsonHeader.Get('businessName', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Business Name" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('tin', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.Tin := DelChr(TempResult, '=', '"');

        JsonHeader.Get('locationName', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Location Name" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('address', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.Address := DelChr(TempResult, '=', '"');

        JsonHeader.Get('district', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.District := DelChr(TempResult, '=', '"');

        JsonHeader.Get('mrc', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.Mrc := DelChr(TempResult, '=', '"');
#pragma warning restore
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.FindSet();
        repeat
            RSPOSAuditLogAuxInfo."Discount Amount" += SalesInvoiceLine."Line Discount Amount";
        until SalesInvoiceLine.Next() = 0;

        RSPOSAuditLogAuxInfo."Fiscal Processing Time" := CurrentDateTime - StartTime;

        RSPOSAuditLogAuxInfo.Insert();
        NormalLogReceiptFiscalisated(RSPOSAuditLogAuxInfo);

        RSAuxSalesInvHeader."NPR RS Audit Entry No." := RSPOSAuditLogAuxInfo."Audit Entry No.";
        RSAuxSalesInvHeader.Modify();

        if PrintReceipt then begin
            Commit();
            RSFiscalThermalPrint.PrintReceipt(RSPOSAuditLogAuxInfo);
        end
    end;

    local procedure FillRSAuditFromNormalSaleAndRefundResponse(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; ResponseText: Text; StartTime: DateTime; PrintReceipt: Boolean)
    var
        Customer: Record Customer;
        POSUnit: Record "NPR POS Unit";
        RSAuxSalesCrMemoHeader: Record "NPR RS Aux Sales CrMemo Header";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RSPaymentMethodMapping: Record "NPR RS Payment Method Mapping";
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        RSFiscalThermalPrint: Codeunit "NPR RS Fiscal Thermal Print";
        JsonHeader: JsonObject;
        JsonTok: JsonToken;
        TempResult: Text;
    begin
        if not JsonHeader.ReadFrom(ResponseText) then
            Error(JSONReadErr);

        RSAuxSalesCrMemoHeader.ReadRSAuxSalesCrMemoHeaderFields(SalesCrMemoHeader);
        RSPOSAuditLogAuxInfo.Init();
        RSPOSAuditLogAuxInfo."Audit Entry Type" := RSPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Cr.Memo Header";
        RSPOSAuditLogAuxInfo."Entry Date" := SalesCrMemoHeader."Posting Date";
        RSPOSAuditLogAuxInfo."Source Document No." := SalesCrMemoHeader."No.";
        RSPOSAuditLogAuxInfo."POS Unit No." := RSAuxSalesCrMemoHeader."NPR RS POS Unit";
        RSPOSAuditLogAuxInfo."Payment Method Code" := SalesCrMemoHeader."Payment Method Code";
        RSPOSAuditLogAuxInfo."Email-To" := SalesCrMemoHeader."Sell-to E-Mail";
        POSUnit.Get(RSAuxSalesCrMemoHeader."NPR RS POS Unit");
        RSPOSAuditLogAuxInfo."POS Store Code" := POSUnit."POS Store Code";
        RSFiscalizationSetup.Get();
        case RSFiscalizationSetup.Training of
            true:
                RSPOSAuditLogAuxInfo."RS Invoice Type" := RSPOSAuditLogAuxInfo."RS Invoice Type"::TRAINING;
            false:
                RSPOSAuditLogAuxInfo."RS Invoice Type" := RSPOSAuditLogAuxInfo."RS Invoice Type"::NORMAL;
        end;
        RSAuxSalesCrMemoHeader."NPR RS Audit Entry" := RSAuxSalesCrMemoHeader."NPR RS Audit Entry"::"Normal Refund";
        RSPOSAuditLogAuxInfo."RS Transaction Type" := RSPOSAuditLogAuxInfo."RS Transaction Type"::REFUND;

        if SalesCrMemoHeader."Sell-to Customer No." <> '' then begin
            Customer.Get(SalesCrMemoHeader."Sell-to Customer No.");
            if Customer."VAT Registration No." <> '' then
                RSPOSAuditLogAuxInfo."Customer Identification" := CustomerVATRegNoRSLabel + Customer."VAT Registration No.";
        end;

#pragma warning disable AA0139
        JsonHeader.Get('requestedBy', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Requested By" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('sdcDateTime', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."SDC DateTime" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('invoiceCounter', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Invoice Counter" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('invoiceCounterExtension', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Invoice Counter Extension" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('invoiceNumber', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Invoice Number" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('verificationUrl', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Verification URL" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('journal', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.SetTextToJournal(DelChr(TempResult, '=', '"'));

        JsonHeader.Get('signedBy', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Signed By" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('encryptedInternalData', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Ecrypted Internal Data" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('signature', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.Signature := DelChr(TempResult, '=', '"');

        JsonHeader.Get('totalCounter', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(RSPOSAuditLogAuxInfo."Total Counter", DelChr(TempResult, '=', '"'));

        JsonHeader.Get('transactionTypeCounter', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(RSPOSAuditLogAuxInfo."Transaction Type Counter", DelChr(TempResult, '=', '"'));

        JsonHeader.Get('totalAmount', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(RSPOSAuditLogAuxInfo."Total Amount", DelChr(TempResult, '=', '"'));

        JsonHeader.Get('taxGroupRevision', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(RSPOSAuditLogAuxInfo."Tax Group Revision", DelChr(TempResult, '=', '"'));

        JsonHeader.Get('businessName', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Business Name" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('tin', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.Tin := DelChr(TempResult, '=', '"');

        JsonHeader.Get('locationName', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo."Location Name" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('address', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.Address := DelChr(TempResult, '=', '"');

        JsonHeader.Get('district', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.District := DelChr(TempResult, '=', '"');

        JsonHeader.Get('mrc', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxInfo.Mrc := DelChr(TempResult, '=', '"');
#pragma warning restore
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.FindSet();
        repeat
            RSPOSAuditLogAuxInfo."Discount Amount" += SalesCrMemoLine."Line Discount Amount";
        until SalesCrMemoLine.Next() = 0;

        RSPOSAuditLogAuxInfo."Fiscal Processing Time" := CurrentDateTime - StartTime;
        RSPOSAuditLogAuxInfo.Insert();
        NormalLogReceiptFiscalisated(RSPOSAuditLogAuxInfo);

        RSAuxSalesCrMemoHeader."NPR RS Audit Entry No." := RSPOSAuditLogAuxInfo."Audit Entry No.";
        RSAuxSalesCrMemoHeader.SaveRSAuxSalesCrMemoHeaderFields();

        if SalesCrMemoHeader."Payment Method Code" <> '' then begin
            RSPaymentMethodMapping.Get(SalesCrMemoHeader."Payment Method Code");
            if RSPaymentMethodMapping."RS Payment Method" in [RSPaymentMethodMapping."RS Payment Method"::Cash] then
                CreateCopyFiscalReceipt(RSPOSAuditLogAuxInfo);
        end;

        if PrintReceipt then begin
            Commit();
            RSFiscalThermalPrint.PrintReceipt(RSPOSAuditLogAuxInfo);
        end;
    end;

    local procedure FillRSAuditFromCopySaleAndRefundResponse(var RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info"; ResponseText: Text; StartTime: DateTime)
    var
        RSPOSAuditLogAuxCopy: Record "NPR RS POS Audit Log Aux. Copy";
        RSPOSAuditLogAuxCopy2: Record "NPR RS POS Audit Log Aux. Copy";
        JsonHeader: JsonObject;
        JsonTok: JsonToken;
        TempResult: Text;
    begin
        RSPOSAuditLogAuxCopy.Init();
        RSPOSAuditLogAuxCopy."Audit Entry Type" := RSPOSAuditLogAuxInfo."Audit Entry Type";
        RSPOSAuditLogAuxCopy."Audit Entry No." := RSPOSAuditLogAuxInfo."Audit Entry No.";
        RSPOSAuditLogAuxCopy."POS Entry No." := RSPOSAuditLogAuxInfo."POS Entry No.";
        RSPOSAuditLogAuxCopy."Payment Method Code" := RSPOSAuditLogAuxInfo."Payment Method Code";
        RSPOSAuditLogAuxCopy2.SetRange("Audit Entry Type", RSPOSAuditLogAuxInfo."Audit Entry Type");
        RSPOSAuditLogAuxCopy2.SetRange("POS Entry No.", RSPOSAuditLogAuxInfo."POS Entry No.");
        if RSPOSAuditLogAuxCopy2.FindLast() then
            RSPOSAuditLogAuxCopy."Copy No." := RSPOSAuditLogAuxCopy2."Copy No." + 1
        else
            RSPOSAuditLogAuxCopy."Copy No." := 1;
        RSPOSAuditLogAuxCopy."Discount Amount" := RSPOSAuditLogAuxInfo."Discount Amount";
        RSPOSAuditLogAuxCopy."POS Store Code" := RSPOSAuditLogAuxInfo."POS Store Code";
        RSPOSAuditLogAuxCopy."POS Unit No." := RSPOSAuditLogAuxInfo."POS Unit No.";
        RSPOSAuditLogAuxCopy."Source Document No." := RSPOSAuditLogAuxInfo."Source Document No.";
        RSPOSAuditLogAuxCopy."Source Document Type" := RSPOSAuditLogAuxInfo."Source Document Type";
        RSPOSAuditLogAuxCopy."Entry Date" := RSPOSAuditLogAuxInfo."Entry Date";
        RSPOSAuditLogAuxCopy."RS Invoice Type" := RSPOSAuditLogAuxInfo."RS Invoice Type"::COPY;
        RSPOSAuditLogAuxCopy."RS Transaction Type" := RSPOSAuditLogAuxInfo."RS Transaction Type";
        RSPOSAuditLogAuxCopy."Customer Identification" := RSPOSAuditLogAuxInfo."Customer Identification";
        RSPOSAuditLogAuxCopy."Additional Customer Field" := RSPOSAuditLogAuxInfo."Additional Customer Field";
        RSPOSAuditLogAuxCopy."Email-To" := RSPOSAuditLogAuxInfo."Email-To";
        RSPOSAuditLogAuxCopy."Return Reference No." := RSPOSAuditLogAuxInfo."Return Reference No.";
        RSPOSAuditLogAuxCopy."Return Reference Date/Time" := RSPOSAuditLogAuxInfo."Return Reference Date/Time";

        if not JsonHeader.ReadFrom(ResponseText) then
            Error(JSONReadErr);
#pragma warning disable AA0139
        JsonHeader.Get('requestedBy', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxCopy."Requested By" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('sdcDateTime', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxCopy."SDC DateTime" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('invoiceCounter', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxCopy."Invoice Counter" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('invoiceCounterExtension', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxCopy."Invoice Counter Extension" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('invoiceNumber', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxCopy."Invoice Number" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('verificationUrl', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxCopy."Verification URL" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('journal', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxCopy.SetTextToJournal(DelChr(TempResult, '=', '"'));

        JsonHeader.Get('signedBy', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxCopy."Signed By" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('encryptedInternalData', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxCopy."Ecrypted Internal Data" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('signature', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxCopy.Signature := DelChr(TempResult, '=', '"');

        JsonHeader.Get('totalCounter', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(RSPOSAuditLogAuxCopy."Total Counter", DelChr(TempResult, '=', '"'));

        JsonHeader.Get('transactionTypeCounter', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(RSPOSAuditLogAuxCopy."Transaction Type Counter", DelChr(TempResult, '=', '"'));

        JsonHeader.Get('totalAmount', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(RSPOSAuditLogAuxCopy."Total Amount", DelChr(TempResult, '=', '"'));

        JsonHeader.Get('taxGroupRevision', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(RSPOSAuditLogAuxCopy."Tax Group Revision", DelChr(TempResult, '=', '"'));

        JsonHeader.Get('businessName', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxCopy."Business Name" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('tin', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxCopy.Tin := DelChr(TempResult, '=', '"');

        JsonHeader.Get('locationName', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxCopy."Location Name" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('address', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxCopy.Address := DelChr(TempResult, '=', '"');

        JsonHeader.Get('district', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxCopy.District := DelChr(TempResult, '=', '"');

        JsonHeader.Get('mrc', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSPOSAuditLogAuxCopy.Mrc := DelChr(TempResult, '=', '"');
#pragma warning restore
        RSPOSAuditLogAuxCopy."Fiscal Processing Time" := CurrentDateTime - StartTime;

        RSPOSAuditLogAuxCopy.Insert();
        NormalLogReceiptFiscalisated(RSPOSAuditLogAuxCopy);
    end;

    local procedure FillSUFConfigurationSetup(ResponseText: Text)
    var
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        JsonHeader: JsonObject;
        JsonHeader2: JsonObject;
        JsonTok: JsonToken;
        TempResult: Text;
    begin
        if not JsonHeader.ReadFrom(ResponseText) then
            Error(JSONReadErr);

        RSFiscalizationSetup.Get();
#pragma warning disable AA0139

        JsonHeader.Get('organizationName', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSFiscalizationSetup."Organization Name" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('serverTimeZone', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSFiscalizationSetup."Server Time Zone" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('street', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSFiscalizationSetup.Street := DelChr(TempResult, '=', '"');

        JsonHeader.Get('city', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSFiscalizationSetup.City := DelChr(TempResult, '=', '"');

        JsonHeader.Get('country', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSFiscalizationSetup.Country := DelChr(TempResult, '=', '"');

        JsonHeader.Get('environmentName', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSFiscalizationSetup."Environment Name" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('ntpServer', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSFiscalizationSetup."NPT Server URL" := DelChr(TempResult, '=', '"');

        JsonHeader.Get('endpoints', JsonTok);
        JsonHeader2 := JsonTok.AsObject();

        JsonHeader2.SelectToken('taxpayerAdminPortal', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSFiscalizationSetup."TaxPayer Admin Portal URL" := DelChr(TempResult, '=', '"');

        JsonHeader2.SelectToken('taxCoreApi', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSFiscalizationSetup."TaxCore API URL" := DelChr(TempResult, '=', '"');

        JsonHeader2.SelectToken('vsdc', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSFiscalizationSetup."VSDC URL" := DelChr(TempResult, '=', '"');

        JsonHeader2.SelectToken('taxpayerAdminPortal', JsonTok);
        JsonTok.WriteTo(TempResult);
        RSFiscalizationSetup."Root URL" := DelChr(TempResult, '=', '"');
#pragma warning restore
        RSFiscalizationSetup.Modify();
    end;

    local procedure FillAllowedTaxRates(ResponseText: Text; Silent: Boolean)
    var
        RSAllowedTaxRates: Record "NPR RS Allowed Tax Rates";
        ValidFromDate: Date;
        GroupID: Integer;
        i: Integer;
        j: Integer;
        TaxCategoryType: Integer;
        JArray: JsonArray;
        JArray2: JsonArray;
        JsonHeader: JsonObject;
        JsonHeader2: JsonObject;
        JsonTok: JsonToken;
        AllowedTaxRatesUpdate: Label 'Allowed Tax Rates have been updated.';
        ConfirmUpdateAllowedTaxRatesQst: Label 'By updating Allowed Tax Rates, VAT Posting Setup will be updated. Do you want to proceed?';
        TempResult: Text;
        TaxCategoryName: Text[20];
        ValidFromTime: Time;
    begin
        if not Silent and GuiAllowed then
            if not Confirm(ConfirmUpdateAllowedTaxRatesQst, false) then
                exit;

        if not JsonHeader.ReadFrom(ResponseText) then
            Error(JSONReadErr);

        JsonHeader.Get('currentTaxRates', JsonTok);
        JsonHeader2 := JsonTok.AsObject();

        JsonHeader2.Get('validFrom', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(ValidFromDate, DelChr(TempResult, '=', '"').Split('T').Get(1));
        Evaluate(ValidFromTime, DelChr(TempResult, '=', '"').Split('T').Get(1).Replace('Z', ''));

        JsonHeader2.Get('groupId', JsonTok);
        JsonTok.WriteTo(TempResult);
        Evaluate(GroupID, DelChr(TempResult, '=', '"'));

        JsonHeader2.Get('taxCategories', JsonTok);
        JArray := JsonTok.AsArray();
        RSAllowedTaxRates.DeleteAll();
        for i := 0 to JArray.Count - 1 do begin
            JArray.Get(i, JsonTok);
            JsonHeader := JsonTok.AsObject();

            JsonHeader.Get('name', JsonTok);
            JsonTok.WriteTo(TempResult);
#pragma warning disable AA0139
            TaxCategoryName := DelChr(TempResult, '=', '"');
#pragma warning restore

            JsonHeader.Get('categoryType', JsonTok);
            JsonTok.WriteTo(TempResult);
            Evaluate(TaxCategoryType, DelChr(TempResult, '=', '"'));

            JsonHeader.Get('taxRates', JsonTok);
            JArray2 := JsonTok.AsArray();
            for j := 0 to JArray2.Count - 1 do begin
                JArray2.Get(j, JsonTok);
                RSAllowedTaxRates.Init();
                RSAllowedTaxRates."Valid From Date" := ValidFromDate;
                RSAllowedTaxRates."Valid From Time" := ValidFromTime;
                RSAllowedTaxRates."Group ID" := GroupID;
                RSAllowedTaxRates."Tax Category Name" := TaxCategoryName;
                RSAllowedTaxRates."Tax Category Type" := TaxCategoryType;

                JsonHeader2 := JsonTok.AsObject();

                JsonHeader2.Get('rate', JsonTok);
                JsonTok.WriteTo(TempResult);
                Evaluate(RSAllowedTaxRates."Tax Category Rate", DelChr(TempResult, '=', '"'));

                JsonHeader2.Get('label', JsonTok);
                JsonTok.WriteTo(TempResult);
#pragma warning disable AA0139
                RSAllowedTaxRates."Tax Category Rate Label" := DelChr(TempResult, '=', '"');
#pragma warning restore

                RSAllowedTaxRates.Insert();
            end;
        end;
        UpdateVATPostingSetupForAllowedTaxRates();
        if not Silent and GuiAllowed then
            Message(AllowedTaxRatesUpdate);
    end;

    local procedure UpdateVATPostingSetupForAllowedTaxRates()
    var
        RSAllowedTaxRates: Record "NPR RS Allowed Tax Rates";
        RSVATPostSetupMapping: Record "NPR RS VAT Post. Setup Mapping";
    begin
        if not RSVATPostSetupMapping.FindSet() then
            exit;
        repeat
            if RSAllowedTaxRates.Get(RSVATPostSetupMapping."RS Tax Category Name", RSVATPostSetupMapping."RS Tax Category Label") then begin
                RSVATPostSetupMapping.CalcFields("VAT %");
                if RSAllowedTaxRates."Tax Category Rate" <> RSVATPostSetupMapping."VAT %" then begin
                    Clear(RSVATPostSetupMapping."RS Tax Category Label");
                    Clear(RSVATPostSetupMapping."RS Tax Category Name");
                end;
                RSVATPostSetupMapping.Modify();
            end else begin
                Clear(RSVATPostSetupMapping."RS Tax Category Label");
                Clear(RSVATPostSetupMapping."RS Tax Category Name");
                RSVATPostSetupMapping.Modify();
            end;
        until RSVATPostSetupMapping.Next() = 0;
    end;

    local procedure ClearSUFConfigurationSetup()
    var
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        APIPullError: Label 'Error pulling configuration from SandBox API. Check URL or availability of API.';
    begin
        RSFiscalizationSetup.Get();
        Clear(RSFiscalizationSetup."Organization Name");
        Clear(RSFiscalizationSetup."Server Time Zone");
        Clear(RSFiscalizationSetup.Street);
        Clear(RSFiscalizationSetup.City);
        Clear(RSFiscalizationSetup.Country);
        Clear(RSFiscalizationSetup."Environment Name");
        Clear(RSFiscalizationSetup."NPT Server URL");
        Clear(RSFiscalizationSetup."TaxPayer Admin Portal URL");
        Clear(RSFiscalizationSetup."TaxCore API URL");
        Clear(RSFiscalizationSetup."VSDC URL");
        Clear(RSFiscalizationSetup."Root URL");
        RSFiscalizationSetup.Modify();
        Message(APIPullError);
    end;

    local procedure ClearAllowedTaxRates()
    var
        RSAllowedTaxRates: Record "NPR RS Allowed Tax Rates";
        APIPullError: Label 'Error pulling configuration from SandBox API. Check URL or availability of API.';
    begin
        RSAllowedTaxRates.DeleteAll();
        Message(APIPullError);
    end;

    local procedure GetSumAmountOfPrepaymentSales(SalesInvoiceLine: Record "Sales Invoice Line") Amount: Decimal
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceHeader2: Record "Sales Invoice Header";
        SalesInvoiceLine2: Record "Sales Invoice Line";
    begin
        SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.");
        SalesInvoiceHeader2.SetRange("Prepayment Order No.", SalesInvoiceHeader."Prepayment Order No.");
        repeat
            if SalesInvoiceLine2.Get(SalesInvoiceHeader2."No.", SalesInvoiceLine."Line No.") then
                Amount += SalesInvoiceLine2."Amount Including VAT";
        until SalesInvoiceHeader2.Next() = 0;
    end;
    #endregion

    #region Misc - For Http Requests
    local procedure SendHttpRequest(var RequestMessage: HttpRequestMessage; var ResponseText: Text; SkipErrorMessage: Boolean): Boolean
    var
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        IsResponseSuccess: Boolean;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        ErrorText: Text;
    begin
        Clear(ResponseMessage);
        IsResponseSuccess := Client.Send(RequestMessage, ResponseMessage);
        if (not IsResponseSuccess) then
            if SkipErrorMessage then
                exit(IsResponseSuccess)
            else
                Error(GetLastErrorText);

        RSFiscalizationSetup.Get();
        IsResponseSuccess := ResponseMessage.IsSuccessStatusCode();
        if (not IsResponseSuccess) and (not RSFiscalizationSetup."Allow Offline Use") and (not SkipErrorMessage) and GuiAllowed then begin
            ErrorText := Format(ResponseMessage.HttpStatusCode(), 0, 9) + ': ' + ResponseMessage.ReasonPhrase;
            if ResponseMessage.Content.ReadAs(ResponseText) then
                ErrorText += ':\' + ResponseText;
            Error(CopyStr(ErrorText, 1, 1000));
        end;
        ResponseMessage.Content.ReadAs(ResponseText);
        exit(IsResponseSuccess);
    end;

    local procedure SetHeader(var Headers: HttpHeaders; HeaderName: Text; HeaderValue: Text)
    begin
        if Headers.Contains(HeaderName) then
            Headers.Remove(HeaderName);

        Headers.Add(HeaderName, HeaderValue);
    end;
    #endregion

    #region API Setup
    local procedure GetApiVersionUrl(): Text
    var
        ApiVersionUrl: Label '/api/v3/';
    begin
        exit(ApiVersionUrl);
    end;

    local procedure GetSandboxToken(ExcludeToken: Boolean; SandboxToken: Guid): Text
    begin
        if ExcludeToken then
            exit('');

        exit('/' + DelChr(Format(SandboxToken), '=', '{}'));
    end;
    #endregion

    #region Helper Functions
    local procedure GetEnumValueName(RSInvoiceType: Enum "NPR RS Invoice Type"): Text
    var
        Index: Integer;
        ValueName: Text;
    begin
        Index := RSInvoiceType.Ordinals().IndexOf(RSInvoiceType.AsInteger());
        RSInvoiceType.Names().Get(Index, ValueName);
        exit(ValueName);
    end;

    local procedure GetEnumValueName(RSTransactionType: Enum "NPR RS Transaction Type"): Text
    var
        Index: Integer;
        ValueName: Text;
    begin
        Index := RSTransactionType.Ordinals().IndexOf(RSTransactionType.AsInteger());
        RSTransactionType.Names().Get(Index, ValueName);
        exit(ValueName);
    end;

    local procedure GetEnumValueName(RSPaymentMethod: Enum "NPR RS Payment Method"): Text
    var
        Index: Integer;
        ValueName: Text;
    begin
        Index := RSPaymentMethod.Ordinals().IndexOf(RSPaymentMethod.AsInteger());
        RSPaymentMethod.Names().Get(Index, ValueName);
        exit(ValueName);
    end;

    local procedure CalculatePaymentMethods(RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info"; POSEntryPaymentLine: Record "NPR POS Entry Payment Line"; var JArray: JsonArray; var JObjectLines: JsonObject)
    var
        RSPOSPaymMethMapping: Record "NPR RS POS Paym. Meth. Mapping";
        RSPOSPaymMethMapping2: Record "NPR RS POS Paym. Meth. Mapping";
        POSEntryPaymentLine2: Record "NPR POS Entry Payment Line";
        TempPOSEntryPaymentLine: Record "NPR POS Entry Payment Line" temporary;
        PaymentAmount: Decimal;
        PaymentMethodFilter: Text;
    begin
        POSEntryPaymentLine.SetRange("POS Entry No.", RSPOSAuditLogAuxInfo."POS Entry No.");
        POSEntryPaymentLine2.SetRange("POS Entry No.", RSPOSAuditLogAuxInfo."POS Entry No.");
        if POSEntryPaymentLine.FindSet() then
            repeat
                Clear(PaymentMethodFilter);
                Clear(PaymentAmount);
                if RSPOSPaymMethMapping.Get(POSEntryPaymentLine."POS Payment Method Code") then begin
                    RSPOSPaymMethMapping2.SetRange("RS Payment Method", RSPOSPaymMethMapping."RS Payment Method");
                    if RSPOSPaymMethMapping2.FindSet() then
                        repeat
                            if PaymentMethodFilter <> '' then
                                PaymentMethodFilter += '|';
                            PaymentMethodFilter += RSPOSPaymMethMapping2."POS Payment Method Code";
                        until RSPOSPaymMethMapping2.Next() = 0;
                    POSEntryPaymentLine2.SetFilter("POS Payment Method Code", PaymentMethodFilter);
                    if POSEntryPaymentLine2.FindSet() then
                        repeat
                            PaymentAmount += POSEntryPaymentLine2.Amount;
                        until POSEntryPaymentLine2.Next() = 0;
                    TempPOSEntryPaymentLine.SetFilter("POS Payment Method Code", PaymentMethodFilter);
                    if not TempPOSEntryPaymentLine.FindFirst() then begin
                        TempPOSEntryPaymentLine.Init();
                        TempPOSEntryPaymentLine.Copy(POSEntryPaymentLine);
                        TempPOSEntryPaymentLine.Amount := PaymentAmount;
                        TempPOSEntryPaymentLine.Insert();
                    end;
                end;
            until POSEntryPaymentLine.Next() = 0;

        TempPOSEntryPaymentLine.Reset();
        if TempPOSEntryPaymentLine.FindSet() then begin
            repeat
                Clear(JObjectLines);
                JObjectLines.Add('amount', Abs(TempPOSEntryPaymentLine.Amount));
                if RSPOSPaymMethMapping.Get(TempPOSEntryPaymentLine."POS Payment Method Code") then
                    JObjectLines.Add('paymentType', GetEnumValueName(RSPOSPaymMethMapping."RS Payment Method"))
                else
                    JObjectLines.Add('paymentType', GetEnumValueName(RSPOSPaymMethMapping."RS Payment Method"::Other));
                JArray.Add(JObjectLines);
            until TempPOSEntryPaymentLine.Next() = 0;

            TempPOSEntryPaymentLine.DeleteAll();
        end else begin
            Clear(JObjectLines);
            JObjectLines.Add('amount', Abs(0.01));
            JObjectLines.Add('paymentType', GetEnumValueName(RSPOSPaymMethMapping."RS Payment Method"::Cash));
            JArray.Add(JObjectLines);
        end;
    end;

    #endregion

    #region Telemetry
    local procedure NormalLogReceiptFiscalisated(RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info")
    var
        _LogDict: Dictionary of [Text, Text];
    begin
        Clear(_LogDict);
        _LogDict.Add('NPR_Duration', Format(RSPOSAuditLogAuxInfo."Fiscal Processing Time", 0, 9));
        Session.LogMessage(FinishEventIdTok, RSFiscalReceiptFiscalisedLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, _LogDict);
    end;

    local procedure NormalLogReceiptFiscalisated(RSPOSAuditLogAuxCopy: Record "NPR RS POS Audit Log Aux. Copy")
    var
        _LogDict: Dictionary of [Text, Text];
    begin
        Clear(_LogDict);
        _LogDict.Add('NPR_Duration', Format(RSPOSAuditLogAuxCopy."Fiscal Processing Time", 0, 9));
        Session.LogMessage(FinishEventIdTok, RSFiscalReceiptFiscalisedLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, _LogDict);
    end;

    local procedure ErrorLogReceiptFiscalisated(Error: Text)
    var
        _LogDict: Dictionary of [Text, Text];
    begin
        Clear(_LogDict);
        _LogDict.Add('NPR_Error', Error);
        Session.LogMessage(FinishEventIdTok, RSFiscalReceiptNotFiscalisedLbl, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, _LogDict);
    end;
    #endregion

    #region Automated Test Mockup Helpers
    procedure TestFillRSAuditFromNormalSaleAndRefundResponse(var RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info"; ResponseText: Text; StartTime: DateTime)
    begin
        FillRSAuditFromNormalSaleAndRefundResponse(RSPOSAuditLogAuxInfo, ResponseText, StartTime);
    end;

    procedure TestFillRSAuditFromNormalSaleAndRefundResponse(var SalesInvoiceHeader: Record "Sales Invoice Header"; ResponseText: Text; StartTime: DateTime)
    begin
        FillRSAuditFromNormalSaleAndRefundResponse(SalesInvoiceHeader, ResponseText, StartTime, false, false);
    end;

    procedure TestFillRSAuditFromNormalSaleAndRefundResponse(var SalesHeader: Record "Sales Header"; ResponseText: Text; Refund: Boolean; ModifySalesHeader: Boolean; StartTime: DateTime)
    begin
        FillRSAuditFromNormalSaleAndRefundResponse(SalesHeader, ResponseText, Refund, ModifySalesHeader, StartTime);
    end;

    procedure TestFillRSAuditFromNormalSaleAndRefundResponse(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; ResponseText: Text; StartTime: DateTime)
    begin
        FillRSAuditFromNormalSaleAndRefundResponse(SalesCrMemoHeader, ResponseText, StartTime, false);
    end;

    procedure TextFillSUFConfigurationSetup(ResponseText: Text)
    begin
        FillSUFConfigurationSetup(ResponseText);
    end;

    procedure TestFillAllowedTaxRates(ResponseText: Text; Silent: Boolean)
    begin
        FillAllowedTaxRates(ResponseText, Silent);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForSUFConfiguration(RequestMessage: HttpRequestMessage; var ResponseText: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForAllowedTaxRates(RequestMessage: HttpRequestMessage; var ResponseText: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForNormalSale(RequestMessage: HttpRequestMessage; var ResponseText: Text; var RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info"; StartTime: DateTime; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForNormalSaleDocument(RequestMessage: HttpRequestMessage; var ResponseText: Text; var SalesInvoiceHeader: Record "Sales Invoice Header"; StartTime: DateTime; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForPrepaymentSaleDocument(RequestMessage: HttpRequestMessage; var ResponseText: Text; var SalesInvoiceHeader: Record "Sales Invoice Header"; StartTime: DateTime; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForProformaSale(RequestMessage: HttpRequestMessage; var ResponseText: Text; var SalesHeader: Record "Sales Header"; StartTime: DateTime; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForNormalRefund(RequestMessage: HttpRequestMessage; var ResponseText: Text; var RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info"; StartTime: DateTime; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendHttpRequestForNormalRefundDocument(RequestMessage: HttpRequestMessage; var ResponseText: Text; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; StartTime: DateTime; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendHttpRequestForProformaRefund(RequestMessage: HttpRequestMessage; var ResponseText: Text; var SalesHeader: Record "Sales Header"; StartTime: DateTime; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendHttpRequestForVerifyPin(RequestMessage: HttpRequestMessage; var ResponseText: Text; var IsHandled: Boolean)
    begin
    end;

    #endregion

    var
        OtherPaymentItemPrefixLbl: Label '00:', Locked = true;
        CustomerVATRegNoRSLabel: Label '10:', Locked = true;
        FinishEventIdTok: Label 'NPR_RS_FISCAL', Locked = true;
        JSONReadErr: Label 'JSON can''t be read from response text.';
        RSFiscalReceiptFiscalisedLbl: Label 'RS Fiscal Receipt Fiscalised';
        RSFiscalReceiptNotFiscalisedLbl: Label 'RS Fiscal Receipt Error';
}