page 6150637 "NPR POS End of Day Profiles"
{
    // NPR5.49/TSA /20190314 CASE 348458 Initial Version
    // NPR5.52/SARA/20190912 CASE 368395 New field 'SMS Profile'
    // NPR5.53/TSA /20191107 CASE 376170 Added number series for Z & X reports
    // NPR5.53/TSA /20191219 CASE 383012 Added field "Show Zero Amount Lines"
    // NPR5.55/TSA /20200511 CASE 401889 Added "Posting Error Handling"

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
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("End of Day Type"; "End of Day Type")
                {
                    ApplicationArea = All;
                }
                field("Master POS Unit No."; "Master POS Unit No.")
                {
                    ApplicationArea = All;
                }
                field("Z-Report UI"; "Z-Report UI")
                {
                    ApplicationArea = All;
                }
                field("X-Report UI"; "X-Report UI")
                {
                    ApplicationArea = All;
                }
                field("Close Workshift UI"; "Close Workshift UI")
                {
                    ApplicationArea = All;
                }
                field("Force Blind Counting"; "Force Blind Counting")
                {
                    ApplicationArea = All;
                }
                field("SMS Profile"; "SMS Profile")
                {
                    ApplicationArea = All;
                }
                field("Z-Report Number Series"; "Z-Report Number Series")
                {
                    ApplicationArea = All;
                }
                field("X-Report Number Series"; "X-Report Number Series")
                {
                    ApplicationArea = All;
                }
                field("Show Zero Amount Lines"; "Show Zero Amount Lines")
                {
                    ApplicationArea = All;
                }
                field("Posting Error Handling"; "Posting Error Handling")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

