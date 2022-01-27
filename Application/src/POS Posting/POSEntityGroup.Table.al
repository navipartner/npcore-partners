table 6150649 "NPR POS Entity Group"
{
    Access = Internal;
    Caption = 'POS Entity Group';
    DataClassification = CustomerContent;
    LookupPageID = "NPR POS Entity Groups";

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(3; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(4; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Sorting"; Decimal)
        {
            Caption = 'Sorting';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key(Key1; "Table ID", "Field No.", "Code")
        {
        }
        key(Key2; "Table ID", Sorting)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description)
        {
        }
    }
}

