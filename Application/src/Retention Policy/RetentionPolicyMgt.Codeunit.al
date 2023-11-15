#IF NOT BC17 AND NOT BC18
codeunit 6184619 "NPR Retention Policy Mgt."
{
    Access = Internal;

    var
        ModifyErrMsgLbl: Label 'The retention policy setup for table %1 %2 has been predefined by NaviPartner, and cannot be changed. However, you can modify the Retention Period for lines that are not locked.', Comment = '%1 - table number, %2 - table caption';

    #region Setting filters on table

    internal procedure FindOrDeleteRecords(var RecRef: RecordRef; var ProcessedCount: Integer; Operation: Option Find,Delete)
    var
        NcTask: Record "NPR Nc Task";
        UnsupportedTableIDErr: Label 'NaviPartner retention policy implementation does not support table %1 %2. Please contact your system vendor.', Comment = '%1 - table number, %2 - table caption';
    begin
        case RecRef.Number() of
            Database::"NPR Nc Task":
                begin
                    FindOrDeleteRecords(NcTask, ProcessedCount, Operation);
                    RecRef.Copy(NcTask);
                end;
            else
                Error(UnsupportedTableIDErr, RecRef.Number(), RecRef.Caption());
        end;
    end;

    local procedure FindOrDeleteRecords(var NcTask: Record "NPR Nc Task"; var ProcessedCount: Integer; Operation: Option Find,Delete)
    var
        NcTaskArray: Array[2] of Record "NPR Nc Task";
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
        ExpirationDate: Date;
        I: Integer;
        RetainEntry: Boolean;
        RecordLimitExceeded: Boolean;
    begin
        I := 1;
        if not RetentionPolicySetup.Get(Database::"NPR Nc Task") then
            exit;

        NcTask.FilterGroup(-1);
        NcTask.SetRange(Processed, true);
        NcTask.SetRange("Process Error", true);
        NcTask.FilterGroup(0);

        ExpirationDate := GetYoungestExpirationDate(RetentionPolicySetup);
        if ExpirationDate <> 0D then
            NcTask.SetFilter(SystemCreatedAt, '<=%1', CreateDateTime(ExpirationDate, 235959T));

        if NcTask.IsEmpty() then
            exit;

        // Filter records that are to be retained
        RetentionPolicySetupLine.SetRange("Table ID", RetentionPolicySetup."Table Id");
        RetentionPolicySetupLine.SetRange(Enabled, true);

        if RetentionPolicySetupLine.IsEmpty() then
            exit;

        RetentionPolicySetupLine.FindSet();
        repeat
            if ShouldProcessLine(RetentionPolicySetupLine) then begin
                NcTaskArray[I].SetView(RetentionPolicySetupLine.GetTableFilterView());
                RetentionPeriod.Get(RetentionPolicySetupLine."Retention Period");
                ExpirationDate := CalculateExpirationDate(RetentionPeriod);
                NcTaskArray[I].SetFilter(SystemCreatedAt, '>%1', CreateDateTime(ExpirationDate, 235959T));
                I += 1;
            end;
        until (RetentionPolicySetupLine.Next() = 0) or (I > ArrayLen(NcTaskArray));

        NcTask.SetCurrentKey("Entry No.");
        NcTask.SetAscending("Entry No.", true);

        NcTask.FindSet();
        repeat
            I := 1;
            repeat
                NcTaskArray[I].SetRange("Entry No.", NcTask."Entry No.");
                RetainEntry := not NcTaskArray[I].IsEmpty();
                I += 1;
            until (I > ArrayLen(NcTaskArray)) or RetainEntry;

            if not RetainEntry then begin
                ProcessedCount += 1;
                if Operation = Operation::Find then
                    NcTask.Mark(true)
                else begin
                    NcTask.Delete(true);
                    RecordLimitExceeded := ProcessedCount = MaxNumberOfRecordsToDelete();
                end;
            end;
        until (NcTask.Next() = 0) or RecordLimitExceeded;
    end;

    #endregion

    #region Helper functions

    internal procedure CalculateRetentionPeriodDateFormula(RetentionPeriod: Record "Retention Period"): Text
    var
        RetentionPeriodInterface: Interface "Retention Period";
    begin
        RetentionPeriodInterface := RetentionPeriod."Retention Period";
        exit(RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod));
    end;

    internal procedure ShouldProcessLine(RetentionPolicySetupLine: Record "Retention Policy Setup Line"): Boolean
    var
        RetentionPeriod: Record "Retention Period";
    begin
        if not RetentionPeriod.Get(RetentionPolicySetupLine."Retention Period") then
            exit(false);

        if RetentionPeriod."Retention Period" = RetentionPeriod."Retention Period"::"Never Delete" then
            exit(false);

        exit(true);
    end;

    internal procedure GetYoungestExpirationDate(RetentionPolicySetup: Record "Retention Policy Setup") Result: Date
    var
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
        RetentionPeriod: Record "Retention Period";
        ExpirationDate: Date;
    begin
        RetentionPolicySetupLine.SetRange("Table ID", RetentionPolicySetup."Table Id");
        RetentionPolicySetupLine.SetRange(Enabled, true);

        if RetentionPolicySetupLine.IsEmpty() then
            exit;

        RetentionPolicySetupLine.FindSet();
        repeat
            if ShouldProcessLine(RetentionPolicySetupLine) then begin
                if RetentionPeriod.Get(RetentionPolicySetupLine."Retention Period") then
                    ExpirationDate := CalculateExpirationDate(RetentionPeriod);
                if ExpirationDate >= Result then
                    Result := ExpirationDate;
            end;
        until RetentionPolicySetupLine.Next() = 0;
    end;

    internal procedure CalculateExpirationDate(RetentionPeriod: Record "Retention Period") Result: Date
    var
        RetentionPeriodInterface: Interface "Retention Period";
    begin
        RetentionPeriodInterface := RetentionPeriod."Retention Period";
        Result := RetentionPeriodInterface.CalculateExpirationDate(RetentionPeriod);
        if Result >= Today() then
            Clear(Result);
    end;

    local procedure IsNPRTable(TableID: Integer): Boolean
    begin
        exit(TableID in
          [Database::"NPR Nc Task"]);
    end;

    local procedure GetTableCaption(TableId: Integer): Text
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, TableId) then
            exit(AllObjWithCaption."Object Caption");
    end;

    #endregion

    #region Constants 

    internal procedure MaxNumberOfRecordsToDelete(): Integer
    begin
        exit(10000);
    end;

    #endregion

    #region Subscribers

    [EventSubscriber(ObjectType::Page, Page::"Retention Policy Setup Lines", 'OnModifyRecordEvent', '', false, false)]
    local procedure RetentionPolicySetupLines_OnModifyRecordEvent(var Rec: Record "Retention Policy Setup Line"; var xRec: Record "Retention Policy Setup Line")
    begin
        if not IsNPRTable(Rec."Table ID") then
            exit;

        if Rec.GetTableFilterText() = xRec.GetTableFilterText() then
            exit;

        Error(ModifyErrMsgLbl, Rec."Table ID", GetTableCaption(Rec."Table ID"));
    end;

    [EventSubscriber(ObjectType::Page, Page::"Retention Policy Setup Lines", 'OnInsertRecordEvent', '', false, false)]
    local procedure RetentionPolicySetupLines_OnInsertRecordEvent(var Rec: Record "Retention Policy Setup Line")
    begin
        if not IsNPRTable(Rec."Table ID") then
            exit;

        Error(ModifyErrMsgLbl, Rec."Table ID", GetTableCaption(Rec."Table ID"));
    end;

    [EventSubscriber(ObjectType::Page, Page::"Retention Policy Setup Lines", 'OnDeleteRecordEvent', '', false, false)]
    local procedure RetentionPolicySetupLines_OnDeleteRecordEvent(var Rec: Record "Retention Policy Setup Line")
    begin
        if not IsNPRTable(Rec."Table ID") then
            exit;

        Error(ModifyErrMsgLbl, Rec."Table ID", GetTableCaption(Rec."Table ID"));
    end;

    #endregion
}
#ENDIF