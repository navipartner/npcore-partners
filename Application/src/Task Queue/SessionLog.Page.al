page 6059908 "NPR Session Log"
{
    // TQ1.29/JDH /20161101 CASE 242044 Shows Session logins, and the master thread logout as well
    // TQ1.31/BR /20171109 CASE 295987 Added field Error Message

    Caption = 'Session Log';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Session Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Log Type"; Rec."Log Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Type field';
                }
                field("Log Time"; Rec."Log Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Time field';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Task Worker Group"; Rec."Task Worker Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Worker Group field';
                }
                field("Server Instance ID"; Rec."Server Instance ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Server Instance ID field';
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Message field';
                }
            }
        }
    }

    actions
    {
    }
}

