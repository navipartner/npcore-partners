codeunit 85001 "NPR Library - Inventory"
{
    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryERM: Codeunit "Library - ERM";
        VATPostingSetup: Record "VAT Posting Setup";

    procedure CreateItemCategory(var ItemCategory: Record "Item Category"): Code[20]
    var
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
#ELSE
        NoSeriesManagement: Codeunit NoSeriesManagement;
#ENDIF
        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
        GeneralPostingSetup: Record "General Posting Setup";
        InventoryPostingGroup: Record "Inventory Posting Group";
        VATPostingSetup: Record "VAT Posting Setup";
        TempItem: Record Item temporary;
    begin
        Clear(ItemCategory);

#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        ItemCategory.Code := NoSeriesManagement.GetNextNo(LibraryUtility.GetGlobalNoSeriesCode, Today, false);
#ELSE
        ItemCategory.Code := NoSeriesManagement.GetNextNo(LibraryUtility.GetGlobalNoSeriesCode, Today, true);
#ENDIF
        ItemCategory.Insert(true);

        VATPostingSetup.SetFilter("VAT Bus. Posting Group", '<>%1', '');
        LibraryERM.FindVATPostingSetupInvt(VATPostingSetup);
        LibraryERM.FindGeneralPostingSetupInvtFull(GeneralPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);
        if not InventoryPostingGroup.FindFirst() then
            LibraryInventory.CreateInventoryPostingGroup(InventoryPostingGroup);

        TempItem."Gen. Prod. Posting Group" := GeneralPostingSetup."Gen. Prod. Posting Group";
        TempItem."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
        TempItem."Inventory Posting Group" := InventoryPostingGroup.Code;

        ItemCategory."NPR Item Template Code" := ItemCategoryMgt.CreateItemTemplate(ItemCategory, TempItem);

        ItemCategory.Modify(true);

        exit(ItemCategory.Code);
    end;

    procedure CreateItemCategoryCode(): Code[20]
    var
        ItemCategory: Record "Item Category";
    begin
        CreateItemCategory(ItemCategory);
        exit(ItemCategory.Code);
    end;

    procedure CreateItem(var Item: Record Item): Code[20]
    var
        InventorySetup: Record "Inventory Setup";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        GeneralPostingSetup: Record "General Posting Setup";
        GenProdPostGroup: Record "Gen. Product Posting Group";
        VATProdPostingGroup: Record "VAT Product Posting Group";
        InventoryPostingGroup: Record "Inventory Posting Group";
        TaxGroup: Record "Tax Group";
    begin
        ItemNoSeriesSetup(InventorySetup);
        Clear(Item);

        Item."Item Category Code" := CreateItemCategoryCode();
        Item.Insert(true);

        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", '', 1);

        LibraryERM.FindGeneralPostingSetupInvtFull(GeneralPostingSetup);
        if GeneralPostingSetup."Gen. Prod. Posting Group" <> '' then
            if GenProdPostGroup.Get(GeneralPostingSetup."Gen. Prod. Posting Group") and GenProdPostGroup."Auto Insert Default" and (GenProdPostGroup."Def. VAT Prod. Posting Group" <> '') then
                if not VATProdPostingGroup.Get(GenProdPostGroup."Def. VAT Prod. Posting Group") then begin
                    GenProdPostGroup."Auto Insert Default" := false;
                    GenProdPostGroup.Modify();
                end;
        if VATPostingSetup."VAT Bus. Posting Group" = '' then
            LibraryERM.FindVATPostingSetupInvt(VATPostingSetup);
        if not InventoryPostingGroup.FindFirst() then
            LibraryInventory.CreateInventoryPostingGroup(InventoryPostingGroup);

        Item.Validate(Description, Item."No.");  // Validation Description as No. because value is not important.
        Item.Validate("Base Unit of Measure", ItemUnitOfMeasure.Code);
        Item.Validate("Gen. Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group");
        Item.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        Item.Validate("Inventory Posting Group", InventoryPostingGroup.Code);

        if TaxGroup.FindFirst() then
            Item.Validate("Tax Group Code", TaxGroup.Code);

        Item.Modify(true);
        exit(Item."No.");
    end;

    procedure CreateItemNo(): Code[20]
    var
        Item: Record Item;
    begin
        CreateItem(Item);
        exit(Item."No.");
    end;

    procedure SetVatPostingSetup(NewVATPostingSetup: Record "VAT Posting Setup")
    begin
        VATPostingSetup := NewVATPostingSetup;
    end;

    local procedure ItemNoSeriesSetup(var InventorySetup: Record "Inventory Setup")
    var
        NoSeriesCode: Code[20];
    begin
        InventorySetup.Get();
        NoSeriesCode := LibraryUtility.GetGlobalNoSeriesCode;
        if NoSeriesCode <> InventorySetup."Item Nos." then begin
            InventorySetup.Validate("Item Nos.", LibraryUtility.GetGlobalNoSeriesCode);
            InventorySetup.Modify(true);
        end;
    end;
}

