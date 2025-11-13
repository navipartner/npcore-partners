#if not (BC17 or BC18 or BC19 or BC20)
codeunit 6248589 "NPR Spfy Send BC Transaction"
{
    Access = Internal;
    TableNo = "NPR Nc Task";

    trigger OnRun()
    begin
        Rec.TestField("Store Code");
        case Rec."Table No." of
            Database::"NPR POS Entry":
                SendPOSEntry(Rec);
        end;
    end;

    var
        _GLSetup: Record "General Ledger Setup";
        _SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        _GLSetupRetrieved: Boolean;
        _OrderCreateQueryTok: Label 'mutation orderCreate($order: OrderCreateOrderInput!, $options: OrderCreateOptionsInput) {orderCreate(order: $order, options : $options) {userErrors{field message} order{id}}}', Locked = true;

    local procedure SendPOSEntry(var NcTask: Record "NPR Nc Task")
    var
        SpfyStorePOSEntryLink: Record "NPR Spfy Store-POS Entry Link";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        SendToShopify: Boolean;
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        Success := true;

        SendToShopify := PrepareShopifyOrderCreateRequest(NcTask, SpfyStorePOSEntryLink);
        if SendToShopify then
            Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse);
        NcTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());
        if not SendToShopify then
            exit;
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error('');

        AssignShopifyOrderID(SpfyStorePOSEntryLink, ShopifyResponse);
    end;

    local procedure AssignShopifyOrderID(SpfyStorePOSEntryLink: Record "NPR Spfy Store-POS Entry Link"; ShopifyResponse: JsonToken)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ShopifyOrderID: Text[30];
    begin
#pragma warning disable AA0139
        ShopifyOrderID := SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(ShopifyResponse, 'data.orderCreate.order.id', false), '/');
