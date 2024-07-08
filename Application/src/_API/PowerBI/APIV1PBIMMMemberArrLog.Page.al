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
                field(lastModifiedDateTime; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt))
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Filter', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(eventType; Rec."Event Type")
                {
                    Caption = 'Event Type', Locked = true;
                }
                field(createdAt; Rec."Created At")
                {
                    Caption = 'Created At', Locked = true;
                }
                field(localTime; Rec."Local Time")
                {
                    Caption = 'Local Time', Locked = true;
                }
                field(admissionCode; Rec."Admission Code")
                {
                    Caption = 'Admission Code', Locked = true;
                }
                field(temporaryCard; Rec."Temporary Card")
                {
                    Caption = 'Temporary Card', Locked = true;
                }
                field(responseMessage; Rec."Response Message")
                {
                    Caption = 'Response Message', Locked = true;
                }
                field(responseCode; Rec."Response Code")
                {
                    Caption = 'Response Code', Locked = true;
                }
                field(responseRuleEntryNo; Rec."Response Rule Entry No.")
                {
                    Caption = 'Response Rule Entry No.', Locked = true;
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'System Created At', Locked = true;
                }
                field(systemCreatedBy; Rec.SystemCreatedBy)
                {
                    Caption = 'System Created By', Locked = true;
                }
            }
        }
    }
    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
}