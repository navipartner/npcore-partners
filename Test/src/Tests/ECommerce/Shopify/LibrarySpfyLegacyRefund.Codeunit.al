codeunit 85511 "NPR Library Spfy Legacy Refund"
{
    Access = Internal;

    /// <summary>
    /// Builds a Return Order through the document builder from return detail JSON, with no queue row, as another import path would.
    /// </summary>
    procedure BuildReturnOrderWithoutQueue(StoreCode: Code[20]; DetailJson: Text; ShopifyId: Text[30]; var SalesHeader: Record "Sales Header"): Enum "NPR Spfy Refund Build Outcome"
    var
        ShopifyStore: Record "NPR Spfy Store";
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempEarlierLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Builder: Codeunit "NPR Spfy Refund Doc. Builder";
        Response: JsonToken;
        OutcomeMessage: Text;
        UsedLocationFallback: Boolean;
    begin
        ShopifyStore.Get(StoreCode);
        Response.ReadFrom(DetailJson);
        SpfyLegacyReturnAPI.ParseReturnDetail(StoreCode, ShopifyId, Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);
        TempReturnBuffer.Get(ShopifyId);
        exit(Builder.BuildReturnOrder(ShopifyStore, TempReturnBuffer, TempLineBuffer, TempEarlierLineBuffer, TempRefundTxnBuffer, SalesHeader, UsedLocationFallback, OutcomeMessage));
    end;

    /// <summary>
    /// One order in the poll response with the given return edges and refunds list.
    /// </summary>
    procedure RefundListResponse(OrderGid: Text; OrderName: Text; ReturnEdgesJson: Text; RefundsJson: Text): Text
    var
        RefundListTok: Label '{"data":{"orders":{"edges":[{"node":{"id":"%1","name":"%2","updatedAt":"2026-09-20T10:00:00Z","returns":{"edges":[%3],"pageInfo":{"endCursor":null,"hasNextPage":false}},"refunds":[%4]}}],"pageInfo":{"endCursor":null,"hasNextPage":false}}}}', Locked = true;
    begin
        exit(StrSubstNo(RefundListTok, OrderGid, OrderName, ReturnEdgesJson, RefundsJson));
    end;

    procedure RefundListItemJson(RefundId: Text; CreatedAt: Text; ReturnGid: Text): Text
    var
        ReturnJson: Text;
        RefundListItemTok: Label '{"id":"gid://shopify/Refund/%1","createdAt":"%2","return":%3}', Locked = true;
    begin
        ReturnJson := 'null';
        if ReturnGid <> '' then
            ReturnJson := '{"id":"' + ReturnGid + '"}';
        exit(StrSubstNo(RefundListItemTok, RefundId, CreatedAt, ReturnJson));
    end;

    procedure ClosedReturnEdgeJson(ReturnGid: Text; ReturnName: Text): Text
    var
        ClosedReturnEdgeTok: Label '{"node":{"id":"%1","name":"%2","status":"CLOSED","createdAt":"2026-09-19T09:00:00Z","closedAt":"2026-09-20T10:00:00Z"}}', Locked = true;
    begin
        exit(StrSubstNo(ClosedReturnEdgeTok, ReturnGid, ReturnName));
    end;

    procedure RefundDetailResponse(RefundId: Text; OrderId: Text; OrderName: Text; CreatedAt: Text; TaxesIncluded: Boolean; RefundLinesJson: Text; ShippingLinesJson: Text; AdjustmentsJson: Text; TransactionsJson: Text): Text
    var
        RefundDetailTok: Label '{"data":{"refund":{"id":"gid://shopify/Refund/%1","createdAt":"%4","processedAt":"%4","return":null,"order":{"id":"gid://shopify/Order/%2","name":"%3","number":9001,"email":"anna@npretail.test","phone":null,"sourceName":"web","taxesIncluded":%5,"currencyCode":"%10","presentmentCurrencyCode":"%10","customer":{"id":"gid://shopify/Customer/501","firstName":"Anna","lastName":"Test","defaultEmailAddress":{"emailAddress":"anna@npretail.test"},"defaultPhoneNumber":null,"defaultAddress":{"phone":null}},"billingAddress":{"firstName":"Anna","lastName":"Test","company":null,"countryCodeV2":"DK","zip":"2100","address1":"Testvej 1","address2":null,"city":"Copenhagen"},"shippingAddress":{"firstName":"Anna","lastName":"Test","company":null,"address1":"Testvej 1","address2":null,"zip":"2100","city":"Copenhagen","countryCodeV2":"DK","phone":null}},"refundLineItems":{"pageInfo":{"hasNextPage":false},"edges":[%6]},"refundShippingLines":{"pageInfo":{"hasNextPage":false},"edges":[%7]},"orderAdjustments":{"pageInfo":{"hasNextPage":false},"edges":[%8]},"transactions":{"pageInfo":{"hasNextPage":false},"edges":[%9]}}}}', Locked = true;
    begin
        exit(StrSubstNo(RefundDetailTok, RefundId, OrderId, OrderName, CreatedAt, Format(TaxesIncluded, 0, 9), RefundLinesJson, ShippingLinesJson, AdjustmentsJson, TransactionsJson, _ReturnLib.Lcy()));
    end;

    procedure RefundLineJson(LineItemId: Text; Sku: Text; Qty: Integer; RestockType: Text; LocationId: Text; Subtotal: Decimal; Tax: Decimal; VatRate: Decimal): Text
    begin
        exit(RefundLineJsonOrdered(LineItemId, Sku, Qty, Qty, RestockType, LocationId, Subtotal, Tax, VatRate));
    end;

    /// <summary>
    /// A refund line whose order line was ordered OrderedQty times in Shopify, refunded and removed units included.
    /// </summary>
    procedure RefundLineJsonOrdered(LineItemId: Text; Sku: Text; Qty: Integer; OrderedQty: Integer; RestockType: Text; LocationId: Text; Subtotal: Decimal; Tax: Decimal; VatRate: Decimal): Text
    var
        LocationJson: Text;
        Restocked: Text;
        RefundLineTok: Label '{"node":{"quantity":%1,"restockType":"%2","restocked":%3,"location":%4,"subtotalSet":{"presentmentMoney":{"amount":"%5"}},"totalTaxSet":{"presentmentMoney":{"amount":"%6"}},"lineItem":{"id":"gid://shopify/LineItem/%7","quantity":%10,"sku":"%8","title":"Test jacket","isGiftCard":false,"customAttributes":[],"variant":{"id":"gid://shopify/ProductVariant/1","sku":"%8","barcode":null},"taxLines":[{"ratePercentage":%9}]}}}', Locked = true;
    begin
        LocationJson := 'null';
        if LocationId <> '' then
            LocationJson := '{"id":"gid://shopify/Location/' + LocationId + '"}';
        Restocked := 'false';
        if RestockType in ['RETURN', 'CANCEL', 'LEGACY_RESTOCK'] then
            Restocked := 'true';
        exit(StrSubstNo(RefundLineTok, Qty, RestockType, Restocked, LocationJson, Format(Subtotal, 0, 9), Format(Tax, 0, 9), LineItemId, Sku, Format(VatRate, 0, 9), OrderedQty));
    end;

    procedure GiftCardRefundLineJson(LineItemId: Text; Qty: Integer; Gross: Decimal; ShopifyNative: Boolean): Text
    var
        Attributes: Text;
        GiftCardRefundLineTok: Label '{"node":{"quantity":%1,"restockType":"NO_RESTOCK","restocked":false,"location":null,"subtotalSet":{"presentmentMoney":{"amount":"%2"}},"totalTaxSet":{"presentmentMoney":{"amount":"0"}},"lineItem":{"id":"gid://shopify/LineItem/%3","quantity":%6,"sku":null,"title":"Gift Card","isGiftCard":%4,"customAttributes":%5,"variant":{"id":"gid://shopify/ProductVariant/2","sku":null,"barcode":null},"taxLines":[{"ratePercentage":0}]}}}', Locked = true;
    begin
        Attributes := '[{"key":"_is_giftcard","value":"1"}]';
        if ShopifyNative then
            Attributes := '[]';
        exit(StrSubstNo(GiftCardRefundLineTok, Qty, Format(Gross, 0, 9), LineItemId, Format(ShopifyNative, 0, 9), Attributes, Qty));
    end;

    /// <summary>
    /// The order's refunds as the refund import lists them; RefundsJson is a comma-separated list of RefundListItemJson.
    /// </summary>
    procedure OrderRefundsResponse(OrderId: Text; RefundsJson: Text): Text
    var
        OrderRefundsTok: Label '{"data":{"order":{"id":"gid://shopify/Order/%1","refunds":[%2]}}}', Locked = true;
    begin
        exit(StrSubstNo(OrderRefundsTok, OrderId, RefundsJson));
    end;

    procedure BelongingToReturn(RefundDetailJson: Text; ReturnId: Text): Text
    begin
        exit(RefundDetailJson.Replace('"return":null', '"return":{"id":"gid://shopify/Return/' + ReturnId + '"}'));
    end;

    procedure OfCancelledOrder(RefundDetailJson: Text): Text
    begin
        exit(RefundDetailJson.Replace('"number":9001,', '"number":9001,"cancelledAt":"2026-09-20T09:00:00Z",'));
    end;

    /// <summary>
    /// A refund time one minute from now, so invoices a test posts first count as made before the refund.
    /// </summary>
    procedure RefundTimeAfterNow(): Text
    begin
        exit(Format(CurrentDateTime() + 60000, 0, 9));
    end;

    procedure InsertRefundQueueRow(StoreCode: Code[20]; RefundId: Text; OrderId: Text[30]; OrderName: Text; var QueueRow: Record "NPR Spfy NC Return Queue")
    begin
        _ReturnLib.InsertQueueRow(StoreCode, QueueRow."Source Doc. Type"::Refund, CopyStr(RefundId, 1, 30), OrderId, OrderName, QueueRow);
    end;

    /// <summary>
    /// Posts a Shopify order of one line as the legacy order import does, paid as its Magento payment lines pay it at posting.
    /// </summary>
    procedure PostShopifyOrder(StoreCode: Code[20]; CustomerNo: Code[20]; Sku: Code[20]; LocationCode: Code[10]; OrderId: Text[30]; LineItemId: Text[30]; Qty: Decimal; UnitPrice: Decimal; var ShipmentNo: Code[20]) InvoiceNo: Code[20]
    begin
        InvoiceNo := PostShopifyOrderUnpaid(StoreCode, CustomerNo, Sku, LocationCode, OrderId, LineItemId, Qty, UnitPrice, ShipmentNo);
        PayInvoice(StoreCode, InvoiceNo);
    end;

    /// <summary>
    /// As the order import posts an order whose payment line it dropped: Entry IDs on header and line, shipped and invoiced, the invoice left open.
    /// </summary>
    procedure PostShopifyOrderUnpaid(StoreCode: Code[20]; CustomerNo: Code[20]; Sku: Code[20]; LocationCode: Code[10]; OrderId: Text[30]; LineItemId: Text[30]; Qty: Decimal; UnitPrice: Decimal; var ShipmentNo: Code[20]) InvoiceNo: Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        LibrarySales: Codeunit "Library - Sales";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        OrderNo: Code[20];
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, CustomerNo);
        SalesHeader.Validate("Location Code", LocationCode);
        SalesHeader.Validate("Prices Including VAT", true);
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Sku, Qty);
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Modify(true);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", OrderId, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", LineItemId, false);
        OrderNo := SalesHeader."No.";
        InvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesShipmentHeader.SetRange("Order No.", OrderNo);
        SalesShipmentHeader.FindLast();
        ShipmentNo := SalesShipmentHeader."No.";
    end;

    /// <summary>
    /// Pays a posted invoice in full, as the Magento payment lines do when the order import posts it.
    /// </summary>
    procedure PayInvoice(StoreCode: Code[20]; InvoiceNo: Code[20])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";
        ShopifyStore: Record "NPR Spfy Store";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        ShopifyStore.Get(StoreCode);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", InvoiceNo);
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount");
        GenJnlLine.Init();
        // A payment carries no VAT.
        GenJnlLine."Copy VAT Setup to Jnl. Lines" := false;
        GLSetup.Get();
        if GLSetup."Journal Templ. Name Mandatory" then
            GenJnlLine."Journal Template Name" := CustLedgerEntry."Journal Templ. Name";
        GenJnlLine."Posting Date" := CustLedgerEntry."Posting Date";
        GenJnlLine."Document Date" := CustLedgerEntry."Posting Date";
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        GenJnlLine."Document No." := InvoiceNo;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine.Validate("Account No.", CustLedgerEntry."Customer No.");
        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
        GenJnlLine.Validate("Bal. Account No.", ShopifyStore."Return Refund G/L Account No.");
        GenJnlLine."Currency Code" := CustLedgerEntry."Currency Code";
        GenJnlLine."Currency Factor" := 1;
        GenJnlLine.Validate(Amount, -CustLedgerEntry."Remaining Amount");
        GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice;
        GenJnlLine."Applies-to Doc. No." := InvoiceNo;
        GenJnlLine."Source Code" := CustLedgerEntry."Source Code";
        GenJnlPostLine.RunWithCheck(GenJnlLine);
    end;

    procedure CreateOpenShopifyOrder(StoreCode: Code[20]; CustomerNo: Code[20]; Sku: Code[20]; OrderId: Text[30]; var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, CustomerNo);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Sku, 1);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", OrderId, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);
    end;

    procedure EnsureRefundItemCharge(StoreCode: Code[20]; Sku: Code[20]): Code[20]
    var
        ItemCharge: Record "Item Charge";
        Item: Record Item;
        ShopifyStore: Record "NPR Spfy Store";
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        Item.Get(Sku);
        LibraryInventory.CreateItemCharge(ItemCharge);
        ItemCharge."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
        // A VAT group of its own, so only the builder's override gives the charge line the item's VAT.
        ItemCharge."VAT Prod. Posting Group" := EnsureOtherVatProdPostingGroup(Item."VAT Prod. Posting Group");
        ItemCharge.Modify();
        ShopifyStore.Get(StoreCode);
        ShopifyStore."Refund Item Charge No." := ItemCharge."No.";
        ShopifyStore.Modify();
        exit(ItemCharge."No.");
    end;

    local procedure EnsureOtherVatProdPostingGroup(ItemVatProdPostingGroup: Code[20]): Code[20]
    var
        VATProductPostingGroup: Record "VAT Product Posting Group";
        VATPostingSetup: Record "VAT Posting Setup";
        OtherVATPostingSetup: Record "VAT Posting Setup";
        OtherGroupCode: Code[20];
    begin
        OtherGroupCode := 'SPFYCHGVAT';
        // Library items can pick this group up themselves, as the first setup that matches, so it must differ from the item's.
        if ItemVatProdPostingGroup = OtherGroupCode then
            OtherGroupCode := 'SPFYCHGVAT2';
        if not VATProductPostingGroup.Get(OtherGroupCode) then begin
            VATProductPostingGroup.Init();
            VATProductPostingGroup.Code := OtherGroupCode;
            VATProductPostingGroup.Description := 'Refund item charge test VAT';
            VATProductPostingGroup.Insert();
        end;
        VATPostingSetup.SetRange("VAT Prod. Posting Group", ItemVatProdPostingGroup);
        if VATPostingSetup.FindSet() then
            repeat
                if not OtherVATPostingSetup.Get(VATPostingSetup."VAT Bus. Posting Group", OtherGroupCode) then begin
                    OtherVATPostingSetup := VATPostingSetup;
                    OtherVATPostingSetup."VAT Prod. Posting Group" := OtherGroupCode;
                    OtherVATPostingSetup."VAT Identifier" := OtherGroupCode;
                    OtherVATPostingSetup."VAT %" := VATPostingSetup."VAT %" + 5;
                    OtherVATPostingSetup.Insert();
                end;
            until VATPostingSetup.Next() = 0;
        exit(OtherGroupCode);
    end;

    /// <summary>
    /// Posts a two-unit order line in two partial shipments and invoices, as an order fulfilled in two parcels, both paid.
    /// </summary>
    procedure PostShopifyOrderInTwoParts(StoreCode: Code[20]; CustomerNo: Code[20]; Sku: Code[20]; LocationCode: Code[10]; OrderId: Text[30]; LineItemId: Text[30]; UnitPrice: Decimal)
    var
        InvoiceNos: List of [Code[20]];
        InvoiceNo: Code[20];
    begin
        PostShopifyOrderInTwoPartsUnpaid(StoreCode, CustomerNo, Sku, LocationCode, OrderId, LineItemId, UnitPrice, InvoiceNos);
        foreach InvoiceNo in InvoiceNos do
            PayInvoice(StoreCode, InvoiceNo);
    end;

    procedure PostShopifyOrderInTwoPartsUnpaid(StoreCode: Code[20]; CustomerNo: Code[20]; Sku: Code[20]; LocationCode: Code[10]; OrderId: Text[30]; LineItemId: Text[30]; UnitPrice: Decimal; var InvoiceNos: List of [Code[20]])
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        Part: Integer;
    begin
        Clear(InvoiceNos);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, CustomerNo);
        SalesHeader.Validate("Location Code", LocationCode);
        SalesHeader.Validate("Prices Including VAT", true);
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Sku, 2);
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Modify(true);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", OrderId, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", LineItemId, false);
        for Part := 1 to 2 do begin
            SalesLine.Find();
            SalesLine.Validate("Qty. to Ship", 1);
            SalesLine.Validate("Qty. to Invoice", 1);
            SalesLine.Modify(true);
            SalesHeader.Find();
            InvoiceNos.Add(LibrarySales.PostSalesDocument(SalesHeader, true, true));
        end;
    end;

    /// <summary>
    /// Posts a one-unit order line as shipped, undoes that shipment, then ships and invoices it again, paid; returns both shipment numbers.
    /// </summary>
    procedure PostShopifyOrderShippedUndoneAndReshipped(StoreCode: Code[20]; CustomerNo: Code[20]; Sku: Code[20]; LocationCode: Code[10]; OrderId: Text[30]; LineItemId: Text[30]; UnitPrice: Decimal; var UndoneShipmentNo: Code[20]; var ReshipmentNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        LibrarySales: Codeunit "Library - Sales";
        UndoSalesShipmentLine: Codeunit "Undo Sales Shipment Line";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        OrderNo: Code[20];
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, CustomerNo);
        SalesHeader.Validate("Location Code", LocationCode);
        SalesHeader.Validate("Prices Including VAT", true);
        SalesHeader.Modify(true);
        OrderNo := SalesHeader."No.";
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Sku, 1);
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Modify(true);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", OrderId, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", LineItemId, false);
        LibrarySales.PostSalesDocument(SalesHeader, true, false);
        SalesShipmentHeader.SetRange("Order No.", OrderNo);
        SalesShipmentHeader.FindLast();
        UndoneShipmentNo := SalesShipmentHeader."No.";
        SalesShipmentLine.SetRange("Document No.", UndoneShipmentNo);
        SalesShipmentLine.SetRange(Type, SalesShipmentLine.Type::Item);
        UndoSalesShipmentLine.SetHideDialog(true);
        UndoSalesShipmentLine.Run(SalesShipmentLine);
        SalesLine.Find();
        SalesLine.Validate("Qty. to Ship", 1);
        SalesLine.Validate("Qty. to Invoice", 1);
        SalesLine.Modify(true);
        SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo);
        PayInvoice(StoreCode, LibrarySales.PostSalesDocument(SalesHeader, true, true));
        SalesShipmentHeader.FindLast();
        ReshipmentNo := SalesShipmentHeader."No.";
    end;

    procedure PostShopifyOrderTwoLines(StoreCode: Code[20]; CustomerNo: Code[20]; LocationCode: Code[10]; OrderId: Text[30]; SkuA: Code[20]; LineItemIdA: Text[30]; SkuB: Code[20]; LineItemIdB: Text[30]; UnitPrice: Decimal)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, CustomerNo);
        SalesHeader.Validate("Location Code", LocationCode);
        SalesHeader.Validate("Prices Including VAT", true);
        SalesHeader.Modify(true);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", OrderId, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, SkuA, 1);
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Modify(true);
        SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", LineItemIdA, false);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, SkuB, 1);
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Modify(true);
        SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", LineItemIdB, false);
        PayInvoice(StoreCode, LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    /// <summary>
    /// Posts line A of a two-line order and keeps line B open, as the legacy import posts a partly fulfilled order; the Sales Order stays.
    /// </summary>
    procedure PostShopifyOrderFirstLineOnly(StoreCode: Code[20]; CustomerNo: Code[20]; LocationCode: Code[10]; OrderId: Text[30]; SkuA: Code[20]; LineItemIdA: Text[30]; SkuB: Code[20]; LineItemIdB: Text[30]; UnitPrice: Decimal; var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, CustomerNo);
        SalesHeader.Validate("Location Code", LocationCode);
        SalesHeader.Validate("Prices Including VAT", true);
        SalesHeader.Modify(true);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", OrderId, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, SkuA, 1);
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Modify(true);
        SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", LineItemIdA, false);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, SkuB, 1);
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Validate("Qty. to Ship", 0);
        SalesLine.Validate("Qty. to Invoice", 0);
        SalesLine.Modify(true);
        SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", LineItemIdB, false);
        PayInvoice(StoreCode, LibrarySales.PostSalesDocument(SalesHeader, true, true));
        SalesHeader.Find();
    end;

    /// <summary>
    /// Ships and invoices what is left on the order and pays it; Sales-Post deletes the fully invoiced Sales Order.
    /// </summary>
    procedure PostRemainingLines(StoreCode: Code[20]; var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                if SalesLine."Outstanding Quantity" > 0 then begin
                    SalesLine.Validate("Qty. to Ship", SalesLine."Outstanding Quantity");
                    SalesLine.Modify(true);
                end;
            until SalesLine.Next() = 0;
        SalesHeader.Find();
        PayInvoice(StoreCode, LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    /// <summary>
    /// Posts one of two units of a Shopify order paid, then cuts the line to the posted unit as the order import does once Shopify cancels the other: the Sales Order stays with nothing left to post.
    /// </summary>
    procedure PostShopifyOrderLeavingNothingToPost(StoreCode: Code[20]; CustomerNo: Code[20]; Sku: Code[20]; LocationCode: Code[10]; OrderId: Text[30]; LineItemId: Text[30]; UnitPrice: Decimal; var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, CustomerNo);
        SalesHeader.Validate("Location Code", LocationCode);
        SalesHeader.Validate("Prices Including VAT", true);
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Sku, 2);
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Validate("Qty. to Ship", 1);
        SalesLine.Validate("Qty. to Invoice", 1);
        SalesLine.Modify(true);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", OrderId, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", LineItemId, false);
        PayInvoice(StoreCode, LibrarySales.PostSalesDocument(SalesHeader, true, true));
        SalesLine.Find();
        SalesLine.Validate(Quantity, 1);
        SalesLine.Modify(true);
        SalesHeader.Find();
    end;

    /// <summary>
    /// A Sales Order of a Shopify order whose only line was cut to zero, as when every unit was refunded before anything was posted: nothing left to post and no invoice.
    /// </summary>
    procedure CreateShopifyOrderWithNothingToPost(StoreCode: Code[20]; CustomerNo: Code[20]; Sku: Code[20]; OrderId: Text[30]; var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        CreateOpenShopifyOrder(StoreCode, CustomerNo, Sku, OrderId, SalesHeader);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        SalesLine.Validate(Quantity, 0);
        SalesLine.Modify(true);
    end;

    /// <summary>
    /// A Sales Order of a Shopify order with one unit shipped but not invoiced yet.
    /// </summary>
    procedure PostShopifyOrderShippedOnly(StoreCode: Code[20]; CustomerNo: Code[20]; Sku: Code[20]; LocationCode: Code[10]; OrderId: Text[30]; LineItemId: Text[30]; var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, CustomerNo);
        SalesHeader.Validate("Location Code", LocationCode);
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Sku, 1);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", OrderId, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", LineItemId, false);
        LibrarySales.PostSalesDocument(SalesHeader, true, false);
        SalesHeader.Find();
    end;

    /// <summary>
    /// Invoices the posted shipments of a Sales Order on a separate Sales Invoice through Get Shipment Lines, as Combine Shipments does; that invoice carries no Shopify stamps.
    /// </summary>
    procedure InvoiceShipmentsOfOrder(CustomerNo: Code[20]; OrderNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        LibrarySales: Codeunit "Library - Sales";
        SalesGetShipment: Codeunit "Sales-Get Shipment";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, CustomerNo);
        SalesShipmentLine.SetRange("Order No.", OrderNo);
        SalesGetShipment.SetSalesHeader(SalesHeader);
        SalesGetShipment.CreateInvLines(SalesShipmentLine);
        SalesHeader.Find();
        LibrarySales.PostSalesDocument(SalesHeader, false, true);
    end;

    /// <summary>
    /// A Return Order stamped with a Shopify id and the store, as another engine leaves it, without a settlement row of its own.
    /// </summary>
    procedure CreateStampedReturnOrder(StoreCode: Code[20]; CustomerNo: Code[20]; Sku: Code[20]; LocationCode: Code[10]; ShopifyId: Text[30]; UnitPrice: Decimal; var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Return Order", CustomerNo);
        SalesHeader.Validate("Location Code", LocationCode);
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Sku, 1);
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Modify(true);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyId, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);
    end;

    /// <summary>
    /// Adds the order's line items to a return or refund detail; LineItemsJson is a comma-separated list of OrderLineItemJson.
    /// </summary>
    procedure WithOrderLineItems(DetailJson: Text; LineItemsJson: Text): Text
    var
        Assert: Codeunit Assert;
        CustomerTok: Text;
        OrderLineItemsTok: Label '"lineItems":{"pageInfo":{"hasNextPage":false},"edges":[%1]},', Locked = true;
    begin
        CustomerTok := '"customer":{"id":"gid://shopify/Customer/';
        Assert.IsTrue(DetailJson.Contains(CustomerTok), 'Fixture: the detail must carry the order''s customer.');
        exit(DetailJson.Replace(CustomerTok, StrSubstNo(OrderLineItemsTok, LineItemsJson) + CustomerTok));
    end;

    /// <summary>
    /// An order line as Shopify reports it now: its original unit price, and the discount allocated to the whole line, including one given after the sale.
    /// </summary>
    procedure OrderLineItemJson(LineItemId: Text; OrderedQty: Integer; OriginalUnitPrice: Decimal; Discount: Decimal; VatRate: Decimal): Text
    var
        OrderLineItemTok: Label '{"node":{"id":"gid://shopify/LineItem/%1","quantity":%2,"originalUnitPriceSet":{"presentmentMoney":{"amount":"%3"}},"discountAllocations":[{"allocatedAmountSet":{"presentmentMoney":{"amount":"%4"}}}],"taxLines":[{"ratePercentage":%5}]}}', Locked = true;
    begin
        exit(StrSubstNo(OrderLineItemTok, LineItemId, OrderedQty, Format(OriginalUnitPrice, 0, 9), Format(Discount, 0, 9), Format(VatRate, 0, 9)));
    end;

    /// <summary>
    /// Gives the store's discrepancy account a VAT group other than the items', so only a line that takes the item's VAT carries it.
    /// </summary>
    procedure UseOtherVatOnDiscrepancyAccount(StoreCode: Code[20]; Sku: Code[20])
    var
        GLAccount: Record "G/L Account";
        Item: Record Item;
        ShopifyStore: Record "NPR Spfy Store";
    begin
        Item.Get(Sku);
        ShopifyStore.Get(StoreCode);
        GLAccount.Get(ShopifyStore."Refund Discrepancy G/L Acc.");
        GLAccount."VAT Prod. Posting Group" := EnsureOtherVatProdPostingGroup(Item."VAT Prod. Posting Group");
        GLAccount.Modify();
    end;

    procedure AssertNoReturnOrder(CustomerNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        Assert: Codeunit Assert;
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        Assert.IsTrue(SalesHeader.IsEmpty(), 'A refused import must leave no Return Order.');
    end;

    procedure PostReturnOrder(var SalesHeader: Record "Sales Header"): Boolean
    var
        SalesPost: Codeunit "Sales-Post";
    begin
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        Commit();
        ClearLastError();
        exit(SalesPost.Run(SalesHeader));
    end;

    var
        _ReturnLib: Codeunit "NPR Library Spfy Legacy Return";
}
