page 6060139 "MM Create Membership"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.10/TSA/20160331  CASE 234591 CreateMembershipAll changed signature
    // MM1.40/TSA /20190808 CASE 363147 CreateMembership was stale, invokes a maintained functions on 6060125 instead of duplicating functionality

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
        MembershipSalesSetup: Page "MM Membership Sales Setup";
    begin

        //-MM1.40 [363147]
        // MemberInfoCapture.INIT ();
        // MemberInfoCapture.INSERT ();
        //
        // MemberInfoCapturePage.SETRECORD (MemberInfoCapture);
        // MemberInfoCapture.SETFILTER ("Entry No.", '=%1', MemberInfoCapture."Entry No.");
        // MemberInfoCapturePage.SETTABLEVIEW (MemberInfoCapture);
        // COMMIT ();
        //
        // MemberInfoCapturePage.LOOKUPMODE (TRUE);
        // PageAction := MemberInfoCapturePage.RUNMODAL ();
        //
        // IF (PageAction = ACTION::LookupOK) THEN BEGIN
        //  MemberInfoCapturePage.GETRECORD (MemberInfoCapture);
        //  MembershipEntryNo := MembershipManagement.CreateMembershipAll (Rec, MemberInfoCapture, TRUE);
        //  Membership.GET (MembershipEntryNo);
        //  MembershipPage.SETRECORD (Membership);
        //  MembershipPage.RUN ();
        // END;

        MembershipSalesSetup.CreateMembership (Rec);
        //+MM1.40 [363147]
    end;
}

