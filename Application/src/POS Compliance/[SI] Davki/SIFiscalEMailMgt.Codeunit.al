codeunit 6150672 "NPR SI Fiscal E-Mail Mgt."
{
    Access = Internal;
    TableNo = "NPR SI POS Audit Log Aux. Info";

    var
        _AttachmentTempBlob: Codeunit "Temp Blob";
        _EmailAccountNotFoundErr: Label 'E-Mail Account is not set up.';
        _EmailSendingErr: Label 'Error occurred on E-Mail sending. For more information check Email Outbox.';
        _EMailSubjectLbl: Label 'Fiscal Receipt for your Purchase';
        _RecipientEmailAddrNotFoundErr: Label 'Recipient E-mail address is not found.';
        _EmailBodyTxt: Label '<div style="max-width: 600px; margin: 20px auto; background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); padding: 20px;"> <p style="color: Gray; font-size: 18px; margin: 0 0 10px;">Thank you for shopping.</p> <p style="color: Gray; font-size: 16px; margin: 0;">The fiscal receipt %1 for your purchase is attached in this email.</p> </div>', Locked = true, Comment = '%1 = Fiscal Bill No.';
        _AttachmentName: Text;

    trigger OnRun()
    begin
        SendFiscalBillViaEmail(Rec);
    end;

    procedure SendFiscalBillViaEmail(SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    var
        TempEmailItem: Record "Email Item" temporary;
        ErrorMessage: Text;
    begin
        ErrorMessage := CreateAndSendEmailMessage(TempEmailItem, SIPOSAuditLogAuxInfo, SIPOSAuditLogAuxInfo."Email-To");
        LogEmailSendingInfo(TempEmailItem, SIPOSAuditLogAuxInfo, ErrorMessage);
    end;

    procedure SendFiscalBillViaEmail(SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; RecipientEmail: Text): Text
    var
        TempEmailItem: Record "Email Item" temporary;
        ErrorMessage: Text;
    begin
        ErrorMessage := CreateAndSendEmailMessage(TempEmailItem, SIPOSAuditLogAuxInfo, RecipientEmail);
        LogEmailSendingInfo(TempEmailItem, SIPOSAuditLogAuxInfo, ErrorMessage);
    end;

    local procedure CreateAndSendEmailMessage(var TempEmailItem: Record "Email Item" temporary; SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; RecipientEmail: Text): Text
    var
        EmailAccount: Record "Email Account";
        SIFiscalizationSetup: Record "NPR SI Fiscalization Setup";
        EmailScenarios: Codeunit "Email Scenario";
        ErrorMessage: Text;
    begin
        InitializeEmailItem(TempEmailItem);
        SIFiscalizationSetup.Get();

        if not EmailScenarios.GetEmailAccount(Enum::"Email Scenario"::Default, EmailAccount) then
            exit(_EmailAccountNotFoundErr);

        TempEmailItem."From Address" := EmailAccount."Email Address";
        TempEmailItem."From Name" := CopyStr(EmailAccount.Name, 1, MaxStrLen(TempEmailItem."From Name"));

        TempEmailItem.Modify();

        if RecipientEmail = '' then
            exit(_RecipientEmailAddrNotFoundErr);
#pragma warning disable AA0139
        TempEmailItem."Send to" := RecipientEmail;
#pragma warning restore
        TempEmailItem.Modify();

        TempEmailItem.SetBodyText(StrSubstNo(_EmailBodyTxt, SIPOSAuditLogAuxInfo."Receipt No."));
        if SIFiscalizationSetup."E-Mail Subject" <> '' then
            TempEmailItem.Subject := SIFiscalizationSetup."E-Mail Subject"
        else
            TempEmailItem.Subject := _EMailSubjectLbl;

        TempEmailItem.Modify();

        ErrorMessage := CreateAttachment(SIPOSAuditLogAuxInfo);

        if ErrorMessage <> '' then
            exit(ErrorMessage);

        ErrorMessage := SendMail(TempEmailItem);

        if ErrorMessage <> '' then
            exit(ErrorMessage);
    end;

    #region Attachment creation
    local procedure CreateAttachment(SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"): Text
    var
        SIFiscalizationSetup: Record "NPR SI Fiscalization Setup";
        SIFiscalBillA4: Report "NPR SI Fiscal Bill A4";
        RecRef: RecordRef;
        OutStr: OutStream;
        AttachmentInStream: InStream;
        AttachementNotCreatedErr: Label 'Attachement is not created.';
        ReportIsNotSavedErr: Label 'Report %1 is not saved.', Comment = '%1 = Report Caption';
        AttachmentFileNameFormat: Label 'Fiscal_Receipt_%1.pdf', Comment = '%1 = Receipt No.';
    begin
        SIFiscalizationSetup.Get();
        RecRef.GetTable(SIPOSAuditLogAuxInfo);
        RecRef.SetRecFilter();

        _AttachmentTempBlob.CreateOutStream(OutStr);

        SIFiscalBillA4.SetFilters(SIPOSAuditLogAuxInfo."Audit Entry Type", SIPOSAuditLogAuxInfo."Audit Entry No.", SIPOSAuditLogAuxInfo."Source Document No.");
        if not SIFiscalBillA4.SaveAs('', ReportFormat::Pdf, OutStr, RecRef) then
            exit(StrSubstNo(ReportIsNotSavedErr, SIFiscalBillA4.ObjectId(true)));

        _AttachmentTempBlob.CreateInStream(AttachmentInStream);

        if not _AttachmentTempBlob.HasValue() then
            exit(AttachementNotCreatedErr);

        _AttachmentName := StrSubstNo(AttachmentFileNameFormat, SIPOSAuditLogAuxInfo."Receipt No.");
    end;

    #endregion

    #region E-Mail Sending Logging

    local procedure LogEmailSendingInfo(var TempEmailItem: Record "Email Item" temporary; SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; ErrorMessage: Text)
    var
        SIFiscalEMailLog: Record "NPR SI Fiscal E-Mail Log";
    begin
        SIFiscalEMailLog.Init();
        SIFiscalEMailLog."Audit Entry Type" := SIPOSAuditLogAuxInfo."Audit Entry Type";
        SIFiscalEMailLog."Audit Entry No." := SIPOSAuditLogAuxInfo."Audit Entry No.";
        SIFiscalEMailLog.Filename := CopyStr(_AttachmentName, 1, MaxStrLen(SIFiscalEMailLog.Filename));
        SIFiscalEMailLog."Sender E-mail" := TempEmailItem."From Address";
        SIFiscalEMailLog."Recipient E-mail" := TempEmailItem."Send to";
        SIFiscalEMailLog."E-mail Subject" := CopyStr(TempEmailItem.Subject, 1, MaxStrLen(SIFiscalEMailLog."E-mail Subject"));
        SIFiscalEMailLog."Sending Date" := Today();
        SIFiscalEMailLog."Sending Time" := Time();
        SIFiscalEMailLog."Sent by" := CopyStr(UserId(), 1, MaxStrLen(SIFiscalEMailLog."Sent by"));
        SIFiscalEMailLog.Successful := ErrorMessage = '';
        if ErrorMessage <> '' then
            SIFiscalEMailLog."Error Message" := CopyStr(ErrorMessage, 1, MaxStrLen(SIFiscalEMailLog."Error Message"));
        SIFiscalEMailLog.Insert();
    end;

    #endregion

    #region Email Sending
#if BC17
    local procedure SendMail(var TempEmailItem: Record "Email Item" temporary): Text
    var
        SMTPMail: Codeunit "SMTP Mail";
        Recipients: List of [Text];
        AttachmentInStream: InStream;
    begin
        Recipients.Add(TempEmailItem."Send to");
        SMTPMail.CreateMessage(TempEmailItem."From Name", TempEmailItem."From Address", Recipients, TempEmailItem.Subject, GetBodyText(TempEmailItem), true);

        _AttachmentTempBlob.CreateInStream(AttachmentInStream);
        SMTPMail.AddAttachmentStream(AttachmentInStream, CopyStr(_AttachmentName, 1, 250));

        if not SMTPMail.Send() then
            exit(_EmailSendingErr);
    end;
#else
    local procedure SendMail(var TempEmailItem: Record "Email Item" temporary): Text
    var
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        AttachmentInStream: InStream;
    begin
        EmailMessage.Create(TempEmailItem."Send to", TempEmailItem.Subject, GetBodyText(TempEmailItem), true);

        _AttachmentTempBlob.CreateInStream(AttachmentInStream);
        EmailMessage.AddAttachment(CopyStr(_AttachmentName, 1, 250), 'PDF', AttachmentInStream);

        if not Email.Send(EmailMessage, Enum::"Email Scenario"::Default) then
            exit(_EmailSendingErr);
    end;
#endif

    local procedure InitializeEmailItem(var TempEmailItem: Record "Email Item" temporary)
    begin
        TempEmailItem.DeleteAll();
        TempEmailItem.Initialize();
        TempEmailItem.Insert();
    end;
    #endregion

    local procedure GetBodyText(var TempEmailItem: Record "Email Item" temporary): Text
    var
        BodyText: BigText;
        InStr: InStream;
        Value: Text;
    begin
        if not TempEmailItem.Body.HasValue() then
            exit;

        TempEmailItem.Body.CreateInStream(InStr, TextEncoding::UTF8);
        BodyText.Read(InStr);
        BodyText.GetSubText(Value, 1);
        exit(Value);
    end;
}