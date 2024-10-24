codeunit 6059992 "NPR HL Integration Events"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterCreateDataLogSetup(IntegrationArea: Enum "NPR HL Integration Area")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSetupDataLogSubsriberDataProcessingParams(IntegrationArea: Enum "NPR HL Integration Area"; TableID: Integer; var DataLogSubscriber: Record "NPR Data Log Subscriber"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCheckIfIntegrationAreaIsEnabled(IntegrationArea: Enum "NPR HL Integration Area"; var AreaIsEnabled: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCheckIfIsIntegratedTable(IntegrationArea: Enum "NPR HL Integration Area"; TableId: Integer; var TableIsIntegrated: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeFindRelatedMembers(DataLogEntry: Record "NPR Data Log Record"; var TempMembershipRole: Record "NPR MM Membership Role"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnFindRelatedMembers(DataLogEntry: Record "NPR Data Log Record"; var TempMembershipRole: Record "NPR MM Membership Role"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGenerateMemberUrlParameters(HLMember: Record "NPR HL HeyLoyalty Member"; NewMember: Boolean; var UrlParametersJObject: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAddAttributeToUrlParameters(HLMember: Record "NPR HL HeyLoyalty Member"; NewMember: Boolean; HLMemberAttribute: Record "NPR HL Member Attribute"; var UrlParametersJObject: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAddHLMCFOptionToUrlParameters(HLMember: Record "NPR HL HeyLoyalty Member"; NewMember: Boolean; HLFieldName: Text; HLFieldOptionValueName: Text; var UrlParametersJObject: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnUpdateHLMember(Member: Record "NPR MM Member"; MemberDeleted: Boolean; var HLMember: Record "NPR HL HeyLoyalty Member")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnReadHLResponseField_OnUpdateHLMemberData(var HLMember: Record "NPR HL HeyLoyalty Member"; ResponseFieldName: Text; HLMemberJToken: JsonToken; var HLMemberRelatedDataUpdated: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnUpdateHLMemberWithDataFromHeyLoyalty(var HLMember: Record "NPR HL HeyLoyalty Member"; HLMemberJToken: JsonToken; OnlyEssentialFields: Boolean; var HLMemberRelatedDataUpdated: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnUpdateMemberFromHL(HLMember: Record "NPR HL HeyLoyalty Member"; var Member: Record "NPR MM Member")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterUpdateMemberFromHL(HLMember: Record "NPR HL HeyLoyalty Member"; Member: Record "NPR MM Member")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCheckIfBCMemberUpdateIsRequired(xHLMember: Record "NPR HL HeyLoyalty Member"; HLMember: Record "NPR HL HeyLoyalty Member"; var UpdatedIsRequired: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnUnsubscribeMember(var HLMember: Record "NPR HL HeyLoyalty Member"; HLMemberJToken: JsonToken)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeShowAssignedHLMCFOptionValues(AppliesToRecID: RecordID; MultiChoiceFieldCode: Code[20]; var Editable: Boolean; var HLMultiChoiceFldOption: Record "NPR HL MultiChoice Fld Option")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterManuallyModifyAssignedHLMCFOptionValues(AppliesToRecID: RecordID; MultiChoiceFieldCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAddFieldsToHeybookingDBPayload(TicketNotifEntry: Record "NPR TM Ticket Notif. Entry"; var FieldNameValueList: Dictionary of [Text, Text])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAddTicketAdmissionDataToHeybookingDBPayload(var AdmissionDataFieldNames: Dictionary of [Text, Text])
    begin
    end;

    procedure "HeyBookingDBFieldKey.ActualAdmissionDateTime"(): Text
    begin
        exit('ActualAdmissionDateTime');
    end;

    procedure "HeyBookingDBFieldKey.ScheduledAdmissionDateTime"(): Text
    begin
        exit('ScheduledAdmissionDateTime');
    end;

    procedure "HeyBookingDBFieldKey.TicketScanned"(): Text
    begin
        exit('TicketScanned');
    end;
}