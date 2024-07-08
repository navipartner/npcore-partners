page 6184637 "NPR MM POS Loyalty Profiles"
{
    Extensible = false;
    ApplicationArea = NPRRetail;
    Caption = 'POS Loyalty Profiles';
    UsageCategory = Administration;
    PageType = List;
    Editable = false;
    SourceTable = "NPR MM POS Loyalty Profile";
    CardPageID = "NPR MM POS Loyalty Profile";


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
                field("Assign Loyalty On Sale"; Rec."Assign Loyalty On Sale")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if loyalty points are going to be generated after the end of the pos sale.';
                }
            }
        }
    }
}