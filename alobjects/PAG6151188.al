page 6151188 "MM Member Communication"
{
    // MM1.42/TSA /20191219 CASE 382728 Initial Version

    Caption = 'Member Communication';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "MM Member Communication";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Member Entry No.";"Member Entry No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Membership Entry No.";"Membership Entry No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Membership Code";"Membership Code")
                {
                }
                field("Display Name";"Display Name")
                {
                }
                field("External Member No.";"External Member No.")
                {
                }
                field("External Membership No.";"External Membership No.")
                {
                }
                field("Message Type";"Message Type")
                {
                }
                field("Preferred Method";"Preferred Method")
                {
                }
                field("Accepted Communication";"Accepted Communication")
                {
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

                trigger OnAction()
                var
                    Member: Record "MM Member";
                begin
                    Member.SetFilter ("Entry No.", Rec.GetFilter ("Member Entry No."));
                    if (Member.FindFirst ()) then
                      CreateMemberDefaultSetup (Member."Entry No.");

                    CurrPage.Update (false);
                end;
            }
        }
    }

    local procedure CreateMemberDefaultSetup(MemberEntryNo: Integer)
    var
        MembershipManagement: Codeunit "MM Membership Management";
    begin

        MembershipManagement.CreateMemberCommunicationDefaultSetup (MemberEntryNo);
    end;
}

