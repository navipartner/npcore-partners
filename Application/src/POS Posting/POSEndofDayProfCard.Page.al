page 6150752 "NPR POS End of Day Prof. Card"
{
    Extensible = False;
    Caption = 'NPR POS End of Day Profile Card';
    PageType = Card;
    SourceTable = "NPR POS End of Day Profile";
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

                field("End of Day Frequency"; Rec."End of Day Frequency")
                {
                    ToolTip = 'Specifies how often the end of day process is required.';
                    ApplicationArea = NPRRetail;
                }
                field("End of Day Type"; Rec."End of Day Type")
                {
                    ToolTip = 'Specifies the value of the End of Day Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Master POS Unit No."; Rec."Master POS Unit No.")
                {
                    ToolTip = 'Specifies the value of the Master POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Z-Report UI"; Rec."Z-Report UI")
                {
                    ToolTip = 'Specifies the value of the Z-Report UI field';
                    ApplicationArea = NPRRetail;
                }
                field("X-Report UI"; Rec."X-Report UI")
                {
                    ToolTip = 'Specifies the value of the X-Report UI field';
                    ApplicationArea = NPRRetail;
                }
                field("Close Workshift UI"; Rec."Close Workshift UI")
                {
                    ToolTip = 'Specifies the value of the Close Workshift UI field';
                    ApplicationArea = NPRRetail;
                }
                field("User Experience"; Rec."User Experience")
                {
                    ToolTip = 'Specifies which platform will show the End of Day user interface.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Force Blind Counting"; Rec."Force Blind Counting")
                {
                    ToolTip = 'Specifies the value of the Force Blind Counting field';
                    ApplicationArea = NPRRetail;
                }
                field("SMS Profile"; Rec."SMS Profile")
                {
                    ToolTip = 'Specifies the value of the SMS Profile field';
                    ApplicationArea = NPRRetail;
                }
                field("Z-Report Number Series"; Rec."Z-Report Number Series")
                {
                    ToolTip = 'Specifies the value of the Z-Report Number Series field';
                    ApplicationArea = NPRRetail;
                }
                field("X-Report Number Series"; Rec."X-Report Number Series")
                {
                    ToolTip = 'Specifies the value of the X-Report Number Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Show Zero Amount Lines"; Rec."Show Zero Amount Lines")
                {
                    ToolTip = 'Specifies the value of the Show Zero Amount Lines field';
                    ApplicationArea = NPRRetail;
                }
                field("Hide Turnover Section"; Rec."Hide Turnover Section")
                {
                    ToolTip = 'Specifies the value of the Hide Turnover Section field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
