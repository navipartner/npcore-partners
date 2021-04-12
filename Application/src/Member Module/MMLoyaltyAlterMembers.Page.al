page 6151163 "NPR MM Loyalty Alter Members."
{

    Caption = 'Loyalty Alter Membership';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Loyalty Alter Members.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Loyalty Code"; Rec."Loyalty Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("From Membership Code"; Rec."From Membership Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From Membership Code field';
                }
                field("Change Direction"; Rec."Change Direction")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Change Direction field';
                }
                field("To Membership Code"; Rec."To Membership Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Membership Code field';
                }
                field("Points Threshold"; Rec."Points Threshold")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Points Threshold field';
                }
                field("Sales Item No."; Rec."Sales Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Item No. field';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field(Description; Rec.Description)
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

