page 6151163 "NPR MM Loyalty Alter Members."
{

    Caption = 'Loyalty Alter Membership';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Loyalty Alter Members.";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Loyalty Code"; Rec."Loyalty Code")
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("From Membership Code"; Rec."From Membership Code")
                {

                    ToolTip = 'Specifies the value of the From Membership Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Change Direction"; Rec."Change Direction")
                {

                    ToolTip = 'Specifies the value of the Change Direction field';
                    ApplicationArea = NPRRetail;
                }
                field("To Membership Code"; Rec."To Membership Code")
                {

                    ToolTip = 'Specifies the value of the To Membership Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Points Threshold"; Rec."Points Threshold")
                {

                    ToolTip = 'Specifies the value of the Points Threshold field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Item No."; Rec."Sales Item No.")
                {

                    ToolTip = 'Specifies the value of the Sales Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

