﻿codeunit 6151506 "NPR Nc IL Update Default" implements "NPR Nc Import List IUpdate"
{
    Access = Internal;

#IF BC17    
    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.')]
    procedure Update(TaskLine: Record "NPR Task Line"; ImportType: Record "NPR Nc Import Type")
    var
    begin
    end;
#ENDIF

    procedure Update(JobQueueEntry: Record "Job Queue Entry"; ImportType: Record "NPR Nc Import Type")
    var
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        NcImpListProcessing: Codeunit "NPR Nc Import List Processing";
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
    begin
        JQParamStrMgt.Parse(JobQueueEntry."Parameter String");
        if JQParamStrMgt.ContainsParam(NcImpListProcessing.ParamDownloadFtp()) then begin
            NcSyncMgt.DownloadFtpType(ImportType);
            Commit();
        end;
    end;

    procedure ShowSetup(ImportType: Record "NPR Nc Import Type")
    begin
        ImportType.SetRange(Code, ImportType.code);
        Page.Run(Page::"NPR Nc Import Type Card", ImportType);
    end;

    procedure ShowErrorLog(ImportType: Record "NPR Nc Import Type")
    begin

    end;
}
