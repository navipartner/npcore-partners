codeunit 6014452 "E-mail Template Mgt."
{
    // NPR5.48/MHA /20190123  CASE 341711 Object created - Contains functionality around E-mail Templates


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Export failed';
        Text001: Label 'All values on %1 will be replaced with values from %2';
        Text002: Label 'Do you want to delete the HTML Template?';
        Text003: Label 'No End-Tag (%1) found for Start-Tag (%2) in %3';

    local procedure "--- Email Content"()
    begin
    end;

    procedure MergeMailContent(var RecRef: RecordRef;Line: Text;StartTag: Text[10];EndTag: Text[10]) NewLine: Text
    var
        EndPos: Integer;
        EndLength: Integer;
        FieldNo: Integer;
        StartPos: Integer;
        StartLength: Integer;
        FieldValue: Text;
    begin
        if StartTag = '' then
          StartTag := '{';
        if EndTag = '' then
          EndTag := '}';
        StartLength := StrLen(StartTag);
        EndLength := StrLen(EndTag);

        NewLine := Line;
        while (StrPos(NewLine,StartTag) > 0) do begin
          StartPos := StrPos(NewLine,StartTag);
          EndPos := StrPos(NewLine,EndTag);
          if EndPos = 0 then
            Error(StrSubstNo(Text003,EndTag,StartTag,Line));
          Evaluate(FieldNo,CopyStr(NewLine,StartPos + StartLength,EndPos - StartPos - StartLength));

          NewLine := DelStr(NewLine,StartPos,EndPos - StartPos + EndLength);
          FieldValue := GetFieldValue(RecRef,FieldNo);
          NewLine := InsStr(NewLine,FieldValue,StartPos);
        end;

        exit(NewLine);
    end;

    local procedure GetFieldValue(var RecRef: RecordRef;FieldNo: Integer) FieldValue: Text
    var
        "Field": Record "Field";
        FRef: FieldRef;
    begin
        Field.Get(RecRef.Number,FieldNo);
        FRef := RecRef.Field(FieldNo);

        if Field.Class = Field.Class::FlowField then
          FRef.CalcField;

        FieldValue := Format(FRef.Value);
    end;

    local procedure "--- Page Actions"()
    begin
    end;

    procedure CopyFromTemplate(var EmailTemplateHeaderTo: Record "E-mail Template Header")
    var
        EmailTemplateHeaderFrom: Record "E-mail Template Header";
        EmailTemplateLineFrom: Record "E-mail Template Line";
        EmailTemplateLineTo: Record "E-mail Template Line";
        EmailTemplateFilterFrom: Record "E-mail Template Filter";
        EmailTemplateFilterTo: Record "E-mail Template Filter";
    begin
        if ACTION::LookupOK <> PAGE.RunModal(0,EmailTemplateHeaderFrom) then
          exit;

        if not Confirm(Text001,true,EmailTemplateHeaderTo.Code,EmailTemplateHeaderFrom.Code) then
          exit;

        EmailTemplateHeaderFrom.CalcFields("HTML Template");
        EmailTemplateHeaderTo.TransferFields(EmailTemplateHeaderFrom,false);
        EmailTemplateHeaderTo.Modify(true);

        EmailTemplateLineTo.SetRange("E-mail Template Code",EmailTemplateHeaderTo.Code);
        if EmailTemplateLineTo.FindFirst then
          EmailTemplateLineTo.DeleteAll;

        EmailTemplateLineFrom.SetRange("E-mail Template Code",EmailTemplateHeaderFrom.Code);
        if EmailTemplateLineFrom.FindSet then
          repeat
            EmailTemplateLineTo.Init;
            EmailTemplateLineTo.TransferFields(EmailTemplateLineFrom,true);
            EmailTemplateLineTo."E-mail Template Code" := EmailTemplateHeaderTo.Code;
            EmailTemplateLineTo.Insert(true);
          until EmailTemplateLineFrom.Next = 0;

        EmailTemplateFilterTo.SetRange("E-mail Template Code",EmailTemplateHeaderTo.Code);
        if EmailTemplateFilterTo.FindFirst then
          EmailTemplateFilterTo.DeleteAll;

        EmailTemplateFilterFrom.SetRange("E-mail Template Code",EmailTemplateHeaderFrom.Code);
        if EmailTemplateFilterFrom.FindSet then
          repeat
            EmailTemplateLineTo.Init;
            EmailTemplateFilterTo.TransferFields(EmailTemplateFilterFrom,true);
            EmailTemplateFilterTo."E-mail Template Code" := EmailTemplateHeaderTo.Code;
            EmailTemplateFilterTo.Insert(true);
          until EmailTemplateFilterFrom.Next = 0;
    end;

    procedure DeleteHtmlTemplate(var EmailTemplateHeader: Record "E-mail Template Header")
    begin
        if not EmailTemplateHeader."HTML Template".HasValue then
          exit;

        if not Confirm(Text002,false) then
          exit;

        Clear(EmailTemplateHeader."HTML Template");
        EmailTemplateHeader.Modify(true);
    end;

    procedure EditHtmlTemplate(var EmailTemplateHeader: Record "E-mail Template Header")
    var
        FileManagement: Codeunit "File Management";
        Path: Text[1024];
    begin
        Path := ExportHtmlTemplate(EmailTemplateHeader,false);
        RunProcess('notepad.exe',Path,true);
        ImportHtmlTemplate(Path,false,EmailTemplateHeader);

        FileManagement.DeleteClientFile(Path);
    end;

    procedure ExportHtmlTemplate(var EmailTemplateHeader: Record "E-mail Template Header";UseDialog: Boolean) Path: Text[1024]
    var
        FileManagement: Codeunit "File Management";
        InStr: InStream;
        ToFile: Text;
    begin
        EmailTemplateHeader.CalcFields("HTML Template");
        EmailTemplateHeader."HTML Template".CreateInStream(InStr);

        if UseDialog then
          ToFile := 'template.html'
        else
          ToFile :=  FileManagement.ClientTempFileName('html');

        if DownloadFromStream(InStr,'Export','','',ToFile) then
          exit(ToFile);

        Error(Text000);
    end;

    procedure ImportHtmlTemplate(Path: Text[1024];UseDialog: Boolean;var EmailTemplateHeader: Record "E-mail Template Header")
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Record TempBlob temporary;
        OutStr: OutStream;
        InStr: InStream;
    begin
        if UseDialog then
          FileManagement.BLOBImport(TempBlob,'*.html')
        else
          FileManagement.BLOBImport(TempBlob,Path);

        TempBlob.Blob.CreateInStream(InStr);
        EmailTemplateHeader."HTML Template".CreateOutStream(OutStr,TEXTENCODING::UTF8);
        CopyStream(OutStr,InStr);
        EmailTemplateHeader.Modify(true);
    end;

    procedure ViewHtmlTemplate(var EmailTemplateHeader: Record "E-mail Template Header")
    var
        Path: Text[1024];
    begin
        Path := ExportHtmlTemplate(EmailTemplateHeader,false);
        HyperLink(Path);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure RunProcess(Filename: Text;Arguments: Text;Modal: Boolean)
    var
        [RunOnClient]
        Process: DotNet Process;
        [RunOnClient]
        ProcessStartInfo: DotNet ProcessStartInfo;
    begin
        ProcessStartInfo := ProcessStartInfo.ProcessStartInfo(Filename,Arguments);
        Process := Process.Start(ProcessStartInfo);
        if Modal then
          Process.WaitForExit();
    end;
}

