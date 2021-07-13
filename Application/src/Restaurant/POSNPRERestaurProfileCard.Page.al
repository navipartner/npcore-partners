page 6150743 "NPR POS Restaur. Profile Card"
{
    Caption = 'POS Restaur. Profile';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR POS NPRE Rest. Profile";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {

                    ToolTip = 'Specifies the value of the Restaurant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Seating Location"; Rec."Default Seating Location")
                {

                    ToolTip = 'Specifies the value of the Default Seating Location field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
