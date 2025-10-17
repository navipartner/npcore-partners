#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248594 "NPR IncEcomSalesDocApiAgentV2"
{
    Access = Internal;
    internal procedure CreateIncomingEcomDocument(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header";
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        IncEcomSalesDocProcess: Codeunit "NPR IncEcomSalesDocProcess";
    begin
        Request.SkipCacheIfNonStickyRequest(GetTableIds());
        InsertSalesDocument(Request, IncEcomSalesHeader);

        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();

        IncEcomSalesHeader.Get(IncEcomSalesHeader.RecordId);
        if (IncEcomSalesDocSetup."Proc Sales Order On Receive" and (IncEcomSalesHeader."Document Type" = IncEcomSalesHeader."Document Type"::Order)) or
           (IncEcomSalesDocSetup."Proc Sales Ret Ord On Receive" and (IncEcomSalesHeader."Document Type" = IncEcomSalesHeader."Document Type"::"Return Order"))
        then begin
            Clear(IncEcomSalesDocProcess);
            IncEcomSalesDocProcess.SetUpdateRetryCount(true);
            IncEcomSalesDocProcess.Run(IncEcomSalesHeader);
        end;

        exit(Response.RespondOK(GetSalesDocumentCreateResponse(IncEcomSalesHeader)));
    end;

    internal procedure GetIncomingEcomDocumentById(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header";
        DocumentIdText: Text;
        DocumentId: Guid;
    begin
        Request.SkipCacheIfNonStickyRequest(GetTableIds());
        if (not Request.Paths().Get(3, DocumentIdText)) then
            exit(Response.RespondBadRequest('Missing required parameter: documentId'));

        if (not Evaluate(DocumentId, DocumentIdText)) then
            exit(Response.RespondBadRequest('Malformed parameter: documentId'));

        IncEcomSalesHeader.ReadIsolation := IncEcomSalesHeader.ReadIsolation::ReadCommitted;
        if (not IncEcomSalesHeader.GetBySystemId(DocumentId)) then
            exit(Response.RespondResourceNotFound());

        exit(Response.RespondOK(GetSalesDocumentJsonObject(IncEcomSalesHeader)));
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure InsertSalesDocument(var Request: Codeunit "NPR API Request"; var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header")
    var
        RequestBody: JsonToken;
        RequestedApiVersion: Date;
    begin
        RequestBody := Request.BodyJson();
        RequestedApiVersion := Request.ApiVersion();
        ProcessIncomingSalesHeader(RequestBody, IncEcomSalesHeader, RequestedApiVersion);
        ProcessIncomingSalesLines(RequestBody, IncEcomSalesHeader);
        ProcessIncomingSalesPaymentLines(RequestBody, IncEcomSalesHeader);
        ProcessIncomingSalesDocumentComments(RequestBody, IncEcomSalesHeader);
    end;

    local procedure DeserializeIncomingEcomSalesHeader(RequestBody: JsonToken; var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header");
    var
        JsonHelper: Codeunit "NPR Json Helper";
        IncEcomSalesDocApiEvents: Codeunit "NPR IncEcomSalesDocApiEvents";
        IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
        SalesDocToJsonToken: JsonToken;
        SellToCustomerJsonToken: JsonToken;
        ShipmentJsonToken: JsonToken;
        ShipToJsonToken: JsonToken;
    begin
#pragma warning disable AA0139

        SalesDocToJsonToken := RequestBody;
        IncEcomSalesHeader."External No." := JsonHelper.GetJText(RequestBody, 'externalNo', MaxStrLen(IncEcomSalesHeader."External No."), true, true);
        IncEcomSalesHeader."Document Type" := GetEcomDocumentTypeFromRequest(RequestBody);
        IncEcomSalesDocUtils.CheckIncomingSalesDocumentAlreadyExists(IncEcomSalesHeader."Document Type", IncEcomSalesHeader."External No.");

        IncEcomSalesHeader."Currency Code" := JsonHelper.GetJText(RequestBody, 'currencyCode', MaxStrLen(IncEcomSalesHeader."Currency Code"), true, false);

        if IncEcomSalesHeader."Document Type" = IncEcomSalesHeader."Document Type"::Order then begin
            if IncEcomSalesHeader."Currency Code" <> '' then
                IncEcomSalesHeader."Currency Exchange Rate" := JsonHelper.GetJDecimal(RequestBody, 'currencyExchangeRate', false);
        end;

        IncEcomSalesHeader."External Document No." := JsonHelper.GetJText(RequestBody, 'externalDocumentNo', MaxStrLen(IncEcomSalesHeader."External Document No."), true, false);
        IncEcomSalesHeader."Your Reference" := JsonHelper.GetJText(RequestBody, 'yourReference', MaxStrLen(IncEcomSalesHeader."Your Reference"), true, false);
        IncEcomSalesHeader."Location Code." := JsonHelper.GetJText(RequestBody, 'locationCode', MaxStrLen(IncEcomSalesHeader."Location Code."), true, false);
        IncEcomSalesHeader."Price Excl. VAT" := JsonHelper.GetJBoolean(RequestBody, 'pricesExcludingVat', false);

        //Sell-to
        SellToCustomerJsonToken := JsonHelper.GetJsonToken(RequestBody, 'sellToCustomer');
        IncEcomSalesHeader."Sell-to Customer No." := JsonHelper.GetJText(RequestBody, 'sellToCustomer.no', MaxStrLen(IncEcomSalesHeader."Sell-to Customer No."), true, false);
        IncEcomSalesHeader."Customer Template" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.customerTemplate', MaxStrLen(IncEcomSalesHeader."Customer Template"), true, false);
        IncEcomSalesHeader."Configuration Template" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.configurationTemplate', MaxStrLen(IncEcomSalesHeader."Configuration Template"), true, false);
        IncEcomSalesHeader."Sell-to Name" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.name', MaxStrLen(IncEcomSalesHeader."Sell-to Name"), true, true);
        IncEcomSalesHeader."Sell-to Address" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.address', MaxStrLen(IncEcomSalesHeader."Sell-to Address"), true, true);
        IncEcomSalesHeader."Sell-to Address 2" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.address2', MaxStrLen(IncEcomSalesHeader."Sell-to Address 2"), true, false);
        IncEcomSalesHeader."Sell-to Post Code" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.postCode', MaxStrLen(IncEcomSalesHeader."Sell-to Post Code"), true, true);
        IncEcomSalesHeader."Sell-to County" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.county', MaxStrLen(IncEcomSalesHeader."Sell-to County"), true, false);
        IncEcomSalesHeader."Sell-to City" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.city', MaxStrLen(IncEcomSalesHeader."Sell-to City"), true, true);
        IncEcomSalesHeader."Sell-to Country Code" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.countryCode', MaxStrLen(IncEcomSalesHeader."Sell-to Country Code"), true, true);
        IncEcomSalesHeader."Sell-to Contact" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.contact', MaxStrLen(IncEcomSalesHeader."Sell-to Contact"), true, false);
        IncEcomSalesHeader."Sell-to Email" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.email', MaxStrLen(IncEcomSalesHeader."Sell-to Email"), true, true);
        IncEcomSalesHeader."Sell-to Phone No." := JsonHelper.GetJText(RequestBody, 'sellToCustomer.phone', MaxStrLen(IncEcomSalesHeader."Sell-to Phone No."), true, false);
        IncEcomSalesHeader."Sell-to EAN" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.ean', MaxStrLen(IncEcomSalesHeader."Sell-to EAN"), true, false);
        IncEcomSalesHeader."Sell-to VAT Registration No." := JsonHelper.GetJText(RequestBody, 'sellToCustomer.vatRegistrationNo', MaxStrLen(IncEcomSalesHeader."Sell-to VAT Registration No."), true, false);

        if IncEcomSalesHeader."Document Type" = IncEcomSalesHeader."Document Type"::Order then
            IncEcomSalesHeader."Sell-to Invoice Email" := JsonHelper.GetJText(RequestBody, 'sellToCustomer.invoiceEmail', MaxStrLen(IncEcomSalesHeader."Sell-to Invoice Email"), true, false);

        //Ship-to
        if JsonHelper.GetJsonToken(RequestBody, 'shipToCustomer', ShipToJsonToken) then begin
            IncEcomSalesHeader."Ship-to Name" := JsonHelper.GetJText(RequestBody, 'shipToCustomer.name', MaxStrLen(IncEcomSalesHeader."Ship-to Name"), true, true);
            IncEcomSalesHeader."Ship-to Address" := JsonHelper.GetJText(RequestBody, 'shipToCustomer.address', MaxStrLen(IncEcomSalesHeader."Ship-to Address"), true, true);
            IncEcomSalesHeader."Ship-to Address 2" := JsonHelper.GetJText(RequestBody, 'shipToCustomer.address2', MaxStrLen(IncEcomSalesHeader."Ship-to Address 2"), true, false);
            IncEcomSalesHeader."Ship-to Post Code" := JsonHelper.GetJText(RequestBody, 'shipToCustomer.postCode', MaxStrLen(IncEcomSalesHeader."Ship-to Post Code"), true, true);
            IncEcomSalesHeader."Ship-to County" := JsonHelper.GetJText(RequestBody, 'shipToCustomer.county', MaxStrLen(IncEcomSalesHeader."Ship-to County"), true, false);
            IncEcomSalesHeader."Ship-to City" := JsonHelper.GetJText(RequestBody, 'shipToCustomer.city', MaxStrLen(IncEcomSalesHeader."Ship-to City"), true, true);
            IncEcomSalesHeader."Ship-to Country Code" := JsonHelper.GetJText(RequestBody, 'shipToCustomer.countryCode', MaxStrLen(IncEcomSalesHeader."Ship-to Country Code"), true, false);
            IncEcomSalesHeader."Ship-to Contact" := JsonHelper.GetJText(RequestBody, 'shipToCustomer.contact', MaxStrLen(IncEcomSalesHeader."Ship-to Contact"), true, false);
        end;

        //Shipment
        if JsonHelper.GetJsonToken(RequestBody, 'shipment', ShipmentJsonToken) then begin
            IncEcomSalesHeader."Shipment Method Code" := JsonHelper.GetJText(RequestBody, 'shipment.shipmentMethod', MaxStrLen(IncEcomSalesHeader."Shipment Method Code"), true, true);
            IncEcomSalesHeader."Shipment Service" := JsonHelper.GetJText(RequestBody, 'shipment.shipmentService', MaxStrLen(IncEcomSalesHeader."Shipment Service"), true, false);
        end;

        IncEcomSalesDocApiEvents.OnAfterDeserializeIncomingEcomSalesHeader(IncEcomSalesHeader, RequestBody);
#pragma warning restore AA0139
    end;

    local procedure ProcessIncomingSalesHeader(Request: JsonToken; var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; RequestedApiVersion: Date);
    begin
        InsertIncomingSalesHeader(Request, IncEcomSalesHeader, RequestedApiVersion);
    end;

    local procedure InsertIncomingSalesHeader(Request: JsonToken; var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; RequestedApiVersion: Date)
    var
        IncEcomSalesDocApiEvents: Codeunit "NPR IncEcomSalesDocApiEvents";
        IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
    begin
        IncEcomSalesHeader.Init();
        DeserializeIncomingEcomSalesHeader(Request, IncEcomSalesHeader);
        IncEcomSalesHeader."Received Date" := Today;
        IncEcomSalesHeader."Received Time" := Time;
        IncEcomSalesHeader."Requested API Version Date" := RequestedApiVersion;
        IncEcomSalesHeader."API Version Date" := IncEcomSalesDocUtils.GetApiVersionDateByRequest(RequestedApiVersion);
        IncEcomSalesDocApiEvents.OnBeforeProcessIncomingSalesHeaderInsertIncSalesHeader(IncEcomSalesHeader, Request);
        IncEcomSalesHeader.Insert(true);
    end;

    local procedure ProcessIncomingSalesLines(RequestBody: JsonToken; IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header")
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
            InsertIncomingSalesLine(SalesLineJsonToken, IncEcomSalesHeader);
    end;

    local procedure InsertIncomingSalesLine(SalesLineJsonToken: JsonToken; IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header")
    var
        IncEcomSalesLine: Record "NPR Inc Ecom Sales Line";
        IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
        IncEcomSalesDocApiEvents: Codeunit "NPR IncEcomSalesDocApiEvents";
    begin
        IncEcomSalesLine.Init();
        IncEcomSalesLine."Document Type" := IncEcomSalesHeader."Document Type";
        IncEcomSalesLine."External Document No." := IncEcomSalesHeader."External No.";
        IncEcomSalesLine."Line No." := IncEcomSalesDocUtils.GetSalesDocLastSalesLineLineNo(IncEcomSalesHeader) + 10000;
        DeserializeIncomingEcomSalesLine(IncEcomSalesHeader, SalesLineJsonToken, IncEcomSalesLine);
        IncEcomSalesDocApiEvents.OnBeforeInsertIncomingSalesLineBeforeInsert(SalesLineJsonToken, IncEcomSalesHeader, IncEcomSalesLine);
        IncEcomSalesLine.Insert(true);
    end;

    local procedure DeserializeIncomingEcomSalesLine(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; SalesLineJsonToken: JsonToken; var IncEcomSalesLine: Record "NPR Inc Ecom Sales Line")
    var
        IncEcomSalesDocApiEvents: Codeunit "NPR IncEcomSalesDocApiEvents";
        JsonHelper: Codeunit "NPR Json Helper";
        LineTypeText: Text;
        PropertyErrorText: Label 'Property %1 has incorrect value: %2.', Comment = '%1 - absolute path, %2 - type', Locked = true;
    begin
        LineTypeText := JsonHelper.GetJText(SalesLineJsonToken, 'type', true);
        if not TryEvaluateIncSalesLineType(IncEcomSalesHeader, LineTypeText, IncEcomSalesLine.Type) then
            Error(PropertyErrorText, JsonHelper.GetAbsolutePath(SalesLineJsonToken, 'type'), LineTypeText);
#pragma warning disable AA0139
        case IncEcomSalesLine.Type of
            IncEcomSalesLine.Type::Item:
                begin
                    IncEcomSalesLine."No." := JsonHelper.GetJText(SalesLineJsonToken, 'no', MaxStrLen(IncEcomSalesLine."No."), true, false);
                    IncEcomSalesLine."Variant Code" := JsonHelper.GetJText(SalesLineJsonToken, 'variantCode', MaxStrLen(IncEcomSalesLine."Variant Code"), true, false);
                    IncEcomSalesLine."Barcode No." := JsonHelper.GetJText(SalesLineJsonToken, 'barcodeNo', MaxStrLen(IncEcomSalesLine."Barcode No."), true, false);
                    if (IncEcomSalesLine."No." = '') and (IncEcomSalesLine."Barcode No." = '') then
                        Error(PropertyErrorText, JsonHelper.GetAbsolutePath(SalesLineJsonToken, 'no'), IncEcomSalesLine."No.");
                    IncEcomSalesLine.Description := JsonHelper.GetJText(SalesLineJsonToken, 'description', MaxStrLen(IncEcomSalesLine.Description), true, false);
                    IncEcomSalesLine."Unit Price" := JsonHelper.GetJDecimal(SalesLineJsonToken, 'unitPrice', true);
                    IncEcomSalesLine.Quantity := JsonHelper.GetJDecimal(SalesLineJsonToken, 'quantity', true);
                    IncEcomSalesLine."Unit Of Measure Code" := JsonHelper.GetJText(SalesLineJsonToken, 'unitOfMeasure', MaxStrLen(IncEcomSalesLine."Unit Of Measure Code"), true, false);
                    IncEcomSalesLine."VAT %" := JsonHelper.GetJDecimal(SalesLineJsonToken, 'vatPercent', true);
                    IncEcomSalesLine."Line Amount" := JsonHelper.GetJDecimal(SalesLineJsonToken, 'lineAmount', true);
                    IncEcomSalesLine."Requested Delivery Date" := JsonHelper.GetJDate(SalesLineJsonToken, 'requestedDeliveryDate', false);
                end;
            IncEcomSalesLine.Type::Comment:
                begin
                    IncEcomSalesLine.Description := JsonHelper.GetJText(SalesLineJsonToken, 'description', MaxStrLen(IncEcomSalesLine.Description), true, true);
                end;
            IncEcomSalesLine.Type::"Shipment Fee":
                begin
                    IncEcomSalesLine."No." := JsonHelper.GetJText(SalesLineJsonToken, 'no', MaxStrLen(IncEcomSalesLine."No."), true, false);
                    IncEcomSalesLine.Description := JsonHelper.GetJText(SalesLineJsonToken, 'description', MaxStrLen(IncEcomSalesLine.Description), true, true);
                    IncEcomSalesLine."Unit Price" := JsonHelper.GetJDecimal(SalesLineJsonToken, 'unitPrice', true);
                    IncEcomSalesLine.Quantity := JsonHelper.GetJDecimal(SalesLineJsonToken, 'quantity', true);
                    IncEcomSalesLine."VAT %" := JsonHelper.GetJDecimal(SalesLineJsonToken, 'vatPercent', true);
                    IncEcomSalesLine."Line Amount" := JsonHelper.GetJDecimal(SalesLineJsonToken, 'lineAmount', true);
                end;
        end;


        IncEcomSalesDocApiEvents.OnAfterDeserializeIncomingEcomSalesLine(SalesLineJsonToken, IncEcomSalesLine);
#pragma warning restore AA0139
    end;

    [TryFunction]
    procedure TryEvaluateIncSalesLineType(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; IncSalesLineTypeText: Text; var IncEcomSalesLineType: Enum "NPR Inc Ecom Sales Line Type")
    var
        UnsupportedLineTypeTextErr: Label 'Sales line type %1 is not supported.', Comment = '%1 - sales line type', Locked = true;
    begin
        Case IncSalesLineTypeText of
            'item':
                IncEcomSalesLineType := IncEcomSalesLineType::Item;
            'comment':
                IncEcomSalesLineType := IncEcomSalesLineType::Comment;
            'shipmentFee':
                IncEcomSalesLineType := IncEcomSalesLineType::"Shipment Fee";
            else
                Error(UnsupportedLineTypeTextErr, IncSalesLineTypeText);
        End;

    end;

    procedure GetSalesLineApiType(IncEcomSalesLine: Record "NPR Inc Ecom Sales Line") IncSalesLineTypeText: Text
    var
        UnsupportedLineTypeTextErr: Label 'Sales line type %1 is not supported.', Comment = '%1 - sales line type', Locked = true;
    begin
        case IncEcomSalesLine.Type of
            IncEcomSalesLine.Type::Item:
                IncSalesLineTypeText := 'item';
            IncEcomSalesLine.Type::Comment:
                IncSalesLineTypeText := 'comment';
            IncEcomSalesLine.Type::"Shipment Fee":
                IncSalesLineTypeText := 'shipmentFee';
            else
                Error(UnsupportedLineTypeTextErr, IncSalesLineTypeText);
        end;
    end;

    local procedure ProcessIncomingSalesPaymentLines(RequestBody: JsonToken; IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header")
    var
        IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line";
        JsonHelper: Codeunit "NPR Json Helper";
        PaymentLineJsonToken: JsonToken;
        PaymentLinesJsonToken: JsonToken;
        PaymentLinesNoArrayErr: Label 'The payments property is not an array.', Locked = true;
    begin
        PaymentLinesJsonToken := JsonHelper.GetJsonToken(RequestBody, 'payments');

        if (not PaymentLinesJsonToken.IsArray()) then
            Error(PaymentLinesNoArrayErr);

        foreach PaymentLineJsonToken in PaymentLinesJsonToken.AsArray() do begin
            Clear(IncEcomSalesPmtLine);
            InsertIncomingSalesPaymentLine(PaymentLineJsonToken, IncEcomSalesHeader, IncEcomSalesPmtLine);
        end;
    end;

    local procedure InsertIncomingSalesPaymentLine(PaymentLineJsonToken: JsonToken; IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line")
    var
        PaymentMethod: Record "Payment Method";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        IncEcomSalesDocApiEvents: Codeunit "NPR IncEcomSalesDocApiEvents";
        IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
        ExternalPaymentMethodNotSetupErr: Label 'External payment method type: %1, external payment method code: %2 is not set up for payment.', Comment = '%1 - external payment method type, %2 - external payment method code', Locked = true;
    begin
        IncEcomSalesPmtLine.Init();
        IncEcomSalesPmtLine."Document Type" := IncEcomSalesHeader."Document Type";
        IncEcomSalesPmtLine."External Document No." := IncEcomSalesHeader."External No.";
        IncEcomSalesPmtLine."Line No." := IncEcomSalesDocUtils.GetSalesDocLastPaymentLineLineNo(IncEcomSalesHeader) + 10000;
        DeserializeIncomingEcomSalesPaymentLine(IncEcomSalesHeader, PaymentLineJsonToken, IncEcomSalesPmtLine);

        if not TryGetPaymentMethod(IncEcomSalesPmtLine."External Paymment Type", IncEcomSalesPmtLine."External Payment Method Code", PaymentMethod, PaymentMapping) then
            Error(ExternalPaymentMethodNotSetupErr, IncEcomSalesPmtLine."External Paymment Type", IncEcomSalesPmtLine."External Payment Method Code");

        IncEcomSalesPmtLine.Description := CopyStr(PaymentMethod.Description + ' ' + IncEcomSalesHeader."External No.", 1, MaxStrLen(IncEcomSalesPmtLine.Description));
        IncEcomSalesDocApiEvents.OnBeforeInsertIncomingSalesPaymentLineBeforeInsert(PaymentLineJsonToken, IncEcomSalesHeader, IncEcomSalesPmtLine);
        IncEcomSalesPmtLine.Insert(true);
    end;

    local procedure DeserializeIncomingEcomSalesPaymentLine(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; PaymentLineJsonToken: JsonToken; var IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line")
    var
        JsonHelper: Codeunit "NPR Json Helper";
        IncEcomSalesDocApiEvents: Codeunit "NPR IncEcomSalesDocApiEvents";
        LineTypeText: Text;
        LineTypeErr: Label 'Property %1 has incorrect value: %2.', Comment = '%1 - abolute path, %2 - type', Locked = true;
    begin
        LineTypeText := JsonHelper.GetJText(PaymentLineJsonToken, 'paymentMethodType', true);
        if not TryEvaluateIncSalesPaymentLineType(IncEcomSalesHeader, LineTypeText, IncEcomSalesPmtLine."Payment Method Type") then
            Error(LineTypeErr, JsonHelper.GetAbsolutePath(PaymentLineJsonToken, 'paymentMethodType'), LineTypeText);

        case IncEcomSalesPmtLine."Payment Method Type" of
            IncEcomSalesPmtLine."Payment Method Type"::"Payment Method":
                begin
#pragma warning disable AA0139
                    IncEcomSalesPmtLine."Payment Reference" := JsonHelper.GetJText(PaymentLineJsonToken, 'paymentReference', MaxStrLen(IncEcomSalesPmtLine."Payment Reference"), true, false);
                    IncEcomSalesPmtLine.Amount := JsonHelper.GetJDecimal(PaymentLineJsonToken, 'paymentAmount', true);
                    IncEcomSalesPmtLine."PAR Token" := JsonHelper.GetJText(PaymentLineJsonToken, 'parToken', false);
                    IncEcomSalesPmtLine."PSP Token" := JsonHelper.GetJText(PaymentLineJsonToken, 'pspToken', false);
                    IncEcomSalesPmtLine."Card Expiry Date" := JsonHelper.GetJText(PaymentLineJsonToken, 'cardExpiryDate', false);
                    IncEcomSalesPmtLine."Card Brand" := JsonHelper.GetJText(PaymentLineJsonToken, 'cardBrand', false);
                    IncEcomSalesPmtLine."Masked Card Number" := JsonHelper.GetJText(PaymentLineJsonToken, 'maskedCardNumber', false);
                    IncEcomSalesPmtLine."External Payment Method Code" := JsonHelper.GetJText(PaymentLineJsonToken, 'externalPaymentMethodCode', MaxStrLen(IncEcomSalesPmtLine."External Payment Method Code"), true, true);
                    IncEcomSalesPmtLine."External Paymment Type" := JsonHelper.GetJText(PaymentLineJsonToken, 'externalPaymentType', false);
                    IncEcomSalesPmtLine."Card Alias Token" := JsonHelper.GetJText(PaymentLineJsonToken, 'cardAliasToken', false);
#pragma warning restore AA0139
                end;
        end;

        IncEcomSalesDocApiEvents.OnAfterDeserializeIncomingEcomSalesPaymentLine(PaymentLineJsonToken, IncEcomSalesPmtLine);
    end;

    [TryFunction]
    procedure TryEvaluateIncSalesPaymentLineType(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; IncSalesPaymentLineTypeText: Text; var PaymentType: Enum "NPR Inc Ecom Pmt Method Type")
    var
        NotSupportPaymentTypeErr: Label 'Payment type: %1 is not supported.', Comment = '%1 - payment type', Locked = true;
    begin
        case IncSalesPaymentLineTypeText of
            'paymentGateway':
                PaymentType := PaymentType::"Payment Method";
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

    local procedure ProcessIncomingSalesDocumentComments(RequestBody: JsonToken; IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header")
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
            InsertIncomingSalesDocumentComment(CommentJsonToken, IncEcomSalesHeader);
    end;

    local procedure InsertIncomingSalesDocumentComment(SalesLineJsonToken: JsonToken; IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header")
    var
        RecordLink: Record "Record Link";
        JsonHelper: Codeunit "NPR Json Helper";
        RecordLinkManagement: Codeunit "Record Link Management";
        IncEcomSalesDocApiEvents: Codeunit "NPR IncEcomSalesDocApiEvents";
        CommentLine: Text;
        Note: Text;
        LinkID: Integer;
    begin
        CommentLine := JsonHelper.GetJText(SalesLineJsonToken, 'comment', 0, true);
        if CommentLine = '' then
            exit;

        LinkID := IncEcomSalesHeader.AddLink('', IncEcomSalesHeader."External No.");
        RecordLink.Get(LinkID);
        RecordLink.Type := RecordLink.Type::Note;
        RecordLink."User ID" := '';
        Note := CommentLine;

        RecordLinkManagement.WriteNote(RecordLink, Note);
        IncEcomSalesDocApiEvents.OnBeforeModifyIncomingSalesDocumentCommentBeforeModifyRecordLink(SalesLineJsonToken, IncEcomSalesHeader, RecordLink);
        RecordLink.Modify(true);
    end;

    internal procedure GetSalesDocumentCreateResponse(IncSalesHeader: Record "NPR Inc Ecom Sales Header") IncSalesDocumentJsonObject: Codeunit "NPR Json Builder";
    var
        IncEcomSalesDocApiEvents: Codeunit "NPR IncEcomSalesDocApiEvents";
    begin
        IncSalesDocumentJsonObject.StartObject('salesDocument')
                                   .AddProperty('id', Format(IncSalesHeader.SystemId, 0, 4).ToLower());
        IncEcomSalesDocApiEvents.OnGetSalesDocumentCreateResponseBeforeEndObject(IncSalesHeader, IncSalesDocumentJsonObject);
        IncSalesDocumentJsonObject.EndObject();
    end;

    internal procedure GetSalesDocumentJsonObject(IncSalesHeader: Record "NPR Inc Ecom Sales Header") IncSalesDocumentJsonObject: Codeunit "NPR Json Builder";
    var
        IncEcomSalesLine: Record "NPR Inc Ecom Sales Line";
        IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line";
        RecordLink: Record "Record Link";
        IncEcomSalesDocApiEvents: Codeunit "NPR IncEcomSalesDocApiEvents";
        PaymentLineJsonObject: Codeunit "NPR Json Builder";
        SalesLineJsonObject: Codeunit "NPR Json Builder";
        CommentJsonObject: Codeunit "NPR Json Builder";
        IncEcomSalesHeaderCustomFieldsObject: Codeunit "NPR Json Builder";
    begin
        IncSalesDocumentJsonObject.StartObject('salesDocument')
                                 .AddProperty('externalNo', IncSalesHeader."External No.")
                                 .AddProperty('id', Format(IncSalesHeader.SystemId, 0, 4).ToLower())
                                 .AddProperty('documentType', GetSalesDocumentApiType(IncSalesHeader))
                                 .AddProperty('creationStatus', GetSalesDocumentCreationStatusApiType(IncSalesHeader))
                                 .AddProperty('postingStatus', GetSalesDocumentPostingStatusApiType(IncSalesHeader))
                                 .AddProperty('currencyCode', IncSalesHeader."Currency Code")
                                 .AddProperty('currencyExchangeRate', Format(IncSalesHeader."Currency Exchange Rate", 0, 9))
                                 .AddProperty('externalDocumentNo', IncSalesHeader."External Document No.")
                                 .AddProperty('yourReference', IncSalesHeader."Your Reference")
                                 .AddProperty('locationCode', IncSalesHeader."Location Code.")
                                 .AddProperty('pricesExcludingVat', IncSalesHeader."Price Excl. VAT")
                                 .StartObject('sellToCustomer')
                                    .AddProperty('no', IncSalesHeader."Sell-to Customer No.")
                                    .AddProperty('name', IncSalesHeader."Sell-to Name")
                                    .AddProperty('address', IncSalesHeader."Sell-to Address")
                                    .AddProperty('address2', IncSalesHeader."Sell-to Address 2")
                                    .AddProperty('postCode', IncSalesHeader."Sell-to Post Code")
                                    .AddProperty('county', IncSalesHeader."Sell-to County")
                                    .AddProperty('city', IncSalesHeader."Sell-to City")
                                    .AddProperty('countryCode', IncSalesHeader."Sell-to Country Code")
                                    .AddProperty('contact', IncSalesHeader."Sell-to Contact")
                                    .AddProperty('email', IncSalesHeader."Sell-to Email")
                                    .AddProperty('phone', IncSalesHeader."Sell-to Phone No.")
                                    .AddProperty('ean', IncSalesHeader."Sell-to EAN")
                                    .AddProperty('vatRegistrationNo', IncSalesHeader."Sell-to VAT Registration No.")
                                    .AddProperty('invoiceEmail', IncSalesHeader."Sell-to Invoice Email")
                                .EndObject()
                                .StartObject('shipToCustomer')
                                    .AddProperty('name', IncSalesHeader."Ship-to Name")
                                    .AddProperty('address', IncSalesHeader."Ship-to Address")
                                    .AddProperty('address2', IncSalesHeader."Ship-to Address 2")
                                    .AddProperty('postCode', IncSalesHeader."Ship-to Post Code")
                                    .AddProperty('county', IncSalesHeader."Ship-to County")
                                    .AddProperty('city', IncSalesHeader."Ship-to City")
                                    .AddProperty('countryCode', IncSalesHeader."Ship-to Country Code")
                                    .AddProperty('contact', IncSalesHeader."Ship-to Contact")
                                .EndObject()
                                .StartObject('shipment')
                                    .AddProperty('shipmentMethod', IncSalesHeader."Shipment Method Code")
                                    .AddProperty('shipmentService', IncSalesHeader."Shipment Service")
                                .EndObject();

        IncEcomSalesDocApiEvents.OnGetSalesDocumentCustomFieldsJsonObject(IncSalesHeader, IncEcomSalesHeaderCustomFieldsObject);
        if IncEcomSalesHeaderCustomFieldsObject.IsInitialized() then
            IncSalesDocumentJsonObject.AddNestedObject('customFields', IncEcomSalesHeaderCustomFieldsObject);

        RecordLink.Reset();
        RecordLink.SetRange("Record ID", IncSalesHeader.RecordId);
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

        IncEcomSalesPmtLine.Reset();
        IncEcomSalesPmtLine.SetRange("Document Type", IncSalesHeader."Document Type");
        IncEcomSalesPmtLine.SetRange("External Document No.", IncSalesHeader."External No.");
        if IncEcomSalesPmtLine.FindSet() then begin
            IncSalesDocumentJsonObject.StartArray('payments');
            repeat
                PaymentLineJsonObject := CreateAddPaymentDocumentDetailsJsonObject(IncEcomSalesPmtLine, IncSalesDocumentJsonObject);
                IncSalesDocumentJsonObject.AddObject(PaymentLineJsonObject);
            until IncEcomSalesPmtLine.Next() = 0;
            IncSalesDocumentJsonObject.EndArray();
        end;

        IncEcomSalesLine.Reset();
        IncEcomSalesLine.SetRange("Document Type", IncSalesHeader."Document Type");
        IncEcomSalesLine.SetRange("External Document No.", IncSalesHeader."External No.");
        if IncEcomSalesLine.FindSet() then begin
            IncSalesDocumentJsonObject.StartArray('salesDocumentLines');
            repeat
                SalesLineJsonObject := CreateAddSalesLineDetailsJsonObject(IncEcomSalesLine, IncSalesDocumentJsonObject);
                IncSalesDocumentJsonObject.AddObject(SalesLineJsonObject);
            until IncEcomSalesLine.Next() = 0;
            IncSalesDocumentJsonObject.EndArray();
        end;

        IncSalesDocumentJsonObject.EndObject();
    end;

    internal procedure CreateAddPaymentDocumentDetailsJsonObject(IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line"; var PaymentDocumentDetailsJsonObject: Codeunit "NPR Json Builder"): Codeunit "NPR Json Builder"
    var
        IncEcomSalesLine: Record "NPR Inc Ecom Sales Line";
        IncEcomSalesDocApiEvents: Codeunit "NPR IncEcomSalesDocApiEvents";
        PaymentDocumentDetailsCustomFieldsJsonObject: Codeunit "NPR Json Builder";
    begin
        PaymentDocumentDetailsJsonObject.StartObject()
                                        .AddProperty('id', Format(IncEcomSalesPmtLine.SystemId, 0, 4).ToLower())
                                        .AddProperty('paymentMethodType', GetPaymentMethodTypeJsonValue(IncEcomSalesPmtLine))
                                        .AddProperty('externalPaymentMethodCode', IncEcomSalesPmtLine."External Payment Method Code")
                                        .AddProperty('externalPaymentType', IncEcomSalesPmtLine."External Paymment Type")
                                        .AddProperty('paymentReference', IncEcomSalesPmtLine."Payment Reference")
                                        .AddProperty('paymentAmount', Format(IncEcomSalesPmtLine.Amount, 0, 9))
                                        .AddProperty('pspToken', IncEcomSalesPmtLine."PSP Token")
                                        .AddProperty('cardExpiryDate', IncEcomSalesPmtLine."Card Expiry Date")
                                        .AddProperty('cardBrand', IncEcomSalesPmtLine."Card Brand")
                                        .AddProperty('maskedCardNumber', IncEcomSalesPmtLine."Masked Card Number")
                                        .AddProperty('parToken', (IncEcomSalesPmtLine."PAR Token"))
                                        .AddProperty('cardAliasToken', (IncEcomSalesPmtLine."Card Alias Token"))
                                        .AddProperty('capturedPaymentAmount', Format(IncEcomSalesPmtLine."Captured Amount", 0, 9));

        IncEcomSalesLine.SetRange("Created From Pmt. Line Id", IncEcomSalesPmtLine.SystemId);
        IncEcomSalesLine.SetLoadFields(SystemId);
        if IncEcomSalesLine.FindSet() then begin
            PaymentDocumentDetailsJsonObject.StartArray('paymentFees');
            repeat
                PaymentDocumentDetailsJsonObject.StartObject();
                PaymentDocumentDetailsJsonObject.AddProperty('paymentFeeId', Format(IncEcomSalesLine.SystemId, 0, 4).ToLower());
                PaymentDocumentDetailsJsonObject.EndObject();
            until IncEcomSalesLine.Next() = 0;
            PaymentDocumentDetailsJsonObject.EndArray();
        end;

        IncEcomSalesDocApiEvents.OnGetPaymentDocumentDetailsCustomFieldsJsonObject(IncEcomSalesPmtLine, PaymentDocumentDetailsCustomFieldsJsonObject);
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

    internal procedure CreateAddSalesLineDetailsJsonObject(IncEcomSalesLine: Record "NPR Inc Ecom Sales Line"; var SalesLineDetailsJsonObject: Codeunit "NPR Json Builder"): Codeunit "NPR Json Builder"
    var
        IncEcomSalesDocApiEvents: Codeunit "NPR IncEcomSalesDocApiEvents";
        SalesLineDetailsCustomFieldsJsonObject: Codeunit "NPR Json Builder";
    begin
        SalesLineDetailsJsonObject.StartObject()
                                  .AddProperty('id', Format(IncEcomSalesLine.SystemId, 0, 4).ToLower())
                                  .AddProperty('type', GetSalesLineApiType(IncEcomSalesLine))
                                  .AddProperty('no', IncEcomSalesLine."No.")
                                  .AddProperty('variantCode', IncEcomSalesLine."Variant Code")
                                  .AddProperty('barcodeNo', IncEcomSalesLine."Barcode No.")
                                  .AddProperty('description', IncEcomSalesLine.Description)
                                  .AddProperty('unitPrice', Format(IncEcomSalesLine."Unit Price", 0, 9))
                                  .AddProperty('quantity', Format(IncEcomSalesLine.Quantity, 0, 9))
                                  .AddProperty('unitOfMeasure', Format(IncEcomSalesLine."Unit of Measure Code", 0, 9))
                                  .AddProperty('vatPercent', Format(IncEcomSalesLine."VAT %", 0, 9))
                                  .AddProperty('lineAmount', Format(IncEcomSalesLine."Line Amount", 0, 9))
                                  .AddProperty('requestedDeliveryDate', Format(IncEcomSalesLine."Requested Delivery Date", 0, 9))
                                  .AddProperty('invoicedQuantity', Format(IncEcomSalesLine."Invoiced Qty.", 0, 9))
                                  .AddProperty('invoicedAmount', Format(IncEcomSalesLine."Invoiced Amount", 0, 9));
        IncEcomSalesDocApiEvents.OnCreateAddSalesLineDetailsCustomFieldsJsonObject(IncEcomSalesLine, SalesLineDetailsCustomFieldsJsonObject);
        if SalesLineDetailsCustomFieldsJsonObject.IsInitialized() then
            SalesLineDetailsJsonObject.AddNestedObject('customFields', SalesLineDetailsCustomFieldsJsonObject);
        SalesLineDetailsJsonObject.EndObject();
    end;


    local procedure GetPaymentMethodTypeJsonValue(IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line") PaymentMethodTypeJsonValue: Text
    var
        NotSupportedStatusErrorLbl: Label 'Payment Method Type: %1 is not supported.', Comment = '%1 - Payment Method Type', Locked = true;
    begin
        case IncEcomSalesPmtLine."Payment Method Type" of
            IncEcomSalesPmtLine."Payment Method Type"::"Payment Method":
                PaymentMethodTypeJsonValue := 'paymentGateway';
            else
                Error(NotSupportedStatusErrorLbl, IncEcomSalesPmtLine."Payment Method Type");
        end;
    end;

    local procedure GetSalesDocumentCreationStatusApiType(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header") SalesDocumenttatusApiType: Text
    var
        NotSupportedStatusErrorLbl: Label 'Sales document creation status: %1 is not supported.', Comment = '%1 - status', Locked = true;
    begin
        case IncEcomSalesHeader."Creation Status" of
            IncEcomSalesHeader."Creation Status"::Created:
                SalesDocumenttatusApiType := 'created';
            IncEcomSalesHeader."Creation Status"::Error:
                SalesDocumenttatusApiType := 'error';
            IncEcomSalesHeader."Creation Status"::Pending:
                SalesDocumenttatusApiType := 'pending';
            else
                Error(NotSupportedStatusErrorLbl, IncEcomSalesHeader."Creation Status");
        end;
    end;

    local procedure GetSalesDocumentApiType(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header") SalesDocumentApiType: Text
    begin
        case IncEcomSalesHeader."Document Type" of
            IncEcomSalesHeader."Document Type"::Order:
                SalesDocumentApiType := 'order';
            IncEcomSalesHeader."Document Type"::"Return Order":
                SalesDocumentApiType := 'returnOrder';
        end;
    end;

    local procedure GetSalesDocumentPostingStatusApiType(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header") SalesDocumentStatusApiType: Text
    var
        NotSupportedStatusErrorLbl: Label 'Sales document posting status: %1 is not supported.', Comment = '%1 - status', Locked = true;
    begin
        case IncEcomSalesHeader."Posting Status" of
            IncEcomSalesHeader."Posting Status"::"Partially Invoiced":
                SalesDocumentStatusApiType := 'partiallyInvoiced';
            IncEcomSalesHeader."Posting Status"::Invoiced:
                SalesDocumentStatusApiType := 'invoiced';
            IncEcomSalesHeader."Posting Status"::Pending:
                SalesDocumentStatusApiType := 'pending';
            else
                Error(NotSupportedStatusErrorLbl, IncEcomSalesHeader."Posting Status");
        end;
    end;

    local procedure GetTableIds() TableIds: List of [Integer]
    begin
        TableIds.Add(Database::"NPR Inc Ecom Sales Pmt. Line");
        TableIds.Add(Database::"NPR Inc Ecom Sales Line");
        TableIds.Add(Database::"NPR Inc Ecom Sales Header");
    end;

    internal procedure GetEcomDocumentTypeFromRequest(RequestBody: JsonToken) IncEcomSalesDocType: Enum "NPR Inc Ecom Sales Doc Type"
    var
        JsonHelper: Codeunit "NPR Json Helper";
        EcomDocumentTypeText: Text;
        UnsupportedDocumentTypeError: Label '%1 has unsupported value: %2.', Comment = '%1 - absolute path, %2 - document type', Locked = true;
    begin
        EcomDocumentTypeText := JsonHelper.GetJText(RequestBody, 'documentType', true);
        case EcomDocumentTypeText of
            'order':
                IncEcomSalesDocType := IncEcomSalesDocType::Order;
            'returnOrder':
                IncEcomSalesDocType := IncEcomSalesDocType::"Return Order"
            else
                Error(UnsupportedDocumentTypeError, JsonHelper.GetAbsolutePath(RequestBody, 'documentType'), EcomDocumentTypeText);
        end;
    end;

}
#endif