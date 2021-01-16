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
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Event Type"; "Event Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Type field';
                }
                field("Created At"; "Created At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created At field';
                }
                field("Local Date"; "Local Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Local Date field';
                }
                field("Local Time"; "Local Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Local Time field';
                }
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Membership No. field';
                }
                field("External Member No."; "External Member No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Member No. field';
                }
                field("External Card No."; "External Card No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Card No. field';
                }
                field("Scanner Station Id"; "Scanner Station Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Scanner Station Id field';
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Response Type"; "Response Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Response Type field';
                }
                field("Response Code"; "Response Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Response Code field';
                }
                field("Response Rule Entry No."; "Response Rule Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Response Rule Entry No. field';
                }
                field("Response Message"; "Response Message")
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

