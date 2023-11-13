#IF NOT BC17 AND NOT BC18
codeunit 6184620 "NPR Nc Task Filtering Impl." implements "Reten. Pol. Filtering"
{
    Access = Internal;

    var
        RetentionPolicyMgt: Codeunit "NPR Retention Policy Mgt.";
        Operation: Option Find,Delete;
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        RecordReferenceIndirectPermission: Interface "Record Reference";
#endif

    procedure ApplyRetentionPolicyAllRecordFilters(RetentionPolicySetup: Record "Retention Policy Setup"; var FilterRecordRef: RecordRef; var RetenPolFilteringParam: Record "Reten. Pol. Filtering Param" temporary): Boolean
    begin
        exit(false);
    end;

    procedure ApplyRetentionPolicySubSetFilters(RetentionPolicySetup: Record "Retention Policy Setup"; var FilterRecordRef: RecordRef; var RetenPolFilteringParam: Record "Reten. Pol. Filtering Param" temporary): Boolean
    var
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        RecordReference: Codeunit "Record Reference";
#endif
        NumberOfRecords: Integer;
        NcTask: Record "NPR Nc Task";
    begin
        FilterRecordRef.Open(RetentionPolicySetup."Table ID");
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        RecordReference.Initialize(FilterRecordRef, RecordReferenceIndirectPermission);
#endif
        RetentionPolicyMgt.FindAndDeleteRecords(NcTask, NumberOfRecords, Operation::Find);
        NcTask.MarkedOnly(true);
        FilterRecordRef.Copy(NcTask);
        exit(NumberOfRecords > 0);
    end;

    procedure HasReadPermission(TableId: Integer): Boolean
    var
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        RecordReference: Codeunit "Record Reference";
#endif
        RecordRef: RecordRef;
    begin
        RecordRef.Open(TableId);

#if BC17 or BC18 or BC19 or BC20 or BC21
        exit(RecordRef.ReadPermission())
#else
        RecordReference.Initialize(RecordRef, RecordReferenceIndirectPermission);
        exit(RecordReferenceIndirectPermission.ReadPermission(RecordRef))
#endif
    end;

    procedure Count(RecordRef: RecordRef): Integer
    var
        NcTask: Record "NPR Nc Task";
        NumberOfRecords: Integer;
    begin
        RetentionPolicyMgt.FindAndDeleteRecords(NcTask, NumberOfRecords, Operation::Find);
        exit(NumberOfRecords);
    end;
}
#ENDIF