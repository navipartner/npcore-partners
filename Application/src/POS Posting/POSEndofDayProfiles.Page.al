page 6150637 "NPR POS End of Day Profiles"
{
    Caption = 'POS End of Day Profile';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR POS End of Day Profile";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("End of Day Type"; "End of Day Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End of Day Type field';
                }
                field("Master POS Unit No."; "Master POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Master POS Unit No. field';
                }
                field("Z-Report UI"; "Z-Report UI")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Z-Report UI field';
                }
                field("X-Report UI"; "X-Report UI")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the X-Report UI field';
                }
                field("Close Workshift UI"; "Close Workshift UI")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Close Workshift UI field';
                }
                field("Force Blind Counting"; "Force Blind Counting")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Force Blind Counting field';
                }
                field("SMS Profile"; "SMS Profile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SMS Profile field';
                }
                field("Z-Report Number Series"; "Z-Report Number Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Z-Report Number Series field';
                }
                field("X-Report Number Series"; "X-Report Number Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the X-Report Number Series field';
                }
                field("Show Zero Amount Lines"; "Show Zero Amount Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Zero Amount Lines field';
                }
                field("Posting Error Handling"; "Posting Error Handling")
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

