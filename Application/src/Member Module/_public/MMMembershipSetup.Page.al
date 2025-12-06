page 6060124 "NPR MM Membership Setup"
{
    Caption = 'Membership Setup';
    ContextSensitiveHelpPage = 'docs/entertainment/membership/intro/';
    CardPageID = "NPR MM Members.Setup Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR MM Membership Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("HeyLoyalty Name"; HeyLoyaltyName)
                {
                    Caption = 'HeyLoyalty Name';
                    ToolTip = 'Specifies the id used for the membership at HeyLoyalty.';
                    ApplicationArea = NPRHeyLoyalty;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                        HLMappedValueMgt.SetMappedValue(Rec.RecordId(), Rec.FieldNo(Description), HeyLoyaltyName, true);
                        CurrPage.Update(false);
                    end;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Type"; Rec."Membership Type")
                {
                    ToolTip = 'Specifies the value of the Membership Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Loyalty Card"; Rec."Loyalty Card")
                {
                    ToolTip = 'Specifies the value of the Loyalty Card field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Loyalty Code"; Rec."Loyalty Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Loyalty Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Customer Config. Template Code"; Rec."Customer Config. Template Code")
                {
                    ToolTip = 'Specifies the value of the Customer Config. Template Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Contact Config. Template Code"; Rec."Contact Config. Template Code")
                {
                    ToolTip = 'Specifies the value of the Contact Config. Template Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Customer No."; Rec."Membership Customer No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Membership Customer No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Member Information"; Rec."Member Information")
                {
                    ToolTip = 'Specifies the value of the Member Information field';
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
                field(Perpetual; Rec.Perpetual)
                {
                    ToolTip = 'Specifies the value of the Perpetual field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Member Role Assignment"; Rec."Member Role Assignment")
                {
                    ToolTip = 'Specifies the value of the Member Role Assignment field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Create Welcome Notification"; Rec."Create Welcome Notification")
                {
                    ToolTip = 'Specifies the value of the Create Welcome Notification field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Create Renewal Notifications"; Rec."Create Renewal Notifications")
                {
                    ToolTip = 'Specifies the value of the Create Renewal Notifications field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Create Renewal Success Notif"; Rec."Create Renewal Success Notif")
                {
                    ToolTip = 'Specifies the value of the Create Renewal Success Notifications field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Create Renewal Failure Notif"; Rec."Create Renewal Failure Notif")
                {
                    ToolTip = 'Specifies the value of the Create Renewal Failure Notifications field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Create AutoRenewal Enabl Notif"; Rec."Create AutoRenewal Enabl Notif")
                {
                    ToolTip = 'Specifies the value of the Create Auto-Renewal Enabled Notifications field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Create AutoRenewal Disbl Notif"; Rec."Create AutoRenewal Disbl Notif")
                {
                    ToolTip = 'Specifies the value of the Create Auto-Renewal Disabled Notifications field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Member Cardinality"; Rec."Membership Member Cardinality")
                {
                    ToolTip = 'Specifies the value of the Membership Member Cardinality field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Anonymous Member Cardinality"; Rec."Anonymous Member Cardinality")
                {
                    ToolTip = 'Specifies the value of the Anonymous Member Cardinality field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Community Code"; Rec."Community Code")
                {
                    ToolTip = 'Specifies the value of the Community Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Allow Membership Delete"; Rec."Allow Membership Delete")
                {
                    ToolTip = 'Specifies the value of the Allow Membership Delete field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Confirm Member On Card Scan"; Rec."Confirm Member On Card Scan")
                {
                    ToolTip = 'Specifies the value of the Confirm Member On Card Scan field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Web Service Print Action"; Rec."Web Service Print Action")
                {
                    ToolTip = 'Specifies the value of the Web Service Print Action field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("POS Print Action"; Rec."POS Print Action")
                {
                    ToolTip = 'Specifies the value of the POS Print Action field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Account Print Object Type"; Rec."Account Print Object Type")
                {
                    ToolTip = 'Specifies the value of the Account Print Object Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Account Print Template Code"; Rec."Account Print Template Code")
                {
                    ToolTip = 'Specifies the value of the Account Print Template Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Account Print Object ID"; Rec."Account Print Object ID")
                {
                    ToolTip = 'Specifies the value of the Account Print Object ID field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Receipt Print Object Type"; Rec."Receipt Print Object Type")
                {
                    ToolTip = 'Specifies the value of the Receipt Print Object Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Receipt Print Template Code"; Rec."Receipt Print Template Code")
                {
                    ToolTip = 'Specifies the value of the Receipt Print Template Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Editable = not TemplateCodeBlocked;
                }
                field("Receipt Print Object ID"; Rec."Receipt Print Object ID")
                {
                    ToolTip = 'Specifies the value of the Receipt Print Object ID field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Number Scheme"; Rec."Card Number Scheme")
                {
                    ToolTip = 'Specifies the value of the Card Number Scheme field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Number Prefix"; Rec."Card Number Prefix")
                {
                    ToolTip = 'Specifies the value of the Card Number Prefix field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Number Length"; Rec."Card Number Length")
                {
                    ToolTip = 'Specifies the value of the Card Number Length field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Number Validation"; Rec."Card Number Validation")
                {
                    ToolTip = 'Specifies the value of the Card Number Validation field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Number No. Series"; Rec."Card Number No. Series")
                {
                    ToolTip = 'Specifies the value of the Card Number No. Series field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Number Valid Until"; Rec."Card Number Valid Until")
                {
                    ToolTip = 'Specifies the value of the Card Number Valid Until field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Number Pattern"; Rec."Card Number Pattern")
                {
                    ToolTip = '<any text><[MA|MS|NS|N*x|A*x|X*x]><[...]><...>';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Print Object Type"; Rec."Card Print Object Type")
                {
                    ToolTip = 'Specifies the value of the Card Print Object Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Print Template Code"; Rec."Card Print Template Code")
                {
                    ToolTip = 'Specifies the value of the Card Print Template Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Print Object ID"; Rec."Card Print Object ID")
                {
                    ToolTip = 'Specifies the value of the Card Print Object ID field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Expire Date Calculation"; Rec."Card Expire Date Calculation")
                {
                    ToolTip = 'Specifies the value of the Card Expire Date Calculation field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Ticket Item Barcode"; Rec."Ticket Item Barcode")
                {
                    ToolTip = 'Specifies the value of the Ticket Item Barcode field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Ticket Print Model"; Rec."Ticket Print Model")
                {
                    ToolTip = 'Specifies the value of the Ticket Print Model field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Ticket Print Object Type"; Rec."Ticket Print Object Type")
                {
                    ToolTip = 'Specifies the value of the Ticket Print Object Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Ticket Print Object ID"; Rec."Ticket Print Object ID")
                {
                    ToolTip = 'Specifies the value of the Ticket Print Object ID field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Ticket Print Template Code"; Rec."Ticket Print Template Code")
                {
                    ToolTip = 'Specifies the value of the Ticket Print Template Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("GDPR Mode"; Rec."GDPR Mode")
                {
                    ToolTip = 'Specifies the value of the GDPR Mode field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("GDPR Agreement No."; Rec."GDPR Agreement No.")
                {
                    ToolTip = 'Specifies the value of the GDPR Agreement No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Enable NP Pass Integration"; Rec."Enable NP Pass Integration")
                {
                    ToolTip = 'Specifies the value of the Enable NP Pass Integration field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Enable Age Verification"; Rec."Enable Age Verification")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Enable Age Verification field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Validate Age Against"; Rec."Validate Age Against")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Validate Age Against field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Defer Cust. Update Alterations"; Rec."Defer Cust. Update Alterations")
                {
                    ToolTip = 'Specifies if customer defer update on alterations should be run';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Community)
            {
                Caption = 'Community';
                Image = Group;
                RunObject = Page "NPR MM Member Community";
                ToolTip = 'Executes the Community action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action("Membership Sales Setup")
            {
                Caption = 'Membership Sales Setup';
                Image = SetupList;
                Promoted = true;
                PromotedOnly = true;
                RunObject = Page "NPR MM Membership Sales Setup";
                RunPageLink = "Membership Code" = FIELD(Code);
                ToolTip = 'Executes the Membership Sales Setup action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action("Membership Alteration")
            {
                Caption = 'Membership Alteration';
                Image = SetupList;
                Promoted = true;
                PromotedOnly = true;
                RunObject = Page "NPR MM Membership Alter.";
                RunPageLink = "From Membership Code" = FIELD(Code);
                ToolTip = 'Executes the Membership Alteration action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action("Member Communication Setup")
            {
                Caption = 'Member Communication Setup';
                Image = ChangeDimensions;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Member Comm. Setup";
                RunPageLink = "Membership Code" = FIELD(Code);
                ToolTip = 'Executes the Member Communication Setup action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            separator(Separator6014404)
            {
            }
            action("Membership Admission Setup")
            {
                Caption = 'Membership Admission Setup';
                Image = SetupLines;
                RunObject = Page "NPR MM Members. Admis. Setup";
                RunPageLink = "Membership  Code" = FIELD(Code);
                ToolTip = 'Executes the Membership Admission Setup action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action("Membership Limitation Setup")
            {
                Caption = 'Membership Limitation Setup';
                Ellipsis = true;
                Image = Lock;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Membership Lim. Setup";
                RunPageLink = "Membership  Code" = FIELD(Code);
                ToolTip = 'Executes the Membership Limitation Setup action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action("Sponsorship Ticket Setup")
            {
                Caption = 'Sponsorship Ticket Setup';
                Ellipsis = true;
                Image = SetupLines;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
                RunObject = Page "NPR MM Sponsors. Ticket Setup";
                RunPageLink = "Membership Code" = FIELD(Code);
                ToolTip = 'Executes the Sponsorship Ticket Setup action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            separator(Separator6014405)
            {
            }
            action(Memberships)
            {
                Caption = 'Memberships';
                Image = List;
                RunObject = Page "NPR MM Memberships";
                RunPageLink = "Membership Code" = FIELD(Code);
                ToolTip = 'Executes the Memberships action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action("Item List")
            {
                Caption = 'Item List';
                Image = List;
                RunObject = Page "Item List";
                ToolTip = 'Executes the Item List action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            separator(Separator6014416)
            {
            }
            action("Turnstile Setup")
            {
                Caption = 'Turnstile Setup';
                Ellipsis = true;
                Image = BarCode;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Admission Service Setup";
                ToolTip = 'Executes the Turnstile Setup action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }
        area(Processing)
        {
            action(CreateWallets)
            {
                Caption = 'Create Wallets';
                Ellipsis = true;
                Image = Interaction;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'This action will create a wallet notification and send it (when notification is inline) for members not having a wallet.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                begin
                    CreateMissingWallets(Rec.Code);
                end;
            }

            action(UpdateWallets)
            {
                Caption = 'Update All Wallets';
                Ellipsis = true;
                Image = Interaction;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = ' This action will create a wallets notification, and send it when notification is inline.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                begin
                    UpdateAllWallets();
                end;
            }

            action(DeployRapidPackageFromAzureBlob)
            {
                Caption = 'Deploy Rapid Package From Azure';
                Image = ImportDatabase;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = page "NPR MM Membership Rapid Pckg.";
                ToolTip = 'Executes the Deploy Rapidstart Package for Member module From Azure Blob Storage';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action(CreateJQMembershipCustomerUpdate)
            {
                Caption = 'Create Membership Pending Customer Upate Job Queue';
                Image = Job;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Creates Job Queue to execute Defer Customer Update for Membership';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                trigger OnAction()
                var
                    JobQueueEntries: Page "Job Queue Entries";
                    StartJobQueueEntrMsg: Label 'Please make sure to start Job Queue Entry on Defer Customer Update On Alterations';
                begin
                    InitMembershipCustomerPendingUpdate();
                    Commit();
                    Message(StartJobQueueEntrMsg);
                    JobQueueEntries.Run();
                end;
            }
        }
    }

    var
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
        TemplateCodeBlocked: Boolean;
        HeyLoyaltyName: Text[100];
        PROCESSING: Label 'Processing: %1';
        PENDING: Label 'Pending: %1';
        SENT: Label 'Sent: %1';
        NOT_SENT: Label 'Not Sent: %1';
        FAILED: Label 'Failed: %1';
        REMAINING: Label 'Remaining: %1';
        WALLET_RESULT: Label '%1 memberships were processed, and resulted in the following notifications: \\%2\%3\%4\%5';
        CONFIRM_MSG: Label '%1 members for %2 do not have a wallet created for them. Do you want to proceed with creating them?';
        NOTIFICATION_OPTION: Label '1,10,100,1000,10000,Unlimited';
        NOTIFICATION_TEXT: Label 'Max number of notifications to create in this session:';
        UPDATE_MSG: Label 'Updates messages will be sent to %1 wallets.';

    trigger OnOpenPage()
    begin

        Rec.SetFilter(Blocked, '=%1', false);
    end;

    trigger OnAfterGetRecord()
    begin
        HeyLoyaltyName := HLMappedValueMgt.GetMappedValue(Rec.RecordId(), Rec.FieldNo(Description), false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        HeyLoyaltyName := '';
    end;

    local procedure CreateMissingWallets(MembershipCode: Code[20])
    var
        MembershipRole: Record "NPR MM Membership Role";
        MembershipNotification: Record "NPR MM Membership Notific.";
        MemberNotificationEntry: Record "NPR MM Member Notific. Entry";
        MemberNotification: Codeunit "NPR MM Member Notification";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        EntryNo: Integer;
        MissingWalletCount: Integer;
        Window: Dialog;
        ProgressBase: Integer;
        ProgressIndex: Integer;
        Summary: ARRAY[10] OF Integer;
        MaxToCreate: Integer;
        RemainingToCreate: Integer;
    begin

        MembershipRole.SetFilter(Blocked, '=%1', false);
        MembershipRole.SetFilter("Membership Code", '=%1', MembershipCode);
        MembershipRole.SetFilter("Wallet Pass Id", '=%1', '');
        MissingWalletCount := MembershipRole.Count();

        if (not Confirm(CONFIRM_MSG, true, MissingWalletCount, MembershipCode)) then
            Error('');

        MaxToCreate := StrMenu(NOTIFICATION_OPTION, 0, NOTIFICATION_TEXT);
        case MaxToCreate OF
            1:
                RemainingToCreate := 1;
            2:
                RemainingToCreate := 10;
            3:
                RemainingToCreate := 100;
            4:
                RemainingToCreate := 1000;
            5:
                RemainingToCreate := 10000;
            6:
                RemainingToCreate := MissingWalletCount;
            else
                Error('');
        end;

        if (RemainingToCreate > MissingWalletCount) then
            RemainingToCreate := MissingWalletCount;

        MaxToCreate := RemainingToCreate;

        if (MembershipRole.FindSet()) then begin
            Window.Open(
             StrSubstNo(PROCESSING, '#1######') +
             StrSubstNo(PENDING, '#2######') +
             StrSubstNo(SENT, '#3######') +
             StrSubstNo(NOT_SENT, '#4######') +
             StrSubstNo(FAILED, '#5######') +
             StrSubstNo(REMAINING, '#6######')
             );

            ProgressBase := 1;
            if (MissingWalletCount > 100) then
                ProgressBase := Round(MissingWalletCount / 100, 1, '<');

            repeat

                if (MembershipManagement.IsMembershipActive(MembershipRole."Membership Entry No.", Today(), false)) then begin
                    EntryNo := MemberNotification.CreateWalletSendNotification(MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.", 0, Today());

                    if (MembershipNotification.Get(EntryNo)) then begin
                        RemainingToCreate -= 1;

                        if (MembershipNotification."Processing Method" = MembershipNotification."Processing Method"::INLINE) then
                            MemberNotification.HandleMembershipNotification(MembershipNotification);

                        if (MemberNotificationEntry.Get(EntryNo, MembershipRole."Member Entry No.")) then
                            Summary[1 + MemberNotificationEntry."Notification Send Status"] += 1;

                    end;
                end;

                if (ProgressIndex MOD ProgressBase = 0) then begin
                    Window.Update(1, Round(ProgressIndex / MissingWalletCount * 100, 1));
                    Window.Update(2, Summary[1 + MemberNotificationEntry."Notification Send Status"::PENDING]);
                    Window.Update(3, Summary[1 + MemberNotificationEntry."Notification Send Status"::SENT]);
                    Window.Update(4, Summary[1 + MemberNotificationEntry."Notification Send Status"::NOT_SENT]);
                    Window.Update(5, Summary[1 + MemberNotificationEntry."Notification Send Status"::FAILED]);
                    Window.Update(6, Round(RemainingToCreate / MaxToCreate * 100, 1));
                end;

                ProgressIndex += 1;
                Commit();

            until ((MembershipRole.Next() = 0) or (RemainingToCreate = 0));
            Window.Close();

            Message(WALLET_RESULT, MissingWalletCount,
              StrSubstNo(PENDING, Summary[1 + MemberNotificationEntry."Notification Send Status"::PENDING]),
              StrSubstNo(SENT, Summary[1 + MemberNotificationEntry."Notification Send Status"::SENT]),
              StrSubstNo(NOT_SENT, Summary[1 + MemberNotificationEntry."Notification Send Status"::NOT_SENT]),
              StrSubstNo(FAILED, Summary[1 + MemberNotificationEntry."Notification Send Status"::FAILED]));

        end;

    end;

    local procedure UpdateAllWallets()
    var
        MembershipRole: Record "NPR MM Membership Role";
        MembershipNotification: Record "NPR MM Membership Notific.";
        MemberNotification: Codeunit "NPR MM Member Notification";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        EntryNo: Integer;
        UpdateWalletCount: Integer;
        Window: Dialog;
        ProgressBase: Integer;
        ProgressIndex: Integer;
    begin

        MembershipRole.SetFilter(Blocked, '=%1', false);
        MembershipRole.SetFilter("Membership Code", '=%1', Rec.Code);
        MembershipRole.SetFilter("Wallet Pass Id", '<>%1', '');
        UpdateWalletCount := MembershipRole.Count();

        if (not Confirm(UPDATE_MSG, true, UpdateWalletCount)) then
            Error('');

        if (MembershipRole.FindSet()) then begin
            Window.Open(StrSubstNo(PROCESSING, '#1######'));

            ProgressBase := 1;
            if (UpdateWalletCount > 100) then
                ProgressBase := Round(UpdateWalletCount / 100, 1, '<');

            repeat

                if (MembershipManagement.IsMembershipActive(MembershipRole."Membership Entry No.", Today(), false)) then begin
                    EntryNo := MemberNotification.CreateUpdateWalletNotification(MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.", 0, Today());

                    if (MembershipNotification.Get(EntryNo)) then begin

                        if (MembershipNotification."Processing Method" = MembershipNotification."Processing Method"::INLINE) then
                            MemberNotification.HandleMembershipNotification(MembershipNotification);

                    end;
                end;

                if (ProgressIndex mod ProgressBase = 0) then begin
                    Window.Update(1, Round(ProgressIndex / UpdateWalletCount * 100, 1));
                end;

                ProgressIndex += 1;
                Commit();

            until (MembershipRole.Next() = 0);
            Window.Close();

        end;
    end;

    local procedure InitMembershipCustomerPendingUpdate(): Boolean
    var
        JobQueueCategory: Record "Job Queue Category";
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NotBeforeDateTime: DateTime;
        NextRunDateFormula: DateFormula;
        JobCategoryDescrLbl: Label 'Membership Customer Update', MaxLength = 30;
        JobQueueDescrLbl: Label 'Membership Customer Pending Update', MaxLength = 250;
    begin
        NotBeforeDateTime := CreateDateTime(Today, 020000T);
        Evaluate(NextRunDateFormula, '<1D>');
        JobQueueMgt.SetJobTimeout(4, 0);  //4 hours
        JobQueueCategory.InsertRec(JQCategoryCode(), JobCategoryDescrLbl);
        JobQueueMgt.SetProtected(true);

        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR MM Update Customer Pending",
            '',
            JobQueueDescrLbl,
            NotBeforeDateTime,
            DT2Time(NotBeforeDateTime),
            030000T,
            NextRunDateFormula,
            JQCategoryCode(),
            JobQueueEntry)
        then begin
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
            exit(true);
        end;
    end;

    local procedure JQCategoryCode(): Code[10]
    begin
        exit('MEMCUSTUPD');
    end;

    trigger OnAfterGetCurrRecord()
    var
        NewAttractionPrintExp: Codeunit "NPR New Attraction Print Exp";
    begin
        TemplateCodeBlocked := NewAttractionPrintExp.IsFeatureEnabled();
    end;
}

