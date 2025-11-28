#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248666 "NPR Billing Data Check"
{
    Access = Internal;

    trigger OnRun()
    var
        BillingDataSenderJQ: Codeunit "NPR Billing Data Sender JQ";
    begin
        BillingDataSenderJQ.CheckNonRunningTaskViaJQAndProcess(true, 2);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", OnAfterLogin, '', false, false)]
    local procedure CheckNonRunningTaskOnAfterLogin()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if not GuiAllowed then exit;
        if not EnvironmentInformation.IsProduction() then exit;
        if not TaskScheduler.CanCreateTask() then exit;

        if not IsTaskAlreadyScheduled() then
            TaskScheduler.CreateTask(Codeunit::"NPR Billing Data Check", 0, true, CompanyName(), CurrentDateTime + 2000);
    end;

    local procedure IsTaskAlreadyScheduled(): Boolean
    var
        ScheduledTask: Record "Scheduled Task";
    begin
        ScheduledTask.SetRange("Run Codeunit", Codeunit::"NPR Billing Data Check");
        ScheduledTask.SetRange(Company, CompanyName());
        ScheduledTask.SetRange("Is Ready", true);
        exit(not ScheduledTask.IsEmpty());
    end;
}
#endif