page 6059976 "NPR Variant per Location"
{
    // NPR5.28/JDH /20161128 CASE 255961 Updated Layout

    Caption = 'Variant per Location';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    UsageCategory = Administration;
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
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    AssistEdit = false;
                    Lookup = false;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    AssistEdit = false;
                    Lookup = false;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
            }
        }
    }

    actions
    {
    }
}

