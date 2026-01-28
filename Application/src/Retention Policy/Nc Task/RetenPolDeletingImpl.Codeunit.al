#if not (BC17 or BC18)
codeunit 6184618 "NPR Reten. Pol. Deleting Impl." implements "Reten. Pol. Deleting"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-28';
    ObsoleteReason = 'No longer relevant, as NaviPartner uses its own retention policy handler in BC26+.';

    procedure DeleteRecords(var RecordRef: RecordRef; var RetenPolDeletingParam: Record "Reten. Pol. Deleting Param" temporary);
    var
        RetentionPolicyMgt: Codeunit "NPR Retention Policy Mgt.";
        Operation: Option Find,Delete;
        NumberOfRecords: Integer;
    begin
        RetentionPolicyMgt.FindOrDeleteRecords(RecordRef, NumberOfRecords, Operation::Delete);
    end;
}
#endif