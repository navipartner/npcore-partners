#if not BC17
codeunit 6184811 "NPR Spfy Inventory Level Mgt."
{
    Access = Internal;
    TableNo = "NPR Data Log Record";

    trigger OnRun()
    var
        TempInventoryLevel: Record "NPR Spfy Inventory Level" temporary;
    begin
        if not Initialize() then
            exit;
        if (Rec."Record ID".TableNo = Database::"Transfer Line") and not IncludeTransferOrdersAnyStore then
            exit;

        FindTouchedSKUs(Rec, TempInventoryLevel);
        if TempInventoryLevel.FindSet() then
            repeat
                RecalcInventoryLevel(TempInventoryLevel);
            until TempInventoryLevel.Next() = 0;
    end;

    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        IncludeTransferOrdersAnyStore: Boolean;

    local procedure Initialize(): Boolean
    begin
        if not SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Inventory Levels") then
            exit(false);
        IncludeTransferOrdersAnyStore := SpfyIntegrationMgt.IncludeTrasferOrdersAnyStore();
        exit(true);
    end;

    local procedure FindTouchedSKUs(DataLogEntry: Record "NPR Data Log Record"; var InventoryLevelTemp: Record "NPR Spfy Inventory Level")
    var
        ItemLedger: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        TransferLine: Record "Transfer Line";
        DataLogSubscriberMgt: Codeunit "NPR Data Log Sub. Mgt.";
        RecRef: RecordRef;
    begin
        if not InventoryLevelTemp.IsTemporary() then
            FunctionCallOnNonTempVarErr('FindTouchedSKUs()');

        Clear(InventoryLevelTemp);
        InventoryLevelTemp.DeleteAll();

        RecRef := DataLogEntry."Record ID".GetRecord();
        case RecRef.Number of
            Database::"Item Ledger Entry":
                begin
                    if not DataLogSubscriberMgt.RestoreRecordToRecRef(DataLogEntry."Entry No.", false, RecRef) then
                        exit;
                    RecRef.SetTable(ItemLedger);
                    TouchInventoryLevel(ItemLedger."Location Code", ItemLedger."Item No.", ItemLedger."Variant Code", InventoryLevelTemp);
                end;

            Database::"Sales Line":
                begin
                    if DataLogSubscriberMgt.RestoreRecordToRecRef(DataLogEntry."Entry No.", false, RecRef) then begin
                        RecRef.SetTable(SalesLine);
                        TouchInventoryLevel(SalesLine, InventoryLevelTemp);
                    end;
                    if DataLogSubscriberMgt.RestoreRecordToRecRef(DataLogEntry."Entry No.", true, RecRef) then begin
                        RecRef.SetTable(SalesLine);
                        TouchInventoryLevel(SalesLine, InventoryLevelTemp);
                    end;
                end;

            Database::"Transfer Line":
                begin
                    if DataLogSubscriberMgt.RestoreRecordToRecRef(DataLogEntry."Entry No.", false, RecRef) then begin
                        RecRef.SetTable(TransferLine);
                        TouchInventoryLevel(TransferLine, InventoryLevelTemp);
                    end;
                    if DataLogSubscriberMgt.RestoreRecordToRecRef(DataLogEntry."Entry No.", true, RecRef) then begin
                        RecRef.SetTable(TransferLine);
                        TouchInventoryLevel(TransferLine, InventoryLevelTemp);
                    end;
                end;
        end;
    end;

    local procedure TouchInventoryLevel(SalesLine: Record "Sales Line"; var InventoryLevelTemp: Record "NPR Spfy Inventory Level")
    begin
        if (SalesLine."Document Type" <> SalesLine."Document Type"::Order) or
           (SalesLine.Type <> SalesLine.Type::Item) or
           (SalesLine."No." = '')
        then
            exit;
        TouchInventoryLevel(SalesLine."Location Code", SalesLine."No.", SalesLine."Variant Code", InventoryLevelTemp);
    end;

    local procedure TouchInventoryLevel(TransferLine: Record "Transfer Line"; var InventoryLevelTemp: Record "NPR Spfy Inventory Level")
    begin
        if (TransferLine."Derived From Line No." <> 0) or
           (TransferLine."Item No." = '') or
           not IncludeTransferOrdersAnyStore
        then
            exit;
        TouchInventoryLevel(TransferLine."Transfer-from Code", TransferLine."Item No.", TransferLine."Variant Code", InventoryLevelTemp);
        TouchInventoryLevel(TransferLine."Transfer-to Code", TransferLine."Item No.", TransferLine."Variant Code", InventoryLevelTemp);
    end;

    local procedure TouchInventoryLevel(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; var InventoryLevelTemp: Record "NPR Spfy Inventory Level")
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreLocationLink: Record "NPR Spfy Store-Location Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        if ItemNo = '' then
            exit;

        SpfyStoreLocationLink.SetRange("Location Code", LocationCode);
        if SpfyStoreLocationLink.FindSet() then
            repeat
                if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Inventory Levels", SpfyStoreLocationLink."Shopify Store Code") then begin
                    InventoryLevelTemp."Shopify Location ID" := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreLocationLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                    if InventoryLevelTemp."Shopify Location ID" <> '' then begin
                        InventoryLevelTemp."Shopify Store Code" := SpfyStoreLocationLink."Shopify Store Code";
                        InventoryLevelTemp."Item No." := ItemNo;
                        InventoryLevelTemp."Variant Code" := VariantCode;
                        if not InventoryLevelTemp.Find() then
                            if SpfyStoreItemLink.Get(SpfyStoreItemLink.Type::Item, ItemNo, '', SpfyStoreLocationLink."Shopify Store Code") and SpfyStoreItemLink."Sync. to this Store" then begin
                                InventoryLevelTemp.Init();
                                InventoryLevelTemp.Insert();
                            end;
                    end;
                end;
            until SpfyStoreLocationLink.Next() = 0;
    end;

    local procedure RecalcInventoryLevel(InventoryLevelParam: Record "NPR Spfy Inventory Level")
    var
        InventoryLevel: Record "NPR Spfy Inventory Level";
    begin
        RecalcInventoryLevel(InventoryLevelParam, InventoryLevel);
    end;

    local procedure RecalcInventoryLevel(InventoryLevelParam: Record "NPR Spfy Inventory Level"; var InventoryLevelOut: Record "NPR Spfy Inventory Level"): Boolean
    var
        InventoryLevel: Record "NPR Spfy Inventory Level";
        Item: Record Item;
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        StockQty: Decimal;
        IncludeTransferOrders: Option No,Outbound,All;
    begin
        if InventoryLevelParam."Variant Code" = '' then begin
            if SpfyItemMgt.AvailableInShopifyVariantsExist(InventoryLevelParam."Item No.", InventoryLevelParam."Shopify Store Code") then
                exit(false);  //Do not calculate inventory level for blank variant if there are synced variants available for the item
        end else
            if SpfyItemMgt.ItemVariantNotAvailableInShopify(InventoryLevelParam."Item No.", InventoryLevelParam."Variant Code", InventoryLevelParam."Shopify Store Code") then
                exit(false);
        if not Item.Get(InventoryLevelParam."Item No.") then
            exit(false);
        IncludeTransferOrders := SpfyIntegrationMgt.IncludeTrasferOrders(InventoryLevelParam."Shopify Store Code");

        Item.SetRange("Variant Filter", InventoryLevelParam."Variant Code");
        Item.SetFilter("Location Filter", GetLocationFilter(InventoryLevelParam."Shopify Store Code", InventoryLevelParam."Shopify Location ID"));
        Item.CalcFields(Inventory, "Qty. on Sales Order");
        StockQty := Item.Inventory - Item."Qty. on Sales Order" - SafetyStockQuantity(Item);
        case IncludeTransferOrders of
            IncludeTransferOrders::Outbound:
                begin
                    Item.CalcFields("Trans. Ord. Shipment (Qty.)");
                    StockQty := StockQty - Item."Trans. Ord. Shipment (Qty.)";
                end;
            IncludeTransferOrders::All:
                begin
                    Item.CalcFields("Trans. Ord. Shipment (Qty.)", "Trans. Ord. Receipt (Qty.)", "Qty. in Transit");
                    StockQty := StockQty - Item."Trans. Ord. Shipment (Qty.)" + Item."Trans. Ord. Receipt (Qty.)" + Item."Qty. in Transit";
                end;
        end;

#if not (BC18 or BC19 or BC20 or BC21)
        InventoryLevel.ReadIsolation := IsolationLevel::UpdLock;
#else
        InventoryLevel.LockTable();
#endif
        InventoryLevel := InventoryLevelParam;
        if not InventoryLevel.Find() then begin
            InventoryLevel.Inventory := StockQty;
            InventoryLevel.Insert(true);
        end else
            if InventoryLevel.Inventory <> StockQty then begin
                InventoryLevel.Inventory := StockQty;
                InventoryLevel.Modify(true);
            end;
        InventoryLevelOut := InventoryLevel;
        exit(true);
    end;

    local procedure GetLocationFilter(ShopifyStoreCode: Code[20]; ShopifyLocationID: Text[30]): Text
    var
        Location: Record Location;
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyStoreLocationLink: Record "NPR Spfy Store-Location Link";
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        RecRef: RecordRef;
    begin
        ShopifyAssignedID.SetCurrentKey("Shopify ID Type", "Shopify ID");
        ShopifyAssignedID.SetRange("Shopify ID Type", "NPR Spfy ID Type"::"Entry ID");
        ShopifyAssignedID.SetRange("Shopify ID", ShopifyLocationID);
        if not ShopifyAssignedID.FindSet() then
            exit(' ');
        repeat
            if RecRef.Get(ShopifyAssignedID."BC Record ID") then
                if RecRef.Number = Database::"NPR Spfy Store-Location Link" then begin
                    RecRef.SetTable(SpfyStoreLocationLink);
                    if SpfyStoreLocationLink."Shopify Store Code" = ShopifyStoreCode then
                        if Location.Get(SpfyStoreLocationLink."Location Code") then
                            Location.Mark(true);
                end;
        until ShopifyAssignedID.Next() = 0;
        Location.MarkedOnly(true);
        if Location.Count() = 0 then
            exit(' ');
        exit(SelectionFilterManagement.GetSelectionFilterForLocation(Location));
    end;

    local procedure SafetyStockQuantity(var Item: Record Item): Decimal
    var
        SKU: Record "Stockkeeping Unit";
    begin
        SKU.SetRange("Item No.", Item."No.");
        Item.CopyFilter("Variant Filter", SKU."Variant Code");
        Item.CopyFilter("Location Filter", SKU."Location Code");
        if SKU.IsEmpty() then
            exit(Item."NPR Spfy Safety Stock Quantity");
        SKU.CalcSums("NPR Spfy Safety Stock Quantity");
        exit(SKU."NPR Spfy Safety Stock Quantity");
    end;

    procedure InitializeInventoryLevels(ShopifyStoreFilter: Text; var Item: Record Item; Silent: Boolean)
    var
        InventoryLevel: Record "NPR Spfy Inventory Level";
        TempInventoryLevel: Record "NPR Spfy Inventory Level" temporary;
        ItemVariant: Record "Item Variant";
        ShopifyStore: Record "NPR Spfy Store";
        SpfyStoreLocationLink: Record "NPR Spfy Store-Location Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        Window: Dialog;
        RecNo: Integer;
        TotalRecNo: Integer;
        ShopifyStoreCode: Code[20];
        ShopifyLocationID: Text[30];
        ShopifyLocations: Dictionary of [Code[20], List of [Text[30]]];
        ShopifyStoreLocations: List of [Text[30]];
        ShopifyStores: List of [Code[20]];
        FullRecalculation: Boolean;
        DialogTextLbl1: Label 'Initializing Inventory Levels...\\';
        DialogTextLbl2: Label 'Prepare   @1@@@@@@@@@@@@@@@@@@@@\';
        DialogTextLbl3: Label 'Calculate @2@@@@@@@@@@@@@@@@@@@@';
        NothingToDoErr: Label 'There is nothing to do. Please make sure you have linked you locations to Shopify locations, and marked all relevant items as Shopify items.';
    begin
        if not Initialize() then
            exit;

        FullRecalculation := Item.GetFilters() = '';

        SpfyStoreLocationLink.SetCurrentKey("Shopify Store Code");
        Item.CopyFilter("Location Filter", SpfyStoreLocationLink."Location Code");
        if ShopifyStoreFilter <> '' then
            ShopifyStore.SetFilter(Code, ShopifyStoreFilter);
        ShopifyStore.SetRange(Enabled, true);
        if ShopifyStore.FindSet() then
            repeat
                SpfyStoreLocationLink.SetRange("Shopify Store Code", ShopifyStore.Code);
                if SpfyStoreLocationLink.FindSet() then
                    repeat
                        ShopifyLocationID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreLocationLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                        if ShopifyLocationID <> '' then
                            if not ShopifyLocations.ContainsKey(SpfyStoreLocationLink."Shopify Store Code") then begin
                                Clear(ShopifyStoreLocations);
                                ShopifyStoreLocations.Add(ShopifyLocationID);
                                ShopifyLocations.Add(SpfyStoreLocationLink."Shopify Store Code", ShopifyStoreLocations);
                            end else
                                if not ShopifyLocations.Get(SpfyStoreLocationLink."Shopify Store Code").Contains(ShopifyLocationID) then
                                    ShopifyLocations.Get(SpfyStoreLocationLink."Shopify Store Code").Add(ShopifyLocationID);
                    until SpfyStoreLocationLink.Next() = 0;
            until ShopifyStore.Next() = 0;

        Item.SetRange(Blocked, false);
        if (ShopifyLocations.Count() = 0) or Item.IsEmpty() then begin
            if Silent then
                exit;
            Error(NothingToDoErr);
        end;

        ShopifyStores := ShopifyLocations."Keys";
        if not Silent then begin
            Window.Open(
                DialogTextLbl1 +
                DialogTextLbl2 +
                DialogTextLbl3);
            RecNo := 0;
            TotalRecNo := 0;
            foreach ShopifyStoreCode in ShopifyStores do
                if ShopifyLocations.Get(ShopifyStoreCode, ShopifyStoreLocations) then
                    TotalRecNo += Item.Count() * ShopifyStoreLocations.Count();
        end;

        Item.SetAutoCalcFields("NPR Spfy Synced Item", "NPR Spfy Synced Item (Planned)");
        foreach ShopifyStoreCode in ShopifyStores do
            if ShopifyLocations.Get(ShopifyStoreCode, ShopifyStoreLocations) then begin
                Item.SetRange("NPR Spfy Store Filter", ShopifyStoreCode);
                foreach ShopifyLocationID in ShopifyStoreLocations do
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
                                                TempInventoryLevel."Shopify Store Code" := ShopifyStoreCode;
                                                TempInventoryLevel."Shopify Location ID" := ShopifyLocationID;
                                                TempInventoryLevel."Item No." := ItemVariant."Item No.";
                                                TempInventoryLevel."Variant Code" := ItemVariant.Code;
                                                if not TempInventoryLevel.Find() then
                                                    TempInventoryLevel.Insert();
                                            end;
                                        until ItemVariant.Next() = 0;
                                end else begin
                                    TempInventoryLevel."Shopify Store Code" := ShopifyStoreCode;
                                    TempInventoryLevel."Shopify Location ID" := ShopifyLocationID;
                                    TempInventoryLevel."Item No." := Item."No.";
                                    TempInventoryLevel."Variant Code" := '';
                                    if not TempInventoryLevel.Find() then
                                        TempInventoryLevel.Insert();
                                end;

                            if not Silent then begin
                                RecNo += 1;
                                Window.Update(1, Round(RecNo / TotalRecNo * 10000, 1));
                            end;
                        until Item.Next() = 0;
            end;

        if not Silent then begin
            RecNo := 0;
            TotalRecNo := TempInventoryLevel.Count();
        end;

#if not (BC18 or BC19 or BC20 or BC21)
        InventoryLevel.ReadIsolation := IsolationLevel::UpdLock;
#else
        InventoryLevel.LockTable();
#endif
        TempInventoryLevel.SetCurrentKey("Shopify Store Code", "Item No.", "Shopify Location ID", "Variant Code");
        if TempInventoryLevel.FindSet() then
            repeat
                InventoryLevel.Reset();
                TempInventoryLevel.SetRange("Shopify Store Code", TempInventoryLevel."Shopify Store Code");
                if FullRecalculation then
                    MarkObsoleteInventoryLevels(TempInventoryLevel."Shopify Store Code", InventoryLevel);
                repeat
                    TempInventoryLevel.SetRange("Item No.", TempInventoryLevel."Item No.");
                    if not FullRecalculation then
                        if (Item.GetFilter("Location Filter") = '') and (Item.GetFilter("Variant Filter") = '') then
                            MarkObsoleteInventoryLevels(TempInventoryLevel, true, true, InventoryLevel);
                    repeat
                        TempInventoryLevel.SetRange("Shopify Location ID", TempInventoryLevel."Shopify Location ID");
                        if not FullRecalculation and (TempInventoryLevel."Variant Code" <> '') then begin
                            InventoryLevel := TempInventoryLevel;
                            InventoryLevel."Variant Code" := '';
                            MarkObsoleteInventoryLevels(InventoryLevel, Item.GetFilter("Variant Filter") = '', false, InventoryLevel);
                        end;
                        repeat
                            if not FullRecalculation then
                                MarkObsoleteInventoryLevels(TempInventoryLevel, false, false, InventoryLevel);
                            if RecalcInventoryLevel(TempInventoryLevel, InventoryLevel) then
                                InventoryLevel.Mark(false);
                            if not Silent then begin
                                RecNo += 1;
                                Window.Update(2, Round(RecNo / TotalRecNo * 10000, 1));
                            end;
                        until TempInventoryLevel.Next() = 0;  //by Item Variant at the Location
                        TempInventoryLevel.SetRange("Shopify Location ID");
                    until TempInventoryLevel.Next() = 0;  //by Shopify location
                    TempInventoryLevel.SetRange("Item No.");
                until TempInventoryLevel.Next() = 0;  //by Item

                InventoryLevel.MarkedOnly(true);
                InventoryLevel.DeleteAll();
                TempInventoryLevel.SetRange("Shopify Store Code");
            until TempInventoryLevel.Next() = 0;  //by Shopify Store
    end;

    local procedure MarkObsoleteInventoryLevels(ShopifyStoreCode: Code[20]; var InventoryLevel: Record "NPR Spfy Inventory Level")
    begin
        InventoryLevel.SetRange("Shopify Store Code", ShopifyStoreCode);
        if InventoryLevel.FindSet() then
            repeat
                InventoryLevel.Mark(true);
            until InventoryLevel.Next() = 0;
    end;

    local procedure MarkObsoleteInventoryLevels(InventoryLevelIn: Record "NPR Spfy Inventory Level"; AllVariants: Boolean; AllLocations: Boolean; var InventoryLevel: Record "NPR Spfy Inventory Level")
    begin
        if AllLocations then
            InventoryLevel.SetCurrentKey("Item No.", "Variant Code")
        else
            InventoryLevel.SetRange("Shopify Location ID", InventoryLevelIn."Shopify Location ID");
        InventoryLevel.SetRange("Item No.", InventoryLevelIn."Item No.");
        if not AllVariants then
            InventoryLevel.SetRange("Variant Code", InventoryLevelIn."Variant Code");
        MarkObsoleteInventoryLevels(InventoryLevelIn."Shopify Store Code", InventoryLevel);

        InventoryLevel.SetCurrentKey("Shopify Store Code", "Shopify Location ID", "Item No.", "Variant Code");  //PK
        InventoryLevel.SetRange("Item No.");
        InventoryLevel.SetRange("Variant Code");
        InventoryLevel.SetRange("Shopify Location ID");
    end;

    procedure ClearInventoryLevels(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    var
        InventoryLevel: Record "NPR Spfy Inventory Level";
    begin
        InventoryLevel.SetCurrentKey("Item No.", "Variant Code");
        InventoryLevel.SetRange("Item No.", SpfyStoreItemLink."Item No.");
        if SpfyStoreItemLink."Variant Code" <> '' then
            InventoryLevel.SetRange("Variant Code", SpfyStoreItemLink."Variant Code");
        InventoryLevel.SetRange("Shopify Store Code", SpfyStoreItemLink."Shopify Store Code");
        If not InventoryLevel.IsEmpty() then
            InventoryLevel.DeleteAll();
    end;

    local procedure FunctionCallOnNonTempVarErr(ProcedureName: Text)
    begin
        SpfyIntegrationMgt.FunctionCallOnNonTempVarErr(StrSubstNo('[Codeunit::NPR Spfy Inventory Level Mgt.(%1)].%2', CurrCodeunitID(), ProcedureName));
    end;

    local procedure CurrCodeunitID(): Integer
    begin
        exit(Codeunit::"NPR Spfy Inventory Level Mgt.");
    end;
}
#endif