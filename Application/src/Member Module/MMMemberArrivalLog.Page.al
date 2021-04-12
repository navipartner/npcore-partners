page 6060088 "NPR MM Member Arrival Log"
{

    Caption = 'Member Arrival Log';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Member Arr. Log Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Event Type"; Rec."Event Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Type field';
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created At field';
                }
                field("Local Date"; Rec."Local Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Local Date field';
                }
                field("Local Time"; Rec."Local Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Local Time field';
                }
                field("External Membership No."; Rec."External Membership No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Membership No. field';
                }
                field("External Member No."; Rec."External Member No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Member No. field';
                }
                field("External Card No."; Rec."External Card No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Card No. field';
                }
                field("Scanner Station Id"; Rec."Scanner Station Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Scanner Station Id field';
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Response Type"; Rec."Response Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Response Type field';
                }
                field("Response Code"; Rec."Response Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Response Code field';
                }
                field("Response Rule Entry No."; Rec."Response Rule Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Response Rule Entry No. field';
                }
                field("Response Message"; Rec."Response Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Response Message field';
                }
            }
        }
    }

    actions
    {
    }
}

