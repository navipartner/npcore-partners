table 6014585 "NPR Advanced Sales Statistics"
{
    Caption = 'Advanced Sales Statistics';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Period Start"; Date)
        {
            Caption = 'Period start';
            DataClassification = CustomerContent;
        }
        field(4; "Primary Key Length"; Integer)
        {
            Caption = 'Primary Key Length';
            DataClassification = CustomerContent;
        }
        field(5; "Sales qty."; Decimal)
        {
            Caption = 'Sales qty.';
            DataClassification = CustomerContent;
        }
        field(6; "Sales qty. last year"; Decimal)
        {
            Caption = 'Sales qty. last year';
            DataClassification = CustomerContent;
        }
        field(7; "Sales LCY"; Decimal)
        {
            Caption = 'Sales LCY';
            DataClassification = CustomerContent;
        }
        field(8; "Sales LCY last year"; Decimal)
        {
            Caption = 'Sales LCY. last year';
            DataClassification = CustomerContent;
        }
        field(9; "Profit LCY"; Decimal)
        {
            Caption = 'Profit LCY';
            DataClassification = CustomerContent;
        }
        field(10; "Profit LCY last year"; Decimal)
        {
            Caption = 'Profit LCY last year';
            DataClassification = CustomerContent;
        }
        field(11; "Profit %"; Decimal)
        {
            Caption = 'Profit %';
            DataClassification = CustomerContent;
        }
        field(12; "Profit % last year"; Decimal)
        {
            Caption = 'Profit % last year';
            DataClassification = CustomerContent;
        }
        field(13; "Date 1"; Date)
        {
            Caption = 'Date 1';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; Description)
        {
        }
        key(Key3; "Period Start")
        {
        }
        key(Key4; "Sales qty.")
        {
        }
        key(Key5; "Sales qty. last year")
        {
        }
        key(Key6; "Sales LCY")
        {
        }
        key(Key7; "Sales LCY last year")
        {
        }
        key(Key8; "Profit LCY")
        {
        }
        key(Key9; "Profit LCY last year")
        {
        }
        key(Key10; "Profit %")
        {
        }
        key(Key11; "Profit % last year")
        {
        }
        key(Key12; "Date 1")
        {
        }
    }

    fieldgroups
    {
    }
}

