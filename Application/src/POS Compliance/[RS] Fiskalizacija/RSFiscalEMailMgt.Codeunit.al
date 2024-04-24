codeunit 6059934 "NPR RS Fiscal E-Mail Mgt."
{
    Access = Internal;
    TableNo = "NPR RS POS Audit Log Aux. Info";

    var
        Attachments: Codeunit "Temp Blob List";
        _AttachementsNotCreatedErr: Label 'Attachement(s) not created.';
        _AttachmentFileName1: Label 'Fiscal Bill Invoice_%1.pdf', Comment = '%1 - specifies Document No. or POS Entry No. depending on Entry Type';
        _AttachmentFileName2: Label 'Fiscal Bill Receipt_%1.pdf', Comment = '%1 - specifies Document No. or POS Entry No. depending on Entry Type';
        _EmailAccountNotFoundErr: Label 'E-Mail Account is not set up.';
        _EMailBodyLbl: Label 'You can validate your QR Code here: %1', Comment = '%1 - specifies the HTML formatted text';
        _EmailSendingErr: Label 'Error occurred on E-Mail sending. For more information check Email Outbox.';
        _EMailSubjectLbl: Label 'Fiscal Bill for your Purchase Order';
        _LinkedText: Label 'Verification URL', Comment = '%1 - specifies the linked text';
        _LinkedTextHtmlLbl: Label '<a href="%1">%2</a>', Comment = '%1 - specifies the value of Verification URL field from NPR RS POS Audit Log Aux. Info table, %2 -  specifies the linked text', Locked = true;
        _RecipientEmailAddrNotFoundErr: Label 'Recipient E-mail address is not found.';
        _ReportIsNotSavedErr: Label 'Report %1 is not saved.', Comment = '%1 - specifies Report Caption';
        AttachmentNames: List of [Text];

    trigger OnRun()
    begin
        SendFiscalBillViaEmail(Rec);
    end;

    procedure SendFiscalBillViaEmail(RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info")
    var
        TempEmailItem: Record "Email Item" temporary;
        ErrorMessage: Text;
    begin
        ErrorMessage := CreateAndSendEmailMessage(TempEmailItem, RSPOSAuditLogAuxInfo, RSPOSAuditLogAuxInfo."Email-To");
        LogEmailSendingInfo(TempEmailItem, RSPOSAuditLogAuxInfo, ErrorMessage);
    end;

    procedure SendFiscalBillViaEmail(RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info"; RecipientEmail: Text): Text
    var
        TempEmailItem: Record "Email Item" temporary;
        ErrorMessage: Text;
    begin
        ErrorMessage := CreateAndSendEmailMessage(TempEmailItem, RSPOSAuditLogAuxInfo, RecipientEmail);
        LogEmailSendingInfo(TempEmailItem, RSPOSAuditLogAuxInfo, ErrorMessage);
    end;

    local procedure CreateAndSendEmailMessage(var TempEmailItem: Record "Email Item" temporary; RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info"; RecipientEmail: Text): Text
    var
        EmailAccount: Record "Email Account";
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        EmailScenarios: Codeunit "Email Scenario";
        ErrorMessage: Text;
    begin
        InitializeEmailItem(TempEmailItem);
        RSFiscalizationSetup.Get();

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

        TempEmailItem.SetBodyText(StrSubstNo(_EMailBodyLbl, StrSubstNo(_LinkedTextHtmlLbl, RSPOSAuditLogAuxInfo."Verification URL", _LinkedText)));
        if RSFiscalizationSetup."E-Mail Subject" <> '' then
            TempEmailItem.Subject := RSFiscalizationSetup."E-Mail Subject"
        else
            TempEmailItem.Subject := _EMailSubjectLbl;

        TempEmailItem.Modify();

        ErrorMessage := CreateAttachments(RSPOSAuditLogAuxInfo);

        if ErrorMessage <> '' then
            exit(ErrorMessage);

        ErrorMessage := SendMail(TempEmailItem);

        if ErrorMessage <> '' then
            exit(ErrorMessage);
    end;

    #region Attachment creation
    local procedure CreateAttachments(RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info"): Text
    var
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
        RecRef: RecordRef;
        ErrorMessage: Text;
        FiscalBillA4v1Filename: Text;
        FiscalBillA4v2Filename: Text;
    begin
        RSFiscalizationSetup.Get();
        RecRef.GetTable(RSPOSAuditLogAuxInfo);
        RecRef.SetRecFilter();

        FiscalBillA4v1Filename := StrSubstNo(_AttachmentFileName1, RSPOSAuditLogAuxInfo."Invoice Counter");
        FiscalBillA4v2Filename := StrSubstNo(_AttachmentFileName2, RSPOSAuditLogAuxInfo."Invoice Counter");

        case RSFiscalizationSetup."Report E-Mail Selection" of
            "NPR RS Report E-Mail Selection"::"Fiscal Bill A4":
                ErrorMessage := CreateAttachment(Report::"NPR RS Fiscal Bill A4 v1", FiscalBillA4v1Filename, RSPOSAuditLogAuxInfo);
            "NPR RS Report E-Mail Selection"::"Thermal printing receipt":
                ErrorMessage := CreateAttachment(Report::"NPR RS Fiscal Bill A4 V2", FiscalBillA4v2Filename, RSPOSAuditLogAuxInfo);
            "NPR RS Report E-Mail Selection"::Both:
                begin
                    ErrorMessage := CreateAttachment(Report::"NPR RS Fiscal Bill A4 v1", FiscalBillA4v1Filename, RSPOSAuditLogAuxInfo);
                    ErrorMessage += CreateAttachment(Report::"NPR RS Fiscal Bill A4 V2", FiscalBillA4v2Filename, RSPOSAuditLogAuxInfo);
                end;
        end;

        if ErrorMessage <> '' then
            exit(ErrorMessage);

        if Attachments.Count() = 0 then
            exit(_AttachementsNotCreatedErr);
    end;

    local procedure CreateAttachment(ReportId: Integer; Filename: Text; RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info"): Text
    var
        RSFiscalBillA4v1: Report "NPR RS Fiscal Bill A4 v1";
        RSFiscalBillA4V2: Report "NPR RS Fiscal Bill A4 V2";
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        InStr: InStream;
        OutStr: OutStream;
    begin
        RecRef.GetTable(RSPOSAuditLogAuxInfo);
        RecRef.SetRecFilter();
        TempBlob.CreateOutStream(OutStr);

        case ReportId of
            Report::"NPR RS Fiscal Bill A4 v1":
                begin
                    RSFiscalBillA4v1.SetFilters(RSPOSAuditLogAuxInfo."Audit Entry Type", RSPOSAuditLogAuxInfo."POS Entry No.", RSPOSAuditLogAuxInfo."Source Document No.", RSPOSAuditLogAuxInfo."Source Document Type");
                    if not RSFiscalBillA4v1.SaveAs('', ReportFormat::Pdf, OutStr, RecRef) then
                        exit(StrSubstNo(_ReportIsNotSavedErr, RSFiscalBillA4v1.ObjectId(true)));
                end;
            Report::"NPR RS Fiscal Bill A4 V2":
                begin
                    RSFiscalBillA4V2.SetFilters(RSPOSAuditLogAuxInfo."Audit Entry Type", RSPOSAuditLogAuxInfo."POS Entry No.", RSPOSAuditLogAuxInfo."Source Document No.", RSPOSAuditLogAuxInfo."Source Document Type");
                    if not RSFiscalBillA4V2.SaveAs('', ReportFormat::Pdf, OutStr, RecRef) then
                        exit(StrSubstNo(_ReportIsNotSavedErr, RSFiscalBillA4v1.ObjectId(true)));
                end;
        end;

        TempBlob.CreateInStream(InStr);

        if TempBlob.HasValue() then
            AddAttachment(InStr, Filename);
    end;

    #endregion

    #region E-Mail Sending Logging

    local procedure LogEmailSendingInfo(var TempEmailItem: Record "Email Item" temporary; RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info"; ErrorMessage: Text)
    var
        RSFiscalEMailLog: Record "NPR RS Fiscal E-Mail Log";
        Element: Text;
        FilenameText: Text;
    begin
        RSFiscalEMailLog.Init();
        RSFiscalEMailLog."Audit Entry Type" := RSPOSAuditLogAuxInfo."Audit Entry Type";
        RSFiscalEMailLog."Audit Entry No." := RSPOSAuditLogAuxInfo."Audit Entry No.";
        foreach Element in AttachmentNames do
            FilenameText += Element + ';';
        if FilenameText <> '' then
            RSFiscalEMailLog.Filename := CopyStr(FilenameText, 1, MaxStrLen(RSFiscalEMailLog.Filename));
        RSFiscalEMailLog."From E-mail" := TempEmailItem."From Address";
        RSFiscalEMailLog."Recipient E-mail" := TempEmailItem."Send to";
        RSFiscalEMailLog."E-mail subject" := CopyStr(TempEmailItem.Subject, 1, MaxStrLen(RSFiscalEMailLog."E-mail subject"));
        RSFiscalEMailLog."Sent Date" := Today();
        RSFiscalEMailLog."Sent Time" := Time();
        RSFiscalEMailLog."Sent Username" := CopyStr(UserId(), 1, MaxStrLen(RSFiscalEMailLog."Sent Username"));
        RSFiscalEMailLog.Successful := ErrorMessage = '';
        if ErrorMessage <> '' then
            RSFiscalEMailLog."Error Message" := CopyStr(ErrorMessage, 1, MaxStrLen(RSFiscalEMailLog."Error Message"));
        RSFiscalEMailLog.Insert();
    end;

    #endregion

    #region Email Sending
#if BC17
    local procedure SendMail(var TempEmailItem: Record "Email Item" temporary): Text
    var
        SMTPMail: Codeunit "SMTP Mail";
        Recipients: List of [Text];
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        Index: Integer;
    begin
        Recipients.Add(TempEmailItem."Send to");
        SMTPMail.CreateMessage(TempEmailItem."From Name", TempEmailItem."From Address", Recipients, TempEmailItem.Subject, GetBodyText(TempEmailItem), true);

        for Index := 1 to Attachments.Count() do begin
            Clear(TempBlob);
            Attachments.Get(Index, TempBlob);
            TempBlob.CreateInStream(InStr);
            SMTPMail.AddAttachmentStream(InStr, CopyStr(AttachmentNames.Get(Index), 1, 250));
        end;

        if not SMTPMail.Send() then
            exit(_EmailSendingErr);
    end;
#else
    local procedure SendMail(var TempEmailItem: Record "Email Item" temporary): Text
    var
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        Index: Integer;
    begin
        EmailMessage.Create(TempEmailItem."Send to", TempEmailItem.Subject, GetBodyText(TempEmailItem), true);
        for Index := 1 to Attachments.Count() do begin
            Clear(TempBlob);
            Attachments.Get(Index, TempBlob);
            TempBlob.CreateInStream(InStr);
            EmailMessage.AddAttachment(CopyStr(AttachmentNames.Get(Index), 1, 250), 'PDF', InStr);
        end;

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

    local procedure AddAttachment(AttachmentStream: InStream; AttachmentName: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
    begin
        if AttachmentStream.EOS() then
            exit;
        TempBlob.CreateOutStream(OutStream);
        CopyStream(OutStream, AttachmentStream);
        Attachments.Add(TempBlob);
        AttachmentNames.Add(AttachmentName);
    end;
}