#pragma warning restore AA0139
        if ShopifyOrderID <> '' then
            SpfyAssignedIDMgt.AssignShopifyID(SpfyStorePOSEntryLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyOrderID, false);
    end;

    local procedure PrepareShopifyOrderCreateRequest(var NcTask: Record "NPR Nc Task"; var SpfyStorePOSEntryLink: Record "NPR Spfy Store-POS Entry Link") SendToShopify: Boolean
    var
        POSEntry: Record "NPR POS Entry";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfySendCustomer: Codeunit "NPR Spfy Send Customers";
        RecRef: RecordRef;
        QueryStream: OutStream;
        ShopifyCustomerID: Text[30];
        CustomerlessPOSEntryMsg: Label 'The POS entry number %1 was posted without a customer number being specified. The entry will not be sent to Shopify.', Comment = '%1 - POS entry number';
        CustomerNotSyncedErr: Label 'The customer number %1 has not yet been synchronized with Shopify store code %2.', Comment = '%1 - customer number, %2 - Shopify store code';
        POSEntryNotEligibleMsg: Label 'The POS entry number %1 is not eligible for synchronization. The entry will not be sent to Shopify.', Comment = '%1 - POS entry number';
        POSEntryAlreadySyncedMsg: Label 'The POS entry number %1 has already been synchronized with Shopify store code %2.', Comment = '%1 - POS entry number, %2 - Shopify store code';
    begin
        NcTask.TestField("Store Code");
        RecRef.Get(NcTask."Record ID");
        RecRef.SetTable(POSEntry);

        if POSEntry."Customer No." = '' then begin
            SpfyIntegrationMgt.SetResponse(NcTask, StrSubstNo(CustomerlessPOSEntryMsg, POSEntry."Entry No."));
            exit;
        end;

        SpfyStorePOSEntryLink."POS Entry No." := POSEntry."Entry No.";
        SpfyStorePOSEntryLink."Shopify Store Code" := NcTask."Store Code";
        if SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStorePOSEntryLink.RecordId(), "NPR Spfy ID Type"::"Entry ID") <> '' then begin
            SpfyIntegrationMgt.SetResponse(NcTask, StrSubstNo(POSEntryAlreadySyncedMsg, POSEntry."Entry No.", NcTask."Store Code"));
            exit;
        end;

        if not SpfySendCustomer.GetStoreCustomerLink(POSEntry."Customer No.", NcTask."Store Code", false, SpfyStoreCustomerLink) then
            Error(CustomerNotSyncedErr, POSEntry."Customer No.", NcTask."Store Code");
        ShopifyCustomerID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreCustomerLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyCustomerID = '' then
            Error(CustomerNotSyncedErr, POSEntry."Customer No.", NcTask."Store Code");

        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        if not PrepareShopifyOrderCreateRequestQuery(POSEntry, SpfyStoreCustomerLink."Shopify Store Code", ShopifyCustomerID, QueryStream) then begin
            SpfyIntegrationMgt.SetResponse(NcTask, StrSubstNo(POSEntryNotEligibleMsg, POSEntry."Entry No."));
            exit;
        end;
        SendToShopify := true;
    end;

    local procedure PrepareShopifyOrderCreateRequestQuery(POSEntry: Record "NPR POS Entry"; ShopifyStoreCode: Code[20]; ShopifyCustomerID: Text[30]; var QueryStream: OutStream): Boolean
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        SpfyStore: Record "NPR Spfy Store";
        SpfyPOSEntryExportMgt: Codeunit "NPR Spfy POS Entry Export Mgt.";
    begin
        if not SpfyPOSEntryExportMgt.IsEligibleForSync(POSEntry) then
            exit(false);
        SpfyStore.Get(ShopifyStoreCode);
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetFilter(Quantity, '>%1', 0); //Shopify only supports lines with a positive quantity
        if POSEntrySalesLine.IsEmpty() then
            exit(false);
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryPaymentLine.SetFilter("Amount (Sales Currency)", '<>%1', 0);
        ShopifyOrderCreateQuery(SpfyStore, ShopifyCustomerID, POSEntry, POSEntrySalesLine, POSEntryPaymentLine).WriteTo(QueryStream);
        exit(true);
    end;

    local procedure ShopifyOrderCreateQuery(SpfyStore: Record "NPR Spfy Store"; ShopifyCustomerID: Text[30]; POSEntry: Record "NPR POS Entry"; var POSEntrySalesLine: Record "NPR POS Entry Sales Line"; var POSEntryPaymentLine: Record "NPR POS Entry Payment Line"): JsonObject
    var
        CurrExchRate: Record "Currency Exchange Rate";
        TempConsolidatedPOSEntryPaymentLine: Record "NPR POS Entry Payment Line" temporary;
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        JsonBuilder: Codeunit "NPR Json Builder";
        ShopifyVariantID: Text[30];
        PresentmentMoneyCurrCode: Code[3];
        ShopMoneyCurrCode: Code[3];
        ShopMoneyAmount: Decimal;
        POSEntryProcessedAt: DateTime;
    begin
        GetGLSetup();
        if SpfyStore."Currency Code" = '' then
            SpfyStore."Currency Code" := _GLSetup."LCY Code";
        ShopMoneyCurrCode := _SpfyPaymentGatewayHdlr.CurrencyISOCode(SpfyStore."Currency Code");
        if POSEntry."Currency Code" = '' then
            POSEntry."Currency Code" := _GLSetup."LCY Code";
        if POSEntry."Currency Code" <> SpfyStore."Currency Code" then
            PresentmentMoneyCurrCode := _SpfyPaymentGatewayHdlr.CurrencyISOCode(POSEntry."Currency Code");
        If POSEntry."Entry Date" = DT2Date(POSEntry.SystemCreatedAt) then
            POSEntryProcessedAt := POSEntry.SystemCreatedAt
        else
            POSEntryProcessedAt := CreateDateTime(POSEntry."Entry Date", POSEntry."Ending Time");  //It may not be time zone adjusted

        JsonBuilder.StartObject();
        JsonBuilder.AddProperty('query', _OrderCreateQueryTok);
        JsonBuilder.StartObject('variables');
        JsonBuilder.StartObject('options');
        JsonBuilder.AddProperty('inventoryBehaviour', 'BYPASS');
        JsonBuilder.EndObject();  //options

        JsonBuilder.StartObject('order');
        JsonBuilder.AddProperty('fulfillmentStatus', 'FULFILLED');
        JsonBuilder.AddProperty('financialStatus', 'PAID');
        JsonBuilder.AddProperty('currency', ShopMoneyCurrCode);
        if PresentmentMoneyCurrCode <> '' then
            JsonBuilder.AddProperty('presentmentCurrency', PresentmentMoneyCurrCode);
        JsonBuilder.AddProperty('processedAt', POSEntryProcessedAt);
        JsonBuilder.AddProperty('closedAt', POSEntryProcessedAt);
        JsonBuilder.AddProperty('sourceIdentifier', StrSubstNo('POSEntry-%1', Format(POSEntry."Entry No.", 0, 9)));
        JsonBuilder.AddProperty('sourceName', NpRetailPOS_SourceName());
        JsonBuilder.AddProperty('sourceUrl', GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"NPR POS Entry Card", POSEntry));
        JsonBuilder.AddProperty('taxesIncluded', POSEntry."Prices Including VAT");

        JsonBuilder.StartArray('lineItems');
        if POSEntrySalesLine.FindSet() then
            repeat
                JsonBuilder.StartObject();  //line item
                if POSEntrySalesLine.Type = POSEntrySalesLine.Type::Item then begin
                    ShopifyVariantID := SpfyItemMgt.GetAssignedShopifyVariantID(POSEntrySalesLine."No.", POSEntrySalesLine."Variant Code", SpfyStore."Code", true);
                    if ShopifyVariantID <> '' then
                        JsonBuilder.AddProperty('variantId', 'gid://shopify/ProductVariant/' + ShopifyVariantID);
                    JsonBuilder.AddProperty('sku', SpfyItemMgt.GetProductVariantSku(POSEntrySalesLine."No.", POSEntrySalesLine."Variant Code"));
                end;
                JsonBuilder.AddProperty('title', GetLineDescription(POSEntrySalesLine));
                JsonBuilder.AddProperty('giftCard', false); //We cannot set this to true (or base it on POSEntrySalesLine.Type::Voucher), because Shopify will create duplicate gift cards
                JsonBuilder.AddProperty('quantity', ToInt(POSEntrySalesLine.Quantity));  //Shopify expects quantity as integer

                JsonBuilder.StartObject('priceSet');
                if PresentmentMoneyCurrCode <> '' then begin
                    JsonBuilder.StartObject('presentmentMoney');
                    JsonBuilder.AddProperty('amount', POSEntrySalesLine."Unit Price");
                    JsonBuilder.AddProperty('currencyCode', PresentmentMoneyCurrCode);
                    JsonBuilder.EndObject();  //presentmentMoney
                    ShopMoneyAmount := CurrExchRate.ExchangeAmount(POSEntrySalesLine."Unit Price", POSEntry."Currency Code", SpfyStore."Currency Code", POSEntry."Entry Date");
                end else
                    ShopMoneyAmount := POSEntrySalesLine."Unit Price";
                JsonBuilder.StartObject('shopMoney');
                JsonBuilder.AddProperty('amount', ShopMoneyAmount);
                JsonBuilder.AddProperty('currencyCode', ShopMoneyCurrCode);
                JsonBuilder.EndObject();  //shopMoney
                JsonBuilder.EndObject();  //priceSet

                JsonBuilder.StartArray('taxLines');
                JsonBuilder.StartObject();  //taxLine
                JsonBuilder.StartObject('priceSet');
                if PresentmentMoneyCurrCode <> '' then begin
                    JsonBuilder.StartObject('presentmentMoney');
                    JsonBuilder.AddProperty('amount', POSEntrySalesLine."Amount Incl. VAT" - POSEntrySalesLine."Amount Excl. VAT");
                    JsonBuilder.AddProperty('currencyCode', PresentmentMoneyCurrCode);
                    JsonBuilder.EndObject();  //presentmentMoney
                    ShopMoneyAmount := CurrExchRate.ExchangeAmount(POSEntrySalesLine."Amount Incl. VAT" - POSEntrySalesLine."Amount Excl. VAT", POSEntry."Currency Code", SpfyStore."Currency Code", POSEntry."Entry Date");
                end else
                    ShopMoneyAmount := POSEntrySalesLine."Amount Incl. VAT" - POSEntrySalesLine."Amount Excl. VAT";
                JsonBuilder.StartObject('shopMoney');
                JsonBuilder.AddProperty('amount', ShopMoneyAmount);
                JsonBuilder.AddProperty('currencyCode', ShopMoneyCurrCode);
                JsonBuilder.EndObject();  //shopMoney
                JsonBuilder.EndObject();  //priceSet (taxLine)
                JsonBuilder.AddProperty('rate', POSEntrySalesLine."VAT %" / 100);
                JsonBuilder.AddProperty('title', Format(POSEntrySalesLine."VAT Calculation Type"));
                JsonBuilder.EndObject();  //taxLine
                JsonBuilder.EndArray();  //taxLines
                JsonBuilder.EndObject();  //line item
            until POSEntrySalesLine.Next() = 0;
        JsonBuilder.EndArray();  //lineItems

        JsonBuilder.StartObject('customer');
        JsonBuilder.StartObject('toAssociate');
        JsonBuilder.AddProperty('id', 'gid://shopify/Customer/' + ShopifyCustomerID);
        JsonBuilder.EndObject();  //toAssociate
        JsonBuilder.EndObject();  //customer

        SummarizePaymentLines(POSEntryPaymentLine, TempConsolidatedPOSEntryPaymentLine);
        TempConsolidatedPOSEntryPaymentLine.SetFilter("Amount (Sales Currency)", '<>%1', 0);
        if TempConsolidatedPOSEntryPaymentLine.FindSet() then begin
            JsonBuilder.StartArray('transactions');
            repeat
                JsonBuilder.StartObject();  //transaction
                if TempConsolidatedPOSEntryPaymentLine."Amount (Sales Currency)" > 0 then
                    JsonBuilder.AddProperty('kind', 'SALE')
                else
                    JsonBuilder.AddProperty('kind', 'REFUND');
                JsonBuilder.AddProperty('status', 'SUCCESS');
                JsonBuilder.AddProperty('gateway', StrSubstNo('NPRetail.POS.%1', TempConsolidatedPOSEntryPaymentLine."POS Payment Method Code"));
                if TempConsolidatedPOSEntryPaymentLine."POS Payment Line Created At" <> 0DT then
                    JsonBuilder.AddProperty('processedAt', TempConsolidatedPOSEntryPaymentLine."POS Payment Line Created At")
                else
                    JsonBuilder.AddProperty('processedAt', POSEntryProcessedAt);
                JsonBuilder.StartObject('amountSet');
                if PresentmentMoneyCurrCode <> '' then begin
                    JsonBuilder.StartObject('presentmentMoney');
                    JsonBuilder.AddProperty('amount', Abs(TempConsolidatedPOSEntryPaymentLine."Amount (Sales Currency)"));
                    JsonBuilder.AddProperty('currencyCode', PresentmentMoneyCurrCode);
                    JsonBuilder.EndObject();  //presentmentMoney
                    ShopMoneyAmount := CurrExchRate.ExchangeAmount(Abs(TempConsolidatedPOSEntryPaymentLine."Amount (Sales Currency)"), POSEntry."Currency Code", SpfyStore."Currency Code", POSEntry."Entry Date");
                end else
                    ShopMoneyAmount := Abs(TempConsolidatedPOSEntryPaymentLine."Amount (Sales Currency)");
                JsonBuilder.StartObject('shopMoney');
                JsonBuilder.AddProperty('amount', ShopMoneyAmount);
                JsonBuilder.AddProperty('currencyCode', ShopMoneyCurrCode);
                JsonBuilder.EndObject();  //shopMoney
                JsonBuilder.EndObject();  //amountSet
                JsonBuilder.EndObject();  //transaction
            until TempConsolidatedPOSEntryPaymentLine.Next() = 0;
            JsonBuilder.EndArray();  //transactions
        end;
        JsonBuilder.EndObject();  //order
        JsonBuilder.EndObject();  //variables
        JsonBuilder.EndObject();

        exit(JsonBuilder.Build());
    end;

    local procedure SummarizePaymentLines(var POSEntryPaymentLine: Record "NPR POS Entry Payment Line"; var ConsolidatedPOSEntryPaymentLine: Record "NPR POS Entry Payment Line")
    begin
        if not ConsolidatedPOSEntryPaymentLine.IsTemporary() then
            FunctionCallOnNonTempVarErr('SummarizePaymentLines');
        ConsolidatedPOSEntryPaymentLine.Reset();
        ConsolidatedPOSEntryPaymentLine.DeleteAll();

        if POSEntryPaymentLine.FindSet() then
            repeat
                ConsolidatedPOSEntryPaymentLine.SetRange("POS Payment Method Code", POSEntryPaymentLine."POS Payment Method Code");
                ConsolidatedPOSEntryPaymentLine.SetRange("Currency Code", POSEntryPaymentLine."Currency Code");
                if not ConsolidatedPOSEntryPaymentLine.FindFirst() then begin
                    ConsolidatedPOSEntryPaymentLine := POSEntryPaymentLine;
                    ConsolidatedPOSEntryPaymentLine.Insert();
                end else begin
                    ConsolidatedPOSEntryPaymentLine."Amount (Sales Currency)" += POSEntryPaymentLine."Amount (Sales Currency)";
                    ConsolidatedPOSEntryPaymentLine.Modify();
                end;
            until POSEntryPaymentLine.Next() = 0;
        ConsolidatedPOSEntryPaymentLine.Reset();
    end;

    local procedure GetGLSetup()
    begin
        if _GLSetupRetrieved then
            exit;
        _GLSetupRetrieved := true;
        if not _GLSetup.Get() then
            _GLSetup.Init();
    end;

    local procedure GetLineDescription(POSEntrySalesLine: Record "NPR POS Entry Sales Line"): Text
    var
        Result: Text;
    begin
        Result := POSEntrySalesLine.Description;
        if POSEntrySalesLine."Description 2" <> '' then begin
            if Result <> '' then
                Result += ' ';
            Result += POSEntrySalesLine."Description 2";
        end;
        exit(Result);
    end;

    local procedure ToInt(Quantity: Decimal): Integer
    begin
        if Quantity < 0 then
            exit(Round(Quantity, 1, '<'));
        exit(Round(Quantity, 1, '>'));
    end;

    internal procedure NpRetailPOS_SourceName(): Text
    begin
        exit('NPRetailPOS');
    end;

    local procedure FunctionCallOnNonTempVarErr(ProcedureName: Text)
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        SpfyIntegrationMgt.FunctionCallOnNonTempVarErr(StrSubstNo('[Codeunit::NPR Spfy Send BC Transaction(%1)].%2', CurrCodeunitID(), ProcedureName));
    end;

    local procedure CurrCodeunitID(): Integer
    begin
        exit(Codeunit::"NPR Spfy Send BC Transaction");
    end;
}
#endif