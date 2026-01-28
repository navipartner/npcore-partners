#if not (BC17 or BC18)
codeunit 6184620 "NPR Reten. Pol. Filtering Impl" implements "Reten. Pol. Filtering"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-28';
    ObsoleteReason = 'No longer relevant, as NaviPartner uses its own retention policy handler in BC26+.';

    var
        RetentionPolicyMgt: Codeunit "NPR Retention Policy Mgt.";
        Operation: Option Find,Delete;
#if not (BC19 or BC20 or BC21)
        RecordReferenceIndirectPermission: Interface "Record Reference";
#endif

    procedure ApplyRetentionPolicyAllRecordFilters(RetentionPolicySetup: Record "Retention Policy Setup"; var FilterRecordRef: RecordRef; var RetenPolFilteringParam: Record "Reten. Pol. Filtering Param" temporary): Boolean
    begin
        exit(false);
    end;

    procedure ApplyRetentionPolicySubSetFilters(RetentionPolicySetup: Record "Retention Policy Setup"; var FilterRecordRef: RecordRef; var RetenPolFilteringParam: Record "Reten. Pol. Filtering Param" temporary): Boolean
    var
#if not (BC19 or BC20 or BC21)
        RecordReference: Codeunit "Record Reference";
#endif
        NumberOfRecords: Integer;
    begin
        FilterRecordRef.Open(RetentionPolicySetup."Table ID");
#if not (BC19 or BC20 or BC21)
        RecordReference.Initialize(FilterRecordRef, RecordReferenceIndirectPermission);
#endif
        RetentionPolicyMgt.FindOrDeleteRecords(FilterRecordRef, NumberOfRecords, Operation::Find);
        FilterRecordRef.MarkedOnly(true);
        exit(NumberOfRecords > 0);
    end;

    procedure HasReadPermission(TableId: Integer): Boolean
    var
#if not (BC19 or BC20 or BC21)
        RecordReference: Codeunit "Record Reference";
#endif
        RecordRef: RecordRef;
    begin
        RecordRef.Open(TableId);

#if BC19 or BC20 or BC21
        exit(RecordRef.ReadPermission())
#else
        RecordReference.Initialize(RecordRef, RecordReferenceIndirectPermission);
        exit(RecordReferenceIndirectPermission.ReadPermission(RecordRef))
#endif
    end;

    procedure Count(RecordRef: RecordRef): Integer
    var
        NumberOfRecords: Integer;
    begin
        RetentionPolicyMgt.FindOrDeleteRecords(RecordRef, NumberOfRecords, Operation::Find);
        exit(NumberOfRecords);
    end;
}
#endif