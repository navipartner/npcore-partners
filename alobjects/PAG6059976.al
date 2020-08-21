page 6059976 "Variant per Location"
{
    // NPR5.28/JDH /20161128 CASE 255961 Updated Layout

    Caption = 'Variant per Location';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    SourceTable = "Inventory Buffer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    AssistEdit = false;
                    Lookup = false;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    AssistEdit = false;
                    Lookup = false;
                }
            }
        }
    }

    actions
    {
    }
}

