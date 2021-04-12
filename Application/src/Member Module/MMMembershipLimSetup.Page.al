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
                field("Membership  Code"; Rec."Membership  Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership  Code field';
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Constraint Type"; Rec."Constraint Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Constraint Type field';
                }
                field("Constraint Source"; Rec."Constraint Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Constraint Source field';
                }
                field("Constraint Seconds"; Rec."Constraint Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Constraint Seconds field';
                }
                field("Constraint From Time"; Rec."Constraint From Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Constraint From Time field';
                }
                field("Constraint Until Time"; Rec."Constraint Until Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Constraint Until Time field';
                }
                field("Constraint Dateformula"; Rec."Constraint Dateformula")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Constraint Dateformula field';
                }
                field("Event Type"; Rec."Event Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Event Type field';
                }
                field("Event Limit"; Rec."Event Limit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Limit field';
                }
                field("POS Response Action"; Rec."POS Response Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Response Action field';
                }
                field("POS Response Message"; Rec."POS Response Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Response Message field';
                }
                field("WS Response Action"; Rec."WS Response Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the WS Response Action field';
                }
                field("WS Deny Message"; Rec."WS Deny Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the WS Deny Message field';
                }
                field("Response Code"; Rec."Response Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Response Code field';
                }
                field(Blocked; Rec.Blocked)
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

