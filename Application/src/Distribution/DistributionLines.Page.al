page 6151059 "NPR Distribution Lines"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    AutoSplitKey = true;
    Caption = 'Distribution Lines';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Distribution Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Distribution Line"; "Distribution Line")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Distribution Line field';
                }
                field("Distribution Item"; "Distribution Item")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Distribution Item field';
                }
                field("Item Variant"; "Item Variant")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Variant field';
                }
                field(Location; Location)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Distribution Group Member"; "Distribution Group Member")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Distribution Group Member field';
                }
                field("Action Required"; "Action Required")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Action Required field';
                }
                field("Distribution Quantity"; "Distribution Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Distribution Quantity field';
                }
                field("Avaliable Quantity"; "Avaliable Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Avaliable Quantity field';
                }
                field("Demanded Quantity"; "Demanded Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Demanded Quantity field';
                }
                field("Org. Distribution Quantity"; "Org. Distribution Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Org. Distribution Quantity field';
                }
                field("Distribution Cost Value (LCY)"; "Distribution Cost Value (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Distribution Cost Value (LCY) field';
                }
                field("Date Created"; "Date Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Created field';
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

