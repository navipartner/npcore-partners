codeunit 6248213 "NPR CRO Fiscal E-Mail Mgt."
{
    Access = Internal;
    TableNo = "NPR CRO POS Aud. Log Aux. Info";

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

    procedure SendFiscalBillViaEmail(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    var
        TempEmailItem: Record "Email Item" temporary;
        ErrorMessage: Text;
    begin
        ErrorMessage := CreateAndSendEmailMessage(TempEmailItem, CROPOSAuditLogAuxInfo, CROPOSAuditLogAuxInfo."Email-To");
        LogEmailSendingInfo(TempEmailItem, CROPOSAuditLogAuxInfo, ErrorMessage);
    end;

    procedure SendFiscalBillViaEmail(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; RecipientEmail: Text): Text
    var
        TempEmailItem: Record "Email Item" temporary;
        ErrorMessage: Text;
    begin
        ErrorMessage := CreateAndSendEmailMessage(TempEmailItem, CROPOSAuditLogAuxInfo, RecipientEmail);
        LogEmailSendingInfo(TempEmailItem, CROPOSAuditLogAuxInfo, ErrorMessage);
    end;

    local procedure CreateAndSendEmailMessage(var TempEmailItem: Record "Email Item" temporary; CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; RecipientEmail: Text): Text
    var
        EmailAccount: Record "Email Account";
        CROFiscalizationSetup: Record "NPR CRO Fiscalization Setup";
        EmailScenarios: Codeunit "Email Scenario";
        ErrorMessage: Text;
    begin
        InitializeEmailItem(TempEmailItem);
        CROFiscalizationSetup.Get();

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

        TempEmailItem.SetBodyText(StrSubstNo(_EmailBodyTxt, CROPOSAuditLogAuxInfo."Bill No."));
        if CROFiscalizationSetup."E-Mail Subject" <> '' then
            TempEmailItem.Subject := CROFiscalizationSetup."E-Mail Subject"
        else
            TempEmailItem.Subject := _EMailSubjectLbl;

        TempEmailItem.Modify();

        ErrorMessage := CreateAttachment(CROPOSAuditLogAuxInfo);

        if ErrorMessage <> '' then
            exit(ErrorMessage);

        ErrorMessage := SendMail(TempEmailItem);

        if ErrorMessage <> '' then
            exit(ErrorMessage);
    end;

    #region Attachment creation
    local procedure CreateAttachment(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"): Text
    var
        CROFiscalizationSetup: Record "NPR CRO Fiscalization Setup";
        CROFiscalBillA4: Report "NPR CRO Fiscal Bill A4";
        RecRef: RecordRef;
        OutStr: OutStream;
        AttachmentInStream: InStream;
        AttachementNotCreatedErr: Label 'Attachement is not created.';
        ReportIsNotSavedErr: Label 'Report %1 is not saved.', Comment = '%1 = Report Caption';
        AttachmentFileNameFormat: Label 'Fiscal_Bill_%1.pdf', Comment = '%1 = Bill No.';
    begin
        CROFiscalizationSetup.Get();
        RecRef.GetTable(CROPOSAuditLogAuxInfo);
        RecRef.SetRecFilter();

        _AttachmentTempBlob.CreateOutStream(OutStr);

        CROFiscalBillA4.SetFilters(CROPOSAuditLogAuxInfo."Audit Entry Type", CROPOSAuditLogAuxInfo."Audit Entry No.", CROPOSAuditLogAuxInfo."Source Document No.");
        if not CROFiscalBillA4.SaveAs('', ReportFormat::Pdf, OutStr, RecRef) then
            exit(StrSubstNo(ReportIsNotSavedErr, CROFiscalBillA4.ObjectId(true)));

        _AttachmentTempBlob.CreateInStream(AttachmentInStream);

        if not _AttachmentTempBlob.HasValue() then
            exit(AttachementNotCreatedErr);

        _AttachmentName := StrSubstNo(AttachmentFileNameFormat, CROPOSAuditLogAuxInfo."Bill No.");
    end;

    #endregion

    #region E-Mail Sending Logging

    local procedure LogEmailSendingInfo(var TempEmailItem: Record "Email Item" temporary; CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; ErrorMessage: Text)
    var
        CROFiscalEMailLog: Record "NPR CRO Fiscal E-Mail Log";
    begin
        CROFiscalEMailLog.Init();
        CROFiscalEMailLog."Audit Entry Type" := CROPOSAuditLogAuxInfo."Audit Entry Type";
        CROFiscalEMailLog."Audit Entry No." := CROPOSAuditLogAuxInfo."Audit Entry No.";
        CROFiscalEMailLog.Filename := CopyStr(_AttachmentName, 1, MaxStrLen(CROFiscalEMailLog.Filename));
        CROFiscalEMailLog."Sender E-mail" := TempEmailItem."From Address";
        CROFiscalEMailLog."Recipient E-mail" := TempEmailItem."Send to";
        CROFiscalEMailLog."E-mail Subject" := CopyStr(TempEmailItem.Subject, 1, MaxStrLen(CROFiscalEMailLog."E-mail Subject"));
        CROFiscalEMailLog."Sending Date" := Today();
        CROFiscalEMailLog."Sending Time" := Time();
        CROFiscalEMailLog."Sent by" := CopyStr(UserId(), 1, MaxStrLen(CROFiscalEMailLog."Sent by"));
        CROFiscalEMailLog.Successful := ErrorMessage = '';
        if ErrorMessage <> '' then
            CROFiscalEMailLog."Error Message" := CopyStr(ErrorMessage, 1, MaxStrLen(CROFiscalEMailLog."Error Message"));
        CROFiscalEMailLog.Insert();
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

    internal procedure TrySendFiscalBillForInvoice(SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        TempEmailItem: Record "Email Item" temporary;
        ErrorMessage: Text;
    begin
        CROPOSAuditLogAuxInfo.SetRange("Source Document No.", SalesInvoiceHeader."No.");
        CROPOSAuditLogAuxInfo.SetRange("Audit Entry Type", CROPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Invoice");
        CROPOSAuditLogAuxInfo.SetRange("Fiscal Bill E-Mails", false);
        if not CROPOSAuditLogAuxInfo.FindFirst() then
            exit(false);
        ErrorMessage := CreateAndSendEmailMessage(TempEmailItem, CROPOSAuditLogAuxInfo, CROPOSAuditLogAuxInfo."Email-To");
        LogEmailSendingInfo(TempEmailItem, CROPOSAuditLogAuxInfo, ErrorMessage);
        if ErrorMessage <> '' then
            exit(false);
        exit(true);
    end;
}