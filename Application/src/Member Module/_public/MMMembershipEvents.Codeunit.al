codeunit 6014485 "NPR MM Membership Events"
{

    [IntegrationEvent(false, false)]
    internal procedure OnAssociateSaleWithMember(POSSession: Codeunit "NPR POS Session"; ExternalMembershipNo: Code[20]; ExternalMemberNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforePOSMemberArrival(SaleLinePOS: Record "NPR POS Sale Line"; CommunityCode: Code[20]; MembershipCode: Code[20]; MembershipEntryNo: Integer; MemberEntryNo: Integer; MemberCardEntryNo: Integer; ScannedCardNumber: Text[100])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCustomItemDescription(CommunityCode: Code[20]; MembershipCode: Code[20]; MemberCardEntryNo: Integer; var NewDescription: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeAssignCustomerNo(var MemberInfoCapture: Record "NPR MM Member Info Capture");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterCustomerCreate(var Customer: Record Customer)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterContactCreate(Customer: Record Customer; var Contact: Record Contact)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterMembershipCreateEvent(Membership: Record "NPR MM Membership")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterMemberCreateEvent(var Membership: Record "NPR MM Membership"; var Member: Record "NPR MM Member"; MemberInfoCapture: Record "NPR MM Member Info Capture")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeSetMemberFields(Member: Record "NPR MM Member"; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterSetMemberFields(var Member: Record "NPR MM Member"; MemberInfoCapture: Record "NPR MM Member Info Capture")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterMemberFieldsAssignmentEvent(CurrentMember: Record "NPR MM Member"; var NewMember: Record "NPR MM Member")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertMembershipEntry(MembershipEntry: Record "NPR MM Membership Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeMembInfoCaptureDialog(var MemberInfoCapture: Record "NPR MM Member Info Capture"; var ShowStandardUserInterface: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    [Obsolete('Replaced by OnBeforeMembInfoCaptureDialog(var MemberInfoCapture: Record "NPR MM Member Info Capture"; var ShowStandardUserInterface: Boolean)', '2023-06-28')]
    internal procedure OnBeforeMemberInfoCaptureDialog(MemberInfoCaptureFilter: Text; var ShowStandardUserInterface: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterMembInfoCaptureDialog(var MemberInfoCapture: Record "NPR MM Member Info Capture"; StandardUserInterface: Boolean; var LookupOK: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    [Obsolete('Replaced by OnAfterMembInfoCaptureDialog(var MemberInfoCapture: Record "NPR MM Member Info Capture"; StandardUserInterface: Boolean; var LookupOK: Boolean)', '2023-06-28')]
    internal procedure OnAfterMemberInfoCaptureDialog(MemberInfoCaptureFilter: Text; StandardUserInterface: Boolean; var LookupOK: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnPOSCreateMembershipOnIdentifyCsStore(PosUnitNo: Code[10]; var CsStoreCode: Code[20]; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeApplyAttributeToMemberInfoCapture(var MemberInfoCapture: Record "NPR MM Member Info Capture"; AttributeCode: Text; AttributeValue: Text; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterBlockMember(MemberEntryNo: Integer)
    begin
    end;


    #region Member Merge
    [IntegrationEvent(false, false)]
    [CommitBehavior(CommitBehavior::Error)]
    internal procedure OnCheckMemberUniqueIdViolation(Community: Record "NPR MM Member Community"; MemberInfoCapture: Record "NPR MM Member Info Capture"; var ConflictingMember: Record "NPR MM Member"; var ConflictExists: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    [CommitBehavior(CommitBehavior::Error)]
    internal procedure OnAfterMemberIsMerged(OriginalMember: Record "NPR MM Member"; NewMember: Record "NPR MM Member")
    begin
    end;


    /// <summary>
    /// Lets a subscriber take over the member-uniqueness decision for a community: set FilterSet to true and apply your
    /// own filter on ConflictingMember (a matching record is treated as a conflict). This hook exists primarily to BYPASS
    /// uniqueness - e.g. communities that deliberately let many named members share one placeholder e-mail - by applying a
    /// never-match filter such as ConflictingMember.SetRange("Entry No.", -1). When you take over, the built-in identity
    /// rule is skipped.
    /// Concurrency: AddNamedMember and (non-SOAP) UpdateMember serialize the built-in uniqueness rule with a per-identity
    /// mutex. A subscriber-handled rule is intentionally NOT locked - there is no server-owned invariant to protect, and
    /// locking a bypass would serialize exactly the shared-address create path this hook enables. If a subscriber ever needs its own
    /// custom uniqueness serialized under concurrency, that requires a dedicated key-emitting event, not this hook: the
    /// filter set here cannot be reverse-engineered into a stable lock key (it may use any filter group, and its text is
    /// locale-dependent).
    /// </summary>
    /// <param name="Community">The community whose uniqueness rule is being resolved.</param>
    /// <param name="MemberInfoCapture">The member data being created or updated.</param>
    /// <param name="ConflictingMember">Apply your uniqueness filter here; a matching record is treated as a conflict.</param>
    /// <param name="FilterSet">Set to true to signal you have taken over the uniqueness decision (skips the built-in rule).</param>
    [IntegrationEvent(false, false)]
    [CommitBehavior(CommitBehavior::Error)]
    internal procedure OnSetMemberUniqueIdFilter(Community: Record "NPR MM Member Community"; MemberInfoCapture: Record "NPR MM Member Info Capture"; var ConflictingMember: Record "NPR MM Member"; var FilterSet: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    [CommitBehavior(CommitBehavior::Error)]
    internal procedure OnBeforeApplyExistingMemberInformation(Community: Record "NPR MM Member Community"; FromFieldId: Integer; Member: Record "NPR MM Member"; var MemberInfoCapture: Record "NPR MM Member Info Capture"; var Handled: Boolean);
    begin
    end;
    #endregion

    #region Loyalty

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCreatePointEntry(var ValueEntry: Record "Value Entry"; LoyaltyPostingSource: Option VALUE_ENTRY,MEMBERSHIP_ENTRY,POS_ENDOFSALE; var POSUnitNo: Code[10]; var CreatePointEntry: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertPointEntry(var MembershipPointsEntry: Record "NPR MM Members. Points Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterMembershipPointsUpdate(MembershipEntryNo: Integer; MembershipPointsEntryNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterPOSActionMemberLoyReadMemberCardNumber(var MemberCardNumber: Text[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterReplaceMemberCard(OldMemberCardEntryNo: Integer; NewMemberCardEntryNo: Integer)
    begin
    end;

    #endregion

    #region SmartSearch

    [IntegrationEvent(false, false)]
    internal procedure OnAfterSetMemberSmartSearchFilter(SearchTerm: Text; SearchContext: Integer; var Member: Record "NPR MM Member")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterSetMembershipSmartSearchFilter(SearchTerm: Text; SearchContext: Integer; var Membership: Record "NPR MM Membership")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterSetMemberCardSmartSearchFilter(SearchTerm: Text; SearchContext: Integer; var MemberCard: Record "NPR MM Member Card")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeValidateSmartSearchTerm(SearchTerm: Text; SearchContext: Integer; var Handled: Boolean; var IsValidSearchTerm: Boolean)
    begin
    end;

    #endregion

    #region GDPR
    [IntegrationEvent(false, false)]
    [CommitBehavior(CommitBehavior::Error)]
    internal procedure OnBeforeAnonymizeMember(var Member: Record "NPR MM Member");
    begin
    end;

    [IntegrationEvent(false, false)]
    [CommitBehavior(CommitBehavior::Error)]
    internal procedure OnBeforeAnonymizeMemberCard(var Member: Record "NPR MM Member Card");
    begin
    end;

    [IntegrationEvent(false, false)]
    [CommitBehavior(CommitBehavior::Error)]
    internal procedure OnBeforeAnonymizeRole(var MembershipRole: Record "NPR MM Membership Role");
    begin
    end;

    [IntegrationEvent(false, false)]
    [CommitBehavior(CommitBehavior::Error)]
    internal procedure OnBeforeAnonymizeMembership(var Membership: Record "NPR MM Membership");
    begin
    end;
    #endregion

    [IntegrationEvent(false, false)]
    procedure OnAfterCreateMemberSoapRequest(var MemberInfoCapture: Record "NPR MM Member Info Capture"; var XmlDoc: XmlDocument; SOAPAction: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCreateMemberRestRequest(var MemberInfoCapture: Record "NPR MM Member Info Capture"; var Request: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetMembershipMembers_OnBeforeTempMemberInfoResponseInsert(var TempMemberInfoResponse: Record "NPR MM Member Info Capture")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAddMemberScannedToastData(MembershipEntryNo: Integer; MemberEntryNo: Integer; var MemberScannedData: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCalculatePoints(LoyaltySetupCode: Code[20]; SaleLinePOS: Record "NPR POS Sale Line"; var TotalPoints: Integer)
    begin
    end;
}