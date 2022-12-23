interface "NPR Nc Import List IUpdate"
{
#IF NOT BC17
    [Obsolete('Task Queue module to be removed from NP Retail. We are now using Job Queue instead.')]
#ENDIF
    procedure Update(TaskLine: Record "NPR Task Line"; ImportType: Record "NPR Nc Import Type");

    procedure Update(JobQueueEntry: Record "Job Queue Entry"; ImportType: Record "NPR Nc Import Type");

    procedure ShowSetup(ImportType: Record "NPR Nc Import Type");

    procedure ShowErrorLog(ImportType: Record "NPR Nc Import Type");
}
