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
        TaskLog.Get(TaskLine.GetLogEntryNo());

        TaskLineParm.SetRange("Journal Template Name", TaskLine."Journal Template Name");
        TaskLineParm.SetRange("Journal Batch Name", TaskLine."Journal Batch Name");
        TaskLineParm.SetRange("Journal Line No.", TaskLine."Line No.");

        case TaskLog.Status of
            TaskLog.Status::Started:
                SendMailOnStart();
            TaskLog.Status::Error:
                SendMailOnError();
            TaskLog.Status::Succes:
                begin
                    SendMailOnErrorRecovery();
                    SendMailOnSucces();
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

        TempEmailItem: Record "Email Item" temporary;
        EmailSenderHandler: Codeunit "NPR Email Sending Handler";
        MailManagement: Codeunit "Mail Management";

    local procedure SendMailOnStart()
    var
        TaskOutputLog: Record "NPR Task Output Log";
        InStr: InStream;
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

        if TaskLine.GetLogEntryNo() <> 0 then begin
            TaskOutputLog.SetRange("Task Log Entry No.", TaskLine.GetLogEntryNo());
            if TaskOutputLog.FindSet() then
                repeat
                    TaskOutputLog.CalcFields(File);
                    if TaskOutputLog.File.HasValue then begin
                        TaskOutputLog.File.CreateInStream(InStr);
                        AddAttachmentFromStream(InStr, TaskOutputLog."File Name");
                    end;
                until TaskOutputLog.Next() = 0;
        end;

        Send();
    end;

    local procedure SendMailOnError()
    var
        CurrentErrorNo: Integer;
        TaskOutputLog: Record "NPR Task Output Log";
        InStr: InStream;
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

        if TaskLineParm.FindFirst() then
            repeat
                AddRecipient(TaskLineParm.Value);
            until TaskLineParm.Next() = 0;


        AppendHTML(StrSubstNo(Text002, CurrentErrorNo));
        AppendHTML(Text004);
        AppendHTML(TaskLog."Last Error Message");

        if CurrentErrorNo = TaskLine."Last E-Mail After Error No." then
            AppendHTML(Text003);

        TaskLineParm.SetRange("Field No.", 177);
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

        if TaskLine.GetLogEntryNo() <> 0 then begin
            TaskOutputLog.SetRange("Task Log Entry No.", TaskLine.GetLogEntryNo());
            if TaskOutputLog.FindSet() then
                repeat
                    TaskOutputLog.CalcFields(File);
                    if TaskOutputLog.File.HasValue then begin
                        TaskOutputLog.File.CreateInStream(InStr);
                        AddAttachmentFromStream(InStr, TaskOutputLog."File Name");
                    end;
                until TaskOutputLog.Next() = 0;
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

        if (TaskLine."Send Only if File Exists") and (TaskLine.GetLogEntryNo() <> 0) then begin
            TaskOutputLog.SetRange("Task Log Entry No.", TaskLine.GetLogEntryNo());
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

        if TaskLine.GetLogEntryNo() <> 0 then begin
            TaskOutputLog.SetRange("Task Log Entry No.", TaskLine.GetLogEntryNo());
            if TaskOutputLog.FindSet() then
                repeat
                    TaskOutputLog.CalcFields(File);
                    if TaskOutputLog.File.HasValue then begin
                        TaskOutputLog.File.CreateInStream(InStr);
                        AddAttachmentFromStream(InStr, TaskOutputLog."File Name");
                    end;
                until TaskOutputLog.Next() = 0;
        end;

        Send();
    end;

    local procedure SendMailOnErrorRecovery()
    var
        TaskOutputLog: Record "NPR Task Output Log";
        InStr: InStream;
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

        if TaskLine.GetLogEntryNo() <> 0 then begin
            TaskOutputLog.SetRange("Task Log Entry No.", TaskLine.GetLogEntryNo());
            if TaskOutputLog.FindSet() then
                repeat
                    TaskOutputLog.CalcFields(File);
                    if TaskOutputLog.File.HasValue then begin
                        TaskOutputLog.File.CreateInStream(InStr);
                        AddAttachmentFromStream(InStr, TaskOutputLog."File Name");
                    end;
                until TaskOutputLog.Next() = 0;
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
        EmailSenderHandler.CreateEmailItem(TempEmailItem, ToName, '', Recipients, '', '', true);
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
        EmailSenderHandler.CreateEmailItem(TempEmailItem, SenderName, SenderAddress, Recipients.Split(Separators), Subject, Body, true);
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

    procedure AddRecipient(NewRecipient: Text)
    var
        Recipients: List of [Text];
        Separators: List of [Text];
    begin
        InitMailAdrSeparators(Separators);
        Recipients := NewRecipient.Split(Separators);
        EmailSenderHandler.AddRecipients(TempEmailItem, Recipients);
    end;

    procedure AddRecipientCC(NewRecipientCC: Text)
    var
        CCRecipients: List of [Text];
        Separators: List of [Text];
    begin
        InitMailAdrSeparators(Separators);
        CCRecipients := NewRecipientCC.Split(Separators);
        EmailSenderHandler.AddRecipientCC(TempEmailItem, CCRecipients);
    end;

    procedure AddRecipientBCC(NewRecipientBCC: Text)
    var
        BCCRecipients: List of [Text];
        Separators: List of [Text];
    begin
        InitMailAdrSeparators(Separators);
        BCCRecipients := NewRecipientBCC.Split(Separators);
        EmailSenderHandler.AddRecipientBCC(TempEmailItem, BCCRecipients);
    end;

    procedure AppendHTML(TextLine: Text[260]): Boolean
    begin
        EmailSenderHandler.AppendBodyLine(TempEmailItem, TextLine + '<br/>');
    end;

    procedure AddAttachmentFromStream(InStrAttachment: InStream; NewAttachment: Text[1024])
    begin
        EmailSenderHandler.AddAttachmentFromStream(TempEmailItem, InStrAttachment, NewAttachment);
    end;

    procedure Send() MailSent: Boolean
    begin
        EmailSenderHandler.Send(TempEmailItem);
        exit(true);
    end;

    local procedure InitMailAdrSeparators(var MailAdrSeparators: List of [Text])
    begin
        MailAdrSeparators.Add(';');
        MailAdrSeparators.Add(',');
    end;
}
