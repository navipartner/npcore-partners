codeunit 6150926 "NPR SaaS Import Service"
{
    procedure Import(Csv: Text)
    var
        SaaSImportBgnSession: Record "NPR SaaS Import Bgn. Session";
        SaaSImportTask: Record "NPR SaaS Import Task";
        ActiveBgnSessions: Integer;
        ActiveTasks: Integer;
        SaaSImportSetup: Record "NPR SaaS Import Setup";
        SaaSImportChunk: Record "NPR SaaS Import Chunk";
        OStream: OutStream;
        SessionId: Integer;
        TaskId: Guid;
        SaaSTryImport: Codeunit "NPR SaaS Try Import";
    begin
        LockTimeout(false);
        SaaSImportSetup.Get();

        SaaSImportChunk.Init();
        SaaSImportChunk.Chunk.CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(Csv);
        SaaSImportChunk.Insert();
        Commit(); // if data import fails, this record is left in table, hopefully with error message

        if SaaSImportSetup."Synchronous Processing" then begin
            SaaSTryImport.Run(SaaSImportChunk);
            exit;
        end;

        SaaSImportBgnSession.LockTable();
        SaaSImportBgnSession.SetRange(ServiceInstance, ServiceInstanceId());
        ActiveBgnSessions := SaaSImportBgnSession.Count();
        if ActiveBgnSessions < SaaSImportSetup."Max Background Sessions" then begin //Import chunk via background session            
            SaaSImportBgnSession.Init();
            SaaSImportBgnSession.ChunkId := SaaSImportChunk.ID;
            SaaSImportBgnSession.ServiceInstance := ServiceInstanceId();
            SaaSImportBgnSession.Insert();
            Commit();
            StartSession(SessionId, Codeunit::"NPR SaaS Try Import", CompanyName(), SaaSImportChunk);
            exit;
        end;

        if SaaSImportSetup."Max Task Scheduler Tasks" > 0 then begin
            SaaSImportTask.LockTable();
            ActiveTasks := SaaSImportTask.Count();
            if ActiveTasks < SaaSImportSetup."Max Task Scheduler Tasks" then begin //Import chunk via task scheduler
                SaaSImportTask.Init();
                SaaSImportTask.ChunkId := SaaSImportChunk.ID;
                SaaSImportTask.Insert();
                Commit();
                TaskId := TaskScheduler.CreateTask(Codeunit::"NPR SaaS Try Import", 0, true, CompanyName(), CurrentDateTime(), SaaSImportChunk.RecordId);
                exit;
            end;
        end;

        Commit(); // release locks held by counts() above

        //Import chunk on this odata/soap session
        SaaSTryImport.Run(SaaSImportChunk);
    end;

    procedure PrepareImport()
    var
        SaaSImportBgnSession: Record "NPR SaaS Import Bgn. Session";
        SaaSImportTask: Record "NPR SaaS Import Task";
        SaaSImportChunk: Record "NPR SaaS Import Chunk";
        SaaSImportSetup: Record "NPR SaaS Import Setup";
        ActiveSession: Record "Active Session";
    begin
        SaaSImportSetup.Get();
        SaaSImportSetup.TestField("Disable Database Triggers", true);

        SaaSImportBgnSession.DeleteAll();
        SaaSImportTask.DeleteAll();
        SaaSImportChunk.DeleteAll();

        ActiveSession.SetFilter("Session ID", '<>%1', SessionId());
        if ActiveSession.FindSet() then
            repeat
                StopSession(ActiveSession."Session ID");
            until ActiveSession.Next() = 0;
    end;

    procedure GetImportStatus(): Text
    var
        SaaSImportChunk: Record "NPR SaaS Import Chunk";
        Response: JsonObject;
        ResponseText: Text;
    begin
        SelectLatestVersion();

        Response.Add('ChunksRemaining', SaaSImportChunk.Count());
        SaaSImportChunk.SetRange(Error, true);
        Response.Add('ErrorsFound', not SaaSImportChunk.IsEmpty());

        Response.WriteTo(ResponseText);
        exit(ResponseText);
    end;
}