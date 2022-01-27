table 6151389 "NPR CS Temp Data"
{
    Access = Internal;

    Caption = 'CS Temp Data';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.';

    fields
    {
        field(1; Id; Code[10])
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Decription 1"; Text[250])
        {
            Caption = 'Decription 1';
            DataClassification = CustomerContent;
        }
        field(11; "Decription 2"; Text[250])
        {
            Caption = 'Decription 2';
            DataClassification = CustomerContent;
        }
        field(12; "Decription 3"; Text[250])
        {
            Caption = 'Decription 3';
            DataClassification = CustomerContent;
        }
        field(13; "Number 1"; Decimal)
        {
            Caption = 'Number 1';
            DataClassification = CustomerContent;
        }
        field(14; "Number 2"; Decimal)
        {
            Caption = 'Number 2';
            DataClassification = CustomerContent;
        }
        field(15; "Number 3"; Decimal)
        {
            Caption = 'Number 3';
            DataClassification = CustomerContent;
        }
        field(100; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(101; "Record Id"; RecordID)
        {
            Caption = 'Record Id';
            DataClassification = CustomerContent;
        }
        field(102; Handled; Boolean)
        {
            Caption = 'Handled';
            DataClassification = CustomerContent;
        }
        field(103; Created; DateTime)
        {
            Caption = 'Created';
            DataClassification = CustomerContent;
        }
        field(104; "Created By"; Code[20])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Id)
        {
        }
    }

    fieldgroups
    {
    }
}

