codeunit 6150926 "NPR SaaS Import Service"
{
    Permissions = tabledata "Change Log Entry" = rimd,
                tabledata "Tenant Media" = rimd,
                tabledata "Tenant Media Thumbnails" = rimd;
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

        if not SaaSImportSetup."Disable StopSession" then begin
            ActiveSession.SetFilter("Session ID", '<>%1', SessionId());
            if ActiveSession.FindSet() then
                repeat
                    StopSession(ActiveSession."Session ID");
                until ActiveSession.Next() = 0;
        end;
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


    procedure GetTableInformation(TableId: Integer) Response: Text
    var
        Field: Record Field;
        TableMetaData: Record "Table Metadata";
        JAFields: JsonArray;
        JOResponse, JOField : JsonObject;
    begin
        Field.SetRange(TableNo, TableId);
        Field.SetRange(Class, Field.Class::Normal);
        Field.FindSet();
        JOResponse.Add('tableId', Field.TableNo);
        JOResponse.Add('tableName', Field.TableName);
        if TableMetaData.Get(TableId) then begin
            JOResponse.Add('tableObsoleteState', Field.ObsoleteState);
            JOResponse.Add('tableObsoleteReason', Field.ObsoleteReason);
        end;
        repeat
            JOField.Add('fieldID', Field."No.");
            JOField.Add('fieldName', Field.FieldName);
            JOField.Add('fieldType', Field."Type");
            JOField.Add('fieldLen', Field."Len");
            JOField.Add('fieldObsoleteState', Field.ObsoleteState);
            JOField.Add('fieldObsoleteReason', Field.ObsoleteReason);
            JAFields.Add(JOField);
            Clear(JOField);
        until Field.Next() = 0;
        JOResponse.Add('tableFields', JAFields);
        JOResponse.WriteTo(Response);
    end;

    procedure GetRecordCount(ListOfTables: Text) Response: Text
    var
        Recref: RecordRef;
        TableList: List of [Text];
        TableTxt: Text;
        JAResponse: JsonArray;
        JOTable: JsonObject;
        JOResponse: JsonObject;
        TableID: Integer;
        AllObj: Record AllObj;
        EmptyFilterErrorLbl: Label 'Filter ListOfTables cannot be empty.';
        TableDoesNotExistErrorLbl: Label 'Table %1 does not exist in target/destination database. RecordCount not possible.', Comment = '%1 = Table ID';
    begin
        TableList := ListOfTables.Split(';');
        if TableList.Count() = 0 then
            Error(EmptyFilterErrorLbl);

        foreach TableTxt in TableList do begin
            Evaluate(TableID, TableTxt);
            if AllObj.Get(AllObj."Object Type"::Table, TableID) then begin
                Recref.Open(TableID);
                JOTable.Add('tableId', TableID);
                JoTable.Add('count', Recref.Count());
                JAResponse.Add(JOTable);
            end else
                Error(TableDoesNotExistErrorLbl, TableID);

            Clear(JOTable);
            Clear(Recref);
        end;
        JOResponse.Add('tableList', JAResponse);
        JOResponse.WriteTo(Response);
    end;

    procedure DisableEventSubscribers(): Boolean
    var
        SaaSImportSetup: Record "NPR SaaS Import Setup";
    begin
        if not SaaSImportSetup.Get() then
            exit(false);
        exit(SaaSImportSetup."Disable Event Subscribers");
    end;
}