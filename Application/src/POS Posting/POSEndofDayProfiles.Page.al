page 6150637 "NPR POS End of Day Profiles"
{
    Caption = 'POS End of Day Profile';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS End of Day Profile";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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

                field("End of Day Frequency"; Rec."End of Day Frequency")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how often the end of day process is required.';
                }
                field("End of Day Type"; Rec."End of Day Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End of Day Type field';
                }
                field("Master POS Unit No."; Rec."Master POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Master POS Unit No. field';
                }
                field("Z-Report UI"; Rec."Z-Report UI")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Z-Report UI field';
                }
                field("X-Report UI"; Rec."X-Report UI")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the X-Report UI field';
                }
                field("Close Workshift UI"; Rec."Close Workshift UI")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Close Workshift UI field';
                }
                field("Force Blind Counting"; Rec."Force Blind Counting")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Force Blind Counting field';
                }
                field("SMS Profile"; Rec."SMS Profile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SMS Profile field';
                }
                field("Z-Report Number Series"; Rec."Z-Report Number Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Z-Report Number Series field';
                }
                field("X-Report Number Series"; Rec."X-Report Number Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the X-Report Number Series field';
                }
                field("Show Zero Amount Lines"; Rec."Show Zero Amount Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Zero Amount Lines field';
                }
                field("Posting Error Handling"; Rec."Posting Error Handling")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Error Handling field';
                }
            }
        }
    }

    actions
    {
    }
}

