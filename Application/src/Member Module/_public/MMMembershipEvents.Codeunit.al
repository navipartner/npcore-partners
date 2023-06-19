﻿codeunit 6014485 "NPR MM Membership Events"
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
    [Obsolete('Replaced by OnBeforeMembInfoCaptureDialog(var MemberInfoCapture: Record "NPR MM Member Info Capture"; var ShowStandardUserInterface: Boolean)')]
    internal procedure OnBeforeMemberInfoCaptureDialog(MemberInfoCaptureFilter: Text; var ShowStandardUserInterface: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterMembInfoCaptureDialog(var MemberInfoCapture: Record "NPR MM Member Info Capture"; StandardUserInterface: Boolean; var LookupOK: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    [Obsolete('Replaced by OnAfterMembInfoCaptureDialog(var MemberInfoCapture: Record "NPR MM Member Info Capture"; StandardUserInterface: Boolean; var LookupOK: Boolean)')]
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
}
