page 6060087 "NPR MM Membership Lim. Setup"
{

    Caption = 'Membership Limitation Setup';
    PageType = List;
    UsageCategory = Administration;
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
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = All;
                }
                field("Constraint Type"; "Constraint Type")
                {
                    ApplicationArea = All;
                }
                field("Constraint Source"; "Constraint Source")
                {
                    ApplicationArea = All;
                }
                field("Constraint Seconds"; "Constraint Seconds")
                {
                    ApplicationArea = All;
                }
                field("Constraint From Time"; "Constraint From Time")
                {
                    ApplicationArea = All;
                }
                field("Constraint Until Time"; "Constraint Until Time")
                {
                    ApplicationArea = All;
                }
                field("Constraint Dateformula"; "Constraint Dateformula")
                {
                    ApplicationArea = All;
                }
                field("Event Type"; "Event Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Event Limit"; "Event Limit")
                {
                    ApplicationArea = All;
                }
                field("POS Response Action"; "POS Response Action")
                {
                    ApplicationArea = All;
                }
                field("POS Response Message"; "POS Response Message")
                {
                    ApplicationArea = All;
                }
                field("WS Response Action"; "WS Response Action")
                {
                    ApplicationArea = All;
                }
                field("WS Deny Message"; "WS Deny Message")
                {
                    ApplicationArea = All;
                }
                field("Response Code"; "Response Code")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
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

