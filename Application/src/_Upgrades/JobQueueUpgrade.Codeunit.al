codeunit 6014489 "NPR Job Queue Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        JobQueueInstall: Codeunit "NPR Job Queue Install";
    begin
        JobQueueInstall.AddJobQueues();
    end;
}