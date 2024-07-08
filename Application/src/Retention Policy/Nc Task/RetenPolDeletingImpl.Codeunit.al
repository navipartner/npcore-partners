#IF NOT BC17 AND NOT BC18
codeunit 6184618 "NPR Reten. Pol. Deleting Impl." implements "Reten. Pol. Deleting"
{
    Access = Internal;

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