page 6150791 "NPR User Logins"
{
    Extensible = false;
    Caption = 'User Logins';
    PageType = List;
    SourceTable = "NPR Client Diagnostic v2";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-09-03';
    ObsoleteReason = 'Not used. Using POS Billing API integration to control licenses.';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("User Name"; Rec."User Name")
                {
                    ToolTip = 'Specifies the value of the User Name field.';
                    ApplicationArea = NPRRetail;
                }
                field("Full Name"; Rec."Full Name")
                {
                    ToolTip = 'Specifies the value of the Full Name field.';
                    ApplicationArea = NPRRetail;
                }
                field("User Login Type"; Rec."User Login Type")
                {
                    ToolTip = 'Specifies the value of the User Login Type field.';
                    ApplicationArea = NPRRetail;
                }
                field("Client Diagnostic Last Sent"; Rec."Client Diagnostic Last Sent")
                {
                    Caption = 'Last recorded login';
                    ToolTip = 'Specifies date and time of last recorded login';
                    ApplicationArea = NPRRetail;
                }
                field("Delegated User"; Rec."Delegated User")
                {
                    ToolTip = 'Specifies date and time of Delegated User field.';
                    ApplicationArea = NPRRetail;
                }
                field("User Security ID"; Rec."User Security ID")
                {
                    ToolTip = 'Specifies the value of the User Security ID field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
