/// <summary>
/// Signals pass refreshes when a Member or Membership field shown on the pass changes, from a page or from code.
/// Watched fields mirror the member and membership objects of GET membership/card/{cardId}, the data np-passes binds designs to.
/// Compares against the stored row in OnBeforeModify because xRec carries old values only for page edits.
/// Member Card and Membership Entry have no table subscriber on purpose: they are written in bulk (ModifyAll) and by
/// multi-record operations, which call the adapter explicitly once the operation is complete. Card edits made on the
/// card pages are caught with page events instead, which leave ModifyAll set-based.
/// </summary>
codeunit 6151531 "NPR MM NP Passes ChangeDetect"
{
    Access = Internal;

    local procedure HasMemberWatchedFieldChanged(StoredMember: Record "NPR MM Member"; Member: Record "NPR MM Member"): Boolean
    begin
        exit(
            (StoredMember."External Member No." <> Member."External Member No.") or
            (StoredMember.Blocked <> Member.Blocked) or
            (StoredMember."First Name" <> Member."First Name") or
            (StoredMember."Middle Name" <> Member."Middle Name") or
            (StoredMember."Last Name" <> Member."Last Name") or
            (StoredMember.Address <> Member.Address) or
            (StoredMember."Post Code Code" <> Member."Post Code Code") or
            (StoredMember.City <> Member.City) or
            (StoredMember.Country <> Member.Country) or
            (StoredMember.Gender <> Member.Gender) or
            (StoredMember."E-Mail News Letter" <> Member."E-Mail News Letter") or
            (StoredMember."E-Mail Address" <> Member."E-Mail Address") or
            (StoredMember."Phone No." <> Member."Phone No.") or
            (StoredMember.Birthday <> Member.Birthday) or
            (StoredMember.PreferredLanguageCode <> Member.PreferredLanguageCode) or
            (StoredMember."Store Code" <> Member."Store Code") or
            (StoredMember.Image.MediaId() <> Member.Image.MediaId())
        );
    end;

    // The pass shows the membership type's description (from Membership Setup), not Membership.Description, and
    // autoRenewalActivated rather than the Auto-Renew value itself.
    local procedure HasMembershipWatchedFieldChanged(StoredMembership: Record "NPR MM Membership"; Membership: Record "NPR MM Membership"): Boolean
    begin
        exit(
            (StoredMembership."External Membership No." <> Membership."External Membership No.") or
            (StoredMembership."Community Code" <> Membership."Community Code") or
            (StoredMembership."Membership Code" <> Membership."Membership Code") or
            (StoredMembership."Issued Date" <> Membership."Issued Date") or
            (StoredMembership.Blocked <> Membership.Blocked) or
            (StoredMembership."Customer No." <> Membership."Customer No.") or
            ((StoredMembership."Auto-Renew" = StoredMembership."Auto-Renew"::NO) <> (Membership."Auto-Renew" = Membership."Auto-Renew"::NO))
        );
    end;

    // Most members never get a pass; an index check is cheaper than reading the stored row on every save.
    local procedure MemberHasPass(MemberEntryNo: Integer): Boolean
    var
        MemberCard: Record "NPR MM Member Card";
    begin
        MemberCard.SetCurrentKey("Member Entry No.");
        MemberCard.SetRange("Member Entry No.", MemberEntryNo);
        MemberCard.SetRange("Card Is Temporary", false);
        MemberCard.SetFilter("NP Passes Link Sent At", '<>%1', 0DT);
        exit(not MemberCard.IsEmpty());
    end;

    local procedure TypeHasDesign(MembershipCode: Code[20]): Boolean
    var
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        MembershipSetup.SetLoadFields("NP Passes Layout Handle");
        if (not MembershipSetup.Get(MembershipCode)) then
            exit(false);
        exit(MembershipSetup."NP Passes Layout Handle" <> '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR MM Member Card Card", OnModifyRecordEvent, '', false, false)]
    local procedure OnModifyMemberCardCard(var Rec: Record "NPR MM Member Card"; var xRec: Record "NPR MM Member Card"; var AllowModify: Boolean)
    begin
        SignalCardEdit(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR MM Member Cards ListPart", OnModifyRecordEvent, '', false, false)]
    local procedure OnModifyMemberCardsListPart(var Rec: Record "NPR MM Member Card"; var xRec: Record "NPR MM Member Card"; var AllowModify: Boolean)
    begin
        SignalCardEdit(Rec, xRec);
    end;

    // The card fields in the card response. On pages xRec holds the old values.
    internal procedure SignalCardEdit(MemberCard: Record "NPR MM Member Card"; xMemberCard: Record "NPR MM Member Card")
    var
        NPPassesAdapter: Codeunit "NPR MM NP Passes Adapter";
    begin
        if (MemberCard.IsTemporary()) then
            exit;
        if ((MemberCard.Blocked = xMemberCard.Blocked) and
            (MemberCard."Valid Until" = xMemberCard."Valid Until") and
            (MemberCard."External Card No." = xMemberCard."External Card No.") and
            (MemberCard."Pin Code" = xMemberCard."Pin Code"))
        then
            exit;

        NPPassesAdapter.NotifyCard(MemberCard);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Member", OnBeforeModifyEvent, '', false, false)]
    local procedure OnBeforeMemberModify(var Rec: Record "NPR MM Member")
    var
        StoredMember: Record "NPR MM Member";
        NPPassesAdapter: Codeunit "NPR MM NP Passes Adapter";
        NPPassesFacade: Codeunit "NPR NP Passes Facade";
    begin
        if (Rec.IsTemporary()) then
            exit;
        if (not NPPassesFacade.IsConfigured()) then
            exit;
        if (not MemberHasPass(Rec."Entry No.")) then
            exit;

        StoredMember.SetLoadFields("External Member No.", Blocked, "First Name", "Middle Name", "Last Name", Address, "Post Code Code", City, Country,
            Gender, "E-Mail News Letter", "E-Mail Address", "Phone No.", Birthday, PreferredLanguageCode, "Store Code", Image);
        if (not StoredMember.Get(Rec."Entry No.")) then
            exit;
        if (not HasMemberWatchedFieldChanged(StoredMember, Rec)) then
            exit;

        NPPassesAdapter.NotifyMember(Rec."Entry No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Membership", OnBeforeModifyEvent, '', false, false)]
    local procedure OnBeforeMembershipModify(var Rec: Record "NPR MM Membership")
    var
        StoredMembership: Record "NPR MM Membership";
        NPPassesAdapter: Codeunit "NPR MM NP Passes Adapter";
        NPPassesFacade: Codeunit "NPR NP Passes Facade";
    begin
        if (Rec.IsTemporary()) then
            exit;
        if (not NPPassesFacade.IsConfigured()) then
            exit;
        // The adapter only signals for a type with a design, so legacy types skip reading the stored row.
        if (not TypeHasDesign(Rec."Membership Code")) then
            exit;

        StoredMembership.SetLoadFields("External Membership No.", "Community Code", "Membership Code", "Issued Date", Blocked, "Customer No.", "Auto-Renew");
        if (not StoredMembership.Get(Rec."Entry No.")) then
            exit;
        if (not HasMembershipWatchedFieldChanged(StoredMembership, Rec)) then
            exit;

        // Rec's code, not the stored one: the row is not written yet and a type change must send the new design.
        NPPassesAdapter.NotifyMembership(Rec."Entry No.", Rec."Membership Code");
    end;
}
