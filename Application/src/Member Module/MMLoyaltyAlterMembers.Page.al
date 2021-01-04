page 6151163 "NPR MM Loyalty Alter Members."
{

    Caption = 'Loyalty Alter Membership';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR MM Loyalty Alter Members.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Loyalty Code"; "Loyalty Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("From Membership Code"; "From Membership Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From Membership Code field';
                }
                field("Change Direction"; "Change Direction")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Change Direction field';
                }
                field("To Membership Code"; "To Membership Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Membership Code field';
                }
                field("Points Threshold"; "Points Threshold")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Points Threshold field';
                }
                field("Sales Item No."; "Sales Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Item No. field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }

    actions
    {
    }
}

