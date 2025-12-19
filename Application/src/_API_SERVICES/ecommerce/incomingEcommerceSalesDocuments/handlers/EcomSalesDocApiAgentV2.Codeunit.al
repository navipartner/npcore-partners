#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248615 "NPR EcomSalesDocApiAgentV2"
{
    Access = Internal;
    internal procedure CreateIncomingEcomDocument(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";

    begin
        Request.SkipCacheIfNonStickyRequest(GetTableIds());
        InsertSalesDocument(Request, EcomSalesHeader);

        Commit();
        PreProcessDocument(EcomSalesHeader);

        AssignBucketId(EcomSalesHeader);
        exit(Response.RespondOK(GetSalesDocumentCreateResponse(EcomSalesHeader)));
    end;

    internal procedure GetIncomingEcomDocumentById(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        DocumentIdText: Text;
        DocumentId: Guid;
    begin
        Request.SkipCacheIfNonStickyRequest(GetTableIds());
        if (not Request.Paths().Get(3, DocumentIdText)) then
            exit(Response.RespondBadRequest('Missing required parameter: documentId'));

        if (not Evaluate(DocumentId, DocumentIdText)) then
            exit(Response.RespondBadRequest('Malformed parameter: documentId'));

        EcomSalesHeader.ReadIsolation := EcomSalesHeader.ReadIsolation::ReadCommitted;
        if (not EcomSalesHeader.GetBySystemId(DocumentId)) then
            exit(Response.RespondResourceNotFound());

        exit(Response.RespondOK(GetSalesDocumentJsonObject(EcomSalesHeader)));
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure InsertSalesDocument(var Request: Codeunit "NPR API Request"; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        RequestBody: JsonToken;
        RequestedApiVersion: Date;
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
    begin
        RequestBody := Request.BodyJson();
        RequestedApiVersion := Request.ApiVersion();
        ProcessIncomingSalesHeader(RequestBody, EcomSalesHeader, RequestedApiVersion);
        ProcessIncomingSalesLines(RequestBody, EcomSalesHeader);
        ProcessIncomingSalesPaymentLines(RequestBody, EcomSalesHeader);
        ProcessIncomingSalesDocumentComments(RequestBody, EcomSalesHeader);
        EcomVirtualItemMgt.UpdateVirtualItemInformationInHeader(EcomSalesHeader);
    end;

    local procedure DeserializeIncomingEcomSalesHeader(RequestBody: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header");
    var
        JsonHelper: Codeunit "NPR Json Helper";
        EcomSalesDocApiEvents: Codeunit "NPR EcomSalesDocApiEvents";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        SalesDocToJsonToken: JsonToken;
        SellToCustomerJsonToken: JsonToken;
        ShipmentJsonToken: JsonToken;
        ShipToJsonToken: JsonToken;
    begin
#pragma warning disable AA0139

        SalesDocToJsonToken := RequestBody;
        EcomSalesHeader."External No." := JsonHelper.GetJText(RequestBody, 'externalNo', MaxStrLen(EcomSalesHeader."External No."), true, true);
        EcomSalesHeader."Document Type" := GetEcomDocumentTypeFromRequest(RequestBody);
        EcomSalesDocUtils.CheckIncomingSalesDocumentAlreadyExists(EcomSalesHeader."Document Type", EcomSalesHeader."External No.");

        EcomSalesHeader."Currency Code" := JsonHelper.GetJText(RequestBody, 'currencyCode', MaxStrLen(EcomSalesHeader."Currency Code"), true, false);

        if EcomSalesHeader."Document Type" = EcomSalesHeader."Document Type"::Order then begin
            if EcomSalesHeader."Currency Code" <> '' then
                EcomSalesHeader."Currency Exchange Rate" := JsonHelper.GetJDecimal(RequestBody, 'currencyExchangeRate', false);
        end;

        EcomSalesHeader."External Document No." := JsonHelper.GetJText(RequestBody, 'externalDocumentNo', MaxStrLen(EcomSalesHeader."External Document No."), true, false);
        EcomSalesHeader."Your Reference" := JsonHelper.GetJText(RequestBody, 'yourReference', MaxStrLen(EcomSalesHeader."Your Reference"), true, false);
        EcomSalesHeader."Location Code" := JsonHelper.GetJText(RequestBody, 'locationCode', MaxStrLen(EcomSalesHeader."Location Code"), true, false);
        EcomSalesHeader."Price Excl. VAT" := JsonHelper.GetJBoolean(RequestBody, 'pricesExcludingVat', false);

        //Sell-to
        SellToCustomerJsonToken := JsonHelper.GetJsonToken(RequestBody, 'sellToCustomer');
        EcomSalesHeader."Sell-to Customer No." := JsonHelper.GetJText(RequestBody, 'sellToCustomer.no', MaxStrLen(EcomSalesHeader."Sell-to Customer No."), true, false);
        EcomSalesHeader."Customer Template" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.customerTemplate', MaxStrLen(EcomSalesHeader."Customer Template"), true, false);
        EcomSalesHeader."Configuration Template" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.configurationTemplate', MaxStrLen(EcomSalesHeader."Configuration Template"), true, false);
        EcomSalesHeader."Sell-to Name" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.name', MaxStrLen(EcomSalesHeader."Sell-to Name"), true, true);
        EcomSalesHeader."Sell-to Address" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.address', MaxStrLen(EcomSalesHeader."Sell-to Address"), true, true);
        EcomSalesHeader."Sell-to Address 2" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.address2', MaxStrLen(EcomSalesHeader."Sell-to Address 2"), true, false);
        EcomSalesHeader."Sell-to Post Code" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.postCode', MaxStrLen(EcomSalesHeader."Sell-to Post Code"), true, true);
        EcomSalesHeader."Sell-to County" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.county', MaxStrLen(EcomSalesHeader."Sell-to County"), true, false);
        EcomSalesHeader."Sell-to City" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.city', MaxStrLen(EcomSalesHeader."Sell-to City"), true, true);
        EcomSalesHeader."Sell-to Country Code" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.countryCode', MaxStrLen(EcomSalesHeader."Sell-to Country Code"), true, true);
        EcomSalesHeader."Sell-to Contact" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.contact', MaxStrLen(EcomSalesHeader."Sell-to Contact"), true, false);
        EcomSalesHeader."Sell-to Email" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.email', MaxStrLen(EcomSalesHeader."Sell-to Email"), true, true);
        EcomSalesHeader."Sell-to Phone No." := JsonHelper.GetJText(RequestBody, 'sellToCustomer.phone', MaxStrLen(EcomSalesHeader."Sell-to Phone No."), true, false);
        ValidatePhoneNumber(EcomSalesHeader."Sell-to Phone No.");
        EcomSalesHeader."Sell-to EAN" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.ean', MaxStrLen(EcomSalesHeader."Sell-to EAN"), true, false);
        EcomSalesHeader."Sell-to VAT Registration No." := JsonHelper.GetJText(RequestBody, 'sellToCustomer.vatRegistrationNo', MaxStrLen(EcomSalesHeader."Sell-to VAT Registration No."), true, false);

        if EcomSalesHeader."Document Type" = EcomSalesHeader."Document Type"::Order then
            EcomSalesHeader."Sell-to Invoice Email" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.invoiceEmail', MaxStrLen(EcomSalesHeader."Sell-to Invoice Email"), true, false);

        //Ship-to
        if JsonHelper.GetJsonToken(RequestBody, 'shipToCustomer', ShipToJsonToken) then begin
            EcomSalesHeader."Ship-to Name" := JsonHelper.GetJText(RequestBody, 'shipToCustomer.name', MaxStrLen(EcomSalesHeader."Ship-to Name"), true, true);
            EcomSalesHeader."Ship-to Address" := JsonHelper.GetJText(RequestBody, 'shipToCustomer.address', MaxStrLen(EcomSalesHeader."Ship-to Address"), true, true);
            EcomSalesHeader."Ship-to Address 2" := JsonHelper.GetJText(RequestBody, 'shipToCustomer.address2', MaxStrLen(EcomSalesHeader."Ship-to Address 2"), true, false);
            EcomSalesHeader."Ship-to Post Code" := JsonHelper.GetJText(RequestBody, 'shipToCustomer.postCode', MaxStrLen(EcomSalesHeader."Ship-to Post Code"), true, true);
            EcomSalesHeader."Ship-to County" := JsonHelper.GetJText(RequestBody, 'shipToCustomer.county', MaxStrLen(EcomSalesHeader."Ship-to County"), true, false);
            EcomSalesHeader."Ship-to City" := JsonHelper.GetJText(RequestBody, 'shipToCustomer.city', MaxStrLen(EcomSalesHeader."Ship-to City"), true, true);
            EcomSalesHeader."Ship-to Country Code" := JsonHelper.GetJText(RequestBody, 'shipToCustomer.countryCode', MaxStrLen(EcomSalesHeader."Ship-to Country Code"), true, false);
            EcomSalesHeader."Ship-to Contact" := JsonHelper.GetJText(RequestBody, 'shipToCustomer.contact', MaxStrLen(EcomSalesHeader."Ship-to Contact"), true, false);
        end;

        //Shipment
        if JsonHelper.GetJsonToken(RequestBody, 'shipment', ShipmentJsonToken) then begin
            EcomSalesHeader."Shipment Method Code" := JsonHelper.GetJText(RequestBody, 'shipment.shipmentMethod', MaxStrLen(EcomSalesHeader."Shipment Method Code"), true, true);
            EcomSalesHeader."Shipment Service" := JsonHelper.GetJText(RequestBody, 'shipment.shipmentService', MaxStrLen(EcomSalesHeader."Shipment Service"), true, false);
        end;

        EcomSalesDocApiEvents.OnAfterDeserializeIncomingEcomSalesHeader(EcomSalesHeader, RequestBody);
#pragma warning restore AA0139
    end;

    local procedure ProcessIncomingSalesHeader(Request: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"; RequestedApiVersion: Date);
    begin
        InsertIncomingSalesHeader(Request, EcomSalesHeader, RequestedApiVersion);
    end;

    local procedure InsertIncomingSalesHeader(Request: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"; RequestedApiVersion: Date)
    var
        EcomSalesDocApiEvents: Codeunit "NPR EcomSalesDocApiEvents";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        EcomSalesHeader.Init();
        DeserializeIncomingEcomSalesHeader(Request, EcomSalesHeader);
        EcomSalesHeader."Received Date" := Today;
        EcomSalesHeader."Received Time" := Time;
        EcomSalesHeader."Requested API Version Date" := RequestedApiVersion;
        EcomSalesHeader."API Version Date" := EcomSalesDocUtils.GetApiVersionDateByRequest(RequestedApiVersion);
        EcomSalesDocApiEvents.OnBeforeProcessIncomingSalesHeaderInsertIncSalesHeader(EcomSalesHeader, Request);
        EcomSalesHeader.Insert(true);
    end;

    local procedure ProcessIncomingSalesLines(RequestBody: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        JsonHelper: Codeunit "NPR Json Helper";
        SalesLineJsonToken: JsonToken;
        SalesLinesJsonToken: JsonToken;
        SalesLinesNoArrayErr: Label 'The salesLines property is not an array.', Locked = true;
    begin
        SalesLinesJsonToken := JsonHelper.GetJsonToken(RequestBody, 'salesDocumentLines');

        if (not SalesLinesJsonToken.IsArray()) then
            Error(SalesLinesNoArrayErr);

        foreach SalesLineJsonToken in SalesLinesJsonToken.AsArray() do
            InsertIncomingSalesLine(SalesLineJsonToken, EcomSalesHeader);
    end;

    local procedure InsertIncomingSalesLine(SalesLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        EcomSalesDocApiEvents: Codeunit "NPR EcomSalesDocApiEvents";
    begin
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."External Document No." := EcomSalesHeader."External No.";
        EcomSalesLine."Line No." := EcomSalesDocUtils.GetSalesDocLastSalesLineLineNo(EcomSalesHeader) + 10000;
        DeserializeIncomingEcomSalesLine(EcomSalesHeader, SalesLineJsonToken, EcomSalesLine);
        EcomSalesDocApiEvents.OnBeforeInsertIncomingSalesLineBeforeInsert(SalesLineJsonToken, EcomSalesHeader, EcomSalesLine);
        EcomSalesLine.Insert(true);
    end;

    local procedure ReserveVoucher(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line")
    var
        VoucherSalesLine: Record "NPR NpRv Sales Line";
        Voucher: Record "NPR NpRv Voucher";
        VoucherMngt: Codeunit "NPR NpRv Voucher Mgt.";
        EcomSalesDocApiEvents: Codeunit "NPR EcomSalesDocApiEvents";
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        VoucherInUser: Label 'Voucher with type %1 and reference no. %2 is already in use';
    begin
        if EcomSalesPmtLine."Payment Method Type" <> EcomSalesPmtLine."Payment Method Type"::Voucher then
            exit;

        EcomVirtualItemMgt.FindVoucher(EcomSalesPmtLine, Voucher);

        VoucherSalesLine.Reset();
        VoucherSalesLine.SetRange("Document Source", VoucherSalesLine."Document Source"::"Sales Document");
        VoucherSalesLine.SetRange("External Document No.", EcomSalesHeader."External No.");
        VoucherSalesLine.SetRange("Voucher Type", Voucher."Voucher Type");
        VoucherSalesLine.SetRange("Voucher No.", Voucher."No.");
        VoucherSalesLine.SetRange(Type, VoucherSalesLine.Type::Payment);
        if not VoucherSalesLine.FindFirst() then begin
            if not VoucherMngt.VoucherReservationByAmountFeatureEnabled() then begin
                if Voucher.CalcInUseQty() > 0 then
                    Error(VoucherInUser, Voucher."Voucher Type", Voucher."Reference No.");
            end;


            VoucherSalesLine.Init();
            VoucherSalesLine.Id := CreateGuid();
            VoucherSalesLine."Document Source" := VoucherSalesLine."Document Source"::"Sales Document";
            VoucherSalesLine."External Document No." := EcomSalesHeader."External No.";
            VoucherSalesLine.Type := VoucherSalesLine.Type::Payment;
            VoucherSalesLine."Voucher Type" := Voucher."Voucher Type";
            VoucherSalesLine."Voucher No." := Voucher."No.";
            VoucherSalesLine."Reference No." := Voucher."Reference No.";
            VoucherSalesLine.Description := Voucher.Description;
            VoucherSalesLine."NPR Inc Ecom Sales Pmt Line Id" := EcomSalesPmtLine.SystemId;
            VoucherSalesLine."NPR Inc Ecom Sale Id" := EcomSalesHeader.SystemId;
            VoucherSalesLine.Amount := EcomSalesPmtLine.Amount;
            VoucherSalesLine.Insert();
        end else begin
            VoucherSalesLine."NPR Inc Ecom Sales Pmt Line Id" := EcomSalesPmtLine.SystemId;
            VoucherSalesLine."NPR Inc Ecom Sale Id" := EcomSalesHeader.SystemId;
            VoucherSalesLine.Amount := EcomSalesPmtLine.Amount;
            VoucherSalesLine.Modify();
        end;

        EcomSalesDocApiEvents.OnAfterReserveVoucher(EcomSalesHeader, EcomSalesPmtLine, VoucherSalesLine);
    end;

    local procedure DeserializeIncomingEcomSalesLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesLineJsonToken: JsonToken; var EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        EcomSalesDocApiEvents: Codeunit "NPR EcomSalesDocApiEvents";
        JsonHelper: Codeunit "NPR Json Helper";
        LineTypeText: Text;
        PropertyErrorText: Label 'Property %1 has incorrect value: %2.', Comment = '%1 - absolute path, %2 - type', Locked = true;
        LengthErrorText: Label 'Property %1 has incorrect length: %2. Max length: %3', Comment = '%1 - absolute path, %2 - type', Locked = true;
    begin
        LineTypeText := JsonHelper.GetJText(SalesLineJsonToken, 'type', true);
        if not TryEvaluateIncSalesLineType(EcomSalesHeader, LineTypeText, EcomSalesLine.Type) then
            Error(PropertyErrorText, JsonHelper.GetAbsolutePath(SalesLineJsonToken, 'type'), LineTypeText);
#pragma warning disable AA0139
        case EcomSalesLine.Type of
            EcomSalesLine.Type::Item:
                begin
                    EcomSalesLine."No." := JsonHelper.GetJText(SalesLineJsonToken, 'no', MaxStrLen(EcomSalesLine."No."), true, false);
                    if Strlen(EcomSalesLine."No.") > 20 then
                        Error(LengthErrorText, JsonHelper.GetAbsolutePath(SalesLineJsonToken, 'no'), Strlen(EcomSalesLine."No."), 20);
                    EcomSalesLine."Variant Code" := JsonHelper.GetJText(SalesLineJsonToken, 'variantCode', MaxStrLen(EcomSalesLine."Variant Code"), true, false);
                    EcomSalesLine."Barcode No." := JsonHelper.GetJText(SalesLineJsonToken, 'barcodeNo', MaxStrLen(EcomSalesLine."Barcode No."), true, false);
                    if (EcomSalesLine."No." = '') and (EcomSalesLine."Barcode No." = '') then
                        Error(PropertyErrorText, JsonHelper.GetAbsolutePath(SalesLineJsonToken, 'no'), EcomSalesLine."No.");
                    EcomSalesLine.Description := JsonHelper.GetJText(SalesLineJsonToken, 'description', MaxStrLen(EcomSalesLine.Description), true, false);
                    EcomSalesLine."Unit Price" := JsonHelper.GetJDecimal(SalesLineJsonToken, 'unitPrice', true);
                    EcomSalesLine.Quantity := JsonHelper.GetJDecimal(SalesLineJsonToken, 'quantity', true);
                    EcomSalesLine."Unit Of Measure Code" := JsonHelper.GetJText(SalesLineJsonToken, 'unitOfMeasure', MaxStrLen(EcomSalesLine."Unit Of Measure Code"), true, false);
                    EcomSalesLine."VAT %" := JsonHelper.GetJDecimal(SalesLineJsonToken, 'vatPercent', true);
                    EcomSalesLine."Line Amount" := JsonHelper.GetJDecimal(SalesLineJsonToken, 'lineAmount', true);
                    EcomSalesLine."Requested Delivery Date" := JsonHelper.GetJDate(SalesLineJsonToken, 'requestedDeliveryDate', false);
                end;
            EcomSalesLine.Type::Comment:
                begin
                    EcomSalesLine.Description := JsonHelper.GetJText(SalesLineJsonToken, 'description', MaxStrLen(EcomSalesLine.Description), true, true);
                end;
            EcomSalesLine.Type::"Shipment Fee":
                begin
                    EcomSalesLine."No." := JsonHelper.GetJText(SalesLineJsonToken, 'no', MaxStrLen(EcomSalesLine."No."), true, false);
                    EcomSalesLine.Description := JsonHelper.GetJText(SalesLineJsonToken, 'description', MaxStrLen(EcomSalesLine.Description), true, true);
                    EcomSalesLine."Unit Price" := JsonHelper.GetJDecimal(SalesLineJsonToken, 'unitPrice', true);
                    EcomSalesLine.Quantity := JsonHelper.GetJDecimal(SalesLineJsonToken, 'quantity', true);
                    EcomSalesLine."VAT %" := JsonHelper.GetJDecimal(SalesLineJsonToken, 'vatPercent', true);
                    EcomSalesLine."Line Amount" := JsonHelper.GetJDecimal(SalesLineJsonToken, 'lineAmount', true);
                end;
            EcomSalesLine.Type::Voucher:
                begin
                    EcomSalesLine."Voucher Type" := JsonHelper.GetJText(SalesLineJsonToken, 'voucherType', MaxStrLen(EcomSalesLine."Voucher Type"), true, false);
                    EcomSalesLine."Barcode No." := JsonHelper.GetJText(SalesLineJsonToken, 'barcodeNo', MaxStrLen(EcomSalesLine."Barcode No."), true, false);
                    if (EcomSalesLine."Barcode No." = '') then
                        if (EcomSalesLine."Voucher Type" = '') then
                            Error(PropertyErrorText, JsonHelper.GetAbsolutePath(SalesLineJsonToken, 'barcodeNo'), EcomSalesLine."Barcode No.");
                    EcomSalesLine.Description := JsonHelper.GetJText(SalesLineJsonToken, 'description', MaxStrLen(EcomSalesLine.Description), true, true);
                    EcomSalesLine."Unit Price" := JsonHelper.GetJDecimal(SalesLineJsonToken, 'unitPrice', true);
                    EcomSalesLine.Quantity := JsonHelper.GetJDecimal(SalesLineJsonToken, 'quantity', true);
                    if EcomSalesLine.Quantity <> 1 then
                        Error(PropertyErrorText, JsonHelper.GetAbsolutePath(SalesLineJsonToken, 'quantity'), EcomSalesLine.Quantity);
                    EcomSalesLine."VAT %" := JsonHelper.GetJDecimal(SalesLineJsonToken, 'vatPercent', true);
                    EcomSalesLine."Line Amount" := JsonHelper.GetJDecimal(SalesLineJsonToken, 'lineAmount', true);
                end;
        end;


        EcomSalesDocApiEvents.OnAfterDeserializeIncomingEcomSalesLine(SalesLineJsonToken, EcomSalesLine);
#pragma warning restore AA0139
    end;

    [TryFunction]
    procedure TryEvaluateIncSalesLineType(EcomSalesHeader: Record "NPR Ecom Sales Header"; IncSalesLineTypeText: Text; var EcomSalesLineType: Enum "NPR Ecom Sales Line Type")
    var
        UnsupportedLineTypeTextErr: Label 'Sales line type %1 is not supported.', Comment = '%1 - sales line type', Locked = true;
        UnsupportedLineTypeReturnOrderTextErr: Label 'Sales line type %1 is not supported in documents with type returnOrder.', Comment = '%1 - sales line type', Locked = true;
    begin
        Case IncSalesLineTypeText of
            'item':
                EcomSalesLineType := EcomSalesLineType::Item;
            'comment':
                EcomSalesLineType := EcomSalesLineType::Comment;
            'shipmentFee':
                EcomSalesLineType := EcomSalesLineType::"Shipment Fee";
            'voucher':
                if EcomSalesHeader."Document Type" = EcomSalesHeader."Document Type"::Order then
                    EcomSalesLineType := EcomSalesLineType::Voucher
                else
                    Error(UnsupportedLineTypeReturnOrderTextErr, IncSalesLineTypeText);
            else
                Error(UnsupportedLineTypeTextErr, IncSalesLineTypeText);
        End;

    end;

    procedure GetSalesLineApiType(EcomSalesLine: Record "NPR Ecom Sales Line") IncSalesLineTypeText: Text
    var
        UnsupportedLineTypeTextErr: Label 'Sales line type %1 is not supported.', Comment = '%1 - sales line type', Locked = true;
    begin
        case EcomSalesLine.Type of
            EcomSalesLine.Type::Item:
                IncSalesLineTypeText := 'item';
            EcomSalesLine.Type::Comment:
                IncSalesLineTypeText := 'comment';
            EcomSalesLine.Type::"Shipment Fee":
                IncSalesLineTypeText := 'shipmentFee';
            EcomSalesLine.Type::Voucher:
                IncSalesLineTypeText := 'voucher';
            else
                Error(UnsupportedLineTypeTextErr, IncSalesLineTypeText);
        end;
    end;

    local procedure ProcessIncomingSalesPaymentLines(RequestBody: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        JsonHelper: Codeunit "NPR Json Helper";
        PaymentLineJsonToken: JsonToken;
        PaymentLinesJsonToken: JsonToken;
        PaymentLinesNoArrayErr: Label 'The payments property is not an array.', Locked = true;
    begin
        PaymentLinesJsonToken := JsonHelper.GetJsonToken(RequestBody, 'payments');

        if (not PaymentLinesJsonToken.IsArray()) then
            Error(PaymentLinesNoArrayErr);

        foreach PaymentLineJsonToken in PaymentLinesJsonToken.AsArray() do begin
            Clear(EcomSalesPmtLine);
            InsertIncomingSalesPaymentLine(PaymentLineJsonToken, EcomSalesHeader, EcomSalesPmtLine);
        end;
    end;

    local procedure InsertIncomingSalesPaymentLine(PaymentLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line")
    var
        PaymentMethod: Record "Payment Method";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        EcomSalesDocApiEvents: Codeunit "NPR EcomSalesDocApiEvents";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        ExternalPaymentMethodNotSetupErr: Label 'External payment method type: %1, external payment method code: %2 is not set up for payment.', Comment = '%1 - external payment method type, %2 - external payment method code', Locked = true;
        VoucherLbl: Label 'Voucher';
    begin
        EcomSalesPmtLine.Init();
        EcomSalesPmtLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesPmtLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesPmtLine."External Document No." := EcomSalesHeader."External No.";
        EcomSalesPmtLine."Line No." := EcomSalesDocUtils.GetSalesDocLastPaymentLineLineNo(EcomSalesHeader) + 10000;
        DeserializeIncomingEcomSalesPaymentLine(EcomSalesHeader, PaymentLineJsonToken, EcomSalesPmtLine);

        case EcomSalesPmtLine."Payment Method Type" of
            EcomSalesPmtLine."Payment Method Type"::"Payment Method":
                begin
                    if not TryGetPaymentMethod(EcomSalesPmtLine."External Payment Type", EcomSalesPmtLine."External Payment Method Code", PaymentMethod, PaymentMapping) then
                        Error(ExternalPaymentMethodNotSetupErr, EcomSalesPmtLine."External Payment Type", EcomSalesPmtLine."External Payment Method Code");
                    EcomSalesPmtLine.Description := CopyStr(PaymentMethod.Description + ' ' + EcomSalesHeader."External No.", 1, MaxStrLen(EcomSalesPmtLine.Description));

                end;
            EcomSalesPmtLine."Payment Method Type"::Voucher:
                begin
                    EcomSalesPmtLine.Description := CopyStr(VoucherLbl + ' ' + EcomSalesHeader."External No.", 1, MaxStrLen(EcomSalesPmtLine.Description));
                end;
        end;

        EcomSalesDocApiEvents.OnBeforeInsertIncomingSalesPaymentLineBeforeInsert(PaymentLineJsonToken, EcomSalesHeader, EcomSalesPmtLine);
        EcomSalesPmtLine.Insert(true);

        if EcomSalesPmtLine."Payment Method Type" = EcomSalesPmtLine."Payment Method Type"::Voucher then
            ReserveVoucher(EcomSalesHeader, EcomSalesPmtLine);
    end;

    local procedure DeserializeIncomingEcomSalesPaymentLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; PaymentLineJsonToken: JsonToken; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line")
    var
        JsonHelper: Codeunit "NPR Json Helper";
        EcomSalesDocApiEvents: Codeunit "NPR EcomSalesDocApiEvents";
        LineTypeText: Text;
        LineTypeErr: Label 'Property %1 has incorrect value: %2.', Comment = '%1 - abolute path, %2 - type', Locked = true;
    begin
        LineTypeText := JsonHelper.GetJText(PaymentLineJsonToken, 'paymentMethodType', true);
        if not TryEvaluateIncSalesPaymentLineType(EcomSalesHeader, LineTypeText, EcomSalesPmtLine."Payment Method Type") then
            Error(LineTypeErr, JsonHelper.GetAbsolutePath(PaymentLineJsonToken, 'paymentMethodType'), LineTypeText);

        case EcomSalesPmtLine."Payment Method Type" of
            EcomSalesPmtLine."Payment Method Type"::"Payment Method":
                begin
#pragma warning disable AA0139
                    EcomSalesPmtLine."Payment Reference" := JsonHelper.GetJText(PaymentLineJsonToken, 'paymentReference', MaxStrLen(EcomSalesPmtLine."Payment Reference"), true, false);
                    EcomSalesPmtLine.Amount := JsonHelper.GetJDecimal(PaymentLineJsonToken, 'paymentAmount', true);
                    EcomSalesPmtLine."PAR Token" := JsonHelper.GetJText(PaymentLineJsonToken, 'parToken', false);
                    EcomSalesPmtLine."PSP Token" := JsonHelper.GetJText(PaymentLineJsonToken, 'pspToken', false);
                    EcomSalesPmtLine."Card Expiry Date" := JsonHelper.GetJText(PaymentLineJsonToken, 'cardExpiryDate', false);
                    EcomSalesPmtLine."Card Brand" := JsonHelper.GetJText(PaymentLineJsonToken, 'cardBrand', false);
                    EcomSalesPmtLine."Masked Card Number" := JsonHelper.GetJText(PaymentLineJsonToken, 'maskedCardNumber', false);
                    EcomSalesPmtLine."External Payment Method Code" := JsonHelper.GetJText(PaymentLineJsonToken, 'externalPaymentMethodCode', MaxStrLen(EcomSalesPmtLine."External Payment Method Code"), true, true);
                    EcomSalesPmtLine."External Payment Type" := JsonHelper.GetJText(PaymentLineJsonToken, 'externalPaymentType', false);
                    EcomSalesPmtLine."Card Alias Token" := JsonHelper.GetJText(PaymentLineJsonToken, 'cardAliasToken', false);
#pragma warning restore AA0139
                end;
            EcomSalesPmtLine."Payment Method Type"::Voucher:
                begin
#pragma warning disable AA0139
                    EcomSalesPmtLine."Payment Reference" := JsonHelper.GetJText(PaymentLineJsonToken, 'paymentReference', MaxStrLen(EcomSalesPmtLine."Payment Reference"), true, true);
                    EcomSalesPmtLine.Amount := JsonHelper.GetJDecimal(PaymentLineJsonToken, 'paymentAmount', true);
#pragma warning restore AA0139
                end;
        end;

        EcomSalesDocApiEvents.OnAfterDeserializeIncomingEcomSalesPaymentLine(PaymentLineJsonToken, EcomSalesPmtLine);
    end;

    [TryFunction]
    procedure TryEvaluateIncSalesPaymentLineType(EcomSalesHeader: Record "NPR Ecom Sales Header"; IncSalesPaymentLineTypeText: Text; var PaymentType: Enum "NPR Ecom Pmt Method Type")
    var
        NotSupportPaymentTypeErr: Label 'Payment type: %1 is not supported.', Comment = '%1 - payment type', Locked = true;
        NotSupportPaymentTypeReturnOrderErr: Label 'Payment type: %1 is not supported in documents with type returnOrder.', Comment = '%1 - payment type', Locked = true;
    begin
        case IncSalesPaymentLineTypeText of
            'paymentGateway':
                PaymentType := PaymentType::"Payment Method";
            'voucher':
                if EcomSalesHeader."Document Type" = EcomSalesHeader."Document Type"::Order then
                    PaymentType := PaymentType::Voucher
                else
                    Error(NotSupportPaymentTypeReturnOrderErr, IncSalesPaymentLineTypeText);
            else
                Error(NotSupportPaymentTypeErr, IncSalesPaymentLineTypeText);
        end;
    end;

    [TryFunction]
    local procedure TryGetPaymentMethod(ExternalPaymentMethodType: Text[50]; ExternalPaymentMethodCode: Text[50]; var PaymentMethod: Record "Payment Method"; var PaymentMapping: Record "NPR Magento Payment Mapping")
    begin
        PaymentMapping.SetRange("External Payment Method Code", ExternalPaymentMethodCode);
        PaymentMapping.SetRange("External Payment Type", ExternalPaymentMethodType);
        PaymentMapping.SetLoadFields("Payment Method Code");
        if not PaymentMapping.FindFirst() then begin
            PaymentMapping.SetRange("External Payment Type");
            PaymentMapping.FindFirst();
        end;
        PaymentMapping.TestField("Payment Method Code");
        PaymentMethod.Get(PaymentMapping."Payment Method Code");
    end;

    local procedure ProcessIncomingSalesDocumentComments(RequestBody: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        JsonHelper: Codeunit "NPR Json Helper";
        CommentJsonToken: JsonToken;
        CommentsJsonToken: JsonToken;
        SalesLinesNoArrayErr: Label 'The comments property is not an array.', Locked = true;
    begin
        if not JsonHelper.GetJsonToken(RequestBody, 'comments', CommentsJsonToken) then
            exit;

        if (not CommentsJsonToken.IsArray()) then
            Error(SalesLinesNoArrayErr);

        foreach CommentJsonToken in CommentsJsonToken.AsArray() do
            InsertIncomingSalesDocumentComment(CommentJsonToken, EcomSalesHeader);
    end;

    local procedure InsertIncomingSalesDocumentComment(SalesLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        RecordLink: Record "Record Link";
        JsonHelper: Codeunit "NPR Json Helper";
        RecordLinkManagement: Codeunit "Record Link Management";
        EcomSalesDocApiEvents: Codeunit "NPR EcomSalesDocApiEvents";
        CommentLine: Text;
        Note: Text;
        LinkID: Integer;
    begin
        CommentLine := JsonHelper.GetJText(SalesLineJsonToken, 'comment', 0, true);
        if CommentLine = '' then
            exit;

        LinkID := EcomSalesHeader.AddLink('', EcomSalesHeader."External No.");
        RecordLink.Get(LinkID);
        RecordLink.Type := RecordLink.Type::Note;
        RecordLink."User ID" := '';
        Note := CommentLine;

        RecordLinkManagement.WriteNote(RecordLink, Note);
        EcomSalesDocApiEvents.OnBeforeModifyIncomingSalesDocumentCommentBeforeModifyRecordLink(SalesLineJsonToken, EcomSalesHeader, RecordLink);
        RecordLink.Modify(true);
    end;

    internal procedure GetSalesDocumentCreateResponse(EcomSalesHeader: Record "NPR Ecom Sales Header") IncSalesDocumentJsonObject: Codeunit "NPR Json Builder";
    var
        EcomSalesDocApiEvents: Codeunit "NPR EcomSalesDocApiEvents";
    begin
        IncSalesDocumentJsonObject.StartObject('salesDocument')
                                   .AddProperty('id', Format(EcomSalesHeader.SystemId, 0, 4).ToLower());
        EcomSalesDocApiEvents.OnGetSalesDocumentCreateResponseBeforeEndObject(EcomSalesHeader, IncSalesDocumentJsonObject);
        IncSalesDocumentJsonObject.EndObject();
    end;

    internal procedure GetSalesDocumentJsonObject(EcomSalesHeader: Record "NPR Ecom Sales Header") IncSalesDocumentJsonObject: Codeunit "NPR Json Builder";
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        RecordLink: Record "Record Link";
        EcomSalesDocApiEvents: Codeunit "NPR EcomSalesDocApiEvents";
        PaymentLineJsonObject: Codeunit "NPR Json Builder";
        SalesLineJsonObject: Codeunit "NPR Json Builder";
        CommentJsonObject: Codeunit "NPR Json Builder";
        EcomSalesHeaderCustomFieldsObject: Codeunit "NPR Json Builder";
    begin
        IncSalesDocumentJsonObject.StartObject('salesDocument')
                                 .AddProperty('externalNo', EcomSalesHeader."External No.")
                                 .AddProperty('id', Format(EcomSalesHeader.SystemId, 0, 4).ToLower())
                                 .AddProperty('documentType', GetSalesDocumentApiType(EcomSalesHeader))
                                 .AddProperty('creationStatus', GetSalesDocumentCreationStatusApiType(EcomSalesHeader))
                                 .AddProperty('postingStatus', GetSalesDocumentPostingStatusApiType(EcomSalesHeader))
                                 .AddProperty('currencyCode', EcomSalesHeader."Currency Code")
                                 .AddProperty('currencyExchangeRate', Format(EcomSalesHeader."Currency Exchange Rate", 0, 9))
                                 .AddProperty('externalDocumentNo', EcomSalesHeader."External Document No.")
                                 .AddProperty('yourReference', EcomSalesHeader."Your Reference")
                                 .AddProperty('locationCode', EcomSalesHeader."Location Code")
                                 .AddProperty('pricesExcludingVat', EcomSalesHeader."Price Excl. VAT")
                                 .AddProperty('captureProcessingStatus', GetSalesDocumentCaptureProcessingStatusApiType(EcomSalesHeader))
                                 .AddProperty('lastCaptureErrorMessage', EcomSalesHeader."Last Capture Error Message")
                                 .StartObject('sellToCustomer')
                                    .AddProperty('no', EcomSalesHeader."Sell-to Customer No.")
                                    .AddProperty('name', EcomSalesHeader."Sell-to Name")
                                    .AddProperty('address', EcomSalesHeader."Sell-to Address")
                                    .AddProperty('address2', EcomSalesHeader."Sell-to Address 2")
                                    .AddProperty('postCode', EcomSalesHeader."Sell-to Post Code")
                                    .AddProperty('county', EcomSalesHeader."Sell-to County")
                                    .AddProperty('city', EcomSalesHeader."Sell-to City")
                                    .AddProperty('countryCode', EcomSalesHeader."Sell-to Country Code")
                                    .AddProperty('contact', EcomSalesHeader."Sell-to Contact")
                                    .AddProperty('email', EcomSalesHeader."Sell-to Email")
                                    .AddProperty('phone', EcomSalesHeader."Sell-to Phone No.")
                                    .AddProperty('ean', EcomSalesHeader."Sell-to EAN")
                                    .AddProperty('vatRegistrationNo', EcomSalesHeader."Sell-to VAT Registration No.")
                                    .AddProperty('invoiceEmail', EcomSalesHeader."Sell-to Invoice Email")
                                .EndObject()
                                .StartObject('shipToCustomer')
                                    .AddProperty('name', EcomSalesHeader."Ship-to Name")
                                    .AddProperty('address', EcomSalesHeader."Ship-to Address")
                                    .AddProperty('address2', EcomSalesHeader."Ship-to Address 2")
                                    .AddProperty('postCode', EcomSalesHeader."Ship-to Post Code")
                                    .AddProperty('county', EcomSalesHeader."Ship-to County")
                                    .AddProperty('city', EcomSalesHeader."Ship-to City")
                                    .AddProperty('countryCode', EcomSalesHeader."Ship-to Country Code")
                                    .AddProperty('contact', EcomSalesHeader."Ship-to Contact")
                                .EndObject()
                                .StartObject('shipment')
                                    .AddProperty('shipmentMethod', EcomSalesHeader."Shipment Method Code")
                                    .AddProperty('shipmentService', EcomSalesHeader."Shipment Service")
                                .EndObject();

        EcomSalesDocApiEvents.OnGetSalesDocumentCustomFieldsJsonObject(EcomSalesHeader, EcomSalesHeaderCustomFieldsObject);
        if EcomSalesHeaderCustomFieldsObject.IsInitialized() then
            IncSalesDocumentJsonObject.AddNestedObject('customFields', EcomSalesHeaderCustomFieldsObject);

        RecordLink.Reset();
        RecordLink.SetRange("Record ID", EcomSalesHeader.RecordId);
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetAutoCalcFields(Note);
        RecordLink.SetLoadFields(Note);
        if RecordLink.FindSet() then begin
            IncSalesDocumentJsonObject.StartArray('comments');
            repeat
                CommentJsonObject := CreateAddCommentDocumentDetailsJsonObject(RecordLink, IncSalesDocumentJsonObject);
                IncSalesDocumentJsonObject.AddObject(CommentJsonObject);
            until RecordLink.Next() = 0;
            IncSalesDocumentJsonObject.EndArray();
        end;

        EcomSalesPmtLine.Reset();
        EcomSalesPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        if EcomSalesPmtLine.FindSet() then begin
            IncSalesDocumentJsonObject.StartArray('payments');
            repeat
                PaymentLineJsonObject := CreateAddPaymentDocumentDetailsJsonObject(EcomSalesPmtLine, IncSalesDocumentJsonObject);
                IncSalesDocumentJsonObject.AddObject(PaymentLineJsonObject);
            until EcomSalesPmtLine.Next() = 0;
            IncSalesDocumentJsonObject.EndArray();
        end;

        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        if EcomSalesLine.FindSet() then begin
            IncSalesDocumentJsonObject.StartArray('salesDocumentLines');
            repeat
                SalesLineJsonObject := CreateAddSalesLineDetailsJsonObject(EcomSalesLine, IncSalesDocumentJsonObject);
                IncSalesDocumentJsonObject.AddObject(SalesLineJsonObject);
            until EcomSalesLine.Next() = 0;
            IncSalesDocumentJsonObject.EndArray();
        end;

        IncSalesDocumentJsonObject.EndObject();
    end;

    internal procedure CreateAddPaymentDocumentDetailsJsonObject(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; var PaymentDocumentDetailsJsonObject: Codeunit "NPR Json Builder"): Codeunit "NPR Json Builder"
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesDocApiEvents: Codeunit "NPR EcomSalesDocApiEvents";
        PaymentDocumentDetailsCustomFieldsJsonObject: Codeunit "NPR Json Builder";
    begin
        PaymentDocumentDetailsJsonObject.StartObject()
                                        .AddProperty('id', Format(EcomSalesPmtLine.SystemId, 0, 4).ToLower())
                                        .AddProperty('paymentMethodType', GetPaymentMethodTypeJsonValue(EcomSalesPmtLine))
                                        .AddProperty('externalPaymentMethodCode', EcomSalesPmtLine."External Payment Method Code")
                                        .AddProperty('externalPaymentType', EcomSalesPmtLine."External Payment Type")
                                        .AddProperty('paymentReference', EcomSalesPmtLine."Payment Reference")
                                        .AddProperty('paymentAmount', Format(EcomSalesPmtLine.Amount, 0, 9))
                                        .AddProperty('pspToken', EcomSalesPmtLine."PSP Token")
                                        .AddProperty('cardExpiryDate', EcomSalesPmtLine."Card Expiry Date")
                                        .AddProperty('cardBrand', EcomSalesPmtLine."Card Brand")
                                        .AddProperty('maskedCardNumber', EcomSalesPmtLine."Masked Card Number")
                                        .AddProperty('parToken', (EcomSalesPmtLine."PAR Token"))
                                        .AddProperty('cardAliasToken', (EcomSalesPmtLine."Card Alias Token"))
                                        .AddProperty('capturedPaymentAmount', Format(EcomSalesPmtLine."Captured Amount", 0, 9));

        EcomSalesLine.SetRange("Created From Pmt. Line Id", EcomSalesPmtLine.SystemId);
        EcomSalesLine.SetLoadFields(SystemId);
        if EcomSalesLine.FindSet() then begin
            PaymentDocumentDetailsJsonObject.StartArray('paymentFees');
            repeat
                PaymentDocumentDetailsJsonObject.StartObject();
                PaymentDocumentDetailsJsonObject.AddProperty('paymentFeeId', Format(EcomSalesLine.SystemId, 0, 4).ToLower());
                PaymentDocumentDetailsJsonObject.EndObject();
            until EcomSalesLine.Next() = 0;
            PaymentDocumentDetailsJsonObject.EndArray();
        end;

        EcomSalesDocApiEvents.OnGetPaymentDocumentDetailsCustomFieldsJsonObject(EcomSalesPmtLine, PaymentDocumentDetailsCustomFieldsJsonObject);
        if PaymentDocumentDetailsCustomFieldsJsonObject.IsInitialized() then
            PaymentDocumentDetailsJsonObject.AddNestedObject('customFields', PaymentDocumentDetailsCustomFieldsJsonObject);
        PaymentDocumentDetailsJsonObject.EndObject();
    end;

    internal procedure CreateAddCommentDocumentDetailsJsonObject(RecordLink: Record "Record Link"; var CommentDocumentDetailsJsonObject: Codeunit "NPR Json Builder"): Codeunit "NPR Json Builder"
    var
        RecordLinkManagement: Codeunit "Record Link Management";
    begin
        CommentDocumentDetailsJsonObject.StartObject()
                                        .AddProperty('id', Format(RecordLink.SystemId, 0, 4).ToLower())
                                        .AddProperty('comment', RecordLinkManagement.ReadNote(RecordLink));
        CommentDocumentDetailsJsonObject.EndObject();
    end;

    internal procedure CreateAddSalesLineDetailsJsonObject(EcomSalesLine: Record "NPR Ecom Sales Line"; var SalesLineDetailsJsonObject: Codeunit "NPR Json Builder"): Codeunit "NPR Json Builder"
    var
        EcomSalesDocApiEvents: Codeunit "NPR EcomSalesDocApiEvents";
        SalesLineDetailsCustomFieldsJsonObject: Codeunit "NPR Json Builder";
    begin
        SalesLineDetailsJsonObject.StartObject()
                                  .AddProperty('id', Format(EcomSalesLine.SystemId, 0, 4).ToLower())
                                  .AddProperty('type', GetSalesLineApiType(EcomSalesLine))
                                  .AddProperty('no', EcomSalesLine."No.")
                                  .AddProperty('variantCode', EcomSalesLine."Variant Code")
                                  .AddProperty('barcodeNo', EcomSalesLine."Barcode No.")
                                  .AddProperty('description', EcomSalesLine.Description)
                                  .AddProperty('unitPrice', Format(EcomSalesLine."Unit Price", 0, 9))
                                  .AddProperty('quantity', Format(EcomSalesLine.Quantity, 0, 9))
                                  .AddProperty('unitOfMeasure', Format(EcomSalesLine."Unit of Measure Code", 0, 9))
                                  .AddProperty('vatPercent', Format(EcomSalesLine."VAT %", 0, 9))
                                  .AddProperty('lineAmount', Format(EcomSalesLine."Line Amount", 0, 9))
                                  .AddProperty('requestedDeliveryDate', Format(EcomSalesLine."Requested Delivery Date", 0, 9))
                                  .AddProperty('invoicedQuantity', Format(EcomSalesLine."Invoiced Qty.", 0, 9))
                                  .AddProperty('invoicedAmount', Format(EcomSalesLine."Invoiced Amount", 0, 9))
                                  .AddProperty('captured', EcomSalesLine.Captured)
                                  .AddProperty('virtualItemProcessStatus', GetVirtualItemProcessStatusApiType(EcomSalesLine))
                                  .AddProperty('virtualItemProcessErrorMessage', EcomSalesLine."Virtual Item Process ErrMsg");
        EcomSalesDocApiEvents.OnCreateAddSalesLineDetailsCustomFieldsJsonObject(EcomSalesLine, SalesLineDetailsCustomFieldsJsonObject);
        if SalesLineDetailsCustomFieldsJsonObject.IsInitialized() then
            SalesLineDetailsJsonObject.AddNestedObject('customFields', SalesLineDetailsCustomFieldsJsonObject);
        SalesLineDetailsJsonObject.EndObject();
    end;


    local procedure GetPaymentMethodTypeJsonValue(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line") PaymentMethodTypeJsonValue: Text
    var
        NotSupportedStatusErrorLbl: Label 'Payment Method Type: %1 is not supported.', Comment = '%1 - Payment Method Type', Locked = true;
    begin
        case EcomSalesPmtLine."Payment Method Type" of
            EcomSalesPmtLine."Payment Method Type"::"Payment Method":
                PaymentMethodTypeJsonValue := 'paymentGateway';
            else
                Error(NotSupportedStatusErrorLbl, EcomSalesPmtLine."Payment Method Type");
        end;
    end;

    local procedure GetSalesDocumentCreationStatusApiType(EcomSalesHeader: Record "NPR Ecom Sales Header") SalesDocumenttatusApiType: Text
    var
        NotSupportedStatusErrorLbl: Label 'Sales document creation status: %1 is not supported.', Comment = '%1 - status', Locked = true;
    begin
        case EcomSalesHeader."Creation Status" of
            EcomSalesHeader."Creation Status"::Created:
                SalesDocumenttatusApiType := 'created';
            EcomSalesHeader."Creation Status"::Error:
                SalesDocumenttatusApiType := 'error';
            EcomSalesHeader."Creation Status"::Pending:
                SalesDocumenttatusApiType := 'pending';
            else
                Error(NotSupportedStatusErrorLbl, EcomSalesHeader."Creation Status");
        end;
    end;

    local procedure GetSalesDocumentApiType(EcomSalesHeader: Record "NPR Ecom Sales Header") SalesDocumentApiType: Text
    begin
        case EcomSalesHeader."Document Type" of
            EcomSalesHeader."Document Type"::Order:
                SalesDocumentApiType := 'order';
            EcomSalesHeader."Document Type"::"Return Order":
                SalesDocumentApiType := 'returnOrder';
        end;
    end;

    local procedure GetSalesDocumentPostingStatusApiType(EcomSalesHeader: Record "NPR Ecom Sales Header") SalesDocumentStatusApiType: Text
    var
        NotSupportedStatusErrorLbl: Label 'Sales document posting status: %1 is not supported.', Comment = '%1 - status', Locked = true;
    begin
        case EcomSalesHeader."Posting Status" of
            EcomSalesHeader."Posting Status"::"Partially Invoiced":
                SalesDocumentStatusApiType := 'partiallyInvoiced';
            EcomSalesHeader."Posting Status"::Invoiced:
                SalesDocumentStatusApiType := 'invoiced';
            EcomSalesHeader."Posting Status"::Pending:
                SalesDocumentStatusApiType := 'pending';
            else
                Error(NotSupportedStatusErrorLbl, EcomSalesHeader."Posting Status");
        end;
    end;

    local procedure GetTableIds() TableIds: List of [Integer]
    begin
        TableIds.Add(Database::"NPR Ecom Sales Pmt. Line");
        TableIds.Add(Database::"NPR Ecom Sales Line");
        TableIds.Add(Database::"NPR Ecom Sales Header");
    end;

    internal procedure GetEcomDocumentTypeFromRequest(RequestBody: JsonToken) EcomSalesDocType: Enum "NPR Ecom Sales Doc Type"
    var
        JsonHelper: Codeunit "NPR Json Helper";
        EcomDocumentTypeText: Text;
        UnsupportedDocumentTypeError: Label '%1 has unsupported value: %2.', Comment = '%1 - absolute path, %2 - document type', Locked = true;
    begin
        EcomDocumentTypeText := JsonHelper.GetJText(RequestBody, 'documentType', true);
        case EcomDocumentTypeText of
            'order':
                EcomSalesDocType := EcomSalesDocType::Order;
            'returnOrder':
                EcomSalesDocType := EcomSalesDocType::"Return Order"
            else
                Error(UnsupportedDocumentTypeError, JsonHelper.GetAbsolutePath(RequestBody, 'documentType'), EcomDocumentTypeText);
        end;
    end;

    internal procedure AssignBucketId(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
    begin
        EcomSalesHeader."Bucket Id" := EcomVirtualItemMgt.AssignBucketLines(EcomSalesHeader);
        EcomSalesHeader.Modify();
    end;

    internal procedure PreProcessDocument(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
    begin
        if EcomSalesHeader."Virtual Items Exist" then begin
            EcomVirtualItemMgt.CaptureEcomDocument(EcomSalesHeader, false, false);
            EcomVirtualItemMgt.CreateVouchers(EcomSalesHeader, false, false);
        end;
        CreateDocument(EcomSalesHeader)
    end;


    local procedure CreateDocument(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesDocProcess: Codeunit "NPR EcomSalesDocProcess";
    begin
        if EcomSalesHeader."Creation Status" = EcomSalesHeader."Creation Status"::Created then
            exit;

        //Process document
        EcomSalesHeader.Get(EcomSalesHeader.RecordId);
        Clear(EcomSalesDocProcess);
        EcomSalesDocProcess.SetShowError(false);
        EcomSalesDocProcess.SetUpdateRetryCount(false);
        EcomSalesDocProcess.Run(EcomSalesHeader);
    end;

    local procedure GetSalesDocumentCaptureProcessingStatusApiType(EcomSalesHeader: Record "NPR Ecom Sales Header") CaptureProcessingStatus: Text
    begin
        case EcomSalesHeader."Capture Processing Status" of
            EcomSalesHeader."Capture Processing Status"::Error:
                CaptureProcessingStatus := 'error';
            EcomSalesHeader."Capture Processing Status"::"Partially Processed":
                CaptureProcessingStatus := 'partiallyProcessed';
            EcomSalesHeader."Capture Processing Status"::Processed:
                CaptureProcessingStatus := 'processed';
            EcomSalesHeader."Capture Processing Status"::Pending:
                CaptureProcessingStatus := 'pending';
        end;
    end;

    local procedure GetVirtualItemProcessStatusApiType(EcomSalesLine: Record "NPR Ecom Sales Line") VirtualItemProcessStatus: Text
    begin
        case EcomSalesLine."Virtual Item Process Status" of
            EcomSalesLine."Virtual Item Process Status"::" ":
                VirtualItemProcessStatus := '';
            EcomSalesLine."Virtual Item Process Status"::Processed:
                VirtualItemProcessStatus := 'processed';
            EcomSalesLine."Virtual Item Process Status"::Error:
                VirtualItemProcessStatus := 'error';
        end;
    end;

    local procedure ValidatePhoneNumber(PhoneNo: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        InvalidPhoneErr: Label 'Invalid phone number format.';
    begin
        if PhoneNo = '' then
            exit;
        if not TypeHelper.IsPhoneNumber(PhoneNo) then
            Error(InvalidPhoneErr);
    end;
}
#endif