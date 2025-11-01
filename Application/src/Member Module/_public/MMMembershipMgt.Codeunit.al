codeunit 6060127 "NPR MM Membership Mgt."
{
    /// <summary>
    /// This function allows you to create a new membership.
    /// <br />
    /// If `CreateMembershipLedgerEntry` is set to false, the membership will not be active because it will not have an active timeframe created.
    /// To do so, call `StartMembership()` subsequently.
    /// </summary>
    /// <param name="MembershipSalesSetup">Sales setup to issue membership from.</param>
    /// <param name="MemberInfoCapture">Record containing information about member.</param>
    /// <param name="CreateMembershipLedgerEntry">Determine if the initial timeframe is created or not.</param>
    /// <returns>The entry no of the created membership.</returns>
    procedure CreateMembershipAll(MembershipSalesSetup: Record "NPR MM Members. Sales Setup"; var MemberInfoCapture: Record "NPR MM Member Info Capture"; CreateMembershipLedgerEntry: Boolean) MembershipEntryNo: Integer
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipEntryNo := MembershipManagement.CreateMembershipAll(MembershipSalesSetup, MemberInfoCapture, CreateMembershipLedgerEntry);
    end;

    /// <summary>
    /// Add an initial timeframe to the given membership.
    /// </summary>
    /// <param name="MembershipEntryNo">The membership to add the timeframe to.</param>
    /// <param name="ReferenceDate">The reference date from which the activation should be calculated.</param>
    /// <param name="MembershipSalesSetup">The sales setup containing rules.</param>
    /// <param name="MemberInfoCapture">Record containing information about the sale that's starting the membership.</param>
    /// <returns>The entry no of the created membership ledger entry.</returns>
    procedure StartMembership(MembershipEntryNo: Integer; ReferenceDate: Date; MembershipSalesSetup: Record "NPR MM Members. Sales Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture") LedgerEntryNo: Integer
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        LedgerEntryNo := MembershipManagement.AddMembershipLedgerEntry_NEW(MembershipEntryNo, ReferenceDate, MembershipSalesSetup, MemberInfoCapture);
    end;

    procedure GetMembershipFromExtCardNo(ExternalCardNo: Text[100]; ReferenceDate: Date; var ReasonNotFound: Text) MembershipEntryNo: Integer
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipEntryNo := MembershipManagement.GetMembershipFromExtCardNo(ExternalCardNo, ReferenceDate, ReasonNotFound);
    end;

    procedure DeleteMembership(MembershipEntryNo: Integer; WithGDPRCheck: Boolean; Force: Boolean)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        GDPR: Codeunit "NPR MM GDPR Management";
    begin
        if (WithGDPRCheck) then begin
            GDPR.DeleteMembership(MembershipEntryNo);
        end else begin
            MembershipManagement.DeleteMembership(MembershipEntryNo, Force);
        end;
    end;

    procedure GetMembershipMaxValidUntilDate(MembershipEntryNo: Integer; var MaxValidUntilDate: Date)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.GetMembershipMaxValidUntilDate(MembershipEntryNo, MaxValidUntilDate);
    end;

    procedure RegretMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var MembershipStartDate: Date; var MembershipUntilDate: Date; var UnitPrice: Decimal)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.RegretMembership(MemberInfoCapture, WithConfirm, WithUpdate, MembershipStartDate, MembershipUntilDate, UnitPrice);
    end;

    procedure RenewMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var MembershipStartDate: Date; var MembershipUntilDate: Date; var UnitPrice: Decimal)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.RenewMembership(MemberInfoCapture, WithConfirm, WithUpdate, MembershipStartDate, MembershipUntilDate, UnitPrice);
    end;

    procedure UpgradeMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var MembershipStartDate: Date; var MembershipUntilDate: Date; var UnitPrice: Decimal)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.UpgradeMembership(MemberInfoCapture, WithConfirm, WithUpdate, MembershipStartDate, MembershipUntilDate, UnitPrice);
    end;

    procedure ExtendMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var MembershipStartDate: Date; var MembershipUntilDate: Date; var UnitPrice: Decimal)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.ExtendMembership(MemberInfoCapture, WithConfirm, WithUpdate, MembershipStartDate, MembershipUntilDate, UnitPrice);
    end;

    procedure CancelMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var MembershipStartDate: Date; var MembershipUntilDate: Date; var UnitPrice: Decimal)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.CancelMembership(MemberInfoCapture, WithConfirm, WithUpdate, MembershipStartDate, MembershipUntilDate, UnitPrice);
    end;

    procedure BlockMembership(MembershipEntryNo: Integer)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.BlockMembership(MembershipEntryNo, true);
    end;

    procedure UnblockMembership(MembershipEntryNo: Integer)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.BlockMembership(MembershipEntryNo, false);
    end;

    procedure BlockMember(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.BlockMember(MembershipEntryNo, MemberEntryNo, true);
    end;

    procedure UnblockMember(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.BlockMember(MembershipEntryNo, MemberEntryNo, false);
    end;

    procedure BlockMemberCard(CardEntryNo: Integer)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.BlockMemberCard(CardEntryNo, true);
    end;

    procedure UnblockMemberCard(CardEntryNo: Integer)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.BlockMemberCard(CardEntryNo, false);
    end;

    procedure BlockMemberCards(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.BlockMemberCards(MembershipEntryNo, MemberEntryNo, true);
    end;

    procedure UnblockMemberCards(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.BlockMemberCards(MembershipEntryNo, MemberEntryNo, false);
    end;

    procedure EnableMembershipInternalAutoRenewal(MembershipEntryNo: Integer; CreateMemberNotification: Boolean; ForceMemberNotification: Boolean)
    var
        Membership: Record "NPR MM Membership";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        Membership.Get(MembershipEntryNo);
        MembershipManagement.EnableMembershipInternalAutoRenewal(Membership, CreateMemberNotification, ForceMemberNotification);
    end;

    procedure EnableMembershipExternalAutoRenewal(MembershipEntryNo: Integer; CreateMemberNotification: Boolean; ForceMemberNotification: Boolean)
    var
        Membership: Record "NPR MM Membership";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        Membership.Get(MembershipEntryNo);
        MembershipManagement.EnableMembershipExternalAutoRenewal(Membership, CreateMemberNotification, ForceMemberNotification);
    end;

    procedure DisableMembershipAutoRenewal(MembershipEntryNo: Integer; CreateMemberNotification: Boolean; ForceMemberNotification: Boolean)
    var
        Membership: Record "NPR MM Membership";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        Membership.Get(MembershipEntryNo);
        MembershipManagement.DisableMembershipAutoRenewal(Membership, CreateMemberNotification, ForceMemberNotification);
    end;
    /// <summary>
    /// Compacts members that have conflicting Unique IDs by keeping the given member and merging conflicting members
    /// into the member to keep. This procedure does not show any UI and is intended for use in automated processes.
    /// </summary>
    /// <param name="MemberToKeep">The member record to keep. Conflicting members will be merged into this member.</param>
    /// <param name="ConflictExists">Output parameter indicating whether any conflicts were found.</param>
    /// <param name="ConflictingMembersMerged">Output parameter indicating whether any conflicting members were merged.</param>
    /// <param name="Explanation">Output parameter providing an explanation of the actions taken during the compaction process including a fail explanation.</param>
    procedure CompactMembersOnUniqueIdChangeNoUI(MemberToKeep: Record "NPR MM Member"; var ConflictExists: Boolean; var ConflictingMembersMerged: Boolean; var Explanation: Text): Boolean
    var
        UpdateMemberUniqueId: Page "NPR MemberUpdateUniqueId";
    begin
        exit(UpdateMemberUniqueId.CompactMembersOnUniqueIdChangeNoUI(MemberToKeep, ConflictExists, ConflictingMembersMerged, Explanation));
    end;

}