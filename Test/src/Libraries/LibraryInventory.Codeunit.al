codeunit 85001 "NPR Library - Inventory"
{
    trigger OnRun()
    begin
    end;

    var
        InventorySetup: Record "Inventory Setup";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryERM: Codeunit "Library - ERM";
        VATPostingSetup: Record "VAT Posting Setup";

    procedure CreateItemGroup(var ItemGroup: Record "NPR Item Group"): Code[10]
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
        GeneralPostingSetup: Record "General Posting Setup";
        InventoryPostingGroup: Record "Inventory Posting Group";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        Clear(ItemGroup);

        ItemGroup."No." := NoSeriesManagement.GetNextNo(LibraryUtility.GetGlobalNoSeriesCode, Today, true);
        ItemGroup.Insert(true);

        VATPostingSetup.SetFilter("VAT Bus. Posting Group", '<>%1', '');
        LibraryERM.FindVATPostingSetupInvt(VATPostingSetup);
        LibraryERM.FindGeneralPostingSetupInvtFull(GeneralPostingSetup);
        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);
        if not InventoryPostingGroup.FindFirst then
            LibraryInventory.CreateInventoryPostingGroup(InventoryPostingGroup);

        ItemGroup.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        ItemGroup.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");

        ItemGroup."Gen. Prod. Posting Group" := GeneralPostingSetup."Gen. Prod. Posting Group";
        ItemGroup."Gen. Bus. Posting Group" := GeneralPostingSetup."Gen. Bus. Posting Group";

        ItemGroup."Inventory Posting Group" := InventoryPostingGroup.Code;

        ItemGroup.Modify(true);

        exit(ItemGroup."No.");
    end;

    procedure CreateItemGroupNo(): Code[10]
    var
        ItemGroup: Record "NPR Item Group";
    begin
        CreateItemGroup(ItemGroup);
        exit(ItemGroup."No.");
    end;

    procedure CreateItem(var Item: Record Item): Code[20]
    var
        InventorySetup: Record "Inventory Setup";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        GeneralPostingSetup: Record "General Posting Setup";
        InventoryPostingGroup: Record "Inventory Posting Group";
        TaxGroup: Record "Tax Group";
    begin
        ItemNoSeriesSetup(InventorySetup);
        Clear(Item);

        Item."NPR Item Group" := CreateItemGroupNo();
        Item.Insert(true);

        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", '', 1);

        LibraryERM.FindGeneralPostingSetupInvtFull(GeneralPostingSetup);
        if VATPostingSetup."VAT Bus. Posting Group" = '' then
            LibraryERM.FindVATPostingSetupInvt(VATPostingSetup);
        if not InventoryPostingGroup.FindFirst then
            LibraryInventory.CreateInventoryPostingGroup(InventoryPostingGroup);

        Item.Validate(Description, Item."No.");  // Validation Description as No. because value is not important.
        Item.Validate("Base Unit of Measure", ItemUnitOfMeasure.Code);
        Item.Validate("Gen. Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group");
        Item.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        Item.Validate("Inventory Posting Group", InventoryPostingGroup.Code);

        if TaxGroup.FindFirst then
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
        NoSeriesCode: Code[10];
    begin
        InventorySetup.Get;
        NoSeriesCode := LibraryUtility.GetGlobalNoSeriesCode;
        if NoSeriesCode <> InventorySetup."Item Nos." then begin
            InventorySetup.Validate("Item Nos.", LibraryUtility.GetGlobalNoSeriesCode);
            InventorySetup.Modify(true);
        end;
    end;
}

