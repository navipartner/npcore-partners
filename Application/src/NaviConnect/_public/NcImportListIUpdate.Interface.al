interface "NPR Nc Import List IUpdate"
{
#IF BC17
    procedure Update(TaskLine: Record "NPR Task Line"; ImportType: Record "NPR Nc Import Type");
#ENDIF
    procedure Update(JobQueueEntry: Record "Job Queue Entry"; ImportType: Record "NPR Nc Import Type");

    procedure ShowSetup(ImportType: Record "NPR Nc Import Type");

    procedure ShowErrorLog(ImportType: Record "NPR Nc Import Type");
}
