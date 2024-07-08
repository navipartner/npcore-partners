table 6150837 "NPR RS Ret. Value Entry Mapp."
{
    Access = Internal;
    Caption = 'RS Retail Value Entry Mapping';
    DataClassification = CustomerContent;
    LookupPageId = "NPR RS Ret. Value Entry Mapp.";
    DrillDownPageId = "NPR RS Ret. Value Entry Mapp.";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "Value Entry";
        }
        field(2; "Entry Type"; Enum "Cost Entry Type")
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
        }
        field(3; "Document Type"; Enum "Item Ledger Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(5; "Item Ledger Entry Type"; Enum "Item Ledger Entry Type")
        {
            Caption = 'Item Ledger Entry Type';
            DataClassification = CustomerContent;
        }
        field(6; "Item Ledger Entry No."; Integer)
        {
            Caption = 'Item Ledger Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "Item Ledger Entry";
        }
        field(7; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(8; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(9; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(10; "Retail Calculation"; Boolean)
        {
            Caption = 'Retail Calculation';
            DataClassification = CustomerContent;
        }
        field(11; Nivelation; Boolean)
        {
            Caption = 'Nivelation';
            DataClassification = CustomerContent;
        }
        field(12; "COGS Correction"; Boolean)
        {
            Caption = 'COGS Correction';
            DataClassification = CustomerContent;
        }
        field(13; "Standard Correction"; Boolean)
        {
            Caption = 'Standard Correction';
            DataClassification = CustomerContent;
        }
        field(14; Open; Boolean)
        {
            Caption = 'Open';
            DataClassification = CustomerContent;
        }
        field(15; "Remaining Quantity"; Decimal)
        {
            Caption = 'Remaining Quantity';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}