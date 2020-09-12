page 6151188 "NPR MM Member Communication"
{
    // MM1.42/TSA /20191219 CASE 382728 Initial Version

    Caption = 'Member Communication';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR MM Member Communication";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Member Entry No."; "Member Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Membership Entry No."; "Membership Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Membership Code"; "Membership Code")
                {
                    ApplicationArea = All;
                }
                field("Display Name"; "Display Name")
                {
                    ApplicationArea = All;
                }
                field("External Member No."; "External Member No.")
                {
                    ApplicationArea = All;
                }
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                }
                field("Message Type"; "Message Type")
                {
                    ApplicationArea = All;
                }
                field("Preferred Method"; "Preferred Method")
                {
                    ApplicationArea = All;
                }
                field("Accepted Communication"; "Accepted Communication")
                {
                    ApplicationArea = All;
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
                PromotedIsBig = true;
                ApplicationArea = All;

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

