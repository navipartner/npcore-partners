codeunit 6151317 "NPR Reten. Policy User Handler"
{
    Access = Internal;

    trigger OnRun()
    begin
        UpdateRetentionPolicies();
    end;

    local procedure UpdateRetentionPolicies()
    var
        RetenPolicySetupBuffer: Record "NPR Reten. Policy Setup Buffer";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetenPolInstall: Codeunit "NPR Reten. Pol. Install";
    begin
        if RetenPolicySetupBuffer.IsEmpty() then
            exit;

        RetenPolicySetupBuffer.FindSet();

        repeat
            if RetentionPolicySetup.Get(RetenPolicySetupBuffer."Table Id") then
                RetentionPolicySetup.Delete(true);

            RetenPolInstall.InsertRetentionPolicySetup(RetenPolicySetupBuffer."Table Id", RetenPolicySetupBuffer."Retention Period", RetenPolicySetupBuffer.Enabled, RetenPolicySetupBuffer."Apply to All Records");
        until RetenPolicySetupBuffer.Next() = 0;

        RetenPolicySetupBuffer.DeleteAll();
    end;

#if BC17 or BC18 or BC19
    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnBeforeLogInStart', '', true, false)]
    local procedure HandleRetentionPoliciesOnBeforeLogInStart()
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterLogin', '', false, false)]
    local procedure HandleRetentionPoliciesOnAfterLogin();
#endif
    begin
        UpdateRetentionPoliciesOnAfterLogin();
    end;

    local procedure UpdateRetentionPoliciesOnAfterLogin()
    begin
        if not CanUserUpdateRetentionPolicies() then
            exit;

        if IsTaskAlreadyScheduled() then
            exit;

        TaskScheduler.CreateTask(Codeunit::"NPR Reten. Policy User Handler", 0, true, CompanyName(), CurrentDateTime() + 1000); // Add 1s
    end;

    local procedure CanUserUpdateRetentionPolicies(): Boolean
    var
        RetenPolicySetupBuffer: Record "NPR Reten. Policy Setup Buffer";
        RetentionPolicySetup: Record "Retention Policy Setup";
        User: Record User;
    begin
        if not GuiAllowed then
            exit(false);

        if not (RetenPolicySetupBuffer.WritePermission() and RetenPolicySetupBuffer.ReadPermission()) then
            exit(false);

        if not RetentionPolicySetup.WritePermission() then
            exit(false);

        if not TaskScheduler.CanCreateTask() then
            exit(false);

        if not User.Get(UserSecurityId()) then
            exit(false);

        if User."License Type" = User."License Type"::"Limited User" then
            exit(false);

        exit(true);
    end;

    local procedure IsTaskAlreadyScheduled(): Boolean
    var
        ScheduledTask: Record "Scheduled Task";
    begin
        ScheduledTask.SetRange("Run Codeunit", Codeunit::"NPR Reten. Policy User Handler");
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
}