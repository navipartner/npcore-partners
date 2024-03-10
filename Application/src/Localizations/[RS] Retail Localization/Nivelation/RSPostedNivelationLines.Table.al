table 6060008 "NPR RS Posted Nivelation Lines"
{
    Caption = 'Posted Nivelation Lines';
    DataClassification = CustomerContent;
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
        }
        field(6; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
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

    procedure GetInitialLine(): Integer
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Line No.")))
    end;
}