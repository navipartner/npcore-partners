page 6060124 "NPR MM Membership Setup"
{

    Caption = 'Membership Setup';
    CardPageID = "NPR MM Members.Setup Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR MM Membership Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'General';
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Membership Type"; "Membership Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Type field';
                }
                field("Loyalty Card"; "Loyalty Card")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Loyalty Card field';
                }
                field("Loyalty Code"; "Loyalty Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Loyalty Code field';
                }
                field("Customer Config. Template Code"; "Customer Config. Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Config. Template Code field';
                }
                field("Contact Config. Template Code"; "Contact Config. Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Config. Template Code field';
                }
                field("Membership Customer No."; "Membership Customer No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Membership Customer No. field';
                }
                field("Member Information"; "Member Information")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Information field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Blocked At"; "Blocked At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked At field';
                }
                field(Perpetual; Perpetual)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Perpetual field';
                }
                field("Member Role Assignment"; "Member Role Assignment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Role Assignment field';
                }
                field("Create Welcome Notification"; "Create Welcome Notification")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Welcome Notification field';
                }
                field("Create Renewal Notifications"; "Create Renewal Notifications")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Renewal Notifications field';
                }
                field("Membership Member Cardinality"; "Membership Member Cardinality")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Member Cardinality field';
                }
                field("Anonymous Member Cardinality"; "Anonymous Member Cardinality")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Anonymous Member Cardinality field';
                }
                field("Community Code"; "Community Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Community Code field';
                }
                field("Allow Membership Delete"; "Allow Membership Delete")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Membership Delete field';
                }
                field("Confirm Member On Card Scan"; "Confirm Member On Card Scan")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Confirm Member On Card Scan field';
                }
                field("Web Service Print Action"; "Web Service Print Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Web Service Print Action field';
                }
                field("POS Print Action"; "POS Print Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Print Action field';
                }
                field("Account Print Object Type"; "Account Print Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account Print Object Type field';
                }
                field("Account Print Template Code"; "Account Print Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account Print Template Code field';
                }
                field("Account Print Object ID"; "Account Print Object ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account Print Object ID field';
                }
                field("Receipt Print Object Type"; "Receipt Print Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Print Object Type field';
                }
                field("Receipt Print Template Code"; "Receipt Print Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Print Template Code field';
                }
                field("Receipt Print Object ID"; "Receipt Print Object ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Print Object ID field';
                }
                field("Card Number Scheme"; "Card Number Scheme")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number Scheme field';
                }
                field("Card Number Prefix"; "Card Number Prefix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number Prefix field';
                }
                field("Card Number Length"; "Card Number Length")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number Length field';
                }
                field("Card Number Validation"; "Card Number Validation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number Validation field';
                }
                field("Card Number No. Series"; "Card Number No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number No. Series field';
                }
                field("Card Number Valid Until"; "Card Number Valid Until")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number Valid Until field';
                }
                field("Card Number Pattern"; "Card Number Pattern")
                {
                    ApplicationArea = All;
                    ToolTip = '<any text><[MA|MS|NS|N*x|A*x|X*x]><[...]><...>';
                }
                field("Card Print Object Type"; "Card Print Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Print Object Type field';
                }
                field("Card Print Template Code"; "Card Print Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Print Template Code field';
                }
                field("Card Print Object ID"; "Card Print Object ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Print Object ID field';
                }
                field("Card Expire Date Calculation"; "Card Expire Date Calculation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Expire Date Calculation field';
                }
                field("Ticket Item Barcode"; Rec."Ticket Item Barcode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Item Barcode field';
                }
                field("Ticket Print Model"; "Ticket Print Model")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Print Model field';
                }
                field("Ticket Print Object Type"; "Ticket Print Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Print Object Type field';
                }
                field("Ticket Print Object ID"; "Ticket Print Object ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Print Object ID field';
                }
                field("Ticket Print Template Code"; "Ticket Print Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Print Template Code field';
                }
                field("GDPR Mode"; "GDPR Mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the GDPR Mode field';
                }
                field("GDPR Agreement No."; "GDPR Agreement No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the GDPR Agreement No. field';
                }
                field("Enable NP Pass Integration"; "Enable NP Pass Integration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enable NP Pass Integration field';
                }
                field("Enable Age Verification"; "Enable Age Verification")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Enable Age Verification field';
                }
                field("Validate Age Against"; "Validate Age Against")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Validate Age Against field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Community action';
            }
            action("Membership Sales Setup")
            {
                Caption = 'Membership Sales Setup';
                Image = SetupList;
                Promoted = true;
                PromotedOnly = true;
                RunObject = Page "NPR MM Membership Sales Setup";
                RunPageLink = "Membership Code" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Membership Sales Setup action';
            }
            action("Membership Alteration")
            {
                Caption = 'Membership Alteration';
                Image = SetupList;
                Promoted = true;
                PromotedOnly = true;
                RunObject = Page "NPR MM Membership Alter.";
                RunPageLink = "From Membership Code" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Membership Alteration action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Member Communication Setup action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Membership Admission Setup action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Membership Limitation Setup action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Sponsorship Ticket Setup action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Memberships action';
            }
            action("Item List")
            {
                Caption = 'Item List';
                Image = List;
                RunObject = Page "Item List";
                ApplicationArea = All;
                ToolTip = 'Executes the Item List action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Turnstile Setup action';
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
                ApplicationArea = All;
                ToolTip = 'This action will create a wallet notification and send it (when notification is inline) for members not having a wallet.';

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
                ApplicationArea = All;
                ToolTip = ' This action will create a wallets notification, and send it when notification is inline.';

                trigger OnAction()
                begin
                    UpdateAllWallets(Rec.Code);
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
                ApplicationArea = All;
                RunObject = page "NPR MM Membership Rapid Pckg.";
                ToolTip = 'Executes the Deploy Rapidstart Package for Member module From Azure Blob Storage';
            }
        }
    }

    var
        PROCESSING: Label 'Processing. ';
        PENDING: Label 'Pending.... %1';
        SENT: Label 'Sent....... %1';
        NOT_SENT: Label 'Not Sent... %1';
        FAILED: Label 'Failed..... %1';
        WALLET_RESULT: Label '%1 memberships were processed, and resulted in the following notifications: \\%2\\%3\\%4\\%5';
        REMAINING: Label 'Remaining.. ';
        CONFIRM_MSG: Label '%1 members for %2 do not have a wallet created for them. Do you want to proceed with creating them?';
        NOTIFICATION_OPTION: Label '1,10,100,1000,10000,Unlimited';
        NOTIFICATION_TEXT: Label 'Max number of notifications to create in this session:';
        UPDATE_MSG: Label 'Updates messages will be sent to %1 wallets.';

    trigger OnOpenPage()
    begin

        Rec.SetFilter(Blocked, '=%1', false);
    end;

    local procedure CreateMissingWallets(MembershipCode: Code[20])
    var
        MembershipRole: Record "NPR MM Membership Role";
        MembershipNotification: Record "NPR MM Membership Notific.";
        MemberNotificationEntry: Record "NPR MM Member Notific. Entry";
        MemberNotification: Codeunit "NPR MM Member Notification";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
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

        MaxToCreate := STRMENU(NOTIFICATION_OPTION, 0, NOTIFICATION_TEXT);
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
             PROCESSING +
             StrSubstNo(PENDING, '#2######') +
             StrSubstNo(SENT, '#3######') +
             StrSubstNo(NOT_SENT, '#4######') +
             StrSubstNo(FAILED, '#5######') +
             REMAINING
             );

            ProgressBase := 1;
            if (MissingWalletCount > 100) then
                ProgressBase := ROUND(MissingWalletCount / 100, 1, '<');

            repeat

                if (MembershipManagement.IsMembershipActive(MembershipRole."Membership Entry No.", TODAY, false)) then begin
                    EntryNo := MemberNotification.CreateWalletSendNotification(MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.", 0, TODAY);

                    if (MembershipNotification.Get(EntryNo)) then begin
                        RemainingToCreate -= 1;

                        if (MembershipNotification."Processing Method" = MembershipNotification."Processing Method"::INLINE) then
                            MemberNotification.HandleMembershipNotification(MembershipNotification);

                        if (MemberNotificationEntry.Get(EntryNo, MembershipRole."Member Entry No.")) then
                            Summary[1 + MemberNotificationEntry."Notification Send Status"] += 1;

                    end;
                end;

                if (ProgressIndex MOD ProgressBase = 0) then begin
                    Window.Update(1, ROUND(ProgressIndex / MissingWalletCount * 10000, 1));
                    Window.Update(2, Summary[1 + MemberNotificationEntry."Notification Send Status"::PENDING]);
                    Window.Update(3, Summary[1 + MemberNotificationEntry."Notification Send Status"::SENT]);
                    Window.Update(4, Summary[1 + MemberNotificationEntry."Notification Send Status"::NOT_SENT]);
                    Window.Update(5, Summary[1 + MemberNotificationEntry."Notification Send Status"::FAILED]);
                    Window.Update(6, ROUND(RemainingToCreate / MaxToCreate * 10000, 1));
                end;

                ProgressIndex += 1;
                Commit();

            until ((MembershipRole.NEXT() = 0) or (RemainingToCreate = 0));
            Window.Close();

            Message(WALLET_RESULT, MissingWalletCount,
              StrSubstNo(PENDING, Summary[1 + MemberNotificationEntry."Notification Send Status"::PENDING]),
              StrSubstNo(SENT, Summary[1 + MemberNotificationEntry."Notification Send Status"::SENT]),
              StrSubstNo(NOT_SENT, Summary[1 + MemberNotificationEntry."Notification Send Status"::NOT_SENT]),
              StrSubstNo(FAILED, Summary[1 + MemberNotificationEntry."Notification Send Status"::FAILED]));

        end;

    end;

    local procedure UpdateAllWallets(MembershipCode: Code[20])
    var
        MembershipRole: Record "NPR MM Membership Role";
        MembershipNotification: Record "NPR MM Membership Notific.";
        MemberNotificationEntry: Record "NPR MM Member Notific. Entry";
        MemberNotification: Codeunit "NPR MM Member Notification";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
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
            Window.Open(PROCESSING);

            ProgressBase := 1;
            if (UpdateWalletCount > 100) then
                ProgressBase := ROUND(UpdateWalletCount / 100, 1, '<');

            repeat

                if (MembershipManagement.IsMembershipActive(MembershipRole."Membership Entry No.", TODAY, false)) then begin
                    EntryNo := MemberNotification.CreateUpdateWalletNotification(MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.", 0, TODAY);

                    if (MembershipNotification.Get(EntryNo)) then begin

                        if (MembershipNotification."Processing Method" = MembershipNotification."Processing Method"::INLINE) then
                            MemberNotification.HandleMembershipNotification(MembershipNotification);

                    end;
                end;

                if (ProgressIndex MOD ProgressBase = 0) then begin
                    Window.Update(1, ROUND(ProgressIndex / UpdateWalletCount * 10000, 1));
                end;

                ProgressIndex += 1;
                Commit();

            until (MembershipRole.NEXT() = 0);
            Window.Close();

        end;

    end;
}

