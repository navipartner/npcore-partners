codeunit 6014485 "NPR MM Membership Events"
{

    [IntegrationEvent(false, false)]
    internal procedure OnAssociateSaleWithMember(POSSession: Codeunit "NPR POS Session"; ExternalMembershipNo: Code[20]; ExternalMemberNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforePOSMemberArrival(SaleLinePOS: Record "NPR Sale Line POS"; CommunityCode: Code[20]; MembershipCode: Code[20]; MembershipEntryNo: Integer; MemberEntryNo: Integer; MemberCardEntryNo: Integer; ScannedCardNumber: Text[100])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCustomItemDescription(CommunityCode: Code[20]; MembershipCode: Code[20]; MemberCardEntryNo: Integer; var NewDescription: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterMembershipCreateEvent(Membership: Record "NPR MM Membership")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterMemberCreateEvent(var Membership: Record "NPR MM Membership"; var Member: Record "NPR MM Member")
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

}