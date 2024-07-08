page 6150867 "NPR APIV1 PBIMMMembComm"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
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
                field(systemModifiedAt; Rec.SystemModifiedAt) { }
                field(systemRowVersion; Rec.SystemRowVersion) { }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'System Created At', Locked = true;
                }
                field(systemCreatedBy; Rec.SystemCreatedBy)
                {
                    Caption = 'System Created By', Locked = true;
                }
#ENDIF
                field(changedAt; Rec."Changed At") { }
            }
        }
    }
}