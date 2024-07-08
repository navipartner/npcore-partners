codeunit 6151058 "NPR Job Queue User Handler"
{
    Access = Internal;

    trigger OnRun()
    begin
        RefreshJobQueueEntries();
    end;

    local procedure RefreshJobQueueEntries()
    var
        JobQueueManagement: Codeunit "NPR Job Queue Management";
    begin
        JobQueueManagement.RefreshNPRJobQueueList();
    end;

#if BC17 or BC18 or BC19
    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnBeforeLogInStart', '', true, false)]
    local procedure HandleJobQueueEntriesOnBeforeLogInStart()
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterLogin', '', false, false)]
    local procedure HandleJobQueueEntriesOnAfterLogin();
#endif
    begin
        RefreshJobQueueEntriesOnAfterLogin();
    end;

    local procedure RefreshJobQueueEntriesOnAfterLogin()
    var
        JobQueueRefreshSetup: Record "NPR Job Queue Refresh Setup";
    begin
        if not GuiAllowed() then
            exit;

        if not (JobQueueRefreshSetup.WritePermission() and JobQueueRefreshSetup.ReadPermission()) then
            exit;

        if not IsRefreshJobQueueEntriesEnabled(JobQueueRefreshSetup) then
            exit;

        if not ShouldRefreshJobQueueEntries(JobQueueRefreshSetup) then
            exit;

        if not CanUserRefreshJobQueueEntries() then
            exit;

        if IsTaskAlreadyScheduled() then
            exit;

        UpdateLastRefreshed(JobQueueRefreshSetup);

        TaskScheduler.CreateTask(Codeunit::"NPR Job Queue User Handler", 0, true, CompanyName(), CurrentDateTime() + 2000); // Add 2s
    end;

    local procedure IsRefreshJobQueueEntriesEnabled(var JobQueueRefreshSetup: Record "NPR Job Queue Refresh Setup"): Boolean
    begin
        JobQueueRefreshSetup.GetSetup();
        exit(JobQueueRefreshSetup.Enabled);
    end;

    local procedure ShouldRefreshJobQueueEntries(JobQueueRefreshSetup: Record "NPR Job Queue Refresh Setup") ShouldRefresh: Boolean
    begin
        ShouldRefresh := true;
        if JobQueueRefreshSetup."Last Refreshed" <> 0DT then
            ShouldRefresh := DT2Date(JobQueueRefreshSetup."Last Refreshed") < Today(); // refresh should happen when the date is changed
    end;

    procedure CanUserRefreshJobQueueEntries(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        User: Record User;
#if not BC17
        EnvironmentInformation: Codeunit "Environment Information";
#endif
    begin
        if not (JobQueueEntry.WritePermission() and JobQueueEntry.ReadPermission()) then
            exit(false);

        if not TryCheckRequiredPermissions() then // native procedure TryCheckRequiredPermissions from "Job Queue Entry" table is marked as internal, so I had to create our version by copying it
            exit(false);

        if not TaskScheduler.CanCreateTask() then
            exit(false);

        if not User.Get(UserSecurityId()) then
            exit(false);

        if not (User."License Type" in [User."License Type"::"Full User", User."License Type"::"Device Only User"]) then
            exit(false);

#if not BC17
        if EnvironmentInformation.IsSaaS() then
            if not CanUserRefreshJobQueueEntriesWithUserPlan() then
                exit(false);
#endif

        exit(true);
    end;

#if not BC17
    local procedure CanUserRefreshJobQueueEntriesWithUserPlan(): Boolean
    var
        UsersInPlans: Query "Users in Plans";
        AllowedPlanIDs: List of [Guid];
    begin
        AllowedPlanIDs := GetAllowedPlanIDs();

        UsersInPlans.SetRange(User_Security_ID, UserSecurityId());
        UsersInPlans.Open();
        while UsersInPlans.Read() do
            if AllowedPlanIDs.Contains(UsersInPlans.Plan_ID) then
                exit(true);
        exit(false);
    end;

    local procedure GetAllowedPlanIDs() AllowedPlanIDs: List of [Guid]
    var
        PlanIds: Codeunit "Plan Ids";
    begin
        AddPlanIDToAllowedPlanIDList(PlanIds.GetEssentialPlanId(), AllowedPlanIDs);     //Dynamics 365 Business Central Essential
        AddPlanIDToAllowedPlanIDList(PlanIds.GetEssentialISVPlanId(), AllowedPlanIDs);  //Dynamics 365 Business Central Essential - Embedded
        AddPlanIDToAllowedPlanIDList(PlanIds.GetPremiumPlanId(), AllowedPlanIDs);       //Dynamics 365 Business Central Premium
        AddPlanIDToAllowedPlanIDList(PlanIds.GetPremiumISVPlanId(), AllowedPlanIDs);    //Dynamics 365 Business Central Premium - Embedded
        AddPlanIDToAllowedPlanIDList(PlanIds.GetDevicePlanId(), AllowedPlanIDs);        //Dynamics 365 Business Central Device
        AddPlanIDToAllowedPlanIDList(PlanIds.GetDeviceISVPlanId(), AllowedPlanIDs);     //Dynamics 365 Business Central Device - Embedded
    end;

    local procedure AddPlanIDToAllowedPlanIDList(PlanID: Guid; var AllowedPlanIDs: List of [Guid])
    begin
        if AllowedPlanIDs.Contains(PlanID) then
            exit;
        AllowedPlanIDs.Add(PlanID);
    end;
#endif

    [TryFunction]
    internal procedure TryCheckRequiredPermissions()
    begin
        CheckRequiredPermissions();
    end;

    internal procedure CheckRequiredPermissions()
    var
        DummyJobQueueLogEntry: Record "Job Queue Log Entry";
        DummyErrorMessageRegister: Record "Error Message Register";
        DummyErrorMessage: Record "Error Message";
        NoPermissionsErr: Label 'You are not allowed to schedule background tasks. Ask your system administrator to give you permission to do so. Specifically, you need Insert, Modify and Delete Permissions for the %1 table.', Comment = '%1 Table Name';
    begin
        if not DummyJobQueueLogEntry.WritePermission() then
            Error(NoPermissionsErr, DummyJobQueueLogEntry.TableName());

        if not DummyErrorMessageRegister.WritePermission() then
            Error(NoPermissionsErr, DummyErrorMessageRegister.TableName());

        if not DummyErrorMessage.WritePermission() then
            Error(NoPermissionsErr, DummyErrorMessage.TableName());
    end;

    local procedure IsTaskAlreadyScheduled(): Boolean
    var
        ScheduledTask: Record "Scheduled Task";
    begin
        ScheduledTask.SetRange("Run Codeunit", Codeunit::"NPR Job Queue User Handler");
        ScheduledTask.SetRange(Company, CompanyName());
        ScheduledTask.SetRange("User ID", UserSecurityId());
        ScheduledTask.SetRange("Is Ready", true);
        if not ScheduledTask.IsEmpty() then
            exit(true);

        ScheduledTask.SetRange("User ID");
        if not ScheduledTask.IsEmpty() then
            exit(true);

        exit(false);
    end;

    local procedure UpdateLastRefreshed(var JobQueueRefreshSetup: Record "NPR Job Queue Refresh Setup")
    begin
        JobQueueRefreshSetup."Last Refreshed" := CurrentDateTime();
        JobQueueRefreshSetup.Modify();
    end;
}