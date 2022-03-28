table 6014487 "NPR POS Turnover Calc. Buffer"
{
    Access = Internal;
    DataClassification = CustomerContent;
    TableType = Temporary;
    Caption = 'POS Turnover Calc. Buffer';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; IsHeader; Boolean)
        {
            Caption = 'Indentation';
            DataClassification = CustomerContent;
        }
        field(3; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(4; "This Year"; Text[100])
        {
            Caption = 'This Year';
            DataClassification = CustomerContent;
        }
        field(5; "Last Year"; Text[100])
        {
            Caption = 'Last Year';
            DataClassification = CustomerContent;
        }
        field(6; "Difference %"; Text[100])
        {
            Caption = 'Difference %';
            DataClassification = CustomerContent;
        }
        field(7; "Row Style"; Text[20])
        {
            Caption = 'Row Style';
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
