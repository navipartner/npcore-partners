page 6060137 "MM Membership Card"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.02/TSA/20151228  CASE 229980 Print Membercard
    // MM1.08/TSA/20160223  CASE 234913 Include company name field on membership
    // MM1.10/TSA/20160404  CASE 233948 Added a the Update Customer button to sync customer and contact
    // MM1.14/TSA/20160523  CASE 240871 Notification Service
    // MM1.15/TSA/20160817  CASE 244443 Transport MM1.15 - 19 July 2016
    // MM1.17/TSA/20161205  CASE 260181 Added Item No. to rec used to add member to membership in order for wizzard page to provide defaults
    // MM1.17/TSA/20161214  CASE 243075 Member Point System
    // MM1.17/TSA/20161229  CASE 262040 Signature Change on AddMemberAndCard
    // MM1.21/TSA/20170612  CASE 260181 Added UPGRADE as search option as that would change the base product
    // MM1.21/TSA /20170721 CASE 284653 Added button "Arrival Log"
    // MM1.22/TSA /20170731 CASE 285403 Added Action to Issue Coupon For Loyalty points, RedeemPoints()
    // #287080/TSA /20170823 CASE 287080 Added Member Count breakdown
    // MM1.22/TSA /20170825 CASE 278175 Added a button to activate membership manually.
    // #286922/TSA /20170829 CASE 286922 Added field "Auto-Renew"
    // MM1.22/TSA /20170831 CASE 288919 Changed resolve of Item No to follow the business flow
    // MM1.25/TSA /20171213 CASE 299690 Added global function AddGuardianMember()
    // MM1.25/TSA /20180112 CASE 302302 Supercharging the activate membership
    // MM1.25/TSA /20180119 CASE 302598 New action "Auto-Renew"
    // MM1.26/TSA /20180206 CASE 304579 Added Customer History
    // #306002/TSA /20180315 CASE 306002 Made 3 system fields uneditable
    // MM1.29/NPKNAV/20180524  CASE 313795 Transport MM1.29 - 24 May 2018
    // MM1.29.02/NPKNAV/20180531  CASE 314131-01 Transport TM1.29.02 - 31 May 2018
    // MM1.32/TSA /20180711 CASE 318132 Added Create Wallet Notification action
    // MM1.33/TSA/20180830  CASE 324065 Transport MM1.33 - 30 August 2018
    // #334163/JDH /20181109 CASE 334163 Added Caption to Actions
    // MM1.36/NPKNAV/20190125  CASE 343948 Transport MM1.36 - 25 January 2019

    Caption = 'Membership Card';
    DataCaptionExpression = "External Membership No."+' - ' + "Membership Code";
    InsertAllowed = false;
    SourceTable = "MM Membership";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("External Membership No.";"External Membership No.")
                {
                }
                field(ShowMemberCountAs;ShowMemberCountAs)
                {
                    Caption = 'Members (Admin/Member/Anonymous)';
                    Editable = false;
                }
                field(ShowCurrentPeriod;ShowCurrentPeriod)
                {
                    Caption = 'Current Period';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = NeedsActivation;
                }
                field("Company Name";"Company Name")
                {
                }
                field(Description;Description)
                {
                }
                field("Customer No.";"Customer No.")
                {
                }
                field("Community Code";"Community Code")
                {
                    Editable = false;
                }
                field("Membership Code";"Membership Code")
                {
                    Editable = false;
                }
                field("Issued Date";"Issued Date")
                {
                    Editable = false;
                }
                field(Blocked;Blocked)
                {
                }
                field("Blocked At";"Blocked At")
                {
                }
                field(Control6014412;"Auto-Renew")
                {
                    ShowCaption = false;
                }
                field("Auto-Renew Payment Method Code";"Auto-Renew Payment Method Code")
                {
                }
                field("Document ID";"Document ID")
                {
                    Editable = false;
                    Visible = false;
                }
            }
            part(Control6150625;"MM Membership Member ListPart")
            {
                SubPageLink = "Membership Entry No."=FIELD("Entry No.");
                SubPageView = SORTING("Membership Entry No.","Member Entry No.");
            }
            part(Control6150624;"MM Membership Ledger Entries")
            {
                SubPageLink = "Membership Entry No."=FIELD("Entry No.");
                SubPageView = SORTING("Membership Entry No.");
            }
            group(Points)
            {
                Caption = 'Points';
                field("Awarded Points (Sale)";"Awarded Points (Sale)")
                {
                    Editable = false;
                }
                field("Awarded Points (Refund)";"Awarded Points (Refund)")
                {
                    Editable = false;
                }
                field("Redeemed Points (Withdrawl)";"Redeemed Points (Withdrawl)")
                {
                    Editable = false;
                }
                field("Redeemed Points (Deposit)";"Redeemed Points (Deposit)")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Expired Points";"Expired Points")
                {
                }
                field("Remaining Points";"Remaining Points")
                {
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6150629;Notes)
            {
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Activate Membership")
            {
                Caption = 'Activate Membership';
                Enabled = NeedsActivation;
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin

                    //-MM1.22 [278175]
                    ActivateMembership ();

                    //+MM1.22 [278175]
                end;
            }
            action("Add Member")
            {
                Caption = 'Add Member';
                Ellipsis = true;
                Image = NewCustomer;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    AddMembershipMember ();
                    CurrPage.Update (false);
                end;
            }
            action("Add Guardian")
            {
                Caption = 'Add Guardian';
                Ellipsis = true;
                Image = ChangeCustomer;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    AddMembershipGuardian ();
                    CurrPage.Update (false);
                end;
            }
            action("Update Customer")
            {
                Caption = 'Update Customer Information';
                Image = CreateInteraction;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction()
                var
                    MembershipManagement: Codeunit "MM Membership Management";
                begin
                    MembershipManagement.SynchronizeCustomerAndContact ("Entry No.");
                end;
            }
            action("Redeem Points")
            {
                Caption = 'Redeem Points';
                Image = PostedVoucherGroup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin

                    RedeemPoints (Rec);
                end;
            }
            action("Auto-Renew")
            {
                Caption = 'Auto-Renew';
                Image = Invoice;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    AutoRenewMembership (Rec."Entry No.");
                end;
            }
            action("Create Welcome Notification")
            {
                Caption = 'Create Welcome Notification';
                Image = Interaction;

                trigger OnAction()
                var
                    MemberNotification: Codeunit "MM Member Notification";
                    MembershipNotification: Record "MM Membership Notification";
                    EntryNo: Integer;
                begin
                    EntryNo := MemberNotification.AddMemberWelcomeNotification (Rec."Entry No.", 0);
                    if (MembershipNotification.Get (EntryNo)) then
                      if (MembershipNotification."Processing Method" = MembershipNotification."Processing Method"::INLINE) then
                        MemberNotification.HandleMembershipNotification (MembershipNotification);
                end;
            }
            action("Create Wallet Notification")
            {
                Caption = 'Create Wallet Notification';
                Image = Interaction;

                trigger OnAction()
                var
                    MemberNotification: Codeunit "MM Member Notification";
                    MembershipNotification: Record "MM Membership Notification";
                    EntryNo: Integer;
                begin

                    EntryNo := MemberNotification.CreateWalletSendNotification (Rec."Entry No.", 0, 0);
                    if (MembershipNotification.Get (EntryNo)) then
                      if (MembershipNotification."Processing Method" = MembershipNotification."Processing Method"::INLINE) then
                        MemberNotification.HandleMembershipNotification (MembershipNotification);
                end;
            }
            group(History)
            {
                Caption = 'History';
                Image = History;
                action("Ledger E&ntries")
                {
                    Caption = 'Ledger E&ntries';
                    Image = CustomerLedger;
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    RunObject = Page "Customer Ledger Entries";
                    RunPageLink = "Customer No."=FIELD("Customer No.");
                    RunPageView = SORTING("Customer No.");
                    ShortCutKey = 'Ctrl+F7';
                }
                action(Statistics)
                {
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Customer Statistics";
                    RunPageLink = "No."=FIELD("Customer No.");
                    ShortCutKey = 'F7';
                }
            }
        }
        area(navigation)
        {
            action(Notifications)
            {
                Caption = 'Notifications';
                Image = Interaction;
                Promoted = true;
                PromotedCategory = Process;
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
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipRole: Record "MM Membership Role";
        ValidFromDate: Date;
        ValidUntilDate: Date;
    begin
        MembershipManagement.GetMemberCount (Rec."Entry No.", AdminMemberCount, MemberMemberCount, AnonymousMemberCount);
        ShowMemberCountAs := StrSubstNo ('%1 / %2 / %3', AdminMemberCount, MemberMemberCount, AnonymousMemberCount);

        NeedsActivation := MembershipManagement.MembershipNeedsActivation (Rec."Entry No.");
        ShowCurrentPeriod := NOT_ACTIVATED;
        if (not NeedsActivation) then begin
          MembershipManagement.GetMembershipValidDate (Rec."Entry No.", Today, ValidFromDate, ValidUntilDate);
          ShowCurrentPeriod := StrSubstNo ('%1 - %2', ValidFromDate, ValidUntilDate);
        end;
    end;

    var
        AdminMemberCount: Integer;
        MemberMemberCount: Integer;
        AnonymousMemberCount: Integer;
        ShowMemberCountAs: Text[30];
        ShowCurrentPeriod: Text[30];
        NeedsActivation: Boolean;
        NOT_ACTIVATED: Label 'Not activated';
        ADD_MEMBER_SETUP: Label 'Could not find %1 with %2 set to option %3 for %4 %5. Additional members can''t be added until setup is completed.';

    local procedure AddMembershipMember()
    var
        MemberInfoCapture: Record "MM Member Info Capture";
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MembershipRole: Record "MM Membership Role";
        GuardianMember: Record "MM Member";
        MemberInfoCapturePage: Page "MM Member Info Capture";
        PageAction: Action;
        MembershipManagement: Codeunit "MM Membership Management";
        ResponseMessage: Text;
    begin

        MemberInfoCapture.Init ();

        MembershipSalesSetup.SetFilter (Type, '=%1', MembershipSalesSetup.Type::ITEM);
        MembershipSalesSetup.SetFilter ("Membership Code", '=%1', "Membership Code");
        MembershipSalesSetup.SetFilter ("Business Flow Type", '=%1', MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER);
        if (not MembershipSalesSetup.FindFirst()) then
          Error (ADD_MEMBER_SETUP, MembershipSalesSetup.TableCaption,
            MembershipSalesSetup.FieldCaption ("Business Flow Type"), MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER,
            FieldCaption ("Membership Code"), "Membership Code");

        MemberInfoCapture."Item No." := MembershipSalesSetup."No.";
        MemberInfoCapture."Membership Entry No." := "Entry No.";
        MemberInfoCapture."External Membership No." := "External Membership No.";

        //-MM1.33 [324065]
        MembershipRole.SetFilter ("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipRole.SetFilter ("Member Role", '=%1', MembershipRole."Member Role"::GUARDIAN);
        MembershipRole.SetFilter (Blocked, '=%1', false);
        if (MembershipRole.FindFirst ()) then begin
          GuardianMember.Get (MembershipRole."Member Entry No.");
          MemberInfoCapture."Guardian External Member No." := GuardianMember."External Member No.";
          MemberInfoCapture."E-Mail Address" := GuardianMember."E-Mail Address";
        end;
        //+MM1.33 [324065]

        MemberInfoCapture.Insert ();

        MemberInfoCapturePage.SetRecord (MemberInfoCapture);
        MemberInfoCapture.SetFilter ("Entry No.", '=%1', MemberInfoCapture."Entry No.");
        MemberInfoCapturePage.SetTableView (MemberInfoCapture);
        Commit ();

        MemberInfoCapturePage.LookupMode (true);
        PageAction := MemberInfoCapturePage.RunModal ();
        if (PageAction = ACTION::LookupOK) then begin
          MemberInfoCapturePage.GetRecord (MemberInfoCapture);
          MembershipManagement.AddMemberAndCard (true, "Entry No.", MemberInfoCapture, false, MemberInfoCapture."Member Entry No", ResponseMessage);

        end;
    end;

    local procedure AddMembershipGuardian()
    var
        MemberInfoCapture: Record "MM Member Info Capture";
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MemberInfoCapturePage: Page "MM Member Info Capture";
        PageAction: Action;
        MembershipManagement: Codeunit "MM Membership Management";
        ResponseMessage: Text;
    begin

        MemberInfoCapture."Membership Entry No." := "Entry No.";
        MemberInfoCapture."External Membership No." := "External Membership No.";
        MemberInfoCapture.Insert ();

        MemberInfoCapturePage.SetRecord (MemberInfoCapture);
        MemberInfoCapture.SetFilter ("Entry No.", '=%1', MemberInfoCapture."Entry No.");
        MemberInfoCapturePage.SetTableView (MemberInfoCapture);
        Commit ();

        MemberInfoCapturePage.SetAddMembershipGuardianMode ();
        MemberInfoCapturePage.LookupMode (true);
        PageAction := MemberInfoCapturePage.RunModal ();
        if (PageAction = ACTION::LookupOK) then begin
          MemberInfoCapturePage.GetRecord (MemberInfoCapture);
          //-MM1.29 [313795]
          // MembershipManagement.AddGuardianMember (Rec."Entry No.", MemberInfoCapture."Guardian External Member No.");
          MembershipManagement.AddGuardianMember (Rec."Entry No.", MemberInfoCapture."Guardian External Member No.", MemberInfoCapture."GDPR Approval");
          //+MM1.29 [313795]
        end;
    end;

    local procedure RedeemPoints(Membership: Record "MM Membership")
    var
        LoyaltyPointMgt: Codeunit "MM Loyalty Point Management";
        LoyaltyCouponMgr: Codeunit "MM Loyalty Coupon Mgr";
        TmpLoyaltyPointsSetup: Record "MM Loyalty Points Setup" temporary;
    begin

        if (LoyaltyPointMgt.GetCouponToRedeem (Membership."Entry No.", TmpLoyaltyPointsSetup, 999999)) then begin
          repeat
            Membership.CalcFields ("Remaining Points");

            if (TmpLoyaltyPointsSetup."Value Assignment" = TmpLoyaltyPointsSetup."Value Assignment"::FROM_COUPON) then
              if (TmpLoyaltyPointsSetup."Points Threshold" <= Membership."Remaining Points") then
                LoyaltyCouponMgr.IssueOneCouponAndPrint (TmpLoyaltyPointsSetup."Coupon Type Code", Membership."Entry No.", TmpLoyaltyPointsSetup."Points Threshold",0);

          until (TmpLoyaltyPointsSetup.Next () = 0);
        end;
    end;

    local procedure ActivateMembership()
    var
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipEntry: Record "MM Membership Entry";
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        //-MM1.25 [302302]
        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', Rec."Entry No.");
        if (MembershipEntry.IsEmpty ()) then begin
          MembershipSalesSetup.SetFilter ("Business Flow Type", '=%1', MembershipSalesSetup."Business Flow Type"::MEMBERSHIP);
          MembershipSalesSetup.SetFilter ("Membership Code", '=%1', Rec."Membership Code");
          MembershipSalesSetup.SetFilter (Blocked, '=%1', false);
          MembershipSalesSetup.FindFirst ();

          MemberInfoCapture.Init;
          MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;

          MembershipManagement.AddMembershipLedgerEntry_NEW (Rec."Entry No.", Rec."Issued Date", MembershipSalesSetup, MemberInfoCapture);

        end;
        //+MM1.25 [302302]

        MembershipManagement.ActivateMembershipLedgerEntry (Rec."Entry No.", Today);
    end;

    local procedure AutoRenewMembership(MembershipEntryNo: Integer)
    var
        MembershipAutoRenew: Codeunit "MM Membership Auto Renew";
        MembershipManagement: Codeunit "MM Membership Management";
        TmpMembershipAutoRenew: Record "MM Membership Auto Renew" temporary;
        MemberInfoCapture: Record "MM Member Info Capture";
        RenewStartDate: Date;
        RenewUntilDate: Date;
        RenewUnitPrice: Decimal;
        EntryNo: Integer;
        SalesHeader: Record "Sales Header";
        SalesInvoicePage: Page "Sales Invoice";
    begin

        TmpMembershipAutoRenew.Init;
        MembershipManagement.GetMembershipMaxValidUntilDate (MembershipEntryNo, TmpMembershipAutoRenew."Valid Until Date");
        EntryNo := MembershipAutoRenew.AutoRenewOneMembership (0, MembershipEntryNo, TmpMembershipAutoRenew, RenewStartDate, RenewUntilDate, RenewUnitPrice, false);
        MemberInfoCapture.Get (EntryNo);
        if (MemberInfoCapture."Response Status" <> MemberInfoCapture."Response Status"::COMPLETED) then
          Error (MemberInfoCapture."Response Message");

        Commit;
        SalesHeader.Get (SalesHeader."Document Type"::Invoice, TmpMembershipAutoRenew."Last Invoice No.");
        SalesInvoicePage.SetRecord (SalesHeader);
        SalesInvoicePage.RunModal ();
    end;
}

