page 6150852 "NPR API V1 PBI SGEntryLog"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'speedgateEntry';
    EntitySetName = 'speedgateEntries';
    Caption = 'PowerBI Speedgate Entry';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR SGEntryLog";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(admissionCode; Rec.AdmissionCode)
                {
                    Caption = 'Admission Code', Locked = true;
                }
                field(admittedAt; Rec.AdmittedAt)
                {
                    Caption = 'Admitted At', Locked = true;
                }
                field(admittedReferenceNo; Rec.AdmittedReferenceNo)
                {
                    Caption = 'Admitted Reference No', Locked = true;
                }
                field(apiErrorNumber; Rec.ApiErrorNumber)
                {
                    Caption = 'Api Error Number', Locked = true;
                }
                field(entityId; Rec.EntityId)
                {
                    Caption = 'Entity Id', Locked = true;
                }
                field(entryNo; Rec.EntryNo)
                {
                    Caption = 'EntryNo', Locked = true;
                }
                field(entryStatus; Rec.EntryStatus)
                {
                    Caption = 'Entry Status', Locked = true;
                }
                field(extraEntityId; Rec.ExtraEntityId)
                {
                    Caption = 'Extra Entity Id', Locked = true;
                }
                field(extraEntityTableId; Rec.ExtraEntityTableId)
                {
                    Caption = 'Extra Entity Table Id', Locked = true;
                }
                field(memberCardLogEntryNo; Rec.MemberCardLogEntryNo)
                {
                    Caption = 'Member Card Log Entry No', Locked = true;
                }
                field(referenceNo; Rec.ReferenceNo)
                {
                    Caption = 'Reference No', Locked = true;
                }
                field(referenceNumberType; Rec.ReferenceNumberType)
                {
                    Caption = 'Entry Type', Locked = true;
                }
                field(scannerId; Rec.ScannerId)
                {
                    Caption = 'Scanner Id', Locked = true;
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'SystemCreatedAt', Locked = true;
                }
                field(systemCreatedBy; Rec.SystemCreatedBy)
                {
                    Caption = 'SystemCreatedBy', Locked = true;
                }
                field(systemId; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'SystemModifiedAt', Locked = true;
                }
                field(systemModifiedBy; Rec.SystemModifiedBy)
                {
                    Caption = 'SystemModifiedBy', Locked = true;
                }
                field(token; Rec.Token)
                {
                    Caption = 'Token', Locked = true;
                }
                field(parentToken; Rec.ParentToken)
                {
                    Caption = 'Parent Token', Locked = true;
                }
#if not (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'System Row Version', Locked = true;
                }
#endif
            }
        }
    }
}
