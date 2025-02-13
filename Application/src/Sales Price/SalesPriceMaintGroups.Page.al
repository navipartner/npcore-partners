page 6059947 "NPR Sales Price Maint. Groups"
{
    Extensible = False;
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
                field(Id; Rec.Id)
                {
                    ToolTip = 'Specifies the value of the Id field.';
                    ApplicationArea = NPRRetail;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {

                    ToolTip = 'Specifies the value of the Item Category Code field. The value specified here should be the parent item category of the item category that you want to filter out.';
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

