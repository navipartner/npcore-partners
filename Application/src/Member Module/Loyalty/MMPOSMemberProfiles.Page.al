page 6184631 "NPR MM POS Member Profiles"
{
    Extensible = false;
    ApplicationArea = NPRRetail;
    Caption = 'POS Member Profiles';
    UsageCategory = Administration;
    PageType = List;
    Editable = false;
    SourceTable = "NPR MM POS Member Profile";
    CardPageID = "NPR MM POS Member Profile";


    layout
    {
        area(content)
        {
            repeater(General)
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

                field("Print Membership On Sale"; Rec."Print Membership On Sale")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if a membership is going to be printed after the end of the pos sale.';
                }
            }
        }
    }
}