page 6184636 "NPR MM POS Loyalty Profile"
{
    Extensible = false;
    Caption = 'POS Loyalty Profile';
    PageType = Card;
    SourceTable = "NPR MM POS Loyalty Profile";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Assign Loyalty On Sale"; Rec."Assign Loyalty On Sale")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if loyalty points are going to be generated after the end of the pos sale.';
                }

            }
        }
    }
}