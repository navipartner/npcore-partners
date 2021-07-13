page 6059947 "NPR Sales Price Maint. Groups"
{
    Caption = 'Sales Price Maintenance Groups';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Sales Price Maint. Groups2";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item Category Code"; Rec."Item Category Code")
                {

                    ToolTip = 'Specifies the value of the Item Category Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

