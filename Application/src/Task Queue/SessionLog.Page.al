page 6059908 "NPR Session Log"
{
    Extensible = False;
    // TQ1.29/JDH /20161101 CASE 242044 Shows Session logins, and the master thread logout as well
    // TQ1.31/BR /20171109 CASE 295987 Added field Error Message

    Caption = 'Session Log';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Session Log";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Log Type"; Rec."Log Type")
                {

                    ToolTip = 'Specifies the value of the Entry Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Log Time"; Rec."Log Time")
                {

                    ToolTip = 'Specifies the value of the Starting Time field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Task Worker Group"; Rec."Task Worker Group")
                {

                    ToolTip = 'Specifies the value of the Task Worker Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Server Instance ID"; Rec."Server Instance ID")
                {

                    ToolTip = 'Specifies the value of the Server Instance ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Company Name"; Rec."Company Name")
                {

                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Error Message"; Rec."Error Message")
                {

                    ToolTip = 'Specifies the value of the Error Message field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

