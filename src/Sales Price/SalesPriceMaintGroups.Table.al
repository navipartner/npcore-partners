table 6059782 "NPR Sales Price Maint. Groups"
{
    // NPR5.33/CLVA/20170607 CASE 272906 : Sales Price Groups
    // NPR5.48/TJ  /20181106 CASE 331261 Length property of field Description changed from 30 to 50

    Caption = 'Sales Price Maintenance Groups';
    DrillDownPageID = "NPR Sales Price Maint. Groups";
    LookupPageID = "NPR Sales Price Maint. Groups";

    fields
    {
        field(1; Id; Integer)
        {
            Caption = 'Id';
            TableRelation = "NPR Sales Price Maint. Setup";
        }
        field(2; "Item Group"; Code[10])
        {
            Caption = 'Item Group';
            TableRelation = "NPR Item Group";
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            Editable = false;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
            end;
        }
    }

    keys
    {
        key(Key1; Id, "Item Group")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "Item Group" <> '' then begin
            Clear(ItemGroup);
            ItemGroup.Get("Item Group");
            Description := ItemGroup.Description;
        end;
    end;

    var
        ItemGroup: Record "NPR Item Group";
}

