table 6059864 "NPR Sales Stat Buffer Table"
{
    Caption = 'Buffer Table';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Decimal Field 1"; Decimal)
        {
            Caption = 'Decimal Field 1';
            DataClassification = CustomerContent;
        }
        field(11; "Decimal Field 2"; Decimal)
        {
            Caption = 'Decimal Field 2';
            DataClassification = CustomerContent;
        }
        field(12; "Decimal Field 3"; Decimal)
        {
            Caption = 'Decimal Field 3';
            DataClassification = CustomerContent;
        }
        field(13; "Decimal Field 4"; Decimal)
        {
            Caption = 'Decimal Field 4';
            DataClassification = CustomerContent;
        }
        field(14; "Decimal Field 5"; Decimal)
        {
            Caption = 'Decimal Field 5';
            DataClassification = CustomerContent;
        }
        field(15; "Decimal Field 6"; Decimal)
        {
            Caption = 'Decimal Field 6';
            DataClassification = CustomerContent;
        }
        field(16; "Decimal Field 7"; Decimal)
        {
            Caption = 'Decimal Field 7';
            DataClassification = CustomerContent;
        }
        field(17; "Decimal Field 8"; Decimal)
        {
            Caption = 'Decimal Field 8';
            DataClassification = CustomerContent;
        }
        field(18; "Decimal Field 9"; Decimal)
        {
            Caption = 'Decimal Field 9';
            DataClassification = CustomerContent;
        }
        field(19; "Decimal Field 10"; Decimal)
        {
            Caption = 'Decimal Field 10';
            DataClassification = CustomerContent;
        }

    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
