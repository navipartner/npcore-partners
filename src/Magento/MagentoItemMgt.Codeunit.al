codeunit 6151407 "NPR Magento Item Mgt."
{
    // MAG1.01/MHA /20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.02/MHA /20150202  CASE 199932 Added Function DeleteMagentoData()
    // MAG1.04/MHA /20150213  CASE 199932 Added WebVariant Functionality
    // MAG1.12/MHA /20150407  CASE 210741 Added Test on From- and To Dates
    // MAG1.14/MHA /20150415  CASE 211360 Added Test on Item Webshop Descriptions
    // MAG1.18/MHA /20150716  CASE 218309 Removed TESTFIELD on Short Description
    // MAG1.22/MHA /20160405  CASE 238100 Disabled TestItem()MAG1.21/MHA /20151026  CASE 225825 Removed Attributes Setup in SetupMagentoData() due to performance
    // MAG1.21/MHA /20151105  CASE 226578 Removed Testfield on Webshop Description
    // MAG1.21/MHA /20151118  CASE 223835 Type deleted from Picture Link
    // MAG1.21/MHA /20151118  CASE 227354 Added function SetupStoreData()
    // MAG1.21/MHA /20151520  CASE 227734 Functions DeleteWebVariants() deleted and Item."Meta Keywords" field deleted
    // MAG1.22/TS  /20150212  CASE 234349 Deleted deprecated function TestItem()
    // MAG1.22/MHA /20160421  CASE 236917 Added function GetAvailableInventory()
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.03/MHA /20170316  CASE 267449 Added functions for replicating Special Price
    // MAG2.03/MHA /20170425  CASE 267094 Added "Auto Seo Link Disabled"
    // MAG2.04/MHA /20170518  CASE 267449 "Price Includes VAT" is set based on Item in ReplicateSpecialPrice2SalesPrice()
    // MAG2.07/TS  /20170904  CASE 288850 Added VAT Bus Posting Group
    // MAG2.08/TS  /20171003  CASE 292154 Website link should be created even if Multistore is not setup
    // MAG2.12/RA  /20180419  CASE 311123 Changed EventFunction from OnBeforeInsertEvent to OnAfterInsertEvent on Function ItemOnInsert
    // MAG2.17/TS  /20181019  CASE 333049 Seo Link should not be updated if Confirm is NO
    // MAG2.19/MHA /20190319  CASE 345884 Added function AutoUpdateSeoLink()
    // MAG2.20/MHA /20190430  CASE 353499 Removed function ItemOnAfterValidateAttributeSetId() and check on "Magento Item" when "Attribute Set ID" in ItemOnModify()
    // MAG2.23/BHR /20190822  CASE 363897 Skip creation of websites when entries already exists
    // MAG2.26/MHA /20200430  CASE 402486 Reworked Inventory Mgt. functions
    // MAG2.26/MHA /20200505  CASE 402488 Added Stock Calculation publisher functions


    trigger OnRun()
    begin
    end;

    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoAttributeSetMgt: Codeunit "NPR Magento Attr. Set Mgt.";
        MagentoFunctions: Codeunit "NPR Magento Functions";
        Error001: Label '%1 should be less than or equal to %2';
        Text000: Label 'Replicating Special Prices to Sales Prices:';

    procedure "--- Data Mgt."()
    begin
    end;

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
        MagentoWebsiteLink.DeleteAll;

        MagentoItemGroupLink.SetRange("Item No.", Item."No.");
        MagentoItemGroupLink.DeleteAll;

        MagentoPictureLink.SetRange("Item No.", Item."No.");
        MagentoPictureLink.DeleteAll;

        MagentoItemAttribute.SetRange("Item No.", Item."No.");
        MagentoItemAttribute.DeleteAll;

        MagentoItemAttributeValue.SetRange("Item No.", Item."No.");
        MagentoItemAttributeValue.DeleteAll;

        MagentoProductRelation.Reset;
        MagentoProductRelation.SetRange("From Item No.", Item."No.");
        MagentoProductRelation.DeleteAll;
        MagentoProductRelation.Reset;
        MagentoProductRelation.SetRange("To Item No.", Item."No.");
        MagentoProductRelation.DeleteAll;
    end;

    procedure SetupMagentoData(var Item: Record Item)
    var
        MagentoWebsite: Record "NPR Magento Website";
        MagentoWebsiteLink: Record "NPR Magento Website Link";
    begin
        if Item."NPR Magento Name" = '' then
            Item."NPR Magento Name" := Item.Description;

        //-MAG2.19 [345884]
        // IF (Item."Seo Link" = '') AND (NOT MagentoSetup.GET) OR (NOT MagentoSetup."Auto Seo Link Disabled") THEN
        //  //-MAG2.17 [333049]
        //  Item."Seo Link" := MagentoFunctions.SeoFormat(Item."Seo Link");
        //  //+MAG2.17 [333049]
        if AutoUpdateSeoLink(Item) then
            Item."NPR Seo Link" := MagentoFunctions.SeoFormat(Item."NPR Magento Name");
        //+MAG2.19 [345884]
        if not Item."NPR Magento Item" then
            exit;

        if not (MagentoSetup.Get and MagentoSetup."Magento Enabled") then
            exit;

        MagentoWebsite.SetRange("Default Website", true);
        if not MagentoWebsite.FindFirst then
            exit;

        //-MAG2.23 [363897]
        //IF NOT MagentoWebsiteLink.GET(MagentoWebsite.Code,Item."No.",'') THEN BEGIN
        MagentoWebsiteLink.SetRange("Item No.", Item."No.");
        MagentoWebsiteLink.SetRange("Variant Code", '');
        if not MagentoWebsiteLink.FindFirst then begin
            //+MAG2.23 [363897]
            MagentoWebsiteLink.Init;
            MagentoWebsiteLink."Website Code" := MagentoWebsite.Code;
            MagentoWebsiteLink."Item No." := Item."No.";
            MagentoWebsiteLink.Insert(true);
        end;
    end;

    local procedure AutoUpdateSeoLink(Item: Record Item): Boolean
    begin
        //-MAG2.19 [345884]
        if Item."NPR Seo Link" <> '' then
            exit(false);
        if not MagentoSetup.Get then
            exit(false);

        exit(not MagentoSetup."Auto Seo Link Disabled");
        //+MAG2.19 [345884]
    end;

    procedure SetupMultiStoreData(var Item: Record Item)
    var
        MagentoStore: Record "NPR Magento Store";
        MagentoStoreItem: Record "NPR Magento Store Item";
        MagentoWebsite: Record "NPR Magento Website";
        StoreItemModified: Boolean;
    begin
        if not Item."NPR Magento Item" then
            exit;
        if not (MagentoSetup.Get and MagentoSetup."Magento Enabled") then
            exit;
        if not MagentoSetup."Multistore Enabled" then
            exit;

        if MagentoStore.FindSet then
            repeat
                //-MAG2.00
                //Item.CALCFIELDS("Magento Description","Magento Short Description");
                //+MAG2.00
                MagentoWebsite.Get(MagentoStore."Website Code");
                if not MagentoStoreItem.Get(Item."No.", MagentoStore.Code) then begin
                    MagentoStoreItem.Init;
                    MagentoStoreItem."Item No." := Item."No.";
                    MagentoStoreItem."Store Code" := MagentoStore.Code;
                    MagentoStoreItem."Website Code" := MagentoStore."Website Code";
                    MagentoStoreItem.Enabled := MagentoWebsite."Default Website";
                    MagentoStoreItem."Root Item Group No." := MagentoStore."Root Item Group No.";
                    MagentoStoreItem.Insert(true);
                end;
            until MagentoStore.Next = 0;
    end;

    local procedure "--- Replication Mgt."()
    begin
    end;

    procedure InitReplicateSpecialPrice2SalesPrices()
    var
        Item: Record Item;
        Window: Dialog;
        UseDialog: Boolean;
        Counter: Integer;
        Total: Integer;
    begin
        //-MAG2.03 [267449]
        if not (MagentoSetup.Get and MagentoSetup."Special Prices Enabled" and MagentoSetup."Replicate to Sales Prices") then
            exit;

        Item.SetFilter("NPR Special Price", '>%1', 0);
        if Item.IsEmpty then
            exit;

        UseDialog := GuiAllowed;
        if UseDialog then begin
            Total := Item.Count;
            Window.Open(Text000 + ' @1@@@@@@@@@@@@@@');
        end;
        Item.FindSet;
        repeat
            if UseDialog then begin
                Counter += 1;
                Window.Update(1, Round((Counter / Total) * 10000, 1));
            end;
            ReplicateSpecialPrice2SalesPrice(Item, false);
        until Item.Next = 0;
        if UseDialog then
            Window.Close;
        //+MAG2.03 [267449]
    end;

    local procedure ReplicateSpecialPrice2SalesPrice(Item: Record Item; DeleteTrigger: Boolean)
    var
        SalesPrice: Record "Sales Price";
    begin
        //-MAG2.03 [267449]
        if not (MagentoSetup.Get and MagentoSetup."Special Prices Enabled" and MagentoSetup."Replicate to Sales Prices") then
            exit;

        if Item."NPR Special Price" <= 0 then
            DeleteTrigger := true;

        if FindSalesPrices(Item, SalesPrice) then begin
            if not DeleteTrigger then begin
                SalesPrice.SetRange("Starting Date", Item."NPR Special Price From");
                SalesPrice.SetRange("Ending Date", Item."NPR Special Price To");
                if not SalesPrice.IsEmpty then
                    exit;

                SalesPrice.SetRange("Starting Date");
                SalesPrice.SetRange("Ending Date");
            end;

            SalesPrice.DeleteAll;
        end;

        if DeleteTrigger then
            exit;
        if (MagentoSetup."Replicate to Sales Type" <> MagentoSetup."Replicate to Sales Type"::"All Customers") and (MagentoSetup."Replicate to Sales Code" = '') then
            SalesPrice.Init;
        SalesPrice.Validate("Item No.", Item."No.");
        SalesPrice."Sales Type" := MagentoSetup."Replicate to Sales Type";
        if MagentoSetup."Replicate to Sales Type" <> MagentoSetup."Replicate to Sales Type"::"All Customers" then
            SalesPrice.Validate("Sales Code", MagentoSetup."Replicate to Sales Code");
        SalesPrice."Starting Date" := Item."NPR Special Price From";
        SalesPrice."Minimum Quantity" := 0;
        SalesPrice."Unit Price" := Item."NPR Special Price";
        SalesPrice."Ending Date" := Item."NPR Special Price To";
        //-MAG2.07
        SalesPrice."VAT Bus. Posting Gr. (Price)" := Item."VAT Bus. Posting Gr. (Price)";
        //+MAG2.07
        //-MAG2.04 [247449]
        SalesPrice."Price Includes VAT" := Item."Price Includes VAT";
        //+MAG2.04 [247449]
        SalesPrice.Insert(true);
        //+MAG2.03 [267449]
    end;

    local procedure FindSalesPrices(Item: Record Item; var SalesPrice: Record "Sales Price"): Boolean
    begin
        //-MAG2.03 [267449]
        if not (MagentoSetup.Get and MagentoSetup."Special Prices Enabled" and MagentoSetup."Replicate to Sales Prices") then
            exit(false);

        Clear(SalesPrice);
        SalesPrice.SetRange("Item No.", Item."No.");
        SalesPrice.SetRange("Sales Type", MagentoSetup."Replicate to Sales Type");
        if MagentoSetup."Replicate to Sales Type" <> MagentoSetup."Replicate to Sales Type"::"All Customers" then
            SalesPrice.SetRange("Sales Code", MagentoSetup."Replicate to Sales Code");
        SalesPrice.SetRange("Variant Code", '');
        exit(not SalesPrice.IsEmpty);
        //+MAG2.03 [267449]
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'NPR Seo Link', true, true)]
    local procedure ItemOnAfterValidateSeoLink(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        MagentoFunctions: Codeunit "NPR Magento Functions";
    begin
        //-MAG2.00
        //-MAG2.03 [267449]
        //IF IsTemporary(Rec) THEN
        //  EXIT;
        if Rec.IsTemporary then
            exit;
        //+MAG2.03 [267449]

        Rec."NPR Seo Link" := MagentoFunctions.SeoFormat(Rec."NPR Seo Link");
        //+MAG2.00
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterInsertEvent', '', true, true)]
    local procedure ItemOnInsert(var Rec: Record Item; RunTrigger: Boolean)
    begin
        //-MAG2.00
        if not RunTrigger then
            exit;
        //-MAG2.03 [267449]
        //IF IsTemporary(Rec) THEN
        //  EXIT;
        if Rec.IsTemporary then
            exit;
        //+MAG2.03 [267449]

        //-MAG2.03 [267449]
        //MagentoItemMgt.SetupMagentoData(Rec);
        SetupMagentoData(Rec);
        ReplicateSpecialPrice2SalesPrice(Rec, false);
        //+MAG2.03 [267449]
        //+MAG2.00
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeModifyEvent', '', true, true)]
    local procedure ItemOnModify(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    begin
        //-MAG2.00
        if not RunTrigger then
            exit;
        //-MAG2.03 [267449]
        //IF IsTemporary(Rec) THEN
        //  EXIT;
        if Rec.IsTemporary then
            exit;
        //+MAG2.03 [267449]

        //-MAG2.20 [353499]
        // IF (xRec."Attribute Set ID" <> Rec."Attribute Set ID") AND xRec."Magento Item" AND Rec."Magento Item" THEN
        //  ERROR(Error001);
        //+MAG2.20 [353499]

        //-MAG2.03 [267449]
        //MagentoItemMgt.SetupMagentoData(Rec);
        SetupMagentoData(Rec);
        ReplicateSpecialPrice2SalesPrice(Rec, false);
        //+MAG2.03 [267449]
        //+MAG2.00
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterDeleteEvent', '', true, true)]
    local procedure ItemOnDelete(var Rec: Record Item; RunTrigger: Boolean)
    begin
        //-MAG2.00
        if not RunTrigger then
            exit;
        //-MAG2.03 [267449]
        //IF IsTemporary(Rec) THEN
        //  EXIT;
        if Rec.IsTemporary then
            exit;
        //+MAG2.03 [267449]

        //-MAG2.03 [267449]
        //MagentoItemMgt.DeleteMagentoData(Rec);
        DeleteMagentoData(Rec);
        ReplicateSpecialPrice2SalesPrice(Rec, true);
        //+MAG2.03 [267449]
        //+MAG2.00
    end;

    procedure "--- Stock Mgt."()
    begin
    end;

    procedure GetStockQty(ItemNo: Code[20]; VariantFilter: Text) StockQty: Decimal
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        //-MAG2.26 [402486]
        if MagentoSetup.Get then;
        StockQty := CalcStockQty(ItemNo, VariantFilter, MagentoSetup."Inventory Location Filter");
        exit(StockQty);
        //+MAG2.26 [402486]
    end;

    procedure GetStockQty2(var RecRef: RecordRef) StockQty: Decimal
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        MagentoItemMgt: Codeunit "NPR Magento Item Mgt.";
    begin
        //-MAG2.26 [402486]
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
        //+MAG2.26 [402486]
    end;

    procedure GetStockQty3(ItemNo: Code[20]; VariantFilter: Text; MagentoInventoryCompany: Record "NPR Magento Inv. Company") StockQty: Decimal
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        //-MAG2.26 [402486]
        StockQty := CalcStockQty(ItemNo, VariantFilter, MagentoInventoryCompany."Location Filter");
        exit(StockQty);
        //+MAG2.26 [402486]
    end;

    procedure CalcStockQty(ItemNo: Code[20]; VariantFilter: Text; LocationFilter: Text) StockQty: Decimal
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        VariantStockQty: Decimal;
        Handled: Boolean;
    begin
        //-MAG2.26 [402486]
        VariantFilter := UpperCase(VariantFilter);
        LocationFilter := UpperCase(LocationFilter);

        //-MAG2.26 [402488]
        if MagentoSetup.Get then;
        case MagentoSetup."Stock Calculation Method" of
            MagentoSetup."Stock Calculation Method"::"Function":
                begin
                    OnCalcStockQty(MagentoSetup, ItemNo, VariantFilter, LocationFilter, StockQty, Handled);
                end;
        end;

        if Handled then
            exit(StockQty);
        //+MAG2.26 [402488]

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
        if ItemVariant.FindSet then begin
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
            until ItemVariant.Next = 0;

            exit(StockQty);
        end;

        Item.SetFilter("Location Filter", LocationFilter);
        Item.CalcFields(Inventory, "Qty. on Sales Order");
        StockQty := Item.Inventory - Item."Qty. on Sales Order";

        exit(StockQty);
        //+MAG2.26 [402486]
    end;

    [EventSubscriber(ObjectType::Table, 6151401, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModifyMagentoSetup(var Rec: Record "NPR Magento Setup"; var xRec: Record "NPR Magento Setup"; RunTrigger: Boolean)
    begin
        //-MAG2.26 [402488]
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
        //+MAG2.26 [402488]
    end;

    procedure UpsertStockTriggers()
    var
        MagentoSetup: Record "NPR Magento Setup";
        NpXmlTemplate: Record "NPR NpXml Template";
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        ReqLine: Record "Requisition Line";
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        JobPlanningLine: Record "Job Planning Line";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComponent: Record "Prod. Order Component";
        TransLine: Record "Transfer Line";
        ServiceLine: Record "Service Line";
        PlanningComponent: Record "Planning Component";
        NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger";
        Handled: Boolean;
    begin
        //-MAG2.26 [402488]
        if not MagentoSetup.Get then
            exit;

        if MagentoSetup."Stock NpXml Template" = '' then
            exit;
        if not NpXmlTemplate.Get(MagentoSetup."Stock NpXml Template") then
            exit;
        if NpXmlTemplate."Table No." <> DATABASE::Item then
            exit;

        NpXmlTemplateTrigger.SetRange("Xml Template Code", NpXmlTemplate.Code);
        if NpXmlTemplateTrigger.FindFirst then
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
        //+MAG2.26 [402488]
    end;

    procedure UpsertStockTrigger(NpXmlTemplate: Record "NPR NpXml Template"; LinkFieldNoParent: Integer; TableNo: Integer; LinkFieldNoChild: Integer; TriggerOnInsert: Boolean; TriggerOnModify: Boolean; TriggerOnDelete: Boolean)
    var
        NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger";
        NpXmlTemplateTriggerLink: Record "NPR NpXml Templ.Trigger Link";
        "Field": Record "Field";
        LineNo: Integer;
    begin
        //-MAG2.26 [402488]
        NpXmlTemplateTrigger.SetRange("Xml Template Code", NpXmlTemplate.Code);
        NpXmlTemplateTrigger.SetRange("Table No.", TableNo);
        if not NpXmlTemplateTrigger.FindFirst then begin
            Clear(NpXmlTemplateTrigger);
            NpXmlTemplateTrigger.SetRange("Xml Template Code", NpXmlTemplate.Code);
            if NpXmlTemplateTrigger.FindLast then;
            LineNo := NpXmlTemplateTrigger."Line No." + 10000;

            NpXmlTemplateTrigger.Init;
            NpXmlTemplateTrigger."Xml Template Code" := NpXmlTemplate.Code;
            NpXmlTemplateTrigger."Line No." := LineNo;
            NpXmlTemplateTrigger."Table No." := TableNo;
            NpXmlTemplateTrigger."Parent Table No." := NpXmlTemplate."Table No.";
            NpXmlTemplateTrigger."Parent Line No." := 0;
            NpXmlTemplateTrigger."Insert Trigger" := TriggerOnInsert;
            NpXmlTemplateTrigger."Modify Trigger" := TriggerOnModify;
            NpXmlTemplateTrigger."Delete Trigger" := TriggerOnDelete;
            NpXmlTemplateTrigger."Generic Parent Codeunit ID" := CurrCodeunitId();
            NpXmlTemplateTrigger."Generic Parent Function" := GetTriggerStockFunctionName();
            NpXmlTemplateTrigger.Insert;
        end else begin
            NpXmlTemplateTrigger."Parent Table No." := NpXmlTemplate."Table No.";
            NpXmlTemplateTrigger."Parent Line No." := 0;
            NpXmlTemplateTrigger."Insert Trigger" := TriggerOnInsert;
            NpXmlTemplateTrigger."Modify Trigger" := TriggerOnModify;
            NpXmlTemplateTrigger."Delete Trigger" := TriggerOnDelete;
            NpXmlTemplateTrigger."Generic Parent Codeunit ID" := CurrCodeunitId();
            NpXmlTemplateTrigger."Generic Parent Function" := GetTriggerStockFunctionName();
            NpXmlTemplateTrigger.Modify;
        end;

        NpXmlTemplateTriggerLink.SetRange("Xml Template Code", NpXmlTemplateTrigger."Xml Template Code");
        NpXmlTemplateTriggerLink.SetRange("Xml Template Trigger Line No.", NpXmlTemplateTrigger."Line No.");
        NpXmlTemplateTriggerLink.SetRange("Parent Table No.", NpXmlTemplateTrigger."Parent Table No.");
        NpXmlTemplateTriggerLink.SetRange("Parent Field No.", LinkFieldNoParent);
        NpXmlTemplateTriggerLink.SetRange("Link Type", NpXmlTemplateTriggerLink."Link Type"::TableLink);
        NpXmlTemplateTriggerLink.SetRange("Table No.", NpXmlTemplateTrigger."Table No.");
        NpXmlTemplateTriggerLink.SetRange("Field No.", LinkFieldNoChild);
        if not NpXmlTemplateTriggerLink.FindFirst then begin
            Clear(NpXmlTemplateTriggerLink);
            NpXmlTemplateTriggerLink.SetRange("Xml Template Code", NpXmlTemplateTrigger."Xml Template Code");
            NpXmlTemplateTriggerLink.SetRange("Xml Template Trigger Line No.", NpXmlTemplateTrigger."Line No.");
            if NpXmlTemplateTriggerLink.FindLast then;
            LineNo := NpXmlTemplateTriggerLink."Line No." + 10000;

            NpXmlTemplateTriggerLink.Init;
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
        //+MAG2.26 [402488]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151553, 'OnSetupGenericParentTable', '', true, true)]
    local procedure TriggerStockUpdate(NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger"; ChildLinkRecRef: RecordRef; var ParentRecRef: RecordRef; var Handled: Boolean)
    var
        TempItem: Record Item temporary;
        MagentoSetup: Record "NPR Magento Setup";
    begin
        //-MAG2.26 [402488]
        if Handled then
            exit;
        if NpXmlTemplateTrigger."Generic Parent Codeunit ID" <> CurrCodeunitId() then
            exit;
        if NpXmlTemplateTrigger."Generic Parent Function" <> GetTriggerStockFunctionName() then
            exit;
        if NpXmlTemplateTrigger."Parent Table No." <> DATABASE::Item then
            exit;

        Handled := true;

        if MagentoSetup.Get then;
        Trigger2Item(MagentoSetup, ChildLinkRecRef, TempItem);

        ParentRecRef.GetTable(TempItem);
        //+MAG2.26 [402488]
    end;

    local procedure Trigger2Item(MagentoSetup: Record "NPR Magento Setup"; RecRef: RecordRef; var TempItem: Record Item temporary)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        Item: Record Item;
        TempSalesLine: Record "Sales Line" temporary;
        ItemNo: Code[20];
        Handled: Boolean;
    begin
        //-MAG2.26 [402488]
        if not TempItem.IsTemporary then
            exit;

        Clear(TempItem);
        TempItem.DeleteAll;

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
                    if not ItemLedgerEntry.Find then
                        exit;

                    ItemNo := ItemLedgerEntry."Item No.";
                end;
            DATABASE::"Sales Line":
                begin
                    if not RecRef2TempSalesLine(RecRef, TempSalesLine) then
                        exit;

                    TempSalesLine.SetRecFilter;
                    TempSalesLine.FilterGroup(40);
                    TempSalesLine.SetFilter("Location Code", MagentoSetup."Inventory Location Filter");
                    TempSalesLine.SetRange("Document Type", TempSalesLine."Document Type"::Order);
                    TempSalesLine.SetFilter("Location Code", MagentoSetup."Inventory Location Filter");
                    TempSalesLine.SetRange(Type, TempSalesLine.Type::Item);
                    TempSalesLine.SetFilter("No.", '<>%1', '');
                    if not TempSalesLine.FindFirst then
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

        TempItem.Init;
        TempItem := Item;
        TempItem.Insert;
        //+MAG2.26 [402488]
    end;

    local procedure RecRef2TempSalesLine(RecRef: RecordRef; var TempSalesLine: Record "Sales Line" temporary): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        //-MAG2.26 [402488]
        if RecRef.IsTemporary then begin
            RecRef.SetTable(TempSalesLine);
            TempSalesLine.Insert;
            exit(true);
        end;

        RecRef.SetTable(SalesLine);
        if not SalesLine.Find then
            exit(false);

        TempSalesLine.Init;
        TempSalesLine := SalesLine;
        TempSalesLine.Insert;
        exit(true)
        //+MAG2.26 [402488]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-MAG2.26 [402488]
        exit(CODEUNIT::"NPR Magento Item Mgt.");
        //+MAG2.26 [402488]
    end;

    local procedure GetTriggerStockFunctionName(): Text
    begin
        //-MAG2.26 [402488]
        exit('TriggerStockUpdate');
        //+MAG2.26 [402488]
    end;

    local procedure "--- Stock Calculation Interface"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcStockQty(MagentoSetup: Record "NPR Magento Setup"; ItemNo: Code[20]; VariantFilter: Text; LocationFilter: Text; var StockQty: Decimal; var Handled: Boolean)
    begin
        //-MAG2.26 [402488]
        //+MAG2.26 [402488]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpsertStockTriggers(MagentoSetup: Record "NPR Magento Setup"; NpXmlTemplate: Record "NPR NpXml Template"; var Handled: Boolean)
    begin
        //-MAG2.26 [402488]
        //+MAG2.26 [402488]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTrigger2Item(MagentoSetup: Record "NPR Magento Setup"; RecRef: RecordRef; var TempItem: Record Item temporary; var Handled: Boolean)
    begin
        //-MAG2.26 [402488]
        //+MAG2.26 [402488]
    end;
}

