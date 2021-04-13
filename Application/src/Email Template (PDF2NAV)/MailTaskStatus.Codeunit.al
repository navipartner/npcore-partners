codeunit 6059905 "NPR Mail Task Status"
{
    TableNo = "NPR Task Line";

    trigger OnRun()
    begin
        TaskLine := Rec;
        TaskBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name");
        if TaskBatch."Mail From Address" = '' then
            TaskBatch."Mail From Address" := 'Navipartner@NoReply.com';
        if TaskBatch."Mail From Name" = '' then
            TaskBatch."Mail From Name" := 'Navipartner (No Reply)';
        TaskLog.Get(TaskLine.GetLogEntryNo);

        TaskLineParm.SetRange("Journal Template Name", TaskLine."Journal Template Name");
        TaskLineParm.SetRange("Journal Batch Name", TaskLine."Journal Batch Name");
        TaskLineParm.SetRange("Journal Line No.", TaskLine."Line No.");

        case TaskLog.Status of
            TaskLog.Status::Started:
                SendMailOnStart;
            TaskLog.Status::Error:
                SendMailOnError;
            TaskLog.Status::Succes:
                begin
                    SendMailOnErrorRecovery;
                    SendMailOnSucces;
                end;
        end;
    end;

    var
        Text001: Label 'Task "%1" executed with status %2';
        TaskLine: Record "NPR Task Line";
        TaskLineParm: Record "NPR Task Line Parameters";
        TaskBatch: Record "NPR Task Batch";
        TaskLog: Record "NPR Task Log (Task)";
        Text002: Label 'This is error no %1 on this task';
        Text003: Label 'Due to the setup, there will not be send any more mails for this task, before it is executed with success again';
        Text004: Label 'Error message:';
        Text005: Label 'Task details:';
        Text006: Label 'Company name';
        Text007: Label 'Task "%1" will be executed now';
        Text008: Label 'Task "%1" is running again with status %2';

        EmailItem: Record "Email Item" temporary;
        MailManagement: Codeunit "Mail Management";
        Text009: Label 'J-Mail is discontinued';

    local procedure SendMailOnStart()
    var
        TaskOutputLog: Record "NPR Task Output Log";
    begin
        if not TaskLine."Send E-Mail (On Start)" then
            exit;

        TaskLineParm.SetRange("Field No.", 171);
        if TaskLineParm.IsEmpty then
            exit;

        CreateMessage(0, TaskBatch."Mail From Name", TaskBatch."Mail From Address",
                      '', StrSubstNo(Text007, TaskLine.Description), '');

        if TaskLineParm.FindFirst() then
            repeat
                AddRecipient(TaskLineParm.Value);
            until TaskLineParm.Next() = 0;

        TaskLineParm.SetRange("Field No.", 172);

        if TaskLineParm.FindFirst() then
            repeat
                AppendHTML(TaskLineParm.Value);
            until TaskLineParm.Next() = 0;

        AppendHTML('');
        AppendHTML(Text005);
        AppendHTML(Text006 + ': ' + CompanyName);
        AppendHTML(TaskLine.FieldCaption("Journal Template Name") + ': ' + TaskLine."Journal Template Name");
        AppendHTML(TaskLine.FieldCaption("Journal Batch Name") + ': ' + TaskLine."Journal Batch Name");
        AppendHTML(TaskLine.FieldCaption("Line No.") + ': ' + Format(TaskLine."Line No."));
        AppendHTML(TaskLine.FieldCaption(Description) + ': ' + TaskLine.Description);

        if TaskLine.GetLogEntryNo <> 0 then begin
            TaskOutputLog.SetRange("Task Log Entry No.", TaskLine.GetLogEntryNo);
            if TaskOutputLog.FindSet() then
                repeat
                    AddAttachment(TaskOutputLog."File Name");
                until TaskOutputLog.Next = 0;
        end;

        Send();
    end;

    local procedure SendMailOnError()
    var
        CurrentErrorNo: Integer;
        TaskOutputLog: Record "NPR Task Output Log";
    begin
        if not TaskLine."Send E-Mail (On Error)" then
            exit;

        CurrentErrorNo := TaskLine."Error Counter" + 1;

        if TaskLine."First E-Mail After Error No." <> 0 then
            if CurrentErrorNo < TaskLine."First E-Mail After Error No." then
                exit;

        if TaskLine."Last E-Mail After Error No." <> 0 then
            if CurrentErrorNo > TaskLine."Last E-Mail After Error No." then
                exit;

        TaskLineParm.SetRange("Field No.", 176);
        if TaskLineParm.IsEmpty then
            exit;

        CreateMessage(0, TaskBatch."Mail From Name", TaskBatch."Mail From Address",
                      '', StrSubstNo(Text001, TaskLine.Description, TaskLog.Status), '');

        if TaskLineParm.FindFirst then
            repeat
                AddRecipient(TaskLineParm.Value);
            until TaskLineParm.Next = 0;


        AppendHTML(StrSubstNo(Text002, CurrentErrorNo));
        AppendHTML(Text004);
        AppendHTML(TaskLog."Last Error Message");

        if CurrentErrorNo = TaskLine."Last E-Mail After Error No." then
            AppendHTML(Text003);

        TaskLineParm.SetRange("Field No.", 177);
        if TaskLineParm.FindFirst then
            repeat
                AppendHTML(TaskLineParm.Value);
            until TaskLineParm.Next = 0;

        AppendHTML('');
        AppendHTML(Text005);
        AppendHTML(Text006 + ': ' + CompanyName);
        AppendHTML(TaskLine.FieldCaption("Journal Template Name") + ': ' + TaskLine."Journal Template Name");
        AppendHTML(TaskLine.FieldCaption("Journal Batch Name") + ': ' + TaskLine."Journal Batch Name");
        AppendHTML(TaskLine.FieldCaption("Line No.") + ': ' + Format(TaskLine."Line No."));
        AppendHTML(TaskLine.FieldCaption(Description) + ': ' + TaskLine.Description);

        if TaskLine.GetLogEntryNo <> 0 then begin
            TaskOutputLog.SetRange("Task Log Entry No.", TaskLine.GetLogEntryNo);
            if TaskOutputLog.FindSet then
                repeat
                    AddAttachment(TaskOutputLog."File Name");
                until TaskOutputLog.Next = 0;
        end;

        Send();
    end;

    local procedure SendMailOnSucces()
    var
        TaskOutputLog: Record "NPR Task Output Log";
        FilesExists: Boolean;
        InStr: InStream;
    begin
        if not TaskLine."Send E-Mail (On Success)" then
            exit;

        TaskLineParm.SetRange("Field No.", 181);
        if TaskLineParm.IsEmpty then
            exit;

        if (TaskLine."Send Only if File Exists") and (TaskLine.GetLogEntryNo <> 0) then begin
            TaskOutputLog.SetRange("Task Log Entry No.", TaskLine.GetLogEntryNo);
            if TaskOutputLog.FindSet() then
                repeat
                    TaskOutputLog.CalcFields(TaskOutputLog.File);
                    FilesExists := TaskOutputLog.File.HasValue;
                until (TaskOutputLog.Next() = 0) or FilesExists;
            if not FilesExists then
                exit;
        end;

        CreateMessage(0, TaskBatch."Mail From Name", TaskBatch."Mail From Address",
                      '', StrSubstNo(Text001, TaskLine.Description, TaskLog.Status), '');

        if TaskLineParm.FindFirst() then
            repeat
                AddRecipient(TaskLineParm.Value);
            until TaskLineParm.Next() = 0;

        TaskLineParm.SetRange("Field No.", 182);
        if TaskLineParm.FindFirst() then
            repeat
                AppendHTML(TaskLineParm.Value);
            until TaskLineParm.Next() = 0;

        AppendHTML('');
        AppendHTML(Text005);
        AppendHTML(Text006 + ': ' + CompanyName);
        AppendHTML(TaskLine.FieldCaption("Journal Template Name") + ': ' + TaskLine."Journal Template Name");
        AppendHTML(TaskLine.FieldCaption("Journal Batch Name") + ': ' + TaskLine."Journal Batch Name");
        AppendHTML(TaskLine.FieldCaption("Line No.") + ': ' + Format(TaskLine."Line No."));
        AppendHTML(TaskLine.FieldCaption(Description) + ': ' + TaskLine.Description);

        if TaskLine.GetLogEntryNo <> 0 then begin
            TaskOutputLog.SetRange("Task Log Entry No.", TaskLine.GetLogEntryNo);
            if TaskOutputLog.FindSet() then
                repeat
                    AddAttachment(TaskOutputLog."File Name")
                until TaskOutputLog.Next = 0;
        end;

        Send();
    end;

    local procedure SendMailOnErrorRecovery()
    var
        TaskOutputLog: Record "NPR Task Output Log";
    begin
        if not TaskLine."Send E-Mail (On Error)" or (TaskLine."Last E-Mail After Error No." = 0) then
            exit;

        if TaskLine."Error Counter" < TaskLine."Last E-Mail After Error No." then
            exit;

        TaskLineParm.SetRange("Field No.", 176);
        if TaskLineParm.IsEmpty then
            exit;

        CreateMessage(0, TaskBatch."Mail From Name", TaskBatch."Mail From Address",
                      '', StrSubstNo(Text008, TaskLine.Description, TaskLog.Status), '');

        if TaskLineParm.FindFirst then
            repeat
                AddRecipient(TaskLineParm.Value);
            until TaskLineParm.Next = 0;

        TaskLineParm.SetRange("Field No.", 182);
        if TaskLineParm.FindFirst then
            repeat
                AppendHTML(TaskLineParm.Value);
            until TaskLineParm.Next = 0;

        AppendHTML('');
        AppendHTML(Text005);
        AppendHTML(Text006 + ': ' + CompanyName);
        AppendHTML(TaskLine.FieldCaption("Journal Template Name") + ': ' + TaskLine."Journal Template Name");
        AppendHTML(TaskLine.FieldCaption("Journal Batch Name") + ': ' + TaskLine."Journal Batch Name");
        AppendHTML(TaskLine.FieldCaption("Line No.") + ': ' + Format(TaskLine."Line No."));
        AppendHTML(TaskLine.FieldCaption(Description) + ': ' + TaskLine.Description);

        if TaskLine.GetLogEntryNo <> 0 then begin
            TaskOutputLog.SetRange("Task Log Entry No.", TaskLine.GetLogEntryNo);
            if TaskOutputLog.FindSet then
                repeat
                    AddAttachment(TaskOutputLog."File Name");
                until TaskOutputLog.Next = 0;
        end;

        Send();
    end;

    procedure OpenNewMessage(SendAsMailType: Option Auto,JMail,SMTPMail; ToName: Text[80]): Boolean
    var
        Recipients: List of [Text];
    begin
        Clear(MailManagement);
        if SendAsMailType = SendAsMailType::Auto then begin
            if MailManagement.IsEnabled() then
                SendAsMailType := SendAsMailType::SMTPMail
            else
                SendAsMailType := SendAsMailType::JMail;
        end;

        CreateEmailItem(EmailItem, ToName, '', Recipients, '', '');
    end;

    procedure CreateMessage(SendAsMailType: Option Auto,JMail,SMTPMail; SenderName: Text[100]; SenderAddress: Text; Recipients: Text[1024]; Subject: Text[200]; Body: Text[1024])
    var
        Separators: List of [Text];
    begin
        Clear(MailManagement);
        if SendAsMailType = SendAsMailType::Auto then begin
            if MailManagement.IsEnabled() then
                SendAsMailType := SendAsMailType::SMTPMail
            else
                SendAsMailType := SendAsMailType::JMail;
        end;

        InitMailAdrSeparators(Separators);

        CreateEmailItem(EmailItem, SenderName, SenderAddress, Recipients.Split(Separators), Subject, Body);
    end;

    local procedure CreateEmailItem(var EmailItem: Record "Email Item"; FromName: Text; FromAddress: Text; Recipients: List of [Text]; Subject: Text; Body: Text)
    var
        i: Integer;
        RecipientsText: Text;
        RecipientsCCText: Text;
        RecValue: Text;
    begin
        EmailItem.Initialize();
        EmailItem.Validate("Plaintext Formatted", false);
        EmailItem.Validate("Message Type", EmailItem."Message Type"::"From Email Body Template");
        EmailItem.Validate("From Address", FromAddress);
        EmailItem.Validate("From Name", FromName);

        for i := 1 to Recipients.Count do begin
            Recipients.Get(i, RecValue);
            if StrLen(RecipientsText + ';' + RecValue) < 250 then
                if RecipientsText = '' then
                    RecipientsText := RecValue
                else
                    RecipientsText += ';' + RecValue
            else
                if StrLen(RecipientsCCText + ';' + RecValue) < 250 then
                    if RecipientsCCText = '' then
                        RecipientsCCText := RecValue
                    else
                        RecipientsCCText += ';' + RecValue;
        end;
        EmailItem.Validate("Send to", RecipientsText);
        EmailItem.Validate("Send CC", RecipientsCCText);
        EmailItem.Validate(Subject, Subject);
        EmailItem.SetBodyText(Body);
        EmailItem.Insert();
    end;

    procedure CreateMessage2(SendAsMailType: Option Auto,JMail,SMTPMail; Subject: Text[200]; TaskLine2: Record "NPR Task Line")
    begin
        TaskLineParm.SetRange("Journal Template Name", TaskLine2."Journal Template Name");
        TaskLineParm.SetRange("Journal Batch Name", TaskLine2."Journal Batch Name");
        TaskLineParm.SetRange("Journal Line No.", TaskLine2."Line No.");
        TaskLineParm.SetRange("Field No.", 185);
        if TaskLineParm.IsEmpty then
            exit;

        TaskBatch.Get(TaskLine2."Journal Template Name", TaskLine2."Journal Batch Name");
        if TaskBatch."Mail From Address" = '' then
            TaskBatch."Mail From Address" := 'Navipartner@NoReply.com';
        if TaskBatch."Mail From Name" = '' then
            TaskBatch."Mail From Name" := 'Navipartner (No Reply)';

        CreateMessage(SendAsMailType, TaskBatch."Mail From Name", TaskBatch."Mail From Address", '', Subject, '');

        if TaskLineParm.FindFirst() then
            repeat
                AddRecipient(TaskLineParm.Value);
            until TaskLineParm.Next() = 0;

        TaskLineParm.SetRange("Field No.", 186);
        if TaskLineParm.FindFirst() then
            repeat
                AddRecipientCC(TaskLineParm.Value);
            until TaskLineParm.Next() = 0;

        TaskLineParm.SetRange("Field No.", 187);
        if TaskLineParm.FindFirst() then
            repeat
                AddRecipientBCC(TaskLineParm.Value);
            until TaskLineParm.Next() = 0;
    end;

    procedure AddRecipient(NewRecipient: Text[80])
    var
        Recipients: List of [Text];
        Separators: List of [Text];
        RecValue: Text;
        RecipientsText: Text;
        i: Integer;
    begin
        InitMailAdrSeparators(Separators);
        Recipients := NewRecipient.Split(Separators);

        RecipientsText := EmailItem."Send to";

        for i := 1 to Recipients.Count do begin
            Recipients.Get(i, RecValue);
            if StrLen(RecipientsText + ';' + RecValue) < 250 then
                if RecipientsText = '' then
                    RecipientsText := RecValue
                else
                    RecipientsText += ';' + RecValue;
        end;

        EmailItem.Validate("Send to", RecipientsText);
        EmailItem.Modify();
    end;

    procedure AddRecipientCC(NewRecipientCC: Text[80])
    var
        CCRecipients: List of [Text];
        Separators: List of [Text];
        RecValue: Text;
        RecipientsText: Text;
        i: Integer;
    begin
        InitMailAdrSeparators(Separators);
        CCRecipients := NewRecipientCC.Split(Separators);

        RecipientsText := EmailItem."Send CC";

        for i := 1 to CCRecipients.Count do begin
            CCRecipients.Get(i, RecValue);
            if StrLen(RecipientsText + ';' + RecValue) < 250 then
                if RecipientsText = '' then
                    RecipientsText := RecValue
                else
                    RecipientsText += ';' + RecValue;
        end;

        EmailItem.Validate("Send CC", RecipientsText);
        EmailItem.Modify();
    end;

    procedure AddRecipientBCC(NewRecipientBCC: Text[80])
    var
        BCCRecipients: List of [Text];
        Separators: List of [Text];
        RecValue: Text;
        RecipientsText: Text;
        i: Integer;
    begin
        InitMailAdrSeparators(Separators);
        BCCRecipients := NewRecipientBCC.Split(Separators);

        RecipientsText := EmailItem."Send BCC";

        for i := 1 to BCCRecipients.Count do begin
            BCCRecipients.Get(i, RecValue);
            if StrLen(RecipientsText + ';' + RecValue) < 250 then
                if RecipientsText = '' then
                    RecipientsText := RecValue
                else
                    RecipientsText += ';' + RecValue;
        end;

        EmailItem.Validate("Send BCC", RecipientsText);
        EmailItem.Modify();
    end;

    procedure AppendHTML(TextLine: Text[260]): Boolean
    var
        InStr: InStream;
        BodyText: Text;
    begin
        EmailItem.CalcFields(Body);
        EmailItem.Body.CreateInStream(InStr);
        InStr.Read(BodyText);
        BodyText += TextLine + '<br/>';
        EmailItem.SetBodyText(BodyText);
        EmailItem.Modify();
    end;

    procedure AddAttachment(NewAttachment: Text[1024])
    var
        FileMgt: Codeunit "File Management";
    begin
        case true of
            EmailItem."Attachment File Path" = '':
                begin
                    EmailItem."Attachment File Path" := NewAttachment;
                    EmailItem."Attachment Name" := FileMgt.GetFileName(NewAttachment);
                end;
            EmailItem."Attachment File Path 2" = '':
                begin
                    EmailItem."Attachment File Path 2" := NewAttachment;
                    EmailItem."Attachment Name 2" := FileMgt.GetFileName(NewAttachment);
                end;
            EmailItem."Attachment File Path 3" = '':
                begin
                    EmailItem."Attachment File Path 3" := NewAttachment;
                    EmailItem."Attachment Name 3" := FileMgt.GetFileName(NewAttachment);
                end;
            EmailItem."Attachment File Path 4" = '':
                begin
                    EmailItem."Attachment File Path 4" := NewAttachment;
                    EmailItem."Attachment Name 4" := FileMgt.GetFileName(NewAttachment);
                end;
            EmailItem."Attachment File Path 5" = '':
                begin
                    EmailItem."Attachment File Path 5" := NewAttachment;
                    EmailItem."Attachment Name 5" := FileMgt.GetFileName(NewAttachment);
                end;
            EmailItem."Attachment File Path 6" = '':
                begin
                    EmailItem."Attachment File Path 6" := NewAttachment;
                    EmailItem."Attachment Name 6" := FileMgt.GetFileName(NewAttachment);
                end;
            EmailItem."Attachment File Path 7" = '':
                begin
                    EmailItem."Attachment File Path 7" := NewAttachment;
                    EmailItem."Attachment Name 7" := FileMgt.GetFileName(NewAttachment);
                end;
        end;
        EmailItem.Modify();
    end;

    procedure AddAttachmentFromStream(TaskOutputLog: Record "NPR Task Output Log"; NewAttachment: Text[1024])
    var
        TempBLOB: Codeunit "Temp Blob";
        Outstr: OutStream;
        FileMgt: Codeunit "File Management";
        FilePath: Text;
    begin
        FilePath := FileMgt.CreateFileNameWithExtension(NewAttachment, '.pdf');
        TaskOutputLog.File.Export(FilePath);
        case true of
            EmailItem."Attachment File Path" = '':
                begin
                    EmailItem."Attachment File Path" := FilePath;
                    EmailItem."Attachment Name" := NewAttachment;
                end;
            EmailItem."Attachment File Path 2" = '':
                begin
                    EmailItem."Attachment File Path 2" := FilePath;
                    EmailItem."Attachment Name 2" := NewAttachment;
                end;
            EmailItem."Attachment File Path 3" = '':
                begin
                    EmailItem."Attachment File Path 3" := FilePath;
                    EmailItem."Attachment Name 3" := NewAttachment;
                end;
            EmailItem."Attachment File Path 4" = '':
                begin
                    EmailItem."Attachment File Path 4" := FilePath;
                    EmailItem."Attachment Name 4" := NewAttachment;
                end;
            EmailItem."Attachment File Path 5" = '':
                begin
                    EmailItem."Attachment File Path 5" := FilePath;
                    EmailItem."Attachment Name 5" := NewAttachment;
                end;
            EmailItem."Attachment File Path 6" = '':
                begin
                    EmailItem."Attachment File Path 6" := FilePath;
                    EmailItem."Attachment Name 6" := NewAttachment;
                end;
            EmailItem."Attachment File Path 7" = '':
                begin
                    EmailItem."Attachment File Path 7" := FilePath;
                    EmailItem."Attachment Name 7" := NewAttachment;
                end;
        end;
        EmailItem.Modify();
    end;

    procedure Send() MailSent: Boolean
    begin
        MailManagement.SetHideMailDialog(true);
        MailManagement.Send(EmailItem, Enum::"Email Scenario"::Default);
        exit(true);
    end;

    local procedure InitMailAdrSeparators(var MailAdrSeparators: List of [Text])
    begin
        MailAdrSeparators.Add(';');
        MailAdrSeparators.Add(',');
    end;
}
