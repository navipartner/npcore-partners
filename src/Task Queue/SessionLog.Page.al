page 6059908 "NPR Session Log"
{
    // TQ1.29/JDH /20161101 CASE 242044 Shows Session logins, and the master thread logout as well
    // TQ1.31/BR /20171109 CASE 295987 Added field Error Message

    Caption = 'Session Log';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Session Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Log Type"; "Log Type")
                {
                    ApplicationArea = All;
                }
                field("Log Time"; "Log Time")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Task Worker Group"; "Task Worker Group")
                {
                    ApplicationArea = All;
                }
                field("Server Instance ID"; "Server Instance ID")
                {
                    ApplicationArea = All;
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                }
                field("Error Message"; "Error Message")
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

