page 6060124 "NPR MM Membership Setup"
{

    Caption = 'Membership Setup';
    CardPageID = "NPR MM Members.Setup Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR MM Membership Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


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
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Type"; Rec."Membership Type")
                {

                    ToolTip = 'Specifies the value of the Membership Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Loyalty Card"; Rec."Loyalty Card")
                {

                    ToolTip = 'Specifies the value of the Loyalty Card field';
                    ApplicationArea = NPRRetail;
                }
                field("Loyalty Code"; Rec."Loyalty Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Loyalty Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Config. Template Code"; Rec."Customer Config. Template Code")
                {

                    ToolTip = 'Specifies the value of the Customer Config. Template Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Contact Config. Template Code"; Rec."Contact Config. Template Code")
                {

                    ToolTip = 'Specifies the value of the Contact Config. Template Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Customer No."; Rec."Membership Customer No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Membership Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Member Information"; Rec."Member Information")
                {

                    ToolTip = 'Specifies the value of the Member Information field';
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
                field(Perpetual; Rec.Perpetual)
                {

                    ToolTip = 'Specifies the value of the Perpetual field';
                    ApplicationArea = NPRRetail;
                }
                field("Member Role Assignment"; Rec."Member Role Assignment")
                {

                    ToolTip = 'Specifies the value of the Member Role Assignment field';
                    ApplicationArea = NPRRetail;
                }
                field("Create Welcome Notification"; Rec."Create Welcome Notification")
                {

                    ToolTip = 'Specifies the value of the Create Welcome Notification field';
                    ApplicationArea = NPRRetail;
                }
                field("Create Renewal Notifications"; Rec."Create Renewal Notifications")
                {

                    ToolTip = 'Specifies the value of the Create Renewal Notifications field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Member Cardinality"; Rec."Membership Member Cardinality")
                {

                    ToolTip = 'Specifies the value of the Membership Member Cardinality field';
                    ApplicationArea = NPRRetail;
                }
                field("Anonymous Member Cardinality"; Rec."Anonymous Member Cardinality")
                {

                    ToolTip = 'Specifies the value of the Anonymous Member Cardinality field';
                    ApplicationArea = NPRRetail;
                }
                field("Community Code"; Rec."Community Code")
                {

                    ToolTip = 'Specifies the value of the Community Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Membership Delete"; Rec."Allow Membership Delete")
                {

                    ToolTip = 'Specifies the value of the Allow Membership Delete field';
                    ApplicationArea = NPRRetail;
                }
                field("Confirm Member On Card Scan"; Rec."Confirm Member On Card Scan")
                {

                    ToolTip = 'Specifies the value of the Confirm Member On Card Scan field';
                    ApplicationArea = NPRRetail;
                }
                field("Web Service Print Action"; Rec."Web Service Print Action")
                {

                    ToolTip = 'Specifies the value of the Web Service Print Action field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Print Action"; Rec."POS Print Action")
                {

                    ToolTip = 'Specifies the value of the POS Print Action field';
                    ApplicationArea = NPRRetail;
                }
                field("Account Print Object Type"; Rec."Account Print Object Type")
                {

                    ToolTip = 'Specifies the value of the Account Print Object Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Account Print Template Code"; Rec."Account Print Template Code")
                {

                    ToolTip = 'Specifies the value of the Account Print Template Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Account Print Object ID"; Rec."Account Print Object ID")
                {

                    ToolTip = 'Specifies the value of the Account Print Object ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Print Object Type"; Rec."Receipt Print Object Type")
                {

                    ToolTip = 'Specifies the value of the Receipt Print Object Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Print Template Code"; Rec."Receipt Print Template Code")
                {

                    ToolTip = 'Specifies the value of the Receipt Print Template Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Print Object ID"; Rec."Receipt Print Object ID")
                {

                    ToolTip = 'Specifies the value of the Receipt Print Object ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Number Scheme"; Rec."Card Number Scheme")
                {

                    ToolTip = 'Specifies the value of the Card Number Scheme field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Number Prefix"; Rec."Card Number Prefix")
                {

                    ToolTip = 'Specifies the value of the Card Number Prefix field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Number Length"; Rec."Card Number Length")
                {

                    ToolTip = 'Specifies the value of the Card Number Length field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Number Validation"; Rec."Card Number Validation")
                {

                    ToolTip = 'Specifies the value of the Card Number Validation field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Number No. Series"; Rec."Card Number No. Series")
                {

                    ToolTip = 'Specifies the value of the Card Number No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Number Valid Until"; Rec."Card Number Valid Until")
                {

                    ToolTip = 'Specifies the value of the Card Number Valid Until field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Number Pattern"; Rec."Card Number Pattern")
                {

                    ToolTip = '<any text><[MA|MS|NS|N*x|A*x|X*x]><[...]><...>';
                    ApplicationArea = NPRRetail;
                }
                field("Card Print Object Type"; Rec."Card Print Object Type")
                {

                    ToolTip = 'Specifies the value of the Card Print Object Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Print Template Code"; Rec."Card Print Template Code")
                {

                    ToolTip = 'Specifies the value of the Card Print Template Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Print Object ID"; Rec."Card Print Object ID")
                {

                    ToolTip = 'Specifies the value of the Card Print Object ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Expire Date Calculation"; Rec."Card Expire Date Calculation")
                {

                    ToolTip = 'Specifies the value of the Card Expire Date Calculation field';
                    ApplicationArea = NPRRetail;
                }
                field("Ticket Item Barcode"; Rec."Ticket Item Barcode")
                {

                    ToolTip = 'Specifies the value of the Ticket Item Barcode field';
                    ApplicationArea = NPRRetail;
                }
                field("Ticket Print Model"; Rec."Ticket Print Model")
                {

                    ToolTip = 'Specifies the value of the Ticket Print Model field';
                    ApplicationArea = NPRRetail;
                }
                field("Ticket Print Object Type"; Rec."Ticket Print Object Type")
                {

                    ToolTip = 'Specifies the value of the Ticket Print Object Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Ticket Print Object ID"; Rec."Ticket Print Object ID")
                {

                    ToolTip = 'Specifies the value of the Ticket Print Object ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Ticket Print Template Code"; Rec."Ticket Print Template Code")
                {

                    ToolTip = 'Specifies the value of the Ticket Print Template Code field';
                    ApplicationArea = NPRRetail;
                }
                field("GDPR Mode"; Rec."GDPR Mode")
                {

                    ToolTip = 'Specifies the value of the GDPR Mode field';
                    ApplicationArea = NPRRetail;
                }
                field("GDPR Agreement No."; Rec."GDPR Agreement No.")
                {

                    ToolTip = 'Specifies the value of the GDPR Agreement No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Enable NP Pass Integration"; Rec."Enable NP Pass Integration")
                {

                    ToolTip = 'Specifies the value of the Enable NP Pass Integration field';
                    ApplicationArea = NPRRetail;
                }
                field("Enable Age Verification"; Rec."Enable Age Verification")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Enable Age Verification field';
                    ApplicationArea = NPRRetail;
                }
                field("Validate Age Against"; Rec."Validate Age Against")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Validate Age Against field';
                    ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;

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
                ApplicationArea = NPRRetail;

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
                ApplicationArea = NPRRetail;
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

    local procedure UpdateAllWallets()
    var
        MembershipRole: Record "NPR MM Membership Role";
        MembershipNotification: Record "NPR MM Membership Notific.";
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

