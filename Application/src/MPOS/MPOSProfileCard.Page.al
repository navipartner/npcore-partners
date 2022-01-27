page 6150698 "NPR MPOS Profile Card"
{
    Extensible = False;
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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Ticket Admission Web Url"; Rec."Ticket Admission Web Url")
                {

                    ToolTip = 'Specifies the value of the Ticket Admission Web Url field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }


}
