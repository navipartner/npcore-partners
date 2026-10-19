/// <summary>
/// Membership side of NP Passes: issues pass links for member notifications and maps membership changes to the
/// cards (pass serial numbers) to signal. No-op when NP Passes is off or the type has no handle.
/// </summary>
codeunit 6151542 "NPR MM NP Passes Adapter"
{
    Access = Internal;

    internal procedure NotifyMembership(MembershipEntryNo: Integer)
    var
        MemberCard: Record "NPR MM Member Card";
    begin
        MemberCard.SetCurrentKey("Membership Entry No.", "Member Entry No.");
        MemberCard.SetRange("Membership Entry No.", MembershipEntryNo);
        NotifyCards(MemberCard);
    end;

    /// <summary>
    /// For callers that run before the membership row is written: whether the type is on NP Passes comes from MembershipCode, not the stored row.
    /// </summary>
    internal procedure NotifyMembership(MembershipEntryNo: Integer; MembershipCode: Code[20])
    var
        MemberCard: Record "NPR MM Member Card";
        NPPassesFacade: Codeunit "NPR NP Passes Facade";
        LayoutHandle: Text[40];
    begin
        if (not NPPassesFacade.IsConfigured()) then
            exit;

        LayoutHandle := GetLayoutHandleForCode(MembershipCode);
        if (LayoutHandle = '') then
            exit;

        MemberCard.SetCurrentKey("Membership Entry No.", "Member Entry No.");
        MemberCard.SetRange("Membership Entry No.", MembershipEntryNo);
        MemberCard.SetRange("Card Is Temporary", false);
        MemberCard.SetFilter("NP Passes Link Sent At", '<>%1', 0DT);
        if (not MemberCard.FindSet()) then
            exit;

        repeat
            NPPassesFacade.NotifyPassUpdated(MemberCard.SystemId);
        until (MemberCard.Next() = 0);
    end;

    internal procedure NotifyRole(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        MemberCard: Record "NPR MM Member Card";
    begin
        MemberCard.SetCurrentKey("Membership Entry No.", "Member Entry No.");
        MemberCard.SetRange("Membership Entry No.", MembershipEntryNo);
        MemberCard.SetRange("Member Entry No.", MemberEntryNo);
        NotifyCards(MemberCard);
    end;

    internal procedure NotifyMember(MemberEntryNo: Integer)
    var
        MemberCard: Record "NPR MM Member Card";
    begin
        MemberCard.SetCurrentKey("Member Entry No.");
        MemberCard.SetRange("Member Entry No.", MemberEntryNo);
        NotifyCards(MemberCard);
    end;

    /// <summary>
    /// Issues the pass link for a WALLET_CREATE / welcome notification: landing URL and pass id on the entry,
    /// "NP Passes Link Sent At" on the card. WALLET_UPDATE entries are acknowledged only (updates use the webhook).
    /// False when the type is not on NP Passes or no active permanent card exists.
    /// </summary>
    internal procedure TryIssuePassLink(var MemberNotificationEntry: Record "NPR MM Member Notific. Entry"): Boolean
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberCard: Record "NPR MM Member Card";
        NPPassesFacade: Codeunit "NPR NP Passes Facade";
        Link: Text;
    begin
        if (not NPPassesFacade.IsConfigured()) then
            exit(false);
        if (MemberNotificationEntry."Membership Code" = '') then
            exit(false);
        if (not MembershipSetup.Get(MemberNotificationEntry."Membership Code")) then
            exit(false);
        if (MembershipSetup."NP Passes Layout Handle" = '') then
            exit(false);
        if (not TryFindMemberCard(MemberNotificationEntry, MemberCard)) then
            exit(false);

        if (MemberNotificationEntry."Notification Trigger" = MemberNotificationEntry."Notification Trigger"::WALLET_UPDATE) then begin
            NotifyCard(MemberCard);
            exit(true);
        end;

        Link := IssueLandingLink(MemberCard, MembershipSetup."NP Passes Layout Handle");
        if (Link = '') then
            exit(false);

        SetWalletPassId(MemberNotificationEntry, MemberCard);
        MemberNotificationEntry."Wallet Pass Landing URL" := CopyStr(Link, 1, MaxStrLen(MemberNotificationEntry."Wallet Pass Landing URL"));
        MemberNotificationEntry.Modify();
        exit(true);
    end;

    /// <summary>
    /// Builds the landing link for the card and marks the card as offered a pass, so later updates reach it.
    /// Every path that hands out a link must use this. Empty when NP Passes is not configured or has no signing secret.
    /// </summary>
    internal procedure IssueLandingLink(var MemberCard: Record "NPR MM Member Card"; LayoutHandle: Text[40]) Link: Text
    var
        NPPassesFacade: Codeunit "NPR NP Passes Facade";
    begin
        Link := NPPassesFacade.BuildLandingLink(LayoutHandle, MemberCard.SystemId);
        if (Link = '') then
            exit('');

        MemberCard."NP Passes Link Sent At" := CurrentDateTime();
        MemberCard.Modify();
    end;

    local procedure TryFindMemberCard(MemberNotificationEntry: Record "NPR MM Member Notific. Entry"; var MemberCard: Record "NPR MM Member Card"): Boolean
    begin
        SetLinkCardFilters(MemberCard, MemberNotificationEntry."Membership Entry No.", MemberNotificationEntry."Member Entry No.", Today());
        if (MemberNotificationEntry."External Member Card No." <> '') then
            MemberCard.SetRange("External Card No.", MemberNotificationEntry."External Member Card No.");
        exit(MemberCard.FindLast());
    end;

    /// <summary>
    /// True when a pass link may be issued for this card: not blocked or temporary and still valid, the same rules the
    /// notification path uses. Other cards would get a pass that never receives updates.
    /// </summary>
    internal procedure CanIssuePassLink(MemberCard: Record "NPR MM Member Card"): Boolean
    var
        LinkCard: Record "NPR MM Member Card";
    begin
        SetLinkCardFilters(LinkCard, MemberCard."Membership Entry No.", MemberCard."Member Entry No.", Today());
        LinkCard.SetRange("Entry No.", MemberCard."Entry No.");
        exit(not LinkCard.IsEmpty());
    end;

    // Valid Until 0D = no expiry.
    local procedure SetLinkCardFilters(var MemberCard: Record "NPR MM Member Card"; MembershipEntryNo: Integer; MemberEntryNo: Integer; ValidOn: Date)
    begin
        MemberCard.SetRange("Membership Entry No.", MembershipEntryNo);
        MemberCard.SetRange("Member Entry No.", MemberEntryNo);
        MemberCard.SetRange(Blocked, false);
        MemberCard.SetRange("Card Is Temporary", false);
        MemberCard.SetFilter("Valid Until", '%1|>=%2', 0D, ValidOn);
    end;

    // Only the entry gets the serial (SOAP response, email data); the role's Wallet Pass Id belongs to the legacy pass server.
    local procedure SetWalletPassId(var MemberNotificationEntry: Record "NPR MM Member Notific. Entry"; MemberCard: Record "NPR MM Member Card")
    var
        NPPassesFacade: Codeunit "NPR NP Passes Facade";
    begin
        MemberNotificationEntry."Wallet Pass Id" := CopyStr(NPPassesFacade.FormatSerialNumber(MemberCard.SystemId), 1, MaxStrLen(MemberNotificationEntry."Wallet Pass Id"));
    end;

    /// <summary>
    /// True when the member holds a card on the membership that was sent an NP Passes link. For NP Passes types this,
    /// not the role's legacy Wallet Pass Id, decides between sending a link and updating the pass.
    /// </summary>
    internal procedure HasNPPass(MembershipEntryNo: Integer; MemberEntryNo: Integer): Boolean
    var
        MemberCard: Record "NPR MM Member Card";
    begin
        MemberCard.SetRange("Membership Entry No.", MembershipEntryNo);
        MemberCard.SetRange("Member Entry No.", MemberEntryNo);
        MemberCard.SetRange("Card Is Temporary", false);
        MemberCard.SetFilter("NP Passes Link Sent At", '<>%1', 0DT);
        exit(not MemberCard.IsEmpty());
    end;

    internal procedure NotifyCard(var MemberCard: Record "NPR MM Member Card"): Boolean
    var
        NPPassesFacade: Codeunit "NPR NP Passes Facade";
        LayoutHandle: Text[40];
    begin
        if (MemberCard."Card Is Temporary") then
            exit(false);
        if (MemberCard."NP Passes Link Sent At" = 0DT) then
            exit(false);
        if (not NPPassesFacade.IsConfigured()) then
            exit(false);

        LayoutHandle := GetLayoutHandle(MemberCard."Membership Entry No.");
        if (LayoutHandle = '') then
            exit(false);

        exit(NPPassesFacade.NotifyPassUpdated(MemberCard.SystemId));
    end;

    // Blocked and expired cards are included so the pass can show that state.
    local procedure NotifyCards(var MemberCard: Record "NPR MM Member Card")
    var
        NPPassesFacade: Codeunit "NPR NP Passes Facade";
        LayoutHandles: Dictionary of [Integer, Text[40]];
        LayoutHandle: Text[40];
    begin
        if (not NPPassesFacade.IsConfigured()) then
            exit;

        MemberCard.SetRange("Card Is Temporary", false);
        MemberCard.SetFilter("NP Passes Link Sent At", '<>%1', 0DT);
        if (not MemberCard.FindSet()) then
            exit;

        repeat
            if (not LayoutHandles.Get(MemberCard."Membership Entry No.", LayoutHandle)) then begin
                LayoutHandle := GetLayoutHandle(MemberCard."Membership Entry No.");
                LayoutHandles.Add(MemberCard."Membership Entry No.", LayoutHandle);
            end;

            if (LayoutHandle <> '') then
                NPPassesFacade.NotifyPassUpdated(MemberCard.SystemId);
        until (MemberCard.Next() = 0);
    end;

    internal procedure UsesNPPasses(MembershipEntryNo: Integer): Boolean
    var
        NPPassesFacade: Codeunit "NPR NP Passes Facade";
    begin
        if (not NPPassesFacade.IsConfigured()) then
            exit(false);
        exit(GetLayoutHandle(MembershipEntryNo) <> '');
    end;

    local procedure GetLayoutHandle(MembershipEntryNo: Integer): Text[40]
    var
        Membership: Record "NPR MM Membership";
    begin
        Membership.SetLoadFields("Membership Code");
        if (not Membership.Get(MembershipEntryNo)) then
            exit('');

        exit(GetLayoutHandleForCode(Membership."Membership Code"));
    end;

    local procedure GetLayoutHandleForCode(MembershipCode: Code[20]): Text[40]
    var
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        MembershipSetup.SetLoadFields("NP Passes Layout Handle");
        if (not MembershipSetup.Get(MembershipCode)) then
            exit('');

        exit(MembershipSetup."NP Passes Layout Handle");
    end;
}
