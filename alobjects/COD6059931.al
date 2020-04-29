codeunit 6059931 "Doc. Exch. File Task Queue"
{
    // NPR5.30/BR  /20170213  CASE 265778 Added support for files (disappeared in last release)

    TableNo = "Task Line";

    trigger OnRun()
    var
        InboxPath: Text;
        InboxPathServer: Text;
        IsLocalInbox: Boolean;
        ArchivePath: Text;
        IsLocalArchive: Boolean;
        CreateDocument: Boolean;
        DocExchFileMgt: Codeunit "Doc. Exch. File Mgt.";
    begin
        TaskLine := Rec;
        SetParameterCodes();

        InboxPath := GetParameterText(Inbox);
        if InboxPath <> '' then begin
          IsLocalInbox := GetParameterBool(LocalInbox);
          ArchivePath := GetParameterText(Archive);
          IsLocalArchive := GetParameterBool(LocalArchive);
          CreateDocument := GetParameterBool(CreateCode);

          DocExchFileMgt.ImportDirectory(InboxPath,ArchivePath,IsLocalInbox,IsLocalArchive,CreateDocument);
          //TaskLine.AddMessageLine2OutputLog(STRSUBSTNO(FileImported,FileMgt.GetFileName(FilePath)));
        end else begin
          //-NPR5.30 [265778]
          DocExchFileMgt.ImportUsingSetup;
          //+NPR5.30 [265778]
          DocExchFileMgt.ImportFTPUsingSetup;
        end;
    end;

    var
        InboxError: Label 'Inbox folder path needs to be set as an %1 parameter.';
        ArchiveError: Label 'Archive folder path needs to be set as an %1 parameter.';
        FolderError: Label 'Invalid %1 folder path.';
        TaskLine: Record "Task Line";
        Inbox: Text;
        Archive: Text;
        CreateCode: Text;
        LocalInbox: Text;
        LocalArchive: Text;
        FileImported: Label 'File %1 has been successfully imported.';
        FolderStructureDelimiter: Text;

    local procedure SetParameterCodes()
    begin
        Inbox := 'INBOX';
        Archive := 'ARCHIVE';
        LocalInbox := 'LOCALINBOX';
        LocalArchive := 'LOCALARCHIVE';
        CreateCode := 'CREATE';
    end;

    [EventSubscriber(ObjectType::Table, 6059902, 'OnAfterValidateEvent', 'Object No.', false, false)]
    local procedure Initialize(var Rec: Record "Task Line";var xRec: Record "Task Line";CurrFieldNo: Integer)
    var
        TaskLineParam: Record "Task Line Parameters";
        TaskWorkerGroup: Record "Task Worker Group";
        Text001: Label 'No Parameters found. Do you with to have empty Parameters added?';
    begin
        SetParameterCodes();

        with Rec do begin
          if (xRec."Object No." = 6059908) and ("Object No." <> 6059908) then begin
            TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
            TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
            TaskLineParam.SetRange("Journal Line No.", "Line No.");
            TaskLineParam.DeleteAll;
            "Call Object With Task Record" := false;
          end;

          if "Object No." <> 6059908 then
            exit;

          if GuiAllowed then
            if not Confirm(Text001) then
              exit;

          TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
          TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
          TaskLineParam.SetRange("Journal Line No.", "Line No.");
          TaskLineParam.DeleteAll;

          InsertParameter(Inbox,0);
          InsertParameter(Archive,0);
          InsertParameter(LocalInbox,0);
          InsertParameter(LocalArchive,0);
          InsertParameter(CreateCode,0);

          "Call Object With Task Record" := true;
        end;
    end;
}

