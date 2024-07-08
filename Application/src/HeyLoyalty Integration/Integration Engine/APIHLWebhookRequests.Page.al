page 6150800 "NPR API - HL Webhook Requests"
{
    PageType = API;
    APIVersion = 'v2.0';
    APIPublisher = 'navipartner';
    APIGroup = 'heyloyalty';
    Caption = 'HL Webhook Requests';
    EntityCaption = 'HL Webhook Request';
    EntitySetCaption = 'HL Webhook Requests';
    ChangeTrackingAllowed = false;
    DelayedInsert = true;
    EntityName = 'webhookRequest';
    EntitySetName = 'webhookRequests';
    SourceTable = "NPR HL Webhook Request";
    ODataKeyFields = SystemId;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(memberId; Rec."HL Member ID")
                {
                    Caption = 'HL Member ID', Locked = true;
                }
                field(listId; Rec."HL List ID")
                {
                    Caption = 'HL List ID', Locked = true;
                }
                field(refId; Rec."HL Reference ID")
                {
                    Caption = 'HL Reference ID', Locked = true;
                }
                field(messageType; Rec."HL Message Type")
                {
                    Caption = 'HL Message Type', Locked = true;
                }
                field(type; Rec."HL Request Type")
                {
                    Caption = 'HL Request Type', Locked = true;
                }
                field(webhookId; Rec."HL Webhook ID")
                {
                    Caption = 'HL Webhook ID', Locked = true;
                }
                field(queuedAt; Rec."HL Queued at")
                {
                    Caption = 'HL Queued at', Locked = true;
                }
                field(signature; Rec."HL Signature")
                {
                    Caption = 'HL Request Type', Locked = true;
                }
                field(member; HLMemberData)
                {
                    Caption = 'HL Member Data', Locked = true;
                    trigger OnValidate()
                    begin
                        Rec.SetHLRequestData(HLMemberData);
                    end;
                }
                field(systemId; Rec.SystemId)
                {
                    Caption = 'BC System Id', Locked = true;
                    Editable = false;
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'BC Created at', Locked = true;
                    Editable = false;
                }
#IF NOT (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'BC Row Version', Locked = true;
                }
#ENDIF
            }
        }
    }

    var
        HLMemberData: Text;
}