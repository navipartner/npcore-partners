page 6151059 "Distribution Lines"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    AutoSplitKey = true;
    Caption = 'Distribution Lines';
    PageType = List;
    SourceTable = "Distribution Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Distribution Line"; "Distribution Line")
                {
                    ApplicationArea = All;
                }
                field("Distribution Item"; "Distribution Item")
                {
                    ApplicationArea = All;
                }
                field("Item Variant"; "Item Variant")
                {
                    ApplicationArea = All;
                }
                field(Location; Location)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Distribution Group Member"; "Distribution Group Member")
                {
                    ApplicationArea = All;
                }
                field("Action Required"; "Action Required")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Distribution Quantity"; "Distribution Quantity")
                {
                    ApplicationArea = All;
                }
                field("Avaliable Quantity"; "Avaliable Quantity")
                {
                    ApplicationArea = All;
                }
                field("Demanded Quantity"; "Demanded Quantity")
                {
                    ApplicationArea = All;
                }
                field("Org. Distribution Quantity"; "Org. Distribution Quantity")
                {
                    ApplicationArea = All;
                }
                field("Distribution Cost Value (LCY)"; "Distribution Cost Value (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Date Created"; "Date Created")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
    }
}

