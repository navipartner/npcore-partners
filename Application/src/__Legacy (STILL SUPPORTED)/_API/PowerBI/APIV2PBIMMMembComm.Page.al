page 6151546 "NPR APIV2 PBIMMMembComm"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v2.0';
    PageType = API;
    EntityName = 'mmMemberCommunication';
    EntitySetName = 'mmMemberCommunications';
    Caption = 'PowerBI MM Member Communication';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR MM Member Communication";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(id; Rec.SystemId) { }
                field(memberEntryNo; Rec."Member Entry No.") { }
                field(membershipEntryNo; Rec."Membership Entry No.") { }
                field(messageType; Rec."Message Type") { }
                field(preferredMethod; Rec."Preferred Method") { }
                field(acceptedCommunication; Rec."Accepted Communication") { }
                field(externalMemberNo; Rec."External Member No.") { }
                field(externalMembershipNo; Rec."External Membership No.") { }
                field(membershipCode; Rec."Membership Code") { }
                field(displayName; Rec."Display Name") { }

#IF NOT (BC17 or BC18 or BC19 or BC20)
                field(systemModifiedAt; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt)) { }
                field(systemRowVersion; Rec.SystemRowVersion) { }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt) { }
#ENDIF
            }
        }
    }
#IF NOT (BC17 or BC18 or BC19 or BC20)
    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
#ENDIF
}