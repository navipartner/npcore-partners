codeunit 6014664 "NPR Cleanup JQ Log Entries"
{
    #region execute
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        PurgeOldJobQueueLogEntries(Rec);
    end;

    local procedure PurgeOldJobQueueLogEntries(JobQueueEntry: Record "Job Queue Entry")
    var
        JobQueueLogEntry: Record "Job Queue Log Entry";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        PurgeDateFormula: DateFormula;
        PurgeUntil: Date;
    begin
        if JobQueueEntry."Parameter String" <> '' then begin
            JQParamStrMgt.Parse(JobQueueEntry."Parameter String");
            if JQParamStrMgt.ContainsParam(ParamClearBeforeDF()) then
                if Evaluate(PurgeDateFormula, JQParamStrMgt.GetText(ParamClearBeforeDF())) then
                    PurgeUntil := CalcDate(PurgeDateFormula, Today);
        end;
        if (PurgeUntil = 0D) or (PurgeUntil >= Today) then
            PurgeUntil := CalcDate(DefaultDateFormula(), Today);

        JobQueueLogEntry.SetCurrentKey("Start Date/Time");
        JobQueueLogEntry.SetFilter("Start Date/Time", '<%1', CreateDateTime(PurgeUntil, 0T));
        if not JobQueueLogEntry.IsEmpty() then
            JobQueueLogEntry.DeleteAll();
    end;
    #endregion

    #region instantiate
    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnAfterValidateEvent', 'Object ID to Run', true, true)]
    local procedure OnValidateJobQueueEntryObjectIDtoRun(var Rec: Record "Job Queue Entry")
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
            exit;
        if Rec."Object ID to Run" <> CurrCodeunitId() then
            exit;

        Rec.Validate("Parameter String", CopyStr(GetDefaultParameterString(), 1, MaxStrLen(Rec."Parameter String")));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', true, false)]
    local procedure InitJQLogCleanupJob_OnCompanyInitialize()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if TaskScheduler.CanCreateTask() then
            InitJQLogCleanupJob(JobQueueEntry);
    end;

    procedure AddJQLogCleanupJob(var JobQueueEntry: Record "Job Queue Entry"; Silent: Boolean): Boolean
    var
        ConfirmJobCreationQst: Label 'This function will add a new periodic job (Job Queue Entry), responsible for purging outdated (older than 30 days) Joq Queue Log entries.\Are you sure you want to continue?';
    begin
        if not Silent then
            if not Confirm(ConfirmJobCreationQst, true) then
                exit(false);
        exit(InitJQLogCleanupJob(JobQueueEntry));
    end;

    local procedure InitJQLogCleanupJob(var JobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        JobQueueCategory: Record "Job Queue Category";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NotBeforeDateTime: DateTime;
        NextRunDateFormula: DateFormula;
        JobCategoryDescrLbl: Label 'Cleanup Job Queue Log Entries', MaxLength = 30;
        JobQueueDescrLbl: Label 'Purges old Job Queue Log entries', MaxLength = 250;
    begin
        NotBeforeDateTime := CreateDateTime(Today, 020000T);
        Evaluate(NextRunDateFormula, '<1D>');
        JobQueueCategory.InsertRec(JQCategoryCode(), JobCategoryDescrLbl);

        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            CurrCodeunitId(),
            GetDefaultParameterString(),
            JobQueueDescrLbl,
            NotBeforeDateTime,
            DT2Time(NotBeforeDateTime),
            030000T,
            NextRunDateFormula,
            JQCategoryCode(),
            JobQueueEntry)
        then begin
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry, NotBeforeDateTime);
            exit(true);
        end;
    end;

    local procedure GetDefaultParameterString(): Text
    var
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        DFSubstringLbl: Label '%1=%2', Locked = true, Comment = '%1 - parameter name, %2 - parameter value';
    begin
        JQParamStrMgt.ClearParamDict();
        JQParamStrMgt.AddToParamDict(StrSubstNo(DFSubstringLbl, ParamClearBeforeDF(), DefaultDateFormula()));
        exit(JQParamStrMgt.GetParamListAsCSString());
    end;
    #endregion

    #region constants
    local procedure ParamClearBeforeDF(): Text
    begin
        exit('ClearBeforeDF');
    end;

    local procedure DefaultDateFormula(): Text
    begin
        exit('<-30D>');
    end;

    local procedure JQCategoryCode(): Code[10]
    begin
        exit('CLEARJQLOG');
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR Cleanup JQ Log Entries");
    end;
    #endregion
}