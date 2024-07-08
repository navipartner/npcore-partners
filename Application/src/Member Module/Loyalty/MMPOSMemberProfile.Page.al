page 6184630 "NPR MM POS Member Profile"
{
    Extensible = false;
    Caption = 'POS Member Profile';
    PageType = Card;
    SourceTable = "NPR MM POS Member Profile";
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
                field("Send Notification On Sale"; Rec."Send Notification On Sale")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if member notifications are going to be send after the end of the pos sale.';
                }
            }
            group(Print)
            {
                field("Print Membership On Sale"; Rec."Print Membership On Sale")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if a membership is going to be printed after the end of the pos sale.';
                }
            }
        }
    }
}