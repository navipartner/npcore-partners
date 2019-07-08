page 6060127 "MM Memberships"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.08/TSA/20160223  CASE 234913 Include company name field on membership
    // MM1.10/TSA/20160404  CASE 233948 Added a the Update Customer button to sync customer and contact
    // MM1.14/TSA/20160523  CASE 240871 Reminder Service
    // MM1.17/TSA/20170125  CASE 243075 Added the loyality reports
    // MM1.18/TSA/20170220 CASE 266768 Added default filter to not show blocked entries
    // MM1.19/TSA/20170525  CASE 278061 Handling issues reported by OMA
    // MM1.21/TSA /20170721 CASE 284653 Added button "Arrival Log"
    // MM1.22/TSA /20170829 CASE 286922 Added field "Auto-Renew"
    // MM1.22/NPKNAV/20170914  CASE 285403 Transport MM1.22 - 13 September 2017
    // MM1.34/TSA/20180927  CASE 327637 Transport MM1.34 - 27 September 2018
    // NPR5.46/BHR/20180110 CASE 330112 Added field "Auto-Renew Payment Method Code"

    Caption = 'Memberships';
    CardPageID = "MM Membership Card";
    DataCaptionExpression = "External Membership No.";
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "MM Membership";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Membership No.";"External Membership No.")
                {
                }
                field("Community Code";"Community Code")
                {
                }
                field("Customer No.";"Customer No.")
                {
                }
                field("Company Name";"Company Name")
                {
                }
                field("Membership Code";"Membership Code")
                {
                }
                field("Issued Date";"Issued Date")
                {
                }
                field(Description;Description)
                {
                }
                field(Blocked;Blocked)
                {
                }
                field("Blocked At";"Blocked At")
                {
                }
                field("Auto-Renew";"Auto-Renew")
                {
                }
                field("Auto-Renew Payment Method Code";"Auto-Renew Payment Method Code")
                {
                }
                field(DisplayName;DisplayName)
                {
                    Caption = 'Member Display Name';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Membership)
            {
                Caption = 'Membership';
                Ellipsis = true;
                Image = CustomerList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "MM Membership Card";
                RunPageLink = "Entry No."=FIELD("Entry No.");
            }
            action(Notifications)
            {
                Caption = 'Notifications';
                Image = Interaction;
                RunObject = Page "MM Membership Notification";
                RunPageLink = "Membership Entry No."=FIELD("Entry No.");
                RunPageView = SORTING("Membership Entry No.");
            }
            action("Arrival Log")
            {
                Caption = 'Arrival Log';
                Ellipsis = true;
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "MM Member Arrival Log";
                RunPageLink = "External Membership No."=FIELD("External Membership No.");
            }
            action("Open Coupons")
            {
                Caption = 'Open Coupons';
                Image = Voucher;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NpDc Coupons";
                RunPageLink = "Customer No."=FIELD("Customer No.");
            }
        }
        area(processing)
        {
            action("Update Customer")
            {
                Caption = 'Update Customer Information';
                Image = CreateInteraction;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction()
                begin
                    SyncContacts ();
                end;
            }
            group(Loyalty)
            {
                action("Loyalty Point Summary")
                {
                    Caption = 'Loyalty Point Summary';
                    Image = CreditCard;
                    RunObject = Report "MM Membership Points Summary";
                }
                action("Loyalty Point Value")
                {
                    Caption = 'Loyalty Point Value';
                    Image = LimitedCredit;
                    RunObject = Report "MM Membership Points Value";
                }
                action("Loyalty Point Details")
                {
                    Caption = 'Loyalty Point Details';
                    Image = CreditCardLog;
                    RunObject = Report "MM Membership Points Detail";
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        MembershipRole: Record "MM Membership Role";
        Member: Record "MM Member";
    begin
        MembershipRole.SetFilter ("Membership Entry No.", '=%1', "Entry No.");
        MembershipRole.SetFilter (Blocked, '=%1', false);
        MembershipRole.SetFilter ("Member Role", '=%1|=%2', MembershipRole."Member Role"::ADMIN, MembershipRole."Member Role"::GUARDIAN);
        DisplayName := '';
        if (MembershipRole.FindFirst ()) then begin
          MembershipRole.CalcFields ("Member Display Name");
          DisplayName := MembershipRole."Member Display Name";
        end;
    end;

    trigger OnOpenPage()
    begin

        //-+MM1.18 [266769]
        Rec.SetFilter (Blocked, '=%1', false);
    end;

    var
        MembershipManagement: Codeunit "MM Membership Management";
        CONFIRM_SYNC: Label 'Do you want to sync the customers and contacts for %1 memberships?';
        DisplayName: Text[200];

    local procedure SyncContacts()
    var
        Membership: Record "MM Membership";
    begin
        CurrPage.SetSelectionFilter (Membership);
        if (Membership.FindSet ()) then begin
          if (Membership.Count() > 1) then
            if (not Confirm (CONFIRM_SYNC, true, Membership.Count())) then
              Error ('');
          repeat
            MembershipManagement.SynchronizeCustomerAndContact (Membership."Entry No.");
          until (Membership.Next () = 0);
        end;
    end;
}

