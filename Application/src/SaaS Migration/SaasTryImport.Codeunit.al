codeunit 6150928 "NPR SaaS Try Import"
{
    TableNo = "NPR SaaS Import Chunk";
    Access = Internal;

    trigger OnRun()
    var
        SaaSImportBgnSession: Record "NPR SaaS Import Bgn. Session";
        SaaSImportTask: Record "NPR SaaS Import Task";
        Success: Boolean;
        ErrorText: Text;
        ImportCSVParser: Codeunit "NPR SaaS Import CSV Parser";
    begin
        ClearLastError();
        Success := ImportCSVParser.Run(Rec);

        LockTimeout(false);
        if Success then begin
            Rec.SetRange(ID, Rec.ID);
            Rec.DeleteAll();
        end else begin
            Rec.LockTable();
            Rec.Get(Rec.Id);
            ErrorText := GetLastErrorText();
            if ErrorText.Trim() = '' then
                ErrorText := 'An unknown error occurred (Possibly field mismatch or permissions on azure application?)';
            Rec."Error Reason" := CopyStr(ErrorText, 1, MaxStrLen(Rec."Error Reason"));
            Rec.Error := true;
            Rec.Modify();
        end;

        if CurrentClientType <> ClientType::Background then
            exit;

        SaaSImportBgnSession.SetRange(ChunkId, Rec.ID);
        SaaSImportBgnSession.DeleteAll();

        SaaSImportTask.SetRange(ChunkId, Rec.ID);
        SaaSImportTask.DeleteAll();

        Commit();
    end;
}