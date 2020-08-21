page 6060088 "MM Member Arrival Log"
{
    // MM1.21/TSA /20170721 CASE 284653 First Version

    Caption = 'Member Arrival Log';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "MM Member Arrival Log Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Event Type"; "Event Type")
                {
                    ApplicationArea = All;
                }
                field("Created At"; "Created At")
                {
                    ApplicationArea = All;
                }
                field("Local Date"; "Local Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Local Time"; "Local Time")
                {
                    ApplicationArea = All;
                }
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                }
                field("External Member No."; "External Member No.")
                {
                    ApplicationArea = All;
                }
                field("External Card No."; "External Card No.")
                {
                    ApplicationArea = All;
                }
                field("Scanner Station Id"; "Scanner Station Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = All;
                }
                field("Response Type"; "Response Type")
                {
                    ApplicationArea = All;
                }
                field("Response Code"; "Response Code")
                {
                    ApplicationArea = All;
                }
                field("Response Rule Entry No."; "Response Rule Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Response Message"; "Response Message")
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

