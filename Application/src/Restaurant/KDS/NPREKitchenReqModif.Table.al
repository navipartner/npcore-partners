table 6150787 "NPR NPRE Kitchen Req. Modif."
{
    Access = Internal;
    Caption = 'Kitchen Request Modification';
    DataClassification = CustomerContent;
    LookupPageId = "NPR NPRE Kitchen Req. Modif.";
    DrillDownPageId = "NPR NPRE Kitchen Req. Modif.";

    fields
    {
        field(1; "Request No."; BigInteger)
        {
            Caption = 'Request No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Kitchen Request";
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Line Type"; Enum "NPR POS Sale Line Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            InitValue = Item;
            ValuesAllowed = Item, Comment;
        }
        field(20; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Line Type" = const(Item)) Item."No.";
        }
        field(30; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = if ("Line Type" = const(Item)) "Item Variant".Code where("Item No." = field("No."));
        }
        field(40; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(50; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
        }
        field(60; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(100; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(140; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = if ("Line Type" = const(Item), "No." = filter(<> '')) "Item Unit of Measure".Code where("Item No." = field("No."));
        }
        field(150; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(160; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Request No.", "Line No.") { }
    }
}
