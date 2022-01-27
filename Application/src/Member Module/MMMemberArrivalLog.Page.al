page 6060088 "NPR MM Member Arrival Log"
{
    Extensible = False;

    Caption = 'Member Arrival Log';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Member Arr. Log Entry";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Event Type"; Rec."Event Type")
                {

                    ToolTip = 'Specifies the value of the Event Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Created At"; Rec."Created At")
                {

                    ToolTip = 'Specifies the value of the Created At field';
                    ApplicationArea = NPRRetail;
                }
                field("Local Date"; Rec."Local Date")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Local Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Local Time"; Rec."Local Time")
                {

                    ToolTip = 'Specifies the value of the Local Time field';
                    ApplicationArea = NPRRetail;
                }
                field("External Membership No."; Rec."External Membership No.")
                {

                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Member No."; Rec."External Member No.")
                {

                    ToolTip = 'Specifies the value of the External Member No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Card No."; Rec."External Card No.")
                {

                    ToolTip = 'Specifies the value of the External Card No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Scanner Station Id"; Rec."Scanner Station Id")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Scanner Station Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Admission Code"; Rec."Admission Code")
                {

                    ToolTip = 'Specifies the value of the Admission Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Response Type"; Rec."Response Type")
                {

                    ToolTip = 'Specifies the value of the Response Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Response Code"; Rec."Response Code")
                {

                    ToolTip = 'Specifies the value of the Response Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Response Rule Entry No."; Rec."Response Rule Entry No.")
                {

                    ToolTip = 'Specifies the value of the Response Rule Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Response Message"; Rec."Response Message")
                {

                    ToolTip = 'Specifies the value of the Response Message field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

