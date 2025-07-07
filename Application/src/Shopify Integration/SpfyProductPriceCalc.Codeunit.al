#if not BC17
codeunit 6185050 "NPR Spfy Product Price Calc."
{
    Access = Internal;
    Permissions =
        tabledata Customer = rmid,
        tabledata Item = r,
        tabledata "Item Unit of Measure" = r,
        tabledata "Sales Header" = rimd,
        tabledata "Sales Line" = rmid,
        tabledata "VAT Posting Setup" = r;

    var
        TempSalesHeader: Record "Sales Header" temporary;
        _SpfyStoreCode: Code[20];
        _SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";

    internal procedure CalcCompareAtPrice(ShopifyStoreCode: Code[20]; CurrencyCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; ItemPriceDate: Date): Decimal
    var
        Item: Record Item;
        ShopifyStore: Record "NPR Spfy Store";
        Price: Decimal;
        ComparePrice: Decimal;
    begin
        Item.Get(ItemNo);
        ShopifyStore.Get(ShopifyStoreCode);
        ShopifyStore."Currency Code" := CurrencyCode;
        Initialize(ShopifyStore, ItemPriceDate);
        CalcPrice(Item, VariantCode, Item."Sales Unit of Measure", Price, ComparePrice);
        exit(ComparePrice);
    end;

    [TryFunction]
    internal procedure CalcPrice(Item: Record Item; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; var Price: Decimal; var ComparePrice: Decimal)
    var
        Currency: Record Currency;
        ItemUnitofMeasure: Record "Item Unit of Measure";
        TempSalesLine: Record "Sales Line" temporary;
        IsHandled: Boolean;
    begin
        TempSalesHeader.FindFirst();
        _SpfyIntegrationEvents.OnBeforeCalculateUnitPrice(Item, VariantCode, UnitOfMeasureCode, _SpfyStoreCode, TempSalesHeader."Currency Code", Price, ComparePrice, IsHandled);
        if not IsHandled then begin
            if TempSalesHeader."Sell-to Customer No." <> '' then begin
                Clear(TempSalesLine);
                TempSalesLine."Document Type" := TempSalesHeader."Document Type";
                TempSalesLine."Document No." := TempSalesHeader."No.";
                TempSalesLine."System-Created Entry" := true;
                TempSalesLine.SetSalesHeader(TempSalesHeader);
                TempSalesLine.Type := TempSalesLine.Type::Item;
                TempSalesLine.Validate("No.", Item."No.");
                if TempSalesLine."Variant Code" <> VariantCode then
                    TempSalesLine.Validate("Variant Code", VariantCode);
                if (TempSalesLine."Unit of Measure Code" <> UnitOfMeasureCode) and (UnitOfMeasureCode <> '') then
                    TempSalesLine.Validate("Unit of Measure Code", UnitOfMeasureCode);
                TempSalesLine.Validate(Quantity, 1);
                GetCurrency(TempSalesLine, Currency);
                ComparePrice := Round(TempSalesLine."Unit Price", Currency."Amount Rounding Precision");
                if TempSalesLine."Line Discount Amount" = 0 then
                    Price := ComparePrice
                else
                    Price := TempSalesLine."Line Amount";
            end else begin
                Price := Item."Unit Price";
                if (UnitOfMeasureCode <> '') and ItemUnitofMeasure.Get(Item."No.", UnitOfMeasureCode) then begin
                    Price := Price * ItemUnitofMeasure."Qty. per Unit of Measure";
                end;
                ComparePrice := Price;
            end;
            if ComparePrice < Price then
                ComparePrice := Price;
        end;
        _SpfyIntegrationEvents.OnAfterCalculateUnitPrice(Item, VariantCode, UnitOfMeasureCode, _SpfyStoreCode, TempSalesHeader."Currency Code", Price, ComparePrice);
    end;

    local procedure GetCurrency(var SalesLine: Record "Sales Line"; var Currency: Record Currency)
    var
        SalesHeader: Record "Sales Header";
    begin
        Clear(Currency);
        SalesLine.GetSalesHeader(SalesHeader, Currency);
    end;

    local procedure CreateTempSalesHeader(ShopifyStore: Record "NPR Spfy Store"; ItemPriceDate: Date)
    var
        Customer: Record Customer;
    begin
        if ShopifyStore."Customer No. (Price)" <> '' then
            Customer.Get(ShopifyStore."Customer No. (Price)");
        Clear(TempSalesHeader);
        TempSalesHeader."Document Type" := TempSalesHeader."Document Type"::Quote;
        TempSalesHeader."No." := ShopifyStore.Code;
        TempSalesHeader."Sell-to Customer No." := Customer."No.";
        TempSalesHeader."Bill-to Customer No." := Customer."No.";
        TempSalesHeader."Customer Price Group" := Customer."Customer Price Group";
        TempSalesHeader."Customer Disc. Group" := Customer."Customer Disc. Group";
        TempSalesHeader."Allow Line Disc." := Customer."Allow Line Disc.";
        TempSalesHeader."Gen. Bus. Posting Group" := Customer."Gen. Bus. Posting Group";
        TempSalesHeader."VAT Bus. Posting Group" := Customer."VAT Bus. Posting Group";

        TempSalesHeader."Tax Area Code" := Customer."Tax Area Code";
        TempSalesHeader."Tax Liable" := Customer."Tax Liable";
        TempSalesHeader."VAT Country/Region Code" := Customer."Country/Region Code";
        TempSalesHeader."Customer Posting Group" := Customer."Customer Posting Group";
        TempSalesHeader."Prices Including VAT" := Customer."Prices Including VAT";
        TempSalesHeader.Validate("Document Date", ItemPriceDate);
        TempSalesHeader."Order Date" := ItemPriceDate;
        TempSalesHeader."Currency Code" := ShopifyStore."Currency Code";
        TempSalesHeader.UpdateCurrencyFactor();
        TempSalesHeader.Insert(false);
    end;

    [TryFunction]
    internal procedure Initialize(ShopifyStore: Record "NPR Spfy Store"; ItemPriceDate: Date)
    begin
        Clear(TempSalesHeader);
        TempSalesHeader.DeleteAll();
        CreateTempSalesHeader(ShopifyStore, ItemPriceDate);
    end;
}
#endif