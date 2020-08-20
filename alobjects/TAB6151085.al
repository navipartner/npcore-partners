table 6151085 "RIS Retail Inventory Set"
{
    // NPR5.40/MHA /20180320  CASE 307025 Object created - Retail Inventory Set

    Caption = 'Retail Inventory Set';
    DataClassification = CustomerContent;
    DrillDownPageID = "RIS Retail Inventory Sets";
    LookupPageID = "RIS Retail Inventory Sets";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        RetailInventorySetEntry: Record "RIS Retail Inventory Set Entry";
    begin
        RetailInventorySetEntry.SetRange("Set Code", Code);
        if RetailInventorySetEntry.FindFirst then
            RetailInventorySetEntry.DeleteAll;
    end;
}

