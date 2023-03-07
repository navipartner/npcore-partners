codeunit 6059992 "NPR HL Integration Events"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    procedure OnAfterCreateDataLogSetup(IntegrationArea: Enum "NPR HL Integration Area")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetupDataLogSubsriberDataProcessingParams(IntegrationArea: Enum "NPR HL Integration Area"; TableID: Integer; var DataLogSubscriber: Record "NPR Data Log Subscriber"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCheckIfIntegrationAreaIsEnabled(IntegrationArea: Enum "NPR HL Integration Area"; var AreaIsEnabled: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCheckIfIsIntegratedTable(IntegrationArea: Enum "NPR HL Integration Area"; TableId: Integer; var TableIsIntegrated: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeFindRelatedMembers(DataLogEntry: Record "NPR Data Log Record"; var TempMembershipRole: Record "NPR MM Membership Role"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnFindRelatedMembers(DataLogEntry: Record "NPR Data Log Record"; var TempMembershipRole: Record "NPR MM Membership Role"; var Handled: Boolean)
    begin
    end;

    [Obsolete('In next release goes internal')]
    [IntegrationEvent(false, false)]
    procedure OnGenerateMemberUrlParameters(HLMember: Record "NPR HL HeyLoyalty Member"; NewMember: Boolean; var UrlParametersJObject: JsonObject)
    begin
    end;

    [Obsolete('In next release goes internal')]
    [IntegrationEvent(false, false)]
    procedure OnAfterAddAttributeToUrlParameters(HLMember: Record "NPR HL HeyLoyalty Member"; NewMember: Boolean; HLMemberAttribute: Record "NPR HL Member Attribute"; var UrlParametersJObject: JsonObject)
    begin
    end;

    [Obsolete('In next release goes internal')]
    [IntegrationEvent(false, false)]
    procedure OnUpdateHLMember(Member: Record "NPR MM Member"; MemberDeleted: Boolean; var HLMember: Record "NPR HL HeyLoyalty Member")
    begin
    end;

    [Obsolete('In next release goes internal')]
    [IntegrationEvent(false, false)]
    procedure OnReadHLResponseField_OnUpdateHLMember(var HLMember: Record "NPR HL HeyLoyalty Member"; ResponseFieldName: Text; HLMemberJToken: JsonToken)
    begin
    end;

    [Obsolete('In next release goes internal')]
    [IntegrationEvent(false, false)]
    procedure OnUpdateHLMemberWithDataFromHeyLoyalty(var HLMember: Record "NPR HL HeyLoyalty Member"; HLMemberJToken: JsonToken; OnlyEssentialFields: Boolean)
    begin
    end;

    [Obsolete('In next release goes internal')]
    [IntegrationEvent(false, false)]
    procedure OnUpdateMemberFromHL(HLMember: Record "NPR HL HeyLoyalty Member"; var Member: Record "NPR MM Member")
    begin
    end;

    [Obsolete('In next release goes internal')]
    [IntegrationEvent(false, false)]
    procedure OnAfterUpdateMemberFromHL(HLMember: Record "NPR HL HeyLoyalty Member"; Member: Record "NPR MM Member")
    begin
    end;

    [Obsolete('In next release goes internal')]
    [IntegrationEvent(false, false)]
    procedure OnCheckIfBCMemberUpdateIsRequired(xHLMember: Record "NPR HL HeyLoyalty Member"; HLMember: Record "NPR HL HeyLoyalty Member"; var UpdatedIsRequired: Boolean)
    begin
    end;

    [Obsolete('In next release goes internal')]
    [IntegrationEvent(false, false)]
    procedure OnUnsubscribeMember(var HLMember: Record "NPR HL HeyLoyalty Member"; HLMemberJToken: JsonToken)
    begin
    end;
}