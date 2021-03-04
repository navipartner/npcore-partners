page 6150698 "NPR MPOS Profile Card"
{
    Caption = 'MPOS Profile';
    PageType = Card;
    SourceTable = "NPR MPOS Profile";
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Ticket Admission Web Url"; Rec."Ticket Admission Web Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Admission Web Url field';
                }
            }
        }
    }


}
