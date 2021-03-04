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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Restaurant Code field';
                }
                field("Default Seating Location"; Rec."Default Seating Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Seating Location field';
                }
            }
        }
    }
}
