codeunit 6151407 "NPR Magento Item Mgt."
{
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoFunctions: Codeunit "NPR Magento Functions";
        Text000: Label 'Replicating Special Prices to Sales Prices:';

    procedure DeleteMagentoData(var Item: Record Item)
    var
        MagentoItemAttribute: Record "NPR Magento Item Attr.";
        MagentoItemAttributeValue: Record "NPR Magento Item Attr. Value";
        MagentoItemGroupLink: Record "NPR Magento Category Link";
        MagentoPictureLink: Record "NPR Magento Picture Link";
        MagentoProductRelation: Record "NPR Magento Product Relation";
        MagentoWebsiteLink: Record "NPR Magento Website Link";
    begin
        MagentoWebsiteLink.SetRange("Item No.", Item."No.");
        MagentoWebsiteLink.DeleteAll();

        MagentoItemGroupLink.SetRange("Item No.", Item."No.");
        MagentoItemGroupLink.DeleteAll();

        MagentoPictureLink.SetRange("Item No.", Item."No.");
        MagentoPictureLink.DeleteAll();

        MagentoItemAttribute.SetRange("Item No.", Item."No.");
        MagentoItemAttribute.DeleteAll();

        MagentoItemAttributeValue.SetRange("Item No.", Item."No.");
        MagentoItemAttributeValue.DeleteAll();

        MagentoProductRelation.Reset();
        MagentoProductRelation.SetRange("From Item No.", Item."No.");
        MagentoProductRelation.DeleteAll();
        MagentoProductRelation.Reset();
        MagentoProductRelation.SetRange("To Item No.", Item."No.");
        MagentoProductRelation.DeleteAll();
    end;

    procedure SetupMagentoData(var Item: Record Item)
    var
        MagentoWebsite: Record "NPR Magento Website";
        MagentoWebsiteLink: Record "NPR Magento Website Link";
    begin
        if Item."NPR Magento Name" = '' then
            Item."NPR Magento Name" := Item.Description;

        if AutoUpdateSeoLink(Item) then
            Item."NPR Seo Link" := CopyStr(MagentoFunctions.SeoFormat(Item."NPR Magento Name"), 1, MaxStrLen(Item."NPR Seo Link"));
        if not Item."NPR Magento Item" then
            exit;

        if not (MagentoSetup.Get() and MagentoSetup."Magento Enabled") then
            exit;

        MagentoWebsite.SetRange("Default Website", true);
        if not MagentoWebsite.FindFirst() then
            exit;

        MagentoWebsiteLink.SetRange("Item No.", Item."No.");
        MagentoWebsiteLink.SetRange("Variant Code", '');
        if not MagentoWebsiteLink.FindFirst() then begin
            MagentoWebsiteLink.Init();
            MagentoWebsiteLink."Website Code" := MagentoWebsite.Code;
            MagentoWebsiteLink."Item No." := Item."No.";
            MagentoWebsiteLink.Insert(true);
        end;
    end;

    local procedure AutoUpdateSeoLink(Item: Record Item): Boolean
    begin
        if Item."NPR Seo Link" <> '' then
            exit(false);
        if not MagentoSetup.Get() then
            exit(false);

        exit(not MagentoSetup."Auto Seo Link Disabled");
    end;

    procedure SetupMultiStoreData(var Item: Record Item)
    var
        MagentoStore: Record "NPR Magento Store";
        MagentoStoreItem: Record "NPR Magento Store Item";
        MagentoWebsite: Record "NPR Magento Website";
    begin
        if not Item."NPR Magento Item" then
            exit;
        if not (MagentoSetup.Get() and MagentoSetup."Magento Enabled") then
            exit;
        if not MagentoSetup."Multistore Enabled" then
            exit;

        if MagentoStore.FindSet() then
            repeat
                MagentoWebsite.Get(MagentoStore."Website Code");
                if not MagentoStoreItem.Get(Item."No.", MagentoStore.Code) then begin
                    MagentoStoreItem.Init();
                    MagentoStoreItem."Item No." := Item."No.";
                    MagentoStoreItem."Store Code" := MagentoStore.Code;
                    MagentoStoreItem."Website Code" := MagentoStore."Website Code";
                    MagentoStoreItem.Enabled := MagentoWebsite."Default Website";
                    MagentoStoreItem."Root Item Group No." := MagentoStore."Root Item Group No.";
                    MagentoStoreItem.Insert(true);
                end;
            until MagentoStore.Next() = 0;
    end;

    procedure InitReplicateSpecialPrice2SalesPrices()
    var
        Item: Record Item;
        Window: Dialog;
        UseDialog: Boolean;
        Counter: Integer;
        Total: Integer;
    begin
        if not (MagentoSetup.Get() and MagentoSetup."Special Prices Enabled" and MagentoSetup."Replicate to Sales Prices") then
            exit;

        Item.SetFilter("NPR Special Price", '>%1', 0);
        if Item.IsEmpty then
            exit;

        UseDialog := GuiAllowed;
        if UseDialog then begin
            Total := Item.Count();
            Window.Open(Text000 + ' @1@@@@@@@@@@@@@@');
        end;
        Item.FindSet();
        repeat
            if UseDialog then begin
                Counter += 1;
                Window.Update(1, Round((Counter / Total) * 10000, 1));
            end;
            ReplicateSpecialPrice2SalesPrice(Item, false);
        until Item.Next() = 0;
        if UseDialog then
            Window.Close();
    end;

    local procedure ReplicateSpecialPrice2SalesPrice(Item: Record Item; DeleteTrigger: Boolean)
    var
        PriceListLine: Record "Price List Line";
        PriceListHeader: Record "Price List Header";
    begin
        if not (MagentoSetup.Get() and MagentoSetup."Special Prices Enabled" and MagentoSetup."Replicate to Sales Prices") then
            exit;

        if Item."NPR Special Price" <= 0 then
            DeleteTrigger := true;

        if FindSalesPrices(Item, PriceListLine) then begin
            if not DeleteTrigger then begin
                PriceListLine.SetRange("Starting Date", Item."NPR Special Price From");
                PriceListLine.SetRange("Ending Date", Item."NPR Special Price To");
                if not PriceListLine.IsEmpty then
                    exit;

                PriceListLine.SetRange("Starting Date");
                PriceListLine.SetRange("Ending Date");
            end;

            PriceListLine.DeleteAll();
        end;

        if DeleteTrigger then
            exit;
        if (MagentoSetup."Replicate to Price Source Type" <> MagentoSetup."Replicate to Price Source Type"::"All Customers") and (MagentoSetup."Replicate to Sales Code" = '') then
            PriceListLine.Init();
        if not PriceListHeader.Get(MagentoSetup."Replicate to Sales Code") then
            CreatePriceListHeader(MagentoSetup."Replicate to Sales Code", Item."NPR Special Price From", Item."NPR Special Price To");
        PriceListLine.Validate("Price List Code", MagentoSetup."Replicate to Sales Code");
        PriceListLine.Validate("Asset Type", PriceListLine."Asset Type"::Item);
        PriceListLine.Validate("Asset No.", Item."No.");
        PriceListLine."Source Type" := MagentoSetup."Replicate to Price Source Type";
        if MagentoSetup."Replicate to Price Source Type" <> MagentoSetup."Replicate to Price Source Type"::"All Customers" then
            PriceListLine.Validate("Source No.", MagentoSetup."Replicate to Sales Code");
        PriceListLine."Starting Date" := Item."NPR Special Price From";
        PriceListLine."Minimum Quantity" := 0;
        PriceListLine."Unit Price" := Item."NPR Special Price";
        PriceListLine."Ending Date" := Item."NPR Special Price To";
        PriceListLine."VAT Bus. Posting Gr. (Price)" := Item."VAT Bus. Posting Gr. (Price)";
        PriceListLine."Price Includes VAT" := Item."Price Includes VAT";
        PriceListLine.Status := PriceListLine.Status::Active;
        PriceListLine.Insert(true);
    end;

    local procedure FindSalesPrices(Item: Record Item; var PriceListLine: Record "Price List Line"): Boolean
    begin
        if not (MagentoSetup.Get() and MagentoSetup."Special Prices Enabled" and MagentoSetup."Replicate to Sales Prices") then
            exit(false);

        Clear(PriceListLine);
        PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
        PriceListLine.SetRange("Asset No.", Item."No.");
        PriceListLine.SetRange("Source Type", MagentoSetup."Replicate to Price Source Type");
        if MagentoSetup."Replicate to Price Source Type" <> MagentoSetup."Replicate to Price Source Type"::"All Customers" then
            PriceListLine.SetRange("Source No.", MagentoSetup."Replicate to Sales Code");
        PriceListLine.SetRange("Variant Code", '');
        exit(not PriceListLine.IsEmpty());
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateEvent', 'NPR Seo Link', true, true)]
    local procedure ItemOnAfterValidateSeoLink(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary then
            exit;

        Rec."NPR Seo Link" := CopyStr(MagentoFunctions.SeoFormat(Rec."NPR Seo Link"), 1, MaxStrLen(Rec."NPR Seo Link"));
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterInsertEvent', '', true, true)]
    local procedure ItemOnInsert(var Rec: Record Item; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if Rec.IsTemporary then
            exit;
        SetupMagentoData(Rec);
        ReplicateSpecialPrice2SalesPrice(Rec, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeModifyEvent', '', true, true)]
    local procedure ItemOnModify(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if Rec.IsTemporary then
            exit;

        SetupMagentoData(Rec);
        ReplicateSpecialPrice2SalesPrice(Rec, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterDeleteEvent', '', true, true)]
    local procedure ItemOnDelete(var Rec: Record Item; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if Rec.IsTemporary then
            exit;

        DeleteMagentoData(Rec);
        ReplicateSpecialPrice2SalesPrice(Rec, true);
    end;

    procedure GetStockQty(ItemNo: Code[20]; VariantFilter: Text) StockQty: Decimal
    begin
        if MagentoSetup.Get() then;
        StockQty := CalcStockQty(ItemNo, VariantFilter, MagentoSetup."Inventory Location Filter");
        exit(StockQty);
    end;

    procedure GetStockQty2(var RecRef: RecordRef) StockQty: Decimal
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        StockQty := 0;
        case RecRef.Number of
            DATABASE::Item:
                begin
                    RecRef.SetTable(Item);
                    StockQty := GetStockQty(Item."No.", '');
                    exit(StockQty);
                end;
            DATABASE::"Item Variant":
                begin
                    RecRef.SetTable(ItemVariant);
                    StockQty := GetStockQty(ItemVariant."Item No.", ItemVariant.Code);
                    exit(StockQty);
                end;
        end;

        exit(StockQty);
    end;

    procedure GetStockQty3(ItemNo: Code[20]; VariantFilter: Text; MagentoInventoryCompany: Record "NPR Magento Inv. Company") StockQty: Decimal
    begin
        StockQty := CalcStockQty(ItemNo, VariantFilter, MagentoInventoryCompany."Location Filter");
        exit(StockQty);
    end;

    procedure CalcStockQty(ItemNo: Code[20]; VariantFilter: Text; LocationFilter: Text) StockQty: Decimal
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        VariantStockQty: Decimal;
        Handled: Boolean;
    begin
        VariantFilter := UpperCase(VariantFilter);
        LocationFilter := UpperCase(LocationFilter);

        if MagentoSetup.Get() then;
        case MagentoSetup."Stock Calculation Method" of
            MagentoSetup."Stock Calculation Method"::"Function":
                begin
                    OnCalcStockQty(MagentoSetup, ItemNo, VariantFilter, LocationFilter, StockQty, Handled);
                end;
        end;

        if Handled then
            exit(StockQty);

        StockQty := 0;
        if not Item.Get(ItemNo) then
            exit(0);

        if VariantFilter <> '' then begin
            Item.SetFilter("Variant Filter", VariantFilter);
            Item.SetFilter("Location Filter", LocationFilter);
            Item.CalcFields(Inventory, "Qty. on Sales Order");
            StockQty := Item.Inventory - Item."Qty. on Sales Order";
            if StockQty < 0 then
                StockQty := 0;

            exit(StockQty);
        end;

        ItemVariant.SetRange("Item No.", Item."No.");
        if ItemVariant.FindSet() then begin
            StockQty := 0;
            VariantStockQty := 0;
            repeat
                Item.SetFilter("Variant Filter", ItemVariant.Code);
                Item.SetFilter("Location Filter", LocationFilter);
                Item.CalcFields(Inventory, "Qty. on Sales Order");
                VariantStockQty := Item.Inventory - Item."Qty. on Sales Order";
                if VariantStockQty < 0 then
                    VariantStockQty := 0;

                StockQty += VariantStockQty;
            until ItemVariant.Next() = 0;

            exit(StockQty);
        end;

        Item.SetFilter("Location Filter", LocationFilter);
        Item.CalcFields(Inventory, "Qty. on Sales Order");
        StockQty := Item.Inventory - Item."Qty. on Sales Order";

        exit(StockQty);
    end;

    procedure CalcQtyOnSalesOrder(ItemNo: Code[20]; VariantFilter: Text; LocationFilter: Text) Qty: Decimal
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        VariantStockQty: Decimal;
    begin
        VariantFilter := UpperCase(VariantFilter);
        LocationFilter := UpperCase(LocationFilter);

        Qty := 0;
        if not Item.Get(ItemNo) then
            exit(0);

        if VariantFilter <> '' then begin
            Item.SetFilter("Variant Filter", VariantFilter);
            Item.SetFilter("Location Filter", LocationFilter);
            Item.CalcFields("Qty. on Sales Order");
            Qty := Item."Qty. on Sales Order";
            if Qty < 0 then
                Qty := 0;

            exit(Qty);
        end;

        ItemVariant.SetRange("Item No.", Item."No.");
        if ItemVariant.FindSet() then begin
            Qty := 0;
            VariantStockQty := 0;
            repeat
                Item.SetFilter("Variant Filter", ItemVariant.Code);
                Item.SetFilter("Location Filter", LocationFilter);
                Item.CalcFields("Qty. on Sales Order");
                VariantStockQty := Item."Qty. on Sales Order";
                if VariantStockQty < 0 then
                    VariantStockQty := 0;

                Qty += VariantStockQty;
            until ItemVariant.Next() = 0;

            exit(Qty);
        end;

        Item.SetFilter("Location Filter", LocationFilter);
        Item.CalcFields(Inventory, "Qty. on Sales Order");
        Qty := Item."Qty. on Sales Order";

        exit(Qty);
    end;

    procedure CalcQtyOnSalesReturn(ItemNo: Code[20]; VariantFilter: Text; LocationFilter: Text) Qty: Decimal
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        VariantStockQty: Decimal;
    begin
        VariantFilter := UpperCase(VariantFilter);
        LocationFilter := UpperCase(LocationFilter);

        Qty := 0;
        if not Item.Get(ItemNo) then
            exit(0);

        if VariantFilter <> '' then begin
            Item.SetFilter("Variant Filter", VariantFilter);
            Item.SetFilter("Location Filter", LocationFilter);
            Item.CalcFields("Qty. on Sales Return");
            Qty := Item."Qty. on Sales Return";
            if Qty < 0 then
                Qty := 0;

            exit(Qty);
        end;

        ItemVariant.SetRange("Item No.", Item."No.");
        if ItemVariant.FindSet() then begin
            Qty := 0;
            VariantStockQty := 0;
            repeat
                Item.SetFilter("Variant Filter", ItemVariant.Code);
                Item.SetFilter("Location Filter", LocationFilter);
                Item.CalcFields("Qty. on Sales Return");
                VariantStockQty := Item."Qty. on Sales Return";
                if VariantStockQty < 0 then
                    VariantStockQty := 0;

                Qty += VariantStockQty;
            until ItemVariant.Next() = 0;

            exit(Qty);
        end;

        Item.SetFilter("Location Filter", LocationFilter);
        Item.CalcFields(Inventory, "Qty. on Sales Return");
        Qty := Item."Qty. on Sales Return";

        exit(Qty);
    end;

    procedure CalcQtyOnPurchOrder(ItemNo: Code[20]; VariantFilter: Text; LocationFilter: Text) Qty: Decimal
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        VariantStockQty: Decimal;
    begin
        VariantFilter := UpperCase(VariantFilter);
        LocationFilter := UpperCase(LocationFilter);

        Qty := 0;
        if not Item.Get(ItemNo) then
            exit(0);

        if VariantFilter <> '' then begin
            Item.SetFilter("Variant Filter", VariantFilter);
            Item.SetFilter("Location Filter", LocationFilter);
            Item.CalcFields("Qty. on Purch. Order");
            Qty := Item."Qty. on Purch. Order";
            if Qty < 0 then
                Qty := 0;

            exit(Qty);
        end;

        ItemVariant.SetRange("Item No.", Item."No.");
        if ItemVariant.FindSet() then begin
            Qty := 0;
            VariantStockQty := 0;
            repeat
                Item.SetFilter("Variant Filter", ItemVariant.Code);
                Item.SetFilter("Location Filter", LocationFilter);
                Item.CalcFields("Qty. on Purch. Order");
                VariantStockQty := Item."Qty. on Purch. Order";
                if VariantStockQty < 0 then
                    VariantStockQty := 0;

                Qty += VariantStockQty;
            until ItemVariant.Next() = 0;

            exit(Qty);
        end;

        Item.SetFilter("Location Filter", LocationFilter);
        Item.CalcFields(Inventory, "Qty. on Purch. Order");
        Qty := Item."Qty. on Purch. Order";

        exit(Qty);
    end;

    procedure CalcQtyOnPurchReturn(ItemNo: Code[20]; VariantFilter: Text; LocationFilter: Text) Qty: Decimal
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        VariantStockQty: Decimal;
    begin
        VariantFilter := UpperCase(VariantFilter);
        LocationFilter := UpperCase(LocationFilter);

        Qty := 0;
        if not Item.Get(ItemNo) then
            exit(0);

        if VariantFilter <> '' then begin
            Item.SetFilter("Variant Filter", VariantFilter);
            Item.SetFilter("Location Filter", LocationFilter);
            Item.CalcFields("Qty. on Purch. Return");
            Qty := Item."Qty. on Purch. Return";
            if Qty < 0 then
                Qty := 0;

            exit(Qty);
        end;

        ItemVariant.SetRange("Item No.", Item."No.");
        if ItemVariant.FindSet() then begin
            Qty := 0;
            VariantStockQty := 0;
            repeat
                Item.SetFilter("Variant Filter", ItemVariant.Code);
                Item.SetFilter("Location Filter", LocationFilter);
                Item.CalcFields("Qty. on Purch. Return");
                VariantStockQty := Item."Qty. on Purch. Return";
                if VariantStockQty < 0 then
                    VariantStockQty := 0;

                Qty += VariantStockQty;
            until ItemVariant.Next() = 0;

            exit(Qty);
        end;

        Item.SetFilter("Location Filter", LocationFilter);
        Item.CalcFields(Inventory, "Qty. on Purch. Return");
        Qty := Item."Qty. on Purch. Return";

        exit(Qty);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Setup", 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModifyMagentoSetup(var Rec: Record "NPR Magento Setup"; var xRec: Record "NPR Magento Setup"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;
        if not RunTrigger then
            exit;

        if (xRec."Stock Calculation Method" <> Rec."Stock Calculation Method") or
          (xRec."Stock NpXml Template" <> Rec."Stock NpXml Template") or
          (xRec."Stock Codeunit Id" <> Rec."Stock Codeunit Id") or
          (xRec."Stock Function Name" <> Rec."Stock Function Name")
        then
            UpsertStockTriggers();
    end;

    procedure UpsertStockTriggers()
    var
        NpXmlTemplate: Record "NPR NpXml Template";
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger";
        Handled: Boolean;
    begin
        if not MagentoSetup.Get() then
            exit;

        if MagentoSetup."Stock NpXml Template" = '' then
            exit;
        if not NpXmlTemplate.Get(MagentoSetup."Stock NpXml Template") then
            exit;
        if NpXmlTemplate."Table No." <> DATABASE::Item then
            exit;

        NpXmlTemplateTrigger.SetRange("Xml Template Code", NpXmlTemplate.Code);
        if NpXmlTemplateTrigger.FindFirst() then
            NpXmlTemplateTrigger.DeleteAll(true);

        case MagentoSetup."Stock Calculation Method" of
            MagentoSetup."Stock Calculation Method"::"Function":
                begin
                    OnUpsertStockTriggers(MagentoSetup, NpXmlTemplate, Handled);
                end;
        end;

        if Handled then
            exit;

        UpsertStockTrigger(NpXmlTemplate, Item.FieldNo("No."), DATABASE::"Item Ledger Entry", ItemLedgerEntry.FieldNo("Item No."), true, false, false);
        UpsertStockTrigger(NpXmlTemplate, Item.FieldNo("No."), DATABASE::"Sales Line", SalesLine.FieldNo("No."), true, true, true);
    end;

    procedure UpsertStockTrigger(NpXmlTemplate: Record "NPR NpXml Template"; LinkFieldNoParent: Integer; TableNo: Integer; LinkFieldNoChild: Integer; TriggerOnInsert: Boolean; TriggerOnModify: Boolean; TriggerOnDelete: Boolean)
    var
        NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger";
        NpXmlTemplateTriggerLink: Record "NPR NpXml Templ.Trigger Link";
        LineNo: Integer;
    begin
        NpXmlTemplateTrigger.SetRange("Xml Template Code", NpXmlTemplate.Code);
        NpXmlTemplateTrigger.SetRange("Table No.", TableNo);
        if not NpXmlTemplateTrigger.FindFirst() then begin
            Clear(NpXmlTemplateTrigger);
            NpXmlTemplateTrigger.SetRange("Xml Template Code", NpXmlTemplate.Code);
            if NpXmlTemplateTrigger.FindLast() then;
            LineNo := NpXmlTemplateTrigger."Line No." + 10000;

            NpXmlTemplateTrigger.Init();
            NpXmlTemplateTrigger."Xml Template Code" := NpXmlTemplate.Code;
            NpXmlTemplateTrigger."Line No." := LineNo;
            NpXmlTemplateTrigger."Table No." := TableNo;
            NpXmlTemplateTrigger."Parent Table No." := NpXmlTemplate."Table No.";
            NpXmlTemplateTrigger."Parent Line No." := 0;
            NpXmlTemplateTrigger."Insert Trigger" := TriggerOnInsert;
            NpXmlTemplateTrigger."Modify Trigger" := TriggerOnModify;
            NpXmlTemplateTrigger."Delete Trigger" := TriggerOnDelete;
            NpXmlTemplateTrigger."Generic Parent Codeunit ID" := CurrCodeunitId();
            NpXmlTemplateTrigger."Generic Parent Function" := CopyStr(GetTriggerStockFunctionName(), 1, MaxStrLen(NpXmlTemplateTrigger."Generic Parent Function"));
            NpXmlTemplateTrigger.Insert();
        end else begin
            NpXmlTemplateTrigger."Parent Table No." := NpXmlTemplate."Table No.";
            NpXmlTemplateTrigger."Parent Line No." := 0;
            NpXmlTemplateTrigger."Insert Trigger" := TriggerOnInsert;
            NpXmlTemplateTrigger."Modify Trigger" := TriggerOnModify;
            NpXmlTemplateTrigger."Delete Trigger" := TriggerOnDelete;
            NpXmlTemplateTrigger."Generic Parent Codeunit ID" := CurrCodeunitId();
            NpXmlTemplateTrigger."Generic Parent Function" := CopyStr(GetTriggerStockFunctionName(), 1, MaxStrLen(NpXmlTemplateTrigger."Generic Parent Function"));
            NpXmlTemplateTrigger.Modify();
        end;

        NpXmlTemplateTriggerLink.SetRange("Xml Template Code", NpXmlTemplateTrigger."Xml Template Code");
        NpXmlTemplateTriggerLink.SetRange("Xml Template Trigger Line No.", NpXmlTemplateTrigger."Line No.");
        NpXmlTemplateTriggerLink.SetRange("Parent Table No.", NpXmlTemplateTrigger."Parent Table No.");
        NpXmlTemplateTriggerLink.SetRange("Parent Field No.", LinkFieldNoParent);
        NpXmlTemplateTriggerLink.SetRange("Link Type", NpXmlTemplateTriggerLink."Link Type"::TableLink);
        NpXmlTemplateTriggerLink.SetRange("Table No.", NpXmlTemplateTrigger."Table No.");
        NpXmlTemplateTriggerLink.SetRange("Field No.", LinkFieldNoChild);
        if not NpXmlTemplateTriggerLink.FindFirst() then begin
            Clear(NpXmlTemplateTriggerLink);
            NpXmlTemplateTriggerLink.SetRange("Xml Template Code", NpXmlTemplateTrigger."Xml Template Code");
            NpXmlTemplateTriggerLink.SetRange("Xml Template Trigger Line No.", NpXmlTemplateTrigger."Line No.");
            if NpXmlTemplateTriggerLink.FindLast() then;
            LineNo := NpXmlTemplateTriggerLink."Line No." + 10000;

            NpXmlTemplateTriggerLink.Init();
            NpXmlTemplateTriggerLink."Xml Template Code" := NpXmlTemplateTrigger."Xml Template Code";
            NpXmlTemplateTriggerLink."Xml Template Trigger Line No." := NpXmlTemplateTrigger."Line No.";
            NpXmlTemplateTriggerLink."Line No." := LineNo;
            NpXmlTemplateTriggerLink."Parent Table No." := NpXmlTemplateTrigger."Parent Table No.";
            NpXmlTemplateTriggerLink."Parent Field No." := LinkFieldNoParent;
            NpXmlTemplateTriggerLink."Link Type" := NpXmlTemplateTriggerLink."Link Type"::TableLink;
            NpXmlTemplateTriggerLink."Table No." := NpXmlTemplateTrigger."Table No.";
            NpXmlTemplateTriggerLink."Field No." := LinkFieldNoChild;
            NpXmlTemplateTriggerLink.Insert(true);
        end;

        NpXmlTemplateTrigger.UpdateNaviConnectSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpXml Trigger Mgt.", 'OnSetupGenericParentTable', '', true, true)]
    local procedure TriggerStockUpdate(NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger"; ChildLinkRecRef: RecordRef; var ParentRecRef: RecordRef; var Handled: Boolean)
    var
        TempItem: Record Item temporary;
    begin
        if Handled then
            exit;
        if NpXmlTemplateTrigger."Generic Parent Codeunit ID" <> CurrCodeunitId() then
            exit;
        if NpXmlTemplateTrigger."Generic Parent Function" <> GetTriggerStockFunctionName() then
            exit;
        if NpXmlTemplateTrigger."Parent Table No." <> DATABASE::Item then
            exit;

        Handled := true;

        if MagentoSetup.Get() then;
        Trigger2Item(MagentoSetup, ChildLinkRecRef, TempItem);

        ParentRecRef.GetTable(TempItem);
    end;

    local procedure Trigger2Item(MagentoSetup: Record "NPR Magento Setup"; RecRef: RecordRef; var TempItem: Record Item temporary)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        Item: Record Item;
        TempSalesLine: Record "Sales Line" temporary;
        ItemNo: Code[20];
        Handled: Boolean;
    begin
        if not TempItem.IsTemporary then
            exit;

        Clear(TempItem);
        TempItem.DeleteAll();

        case MagentoSetup."Stock Calculation Method" of
            MagentoSetup."Stock Calculation Method"::"Function":
                begin
                    OnTrigger2Item(MagentoSetup, RecRef, TempItem, Handled);
                end;
        end;

        if Handled then
            exit;

        case RecRef.Number of
            DATABASE::"Item Ledger Entry":
                begin
                    RecRef.SetTable(ItemLedgerEntry);
                    ItemLedgerEntry.SetFilter("Location Code", MagentoSetup."Inventory Location Filter");
                    if not ItemLedgerEntry.Find() then
                        exit;

                    ItemNo := ItemLedgerEntry."Item No.";
                end;
            DATABASE::"Sales Line":
                begin
                    if not RecRef2TempSalesLine(RecRef, TempSalesLine) then
                        exit;

                    TempSalesLine.SetRecFilter();
                    TempSalesLine.FilterGroup(40);
                    TempSalesLine.SetFilter("Location Code", MagentoSetup."Inventory Location Filter");
                    TempSalesLine.SetRange("Document Type", TempSalesLine."Document Type"::Order);
                    TempSalesLine.SetFilter("Location Code", MagentoSetup."Inventory Location Filter");
                    TempSalesLine.SetRange(Type, TempSalesLine.Type::Item);
                    TempSalesLine.SetFilter("No.", '<>%1', '');
                    if not TempSalesLine.FindFirst() then
                        exit;

                    ItemNo := TempSalesLine."No.";
                end;
            else
                exit;
        end;

        if not Item.Get(ItemNo) then
            exit;

        if not Item."NPR Magento Item" then
            exit;

        TempItem.Init();
        TempItem := Item;
        TempItem.Insert();
    end;

    local procedure RecRef2TempSalesLine(RecRef: RecordRef; var TempSalesLine: Record "Sales Line" temporary): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        if RecRef.IsTemporary then begin
            RecRef.SetTable(TempSalesLine);
            TempSalesLine.Insert();
            exit(true);
        end;

        RecRef.SetTable(SalesLine);
        if not SalesLine.Find() then
            exit(false);

        TempSalesLine.Init();
        TempSalesLine := SalesLine;
        TempSalesLine.Insert();
        exit(true)
    end;

    local procedure CreatePriceListHeader(WorksheetTemplateName: Code[20]; SalesPriceStartDate: Date; SalesPriceEndDate: Date)
    var
        PriceListHeader: Record "Price List Header";
    begin
        PriceListHeader.Init();
        PriceListHeader.Code := WorksheetTemplateName;
        PriceListHeader.Insert(true);
        PriceListHeader.Validate("Starting Date", SalesPriceStartDate);
        PriceListHeader.Validate("Ending Date", SalesPriceEndDate);
        PriceListHeader.Validate("Source Group", PriceListHeader."Source Group"::All);
        PriceListHeader.Validate(Status, PriceListHeader.Status::Active);
        PriceListHeader.Modify(true);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Magento Item Mgt.");
    end;

    local procedure GetTriggerStockFunctionName(): Text
    begin
        exit('TriggerStockUpdate');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcStockQty(MagentoSetup: Record "NPR Magento Setup"; ItemNo: Code[20]; VariantFilter: Text; LocationFilter: Text; var StockQty: Decimal; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpsertStockTriggers(MagentoSetup: Record "NPR Magento Setup"; NpXmlTemplate: Record "NPR NpXml Template"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTrigger2Item(MagentoSetup: Record "NPR Magento Setup"; RecRef: RecordRef; var TempItem: Record Item temporary; var Handled: Boolean)
    begin
    end;
}