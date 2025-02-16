#if not BC17
codeunit 6185048 "NPR Spfy Item Price Mgt."
{
    Access = Internal;

    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyProductPriceCalc: Codeunit "NPR Spfy Product Price Calc.";

    local procedure Initialize(): Boolean
    begin
        if not SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Item Prices") then
            exit(false);
        exit(true);
    end;

    procedure CalculateItemPrices(var ShopifyStore: Record "NPR Spfy Store"; var Item: Record Item; Silent: Boolean; ItemPricesCalculationDate: Date)
    var
        ItemPrice: Record "NPR Spfy Item Price";
        TempItemPrice: Record "NPR Spfy Item Price" temporary;
        ItemVariant: Record "Item Variant";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        Window: Dialog;
        CalculatedPrices: Integer;
        RecNo: Integer;
        TotalRecNo: Integer;
        ShopifyStoreCode: Code[20];
        ShopifyStores: List of [Code[20]];
        FullRecalculation: Boolean;
        ItemPriceUpdated: Boolean;
        DialogTextLbl1: Label 'Initializing Item Prices...\\';
        DialogTextLbl2: Label 'Prepare   @1@@@@@@@@@@@@@@@@@@@@\';
        DialogTextLbl3: Label 'Calculate @2@@@@@@@@@@@@@@@@@@@@';
        FinishedItemPriceCalcInfLbl: Label 'Finished item price calculation. %1 Item Price entries were updated/created.';
        SalesHeaderInitializationWrnLbl: Label 'Sales Header initialization error: %1';
        NothingToDoErr: Label 'There is nothing to do. Please make sure you have marked all relevant items as Shopify items.';
        StartingItemPriceCalcInfLbl: Label 'Starting item price calculation... \Filters: \Item Prices Calculation Date: "%1", \Shopify Store filters: "%2", \Item filters: "%3"';
    begin
        if not Initialize() then
            exit;

        if ItemPricesCalculationDate = 0D then
            ItemPricesCalculationDate := Today() + 1;

        FullRecalculation := Item.GetFilters() = '';

        if ShopifyStore.FindSet() then
            repeat
                if ValidateStore(ShopifyStore) then
                    ShopifyStores.Add(ShopifyStore.Code);
            until ShopifyStore.Next() = 0;

        Item.SetRange(Blocked, false);
        if Item.IsEmpty() or (ShopifyStores.Count() = 0) then begin
            if Silent then
                exit;
            Error(NothingToDoErr);
        end;

        LogMessage(StrSubstNo(StartingItemPriceCalcInfLbl, ItemPricesCalculationDate, ShopifyStore.GetFilters(), Item.GetFilters()), Enum::"NPR Spfy Message Type"::Info);

        if not Silent then begin
            Window.Open(
                DialogTextLbl1 +
                DialogTextLbl2 +
                DialogTextLbl3);
            RecNo := 0;
            TotalRecNo := Item.Count() * ShopifyStores.Count();
        end;

        Item.SetAutoCalcFields("NPR Spfy Synced Item", "NPR Spfy Synced Item (Planned)");
        foreach ShopifyStoreCode in ShopifyStores do begin
            Item.SetRange("NPR Spfy Store Filter", ShopifyStoreCode);
            if Item.FindSet() then
                repeat
                    if Item."NPR Spfy Synced Item" or Item."NPR Spfy Synced Item (Planned)" then
                        if SpfyItemMgt.AvailableInShopifyVariantsExist(Item."No.", ShopifyStoreCode) then begin
                            ItemVariant.Reset();
                            ItemVariant.SetRange("Item No.", Item."No.");
#if BC18 or BC19 or BC20 or BC21 or BC22
                            ItemVariant.SetRange("NPR Blocked", false);
#else
                            ItemVariant.SetRange(Blocked, false);
#endif
                            Item.CopyFilter("Variant Filter", ItemVariant.Code);
                            ItemVariant.SetRange("NPR Spfy Store Filter", ShopifyStoreCode);
                            ItemVariant.SetAutoCalcFields("NPR Spfy Not Available");
                            if ItemVariant.FindSet() then
                                repeat
                                    if not ItemVariant."NPR Spfy Not Available" then begin
                                        TempItemPrice."Shopify Store Code" := ShopifyStoreCode;
                                        TempItemPrice."Item No." := ItemVariant."Item No.";
                                        TempItemPrice."Variant Code" := ItemVariant.Code;
                                        if not TempItemPrice.Find() then
                                            TempItemPrice.Insert();
                                    end;
                                until ItemVariant.Next() = 0;
                        end else begin
                            TempItemPrice."Shopify Store Code" := ShopifyStoreCode;
                            TempItemPrice."Item No." := Item."No.";
                            TempItemPrice."Variant Code" := '';
                            if not TempItemPrice.Find() then
                                TempItemPrice.Insert();
                        end;

                    if not Silent then begin
                        RecNo += 1;
                        Window.Update(1, Round(RecNo / TotalRecNo * 10000, 1));
                    end;
                until Item.Next() = 0;
        end;
        if not Silent then begin
            RecNo := 0;
            TotalRecNo := TempItemPrice.Count();
        end;
        CalculatedPrices := 0;
#if not (BC18 or BC19 or BC20 or BC21)
        ItemPrice.ReadIsolation := IsolationLevel::UpdLock;
#else
        ItemPrice.LockTable();
#endif
        TempItemPrice.SetCurrentKey("Shopify Store Code", "Item No.", "Variant Code");
        if TempItemPrice.FindSet() then
            repeat
                ItemPrice.Reset();
                TempItemPrice.SetRange("Shopify Store Code", TempItemPrice."Shopify Store Code");
                if SpfyProductPriceCalc.Initialize(TempItemPrice."Shopify Store Code", ItemPricesCalculationDate) then begin

                    if FullRecalculation then
                        MarkObsoleteItemPrices(TempItemPrice."Shopify Store Code", ItemPrice);
                    repeat
                        TempItemPrice.SetRange("Item No.", TempItemPrice."Item No.");

                        if not FullRecalculation then begin
                            if (Item.GetFilter("Variant Filter") = '') then
                                MarkObsoleteItemPrices(TempItemPrice, true, ItemPrice);

                            if TempItemPrice."Variant Code" <> '' then begin
                                ItemPrice := TempItemPrice;
                                ItemPrice."Variant Code" := '';
                                MarkObsoleteItemPrices(ItemPrice, Item.GetFilter("Variant Filter") = '', ItemPrice);
                            end;
                        end;

                        repeat
                            if not FullRecalculation then
                                MarkObsoleteItemPrices(TempItemPrice, false, ItemPrice);
                            ItemPriceUpdated := false;
                            if RecalcItemPrice(TempItemPrice, ItemPrice, ItemPricesCalculationDate, ItemPriceUpdated) then begin
                                if ItemPriceUpdated then
                                    CalculatedPrices += 1;
                                ItemPrice.Mark(false);
                            end;
                            if not Silent then begin
                                RecNo += 1;
                                Window.Update(2, Round(RecNo / TotalRecNo * 10000, 1));
                            end;
                        until TempItemPrice.Next() = 0; //by Variant
                        TempItemPrice.SetRange("Item No.");
                    until TempItemPrice.Next() = 0;  //by Item

                    ItemPrice.MarkedOnly(true);
                    ItemPrice.DeleteAll();
                    TempItemPrice.SetRange("Shopify Store Code");
                end else
                    LogMessage(StrSubstNo(SalesHeaderInitializationWrnLbl, GetLastErrorText()), Enum::"NPR Spfy Message Type"::Error);
            until TempItemPrice.Next() = 0;  //by Shopify Store

        if not Silent then
            Window.Close();

        LogMessage(StrSubstNo(FinishedItemPriceCalcInfLbl, Format(CalculatedPrices)), Enum::"NPR Spfy Message Type"::Info);
    end;

    internal procedure CreateSpfyItemPriceSyncJob(JobDescription: Text)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NextRunDateFormula: DateFormula;
        NotBeforeDateTime: DateTime;
    begin
        NotBeforeDateTime := CreateDateTime(Today, 200000T);
        Evaluate(NextRunDateFormula, '<1D>');
        JobQueueMgt.SetJobTimeout(4, 0);  // 4 hours
        JobQueueMgt.SetAutoRescheduleAndNotifyOnError(true, 600, '');

        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Report,
            Report::"NPR Spfy Calculate Item Prices",
            '',
            JobDescription,
            NotBeforeDateTime,
            DT2Time(NotBeforeDateTime),
            230000T,
            NextRunDateFormula,
            '',
            JobQueueEntry)
        then
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
    end;

    internal procedure CancelSpfyItemPriceSyncJob()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Report, Report::"NPR Spfy Calculate Item Prices") then
            JobQueueEntry.Cancel();
    end;

    internal procedure EnableShopifyLogRetentionPolicy()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
    begin
        if not RetentionPolicySetup.WritePermission() then
            exit;
        if not RetentionPolicySetup.Get(Database::"NPR Spfy Log") or RetentionPolicySetup.Enabled then
            exit;
        RetentionPolicySetup.Validate(Enabled, true);
        RetentionPolicySetup.Modify(true);
    end;

    local procedure LogMessage(Message: Text; MessageType: Enum "NPR Spfy Message Type")
    var
        SpfyItemPriceLog: Record "NPR Spfy Log";
        OutS: OutStream;
    begin
        SpfyItemPriceLog.Init();
        SpfyItemPriceLog."Entry No." := 0;
        SpfyItemPriceLog."Log Source" := SpfyItemPriceLog."Log Source"::"Item Price";
        SpfyItemPriceLog."Message Type" := MessageType;
        SpfyItemPriceLog."Message Text" := CopyStr(DelChr(Message, '=', '\'), 1, MaxStrLen(SpfyItemPriceLog."Message Text"));
        SpfyItemPriceLog."Message Blob".CreateOutStream(OutS, TextEncoding::UTF8);
        OutS.WriteText(Message);
        SpfyItemPriceLog.Insert();
    end;

    local procedure ValidateStore(SpfyStore: Record "NPR Spfy Store"): Boolean
    begin
        if not SpfyStore.Enabled then
            exit;
        exit(SpfyIntegrationMgt.IsSendSalesPrices(SpfyStore));
    end;

    local procedure MarkObsoleteItemPrices(ShopifyStoreCode: Code[20]; var ItemPrice: Record "NPR Spfy Item Price")
    begin
        ItemPrice.SetRange("Shopify Store Code", ShopifyStoreCode);
        if ItemPrice.FindSet() then
            repeat
                ItemPrice.Mark(true);
            until ItemPrice.Next() = 0;
    end;

    local procedure MarkObsoleteItemPrices(ItemPriceIn: Record "NPR Spfy Item Price"; AllVariants: Boolean; var ItemPrice: Record "NPR Spfy Item Price")
    begin
        ItemPrice.SetCurrentKey("Item No.", "Variant Code");
        ItemPrice.SetRange("Item No.", ItemPriceIn."Item No.");
        if not AllVariants then
            ItemPrice.SetRange("Variant Code", ItemPriceIn."Variant Code");
        MarkObsoleteItemPrices(ItemPriceIn."Shopify Store Code", ItemPrice);

        ItemPrice.SetCurrentKey("Shopify Store Code", "Item No.", "Variant Code");  //PK
        ItemPrice.SetRange("Item No.");
        ItemPrice.SetRange("Variant Code");
    end;

    procedure ClearItemPrices(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    var
        ItemPrice: Record "NPR Spfy Item Price";
    begin
        ItemPrice.SetCurrentKey("Item No.", "Variant Code");
        ItemPrice.SetRange("Item No.", SpfyStoreItemLink."Item No.");
        if SpfyStoreItemLink."Variant Code" <> '' then
            ItemPrice.SetRange("Variant Code", SpfyStoreItemLink."Variant Code");
        ItemPrice.SetRange("Shopify Store Code", SpfyStoreItemLink."Shopify Store Code");
        If not ItemPrice.IsEmpty() then
            ItemPrice.DeleteAll();
    end;

    local procedure RecalcItemPrice(ItemPriceParam: Record "NPR Spfy Item Price"; var ItemPriceOut: Record "NPR Spfy Item Price"; ItemPricesCalculationDate: Date; var ItemPriceUpdated: Boolean): Boolean
    var
        Item: Record Item;
        ItemPrice: Record "NPR Spfy Item Price";
        ItemVariant: Record "Item Variant";
        ShopifyStore: Record "NPR Spfy Store";
        CurrentPrice: Decimal;
        CurrentComparePrice: Decimal;
    begin
        ItemPriceParam."Starting Date" := ItemPricesCalculationDate;

        if not Item.Get(ItemPriceParam."Item No.") then
            exit(false);
        if ItemPriceParam."Variant Code" = '' then begin
            ItemVariant.SetRange("Item No.", ItemPriceParam."Item No.");
            ItemVariant.SetFilter(Code, '<>%1', '');
#if BC18 or BC19 or BC20 or BC21 or BC22
            ItemVariant.SetRange("NPR Blocked", false);
#else
            ItemVariant.SetRange(Blocked, false);
#endif
            if not ItemVariant.IsEmpty() then
                exit(false);
        end;

        Item.SetRange("Variant Filter", ItemPriceParam."Variant Code");

        ShopifyStore.Get(ItemPriceParam."Shopify Store Code");
        ClearLastError();
        if SpfyProductPriceCalc.CalcPrice(Item, ItemPriceParam."Variant Code", Item."Sales Unit of Measure", CurrentPrice, CurrentComparePrice) then begin
            ItemPrice := ItemPriceParam;
            if not ItemPrice.Find() then begin
                ItemPrice."Unit Price" := CurrentPrice;
                ItemPrice."Compare at Price" := CurrentComparePrice;
                ItemPrice."Currency Code" := ShopifyStore."Currency Code";
                ItemPrice."Starting Date" := ItemPriceParam."Starting Date";
                ItemPriceUpdated := ItemPrice.Insert(true);
            end else
                if (ItemPrice."Unit Price" <> CurrentPrice) or (ItemPrice."Compare at Price" <> CurrentComparePrice) or (ItemPrice."Currency Code" <> ShopifyStore."Currency Code") then begin
                    ItemPrice."Unit Price" := CurrentPrice;
                    ItemPrice."Compare at Price" := CurrentComparePrice;
                    ItemPrice."Currency Code" := ShopifyStore."Currency Code";
                    ItemPrice."Starting Date" := ItemPriceParam."Starting Date";
                    ItemPriceUpdated := ItemPrice.Modify(true);
                end;
            ItemPriceOut := ItemPrice;
            exit(true);
        end else
            LogMessage(GetLastErrorText(), Enum::"NPR Spfy Message Type"::Error);
    end;
}
#endif