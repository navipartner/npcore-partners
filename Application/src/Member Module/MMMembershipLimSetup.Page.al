page 6060087 "NPR MM Membership Lim. Setup"
{

    Caption = 'Membership Limitation Setup';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Membership Lim. Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Membership  Code"; "Membership  Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership  Code field';
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Constraint Type"; "Constraint Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Constraint Type field';
                }
                field("Constraint Source"; "Constraint Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Constraint Source field';
                }
                field("Constraint Seconds"; "Constraint Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Constraint Seconds field';
                }
                field("Constraint From Time"; "Constraint From Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Constraint From Time field';
                }
                field("Constraint Until Time"; "Constraint Until Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Constraint Until Time field';
                }
                field("Constraint Dateformula"; "Constraint Dateformula")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Constraint Dateformula field';
                }
                field("Event Type"; "Event Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Event Type field';
                }
                field("Event Limit"; "Event Limit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Limit field';
                }
                field("POS Response Action"; "POS Response Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Response Action field';
                }
                field("POS Response Message"; "POS Response Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Response Message field';
                }
                field("WS Response Action"; "WS Response Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the WS Response Action field';
                }
                field("WS Deny Message"; "WS Deny Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the WS Deny Message field';
                }
                field("Response Code"; "Response Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Response Code field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
            }
        }
    }

    actions
    {
    }
}

