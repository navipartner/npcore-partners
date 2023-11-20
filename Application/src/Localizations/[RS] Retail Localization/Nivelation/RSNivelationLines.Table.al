table 6060000 "NPR RS Nivelation Lines"
{
    DataClassification = CustomerContent;
    Caption = 'Nivelation Document Subform';
    Access = Internal;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR RS Nivelation Header"."No.";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                Item.SetRange("Location Filter", "Location Code");
                Item.SetRange("Variant Filter", "Variant Code");
                if not Item.Get("Item No.") then
                    exit;
                SetItemFields(Item);
            end;
        }
        field(4; "Item Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; "Variant Code"; Code[20])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
            trigger OnValidate()
            begin
                Validate("Item No.");
            end;
        }
        field(6; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location.Code;
        }
        field(7; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(8; "UOM Code"; Code[20])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
        }
        field(9; "Old Price"; Decimal)
        {
            Caption = 'Old Price';
            DataClassification = CustomerContent;
        }
        field(10; "New Price"; Decimal)
        {
            Caption = 'New Price';
            DataClassification = CustomerContent;
        }
        field(11; "Price Difference"; Decimal)
        {
            Caption = 'Price Difference';
            DataClassification = CustomerContent;
        }
        field(12; "Old Value"; Decimal)
        {
            Caption = 'Old Value';
            DataClassification = CustomerContent;
        }
        field(13; "New Value"; Decimal)
        {
            Caption = 'New Value';
            DataClassification = CustomerContent;
        }
        field(14; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DataClassification = CustomerContent;
        }
        field(15; "Calculated VAT"; Decimal)
        {
            Caption = 'Calculated VAT';
            DataClassification = CustomerContent;
        }
        field(16; "Value Difference"; Decimal)
        {
            Caption = 'Value Difference';
            DataClassification = CustomerContent;
        }
        field(17; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(18; "VAT Bus. Posting Gr. (Price)"; Code[20])
        {
            Caption = 'VAT Bus. Posting Gr. (Price)';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        CalcDifference();
    end;

    local procedure SetItemFields(Item: Record Item)
    var
        VATSetup: Record "VAT Posting Setup";
    begin
        "Item Description" := Item.Description;
        "UOM Code" := Item."Base Unit of Measure";
        if not VATSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then
            exit;
        "VAT %" := VATSetup."VAT %";
    end;

    procedure CalcDifference()
    var
        VATBreakDown: Decimal;
    begin
        if Rec."New Price" = 0 then
            exit;
        Rec."New Value" := Rec."New Price" * Rec.Quantity;
        Rec."Price Difference" := Rec."New Price" - Rec."Old Price";
        Rec."Value Difference" := Rec."New Value" - Rec."Old Value";
        VATBreakDown := (100 * "VAT %") / (100 + "VAT %") / 100;
        Rec."Calculated VAT" := "Value Difference" * VATBreakDown;
    end;

    procedure SetItemLedgerEntryQty(Item: Record Item)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetRange("Item No.", Item."No.");
        ItemLedgerEntry.SetFilter("Posting Date", '..%1', CalcDate('<-1D>', Rec."Posting Date"));
        if Rec."Variant Code" <> '' then
            ItemLedgerEntry.SetRange("Variant Code", Rec."Variant Code");
        if Rec."Location Code" <> '' then
            ItemLedgerEntry.SetRange("Location Code", Rec."Location Code");
        ItemLedgerEntry.CalcSums("Remaining Quantity");
        Quantity := ItemLedgerEntry."Remaining Quantity";
    end;

    procedure GetInitialLine(NivelationHeader: Record "NPR RS Nivelation Header"): Integer
    var
        NivelationLines: Record "NPR RS Nivelation Lines";
        LineNo: Integer;
    begin
        LineNo := 10000;

        NivelationLines.SetRange("Document No.", NivelationHeader."No.");
        if NivelationLines.FindLast() then
            LineNo += NivelationLines."Line No.";

        exit(LineNo);
    end;
}