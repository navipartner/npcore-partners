table 6150688 "NPR RS KEP Book"
{
    Access = Internal;
    Caption = 'KEP Book';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Source Entry No."; Integer)
        {
            Caption = 'Source Entry No.';
            DataClassification = CustomerContent;
        }
        field(20; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
        field(30; Year; Integer)
        {
            Caption = 'Year';
            DataClassification = CustomerContent;
        }
        field(40; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(50; "Document Type"; Enum "Item Ledger Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(60; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(70; "Debit Amount"; Decimal)
        {
            Caption = 'Debit Amount';
            DataClassification = CustomerContent;
        }
        field(80; "Credit Amount"; Decimal)
        {
            Caption = 'Credit Amount';
            DataClassification = CustomerContent;
        }
        field(90; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(100; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(110; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = CustomerContent;
        }
        field(120; Description; Text[250])
        {
            Caption = 'Description';
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