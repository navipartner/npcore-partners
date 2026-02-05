codeunit 6014452 "NPR E-mail Templ. Mgt."
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;

    var
        Text000: Label 'Export failed';
        Text001: Label 'All values on %1 will be replaced with values from %2';
        Text002: Label 'Do you want to delete the HTML Template?';
        Text003: Label 'No End-Tag (%1) found for Start-Tag (%2) in %3';

        Text004Lbl: Label 'Warning: The Recipient E-mail might be overwritten by the template or chosen record. Do you want to send the test e-mail ?';

    #region Email Content

    procedure MergeMailContent(var RecRef: RecordRef; Line: Text; StartTag: Text[10]; EndTag: Text[10]) NewLine: Text
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
        while (StrPos(NewLine, StartTag) > 0) do begin
            StartPos := StrPos(NewLine, StartTag);
            EndPos := StrPos(NewLine, EndTag);
            if EndPos = 0 then
                Error(Text003, EndTag, StartTag, Line);
            Evaluate(FieldNo, CopyStr(NewLine, StartPos + StartLength, EndPos - StartPos - StartLength));

            NewLine := DelStr(NewLine, StartPos, EndPos - StartPos + EndLength);
            FieldValue := GetFieldValue(RecRef, FieldNo);
            NewLine := InsStr(NewLine, FieldValue, StartPos);
        end;

        exit(NewLine);
    end;

    procedure SendTestEmail(var Template: Record "NPR E-mail Template Header")
    var
        EmailSendMessage: Page "NPR Email Send Message";
        RecRefTemplate: RecordRef;
        SenderEmailDialog: Text;
        RecRefDialog: RecordRef;
        MessageDialog: Text;
        ReceiverDialog: Text;
        RecipientEmail: Text[250];
        EmailManagement: Codeunit "NPR E-mail Management";
    begin
        EmailSendMessage.SetRecord(Template);
        if Template."Transactional E-mail" = Template."Transactional E-mail"::" " then
            EmailSendMessage.SetData(Template."From E-mail Address", RecRefTemplate, Template."Use HTML Template", false)
        else
            EmailSendMessage.SetData(Template."From E-mail Address", RecRefTemplate, Template."Use HTML Template", true);
        if EmailSendMessage.RunModal() <> Action::OK then
            exit;

        if Template."Transactional E-mail" <> Template."Transactional E-mail"::" " then
            if not (Confirm(Text004Lbl, true)) then
                exit;


        EmailSendMessage.GetData(SenderEmailDialog, RecRefDialog, ReceiverDialog, MessageDialog);
        RecipientEmail := CopyStr(ReceiverDialog, 1, MaxStrLen(RecipientEmail));
        if Template."Report ID" > 0 then
            EmailManagement.SendReportTemplate(Template."Report ID", RecRefDialog, Template, RecipientEmail, false)
        else
            EmailManagement.SendEmailTemplate(RecRefDialog, Template, RecipientEmail, false);

    end;

    local procedure GetFieldValue(var RecRef: RecordRef; FieldNo: Integer) FieldValue: Text
    var
        "Field": Record "Field";
        FRef: FieldRef;
        TempBlob: Codeunit "Temp Blob";
        IStr: InStream;
        Line: Text;
    begin
        Field.Get(RecRef.Number, FieldNo);
        FRef := RecRef.Field(FieldNo);

        if Field.Class = Field.Class::FlowField then
            FRef.CalcField();

        if Field.Type = Field.Type::BLOB then begin
            TempBlob.FromFieldRef(FRef);
            if TempBlob.HasValue() then begin
                TempBlob.CreateInStream(IStr);
                while not IStr.EOS do begin
                    IStr.ReadText(Line);
                    FieldValue += Line;
                end;
            end;
        end else
            FieldValue := Format(FRef.Value);
    end;
    #endregion
    #region Page Actions
    procedure CopyFromTemplate(var EmailTemplateHeaderTo: Record "NPR E-mail Template Header")
    var
        EmailTemplateHeaderFrom: Record "NPR E-mail Template Header";
        EmailTemplateLineFrom: Record "NPR E-mail Templ. Line";
        EmailTemplateLineTo: Record "NPR E-mail Templ. Line";
        EmailTemplateFilterFrom: Record "NPR E-mail Template Filter";
        EmailTemplateFilterTo: Record "NPR E-mail Template Filter";
    begin
        if Action::LookupOK <> Page.RunModal(0, EmailTemplateHeaderFrom) then
            exit;

        if not Confirm(Text001, true, EmailTemplateHeaderTo.Code, EmailTemplateHeaderFrom.Code) then
            exit;

        EmailTemplateHeaderFrom.CalcFields("HTML Template");
        EmailTemplateHeaderTo.TransferFields(EmailTemplateHeaderFrom, false);
        EmailTemplateHeaderTo.Modify(true);

        EmailTemplateLineTo.SetRange("E-mail Template Code", EmailTemplateHeaderTo.Code);
        if EmailTemplateLineTo.FindFirst() then
            EmailTemplateLineTo.DeleteAll();

        EmailTemplateLineFrom.SetRange("E-mail Template Code", EmailTemplateHeaderFrom.Code);
        if EmailTemplateLineFrom.FindSet() then
            repeat
                EmailTemplateLineTo.Init();
                EmailTemplateLineTo.TransferFields(EmailTemplateLineFrom, true);
                EmailTemplateLineTo."E-mail Template Code" := EmailTemplateHeaderTo.Code;
                EmailTemplateLineTo.Insert(true);
            until EmailTemplateLineFrom.Next() = 0;

        EmailTemplateFilterTo.SetRange("E-mail Template Code", EmailTemplateHeaderTo.Code);
        if EmailTemplateFilterTo.FindFirst() then
            EmailTemplateFilterTo.DeleteAll();

        EmailTemplateFilterFrom.SetRange("E-mail Template Code", EmailTemplateHeaderFrom.Code);
        if EmailTemplateFilterFrom.FindSet() then
            repeat
                EmailTemplateLineTo.Init();
                EmailTemplateFilterTo.TransferFields(EmailTemplateFilterFrom, true);
                EmailTemplateFilterTo."E-mail Template Code" := EmailTemplateHeaderTo.Code;
                EmailTemplateFilterTo.Insert(true);
            until EmailTemplateFilterFrom.Next() = 0;
    end;

    procedure DeleteHtmlTemplate(var EmailTemplateHeader: Record "NPR E-mail Template Header")
    begin
        if not EmailTemplateHeader."HTML Template".HasValue() then
            exit;

        if not Confirm(Text002, false) then
            exit;

        Clear(EmailTemplateHeader."HTML Template");
        EmailTemplateHeader.Modify(true);
    end;

    procedure ExportHtmlTemplate(var EmailTemplateHeader: Record "NPR E-mail Template Header"; UseDialog: Boolean) Path: Text
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
            ToFile := FileManagement.CreateFileNameWithExtension(CreateGuid(), 'html');

        if DownloadFromStream(InStr, 'Export', '', '', ToFile) then
            exit(ToFile);

        Error(Text000);
    end;

    procedure ImportHtmlTemplate(Path: Text; UseDialog: Boolean; var EmailTemplateHeader: Record "NPR E-mail Template Header")
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
    begin
        if UseDialog then
            FileManagement.BLOBImport(TempBlob, '*.html')
        else
            FileManagement.BLOBImport(TempBlob, Path);

        TempBlob.CreateInStream(InStr);
        EmailTemplateHeader."HTML Template".CreateOutStream(OutStr, TextEncoding::UTF8);
        CopyStream(OutStr, InStr);
        EmailTemplateHeader.Modify(true);
    end;

    procedure ViewHtmlTemplate(var EmailTemplateHeader: Record "NPR E-mail Template Header")
    var
        Path: Text;
    begin
        Path := ExportHtmlTemplate(EmailTemplateHeader, false);
        Hyperlink(Path);
    end;

    procedure UploadAttachment(var EmailAttachment: Record "NPR E-mail Attachment")
    var
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        RecRef: RecordRef;
        Text001Lbl: Label 'Replace the existing file?';
    begin
        EmailAttachment.CalcFields("Attached File");
        if EmailAttachment."Attached File".HasValue() then
            if not Confirm(Text001Lbl, false) then
                exit;

        FileName := CopyStr(FileMgt.BLOBImport(TempBlob, '*.*'), 1, MaxStrLen(FileName));
        if FileName = '' then
            exit;
        RecRef.GetTable(EmailAttachment);
        TempBlob.ToRecordRef(RecRef, EmailAttachment.FieldNo("Attached File"));
        RecRef.SetTable(EmailAttachment);

        while StrPos(FileName, '\') <> 0 do
            FileName := CopyStr(CopyStr(FileName, StrPos(FileName, '\') + 1, StrLen(FileName) - StrPos(FileName, '\')), 1, MaxStrLen(FileName));
        EmailAttachment.Description := CopyStr(FileName, 1, MaxStrLen(EmailAttachment.Description));
    end;

    #endregion
}

