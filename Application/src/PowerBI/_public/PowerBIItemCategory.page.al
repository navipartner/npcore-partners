page 6184611 NPRPowerBIItemCategory
{
    PageType = List;
    Caption = 'PowerBI Item Category';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Item Category";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the code for the item category.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the item category.';
                    ApplicationArea = All;
                }
                field("Parent Category"; Rec."Parent Category")
                {
                    ToolTip = 'Specifies the item category that this item category belongs to. Item attributes that are assigned to a parent item category also apply to the child item category.';
                    ApplicationArea = All;
                }
            }
        }
    }
}