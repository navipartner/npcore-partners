codeunit 6060064 "NPR Nonstock Purchase Mgt."
{
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
        UnitofMeasure: Record "Unit of Measure";
        ItemVend: Record "Item Vendor";
        NewItem: Record Item;
        NonStock: Record "Nonstock Item";
        Text002: Label 'You cannot enter a nonstock item on %1.';
        Text003: Label 'Creating item card for nonstock item\';
        Text004: Label 'Manufacturer Code    #1####\';
        Text005: Label 'Vendor               #2##################\';
        Text006: Label 'Vendor Item          #3##################\';
        Text007: Label 'Item No.             #4##################';
        ProgWindow: Dialog;


    procedure ShowNonstock(var PurchaseLine: Record "Purchase Line"; ItemRef: Code[50])
    var
        NonstockItem: Record "Nonstock Item";
        Execute: Boolean;
    begin
        PurchaseLine.TestField(Type, PurchaseLine.Type::Item);
        PurchaseLine.TestField("No.", '');

        if ItemRef = '' then begin
            if PAGE.RunModal(PAGE::"Catalog Item List", NonstockItem) = ACTION::LookupOK then
                Execute := true;
        end else begin
            NonstockItem.SetRange("Vendor Item No.", ItemRef);
            if not NonstockItem.FindFirst() then begin
                NonstockItem.SetRange("Vendor Item No.");
                NonstockItem.SetRange("Bar Code", ItemRef);
                if not NonstockItem.FindFirst() then
                    exit;
            end;
            Execute := true;
        end;
        if Execute then begin
            NonstockItem.TestField("Item Template Code");
            PurchaseLine."No." := NonstockItem."Entry No.";
            NonStockPurchase(PurchaseLine);
            PurchaseLine.Validate("No.", PurchaseLine."No.");
            PurchaseLine."Item Reference Type" := "Item Reference Type"::"Bar Code";
            PurchaseLine."Item Reference No." := NonstockItem."Bar Code";
        end;
    end;

    procedure NonStockPurchase(var PurchaseLine2: Record "Purchase Line")
    var
        InvtSetup: Record "Inventory Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if (PurchaseLine2."Document Type" in
            [PurchaseLine2."Document Type"::"Return Order", PurchaseLine2."Document Type"::"Credit Memo"])
        then
            Error(Text002, PurchaseLine2."Document Type");

        NonStock.Get(PurchaseLine2."No.");
        if NonStock."Item No." <> '' then begin
            PurchaseLine2."No." := NonStock."Item No.";
            exit;
        end;

        if not UnitofMeasure.Get(NonStock."Unit of Measure") then begin
            UnitofMeasure.Code := NonStock."Unit of Measure";
            UnitofMeasure.Insert();
        end;

        NewItem.SetRange("Vendor Item No.", NonStock."Vendor Item No.");
        if NewItem.FindFirst() then begin
            NonStock."Item No." := NewItem."No.";
            NonStock.Modify();
            PurchaseLine2."No." := NewItem."No.";
            exit;
        end;
        ProgWindow.Open(Text003 +
          Text004 +
          Text005 +
          Text006 +
          Text007);
        ProgWindow.Update(1, NonStock."Manufacturer Code");
        ProgWindow.Update(2, NonStock."Vendor No.");
        ProgWindow.Update(3, NonStock."Vendor Item No.");
        ProgWindow.Update(4, PurchaseLine2."No.");
        InvtSetup.Get();
        InvtSetup.TestField("Item Nos.");
        NoSeriesMgt.InitSeries(InvtSetup."Item Nos.", NewItem."No. Series", 0D, NewItem."No.", NewItem."No. Series");
        NewItem.Description := NonStock.Description;
        NewItem.Validate(Description, NewItem.Description);
        if not ItemUnitofMeasure.Get(NewItem."No.", NonStock."Unit of Measure") then begin
            ItemUnitofMeasure."Item No." := NewItem."No.";
            ItemUnitofMeasure.Code := NonStock."Unit of Measure";
            ItemUnitofMeasure."Qty. per Unit of Measure" := 1;
            ItemUnitofMeasure.Insert();
        end;
        NewItem.Validate("Base Unit of Measure", NonStock."Unit of Measure");
        NewItem."Unit Price" := NonStock."Unit Price";
        if NonStock."Negotiated Cost" <> 0 then
            NewItem."Last Direct Cost" := NonStock."Negotiated Cost"
        else
            NewItem."Last Direct Cost" := NonStock."Published Cost";
        NewItem."Automatic Ext. Texts" := false;
        if NewItem."Costing Method" = NewItem."Costing Method"::Standard then
            NewItem."Standard Cost" := NonStock."Negotiated Cost";
        NewItem."Vendor No." := NonStock."Vendor No.";
        NewItem."Vendor Item No." := NonStock."Vendor Item No.";
        NewItem."Net Weight" := NonStock."Net Weight";
        NewItem."Gross Weight" := NonStock."Gross Weight";
        NewItem."Manufacturer Code" := NonStock."Manufacturer Code";
        NewItem."Item Category Code" := NonStock."Item Template Code";
        NewItem."Created From Nonstock Item" := true;
        NewItem."Unit Price" := NonStock."Unit Price";
        NewItem.Insert();

        PurchaseLine2."No." := NewItem."No.";

        NonStock."Item No." := NewItem."No.";
        NonStock.Modify();

        if CheckLicensePermission(DATABASE::"Item Vendor") then
            NonstockItemVend(NonStock);
        if CheckLicensePermission(DATABASE::"Item Reference") then
            NonstockItemRef(NonStock);

        ProgWindow.Close();

    end;

    local procedure CheckLicensePermission(TableID: Integer): Boolean
    var
        LicensePermission: Record "License Permission";
    begin
        LicensePermission.SetRange("Object Type", LicensePermission."Object Type"::TableData);
        LicensePermission.SetRange("Object Number", TableID);
        LicensePermission.SetFilter("Insert Permission", '<>%1', LicensePermission."Insert Permission"::" ");
        exit(LicensePermission.FindFirst());
    end;

    local procedure NonstockItemVend(NonStock2: Record "Nonstock Item")
    begin
        ItemVend.SetRange("Item No.", NonStock2."Item No.");
        ItemVend.SetRange("Vendor No.", NonStock2."Vendor No.");
        if ItemVend.FindFirst() then
            exit;

        ItemVend."Item No." := NonStock2."Item No.";
        ItemVend."Vendor No." := NonStock2."Vendor No.";
        ItemVend."Vendor Item No." := NonStock2."Vendor Item No.";
        ItemVend.Insert(true);
    end;

    local procedure NonstockItemRef(var NonStock2: Record "Nonstock Item")
    var
        ItemReference: Record "Item Reference";
    begin
        ItemReference.SetRange("Item No.", NonStock2."Item No.");
        ItemReference.SetRange("Unit of Measure", NonStock2."Unit of Measure");
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::Vendor);
        ItemReference.SetRange("Reference Type No.", NonStock2."Vendor No.");
        ItemReference.SetRange("Reference No.", NonStock2."Vendor Item No.");
        if not ItemReference.FindFirst() then begin
            ItemReference.Init();
            ItemReference.Validate("Item No.", NonStock2."Item No.");
            ItemReference.Validate("Unit of Measure", NonStock2."Unit of Measure");
            ItemReference.Validate("Reference Type", ItemReference."Reference Type"::Vendor);
            ItemReference.Validate("Reference Type No.", NonStock2."Vendor No.");
            ItemReference.Validate("Reference No.", NonStock2."Vendor Item No.");
            ItemReference.Insert();
        end;
        if NonStock2."Bar Code" <> '' then begin
            ItemReference.Reset();
            ItemReference.SetRange("Item No.", NonStock2."Item No.");
            ItemReference.SetRange("Unit of Measure", NonStock2."Unit of Measure");
            ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
            ItemReference.SetRange("Reference No.", NonStock2."Bar Code");
            if not ItemReference.FindFirst() then begin
                ItemReference.Init();
                ItemReference.Validate("Item No.", NonStock2."Item No.");
                ItemReference.Validate("Unit of Measure", NonStock2."Unit of Measure");
                ItemReference.Validate("Reference Type", ItemReference."Reference Type"::"Bar Code");
                ItemReference.Validate("Reference No.", NonStock2."Bar Code");
                ItemReference.Insert();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, 54, 'OnAfterActionEvent', 'NPR Nonstockitems', true, true)]
    local procedure OnAfterNonstockitems(var Rec: Record "Purchase Line")
    begin
        ShowNonstock(Rec, '');
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnBeforeValidateEvent', 'Item Reference No.', false, false)]
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

