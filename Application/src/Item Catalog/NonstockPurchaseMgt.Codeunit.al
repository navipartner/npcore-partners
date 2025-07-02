#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
codeunit 6060064 "NPR Nonstock Purchase Mgt."
{
    Access = Internal;

    procedure ShowNonstock(var PurchaseLine: Record "Purchase Line"; ItemRef: Code[50])
    var
        NonstockItem: Record "Nonstock Item";
        SelectNonstockItemErr: Label 'You can only select a catalog item for an empty line.';
        Execute: Boolean;
    begin
        PurchaseLine.TestField(Type, PurchaseLine.Type::Item);
        if PurchaseLine."No." <> '' then
            Error(SelectNonstockItemErr);

        if ItemRef <> '' then
            Execute := FindNonstockItemReference(NonstockItem, ItemRef)
        else
            Execute := Page.RunModal(Page::"Catalog Item List", NonstockItem) = Action::LookupOK;

        if Execute then begin
            CheckNonstockItemTemplate(NonstockItem);
            PurchaseLine."No." := NonstockItem."Entry No.";

            NonStockPurchase(PurchaseLine);
            PurchaseLine.Validate("No.", PurchaseLine."No.");

            PurchaseLine."Item Reference Type" := "Item Reference Type"::"Bar Code";
            PurchaseLine."Item Reference No." := NonstockItem."Bar Code";
        end;
    end;

    local procedure FindNonstockItemReference(var NonstockItem: Record "Nonstock Item"; ItemRef: Code[50]): Boolean
    begin
        NonstockItem.SetRange("Vendor Item No.", ItemRef);
        if NonstockItem.FindFirst() then
            exit(true);

        NonstockItem.SetRange("Vendor Item No.");
        if StrLen(ItemRef) <= MaxStrLen(NonstockItem."Bar Code") then begin
            NonstockItem.SetRange("Bar Code", ItemRef);
            exit(NonstockItem.FindFirst());
        end;

        exit(false);
    end;

    local procedure CheckNonstockItemTemplate(NonstockItem: Record "Nonstock Item")
    var
        ItemTempl: Record "Item Templ.";
    begin
        ItemTempl.Get(NonstockItem."Item Templ. Code");
        ItemTempl.TestField("Gen. Prod. Posting Group");
        if ItemTempl.Type = ItemTempl.Type::Inventory then
            ItemTempl.TestField("Inventory Posting Group");
    end;

    local procedure NonStockPurchase(var PurchaseLine2: Record "Purchase Line")
    var
        NonStock: Record "Nonstock Item";
        NewItem: Record Item;
        CatalogItemMgt: Codeunit "Catalog Item Management";
        InvalidDocTypeErr: Label 'You cannot enter a nonstock item on %1.';
    begin
        if PurchaseLine2.IsCreditDocType() then
            Error(InvalidDocTypeErr, PurchaseLine2."Document Type");

        NonStock.Get(PurchaseLine2."No.");
        if NonStock."Item No." <> '' then begin
            PurchaseLine2."No." := NonStock."Item No.";
            exit;
        end;

        CatalogItemMgt.DetermineItemNoAndItemNoSeries(NonStock);
        NonStock.Modify();
        PurchaseLine2."No." := NonStock."Item No.";
        CatalogItemMgt.InsertItemUnitOfMeasure(NonStock."Unit of Measure", PurchaseLine2."No.");

        NewItem.SetRange("No.", PurchaseLine2."No.");
        if NewItem.FindFirst() then
            exit;

        if GuiAllowed() then
            CatalogItemMgt.OpenProgressDialog(NonStock, PurchaseLine2."No.");

        CatalogItemMgt.CreateNewItem(NonStock);

        if CatalogItemMgt.CheckLicensePermission(Database::"Item Vendor") then
            CatalogItemMgt.NonstockItemVend(NonStock);
        if CatalogItemMgt.CheckLicensePermission(Database::"Item Reference") then
            CatalogItemMgt.NonstockItemReference(NonStock);

        if GuiAllowed() then
            CatalogItemMgt.CloseProgressDialog();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeValidateEvent', 'Item Reference No.', false, false)]
    local procedure OnBeforeValidateItemReferenceNo(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
    begin
        if (Rec."Item Reference No." <> '') and (Rec."Item Reference No." <> xRec."Item Reference No.") then begin
            Item.SetRange("Vendor Item No.", Rec."Item Reference No.");
            if not Item.FindFirst() then begin
                ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::Vendor);
                ItemReference.SetRange("Reference No.", Rec."Item Reference No.");
                if not ItemReference.FindFirst() then begin
                    Item.SetRange("Vendor Item No.");
                    ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
                    if not ItemReference.FindFirst() then
                        ShowNonstock(Rec, Rec."Item Reference No.");
                end;
            end;
        end;
    end;
}
#endif
