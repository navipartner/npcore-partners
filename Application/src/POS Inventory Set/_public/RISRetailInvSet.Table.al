table 6151085 "NPR RIS Retail Inv. Set"
{
    Caption = 'Retail Inventory Set';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR RIS Retail Inv. Sets";
    LookupPageID = "NPR RIS Retail Inv. Sets";

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
        field(20; "Client Type"; Option)
        {
            Caption = 'Client Type';
            DataClassification = CustomerContent;
            OptionMembers = SOAP,OData,API;
            OptionCaption = 'SOAP,OData,API';

            trigger OnValidate()
            var
                RetailInvSetMgt: Codeunit "NPR RIS Retail Inv. Set Mgt.";
            begin
                RetailInvSetMgt.ResetInventorySetEntriesAPIValues(Rec);
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    trigger OnDelete()
    var
        RetailInventorySetEntry: Record "NPR RIS Retail Inv. Set Entry";
    begin
        RetailInventorySetEntry.SetRange("Set Code", Code);
        if not RetailInventorySetEntry.IsEmpty() then
            RetailInventorySetEntry.DeleteAll();
    end;
}
