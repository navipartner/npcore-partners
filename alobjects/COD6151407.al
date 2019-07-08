codeunit 6151407 "Magento Item Mgt."
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


    trigger OnRun()
    begin
    end;

    var
        MagentoSetup: Record "Magento Setup";
        MagentoAttributeSetMgt: Codeunit "Magento Attribute Set Mgt.";
        MagentoFunctions: Codeunit "Magento Functions";
        Error001: Label '%1 should be less than or equal to %2';
        Text000: Label 'Replicating Special Prices to Sales Prices:';

    procedure "--- Data Mgt."()
    begin
    end;

    procedure DeleteMagentoData(var Item: Record Item)
    var
        MagentoItemAttribute: Record "Magento Item Attribute";
        MagentoItemAttributeValue: Record "Magento Item Attribute Value";
        MagentoItemGroupLink: Record "Magento Item Group Link";
        MagentoPictureLink: Record "Magento Picture Link";
        MagentoProductRelation: Record "Magento Product Relation";
        MagentoWebsiteLink: Record "Magento Website Link";
    begin
        MagentoWebsiteLink.SetRange("Item No.",Item."No.");
        MagentoWebsiteLink.DeleteAll;

        MagentoItemGroupLink.SetRange("Item No.",Item."No.");
        MagentoItemGroupLink.DeleteAll;

        MagentoPictureLink.SetRange("Item No.",Item."No.");
        MagentoPictureLink.DeleteAll;

        MagentoItemAttribute.SetRange("Item No.",Item."No.");
        MagentoItemAttribute.DeleteAll;

        MagentoItemAttributeValue.SetRange("Item No.",Item."No.");
        MagentoItemAttributeValue.DeleteAll;

        MagentoProductRelation.Reset;
        MagentoProductRelation.SetRange("From Item No.",Item."No.");
        MagentoProductRelation.DeleteAll;
        MagentoProductRelation.Reset;
        MagentoProductRelation.SetRange("To Item No.",Item."No.");
        MagentoProductRelation.DeleteAll;
    end;

    procedure SetupMagentoData(var Item: Record Item)
    var
        MagentoWebsite: Record "Magento Website";
        MagentoWebsiteLink: Record "Magento Website Link";
    begin
        if Item."Magento Name" = '' then
          Item."Magento Name" := Item.Description;

        //-MAG2.19 [345884]
        // IF (Item."Seo Link" = '') AND (NOT MagentoSetup.GET) OR (NOT MagentoSetup."Auto Seo Link Disabled") THEN
        //  //-MAG2.17 [333049]
        //  Item."Seo Link" := MagentoFunctions.SeoFormat(Item."Seo Link");
        //  //+MAG2.17 [333049]
        if AutoUpdateSeoLink(Item) then
          Item."Seo Link" := MagentoFunctions.SeoFormat(Item."Magento Name");
        //+MAG2.19 [345884]
        if not Item."Magento Item" then
          exit;

        if not (MagentoSetup.Get and MagentoSetup."Magento Enabled") then
          exit;

        MagentoWebsite.SetRange("Default Website",true);
        if not MagentoWebsite.FindFirst then
          exit;

        if not MagentoWebsiteLink.Get(MagentoWebsite.Code,Item."No.",'') then begin
          MagentoWebsiteLink.Init;
          MagentoWebsiteLink."Website Code" := MagentoWebsite.Code;
          MagentoWebsiteLink."Item No." := Item."No.";
           MagentoWebsiteLink.Insert(true);
        end;
    end;

    local procedure AutoUpdateSeoLink(Item: Record Item): Boolean
    begin
        //-MAG2.19 [345884]
        if Item."Seo Link" <> '' then
          exit(false);
        if not MagentoSetup.Get then
          exit(false);

        exit(not MagentoSetup."Auto Seo Link Disabled");
        //+MAG2.19 [345884]
    end;

    procedure SetupMultiStoreData(var Item: Record Item)
    var
        MagentoStore: Record "Magento Store";
        MagentoStoreItem: Record "Magento Store Item";
        MagentoWebsite: Record "Magento Website";
        StoreItemModified: Boolean;
    begin
        if not Item."Magento Item" then
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
            if not MagentoStoreItem.Get(Item."No.",MagentoStore.Code) then begin
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

        Item.SetFilter("Special Price",'>%1',0);
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
            Window.Update(1,Round((Counter / Total) * 10000,1));
          end;
          ReplicateSpecialPrice2SalesPrice(Item,false);
        until Item.Next = 0;
        if UseDialog then
          Window.Close;
        //+MAG2.03 [267449]
    end;

    local procedure ReplicateSpecialPrice2SalesPrice(Item: Record Item;DeleteTrigger: Boolean)
    var
        SalesPrice: Record "Sales Price";
    begin
        //-MAG2.03 [267449]
        if not (MagentoSetup.Get and MagentoSetup."Special Prices Enabled" and MagentoSetup."Replicate to Sales Prices") then
          exit;

        if Item."Special Price" <= 0 then
          DeleteTrigger := true;

        if FindSalesPrices(Item,SalesPrice) then begin
          if not DeleteTrigger then begin
            SalesPrice.SetRange("Starting Date",Item."Special Price From");
            SalesPrice.SetRange("Ending Date",Item."Special Price To");
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
        SalesPrice.Validate("Item No.",Item."No.");
        SalesPrice."Sales Type" := MagentoSetup."Replicate to Sales Type";
        if MagentoSetup."Replicate to Sales Type" <> MagentoSetup."Replicate to Sales Type"::"All Customers" then
          SalesPrice.Validate("Sales Code",MagentoSetup."Replicate to Sales Code");
        SalesPrice."Starting Date" := Item."Special Price From";
        SalesPrice."Minimum Quantity" := 0;
        SalesPrice."Unit Price" := Item."Special Price";
        SalesPrice."Ending Date" := Item."Special Price To";
        //-MAG2.07
        SalesPrice."VAT Bus. Posting Gr. (Price)" := Item."VAT Bus. Posting Gr. (Price)" ;
        //+MAG2.07
        //-MAG2.04 [247449]
        SalesPrice."Price Includes VAT" := Item."Price Includes VAT";
        //+MAG2.04 [247449]
        SalesPrice.Insert(true);
        //+MAG2.03 [267449]
    end;

    local procedure FindSalesPrices(Item: Record Item;var SalesPrice: Record "Sales Price"): Boolean
    begin
        //-MAG2.03 [267449]
        if not (MagentoSetup.Get and MagentoSetup."Special Prices Enabled" and MagentoSetup."Replicate to Sales Prices") then
          exit(false);

        Clear(SalesPrice);
        SalesPrice.SetRange("Item No.",Item."No.");
        SalesPrice.SetRange("Sales Type",MagentoSetup."Replicate to Sales Type");
        if MagentoSetup."Replicate to Sales Type" <> MagentoSetup."Replicate to Sales Type"::"All Customers" then
          SalesPrice.SetRange("Sales Code",MagentoSetup."Replicate to Sales Code");
        SalesPrice.SetRange("Variant Code",'');
        exit(not SalesPrice.IsEmpty);
        //+MAG2.03 [267449]
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Seo Link', true, true)]
    local procedure ItemOnAfterValidateSeoLink(var Rec: Record Item;var xRec: Record Item;CurrFieldNo: Integer)
    var
        MagentoFunctions: Codeunit "Magento Functions";
    begin
        //-MAG2.00
        //-MAG2.03 [267449]
        //IF IsTemporary(Rec) THEN
        //  EXIT;
        if Rec.IsTemporary then
          exit;
        //+MAG2.03 [267449]

        Rec."Seo Link" := MagentoFunctions.SeoFormat(Rec."Seo Link");
        //+MAG2.00
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterInsertEvent', '', true, true)]
    local procedure ItemOnInsert(var Rec: Record Item;RunTrigger: Boolean)
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
        ReplicateSpecialPrice2SalesPrice(Rec,false);
        //+MAG2.03 [267449]
        //+MAG2.00
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeModifyEvent', '', true, true)]
    local procedure ItemOnModify(var Rec: Record Item;var xRec: Record Item;RunTrigger: Boolean)
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
        ReplicateSpecialPrice2SalesPrice(Rec,false);
        //+MAG2.03 [267449]
        //+MAG2.00
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterDeleteEvent', '', true, true)]
    local procedure ItemOnDelete(var Rec: Record Item;RunTrigger: Boolean)
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
        ReplicateSpecialPrice2SalesPrice(Rec,true);
        //+MAG2.03 [267449]
        //+MAG2.00
    end;

    procedure "--- Inventory Mgt."()
    begin
    end;

    procedure GetAvailInventory(ItemNo: Code[20];VariantFilter: Text;LocationFilter: Text) AvailInventory: Decimal
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        VariantInventory: Decimal;
    begin
        //-MAG1.22
        Clear(Item);
        if not Item.Get(ItemNo) then
          exit(0);
        VariantFilter := UpperCase(VariantFilter);
        LocationFilter := UpperCase(LocationFilter);

        if VariantFilter <> '' then begin
          Item.SetFilter("Variant Filter",VariantFilter);
          Item.SetFilter("Location Filter",LocationFilter);
          Item.CalcFields(Inventory,"Qty. on Sales Order");
          AvailInventory := Item.Inventory - Item."Qty. on Sales Order";
          if AvailInventory < 0 then
            AvailInventory := 0;

          exit(AvailInventory);
        end;

        ItemVariant.SetRange("Item No.",Item."No.");
        if ItemVariant.FindSet then begin
          AvailInventory := 0;
          VariantInventory := 0;
          repeat
            Item.SetFilter("Variant Filter",ItemVariant.Code);
            Item.SetFilter("Location Filter",LocationFilter);
            Item.CalcFields(Inventory,"Qty. on Sales Order");
            VariantInventory := Item.Inventory - Item."Qty. on Sales Order";
            if VariantInventory < 0 then
              VariantInventory := 0;

            AvailInventory += VariantInventory;
          until ItemVariant.Next = 0;

          exit(AvailInventory);
        end;

        Item.SetFilter("Location Filter",LocationFilter);
        Item.CalcFields(Inventory,"Qty. on Sales Order");
        AvailInventory := Item.Inventory - Item."Qty. on Sales Order";

        exit(AvailInventory);
        //+MAG1.22
    end;
}

