﻿codeunit 6014468 "NPR UPG Item Group"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UGP Item Group', 'Upgrade');

        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Item Group")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        Upgrade();

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Item Group"));

        LogMessageStopwatch.LogFinish();
    end;

    procedure Upgrade()

    begin
        UpgradeItemGroup();
        UpgradeItemGroupOnItem();
        UpgradeSalesPriceMaintGroups();
    end;

    procedure UpgradeItemGroup()
    var
        ItemGroup: Record "NPR Item Group";
        ItemCategory: Record "Item Category";
        TempItem: Record Item temporary;
        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
    begin
        Database.SelectLatestVersion();
        ItemGroup.Reset();
        if not ItemGroup.FindSet() then
            exit;

        repeat
            if ItemGroup."Parent Item Group No." <> '' then
                GetOrInsertItemCategory(ItemGroup."Parent Item Group No.", ItemCategory);

            GetOrInsertItemCategory(ItemGroup."No.", ItemCategory);

            ItemCategory."Parent Category" := ItemGroup."Parent Item Group No.";
            ItemCategory.Description := ItemGroup.Description;
            ItemCategory."NPR Main Category" := ItemGroup."Main Item Group";
            ItemCategory."NPR Main Category Code" := ItemGroup."Belongs In Main Item Group";
            ItemCategory."NPR Blocked" := ItemGroup.Blocked;
            ItemCategory."NPR Global Dimension 1 Code" := ItemGroup."Global Dimension 1 Code";
            ItemCategory."NPR Global Dimension 2 Code" := ItemGroup."Global Dimension 2 Code";

            Clear(TempItem);
            TempItem.Type := ItemGroup.Type;
            TempItem."Item Disc. Group" := ItemGroup."Item Discount Group";
            TempItem."No. Series" := ItemGroup."No. Series";
            TempItem."Costing Method" := ItemGroup."Costing Method";
            TempItem."Base Unit of Measure" := ItemGroup."Base Unit of Measure";
            TempItem."Sales Unit of Measure" := ItemGroup."Sales Unit of Measure";
            TempItem."Purch. Unit of Measure" := ItemGroup."Purch. Unit of Measure";
            TempItem."NPR Guarantee voucher" := ItemGroup.Warranty;
            TempItem."Tax Group Code" := ItemGroup."Tax Group Code";
            TempItem."Tariff No." := ItemGroup."Tarif No.";
            TempItem."Reordering Policy" := "Reordering Policy".FromInteger(ItemGroup."Reordering Policy");
            TempItem."Gen. Prod. Posting Group" := ItemGroup."Gen. Prod. Posting Group";
            TempItem."VAT Prod. Posting Group" := ItemGroup."VAT Prod. Posting Group";
            TempItem."VAT Bus. Posting Gr. (Price)" := ItemGroup."VAT Bus. Posting Group";
            TempItem."Inventory Posting Group" := ItemGroup."Inventory Posting Group";
            TempItem."Item Category Code" := ItemCategory.Code;
            TempItem."NPR Variety Group" := ItemGroup."Variety Group";

            ItemCategory."NPR Item Template Code" := ItemCategoryMgt.CreateItemTemplate(ItemCategory, TempItem);

            // Trigger skip intentional!
            ItemCategory.Modify();

            CopyDefaultDimensions(ItemGroup, ItemCategory);
        until ItemGroup.Next() = 0;

#IF BC17 or BC18 or BC19 or BC20
        ItemCategory.Reset();
        if ItemCategory.FindSet(true) then
            repeat
                DoItemCategoryPresentation(ItemCategory);
                ItemCategory.Modify();
            until ItemCategory.Next() = 0;
#endif
    end;

#IF BC17 or BC18 or BC19 or BC20
    local procedure DoItemCategoryPresentation(var ItemCategory: Record "Item Category")
    var
        ParentItemCategory: Record "Item Category";
        BaseItemCategoryMgt: Codeunit "Item Category Management";
    begin
        if ParentItemCategory.Get(ItemCategory."Parent Category") then
            ItemCategory.UpdateIndentationTree(ParentItemCategory.Indentation + 1)
        else
            ItemCategory.UpdateIndentationTree(0);

        BaseItemCategoryMgt.CalcPresentationOrder(ItemCategory);
    end;
#endif

    local procedure CopyDefaultDimensions(FromItemGroup: Record "NPR Item Group"; ToItemCategory: Record "Item Category")
    var
        FromDefaultDimension: Record "Default Dimension";
        ToDefaultDimension: Record "Default Dimension";
    begin
        FromDefaultDimension.SetRange("Table ID", Database::"NPR Item Group");
        FromDefaultDimension.SetRange("No.", FromItemGroup."No.");
        if FromDefaultDimension.FindSet() then
            repeat
                if not ToDefaultDimension.Get(Database::"Item Category", ToItemCategory.Code, FromDefaultDimension."Dimension Code") then begin
                    ToDefaultDimension.Init();
                    ToDefaultDimension.TransferFields(FromDefaultDimension);
                    ToDefaultDimension."Table ID" := Database::"Item Category";
                    ToDefaultDimension."No." := ToItemCategory.Code;
                    ToDefaultDimension.Insert(true);
                end;
            until FromDefaultDimension.Next() = 0;
    end;

    local procedure UpgradeItemGroupOnItem()
    var
        Item: Record Item;
        MagentoSetup: Record "NPR Magento Setup";
        SpecialPricesEnabled: Boolean;
    begin
        Database.SelectLatestVersion();
        Item.SetFilter("NPR Item Group", '<>%1', '');
        if Item.FindSet(true) then begin
            if MagentoSetup.Get() then begin
                SpecialPricesEnabled := MagentoSetup."Special Prices Enabled";
                MagentoSetup."Special Prices Enabled" := false;
                MagentoSetup.Modify();
            end;

            repeat
                Item."Item Category Code" := Item."NPR Item Group";
                Item.UpdateItemCategoryId();
                Item.Modify(true);
            until Item.Next() = 0;

            if SpecialPricesEnabled then begin
                MagentoSetup."Special Prices Enabled" := SpecialPricesEnabled;
                MagentoSetup.Modify();
            end;
        end;
    end;

    local procedure UpgradeSalesPriceMaintGroups()
    var
        SalesPriceMaintGroups: Record "NPR Sales Price Maint. Groups";
        SalesPriceMaintGroups2: Record "NPR Sales Price Maint. Groups2";
    begin
        if SalesPriceMaintGroups.FindSet() then
            repeat
                if not SalesPriceMaintGroups2.Get(SalesPriceMaintGroups.Id, SalesPriceMaintGroups."Item Group") then begin
                    SalesPriceMaintGroups2.Init();
                    SalesPriceMaintGroups2.TransferFields(SalesPriceMaintGroups);
                    SalesPriceMaintGroups2.Insert();
                end;
            until SalesPriceMaintGroups.Next() = 0;
    end;

    local procedure GetOrInsertItemCategory(ItemCategoryCode: Code[20]; var ItemCategory: Record "Item Category")
    begin
        if ItemCategory.Get(ItemCategoryCode) then
            exit;

        ItemCategory.Init();
        ItemCategory.Code := ItemCategoryCode;
        // Trigger skip intentional!
        ItemCategory.Insert();
    end;
}