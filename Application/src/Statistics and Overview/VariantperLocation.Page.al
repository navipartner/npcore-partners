page 6059976 "NPR Variant per Location"
{
    Caption = 'Variant per Location';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "Inventory Buffer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    AssistEdit = false;
                    Lookup = false;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    AssistEdit = false;
                    Lookup = false;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
            }
        }
    }

}

