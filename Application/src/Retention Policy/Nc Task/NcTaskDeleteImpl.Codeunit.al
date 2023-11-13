#IF NOT BC17 AND NOT BC18
codeunit 6184618 "NPR Nc Task Delete Impl." implements "Reten. Pol. Deleting"
{
    Access = Internal;

    procedure DeleteRecords(var RecordRef: RecordRef; var RetenPolDeletingParam: Record "Reten. Pol. Deleting Param" temporary);
    var
        NcTask: Record "NPR Nc Task";
        RetentionPolicyMgt: Codeunit "NPR Retention Policy Mgt.";
        Operation: Option Find,Delete;
        NumberOfRecords: Integer;
    begin
        RetentionPolicyMgt.FindAndDeleteRecords(NcTask, NumberOfRecords, Operation::Delete);
    end;
}
#endif