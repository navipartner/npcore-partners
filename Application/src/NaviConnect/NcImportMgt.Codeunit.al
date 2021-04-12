codeunit 6151504 "NPR Nc Import Mgt."
{
    // NC1.17/MHA /20150623  CASE 216851 Object created
    // NC1.21/TTH /20151118  CASE 227358 Replacing Type option field with "Import type".
    // NC2.00/MHA /20160525  CASE 240005 NaviConnect
    // NC2.01/MHA /20161014  CASE 255397 Added functions CleanupImportEntries() and CleanupImportEntry()
    // NC2.02/MHA /20170227  CASE 262318 Added Try function SendErrorMail()
    // NC2.06/BR  /20170921  CASE 290771 Changed TryFunction call to support NAV 2017
    // NC2.12/MHA /20180502  CASE 313362 Bumped Version List to remove NPR5.36
    // NC2.23/MHA /20190927  CASE 369170 SendErrorMail() is no longer a Try function as it contains MODIFY transaction
    // NPR5.55/MHA /20200604  CASE 408100 Removed transaction in SendErrorMail() to conform as Try function

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
            NewImportEntry.DeleteAll
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
        //-NC2.02 [262318]
        ClearLastError;
        //+NC2.02 [262318]
        ImportType.Get(ImportEntry."Import Type");
        //-NC2.01 [255397]
        //-NC2.06 [290771]
        //IF CleanupImportType(ImportType) THEN
        CleanupImportType(ImportType);
        //+NC2.06 [290771]
        Commit();
        //+NC2.01 [255397]

        ImportType.TestField("Import Codeunit ID");
        CODEUNIT.Run(ImportType."Import Codeunit ID", ImportEntry);
    end;

    local procedure "--- Cleanup"()
    begin
    end;

    procedure CleanupImportTypes()
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        //-NC2.01 [255397]
        if not ImportType.FindSet() then
            exit;

        repeat
            //-NC2.06 [290771]
            //IF CleanupImportType(ImportType) THEN
            CleanupImportType(ImportType);
            //+NC2.06 [290771]
            Commit();
        until ImportType.Next() = 0;
        //+NC2.01 [255397]
    end;

    [TryFunction]
    procedure CleanupImportType(ImportType: Record "NPR Nc Import Type")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        CleanupDate: DateTime;
    begin
        //-NC2.01 [255397]
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
        //+NC2.01 [255397]
    end;

    local procedure "--- Error Management"()
    begin
    end;

    procedure GetErrorMessage(NcImportEntry: Record "NPR Nc Import Entry"; HtmlFormat: Boolean) ErrorText: Text
    var
        InStream: InStream;
        StreamReader: DotNet NPRNetStreamReader;
        String: DotNet NPRNetString;
    begin
        //-NC2.02 [262318]
        ErrorText := '';
        if not NcImportEntry."Last Error Message".HasValue() then
            exit('');

        NcImportEntry.CalcFields("Last Error Message");
        //-NPR5.55 [408100]
        NcImportEntry."Last Error Message".CreateInStream(InStream, TEXTENCODING::UTF8);
        //+NPR5.55 [408100]
        StreamReader := StreamReader.StreamReader(InStream);
        ErrorText := StreamReader.ReadToEnd();
        if not HtmlFormat then
            exit(ErrorText);

        String := ErrorText;
        ErrorText := String.Replace(NewLine(), '<br />');

        exit(ErrorText);
        //+NC2.02 [262318]
    end;

    local procedure GetErrorMailBody(var NcImportEntry: Record "NPR Nc Import Entry") Body: Text
    var
        ActiveSession: Record "Active Session";
        ErrorMessage: Text;
    begin
        //-NC2.02 [262318]
        ErrorMessage := GetErrorMessage(NcImportEntry, true);

        Body := '<h3>Nc Import Error</h3><br />' +
                '<dl>' +
                '    <dt><b>- Document Name:</b></dt>' +
                '    <dd>' + NcImportEntry."Document Name" + '</dd><br />' +
                '    <dt><b>- Import Type:</b></dt>' +
                '    <dd>' + NcImportEntry."Import Type" + '</dd><br />';
        if ActiveSession.Get(ServiceInstanceId, SessionId) then begin
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
        //+NC2.02 [262318]
    end;

    local procedure GetErrorMailSenderAddress(NcImportEntry: Record "NPR Nc Import Entry"): Text
    begin
        //-NC2.02 [262318]
        exit('noreply@navipartner.com');
        //+NC2.02 [262318]
    end;

    local procedure GetErrorMailSubject(NcImportEntry: Record "NPR Nc Import Entry") Subject: Text
    begin
        //-NC2.02 [262318]
        Subject := 'Nc Import Error: ' + NcImportEntry."Document Name";

        exit(Subject);
        //+NC2.02 [262318]
    end;

    local procedure NewLine() CRLF: Text[2]
    begin
        //-NC2.02 [262318]
        CRLF[1] := 13;
        CRLF[2] := 10;
        exit(CRLF);
        //+NC2.02 [262318]
    end;

    [TryFunction]
    procedure SendErrorMail(NcImportEntry: Record "NPR Nc Import Entry")
    var
        NcImportType: Record "NPR Nc Import Type";
        SMTPMailSetup: Record "SMTP Mail Setup";
        SMTPMail: Codeunit "SMTP Mail";
        InStream: InStream;
        Body: Text;
        SenderAddress: Text;
        Subject: Text;
        Separators: List of [Text];
    begin
        Separators.Add(';');
        Separators.Add(',');

        //-NC2.02 [262318]
        NcImportType.Get(NcImportEntry."Import Type");
        NcImportType.TestField("Send e-mail on Error");
        NcImportType.TestField("E-mail address on Error");

        SMTPMailSetup.Get();

        SenderAddress := GetErrorMailSenderAddress(NcImportEntry);
        Subject := GetErrorMailSubject(NcImportEntry);
        Body := GetErrorMailBody(NcImportEntry);

        SMTPMail.CreateMessage(
          '',
          SenderAddress,
          NcImportType."E-mail address on Error".Split(Separators),
          Subject,
          Body,
          true);

        if NcImportEntry."Document Source".HasValue() then begin
            NcImportEntry.CalcFields("Document Source");
            NcImportEntry."Document Source".CreateInStream(InStream);
            SMTPMail.AddAttachmentStream(InStream, NcImportEntry."Document Name");
        end;
        SMTPMail.Send;
        //+NC2.02 [262318]
    end;

    procedure SendTestErrorMail(NcImportType: Record "NPR Nc Import Type")
    var
        TempNcImportEntry: Record "NPR Nc Import Entry";
        OutStream: OutStream;
    begin
        //-NC2.02 [262318]
        TempNcImportEntry.Init();
        TempNcImportEntry."Import Type" := NcImportType.Code;
        TempNcImportEntry.Date := CurrentDateTime;
        TempNcImportEntry."Document Name" := 'Test ' + NcImportType.Description + '.xml';
        TempNcImportEntry."Last Error Message".CreateOutStream(OutStream);
        OutStream.WriteText('Test Error Line 1' + NewLine() + 'Test Error Line 2');
        TempNcImportEntry.Insert();

        SendErrorMail(TempNcImportEntry);
        Message(Text000, NcImportType."E-mail address on Error");
        //+NC2.02 [262318]
    end;
}

