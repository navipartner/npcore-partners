page 6151188 "NPR MM Member Communication"
{

    Caption = 'Member Communication';
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
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
                    ToolTip = 'Specifies the value of the Member Entry No. field';
                }
                field("Membership Entry No."; "Membership Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                }
                field("Membership Code"; "Membership Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Code field';
                }
                field("Display Name"; "Display Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Display Name field';
                }
                field("External Member No."; "External Member No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Member No. field';
                }
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Membership No. field';
                }
                field("Message Type"; "Message Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Message Type field';
                }
                field("Preferred Method"; "Preferred Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Preferred Method field';
                }
                field("Accepted Communication"; "Accepted Communication")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Accepted Communication field';
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
                ToolTip = 'Executes the Create Defaults action';

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

