page 6151188 "NPR MM Member Communication"
{
    Extensible = False;

    Caption = 'Member Communication';
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Member Communication";
    ApplicationArea = NPRRetail;

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
                    ApplicationArea = NPRRetail;
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Code"; Rec."Membership Code")
                {

                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Display Name"; Rec."Display Name")
                {

                    ToolTip = 'Specifies the value of the Display Name field';
                    ApplicationArea = NPRRetail;
                }
                field("External Member No."; Rec."External Member No.")
                {

                    ToolTip = 'Specifies the value of the External Member No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Membership No."; Rec."External Membership No.")
                {

                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Message Type"; Rec."Message Type")
                {

                    ToolTip = 'Specifies the value of the Message Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Preferred Method"; Rec."Preferred Method")
                {

                    ToolTip = 'Specifies the value of the Preferred Method field';
                    ApplicationArea = NPRRetail;
                }
                field("Accepted Communication"; Rec."Accepted Communication")
                {

                    ToolTip = 'Specifies the value of the Accepted Communication field';
                    ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;

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
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
    begin

        MembershipManagement.CreateMemberCommunicationDefaultSetup(MemberEntryNo);
    end;
}

