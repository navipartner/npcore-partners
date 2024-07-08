page 6151188 "NPR MM Member Communication"
{
    Extensible = False;

    Caption = 'Member Communication';
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Member Communication";
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Member Entry No."; Rec."Member Entry No.")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Member Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Display Name"; Rec."Display Name")
                {
                    ToolTip = 'Specifies the value of the Display Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Member No."; Rec."External Member No.")
                {
                    ToolTip = 'Specifies the value of the External Member No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Membership No."; Rec."External Membership No.")
                {
                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Message Type"; Rec."Message Type")
                {
                    ToolTip = 'Specifies the value of the Message Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Preferred Method"; Rec."Preferred Method")
                {
                    ToolTip = 'Specifies the value of the Preferred Method field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Accepted Communication"; Rec."Accepted Communication")
                {
                    ToolTip = 'Specifies the value of the Accepted Communication field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create Defaults")
            {
                Caption = 'Create Defaults';
                Image = Default;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;

                ToolTip = 'Executes the Create Defaults action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                var
                    Member: Record "NPR MM Member";
                begin
                    Member.SetFilter("Entry No.", Rec.GetFilter("Member Entry No."));
                    if (Member.FindFirst()) then
                        CreateMemberDefaultSetup(Member."Entry No.");

                    CurrPage.Update(false);
                end;
            }
        }
    }

    local procedure CreateMemberDefaultSetup(MemberEntryNo: Integer)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin

        MembershipManagement.CreateMemberCommunicationDefaultSetup(MemberEntryNo);
    end;
}

