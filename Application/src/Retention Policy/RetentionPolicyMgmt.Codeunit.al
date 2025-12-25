#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248677 "NPR Retention Policy Mgmt."
{
    Access = Internal;

    var
        MessageType: Enum "Retention Policy Log Message Type";
        ProcessingDialogMsg: Label 'Deleting records based on the retention policy.';

    internal procedure ApplyAllRetentionPolicies()
    var
        RetentionPolicy: Record "NPR Retention Policy";
    begin
        RetentionPolicy.SetRange(Enabled, true);
        RetentionPolicy.SetAutoCalcFields("Table Caption");
        if RetentionPolicy.FindSet() then
            repeat
                ApplyRetentionPolicy(RetentionPolicy)
            until (RetentionPolicy.Next() = 0);
    end;

    local procedure ApplyRetentionPolicy(RetentionPolicy: Record "NPR Retention Policy")
    var
        SuccessfulApplicationMsg: Label 'Retention policy has been successfully applied for table %1 %2.', Comment = '%1 = Table Id, %2 = Table Caption';
        ErrorOccurredDuringApplicationErr: Label 'An error occurred while applying the retention policy for table %1 %2. %3', Comment = '%1 = Table Id, %2 = Table Caption, %3 = Error Message';
    begin
        ClearLastError();
        if Codeunit.Run(Codeunit::"NPR Apply Retention Policy", RetentionPolicy) then
            LogInfo(StrSubstNo(SuccessfulApplicationMsg, RetentionPolicy."Table Id", RetentionPolicy."Table Caption"))
        else
            LogError(StrSubstNo(ErrorOccurredDuringApplicationErr, RetentionPolicy."Table Id", RetentionPolicy."Table Caption", GetLastErrorText()));
        Commit();
    end;

    internal procedure ApplyRetentionPoliciesManually()
    var
        Dialog: Dialog;
        ManualUserPoliciesApplicationLbl: Label 'Manual application of all retention policies via page action started by a user.';
    begin
        LogInfo(ManualUserPoliciesApplicationLbl);
        Commit();

        Dialog.Open(ProcessingDialogMsg);
        ApplyAllRetentionPolicies();
        Dialog.Close();
    end;

    internal procedure ApplyOneRetentionPolicyManually(RetentionPolicy: Record "NPR Retention Policy")
    var
        Dialog: Dialog;
        ManualUserPolicyApplicationLbl: Label 'Manual application of table %1 %2 retention policy via page action started by a user.', Comment = '%1 = Table Id, %2 = Table Caption';
    begin
        RetentionPolicy.CalcFields("Table Caption");
        LogInfo(StrSubstNo(ManualUserPolicyApplicationLbl, RetentionPolicy."Table Id", RetentionPolicy."Table Caption"));
        Commit();

        Dialog.Open(ProcessingDialogMsg);
        ApplyRetentionPolicy(RetentionPolicy);
        Dialog.Close();
    end;

    #region Logging
    internal procedure LogInfo(Message: Text[2048]);
    begin
        CreateLogEntry(MessageType::Info, Message);
    end;

    internal procedure LogError(Message: Text[2048]);
    begin
        CreateLogEntry(MessageType::Error, Message);
    end;

    local procedure CreateLogEntry(EntryMessageType: Enum "Retention Policy Log Message Type"; Message: Text[2048])
    var
        RetentionPolicyLogEntry: Record "NPR Retention Policy Log Entry";
    begin
        RetentionPolicyLogEntry.Init();
        RetentionPolicyLogEntry."Message Type" := EntryMessageType;
        if EntryMessageType = EntryMessageType::Error then
            RetentionPolicyLogEntry.SetErrorCallStack(GetLastErrorCallstack());
        RetentionPolicyLogEntry.Message := Message;
        RetentionPolicyLogEntry."Entry No." := 0;
        RetentionPolicyLogEntry.Insert();
    end;
    #endregion

    internal procedure AddTablePolicy(TableId: Integer; var RetentionPolicyEnum: Enum "NPR Retention Policy")
    var
        RetentionPolicy: Record "NPR Retention Policy";
    begin
        if RetentionPolicy.Get(TableId) then begin
            if RetentionPolicy.Implementation <> RetentionPolicyEnum then begin
                RetentionPolicy.Implementation := RetentionPolicyEnum;
                RetentionPolicy.Modify();
            end;
        end else begin
            RetentionPolicy.Init();
            RetentionPolicy.Validate("Table Id", TableId);
            RetentionPolicy.Implementation := RetentionPolicyEnum;
            RetentionPolicy.Enabled := true;
            RetentionPolicy.Insert();
        end;
    end;

    #region Job Queue
    internal procedure SetupRetentionPolicyJobQueue()
    var
        JobQueueCategory: Record "Job Queue Category";
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NextRunDateFormula: DateFormula;
        JQCategoryCodeLbl: Label 'NPR-RETPOL', Locked = true;
        JQCategoryDescLbl: Label 'NPR Retention Policy';
    begin
        Evaluate(NextRunDateFormula, '<1D>');
        JobQueueCategory.InsertRec(JQCategoryCodeLbl, JQCategoryDescLbl);
        JobQueueMgt.SetProtected(true);

        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR Retention Policy JQ",
            '',
            JQCategoryDescLbl,
            JobQueueMgt.NowWithDelayInSeconds(360),
            230000T,
            235959T,
            NextRunDateFormula,
            JobQueueCategory.Code,
            JobQueueEntry)
        then
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
    local procedure RefreshJobQueueEntry()
    begin
        SetupRetentionPolicyJobQueue();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnCheckIfIsNprCustomizableJob, '', false, false)]
    local procedure SetAsNprCustomizableJob(JobQueueEntry: Record "Job Queue Entry"; var NprCustomizableJob: Boolean; var Handled: Boolean)
    begin
        if Handled then
            exit;

        if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and (JobQueueEntry."Object ID to Run" = Codeunit::"NPR Retention Policy JQ") then begin
            NprCustomizableJob := true;
            Handled := true;
        end
    end;
    #endregion
}
#endif