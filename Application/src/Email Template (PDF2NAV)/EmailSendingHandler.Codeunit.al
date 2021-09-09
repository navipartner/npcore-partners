codeunit 6014553 "NPR Email Sending Handler"
{
    procedure CreateEmailItem(var EmailItem: Record "Email Item"; FromName: Text; FromAddress: Text; Recipients: List of [Text]; Subject: Text; Body: Text; HtmlFormat: Boolean)
    var
        i: Integer;
        RecipientsText: Text;
        RecipientsCCText: Text;
        RecValue: Text;
    begin
        EmailItem.Initialize();
        if HtmlFormat then begin
            EmailItem.Validate("Plaintext Formatted", false);
            EmailItem.Validate("Message Type", EmailItem."Message Type"::"From Email Body Template");
        end else begin
            EmailItem.Validate("Plaintext Formatted", true);
            EmailItem.Validate("Message Type", EmailItem."Message Type"::"Custom Message");
        end;
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

    procedure AddSubject(var EmailItem: Record "Email Item"; Subject: Text[250])
    begin
        EmailItem.Validate(Subject, Subject);
        EmailItem.Modify();
    end;

    procedure AddAttachmentFromStream(var EmailItem: Record "Email Item"; InStr: InStream; FileName: Text[1024])
    var
#if BC17
        TempAttachment: Record Attachment temporary;
        TempBLOB: Codeunit "Temp Blob";
        Outstr: OutStream;
#endif
    begin
#if BC17
        TempBLOB.CreateOutStream(Outstr);
        CopyStream(Outstr, InStr);
        TempAttachment.SetAttachmentFileFromBlob(TempBLOB);
        TempAttachment."Attachment File".Export(FileName);
        case true of
            EmailItem."Attachment File Path" = '':
                begin
                    EmailItem."Attachment File Path" := CopyStr(FileName, 1, MaxStrLen(EmailItem."Attachment File Path"));
                    EmailItem."Attachment Name" := CopyStr(FileName, 1, MaxStrLen(EmailItem."Attachment Name"));
                end;
            EmailItem."Attachment File Path 2" = '':
                begin
                    EmailItem."Attachment File Path 2" := CopyStr(FileName, 1, MaxStrLen(EmailItem."Attachment File Path 2"));
                    EmailItem."Attachment Name 2" := CopyStr(FileName, 1, MaxStrLen(EmailItem."Attachment Name 2"));
                end;
            EmailItem."Attachment File Path 3" = '':
                begin
                    EmailItem."Attachment File Path 3" := CopyStr(FileName, 1, MaxStrLen(EmailItem."Attachment File Path 3"));
                    EmailItem."Attachment Name 3" := CopyStr(FileName, 1, MaxStrLen(EmailItem."Attachment Name 3"));
                end;
            EmailItem."Attachment File Path 4" = '':
                begin
                    EmailItem."Attachment File Path 4" := CopyStr(FileName, 1, MaxStrLen(EmailItem."Attachment File Path 4"));
                    EmailItem."Attachment Name 4" := CopyStr(FileName, 1, MaxStrLen(EmailItem."Attachment Name 4"));
                end;
            EmailItem."Attachment File Path 5" = '':
                begin
                    EmailItem."Attachment File Path 5" := CopyStr(FileName, 1, MaxStrLen(EmailItem."Attachment File Path 5"));
                    EmailItem."Attachment Name 5" := CopyStr(FileName, 1, MaxStrLen(EmailItem."Attachment Name 5"));
                end;
            EmailItem."Attachment File Path 6" = '':
                begin
                    EmailItem."Attachment File Path 6" := CopyStr(FileName, 1, MaxStrLen(EmailItem."Attachment File Path 6"));
                    EmailItem."Attachment Name 6" := CopyStr(FileName, 1, MaxStrLen(EmailItem."Attachment Name 6"));
                end;
            EmailItem."Attachment File Path 7" = '':
                begin
                    EmailItem."Attachment File Path 7" := CopyStr(FileName, 1, MaxStrLen(EmailItem."Attachment File Path 7"));
                    EmailItem."Attachment Name 7" := CopyStr(FileName, 1, MaxStrLen(EmailItem."Attachment Name 7"));
                end;
        end;
        EmailItem.Modify();
#else
        EmailItem.AddAttachment(InStr, FileName);
#endif
    end;

    procedure AddRecipients(var EmailItem: Record "Email Item"; Recipients: List of [Text])
    var
        RecValue: Text;
        RecipientsText: Text;
        i: Integer;
    begin
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

    procedure AddRecipientCC(var EmailItem: Record "Email Item"; CCRecipients: List of [Text])
    var
        RecValue: Text;
        RecipientsText: Text;
        i: Integer;
    begin
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

    procedure AddRecipientBCC(var EmailItem: Record "Email Item"; BCCRecipients: List of [Text])
    var
        RecValue: Text;
        RecipientsText: Text;
        i: Integer;
    begin
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

    procedure AppendBodyLine(var EmailItem: Record "Email Item"; TextLine: Text): Boolean
    var
        InStr: InStream;
        BodyText: Text;
    begin
        EmailItem.CalcFields(Body);
        EmailItem.Body.CreateInStream(InStr);
        InStr.Read(BodyText);
        BodyText += TextLine;
        EmailItem.SetBodyText(BodyText);
        EmailItem.Modify();
    end;

    [TryFunction]
    procedure Send(EmailItem: Record "Email Item")
    var
        MailManagement: Codeunit "Mail Management";
        NotEnabledErr: Label 'Mail setup is not enabled.';
    begin
        if not MailManagement.IsEnabled() then
            Error(NotEnabledErr);

        MailManagement.SetHideMailDialog(true);
        MailManagement.Send(EmailItem, Enum::"Email Scenario"::Default);
        exit(true);
    end;

    procedure HtmlMessage(EmailItem: Record "Email Item"; IsHtml: Boolean)
    begin
        if IsHtml then begin
            EmailItem.Validate("Plaintext Formatted", false);
            EmailItem.Validate("Message Type", EmailItem."Message Type"::"From Email Body Template");
        end else begin
            EmailItem.Validate("Plaintext Formatted", true);
            EmailItem.Validate("Message Type", EmailItem."Message Type"::"Custom Message");
        end;
    end;

    procedure GetLastError(var ErrorMessage: Text)
    var
        ErrorMessageManagement: Codeunit "Error Message Management";
    begin
        ErrorMessageManagement.GetLastError(ErrorMessage);
    end;
}
