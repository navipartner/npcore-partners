page 6060139 "MM Create Membership"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.10/TSA/20160331  CASE 234591 CreateMembershipAll changed signature

    Caption = 'Create Membership';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "MM Membership Sales Setup";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field(Type;Type)
                {
                }
                field("No.";"No.")
                {
                }
                field("Membership Code";"Membership Code")
                {
                }
                field(Blocked;Blocked)
                {
                }
                field("Blocked At";"Blocked At")
                {
                }
                field("Valid From Base";"Valid From Base")
                {
                }
                field("Sales Cut-Off Date Calculation";"Sales Cut-Off Date Calculation")
                {
                }
                field("Valid From Date Calculation";"Valid From Date Calculation")
                {
                }
                field("Valid Until Calculation";"Valid Until Calculation")
                {
                }
                field("Duration Formula";"Duration Formula")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create Membership")
            {
                Caption = 'Create Membership';
                Ellipsis = true;
                Image = NewCustomer;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    CreateMembership ();
                end;
            }
        }
        area(navigation)
        {
            action("Membership Setup")
            {
                Caption = 'Membership Setup';
                Image = SetupList;
                RunObject = Page "MM Membership Setup";
            }
            action("Item List")
            {
                Caption = 'Item List';
                Image = List;
                RunObject = Page "Retail Item List";
            }
            action(Memberships)
            {
                Caption = 'Memberships';
                Image = List;
                RunObject = Page "MM Memberships";
                RunPageLink = "Membership Code"=FIELD("Membership Code");
            }
            action("Community Setup")
            {
                Caption = 'Community Setup';
                Image = Group;
                RunObject = Page "MM Member Community";
            }
        }
    }

    local procedure CreateMembership()
    var
        MemberInfoCapture: Record "MM Member Info Capture";
        MemberInfoCapturePage: Page "MM Member Info Capture";
        MembershipPage: Page "MM Membership Card";
        PageAction: Action;
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipEntryNo: Integer;
        Membership: Record "MM Membership";
    begin

        MemberInfoCapture.Init ();
        MemberInfoCapture.Insert ();

        MemberInfoCapturePage.SetRecord (MemberInfoCapture);
        MemberInfoCapture.SetFilter ("Entry No.", '=%1', MemberInfoCapture."Entry No.");
        MemberInfoCapturePage.SetTableView (MemberInfoCapture);
        Commit ();

        MemberInfoCapturePage.LookupMode (true);
        PageAction := MemberInfoCapturePage.RunModal ();

        if (PageAction = ACTION::LookupOK) then begin
          MemberInfoCapturePage.GetRecord (MemberInfoCapture);
          MembershipEntryNo := MembershipManagement.CreateMembershipAll (Rec, MemberInfoCapture, true);
          Membership.Get (MembershipEntryNo);
          MembershipPage.SetRecord (Membership);
          MembershipPage.Run ();
        end;
    end;
}

