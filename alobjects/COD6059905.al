codeunit 6059905 "Mail Task Status"
{
    // TQ1.08/LS/20140722  CASE  188358 :   Modified Fx SendJmailOnSucces, to send mail if file exists
    // TQ1.16/JDH/20140916 CASE  179044 Implemented SMTP Mail for 2013 Alignment
    // TQ1.17/JDH/20141002 CASE         added wrapper function to be capable of deciding Mail component by simply calling with parameter
    // TQ1.19/JDH/20141203 CASE  199884 New function to make it easier to send a mail
    // TQ1.27/MH/20150409  CASE 210797 NPR8.00 specific version due to changed parameters for SMTPMail.AddAttachment
    // TQ1.27/TS/20150716  CASE 211152 Possible to not include files in mail
    // TQ1.27/MH/20150727  CASE 217903 Deleted unused Variables and fields
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.29/JDH /20160802 CASE 242044 Removed J-mail option

    TableNo = "Task Line";

    trigger OnRun()
    begin
        TaskLine := Rec;
        TaskBatch.Get("Journal Template Name", "Journal Batch Name");
        if TaskBatch."Mail From Address" = '' then
            TaskBatch."Mail From Address" := 'Navipartner@NoReply.com';
        if TaskBatch."Mail From Name" = '' then
            TaskBatch."Mail From Name" := 'Navipartner (No Reply)';
        TaskLog.Get(TaskLine.GetLogEntryNo);

        TaskLineParm.SetRange("Journal Template Name", TaskLine."Journal Template Name");
        TaskLineParm.SetRange("Journal Batch Name", TaskLine."Journal Batch Name");
        TaskLineParm.SetRange("Journal Line No.", TaskLine."Line No.");

        //-TQ1.17
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
        //+TQ1.17
    end;

    var
        Text001: Label 'Task "%1" executed with status %2';
        TaskLine: Record "Task Line";
        TaskLineParm: Record "Task Line Parameters";
        TaskBatch: Record "Task Batch";
        TaskLog: Record "Task Log (Task)";
        Text002: Label 'This is error no %1 on this task';
        Text003: Label 'Due to the setup, there will not be send any more mails for this task, before it is executed with success again';
        Text004: Label 'Error message:';
        Text005: Label 'Task details:';
        Text006: Label 'Company name';
        Text007: Label 'Task "%1" will be executed now';
        Text008: Label 'Task "%1" is running again with status %2';
        SMTPMail: Codeunit "SMTP Mail";
        Text009: Label 'J-Mail is discontinued';

    local procedure SendMailOnStart()
    var
        TaskOutputLog: Record "Task Output Log";
    begin
        //-TQ1.17
        if not TaskLine."Send E-Mail (On Start)" then
            exit;

        TaskLineParm.SetRange("Field No.", 171);
        if TaskLineParm.IsEmpty then
            exit;

        //-TQ1.29
        //CreateMessage(TaskBatch."Mail Program", TaskBatch."Mail From Name", TaskBatch."Mail From Address",
        //              '', STRSUBSTNO(Text007, TaskLine.Description), '');
        CreateMessage(0, TaskBatch."Mail From Name", TaskBatch."Mail From Address",
                      '', StrSubstNo(Text007, TaskLine.Description), '');
        //+TQ1.29

        if TaskLineParm.FindFirst then
            repeat
                AddRecipient(TaskLineParm.Value);
            until TaskLineParm.Next = 0;

        TaskLineParm.SetRange("Field No.", 172);

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
                    if Exists(TaskOutputLog."File Name") then
                        AddAttachment(TaskOutputLog."File Name");
                until TaskOutputLog.Next = 0;
        end;

        Send();
        //+TQ1.17
    end;

    local procedure SendMailOnError()
    var
        CurrentErrorNo: Integer;
        TaskOutputLog: Record "Task Output Log";
    begin
        //-TQ1.17
        with TaskLine do begin
            if not "Send E-Mail (On Error)" then
                exit;

            //task have runned with status error, but the "error counter" havent been increased yet
            CurrentErrorNo := "Error Counter" + 1;

            if "First E-Mail After Error No." <> 0 then
                if CurrentErrorNo < "First E-Mail After Error No." then
                    exit;

            if "Last E-Mail After Error No." <> 0 then
                if CurrentErrorNo > "Last E-Mail After Error No." then
                    exit;

            TaskLineParm.SetRange("Field No.", 176);
            if TaskLineParm.IsEmpty then
                exit;

            //-TQ1.29
            //CASE TaskBatch."Mail Program" OF
            //  TaskBatch."Mail Program"::JMail: MailType := MailType::JMail;
            //  TaskBatch."Mail Program"::SMTPMail:  MailType := MailType::SMTPMail;
            //END;

            //CreateMessage(TaskBatch."Mail Program", TaskBatch."Mail From Name", TaskBatch."Mail From Address",
            //              '', STRSUBSTNO(Text001, TaskLine.Description, TaskLog.Status), '');
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
                        if Exists(TaskOutputLog."File Name") then
                            AddAttachment(TaskOutputLog."File Name");
                    until TaskOutputLog.Next = 0;
            end;

            Send();
        end;
        //+TQ1.17
    end;

    local procedure SendMailOnSucces()
    var
        TaskOutputLog: Record "Task Output Log";
        FilesExists: Boolean;
        InStr: InStream;
    begin
        //-TQ1.17
        if not TaskLine."Send E-Mail (On Success)" then
            exit;

        TaskLineParm.SetRange("Field No.", 181);
        if TaskLineParm.IsEmpty then
            exit;

        if (TaskLine."Send Only if File Exists") and (TaskLine.GetLogEntryNo <> 0) then begin
            TaskOutputLog.SetRange("Task Log Entry No.", TaskLine.GetLogEntryNo);
            if TaskOutputLog.FindSet then
                repeat
                    TaskOutputLog.CalcFields(TaskOutputLog.File);
                    FilesExists := TaskOutputLog.File.HasValue;
                until (TaskOutputLog.Next = 0) or FilesExists;
            if not FilesExists then
                exit;
        end;

        //-TQ1.29
        //CreateMessage(TaskBatch."Mail Program", TaskBatch."Mail From Name", TaskBatch."Mail From Address",
        //              '', STRSUBSTNO(Text001, TaskLine.Description, TaskLog.Status), '');
        CreateMessage(0, TaskBatch."Mail From Name", TaskBatch."Mail From Address",
                      '', StrSubstNo(Text001, TaskLine.Description, TaskLog.Status), '');
        //+TQ1.29

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
                    if Exists(TaskOutputLog."File Name") then
                        AddAttachment(TaskOutputLog."File Name")
                    //-TQ1.29
                    else begin
                        TaskOutputLog.CalcFields(File);
                        if TaskOutputLog.File.HasValue then begin
                            TaskOutputLog.File.CreateInStream(InStr);
                            AddAttachmentFromStream(InStr, TaskOutputLog."File Name");
                        end;
                    end;
                //+TQ1.29
                until TaskOutputLog.Next = 0;
        end;

        Send();
        //+TQ1.17
    end;

    local procedure SendMailOnErrorRecovery()
    var
        TaskOutputLog: Record "Task Output Log";
    begin
        //-TQ1.17
        with TaskLine do begin
            if not "Send E-Mail (On Error)" or ("Last E-Mail After Error No." = 0) then
                exit;

            if "Error Counter" < "Last E-Mail After Error No." then
                exit;

            TaskLineParm.SetRange("Field No.", 176);
            if TaskLineParm.IsEmpty then
                exit;

            //-TQ1.29
            //CreateMessage(TaskBatch."Mail Program", TaskBatch."Mail From Name", TaskBatch."Mail From Address",
            //              '', STRSUBSTNO(Text008, TaskLine.Description, TaskLog.Status), '');
            CreateMessage(0, TaskBatch."Mail From Name", TaskBatch."Mail From Address",
                          '', StrSubstNo(Text008, TaskLine.Description, TaskLog.Status), '');
            //+TQ1.29

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
                        if Exists(TaskOutputLog."File Name") then
                            AddAttachment(TaskOutputLog."File Name");
                    until TaskOutputLog.Next = 0;
            end;

            Send();
        end;
        //+TQ1.17
    end;

    procedure OpenNewMessage(SendAsMailType: Option Auto,JMail,SMTPMail; ToName: Text[80]): Boolean
    var
        SMTPMailSetup: Record "SMTP Mail Setup";
        Recipients: List of [Text];
    begin
        //-TQ1.17
        if SendAsMailType = SendAsMailType::Auto then begin
            if SMTPMailSetup.Get and (SMTPMailSetup."SMTP Server" <> '') then
                SendAsMailType := SendAsMailType::SMTPMail
            else
                SendAsMailType := SendAsMailType::JMail;
        end;

        //-TQ1.29
        //MailType := SendAsMailType;
        //CASE MailType OF
        //  MailType::SMTPMail:
        //    BEGIN
        //      CLEAR(SMTPMail);
        //      SMTPMail.CreateMessage(ToName, '', '', '', '', TRUE);
        //    END;
        //  MailType::JMail:
        //    BEGIN
        //      //JMail.OpenNewMessage(ToName);
        //      //+TQ1.29
        //    END;
        // END;
        //+TQ1.17
        Clear(SMTPMail);
        SMTPMail.CreateMessage(ToName, '', Recipients, '', '', true);
        //+TQ1.29
    end;

    procedure CreateMessage(SendAsMailType: Option Auto,JMail,SMTPMail; SenderName: Text[100]; SenderAddress: Text[50]; Recipients: Text[1024]; Subject: Text[200]; Body: Text[1024])
    var
        SMTPMailSetup: Record "SMTP Mail Setup";
        Separators: List of [Text];
    begin
        //-TQ1.17
        if SendAsMailType = SendAsMailType::Auto then begin
            if SMTPMailSetup.Get and (SMTPMailSetup."SMTP Server" <> '') then
                SendAsMailType := SendAsMailType::SMTPMail
            else
                SendAsMailType := SendAsMailType::JMail;
        end;

        //-TQ1.29
        // MailType := SendAsMailType;
        // CASE MailType OF
        //  MailType::SMTPMail:
        //    BEGIN
        //      CLEAR(SMTPMail);
        //      SMTPMail.CreateMessage(SenderName, SenderAddress, Recipients, Subject, Body, TRUE);
        //    END;
        //  MailType::JMail:
        //    BEGIN
        //      //JMail.CreateMessage(SenderName, SenderAddress, Recipients, Subject, Body);
        //      //+TQ1.29
        //    END;
        // END;
        //+TQ1.17
        Clear(SMTPMail);
        InitMailAdrSeparators(Separators);
        SMTPMail.CreateMessage(SenderName, SenderAddress, Recipients.Split(Separators), Subject, Body, true);
        //+TQ1.29
    end;

    procedure CreateMessage2(SendAsMailType: Option Auto,JMail,SMTPMail; Subject: Text[200]; TaskLine2: Record "Task Line")
    var
        SMTPMailSetup: Record "SMTP Mail Setup";
    begin
        //-TQ1.19
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

        if TaskLineParm.FindFirst then
            repeat
                AddRecipient(TaskLineParm.Value);
            until TaskLineParm.Next = 0;

        TaskLineParm.SetRange("Field No.", 186);
        if TaskLineParm.FindFirst then
            repeat
                AddRecipientCC(TaskLineParm.Value);
            until TaskLineParm.Next = 0;

        TaskLineParm.SetRange("Field No.", 187);
        if TaskLineParm.FindFirst then
            repeat
                AddRecipientBCC(TaskLineParm.Value);
            until TaskLineParm.Next = 0;
        //+TQ1.19
    end;

    procedure AddRecipient(NewRecipient: Text[80])
    var
        Recipients: List of [Text];
        Separators: List of [Text];
    begin
        //-TQ1.17
        //-TQ1.29
        //CASE MailType OF
        //  MailType::SMTPMail: SMTPMail.AddRecipients(NewRecipient);
        //MailType::JMail:    JMail.AddRecipient(NewRecipient);
        //END;
        //+TQ1.17
        InitMailAdrSeparators(Separators);
        Recipients := NewRecipient.Split(Separators);
        SMTPMail.AddRecipients(Recipients);
        //+TQ1.29
    end;

    procedure AddRecipientCC(NewRecipientCC: Text[80])
    var
        CCRecipients: List of [Text];
        Separators: List of [Text];
    begin
        //-TQ1.17
        //-TQ1.29
        // CASE MailType OF
        //  MailType::SMTPMail: SMTPMail.AddCC(NewRecipientCC);
        //  MailType::JMail:    JMail.AddRecipientCC(NewRecipientCC);
        // END;
        InitMailAdrSeparators(Separators);
        CCRecipients := NewRecipientCC.Split(Separators);
        SMTPMail.AddCC(CCRecipients);
        //+TQ1.29
        //+TQ1.17
    end;

    procedure AddRecipientBCC(NewRecipientBCC: Text[80])
    var
        BCCRecipients: List of [Text];
        Separators: List of [Text];
    begin
        //-TQ1.17
        //-TQ1.29
        // CASE MailType OF
        //  MailType::SMTPMail: SMTPMail.AddBCC(NewRecipientBCC);
        //  MailType::JMail:    JMail.AddRecipientBCC(NewRecipientBCC);
        // END;
        InitMailAdrSeparators(Separators);
        BCCRecipients := NewRecipientBCC.Split(Separators);
        SMTPMail.AddBCC(BCCRecipients);
        //+TQ1.29
        //+TQ1.17
    end;

    procedure AppendHTML(TextLine: Text[260]): Boolean
    begin
        //-TQ1.17
        //-TQ1.29
        // CASE MailType OF
        //  MailType::SMTPMail: SMTPMail.AppendBody(TextLine + '<br/>');
        //  MailType::JMail:    JMail.AppendHTML(TextLine);
        // END;
        SMTPMail.AppendBody(TextLine + '<br/>');
        //+TQ1.29
        //+TQ1.17
    end;

    procedure AddAttachment(NewAttachment: Text[1024])
    begin
        //-TQ1.17
        //-TQ1.29
        // CASE MailType OF
        //  //-TQ1.27
        //  //MailType::SMTPMail: SMTPMail.AddAttachment(NewAttachment);
        //  MailType::SMTPMail: SMTPMail.AddAttachment(NewAttachment,NewAttachment);
        //  //+TQ1.27
        //  MailType::JMail:    JMail.AddAttachment(NewAttachment);
        // END;
        //+TQ1.29
        SMTPMail.AddAttachment(NewAttachment, NewAttachment);
        //+TQ1.17
    end;

    procedure AddAttachmentFromStream(InStrAttachment: InStream; NewAttachment: Text[1024])
    begin
        //-TQ1.29
        SMTPMail.AddAttachmentStream(InStrAttachment, NewAttachment);
        //+TQ1.29
    end;

    procedure Send() MailSent: Boolean
    begin
        //-TQ1.29
        // CASE MailType OF
        //  MailType::SMTPMail: SMTPMail.Send;
        //  MailType::JMail: EXIT(JMail.Send);
        // END;
        SMTPMail.Send;
        //+TQ1.29
        exit(true);
    end;

    local procedure InitMailAdrSeparators(var MailAdrSeparators: List of [Text])
    begin
        MailAdrSeparators.Add(';');
        MailAdrSeparators.Add(',');
    end;
}

