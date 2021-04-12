page 6060139 "NPR MM Create Membership"
{

    Caption = 'Create Membership';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR MM Members. Sales Setup";
    UsageCategory = Tasks;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Code field';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Blocked At"; Rec."Blocked At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked At field';
                }
                field("Valid From Base"; Rec."Valid From Base")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid From Base field';
                }
                field("Sales Cut-Off Date Calculation"; Rec."Sales Cut-Off Date Calculation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Cut-Off Date Calculation field';
                }
                field("Valid From Date Calculation"; Rec."Valid From Date Calculation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid From Date Calculation field';
                }
                field("Valid Until Calculation"; Rec."Valid Until Calculation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid Until Calculation field';
                }
                field("Duration Formula"; Rec."Duration Formula")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Duration Formula field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Create Membership action';

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
                ToolTip = 'Executes the Membership Setup action';
            }
            action("Item List")
            {
                Caption = 'Item List';
                Image = List;
                RunObject = Page "Item List";
                ApplicationArea = All;
                ToolTip = 'Executes the Item List action';
            }
            action(Memberships)
            {
                Caption = 'Memberships';
                Image = List;
                RunObject = Page "NPR MM Memberships";
                RunPageLink = "Membership Code" = FIELD("Membership Code");
                ApplicationArea = All;
                ToolTip = 'Executes the Memberships action';
            }
            action("Community Setup")
            {
                Caption = 'Community Setup';
                Image = Group;
                RunObject = Page "NPR MM Member Community";
                ApplicationArea = All;
                ToolTip = 'Executes the Community Setup action';
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

