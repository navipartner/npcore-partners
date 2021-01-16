page 6059947 "NPR Sales Price Maint. Groups"
{
    // NPR5.33/NPKNAV/20170630  CASE 272906 Transport NPR5.33 - 30 June 2017

    Caption = 'Sales Price Maintenance Groups';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Sales Price Maint. Groups";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item Group"; "Item Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Group field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }

    actions
    {
    }
}

