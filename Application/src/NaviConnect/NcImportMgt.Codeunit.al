codeunit 6151504 "NPR Nc Import Mgt."
{
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    begin
        ProcessImportEntry(Rec);
    end;

    var
        Text000: Label 'Test Error E-mail sent to:\  %1';

    procedure InsertImportEntries(ImportType: Code[10]; documents: XMLport "NPR Nc Import Entry"; var NewImportEntry: Record "NPR Nc Import Entry" temporary)
    var
        ImportEntry: Record "NPR Nc Import Entry";
        TempNcImportEntry: Record "NPR Nc Import Entry" temporary;
        RecRef: RecordRef;
        NewRecIsTemp: Boolean;
    begin
        RecRef.GetTable(NewImportEntry);
        NewRecIsTemp := RecRef.IsTemporary();

        if NewRecIsTemp then
            NewImportEntry.DeleteAll()
        else
            Clear(NewImportEntry);

        documents.Import();
        documents.CopySourceTable(TempNcImportEntry);
        if not TempNcImportEntry.FindSet() then
            exit;

        repeat
            ImportEntry.Init();
            ImportEntry := TempNcImportEntry;
            ImportEntry."Entry No." := 0;
            ImportEntry."Import Type" := ImportType;
            ImportEntry.Insert(true);

            if NewRecIsTemp then begin
                NewImportEntry.Init();
                NewImportEntry := ImportEntry;
                NewImportEntry.Insert();
            end else begin
                NewImportEntry.Get(ImportEntry."Entry No.");
                NewImportEntry.Mark(true);
            end;
        until TempNcImportEntry.Next() = 0;
        Commit();

        if not NewRecIsTemp then
            NewImportEntry.MarkedOnly(true);
    end;

    local procedure ProcessImportEntry(var ImportEntry: Record "NPR Nc Import Entry"): Boolean
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        ClearLastError();
        ImportType.Get(ImportEntry."Import Type");
        CleanupImportType(ImportType);
        Commit();

        ImportType.TestField("Import Codeunit ID");
        CODEUNIT.Run(ImportType."Import Codeunit ID", ImportEntry);
    end;

    procedure CleanupImportTypes()
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        if not ImportType.FindSet() then
            exit;

        repeat
            CleanupImportType(ImportType);
            Commit();
        until ImportType.Next() = 0;
    end;

    [TryFunction]
    procedure CleanupImportType(ImportType: Record "NPR Nc Import Type")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        CleanupDate: DateTime;
    begin
        if ImportType."Keep Import Entries for" = 0 then begin
            ImportType."Keep Import Entries for" := 1000 * 60 * 60 * 24;
            ImportType."Keep Import Entries for" := ImportType."Keep Import Entries for" * 30;
        end;
        CleanupDate := CreateDateTime(Today, Time) - ImportType."Keep Import Entries for";

        ImportEntry.SetCurrentKey("Import Type", Date, Imported);
        ImportEntry.SetRange("Import Type", ImportType.Code);
        ImportEntry.SetFilter(Date, '<%1', CleanupDate);
        ImportEntry.SetRange(Imported, true);
        if not ImportEntry.FindSet() then
            exit;

        ImportEntry.DeleteAll();
    end;

    procedure GetErrorMessage(NcImportEntry: Record "NPR Nc Import Entry"; HtmlFormat: Boolean) ErrorText: Text
    var
        InStr: InStream;
        BufferText: Text;
    begin
        ErrorText := '';
        if not NcImportEntry."Last Error Message".HasValue() then
            exit('');

        NcImportEntry.CalcFields("Last Error Message");
        NcImportEntry."Last Error Message".CreateInStream(InStr, TextEncoding::UTF8);
        while not InStr.EOS do begin
            InStr.ReadText(BufferText);
            ErrorText += BufferText;
        end;
        if not HtmlFormat then
            exit(ErrorText);

        ErrorText := ErrorText.Replace(NewLine(), '<br />');

        exit(ErrorText);
    end;

    local procedure GetErrorMailBody(var NcImportEntry: Record "NPR Nc Import Entry") Body: Text
    var
        ActiveSession: Record "Active Session";
        ErrorMessage: Text;
    begin
        ErrorMessage := GetErrorMessage(NcImportEntry, true);

        Body := '<h3>Nc Import Error</h3><br />' +
                '<dl>' +
                '    <dt><b>- Document Name:</b></dt>' +
                '    <dd>' + NcImportEntry."Document Name" + '</dd><br />' +
                '    <dt><b>- Import Type:</b></dt>' +
                '    <dd>' + NcImportEntry."Import Type" + '</dd><br />';
        if ActiveSession.Get(ServiceInstanceId(), SessionId()) then begin
            Body += '    <dt><b>- Server Instance Name:</b></dt>' +
                    '    <dd>' + ActiveSession."Server Instance Name" + '</dd><br />' +
                    '    <dt><b>- Database Name:</b></dt>' +
                    '    <dd>' + ActiveSession."Database Name" + '</dd><br />';
        end;
        Body += '    <dt><b>- Company Name:</b></dt>' +
                '    <dd>' + CompanyName + '</dd><br />' +
                '    <dt><b>- User:</b></dt>' +
                '    <dd>' + UserId + '</dd><br />' +
                '    <dt><b>- Document Date</b></dt>' +
                '    <dd>' + Format(NcImportEntry.Date) + '</dd><br />' +
                '    <dt><b>- Error Message:</b></dt>' +
                '    <dd>' + ErrorMessage + '</dd><br />' +
                '</dl>';

        exit(Body);
    end;

    local procedure GetErrorMailSenderAddress(): Text
    begin
        exit('noreply@navipartner.com');
    end;

    local procedure GetErrorMailSubject(NcImportEntry: Record "NPR Nc Import Entry") Subject: Text
    begin
        Subject := 'Nc Import Error: ' + NcImportEntry."Document Name";

        exit(Subject);
    end;

    local procedure NewLine() CRLF: Text[2]
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        exit(CRLF);
    end;

    [TryFunction]
    procedure SendErrorMail(NcImportEntry: Record "NPR Nc Import Entry")
    var
        NcImportType: Record "NPR Nc Import Type";
        InStream: InStream;
        Body: Text;
        SenderAddress: Text;
        Subject: Text;
        Separators: List of [Text];
        TempEmailItem: Record "Email Item" temporary;
        EmailSenderHandler: Codeunit "NPR Email Sending Handler";
    begin
        Separators.Add(';');
        Separators.Add(',');

        NcImportType.Get(NcImportEntry."Import Type");
        NcImportType.TestField("Send e-mail on Error");
        NcImportType.TestField("E-mail address on Error");

        SenderAddress := GetErrorMailSenderAddress();
        Subject := GetErrorMailSubject(NcImportEntry);
        Body := GetErrorMailBody(NcImportEntry);
        EmailSenderHandler.CreateEmailItem(TempEmailItem,
                  '',
                  SenderAddress,
                  NcImportType."E-mail address on Error".Split(Separators),
                  Subject,
                  Body,
                  true);

        if NcImportEntry."Document Source".HasValue() then begin
            NcImportEntry.CalcFields("Document Source");
            NcImportEntry."Document Source".CreateInStream(InStream);
            EmailSenderHandler.AddAttachmentFromStream(TempEmailItem, InStream, NcImportEntry."Document Name");
        end;
        EmailSenderHandler.Send(TempEmailItem);
    end;

    procedure SendTestErrorMail(NcImportType: Record "NPR Nc Import Type")
    var
        NcImportEntry: Record "NPR Nc Import Entry";
        OutStream: OutStream;
    begin
        NcImportEntry.Init();
        NcImportEntry."Import Type" := NcImportType.Code;
        NcImportEntry.Date := CurrentDateTime;
        NcImportEntry."Document Name" := 'Test ' + NcImportType.Description + '.xml';
        NcImportEntry."Last Error Message".CreateOutStream(OutStream);
        OutStream.WriteText('Test Error Line 1' + NewLine() + 'Test Error Line 2');
        NcImportEntry.Insert();

        SendErrorMail(NcImportEntry);
        Message(Text000, NcImportType."E-mail address on Error");
    end;
}

