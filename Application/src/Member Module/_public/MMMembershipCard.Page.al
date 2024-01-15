﻿page 6060137 "NPR MM Membership Card"
{
    Extensible = true;
    UsageCategory = None;
    Caption = 'Membership Card';
    ContextSensitiveHelpPage = 'docs/entertainment/loyalty/explanation/navigation_reports/';
    DataCaptionExpression = Rec."External Membership No." + ' - ' + Rec."Membership Code";
    InsertAllowed = false;
    PromotedActionCategories = 'New,Process,Report,History,Raptor';
    SourceTable = "NPR MM Membership";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("External Membership No."; Rec."External Membership No.")
                {

                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnValidate()
                    begin

                        if ((Rec."External Membership No." <> xRec."External Membership No.") and (xRec."External Membership No." <> '')) then
                            if (not Confirm(EXT_NO_CHANGE, false)) then
                                Error('');

                    end;
                }
                field(ShowMemberCountAs; ShowMemberCountAs)
                {

                    Caption = 'Members (Admin/Member/Anonymous)';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Members (Admin/Member/Anonymous) field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(ShowCurrentPeriod; ShowCurrentPeriod)
                {

                    Caption = 'Current Period';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = NeedsActivation;
                    ToolTip = 'Specifies the value of the Current Period field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Company Name"; Rec."Company Name")
                {

                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Customer No."; Rec."Customer No.")
                {

                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Community Code"; Rec."Community Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Community Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Code"; Rec."Membership Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Issued Date"; Rec."Issued Date")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Issued Date field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Blocked At"; Rec."Blocked At")
                {

                    ToolTip = 'Specifies the value of the Blocked At field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Control6014412; Rec."Auto-Renew")
                {

                    ToolTip = 'Specifies the value of the Auto-Renew field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Auto-Renew Payment Method Code"; Rec."Auto-Renew Payment Method Code")
                {

                    ToolTip = 'Specifies the value of the Auto-Renew Payment Method Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Document ID"; Rec."Document ID")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Document ID field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            part(Control6150625; "NPR MM Members.Member ListPart")
            {
                SubPageLink = "Membership Entry No." = FIELD("Entry No.");
                SubPageView = SORTING("Membership Entry No.", "Member Entry No.");
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

            }
            part(Control6150624; "NPR MM Members. Ledger Entries")
            {
                SubPageLink = "Membership Entry No." = FIELD("Entry No.");
                SubPageView = SORTING("Membership Entry No.");
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

            }
            group(Points)
            {
                Caption = 'Points';
                field("Awarded Points (Sale)"; Rec."Awarded Points (Sale)")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Awarded Points (Sale) field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Awarded Points (Refund)"; Rec."Awarded Points (Refund)")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Awarded Points (Refund) field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Redeemed Points (Withdrawl)"; Rec."Redeemed Points (Withdrawl)")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Redeemed Points (Withdrawl) field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Redeemed Points (Deposit)"; Rec."Redeemed Points (Deposit)")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Redeemed Points (Deposit) field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Expired Points"; Rec."Expired Points")
                {

                    ToolTip = 'Specifies the value of the Expired Points field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Remaining Points"; Rec."Remaining Points")
                {

                    ToolTip = 'Specifies the value of the Remaining Points field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            part(PointsSummary; "NPR MM Members. Points Summary")
            {
                ShowFilter = false;
                SubPageLink = "Membership Entry No." = FIELD("Entry No.");
                SubPageView = SORTING("Membership Entry No.", "Relative Period")
                              ORDER(Descending);
                UpdatePropagation = Both;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

            }
            group(Attributes)
            {
                Caption = 'Attributes';
                field(NPRAttrTextArray_01; NPRAttrTextArray[1])
                {

                    CaptionClass = GetAttributeCaptionClass(1);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible01;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[1] field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        OnAttributeLookup(1);

                    end;

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(1);

                    end;
                }
                field(NPRAttrTextArray_02; NPRAttrTextArray[2])
                {

                    CaptionClass = GetAttributeCaptionClass(2);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible02;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[2] field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        OnAttributeLookup(2);

                    end;

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(2);

                    end;
                }
                field(NPRAttrTextArray_03; NPRAttrTextArray[3])
                {

                    CaptionClass = GetAttributeCaptionClass(3);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible03;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[3] field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        OnAttributeLookup(3);

                    end;

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(3);

                    end;
                }
                field(NPRAttrTextArray_04; NPRAttrTextArray[4])
                {

                    CaptionClass = GetAttributeCaptionClass(4);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible04;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[4] field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        OnAttributeLookup(4);

                    end;

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(4);

                    end;
                }
                field(NPRAttrTextArray_05; NPRAttrTextArray[5])
                {

                    CaptionClass = GetAttributeCaptionClass(5);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible05;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[5] field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        OnAttributeLookup(5);

                    end;

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(5);

                    end;
                }
                field(NPRAttrTextArray_06; NPRAttrTextArray[6])
                {

                    CaptionClass = GetAttributeCaptionClass(6);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible06;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[6] field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        OnAttributeLookup(6);

                    end;

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(6);

                    end;
                }
                field(NPRAttrTextArray_07; NPRAttrTextArray[7])
                {

                    CaptionClass = GetAttributeCaptionClass(7);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible07;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[7] field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        OnAttributeLookup(7);

                    end;

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(7);

                    end;
                }
                field(NPRAttrTextArray_08; NPRAttrTextArray[8])
                {

                    CaptionClass = GetAttributeCaptionClass(8);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible08;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[8] field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        OnAttributeLookup(8);

                    end;

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(8);

                    end;
                }
                field(NPRAttrTextArray_09; NPRAttrTextArray[9])
                {

                    CaptionClass = GetAttributeCaptionClass(9);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible09;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[9] field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        OnAttributeLookup(9);

                    end;

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(9);

                    end;
                }
                field(NPRAttrTextArray_10; NPRAttrTextArray[10])
                {

                    CaptionClass = GetAttributeCaptionClass(10);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible10;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[10] field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        OnAttributeLookup(10);

                    end;

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(10);

                    end;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6150629; Notes)
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Executes the Activate Membership action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                begin

                    ActivateMembership();

                end;
            }
            action("Add Member")
            {
                Caption = 'Add Member';
                Ellipsis = true;
                Image = NewCustomer;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;

                ToolTip = 'Executes the Add Member action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                begin
                    AddMembershipMember();
                    CurrPage.Update(false);
                end;
            }
            action("Add Guardian")
            {
                Caption = 'Add Guardian';
                Ellipsis = true;
                Image = ChangeCustomer;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;

                ToolTip = 'Executes the Add Guardian action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                begin
                    AddMembershipGuardian();
                    CurrPage.Update(false);
                end;
            }
            action("Update Customer")
            {
                Caption = 'Update Customer Information';
                Image = CreateInteraction;

                ToolTip = 'Executes the Update Customer Information action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction()
                var
                    MembershipManagement: Codeunit "NPR MM Membership Mgt.";
                begin
                    MembershipManagement.SynchronizeCustomerAndContact(Rec."Entry No.");
                end;
            }
            action("Redeem Points")
            {
                Caption = 'Redeem Points';
                Image = PostedVoucherGroup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Redeem Points action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                begin
                    RedeemPoints(Rec);
                end;
            }
            action("Auto-Renew")
            {
                Caption = 'Auto-Renew';
                Image = Invoice;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Auto-Renew action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                begin
                    AutoRenewMembership(Rec."Entry No.");
                end;
            }
            action("Create Welcome Notification")
            {
                Caption = 'Create Welcome Notification';
                Image = Interaction;

                ToolTip = 'Executes the Create Welcome Notification action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                var
                    MemberNotification: Codeunit "NPR MM Member Notification";
                    MembershipNotification: Record "NPR MM Membership Notific.";
                    AzureMemberRegistration: Record "NPR MM AzureMemberRegSetup";
                    EntryNoList: List of [Integer];
                    EntryNo: Integer;
                    AzureSetupCount: Integer;
                    ForceIncludeAzureSetup: Boolean;
                begin
                    AzureMemberRegistration.SetFilter(Enabled, '=%1', true);
                    AzureSetupCount := AzureMemberRegistration.Count();
                    if (AzureSetupCount > 0) then
                        ForceIncludeAzureSetup := Confirm('Force include the Azure Member Registration information? Else it will be determined by original membership sales item.', false);

                    if (ForceIncludeAzureSetup) and (AzureSetupCount = 1) then
                        AzureMemberRegistration.FindFirst();

                    if (ForceIncludeAzureSetup) and (AzureSetupCount > 1) then
                        if (Page.RunModal(Page::"NPR MM AzureMemberRegList", AzureMemberRegistration) <> Action::LookupOK) then
                            Error('');

                    MemberNotification.AddMemberWelcomeNotificationWorker(Rec."Entry No.", 0, AzureMemberRegistration.AzureRegistrationSetupCode, EntryNoList);
                    foreach EntryNo in EntryNoList do
                        if (MembershipNotification.Get(EntryNo)) then
                            if (MembershipNotification."Processing Method" = MembershipNotification."Processing Method"::INLINE) then
                                MemberNotification.HandleMembershipNotification(MembershipNotification);
                end;
            }
            action("Create Wallet Notification")
            {
                Caption = 'Create Wallet Notification';
                Image = Interaction;

                ToolTip = 'Executes the Create Wallet Notification action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                var
                    MemberNotification: Codeunit "NPR MM Member Notification";
                    MembershipNotification: Record "NPR MM Membership Notific.";
                    EntryNo: Integer;
                begin

                    EntryNo := MemberNotification.CreateWalletSendNotification(Rec."Entry No.", 0, 0, Today);
                    if (MembershipNotification.Get(EntryNo)) then
                        if (MembershipNotification."Processing Method" = MembershipNotification."Processing Method"::INLINE) then
                            MemberNotification.HandleMembershipNotification(MembershipNotification);
                end;
            }
            action("Issue Sponsorship Tickets")
            {
                Caption = 'Issue Sponsorship Tickets';
                Image = TeamSales;

                ToolTip = 'Executes the Issue Sponsorship Tickets action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                begin

                    IssueAdHocSponsorshipTickets(Rec."Entry No.");
                end;
            }
            action(DeleteMembership)
            {
                Caption = 'Delete Membership';
                Image = Delete;

                ToolTip = 'This actions tries a little bit harder to delete a Membership when membership data or setup is inconsistent.';
                ApplicationArea = NPRMembershipAdvanced;

                trigger OnAction()
                var
                    MembershipMgt: Codeunit "NPR MM Membership Mgt.";
                    MembershipSetup: Record "NPR MM Membership Setup";
                    ConfirmLbl: Label 'This action will attempt to delete the membership and its related information. It can not be undone. ';
                begin
                    if (Confirm(ConfirmLbl, false)) then
                        MembershipMgt.DeleteMembership(Rec."Entry No.", (not MembershipSetup.Get(Rec."Membership Code")));
                end;
            }
        }
        area(navigation)
        {
            action(Notifications)
            {
                Caption = 'Notifications';
                Image = Interaction;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Page "NPR MM Membership Notific.";
                RunPageLink = "Membership Entry No." = FIELD("Entry No.");
                RunPageView = SORTING("Membership Entry No.");

                ToolTip = 'Executes the Notifications action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action("Show Sponsorship Tickets")
            {
                Caption = 'Show Sponsorship Tickets';
                Ellipsis = true;
                Image = SalesPurchaseTeam;
                RunObject = Page "NPR MM Sponsor. Ticket Entry";
                RunPageLink = "Membership Entry No." = FIELD("Entry No.");
                RunPageView = SORTING("Membership Entry No.", "Event Type");

                ToolTip = 'Executes the Show Sponsorship Tickets action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action(CustomerCard)
            {
                Caption = 'Open Customer Card';
                Ellipsis = true;
                Image = Customer;
                RunObject = Page "Customer Card";
                RunPageLink = "No." = field("Customer No.");

                ToolTip = 'Opens the Customer Card';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action("Arrival Log")
            {
                Caption = 'Arrival Log';
                Ellipsis = true;
                Image = Log;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Member Arrival Log";
                RunPageLink = "External Membership No." = FIELD("External Membership No.");

                ToolTip = 'Executes the Arrival Log action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action("Open Coupons")
            {
                Caption = 'Coupons';
                Ellipsis = true;
                Image = Voucher;

                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                RunObject = Page "NPR NpDc Coupons";
                RunPageLink = "Customer No." = FIELD("Customer No.");

                ToolTip = 'Opens Coupons List';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action(Achievements)
            {
                Caption = 'Achievements';
                ToolTip = 'This action opens the achievements and progress list for the membership.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = History;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    MemberGoals: Page "NPR MM AchMemberGoalList";
                    Goals: Record "NPR MM AchGoal";
                begin
                    Goals.FilterGroup(248);
                    Goals.SetFilter(CommunityCode, '=%1', Rec."Community Code");
                    Goals.SetFilter(MembershipCode, '=%1', Rec."Membership Code");
                    Goals.SetFilter(Activated, '=%1', true);
                    Goals.SetFilter(MembershipEntryNoFilter, '=%1', Rec."Entry No.");
                    Goals.FilterGroup(0);
                    MemberGoals.SetTableView(Goals);
                    MemberGoals.Run();
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
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Customer Ledger Entries";
                    RunPageLink = "Customer No." = FIELD("Customer No.");
                    RunPageView = SORTING("Customer No.");
                    ShortCutKey = 'Ctrl+F7';

                    ToolTip = 'Executes the Ledger E&ntries action';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                action(ItemLedgerEntries)
                {
                    Caption = 'Item Ledger Entries';
                    Image = ItemLedger;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Executes the Item Ledger Entries action';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnAction()
                    var
                        NoCustomerLbl: Label 'No Customer added to this Membership';
                        ItemLedgerEntry: Record "Item Ledger Entry";
                        ItemLedgerEntries: Page "Item Ledger Entries";
                    begin
                        if Rec."Customer No." = '' then begin
                            Message(NoCustomerLbl);
                            exit;
                        end;
                        ItemLedgerEntry.SetRange("Source No.", Rec."Customer No.");
                        ItemLedgerEntries.SetTableView(ItemLedgerEntry);
                        ItemLedgerEntries.RunModal();
                    end;
                }
                action(Statistics)
                {
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Customer Statistics";
                    RunPageLink = "No." = FIELD("Customer No.");
                    ShortCutKey = 'F7';

                    ToolTip = 'Executes the Statistics action';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                action("Membership Details Report")
                {
                    Caption = 'Membership Details Report';
                    Image = Report;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Executes the Statistics action';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnAction()
                    var
                        Membership: Record "NPR MM Membership";
                    begin
                        Membership.SetRange("Membership Code", Rec."Membership Code");
                        Membership.SetRange("External Membership No.", Rec."External Membership No.");
                        Membership.SetFilter("Date Filter", '01-01-0000..');
                        Report.Run(Report::"NPR MM Membership Points Det.", true, false, Membership);
                    end;
                }
            }
            group("Raptor Integration")
            {
                Caption = 'Raptor Integration';
                action(RaptorBrowsingHistory)
                {
                    Caption = 'Browsing History';
                    Enabled = RaptorEnabled;
                    Image = ViewRegisteredOrder;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    Visible = RaptorEnabled;

                    ToolTip = 'Executes the Browsing History action';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnAction()
                    var
                        RaptorAction: Record "NPR Raptor Action";
                        RaptorMgt: Codeunit "NPR Raptor Management";
                    begin

                        Rec.TestField("Customer No.");
                        if RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserIdHistory(), true, RaptorAction) then
                            RaptorMgt.ShowRaptorData(RaptorAction, Rec."Customer No.");

                    end;
                }
                action(RaptorRecommendations)
                {
                    Caption = 'Recommendations';
                    Enabled = RaptorEnabled;
                    Image = SuggestElectronicDocument;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    Visible = RaptorEnabled;

                    ToolTip = 'Executes the Recommendations action';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnAction()
                    var
                        RaptorAction: Record "NPR Raptor Action";
                        RaptorMgt: Codeunit "NPR Raptor Management";
                    begin

                        Rec.TestField("Customer No.");
                        if RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserRecommendations(), true, RaptorAction) then
                            RaptorMgt.ShowRaptorData(RaptorAction, Rec."Customer No.");

                    end;
                }
            }
        }
        area(Reporting)
        {
            group(Loyalty)
            {
                action("Loyalty Point Summary")
                {
                    Caption = 'Loyalty Point Summary';
                    Image = CreditCard;
                    RunObject = Report "NPR MM Membersh. Points Summ.";

                    ToolTip = 'Executes the Loyalty Point Summary action';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                action("Loyalty Point Value")
                {
                    Caption = 'Loyalty Point Value';
                    Image = LimitedCredit;
                    RunObject = Report "NPR MM Membership Points Value";

                    ToolTip = 'Executes the Loyalty Point Value action';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                action("Loyalty Point Details")
                {
                    Caption = 'Loyalty Point Details';
                    Image = CreditCardLog;
                    RunObject = Report "NPR MM Membership Points Det.";

                    ToolTip = 'Executes the Loyalty Point Details action';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        ValidFromDate: Date;
        ValidUntilDate: Date;
        MaxValidUntilDate: Date;
        PlaceHolder1Lbl: Label '%1 / %2 / %3', Locked = true;
        PlaceHolder2Lbl: Label '%1 - %2', Locked = true;
        PlaceHolder3Lbl: Label '%1 - %2 (%3)', Locked = true;
    begin
        MembershipManagement.GetMemberCount(Rec."Entry No.", AdminMemberCount, MemberMemberCount, AnonymousMemberCount);
        ShowMemberCountAs := StrSubstNo(PlaceHolder1Lbl, AdminMemberCount, MemberMemberCount, AnonymousMemberCount);

        NeedsActivation := MembershipManagement.MembershipNeedsActivation(Rec."Entry No.");
        ShowCurrentPeriod := NOT_ACTIVATED;
        if (not NeedsActivation) then begin
            MembershipManagement.GetMembershipValidDate(Rec."Entry No.", Today, ValidFromDate, ValidUntilDate);
            ShowCurrentPeriod := StrSubstNo(PlaceHolder2Lbl, ValidFromDate, ValidUntilDate);

            MembershipManagement.GetMembershipMaxValidUntilDate(Rec."Entry No.", MaxValidUntilDate);
            if (ValidUntilDate <> MaxValidUntilDate) then
                ShowCurrentPeriod := StrSubstNo(PlaceHolder3Lbl, ValidFromDate, ValidUntilDate, MaxValidUntilDate);

            if (ValidUntilDate < Today) then
                ShowCurrentPeriod := StrSubstNo(PlaceHolder3Lbl, ValidFromDate, ValidUntilDate, MEMBERSHIP_EXPIRED);
        end;

        NPRAttrEditable := CurrPage.Editable();

        CurrPage.PointsSummary.PAGE.FillPageSummary(Rec."Entry No.");
        CurrPage.PointsSummary.PAGE.Update(false);

    end;

    trigger OnAfterGetRecord()
    begin

        GetMasterDataAttributeValue();

    end;

    trigger OnOpenPage()
    var
        RaptorSetup: Record "NPR Raptor Setup";
    begin

        NPRAttrManagement.GetAttributeVisibility(GetAttributeTableId(), NPRAttrVisibleArray);
        // Because NAV is stupid!
        NPRAttrVisible01 := NPRAttrVisibleArray[1];
        NPRAttrVisible02 := NPRAttrVisibleArray[2];
        NPRAttrVisible03 := NPRAttrVisibleArray[3];
        NPRAttrVisible04 := NPRAttrVisibleArray[4];
        NPRAttrVisible05 := NPRAttrVisibleArray[5];
        NPRAttrVisible06 := NPRAttrVisibleArray[6];
        NPRAttrVisible07 := NPRAttrVisibleArray[7];
        NPRAttrVisible08 := NPRAttrVisibleArray[8];
        NPRAttrVisible09 := NPRAttrVisibleArray[9];
        NPRAttrVisible10 := NPRAttrVisibleArray[10];
        NPRAttrEditable := CurrPage.Editable();

        RaptorEnabled := (RaptorSetup.Get() and RaptorSetup."Enable Raptor Functions");

    end;

    var
        AdminMemberCount: Integer;
        MemberMemberCount: Integer;
        AnonymousMemberCount: Integer;
        ShowMemberCountAs: Text;
        ShowCurrentPeriod: Text;
        NeedsActivation: Boolean;
        NOT_ACTIVATED: Label 'Not activated';
        ADD_MEMBER_SETUP: Label 'Could not find %1 with %2 set to option %3 for %4 %5. Additional members can''t be added until setup is completed.';
        NPRAttrTextArray: array[40] of Text;
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        NPRAttrEditable: Boolean;
        NPRAttrVisibleArray: array[40] of Boolean;
        NPRAttrVisible01: Boolean;
        NPRAttrVisible02: Boolean;
        NPRAttrVisible03: Boolean;
        NPRAttrVisible04: Boolean;
        NPRAttrVisible05: Boolean;
        NPRAttrVisible06: Boolean;
        NPRAttrVisible07: Boolean;
        NPRAttrVisible08: Boolean;
        NPRAttrVisible09: Boolean;
        NPRAttrVisible10: Boolean;
        RaptorEnabled: Boolean;
        MEMBERSHIP_EXPIRED: Label 'Expired';
        EXT_NO_CHANGE: Label 'Please note that changing the external number requires re-printing of documents where this number is used. Do you want to continue?';

    local procedure AddMembershipMember()
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipRole: Record "NPR MM Membership Role";
        GuardianMember: Record "NPR MM Member";
        MemberInfoCapturePage: Page "NPR MM Member Info Capture";
        PageAction: Action;
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        ResponseMessage: Text;
    begin

        MemberInfoCapture.Init();

        MembershipSalesSetup.SetFilter(Type, '=%1', MembershipSalesSetup.Type::ITEM);
        MembershipSalesSetup.SetFilter("Membership Code", '=%1', Rec."Membership Code");
        MembershipSalesSetup.SetFilter("Business Flow Type", '=%1', MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER);
        if (not MembershipSalesSetup.FindFirst()) then
            Error(ADD_MEMBER_SETUP, MembershipSalesSetup.TableCaption,
              MembershipSalesSetup.FieldCaption("Business Flow Type"), MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER,
              Rec.FieldCaption("Membership Code"), Rec."Membership Code");

        MemberInfoCapture."Item No." := MembershipSalesSetup."No.";
        MemberInfoCapture."Membership Entry No." := Rec."Entry No.";
        MemberInfoCapture."External Membership No." := Rec."External Membership No.";

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::GUARDIAN);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        if (MembershipRole.FindFirst()) then begin
            GuardianMember.Get(MembershipRole."Member Entry No.");
            MemberInfoCapture."Guardian External Member No." := GuardianMember."External Member No.";
            MemberInfoCapture."E-Mail Address" := GuardianMember."E-Mail Address";
        end;

        MemberInfoCapture.Insert();

        MemberInfoCapturePage.SetRecord(MemberInfoCapture);
        MemberInfoCapture.SetFilter("Entry No.", '=%1', MemberInfoCapture."Entry No.");
        MemberInfoCapturePage.SetTableView(MemberInfoCapture);
        Commit();

        MemberInfoCapturePage.LookupMode(true);
        PageAction := MemberInfoCapturePage.RunModal();
        if (PageAction = ACTION::LookupOK) then begin
            MemberInfoCapturePage.GetRecord(MemberInfoCapture);
            MembershipManagement.AddMemberAndCard(Rec."Entry No.", MemberInfoCapture, false, MemberInfoCapture."Member Entry No", ResponseMessage);

        end;
    end;

    local procedure AddMembershipGuardian()
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberInfoCapturePage: Page "NPR MM Member Info Capture";
        PageAction: Action;
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
    begin

        MemberInfoCapture."Membership Entry No." := Rec."Entry No.";
        MemberInfoCapture."External Membership No." := Rec."External Membership No.";
        MemberInfoCapture.Insert();

        MemberInfoCapturePage.SetRecord(MemberInfoCapture);
        MemberInfoCapture.SetFilter("Entry No.", '=%1', MemberInfoCapture."Entry No.");
        MemberInfoCapturePage.SetTableView(MemberInfoCapture);
        Commit();

        MemberInfoCapturePage.SetAddMembershipGuardianMode();
        MemberInfoCapturePage.LookupMode(true);
        PageAction := MemberInfoCapturePage.RunModal();
        if (PageAction = ACTION::LookupOK) then begin
            MemberInfoCapturePage.GetRecord(MemberInfoCapture);

            // MembershipManagement.AddGuardianMember (Rec."Entry No.", MemberInfoCapture."Guardian External Member No.");
            MembershipManagement.AddGuardianMember(Rec."Entry No.", MemberInfoCapture."Guardian External Member No.", MemberInfoCapture."GDPR Approval");

        end;
    end;

    local procedure RedeemPoints(Membership: Record "NPR MM Membership")
    var
        LoyaltyPointMgt: Codeunit "NPR MM Loyalty Point Mgt.";
        LoyaltyCouponMgr: Codeunit "NPR MM Loyalty Coupon Mgr";
        TempLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary;
    begin

        if (LoyaltyPointMgt.GetCouponToRedeemPOS(Membership."Entry No.", TempLoyaltyPointsSetup, 999999)) then begin
            repeat
                Membership.CalcFields("Remaining Points");

                if (TempLoyaltyPointsSetup."Value Assignment" = TempLoyaltyPointsSetup."Value Assignment"::FROM_COUPON) then
                    if (TempLoyaltyPointsSetup."Points Threshold" <= Membership."Remaining Points") then

                        //LoyaltyCouponMgr.IssueOneCouponAndPrint (TmpLoyaltyPointsSetup."Coupon Type Code", Membership."Entry No.", TmpLoyaltyPointsSetup."Points Threshold",0);
                        LoyaltyCouponMgr.IssueOneCouponAndPrint(TempLoyaltyPointsSetup."Coupon Type Code", Membership."Entry No.", Membership."External Membership No.", Today, TempLoyaltyPointsSetup."Points Threshold", 0);

            until (TempLoyaltyPointsSetup.Next() = 0);
        end;
    end;

    local procedure ActivateMembership()
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Rec."Entry No.");
        if (MembershipEntry.IsEmpty()) then begin
            MembershipSalesSetup.SetFilter("Business Flow Type", '=%1', MembershipSalesSetup."Business Flow Type"::MEMBERSHIP);
            MembershipSalesSetup.SetFilter("Membership Code", '=%1', Rec."Membership Code");
            MembershipSalesSetup.SetFilter(Blocked, '=%1', false);
            MembershipSalesSetup.FindFirst();

            MemberInfoCapture.Init();
            MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;

            MembershipManagement.AddMembershipLedgerEntry_NEW(Rec."Entry No.", Rec."Issued Date", MembershipSalesSetup, MemberInfoCapture);

        end;

        MembershipManagement.ActivateMembershipLedgerEntry(Rec."Entry No.", Today);
    end;

    local procedure AutoRenewMembership(MembershipEntryNo: Integer)
    var
        MembershipAutoRenew: Codeunit "NPR MM Membership Auto Renew";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        TempMembershipAutoRenew: Record "NPR MM Membership Auto Renew" temporary;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        RenewStartDate: Date;
        RenewUntilDate: Date;
        RenewUnitPrice: Decimal;
        EntryNo: Integer;
        SalesHeader: Record "Sales Header";
        SalesInvoicePage: Page "Sales Invoice";
    begin

        TempMembershipAutoRenew.Init();
        MembershipManagement.GetMembershipMaxValidUntilDate(MembershipEntryNo, TempMembershipAutoRenew."Valid Until Date");
        EntryNo := MembershipAutoRenew.AutoRenewOneMembership(0, MembershipEntryNo, TempMembershipAutoRenew, RenewStartDate, RenewUntilDate, RenewUnitPrice, false);
        MemberInfoCapture.Get(EntryNo);
        if (MemberInfoCapture."Response Status" <> MemberInfoCapture."Response Status"::COMPLETED) then
            Error(MemberInfoCapture."Response Message");

        Commit();
        SalesHeader.Get(SalesHeader."Document Type"::Invoice, TempMembershipAutoRenew."Last Invoice No.");
        SalesInvoicePage.SetRecord(SalesHeader);
        SalesInvoicePage.RunModal();
    end;

    local procedure SetMasterDataAttributeValue(AttributeNumber: Integer)
    begin

        NPRAttrManagement.SetEntryAttributeValue(GetAttributeTableId(), AttributeNumber, Rec."Entry No.", NPRAttrTextArray[AttributeNumber]);

    end;

    local procedure GetMasterDataAttributeValue()
    begin

        NPRAttrManagement.GetEntryAttributeValue(NPRAttrTextArray, GetAttributeTableId(), Rec."Entry No.");
        NPRAttrEditable := CurrPage.Editable();

    end;

    internal procedure GetAttributeVisibility(AttributeNumber: Integer): Boolean
    begin

        exit(NPRAttrVisibleArray[AttributeNumber]);

    end;

    local procedure GetAttributeTableId(): Integer
    begin

        exit(DATABASE::"NPR MM Membership");

    end;

    local procedure GetAttributeCaptionClass(AttributeNumber: Integer): Text[50]
    var
        PlaceHolderLbl: Label '6014555,%1,%2,2', Locked = true;
    begin
        exit(StrSubstNo(PlaceHolderLbl, GetAttributeTableId(), AttributeNumber));
    end;

    local procedure OnAttributeLookup(AttributeNumber: Integer)
    begin
        NPRAttrManagement.OnPageLookUp(GetAttributeTableId(), AttributeNumber, Format(Rec."Entry No.", 0, '<integer>'), NPRAttrTextArray[AttributeNumber]);
    end;

    local procedure IssueAdHocSponsorshipTickets(MembershipEntryNo: Integer)
    var
        SponsorshipTicketMgmt: Codeunit "NPR MM Sponsorship Ticket Mgt";
        ResponseMessage: Text;
    begin

        if (not SponsorshipTicketMgmt.IssueAdHocTicket(MembershipEntryNo, ResponseMessage)) then
            Error(ResponseMessage);
    end;
}

