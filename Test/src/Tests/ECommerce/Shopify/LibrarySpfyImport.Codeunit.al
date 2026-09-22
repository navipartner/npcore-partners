#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85465 "NPR Library Spfy Import"
{
    // Test fixture library for the Shopify order import create-path (integration tests).

    var
        StoreCodeTok: Label 'SPFYTESTSTORE', Locked = true;
        EcStoreCodeTok: Label 'SPFYTESTEC', Locked = true;
        SourceNameTok: Label 'web', Locked = true;
        SalespersonTok: Label 'SPFYTEST', Locked = true;
        CustomerNoTok: Label 'SPFYTESTCUST', Locked = true;
        ItemNoTok: Label 'SPFYSNOW', Locked = true;

    /// <summary>Creates the minimal DB prerequisites for a simple item order import and returns the codes.</summary>
    procedure SetupSimpleItemOrder(var StoreCode: Code[20]; var Sku: Code[20]; var ItemNo: Code[20])
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Customer: Record Customer;
        Item: Record Item;
        SpfyStore: Record "NPR Spfy Store";
        NpEcStore: Record "NPR NpEc Store";
    begin
        StoreCode := CopyStr(StoreCodeTok, 1, MaxStrLen(StoreCode));
        ItemNo := CopyStr(ItemNoTok, 1, MaxStrLen(ItemNo));
        Sku := ItemNo;

        if not SalespersonPurchaser.Get(SalespersonTok) then begin
            SalespersonPurchaser.Init();
            SalespersonPurchaser.Code := CopyStr(SalespersonTok, 1, MaxStrLen(SalespersonPurchaser.Code));
            SalespersonPurchaser.Insert();
        end;

        if not Customer.Get(CustomerNoTok) then begin
            Customer.Init();
            Customer."No." := CopyStr(CustomerNoTok, 1, MaxStrLen(Customer."No."));
            Customer.Name := 'Spfy Test Customer';
            Customer.Insert(true);
        end;

        if not Item.Get(ItemNo) then begin
            Item.Init();
            Item."No." := ItemNo;
            Item.Insert(true);
        end;

        EnsureTestLocation();

        if not SpfyStore.Get(StoreCode) then begin
            SpfyStore.Init();
            SpfyStore.Code := StoreCode;
            SpfyStore.Insert();
        end;

        if not NpEcStore.Get(EcStoreCodeTok) then begin
            NpEcStore.Init();
            NpEcStore.Code := CopyStr(EcStoreCodeTok, 1, MaxStrLen(NpEcStore.Code));
            NpEcStore."Salesperson/Purchaser Code" := CopyStr(SalespersonTok, 1, MaxStrLen(NpEcStore."Salesperson/Purchaser Code"));
            NpEcStore."Shopify Store Code" := StoreCode;
            NpEcStore."Shopify Source Name" := CopyStr(SourceNameTok, 1, MaxStrLen(NpEcStore."Shopify Source Name"));
            NpEcStore."Spfy Customer No." := CopyStr(CustomerNoTok, 1, MaxStrLen(NpEcStore."Spfy Customer No."));
            NpEcStore."Allow Create Customers" := false;
            NpEcStore.Validate(LocationCode, 'SPFYLOC');
            NpEcStore.Insert();
        end;
    end;

    /// <summary>Populates (and inserts) an Event Log Entry for an Open Order; presentment currency = LCY.</summary>
    procedure InitLogEntry(var LogEntry: Record "NPR Spfy Event Log Entry"; StoreCode: Code[20]; ShopifyId: Text[30])
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        LogEntry.Init();
        LogEntry."Entry No." := 0; //Init() does not clear the primary key, so a reused variable would carry the previously assigned no. into the AutoIncrement insert
        LogEntry."Store Code" := StoreCode;
        LogEntry."Shopify ID" := ShopifyId;
        LogEntry."Document Type" := LogEntry."Document Type"::Order;
        LogEntry."Document Status" := LogEntry."Document Status"::Open;
        LogEntry."Presentment Currency Code" := GLSetup."LCY Code";
        LogEntry."Event Date-Time" := CurrentDateTime();
        LogEntry.Insert(true);
    end;

    /// <summary>Creates a bare Shopify store (no connection setup), for tests that only need the store to exist.</summary>
    procedure CreateStore(StoreCode: Code[20])
    var
        SpfyStore: Record "NPR Spfy Store";
    begin
        if SpfyStore.Get(StoreCode) then
            exit;
        SpfyStore.Init();
        SpfyStore.Code := StoreCode;
        SpfyStore.Insert();
    end;

    /// <summary>Inserts an "Incoming Sales Order" Event Log Entry with full control over document type, document
    /// status and event date-time (the fields the discard and sibling-wait filters work on).</summary>
    procedure InsertOrderLogEntry(var LogEntry: Record "NPR Spfy Event Log Entry"; StoreCode: Code[20]; ShopifyId: Text[30]; DocType: Enum "NPR SpfyEventLogDocType"; DocStatus: Enum "NPR SpfyAPIDocumentStatus"; EventDateTime: DateTime)
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        LogEntry.Init();
        LogEntry."Entry No." := 0; //Init() does not clear the primary key, so a reused variable would carry the previously assigned no. into the AutoIncrement insert
        LogEntry.Type := LogEntry.Type::"Incoming Sales Order";
        LogEntry."Store Code" := StoreCode;
        LogEntry."Shopify ID" := ShopifyId;
        LogEntry."Document Type" := DocType;
        LogEntry."Document Status" := DocStatus;
        LogEntry."Presentment Currency Code" := GLSetup."LCY Code";
        LogEntry."Event Date-Time" := EventDateTime;
        LogEntry.Insert(true);
    end;

    /// <summary>Puts a log entry into the failed state that the discard paths look for: Error, retries spent,
    /// postponed into the future and carrying stored order data.</summary>
    procedure SetFailedWithOrderData(var LogEntry: Record "NPR Spfy Event Log Entry"; RetryCount: Integer)
    begin
        SetProcessingState(LogEntry, LogEntry."Processing Status"::Error, RetryCount);
        WriteOrderDataText(LogEntry, '{"data":{"order":{}}}');
    end;

    /// <summary>Puts a log entry into the given processing state, postponed into the future, with stored order data.</summary>
    procedure SetProcessingStateWithOrderData(var LogEntry: Record "NPR Spfy Event Log Entry"; ProcessingStatus: Enum "NPR SpfyEventLogProcessStatus"; RetryCount: Integer)
    begin
        SetProcessingState(LogEntry, ProcessingStatus, RetryCount);
        WriteOrderDataText(LogEntry, '{"data":{"order":{}}}');
    end;

    /// <summary>Puts a log entry into the given processing state, with retries spent and postponed into the
    /// future, but without stored order data.</summary>
    procedure SetProcessingState(var LogEntry: Record "NPR Spfy Event Log Entry"; ProcessingStatus: Enum "NPR SpfyEventLogProcessStatus"; RetryCount: Integer)
    begin
        LogEntry."Processing Status" := ProcessingStatus;
        LogEntry."Process Retry Count" := RetryCount;
        LogEntry.Postponed := true;
        LogEntry."Not Before Date-Time" := CurrentDateTime() + 600000; // ten minutes
        LogEntry."Last Error Message" := 'Import failed.';
        LogEntry."Last Error Date" := Today();
        LogEntry.Modify();
    end;

    /// <summary>Writes an arbitrary payload into the "Order Data" blob (only its presence matters here).</summary>
    procedure WriteOrderDataText(var LogEntry: Record "NPR Spfy Event Log Entry"; OrderDataText: Text)
    var
        OutStr: OutStream;
    begin
        LogEntry."Order Data".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(OrderDataText);
        LogEntry.Modify();
    end;

    /// <summary>True when the log entry still has stored Shopify order data.</summary>
    procedure HasOrderData(EntryNo: BigInteger): Boolean
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
    begin
        LogEntry.Get(EntryNo);
        LogEntry.CalcFields("Order Data");
        exit(LogEntry."Order Data".HasValue());
    end;

    /// <summary>Creates a bare Sales Header carrying the Shopify order id. The insert trigger is deliberately not
    /// run: the "does a sales document already exist" predicates only resolve the record behind the assigned id,
    /// so a full document (and its posting setup) is not needed.</summary>
    procedure InsertSalesHeaderWithShopifyId(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]; ShopifyId: Text[30])
    begin
        InsertSalesHeaderWithShopifyId(DocumentType, DocumentNo, ShopifyId, '');
    end;

    /// <summary>Same, but the document also carries the assigned Store Code - the id the "does a sales document
    /// already exist" lookup uses to tell one store's document from another's. Pass a blank store code for the
    /// legacy shape, where only the Entry ID was ever stamped.</summary>
    procedure InsertSalesHeaderWithShopifyId(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]; ShopifyId: Text[30]; StoreCode: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        if not SalesHeader.Get(DocumentType, DocumentNo) then begin
            SalesHeader.Init();
            SalesHeader."Document Type" := DocumentType;
            SalesHeader."No." := DocumentNo;
            SalesHeader.Insert();
        end;
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyId, false);
        if StoreCode <> '' then
            SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);
    end;

    /// <summary>Same as InsertSalesHeaderWithShopifyId, for a posted sales invoice.</summary>
    procedure InsertPostedSalesInvoiceWithShopifyId(DocumentNo: Code[20]; ShopifyId: Text[30])
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        if not SalesInvHeader.Get(DocumentNo) then begin
            SalesInvHeader.Init();
            SalesInvHeader."No." := DocumentNo;
            SalesInvHeader.Insert();
        end;
        SpfyAssignedIDMgt.AssignShopifyID(SalesInvHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyId, false);
    end;

    /// <summary>Builds a minimal unified order JSON (data.order) for a single item line.</summary>
    procedure BuildSimpleItemOrderJson(ShopifyId: Text; Sku: Code[20]; UnitPrice: Decimal) OrderResponse: JsonToken
    var
        Json: JsonToken;
        Builder: TextBuilder;
        Amount: Text;
        InvalidErr: Label 'Built order JSON is not valid.', Locked = true;
    begin
        Amount := Format(UnitPrice, 0, 9);
        Builder.Append('{"data":{"order":{');
        Builder.Append('"id":"gid://shopify/Order/' + ShopifyId + '",');
        Builder.Append('"name":"#' + ShopifyId + '",');
        Builder.Append('"sourceName":"' + SourceNameTok + '",');
        Builder.Append('"number":1001,');
        Builder.Append('"taxesIncluded":false,');
        Builder.Append('"billingAddress":{"firstName":"Test","lastName":"Buyer","company":null,"countryCodeV2":"US","zip":"10001","address1":"1 Test St","address2":null,"city":"New York"},');
        Builder.Append('"shippingAddress":{"firstName":"Test","lastName":"Buyer","company":null,"countryCodeV2":"US","zip":"10001","address1":"1 Test St","address2":null,"city":"New York"},');
        Builder.Append('"customer":{"firstName":"Test","lastName":"Buyer","defaultAddress":{"phone":null}},');
        Builder.Append('"lineItems":[{"node":{');
        Builder.Append('"id":"gid://shopify/LineItem/1",');
        Builder.Append('"sku":"' + Sku + '",');
        Builder.Append('"title":"Snowboard","variantTitle":null,');
        Builder.Append('"quantity":1,"unfulfilledQuantity":1,"currentQuantity":1,"nonFulfillableQuantity":0,');
        Builder.Append('"isGiftCard":false,');
        Builder.Append('"product":{"id":"gid://shopify/Product/1","productType":"snowboard"},');
        Builder.Append('"variant":{"price":"' + Amount + '"},');
        Builder.Append('"originalUnitPriceSet":{"presentmentMoney":{"amount":"' + Amount + '"}},');
        Builder.Append('"taxLines":[],"discountAllocations":[],"customAttributes":[]');
        Builder.Append('}}],');
        Builder.Append('"shippingLines":[],');
        Builder.Append('"transactions":[]');
        Builder.Append('}}}');

        if not Json.ReadFrom(Builder.ToText()) then
            Error(InvalidErr);
        OrderResponse := Json;
    end;

    /// <summary>Creates a shipment mapping so a shipping line resolves (only Shipment Fee No. is required by the create path).</summary>
    procedure SetupShipmentMapping(ShipCode: Code[50])
    var
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
    begin
        if ShipmentMapping.Get(ShipCode) then
            exit;
        ShipmentMapping.Init();
        ShipmentMapping."External Shipment Method Code" := ShipCode;
        ShipmentMapping."Shipment Fee No." := 'SHIPFEE';
        ShipmentMapping.Insert();
    end;

    /// <summary>One item line node (the {"node":{...}} element of data.order.lineItems).</summary>
    procedure ItemLineNodeText(LineId: Text; Sku: Code[20]; UnitPrice: Decimal; Qty: Integer; DiscountAllocText: Text): Text
    var
        Amount: Text;
    begin
        Amount := Format(UnitPrice, 0, 9);
        exit(
            '{"node":{' +
            '"id":"gid://shopify/LineItem/' + LineId + '",' +
            '"sku":"' + Sku + '",' +
            '"title":"Item","variantTitle":null,' +
            '"quantity":' + Format(Qty) + ',"unfulfilledQuantity":' + Format(Qty) + ',"currentQuantity":' + Format(Qty) + ',"nonFulfillableQuantity":0,' +
            '"isGiftCard":false,' +
            '"product":{"id":"gid://shopify/Product/1","productType":"snowboard"},' +
            '"variant":{"price":"' + Amount + '"},' +
            '"originalUnitPriceSet":{"presentmentMoney":{"amount":"' + Amount + '"}},' +
            '"taxLines":[],"discountAllocations":' + DiscountAllocText +
            '}}');
    end;

    /// <summary>Brings a store to the state where the ONLY reason capture requests are off is the store's own
    /// "Send Payment Capture Requests" field. SpfyIntegrationMgt.IsEnabled short-circuits on "Enable Integration"
    /// and on the store's Enabled flag before it ever looks at the field, so a bare CreateStore would make a test
    /// pass because the store is disabled - proving something other than what it claims.
    /// Enabled is assigned, not validated: validating it demands a Shopify URL and rebuilds job queues.</summary>
    procedure EnableStoreWithCaptureRequestsOff(StoreCode: Code[20])
    var
        SpfyStore: Record "NPR Spfy Store";
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        if not SpfyIntegrationSetup.Get() then begin
            SpfyIntegrationSetup.Init();
            SpfyIntegrationSetup.Insert();
        end;
        SpfyIntegrationSetup."Enable Integration" := true;
        SpfyIntegrationSetup.Modify();

        CreateStore(StoreCode);
        SpfyStore.Get(StoreCode);
        SpfyStore.Enabled := true;
        SpfyStore."Send Payment Capture Requests" := false;
        SpfyStore.Modify();

        // "NPR Spfy Integration Mgt." is SingleInstance and caches both the setup record and the store it was last
        // asked about, so this write is invisible to a session that already read either one - and the cached values
        // survive the per-test rollback, which would leave the integration enabled for every later test. Dropping
        // the cache here is what makes the two directions of that leak harmless.
        SpfyIntegrationMgt.SetRereadSetup();
    end;

    /// <summary>Ecommerce document that has already been created and invoiced, which is what the closed-entry path
    /// reads through the log entry's "Posting Status" flowfield.</summary>
    procedure CreateInvoicedEcomDocument(StoreCode: Code[20]; ExternalNo: Code[20]; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        Clear(EcomSalesHeader);
        EcomSalesHeader."Document Type" := EcomSalesHeader."Document Type"::Order;
        EcomSalesHeader."External No." := ExternalNo;
        EcomSalesHeader."Ecommerce Store Code" := CopyStr(EcStoreCodeTok, 1, MaxStrLen(EcomSalesHeader."Ecommerce Store Code"));
        EcomSalesHeader."Document Source" := EcomSalesHeader."Document Source"::Shopify;
        EcomSalesHeader."Creation Status" := EcomSalesHeader."Creation Status"::Created;
        EcomSalesHeader."Posting Status" := EcomSalesHeader."Posting Status"::Invoiced;
        EcomSalesHeader.Insert(true);
    end;

    /// <summary>Ecommerce document carrying a virtual item and one card payment line, plus the payment mapping that
    /// payment line resolves to. This is what the capture check reads: it never looks at the sales lines themselves,
    /// only at "Virtual Items Exist" and the payment lines, so the document is built directly instead of through a
    /// voucher import that would need a voucher type, a reference-no pattern and a payment method on top.</summary>
    procedure CreateEcomDocWithVirtualItemAndCardPayment(StoreCode: Code[20]; ExternalNo: Code[20]; PaymentCodeAndType: Code[50]; CapturedExternally: Boolean; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        PaymentMapping: Record "NPR Magento Payment Mapping";
    begin
        Clear(EcomSalesHeader);
        EcomSalesHeader."Document Type" := EcomSalesHeader."Document Type"::Order;
        EcomSalesHeader."External No." := ExternalNo;
        EcomSalesHeader."Ecommerce Store Code" := CopyStr(EcStoreCodeTok, 1, MaxStrLen(EcomSalesHeader."Ecommerce Store Code"));
        EcomSalesHeader."Document Source" := EcomSalesHeader."Document Source"::Shopify;
        EcomSalesHeader."Virtual Items Exist" := true;
        EcomSalesHeader."Received Date" := WorkDate();
        EcomSalesHeader.Insert(true);

        EcomSalesPmtLine.Init();
        EcomSalesPmtLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesPmtLine."Line No." := 10000;
        EcomSalesPmtLine."Payment Method Type" := EcomSalesPmtLine."Payment Method Type"::"Payment Method";
        EcomSalesPmtLine."External Payment Method Code" := PaymentCodeAndType;
        EcomSalesPmtLine."External Payment Type" := PaymentCodeAndType;
        EcomSalesPmtLine.Amount := 100;
        EcomSalesPmtLine.Insert(true);

        if not PaymentMapping.Get(PaymentCodeAndType, PaymentCodeAndType) then begin
            PaymentMapping.Init();
            PaymentMapping."External Payment Method Code" := PaymentCodeAndType;
            PaymentMapping."External Payment Type" := PaymentCodeAndType;
            PaymentMapping.Insert();
        end;
        PaymentMapping."Captured Externally" := CapturedExternally;
        PaymentMapping.Modify();
    end;

    /// <summary>Ecommerce document plus the persisted "NPR Magento Payment Line" the payment gateway resolves
    /// through Request."Payment Line System Id". "NPR Inc Ecom Sale Id" is what marks the line as belonging to
    /// an ecommerce document, and it is the only thing the capture block in "NPR Spfy Payment Gateway Hdlr"
    /// keys on. Pass a non-blank DateCaptured to model an externally captured line (EcomCaptureImpl stamps
    /// EcomSalesHeader."Received Date" there), and CaptureRequested to model a capture already in flight.</summary>
    procedure CreateEcomDocWithGatewayPaymentLine(StoreCode: Code[20]; ExternalNo: Code[20]; PaymentCodeAndType: Code[50]; CapturedExternally: Boolean; DateCaptured: Date; CaptureRequested: Boolean; var EcomSalesHeader: Record "NPR Ecom Sales Header"; var PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentMapping: Record "NPR Magento Payment Mapping";
    begin
        Clear(EcomSalesHeader);
        EcomSalesHeader."Document Type" := EcomSalesHeader."Document Type"::Order;
        EcomSalesHeader."External No." := ExternalNo;
        EcomSalesHeader."Ecommerce Store Code" := CopyStr(EcStoreCodeTok, 1, MaxStrLen(EcomSalesHeader."Ecommerce Store Code"));
        EcomSalesHeader."Document Source" := EcomSalesHeader."Document Source"::Shopify;
        EcomSalesHeader."Received Date" := WorkDate();
        EcomSalesHeader.Insert(true);

        // Same shape the production inserter builds ("NPR EcomCaptureImpl"): the document is identified by table no.
        // plus the external document no., and the link back to the ecommerce document is the system id.
        PaymentLine.Init();
        PaymentLine."Document Table No." := Database::"NPR Ecom Sales Header";
        PaymentLine."Document Type" := PaymentLine."Document Type"::Order;
        PaymentLine."Document No." := ExternalNo;
        PaymentLine."Line No." := 10000;
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::"Payment Method";
        PaymentLine."No." := PaymentCodeAndType;
        PaymentLine.Amount := 100;
        PaymentLine."Requested Amount" := PaymentLine.Amount;
        PaymentLine."NPR Inc Ecom Sale Id" := EcomSalesHeader.SystemId;
        PaymentLine."Date Captured" := DateCaptured;
        PaymentLine."Capture Requested" := CaptureRequested;
        PaymentLine.Insert();

        if not PaymentMapping.Get(PaymentCodeAndType, PaymentCodeAndType) then begin
            PaymentMapping.Init();
            PaymentMapping."External Payment Method Code" := PaymentCodeAndType;
            PaymentMapping."External Payment Type" := PaymentCodeAndType;
            PaymentMapping.Insert();
        end;
        PaymentMapping."Captured Externally" := CapturedExternally;
        PaymentMapping.Modify();
    end;

    /// <summary>Populates a (temporary) payment gateway capture request for one ecommerce document and one of
    /// its payment lines. Both system ids must be non-blank or InitNcTaskFromPmtRequest rejects the request
    /// before it reaches any prerequisite check.</summary>
    procedure InitEcomCaptureRequest(EcomSalesHeader: Record "NPR Ecom Sales Header"; PaymentLine: Record "NPR Magento Payment Line"; var Request: Record "NPR PG Payment Request")
    begin
        Request.Init();
        Request."Document Table No." := Database::"NPR Ecom Sales Header";
        Request."Document System Id" := EcomSalesHeader.SystemId;
        Request."Payment Line System Id" := PaymentLine.SystemId;
        Request."Transaction ID" := PaymentLine."No.";
        Request."Request Amount" := PaymentLine.Amount;
    end;

    /// <summary>Legacy counterpart: a Sales Header carrying the Shopify Entry ID and Store Code assigned ids,
    /// plus a payment line with NO "NPR Inc Ecom Sale Id" - the shape the ecommerce capture block must leave
    /// alone.</summary>
    procedure CreateLegacySalesDocWithGatewayPaymentLine(StoreCode: Code[20]; DocumentNo: Code[20]; ShopifyId: Text[30]; var SalesHeader: Record "Sales Header"; var PaymentLine: Record "NPR Magento Payment Line")
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        // The insert trigger is deliberately not run, as in InsertSalesHeaderWithShopifyId: the gateway only resolves
        // the document by its system id and reads the assigned ids off it, so no posting setup is needed.
        if not SalesHeader.Get(SalesHeader."Document Type"::Order, DocumentNo) then begin
            SalesHeader.Init();
            SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
            SalesHeader."No." := DocumentNo;
            SalesHeader.Insert();
        end;
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyId, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);

        PaymentLine.Init();
        PaymentLine."Document Table No." := Database::"Sales Header";
        PaymentLine."Document Type" := SalesHeader."Document Type";
        PaymentLine."Document No." := SalesHeader."No.";
        PaymentLine."Line No." := 10000;
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::"Payment Method";
        PaymentLine.Amount := 100;
        PaymentLine."Requested Amount" := PaymentLine.Amount;
        PaymentLine.Insert();
    end;

    /// <summary>Single gift-card line. A gift card is classified as a virtual item straight from this flag
    /// (OrderLineIsGiftCard -> EvaluateLineType), so no item or voucher setup is needed to reach the code that
    /// protects already-issued virtual items.</summary>
    procedure GiftCardLineNodeText(LineId: Text; Sku: Code[20]; UnitPrice: Decimal; Qty: Integer): Text
    var
        Amount: Text;
    begin
        Amount := Format(UnitPrice, 0, 9);
        exit(
            '{"node":{' +
            '"id":"gid://shopify/LineItem/' + LineId + '",' +
            '"sku":"' + Sku + '",' +
            '"title":"Gift card","variantTitle":null,' +
            '"quantity":' + Format(Qty) + ',"unfulfilledQuantity":' + Format(Qty) + ',"currentQuantity":' + Format(Qty) + ',"nonFulfillableQuantity":0,' +
            '"isGiftCard":true,' +
            '"product":{"id":"gid://shopify/Product/2","productType":"giftcard"},' +
            '"variant":{"price":"' + Amount + '"},' +
            '"originalUnitPriceSet":{"presentmentMoney":{"amount":"' + Amount + '"}},' +
            '"taxLines":[],"discountAllocations":[]' +
            '}}');
    end;

    /// <summary>Wraps line-item and shipping-line array texts into a unified order JSON (data.order).</summary>
    procedure WrapOrderText(ShopifyId: Text; LineItemsArrText: Text; ShippingLinesArrText: Text) OrderResponse: JsonToken
    var
        Json: JsonToken;
        Builder: TextBuilder;
        InvalidErr: Label 'Built order JSON is not valid.', Locked = true;
    begin
        Builder.Append('{"data":{"order":{');
        Builder.Append('"id":"gid://shopify/Order/' + ShopifyId + '",');
        Builder.Append('"name":"#' + ShopifyId + '",');
        Builder.Append('"sourceName":"' + SourceNameTok + '",');
        Builder.Append('"number":1001,');
        Builder.Append('"taxesIncluded":false,');
        Builder.Append('"billingAddress":{"firstName":"Test","lastName":"Buyer","company":null,"countryCodeV2":"US","zip":"10001","address1":"1 Test St","address2":null,"city":"New York"},');
        Builder.Append('"shippingAddress":{"firstName":"Test","lastName":"Buyer","company":null,"countryCodeV2":"US","zip":"10001","address1":"1 Test St","address2":null,"city":"New York"},');
        Builder.Append('"customer":{"firstName":"Test","lastName":"Buyer","defaultAddress":{"phone":null}},');
        Builder.Append('"lineItems":' + LineItemsArrText + ',');
        Builder.Append('"shippingLines":' + ShippingLinesArrText + ',');
        Builder.Append('"transactions":[]');
        Builder.Append('}}}');
        if not Json.ReadFrom(Builder.ToText()) then
            Error(InvalidErr);
        OrderResponse := Json;
    end;

    /// <summary>Single item line carrying a line discount.</summary>
    procedure BuildItemOrderWithDiscountJson(ShopifyId: Text; Sku: Code[20]; UnitPrice: Decimal; DiscountAmount: Decimal): JsonToken
    var
        DiscountAlloc: Text;
    begin
        DiscountAlloc := '[{"allocatedAmountSet":{"presentmentMoney":{"amount":"' + Format(DiscountAmount, 0, 9) + '"}}}]';
        exit(WrapOrderText(ShopifyId, '[' + ItemLineNodeText('1', Sku, UnitPrice, 1, DiscountAlloc) + ']', '[]'));
    end;

    /// <summary>Two item lines (same item, distinct Shopify line ids).</summary>
    procedure BuildMultiLineItemOrderJson(ShopifyId: Text; Sku: Code[20]; UnitPrice: Decimal): JsonToken
    begin
        exit(WrapOrderText(ShopifyId,
            '[' + ItemLineNodeText('1', Sku, UnitPrice, 1, '[]') + ',' + ItemLineNodeText('2', Sku, UnitPrice, 1, '[]') + ']',
            '[]'));
    end;

    /// <summary>One item line plus a shipping line (shipping code must match a shipment mapping).</summary>
    procedure BuildItemOrderWithShippingJson(ShopifyId: Text; Sku: Code[20]; UnitPrice: Decimal; ShipCode: Code[50]; ShipFee: Decimal): JsonToken
    var
        ShippingArr: Text;
    begin
        ShippingArr :=
            '[{"node":{"id":"gid://shopify/ShippingLine/1","code":"' + ShipCode + '","title":"Standard",' +
            '"originalPriceSet":{"presentmentMoney":{"amount":"' + Format(ShipFee, 0, 9) + '"}},' +
            '"taxLines":[],"discountAllocations":[]}}]';
        exit(WrapOrderText(ShopifyId, '[' + ItemLineNodeText('1', Sku, UnitPrice, 1, '[]') + ']', ShippingArr));
    end;

    /// <summary>Simple item order including a successful AUTHORIZATION transaction (so the live-fetch guards pass on replay).</summary>
    procedure BuildReplayableItemOrderJson(ShopifyId: Text; Sku: Code[20]; UnitPrice: Decimal) OrderResponse: JsonToken
    var
        Json: JsonToken;
        Builder: TextBuilder;
        Amount: Text;
        InvalidErr: Label 'Built order JSON is not valid.', Locked = true;
    begin
        Amount := Format(UnitPrice, 0, 9);
        Builder.Append('{"data":{"order":{');
        Builder.Append('"id":"gid://shopify/Order/' + ShopifyId + '",');
        Builder.Append('"name":"#' + ShopifyId + '",');
        Builder.Append('"sourceName":"' + SourceNameTok + '",');
        Builder.Append('"number":1001,');
        Builder.Append('"taxesIncluded":false,');
        Builder.Append('"billingAddress":{"firstName":"Test","lastName":"Buyer","company":null,"countryCodeV2":"US","zip":"10001","address1":"1 Test St","address2":null,"city":"New York"},');
        Builder.Append('"shippingAddress":{"firstName":"Test","lastName":"Buyer","company":null,"countryCodeV2":"US","zip":"10001","address1":"1 Test St","address2":null,"city":"New York"},');
        Builder.Append('"customer":{"firstName":"Test","lastName":"Buyer","defaultAddress":{"phone":null}},');
        Builder.Append('"lineItems":[' + ItemLineNodeText('1', Sku, UnitPrice, 1, '[]') + '],');
        Builder.Append('"shippingLines":[],');
        Builder.Append('"transactions":[{"id":"gid://shopify/OrderTransaction/1","kind":"AUTHORIZATION","status":"SUCCESS",');
        Builder.Append('"amountSet":{"presentmentMoney":{"amount":"' + Amount + '","currencyCode":"USD"},"shopMoney":{"amount":"' + Amount + '","currencyCode":"USD"}}}]');
        Builder.Append('}}}');
        if not Json.ReadFrom(Builder.ToText()) then
            Error(InvalidErr);
        OrderResponse := Json;
    end;

    /// <summary>Writes a unified order JSON into the Event Log Entry "Order Data" blob (to test replay).</summary>
    procedure WriteOrderDataBlob(var LogEntry: Record "NPR Spfy Event Log Entry"; OrderResponse: JsonToken)
    var
        OutStr: OutStream;
    begin
        LogEntry."Order Data".CreateOutStream(OutStr, TextEncoding::UTF8);
        OrderResponse.WriteTo(OutStr);
        LogEntry.Modify();
    end;

    /// <summary>Creates or returns the location the Shopify fixtures post from. Every fixture that needs it calls
    /// this, so no test depends on another one having created it first - which only worked at all because one of
    /// the tests that has to Commit happened to commit the location along with its own data.</summary>
    procedure EnsureTestLocation()
    var
        Location: Record Location;
    begin
        if Location.Get('SPFYLOC') then
            exit;
        Location.Init();
        Location.Code := 'SPFYLOC';
        Location.Insert(true);
    end;

    /// <summary>Creates a postable Sales Order with one item line that already carries a Shopify Entry ID - the
    /// precondition for testing the update path. Self-contained: pass SalesLine."No." as the SKU when building the
    /// order JSON, so the line resolves back to the item this created rather than to something another test left
    /// in the database.</summary>
    procedure SetupSalesOrderWithShopifyLine(OrderLineId: Text[30]; UnitPrice: Decimal; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        Customer: Record Customer;
        Item: Record Item;
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryEcom: Codeunit "NPR Library - E-Commerce";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        EnsureTestLocation();
        LibrarySales.CreateCustomer(Customer);
        LibraryInventory.CreateItem(Item);
        LibraryEcom.IncreaseItemInventoryOnLocation(Item."No.", 100, 'SPFYLOC');

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("Location Code", 'SPFYLOC');
        SalesHeader.Modify(true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 1);
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Modify(true);

        SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", OrderLineId, false);
    end;

    /// <summary>Turns an ordinary item into a virtual one the way the importer sees it: "NPR Ecom Virtual Item Mgt"
    /// classifies a line as a ticket on nothing but Item."NPR Ticket Type" being filled, and OrderLineIsVirtualItem
    /// asks it through DetermineItemSubtype. A gift card cannot stand in for a virtual item on the unfulfilled path:
    /// CacheGiftCardOrderLine injects every gift-card order line into the fulfillment buffer, so a gift-card line
    /// always resolves through the snapshot and is handled by the fulfilled path instead.</summary>
    procedure MakeItemATicketItem(ItemNo: Code[20])
    var
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
        TicketTypeCodeTok: Label 'SPFYTT', Locked = true;
    begin
        if not TicketType.Get(TicketTypeCodeTok) then begin
            TicketType.Init();
            TicketType.Code := TicketTypeCodeTok;
            TicketType.Description := TicketTypeCodeTok;
            TicketType.Insert();
        end;

        // Assigned, not validated: the field is all the classification reads, and validating it pulls in the ticket
        // module's own setup, which this fixture has no use for.
        Item.Get(ItemNo);
        Item."NPR Ticket Type" := TicketType.Code;
        Item.Modify();
    end;

    /// <summary>Points the line's item at a VAT posting setup carrying the given rate, and re-validates the line so it
    /// picks the rate up. Without this a "Shopify reported no tax" test cannot fail: the fixture's own setup may already
    /// be 0 %, and then asserting 0 % proves nothing. Only the product side is moved - the setup is created for the VAT
    /// Bus. Posting Group the header already carries, because validating that field on a document that already has lines
    /// makes Business Central ask to recreate them, which would delete the fixture line the test is built on.</summary>
    procedure ApplyVATRateToSalesLine(VATRate: Decimal; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        LibraryERM: Codeunit "Library - ERM";
    begin
        LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);
        LibraryERM.CreateVATPostingSetup(VATPostingSetup, SalesHeader."VAT Bus. Posting Group", VATProductPostingGroup.Code);
        VATPostingSetup.Validate("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATPostingSetup.Validate("VAT %", VATRate);
        VATPostingSetup.Validate("VAT Identifier", VATProductPostingGroup.Code);
        VATPostingSetup.Validate("Sales VAT Account", LibraryERM.CreateGLAccountNo());
        VATPostingSetup.Validate("Purchase VAT Account", LibraryERM.CreateGLAccountNo());
        VATPostingSetup.Modify(true);

        Item.Get(SalesLine."No.");
        Item.Validate("VAT Prod. Posting Group", VATProductPostingGroup.Code);
        Item.Modify(true);

        SalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        SalesLine.Validate("VAT Prod. Posting Group", VATProductPostingGroup.Code);
        SalesLine.Modify(true);
    end;

    /// <summary>Order JSON for the update path: one line + a SUCCESS fulfillment for the given order line id.</summary>
    procedure BuildUpdateOrderJson(ShopifyId: Text; OrderLineId: Text[30]; Sku: Code[20]; UnitPrice: Decimal; FulfilledQty: Integer) OrderResponse: JsonToken
    var
        Json: JsonToken;
        Builder: TextBuilder;
        Amount: Text;
        QtyTxt: Text;
        InvalidErr: Label 'Built order JSON is not valid.', Locked = true;
    begin
        Amount := Format(UnitPrice, 0, 9);
        QtyTxt := Format(FulfilledQty);
        Builder.Append('{"data":{"order":{');
        Builder.Append('"id":"gid://shopify/Order/' + ShopifyId + '",');
        Builder.Append('"name":"#' + ShopifyId + '",');
        Builder.Append('"sourceName":"' + SourceNameTok + '","number":1001,"taxesIncluded":false,');
        Builder.Append('"lineItems":[' + ItemLineNodeText(OrderLineId, Sku, UnitPrice, FulfilledQty, '[]') + '],');
        Builder.Append('"fulfillments":[{"id":"gid://shopify/Fulfillment/1","status":"SUCCESS","displayStatus":"FULFILLED",');
        Builder.Append('"createdAt":"2026-06-23T11:58:31Z","updatedAt":"2026-06-23T11:58:32Z",');
        Builder.Append('"orderId":"gid://shopify/Order/' + ShopifyId + '","email":"buyer@test.com",');
        Builder.Append('"fulfillmentLineItems":[{"cursor":"a","node":{"id":"gid://shopify/FulfillmentLineItem/1","quantity":' + QtyTxt + ',');
        Builder.Append('"lineItem":{"id":"gid://shopify/LineItem/' + OrderLineId + '","currentQuantity":' + QtyTxt + ',"variant":{"price":"' + Amount + '"},"unfulfilledQuantity":0,"nonFulfillableQuantity":0,"isGiftCard":false,"originalUnitPriceSet":{"presentmentMoney":{"amount":"' + Amount + '"}}}}}]}],');
        Builder.Append('"shippingLines":[]');
        Builder.Append('}}}');
        if not Json.ReadFrom(Builder.ToText()) then
            Error(InvalidErr);
        OrderResponse := Json;
    end;

    /// <summary>Removes the log entries of one Shopify document. For tests that have to call Commit() - processing
    /// dispatches through Codeunit.Run and reads its result, which the platform only allows outside a write
    /// transaction - because committed rows survive the per-test rollback. Without this, a second run of the suite
    /// against the same database finds the previous run's entries under the same fixed Shopify ID and behaves
    /// differently than the first.</summary>
    procedure CleanupCommittedLogEntries(StoreCode: Code[20]; ShopifyId: Text[30])
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SpfyStore: Record "NPR Spfy Store";
    begin
        LogEntry.SetRange("Store Code", StoreCode);
        LogEntry.SetRange("Shopify ID", ShopifyId);
        if not LogEntry.IsEmpty() then
            LogEntry.DeleteAll();
        // Same reasoning as for the log entries above: tests using CreateInvoicedEcomDocument write an Ecommerce Sales
        // Header keyed on the Shopify ID as its External No., and CreateStore writes an NPR Spfy Store keyed on the
        // Store Code. Both survive the per-test rollback because the tests must Commit to run through Codeunit.Run.
        EcomSalesHeader.SetRange("External No.", ShopifyId);
        if not EcomSalesHeader.IsEmpty() then
            EcomSalesHeader.DeleteAll();
        if SpfyStore.Get(StoreCode) then
            SpfyStore.Delete();
        Commit();
    end;

    /// <summary>Order JSON carrying only what currency resolution reads: the money sets and the two currency codes.
    /// Same shape in the orders-list response the poller logs from and in the order details the processing fetches,
    /// so one fixture serves both attempts.</summary>
    procedure BuildOrderJsonWithCurrency(ShopifyId: Text; CurrencyCode: Code[10]; TotalAmount: Decimal): JsonToken
    begin
        exit(BuildOrderJsonWithCurrencies(ShopifyId, CurrencyCode, CurrencyCode, TotalAmount));
    end;

    /// <summary>Same, with the two currency codes set independently. Currency resolution writes the presentment
    /// currency before it reads the store currency, so an order whose presentment currency resolves and whose store
    /// currency does not is the only way to reach a failure that happens AFTER the "not resolved yet" sentinel has
    /// already been written.</summary>
    procedure BuildOrderJsonWithCurrencies(ShopifyId: Text; PresentmentCurrencyCode: Code[10]; StoreCurrencyCode: Code[10]; TotalAmount: Decimal) OrderResponse: JsonToken
    var
        Json: JsonToken;
        Builder: TextBuilder;
        Amount: Text;
        InvalidErr: Label 'Built order JSON is not valid.', Locked = true;
    begin
        Amount := Format(TotalAmount, 0, 9);
        Builder.Append('{"data":{"order":{');
        Builder.Append('"id":"gid://shopify/Order/' + ShopifyId + '",');
        Builder.Append('"name":"#' + ShopifyId + '",');
        Builder.Append('"sourceName":"' + SourceNameTok + '","number":1001,');
        Builder.Append('"createdAt":"2026-01-15T10:00:00Z",');
        Builder.Append('"currentTotalPriceSet":{"presentmentMoney":{"amount":"' + Amount + '"},"shopMoney":{"amount":"' + Amount + '"}},');
        Builder.Append('"presentmentCurrencyCode":"' + PresentmentCurrencyCode + '",');
        Builder.Append('"currencyCode":"' + StoreCurrencyCode + '"');
        Builder.Append('}}}');
        if not Json.ReadFrom(Builder.ToText()) then
            Error(InvalidErr);
        OrderResponse := Json;
    end;

}
#endif
