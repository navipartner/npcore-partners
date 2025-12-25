#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248675 "NPR Retention Policy JQ"
{
    Access = Internal;

    var
        StartApplicationRetentionPolicyFromJobQueueLbl: Label 'The job queue entry applying NPR retention policies has started.';
        EndApplicationRetentionPolicyFromJobQueueLbl: Label 'The job queue entry applying NPR retention policies has finished.';

    trigger OnRun()
    var
        RetentionPolicy: Record "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
    begin
        RetentionPolicyMgmt.LogInfo(StartApplicationRetentionPolicyFromJobQueueLbl);
        RetentionPolicy.DiscoverRetentionPolicyTables();
        Commit();

        RetentionPolicyMgmt.ApplyAllRetentionPolicies();
        RetentionPolicyMgmt.LogInfo(EndApplicationRetentionPolicyFromJobQueueLbl);
    end;
}
#endif