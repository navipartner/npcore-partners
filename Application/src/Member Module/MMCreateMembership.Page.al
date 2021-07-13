page 6060139 "NPR MM Create Membership"
{

    Caption = 'Create Membership';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR MM Members. Sales Setup";
    UsageCategory = Tasks;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Code"; Rec."Membership Code")
                {

                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field("Blocked At"; Rec."Blocked At")
                {

                    ToolTip = 'Specifies the value of the Blocked At field';
                    ApplicationArea = NPRRetail;
                }
                field("Valid From Base"; Rec."Valid From Base")
                {

                    ToolTip = 'Specifies the value of the Valid From Base field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Cut-Off Date Calculation"; Rec."Sales Cut-Off Date Calculation")
                {

                    ToolTip = 'Specifies the value of the Sales Cut-Off Date Calculation field';
                    ApplicationArea = NPRRetail;
                }
                field("Valid From Date Calculation"; Rec."Valid From Date Calculation")
                {

                    ToolTip = 'Specifies the value of the Valid From Date Calculation field';
                    ApplicationArea = NPRRetail;
                }
                field("Valid Until Calculation"; Rec."Valid Until Calculation")
                {

                    ToolTip = 'Specifies the value of the Valid Until Calculation field';
                    ApplicationArea = NPRRetail;
                }
                field("Duration Formula"; Rec."Duration Formula")
                {

                    ToolTip = 'Specifies the value of the Duration Formula field';
                    ApplicationArea = NPRRetail;
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
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;

                ToolTip = 'Executes the Create Membership action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Membership Setup action';
                ApplicationArea = NPRRetail;
            }
            action("Item List")
            {
                Caption = 'Item List';
                Image = List;
                RunObject = Page "Item List";

                ToolTip = 'Executes the Item List action';
                ApplicationArea = NPRRetail;
            }
            action(Memberships)
            {
                Caption = 'Memberships';
                Image = List;
                RunObject = Page "NPR MM Memberships";
                RunPageLink = "Membership Code" = FIELD("Membership Code");

                ToolTip = 'Executes the Memberships action';
                ApplicationArea = NPRRetail;
            }
            action("Community Setup")
            {
                Caption = 'Community Setup';
                Image = Group;
                RunObject = Page "NPR MM Member Community";

                ToolTip = 'Executes the Community Setup action';
                ApplicationArea = NPRRetail;
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
        // PageAction := MemberInfoCapturePage.RunModal() ();
        //
        // IF (PageAction = ACTION::LookupOK) THEN BEGIN
        //  MemberInfoCapturePage.GETRECORD (MemberInfoCapture);
        //  MembershipEntryNo := MembershipManagement.CreateMembershipAll (Rec, MemberInfoCapture, TRUE);
        //  Membership.Get() (MembershipEntryNo);
        //  MembershipPage.SETRECORD (Membership);
        //  MembershipPage.RUN ();
        // END;

        MembershipSalesSetup.CreateMembership(Rec);

    end;
}

