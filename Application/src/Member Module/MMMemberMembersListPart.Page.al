page 6060138 "NPR MM Member Members.ListPart"
{
    Extensible = False;

    Caption = 'Member Memberships';
    InsertAllowed = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR MM Membership Role";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Membership No."; Rec."External Membership No.")
                {
                    DrillDownPageID = "NPR MM Membership Card";
                    LookupPageID = "NPR MM Membership Card";
                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("GDPR Approval"; Rec."GDPR Approval")
                {
                    ToolTip = 'Specifies the value of the GDPR Approval field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnDrillDown()
                    var
                        GDPRConsentLog: Record "NPR GDPR Consent Log";
                        GDPRConsentLogPage: Page "NPR GDPR Consent Log";
                    begin
                        GDPRConsentLog.FilterGroup(2);
                        GDPRConsentLog.SetFilter("Agreement No.", '=%1', Rec."GDPR Agreement No.");
                        GDPRConsentLog.SetFilter("Data Subject Id", '=%1', Rec."GDPR Data Subject Id");
                        GDPRConsentLog.FilterGroup(0);
                        GDPRConsentLogPage.SetTableView(GDPRConsentLog);
                        GDPRConsentLogPage.RunModal();
                        CurrPage.Update(false);
                    end;
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    DrillDownPageID = "NPR MM Membership Setup";
                    LookupPageID = "NPR MM Membership Setup";
                    TableRelation = "NPR MM Membership Setup".Code;
                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("User Logon ID"; Rec."User Logon ID")
                {
                    ToolTip = 'Specifies the value of the User Logon ID field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Visible = false;
                }
                field("Password Hash"; Rec."Password Hash")
                {
                    ToolTip = 'Specifies the value of the Password field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Visible = false;
                }
                field(CurrentPeriodField; _CurrentPeriod)
                {
                    Caption = 'Current Period';
                    ToolTip = 'Shows the current valid period of the membership';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Editable = false;
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
                field("GDPR Agreement No."; Rec."GDPR Agreement No.")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the GDPR Agreement No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("GDPR Data Subject Id"; Rec."GDPR Data Subject Id")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the GDPR Data Subject Id field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
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
                    MembershipRole: Record "NPR MM Membership Role";
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

                    CurrPage.SetSelectionFilter(MembershipRole);
                    if (MembershipRole.FindSet()) then begin
                        repeat
                            MemberNotification.AddMemberWelcomeNotificationWorker(MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.", AzureMemberRegistration.AzureRegistrationSetupCode, EntryNoList);

                            foreach EntryNo in EntryNoList do
                                if (MembershipNotification.Get(EntryNo)) then
                                    if (MembershipNotification."Processing Method" = MembershipNotification."Processing Method"::INLINE) then
                                        MemberNotification.HandleMembershipNotification(MembershipNotification);

                        until (MembershipRole.Next() = 0);
                    end;
                end;
            }
            action("Send Wallet Notification")
            {
                Caption = 'Send Wallet Notification';
                Image = Interaction;

                ToolTip = 'Creates a wallet notification message and sends it when processing method is set to inline';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                var
                    MemberNotification: Codeunit "NPR MM Member Notification";
                    MembershipNotification: Record "NPR MM Membership Notific.";
                    MembershipRole: Record "NPR MM Membership Role";
                    EntryNo: Integer;
                begin
                    CurrPage.SetSelectionFilter(MembershipRole);
                    if (MembershipRole.FindSet()) then begin
                        repeat
                            if (MembershipRole."Wallet Pass Id" <> '') then
                                EntryNo := MemberNotification.CreateUpdateWalletNotification(MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.", 0, TODAY);

                            if (MembershipRole."Wallet Pass Id" = '') then
                                EntryNo := MemberNotification.CreateWalletSendNotification(MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.", 0, TODAY);

                            if (MembershipNotification.Get(EntryNo)) then
                                if (MembershipNotification."Processing Method" = MembershipNotification."Processing Method"::INLINE) then
                                    MemberNotification.HandleMembershipNotification(MembershipNotification);
                        until (MembershipRole.Next() = 0);
                    end;
                end;
            }
        }
    }

    var
        _CurrentPeriod: Text[100];
        NOT_ACTIVATED: Label 'Not Activated', Locked = true;
        MEMBERSHIP_EXPIRED: Label 'Membership Expired', Locked = true;

    trigger OnAfterGetRecord()
    begin
        _CurrentPeriod := CopyStr(SetCurrentPeriodText(Rec."Membership Entry No."), 1, MaxStrLen(_CurrentPeriod));
    end;

    local procedure SetCurrentPeriodText(MembershipEntryNo: Integer) CurrentPeriod: Text;
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        ValidFromDate: Date;
        ValidUntilDate: Date;
        MaxValidUntilDate: Date;
        PlaceHolder2Lbl: Label '%1 - %2', Locked = true;
        PlaceHolder3Lbl: Label '%1 - %2 (%3)', Locked = true;
        NeedsActivation: Boolean;
    begin
        NeedsActivation := MembershipManagement.MembershipNeedsActivation(MembershipEntryNo);
        CurrentPeriod := NOT_ACTIVATED;
        if (not NeedsActivation) then begin
            MembershipManagement.GetMembershipValidDate(MembershipEntryNo, Today, ValidFromDate, ValidUntilDate);
            CurrentPeriod := StrSubstNo(PlaceHolder2Lbl, ValidFromDate, ValidUntilDate);

            MembershipManagement.GetMembershipMaxValidUntilDate(MembershipEntryNo, MaxValidUntilDate);
            if (ValidUntilDate <> MaxValidUntilDate) then
                CurrentPeriod := StrSubstNo(PlaceHolder3Lbl, ValidFromDate, ValidUntilDate, MaxValidUntilDate);

            if (ValidUntilDate < Today) then
                CurrentPeriod := StrSubstNo(PlaceHolder3Lbl, ValidFromDate, ValidUntilDate, MEMBERSHIP_EXPIRED);
        end;
    end;

    internal procedure GetSelectedMembershipEntryNo(): Integer
    begin

        exit(Rec."Membership Entry No.");
    end;
}

