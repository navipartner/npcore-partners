table 6151606 "NPR NpDc Ext. Coupon Buffer"
{
    Access = Internal;
    Caption = 'NpDc Ext. Coupon Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            Editable = false;
            NotBlank = true;
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(15; "Reference No."; Text[50])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
        }
        field(20; "Coupon Type"; Code[20])
        {
            Caption = 'Coupon Type';
            DataClassification = CustomerContent;
        }
        field(25; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(35; "Starting Date"; DateTime)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(40; "Ending Date"; DateTime)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
        field(45; Open; Boolean)
        {
            Caption = 'Open';
            DataClassification = CustomerContent;
        }
        field(50; "Remaining Quantity"; Decimal)
        {
            Caption = 'Remaining Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(55; "In-use Quantity"; Integer)
        {
            Caption = 'In-use Quantity';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
        }
    }
}
