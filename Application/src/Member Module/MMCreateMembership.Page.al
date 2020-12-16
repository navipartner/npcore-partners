page 6060139 "NPR MM Create Membership"
{

    Caption = 'Create Membership';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR MM Members. Sales Setup";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Membership Code"; "Membership Code")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field("Blocked At"; "Blocked At")
                {
                    ApplicationArea = All;
                }
                field("Valid From Base"; "Valid From Base")
                {
                    ApplicationArea = All;
                }
                field("Sales Cut-Off Date Calculation"; "Sales Cut-Off Date Calculation")
                {
                    ApplicationArea = All;
                }
                field("Valid From Date Calculation"; "Valid From Date Calculation")
                {
                    ApplicationArea = All;
                }
                field("Valid Until Calculation"; "Valid Until Calculation")
                {
                    ApplicationArea = All;
                }
                field("Duration Formula"; "Duration Formula")
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
            action("Create Membership")
            {
                Caption = 'Create Membership';
                Ellipsis = true;
                Image = NewCustomer;
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    CreateMembership();
                end;
            }
        }
        area(navigation)
        {
            action("Membership Setup")
            {
                Caption = 'Membership Setup';
                Image = SetupList;
                RunObject = Page "NPR MM Membership Setup";
                ApplicationArea = All;
            }
            action("Item List")
            {
                Caption = 'Item List';
                Image = List;
                RunObject = Page "Item List";
                ApplicationArea = All;
            }
            action(Memberships)
            {
                Caption = 'Memberships';
                Image = List;
                RunObject = Page "NPR MM Memberships";
                RunPageLink = "Membership Code" = FIELD("Membership Code");
                ApplicationArea = All;
            }
            action("Community Setup")
            {
                Caption = 'Community Setup';
                Image = Group;
                RunObject = Page "NPR MM Member Community";
                ApplicationArea = All;
            }
        }
    }

    local procedure CreateMembership()
    var
        MembershipSalesSetup: Page "NPR MM Membership Sales Setup";
    begin

        // MemberInfoCapture.INIT ();
        // MemberInfoCapture.Insert ();
        //
        // MemberInfoCapturePage.SETRECORD (MemberInfoCapture);
        // MemberInfoCapture.SetFilter ("Entry No.", '=%1', MemberInfoCapture."Entry No.");
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

        MembershipSalesSetup.CreateMembership(Rec);

    end;
}

