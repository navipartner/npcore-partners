page 6060135 "NPR MM Members. Admis. Setup"
{
    Extensible = False;

    Caption = 'Membership Admission Setup';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Members. Admis. Setup";
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Membership  Code"; Rec."Membership  Code")
                {

                    ToolTip = 'Specifies the value of the Membership  Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Admission Code"; Rec."Admission Code")
                {

                    ToolTip = 'Specifies the value of the Admission Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Ticket No. Type"; Rec."Ticket No. Type")
                {

                    ToolTip = 'Specifies the value of the Ticket No. Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Ticket No."; Rec."Ticket No.")
                {

                    ToolTip = 'Specifies the value of the Ticket No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Cardinality Type"; Rec."Cardinality Type")
                {

                    ToolTip = 'Specifies the value of the Cardinality Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Max Cardinality"; Rec."Max Cardinality")
                {

                    ToolTip = 'Specifies the value of the Max Cardinality field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
    }
}

