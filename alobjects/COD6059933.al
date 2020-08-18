codeunit 6059933 "Doc. Exch. File Job Queue"
{
    // NPR5.55/TJ  /20200422 CASE 395504 New object

    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        InboxPath: Text;
        IsLocalInbox: Boolean;
        ArchivePath: Text;
        IsLocalArchive: Boolean;
        CreateDocument: Boolean;
        DocExchFileMgt: Codeunit "Doc. Exch. File Mgt.";
    begin
        InboxPath := GetParameterValue(Rec,InboxPathParameter());
        if InboxPath <> '' then begin
          IsLocalInbox := HasParameter(Rec,LocalInboxParameter());
          ArchivePath := GetParameterValue(Rec,ArchivePathParameter());
          IsLocalArchive := HasParameter(Rec,LocalArchiveParameter());
          CreateDocument := HasParameter(Rec,CreateDocumentParameter());
          DocExchFileMgt.ImportDirectory(InboxPath,ArchivePath,IsLocalInbox,IsLocalArchive,CreateDocument);
        end else begin
          DocExchFileMgt.ImportUsingSetup;
          DocExchFileMgt.ImportFTPUsingSetup;
        end;
    end;

    var
        InboxPathText: Label 'Inbox Path';
        ArchivePathText: Label 'Archive Path';
        LocalInboxText: Label 'Local Inbox';
        LocalArchiveText: Label 'Local Archive';
        CreateDocumentText: Label 'Create Document';

    local procedure GetParameterValue(JobQueueEntry: Record "Job Queue Entry";ParameterName: Text) ParameterValue: Text
    var
        Position: Integer;
    begin
        if ParameterName = '' then
          exit('');

        ParameterValue := JobQueueEntry."Parameter String";
        Position := StrPos(LowerCase(ParameterValue),LowerCase(ParameterName));
        if Position = 0 then
          exit('');

        if Position > 1 then
          ParameterValue := DelStr(ParameterValue,1,Position - 1);

        ParameterValue := DelStr(ParameterValue,1,StrLen(ParameterName));
        if ParameterValue = '' then
          exit('');
        if ParameterValue[1] = '=' then
          ParameterValue := DelStr(ParameterValue,1,1);

        Position := FindDelimiterPosition(ParameterValue);
        if Position > 0 then
          ParameterValue := DelStr(ParameterValue,Position);

        exit(ParameterValue);
    end;

    local procedure HasParameter(JobQueueEntry: Record "Job Queue Entry";ParameterName: Text): Boolean
    var
        Position: Integer;
    begin
        Position := StrPos(LowerCase(JobQueueEntry."Parameter String"),LowerCase(ParameterName));
        exit(Position > 0);
    end;

    local procedure FindDelimiterPosition(ParameterString: Text) Position: Integer
    var
        NewPosition: Integer;
    begin
        if ParameterString = '' then
          exit(0);

        Position := StrPos(ParameterString,',');

        NewPosition := StrPos(ParameterString,';');
        if (NewPosition > 0) and ((Position = 0) or (NewPosition < Position)) then
          Position := NewPosition;

        NewPosition := StrPos(ParameterString,'|');
        if (NewPosition > 0) and ((Position = 0) or (NewPosition < Position)) then
          Position := NewPosition;

        exit(Position);
    end;

    [EventSubscriber(ObjectType::Table, 472, 'OnAfterValidateEvent', 'Object ID to Run', true, true)]
    local procedure OnValidateJobQueueEntryObjectIDtoRun(var Rec: Record "Job Queue Entry";var xRec: Record "Job Queue Entry";CurrFieldNo: Integer)
    var
        ParameterString: Text;
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
          exit;
        if Rec."Object ID to Run" <> CurrCodeunitId() then
          exit;

        ParameterString := InboxPathParameter() + '=';
        ParameterString += ',' + LocalInboxParameter();
        ParameterString += ',' + ArchivePathParameter() + '=';
        ParameterString += ',' + LocalArchiveParameter();
        ParameterString += ',' + CreateDocumentParameter();

        Rec.Validate("Parameter String",CopyStr(ParameterString,1,MaxStrLen(Rec."Parameter String")));
    end;

    [EventSubscriber(ObjectType::Table, 472, 'OnAfterValidateEvent', 'Parameter String', true, true)]
    local procedure OnValidateJobQueueEntryParameterString(var Rec: Record "Job Queue Entry";var xRec: Record "Job Queue Entry";CurrFieldNo: Integer)
    var
        NcTaskProcessor: Record "Nc Task Processor";
        ParameterString: Text;
        Description: Text;
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
          exit;
        if Rec."Object ID to Run" <> CurrCodeunitId() then
          exit;

        if HasParameter(Rec,InboxPathParameter()) then
          Description := InboxPathText;
        if HasParameter(Rec,LocalInboxParameter()) then
          Description += ' | ' + LocalInboxText;
        if HasParameter(Rec,ArchivePathParameter()) then
          Description += ' | ' + ArchivePathText;
        if HasParameter(Rec,LocalArchiveParameter()) then
          Description += ' | ' + LocalArchiveText;
        if HasParameter(Rec,CreateDocumentParameter()) then
          Description += ' | ' + CreateDocumentText;

        Rec.Description := CopyStr(Description,1,MaxStrLen(Rec.Description));
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"Doc. Exch. File Job Queue");
    end;

    local procedure InboxPathParameter(): Text
    begin
        exit('inbox_path');
    end;

    local procedure ArchivePathParameter(): Text
    begin
        exit('archive_path');
    end;

    local procedure LocalInboxParameter(): Text
    begin
        exit('local_inbox');
    end;

    local procedure LocalArchiveParameter(): Text
    begin
        exit('local_archive');
    end;

    local procedure CreateDocumentParameter(): Text
    begin
        exit('create_doc');
    end;
}

