page 6150795 "NPR APIV1 PBIMMMemberArrLog"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'mmMemberArrLogEntry';
    EntitySetName = 'mmMemberArrLogEntry';
    Caption = 'PowerBI MM Membership Arr Log Entry';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR MM Member Arr. Log Entry";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(externalCardNo; Rec."External Card No.")
                {
                    Caption = 'External Card No.', Locked = true;
                }
                field(externalMemberNo; Rec."External Member No.")
                {
                    Caption = 'External Member No.', Locked = true;
                }
                field(externalMembershipNo; Rec."External Membership No.")
                {
                    Caption = 'External Membership No.';
                }
                field(scannerStationId; Rec."Scanner Station Id")
                {
                    Caption = 'Scanner Station Id', Locked = true;
                }
                field(localDate; Rec."Local Date")
                {
                    Caption = 'Local Date', Locked = true;
                }
                field(responseType; Rec."Response Type")
                {
                    Caption = 'Response Type', Locked = true;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
            }
        }
    }
}