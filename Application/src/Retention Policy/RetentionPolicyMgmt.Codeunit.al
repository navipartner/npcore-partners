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
        RetentionPolicy.SetAutoCalcFields(RetentionPolicy."Table Caption");
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

    internal procedure UpsertTablePolicy(TableId: Integer; var RetentionPolicyEnum: Enum "NPR Retention Policy V2")
    var
        RetentionPolicy: Record "NPR Retention Policy";
    begin
        if RetentionPolicy.Get(TableId) then begin
            if RetentionPolicy."Implementation V2" <> RetentionPolicyEnum then begin
                RetentionPolicy."Implementation V2" := RetentionPolicyEnum;
                RetentionPolicy.Modify();
            end;
        end else begin
            RetentionPolicy.Init();
            RetentionPolicy.Validate("Table Id", TableId);
            RetentionPolicy."Implementation V2" := RetentionPolicyEnum;
            RetentionPolicy.Enabled := true;
            RetentionPolicy.Insert();
        end;
    end;

    internal procedure DeleteTablePolicy(TableId: Integer)
    var
        RetentionPolicy: Record "NPR Retention Policy";
        NonExistantPolicyErr: Label 'NPR Retention policy for table %1 doesn''t exist.';
    begin
        if RetentionPolicy.Get(TableId) then
            RetentionPolicy.Delete()
        else
            Error(NonExistantPolicyErr, TableId);
    end;

    internal procedure ShowDefaultNPSetup(RetentionPolicy: Record "NPR Retention Policy"; RetentionPeriodsEditable: Boolean)
    var
        EmptyPeriodDescriptions: Dictionary of [Enum "NPR Retention Period Type", Text];
    begin
        ShowDefaultNPSetup(RetentionPolicy, RetentionPeriodsEditable, EmptyPeriodDescriptions);
    end;

    internal procedure ShowDefaultNPSetup(RetentionPolicy: Record "NPR Retention Policy"; RetentionPeriodsEditable: Boolean;
                                          PeriodDescriptions: Dictionary of [Enum "NPR Retention Period Type", Text])
    var
        RetentionPeriodInfo: Page "NPR Retention Period Info";
        NewPeriods: Dictionary of [Enum "NPR Retention Period Type", DateFormula];
    begin
        RetentionPeriodInfo.SetRetentionPeriodsEditable(RetentionPeriodsEditable);
        RetentionPeriodInfo.SetRetentionPeriodDescriptions(PeriodDescriptions);
        RetentionPeriodInfo.SetRetentionPolicy(RetentionPolicy);

        if not RetentionPeriodsEditable then begin
            RetentionPeriodInfo.RunModal();
            exit;
        end;

        RetentionPeriodInfo.LookupMode(true);
        if RetentionPeriodInfo.RunModal() = Action::LookupOK then begin
            RetentionPeriodInfo.GetRetentionPeriods(NewPeriods);
            SaveNonDefaultPeriods(RetentionPolicy, NewPeriods);
        end;
    end;

    local procedure SaveNonDefaultPeriods(RetentionPolicy: Record "NPR Retention Policy"; NewPeriods: Dictionary of [Enum "NPR Retention Period Type", DateFormula])
    var
        PeriodType: Enum "NPR Retention Period Type";
    begin
        foreach PeriodType in NewPeriods.Keys() do
            SaveNonDefaultPeriod(RetentionPolicy, PeriodType, NewPeriods.Get(PeriodType));
    end;

    local procedure SaveNonDefaultPeriod(RetentionPolicy: Record "NPR Retention Policy"; PeriodType: Enum "NPR Retention Period Type"; NewPeriod: DateFormula)
    var
        RetentionPolicyPeriod: Record "NPR Retention Policy Period";
        DefaultPeriod: DateFormula;
        EmptyDateFormula: DateFormula;
    begin
        DefaultPeriod := RetentionPolicy.GetDefaultRetentionPeriod(PeriodType);

        if RetentionPolicyPeriod.Get(RetentionPolicy."Table Id", PeriodType) then begin
            if (NewPeriod = DefaultPeriod) or (NewPeriod = EmptyDateFormula) then
                RetentionPolicyPeriod.Delete()
            else
                if RetentionPolicyPeriod."Retention Period" <> NewPeriod then begin
                    RetentionPolicyPeriod."Retention Period" := NewPeriod;
                    RetentionPolicyPeriod.Modify();
                end;
        end else
            if (NewPeriod <> DefaultPeriod) and (NewPeriod <> EmptyDateFormula) then begin
                RetentionPolicyPeriod.Init();
                RetentionPolicyPeriod."Table Id" := RetentionPolicy."Table Id";
                RetentionPolicyPeriod."Period Type" := PeriodType;
                RetentionPolicyPeriod."Retention Period" := NewPeriod;
                RetentionPolicyPeriod.Insert();
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