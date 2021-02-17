table 6060084 "NPR MCS Recommendations Line"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'On February 15, 2018, “Recommendations API is no longer under active development”';
    Caption = 'MCS Recommendations Line';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(20; "Model No."; Code[10])
        {
            Caption = 'Model No.';
            DataClassification = CustomerContent;
        }
        field(30; "Log Entry No."; Integer)
        {
            Caption = 'Log Entry No.';
            DataClassification = CustomerContent;
        }
        field(50; "Seed Item No."; Code[20])
        {
            Caption = 'Seed Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(100; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(110; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(120; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(130; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = CustomerContent;
        }
        field(140; "Register No."; Code[10])
        {
            Caption = 'Register No.';
            DataClassification = CustomerContent;
        }
        field(150; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(160; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(200; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            ValidateTableRelation = false;
        }
        field(210; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(220; Rating; Decimal)
        {
            AutoFormatExpression = '<precision,0:2><Standard Format,0>%';
            AutoFormatType = 10;
            Caption = 'Rating';
            DataClassification = CustomerContent;
        }
        field(300; "Date Time"; DateTime)
        {
            Caption = 'Date Time';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Table No.", "Document Type", "Document No.", "Document Line No.", Rating)
        {
        }
        key(Key3; "Seed Item No.", Rating)
        {
        }
    }
}

