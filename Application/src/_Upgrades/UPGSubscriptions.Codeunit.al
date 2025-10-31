codeunit 6185060 "NPR UPG Subscriptions"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeStep: Text;

    trigger OnUpgradePerCompany()
    begin
        CreateSubscriptions();
        SetMaxRecurringPaymentProcessingTryCount();
        SetMaxSubscriptionRequestProcessingTryCount();
        ScheduleSubscriptionRequestCreationJobQueue();
        ScheduleSubscriptionPaymentRequestProcessingJobQueue();
        ScheduleSubscriptionRequestProcessingJobQueue();
        UpdateSubscriptionAutoRenewStatus();
        UpdateSubscriptionRenewReqJobStartTime();
        UpdateSubscriptionRenewProcJobStartTime();
        UpgradeTerminationSubsRequest();
    end;

    internal procedure CreateSubscriptions()
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
    begin
        UpgradeStep := 'CreateSubscriptions';
        if HasUpgradeTag() then
            exit;

        if Membership.FindSet() then
            repeat
                MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
                MembershipEntry.SetRange(Blocked, false);
                MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
                if MembershipEntry.FindLast() then
                    SubscriptionMgtImpl.UpdateMembershipSubscriptionDetails(Membership, MembershipEntry);
            until Membership.Next() = 0;

        SetUpgradeTag();
    end;

    internal procedure ScheduleSubscriptionRequestCreationJobQueue()
    var
        SubscrRequestUtils: Codeunit "NPR MM Subscr. Request Utils";
    begin
        UpgradeStep := 'ScheduleSubscriptionRequestCreationJobQueue';
        if HasUpgradeTag() then
            exit;

        SubscrRequestUtils.ScheduleSubscriptionRequestCreationJobQueueEntry();

        SetUpgradeTag();
    end;

    internal procedure ScheduleSubscriptionRequestProcessingJobQueue()
    var
        SubscrRequestUtils: Codeunit "NPR MM Subscr. Request Utils";
    begin
        UpgradeStep := 'ScheduleSubscriptionRequestProcessingJobQueue';
        if HasUpgradeTag() then
            exit;

        SubscrRequestUtils.ScheduleSubscriptionRequestProcessingJobQueueEntry();

        SetUpgradeTag();
    end;

    internal procedure ScheduleSubscriptionPaymentRequestProcessingJobQueue()
    var
        SubsPayRequestUtils: Codeunit "NPR MM Subs Pay Request Utils";
    begin
        UpgradeStep := 'ScheduleSubscriptionPaymentRequestProcessingJobQueue';
        if HasUpgradeTag() then
            exit;

        SubsPayRequestUtils.ScheduleSubscriptionPaymentRequestProcessingJobQueueEntryScheduled();

        SetUpgradeTag();
    end;

    local procedure SetMaxRecurringPaymentProcessingTryCount()
    var
        RecurPaymSetup: Record "NPR MM Recur. Paym. Setup";
    begin
        UpgradeStep := 'SetMaxRecurringPaymentProcessingTryCount';
        if HasUpgradeTag() then
            exit;

        RecurPaymSetup.Reset();
        RecurPaymSetup.SetRange("Max. Pay. Process Try Count", 0);
        if not RecurPaymSetup.IsEmpty then
            RecurPaymSetup.ModifyAll("Max. Pay. Process Try Count", 5);

        SetUpgradeTag();
    end;

    local procedure SetMaxSubscriptionRequestProcessingTryCount()
    var
        NPPaySetup: Record "NPR Adyen Setup";
    begin
        UpgradeStep := 'SetMaxSubscriptionRequestProcessingTryCount';
        if HasUpgradeTag() then
            exit;

        if NPPaySetup.Get() then
            if NPPaySetup."Max Sub Req Process Try Count" = 0 then begin
                NPPaySetup."Max Sub Req Process Try Count" := 2;
                NPPaySetup.Modify();
            end;

        SetUpgradeTag();
    end;

    local procedure UpdateSubscriptionAutoRenewStatus()
    var
        Subscription: Record "NPR MM Subscription";
        Membership: Record "NPR MM Membership";
    begin
        UpgradeStep := 'UpdateSubscriptionAutoRenewStatus';
        if HasUpgradeTag() then
            exit;

        Subscription.Reset();
        if Subscription.FindSet() then
            repeat
                Membership.SetLoadFields("Auto-Renew");
                if Membership.Get(Subscription."Membership Entry No.") then
                    if Subscription."Auto-Renew" <> Membership."Auto-Renew" then begin
                        Subscription."Auto-Renew" := Membership."Auto-Renew";
                        Subscription.Modify(true);
                    end;
            until Subscription.Next() = 0;

        SetUpgradeTag();
    end;

    local procedure UpdateSubscriptionRenewProcJobStartTime()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        UpgradeStep := 'UpdateSubscriptionRenewProcJobStartTime';
        if HasUpgradeTag() then
            exit;

        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR MM Subscr. Renew Proc. JQ");
        if JobQueueEntry.FindLast() then
            SetJobStartTime(JobQueueEntry, 230000T);

        SetUpgradeTag();
    end;

    local procedure UpdateSubscriptionRenewReqJobStartTime()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        UpgradeStep := 'UpdateSubscriptionRenewReqJobStartTime';
        if HasUpgradeTag() then
            exit;

        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR MM Subscr. Renew Req. JQ");
        if JobQueueEntry.FindLast() then
            SetJobStartTime(JobQueueEntry, 060000T);

        SetUpgradeTag();
    end;

    local procedure UpgradeTerminationSubsRequest()
    var
        Subscription: Record "NPR MM Subscription";
    begin
        UpgradeStep := 'UpgradeTerminationSubsRequest';
        if HasUpgradeTag() then
            exit;

        Subscription.Reset();
        Subscription.SetRange("Auto-Renew", Subscription."Auto-Renew"::TERMINATION_REQUESTED);
        If Subscription.FindSet() then
            repeat
                CreateSubscTerminationRequest(Subscription);
                ResetSubscriptionTerminationFields(Subscription);
                DisableSubscriptionAutoRenewal(Subscription);
            until Subscription.Next() = 0;

        SetUpgradeTag();
    end;

    local procedure SetJobStartTime(JobQueueEntry: Record "Job Queue Entry"; StartingTime: Time)
    var
        StartDateTime: DateTime;
        IsModified: Boolean;
    begin
        StartDateTime := CreateDateTime(Today, StartingTime);
        if CurrentDateTime > StartDateTime then
            StartDateTime := CreateDateTime(CalcDate('<+1D>', Today), StartingTime);

        if JobQueueEntry."Earliest Start Date/Time" <> StartDateTime then
            IsModified := true;

        if JobQueueEntry."Starting Time" <> StartingTime then
            IsModified := true;

        if IsModified then begin
            if JobQueueEntry.Status <> JobQueueEntry.Status::"On Hold" then
                JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
            if JobQueueEntry."Earliest Start Date/Time" <> StartDateTime then
                JobQueueEntry."Earliest Start Date/Time" := StartDateTime;
            if JobQueueEntry."Starting Time" <> StartingTime then
                JobQueueEntry."Starting Time" := StartingTime;
            JobQueueEntry.Modify();
            if not JobQueueEntry."NPR Manually Set On Hold" then
                JobQueueEntry.SetStatus(JobQueueEntry.Status::Ready);
        end;
    end;

    local procedure HasUpgradeTag(): Boolean
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Subscriptions", UpgradeStep)) then
            exit(true);
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Subscriptions', UpgradeStep);
    end;

    local procedure SetUpgradeTag()
    begin
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Subscriptions", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure CreateSubscTerminationRequest(Subscription: Record "NPR MM Subscription")
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        TerminationRequestLbl: Label 'Termination request';
    begin
        SubscriptionRequest.Init();
        SubscriptionRequest.Type := SubscriptionRequest.Type::Terminate;
        SubscriptionRequest.Status := SubscriptionRequest.Status::Confirmed;
        SubscriptionRequest."Processing Status" := SubscriptionRequest."Processing Status"::Success;
        SubscriptionRequest."Subscription Entry No." := Subscription."Entry No.";
        SubscriptionRequest.Description := TerminationRequestLbl;
        SubscriptionRequest."Membership Code" := Subscription."Membership Code";
        SubscriptionRequest."Terminate At" := Subscription."Terminate At";
        SubscriptionRequest."Termination Reason" := Subscription."Termination Reason";
        SubscriptionRequest."Termination Requested At" := Subscription."Termination Requested At";
        SubscriptionRequest.Insert(true);
    end;

    local procedure ResetSubscriptionTerminationFields(var Subscription: Record "NPR MM Subscription")
    begin
        Subscription."Terminate At" := 0D;
        Subscription."Termination Reason" := Subscription."Termination Reason"::NOT_TERMINATED;
        Subscription."Termination Requested At" := 0DT;
        Subscription.Modify(true);
    end;

    local procedure DisableSubscriptionAutoRenewal(Subscription: Record "NPR MM Subscription")
    var
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        Membership: Record "NPR MM Membership";
    begin
        if (Membership.Get(Subscription."Membership Entry No.")) then
            if Membership."Auto-Renew" <> Membership."Auto-Renew"::NO then
                MembershipMgtInternal.DisableMembershipAutoRenewal(Membership, true, false);
    end;
}