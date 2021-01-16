page 6060062 "NPR Item Category Mapping"
{
    // NPR5.39/NPKNAV/20180223  CASE 295322 Transport NPR5.39 - 23 February 2018
    // NPR5.45/RA  /20180802  CASE 295322 Added field "Item Material"
    // NPR5.45/RA  /20180827  CASE 325023 Added field "Item Material Density"

    Caption = 'Item Category Mapping';
    PageType = List;
    SourceTable = "NPR Item Category Mapping";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item Category Code"; "Item Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Category Code field';
                }
                field("Item Material"; "Item Material")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Material field';
                }
                field("Item Material Density"; "Item Material Density")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Material Density field';
                }
                field("Item Group"; "Item Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Group field';
                }
            }
        }
    }

    actions
    {
    }
}

