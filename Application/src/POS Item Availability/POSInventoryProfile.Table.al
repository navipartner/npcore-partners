table 6014637 "NPR POS Inventory Profile"
{
    Access = Internal;
    Caption = 'POS Inventory Profile';
    DataClassification = CustomerContent;
    LookupPageID = "NPR POS Inventory Profiles";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Stockout Warning"; Boolean)
        {
            Caption = 'Stockout Warning';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}
