codeunit 6014450 "NPR E-mail Management"
{
    var

        Text001: Label 'Enter recipient''s e-mail address';
        Text002: Label 'E-mail has been sent.';
        Text003: Label 'The email may not be empty.';
        Text004: Label 'There is not entered any sender email address in the setup.';
        Text006: Label 'The functionality to save report %1 as PDF, returned an error.\\%2';
        ReqParamStoreDict: Dictionary of [Integer, Text];
        Text008: Label 'Smtp Mail Setup is not completed';
        Text010: Label 'Would you like to resend the e-mail?';
        Text011: Label 'E-mail Template was not found';
        Text012: Label 'Report ID is 0 which is why PDF can not be generated';
        SmtpMail: Codeunit "SMTP Mail";
        UseCustomReportSelection: Boolean;
        GlobalCustomReportSelection: Record "Custom Report Selection";
        AttachmentBuffer: Record "NPR E-mail Attachment" temporary;
        TransactionalType: Option " ",Smart,Classic;
        UseTransactionalEmailCode: Code[20];
        TransactionalEmailRecipient: Text;
        AttachmentNoData: Label 'No data in %1';
        NoOutputFromReport: Label 'No output from report.';

    procedure SendEmail(var RecRef: RecordRef; RecipientEmail: Text; Silent: Boolean) ErrorMessage: Text
    var
        EmailTemplateHeader: Record "NPR E-mail Template Header";
    begin
        exit(SendEmailTemplate(RecRef, EmailTemplateHeader, RecipientEmail, Silent));
    end;

    procedure SendEmailTemplate(var RecRef: RecordRef; var EmailTemplateHeader: Record "NPR E-mail Template Header"; RecipientEmail: Text; Silent: Boolean) ErrorMessage: Text
    begin
        ErrorMessage := SetupEmailTemplate(RecRef, RecipientEmail, Silent, EmailTemplateHeader);
        if EmailTemplateHeader."Default Recipient Address" = '' then
            exit;
        if ErrorMessage = '' then
            ErrorMessage := CreateSmtpMessageFromEmailTemplate(EmailTemplateHeader, RecRef, 0);

        if ErrorMessage = '' then
            ErrorMessage := SendSmtpMessage(RecRef, Silent);

        if (ErrorMessage <> '') and not Silent then
            Error(ErrorMessage);

        exit(ErrorMessage);
    end;

    procedure SendReport(ReportID: Integer; var RecRef: RecordRef; RecipientEmail: Text[250]; Silent: Boolean): Text
    var
        EmailTemplateHeader: Record "NPR E-mail Template Header";
    begin
        exit(SendReportTemplate(ReportID, RecRef, EmailTemplateHeader, RecipientEmail, Silent));
    end;

    procedure SendReportTemplate(ReportID: Integer; var RecRef: RecordRef; var EmailTemplateHeader: Record "NPR E-mail Template Header"; RecipientEmail: Text[250]; Silent: Boolean): Text
    var
        Filename: Text;
        ErrorMessage: Text;
    begin
        ErrorMessage := '';
        if ReportID = 0 then
            ErrorMessage := Text012;

        if ErrorMessage = '' then
            ErrorMessage := SetupEmailTemplate(RecRef, RecipientEmail, Silent, EmailTemplateHeader);
        if EmailTemplateHeader."Default Recipient Address" = '' then
            exit;

        if ErrorMessage = '' then
            ErrorMessage := CreateSmtpMessageFromEmailTemplate(EmailTemplateHeader, RecRef, ReportID);

        AddEmailAttachmentsToSmtpMessage(EmailTemplateHeader);

        if ErrorMessage = '' then begin
            Filename := GetFilename(EmailTemplateHeader, RecRef);
            RecRef.SetRecFilter();
            if not PrintPDF(ReportID, RecRef, Filename) then
                ErrorMessage := StrSubstNo(Text006, ReportID, GetLastErrorText);
        end;

        if ErrorMessage = '' then
            ErrorMessage := AddAdditionalReportsToSmtpMessage(EmailTemplateHeader, RecRef);

        if ErrorMessage = '' then
            ErrorMessage := SendSmtpMessage(RecRef, Silent);

        if (ErrorMessage <> '') and not Silent then
            Error(ErrorMessage);

        exit(CopyStr(ErrorMessage, 1, 1024));
    end;

    //--- SmtpMessage ---

    local procedure AddAdditionalReportsToSmtpMessage(EmailTemplateHeader: Record "NPR E-mail Template Header"; var RecRef: RecordRef) ErrorMessage: Text
    var
        EmailTemplateReport: Record "NPR E-mail Templ. Report";
        EmailTemplateMgt: Codeunit "NPR E-mail Templ. Mgt.";
        Filename: Text[250];
    begin
        EmailTemplateReport.Reset();
        EmailTemplateReport.SetRange("E-mail Template Code", EmailTemplateHeader.Code);
        if EmailTemplateReport.FindSet() then
            repeat
                Filename := EmailTemplateMgt.MergeMailContent(RecRef, EmailTemplateReport.Filename, EmailTemplateHeader."Fieldnumber Start Tag", EmailTemplateHeader."Fieldnumber End Tag");
                if StrPos(Filename, '.pdf') = 0 then
                    Filename += '.pdf';
                Filename := ReplaceSpecialChar(Filename);

                if not PrintPDF(EmailTemplateReport."Report ID", RecRef, Filename) then
                    ErrorMessage := StrSubstNo(Text006, EmailTemplateReport."Report ID", GetLastErrorText);
            until (EmailTemplateReport.Next() = 0) or (ErrorMessage <> '');

        exit(ErrorMessage);
    end;

    local procedure AddEmailAttachmentsToSmtpMessage(EmailTemplateHeader: Record "NPR E-mail Template Header")
    var
        EmailAttachment: Record "NPR E-mail Attachment";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(EmailTemplateHeader);
        EmailAttachment.SetRange("Table No.", RecRef.Number);
        EmailAttachment.SetRange("Primary Key", RecRef.GetPosition(false));
        if EmailAttachment.FindSet() then
            repeat
                if EmailAttachment.Description <> '' then begin
                    EmailAttachment.CalcFields("Attached File");
                    AddAttachmentToBuffer(EmailAttachment);
                end;
            until EmailAttachment.Next() = 0;
    end;

    procedure AddFileToSmtpMessage(Filename: Text[250]) FileAttached: Boolean
    var
        AttachmentFile: File;
        EmailAttachmentTemp: Record "NPR E-mail Attachment" temporary;
        InStream: InStream;
        OutStream: OutStream;
        Pos: Integer;
    begin
        if not Exists(Filename) then
            exit(false);

        AttachmentFile.Open(Filename);
        AttachmentFile.CreateInStream(InStream);
        EmailAttachmentTemp.Init();
        EmailAttachmentTemp."Attached File".CreateOutStream(OutStream);
        CopyStream(OutStream, InStream);
        Pos := StrPos(Filename, '\');
        while Pos > 0 do begin
            Filename := CopyStr(Filename, Pos + 1);
            Pos := StrPos(Filename, '\');
        end;
        EmailAttachmentTemp.Description := ReplaceSpecialChar(Filename);
        EmailAttachmentTemp.Insert();
        AddAttachmentToBuffer(EmailAttachmentTemp);
        AttachmentFile.Close();
        exit(true);
    end;

    procedure AddAttachmentToSmtpMessage(var EmailAttachment: Record "NPR E-mail Attachment"): Boolean
    begin
        exit(AddAttachmentToBuffer(EmailAttachment));
    end;

    local procedure AddAttachmentToBuffer(var EmailAttachment: Record "NPR E-mail Attachment"): Boolean
    var
        NextAttachmentLineNo: Integer;
    begin
        EmailAttachment.CalcFields("Attached File");
        if not EmailAttachment."Attached File".HasValue() then begin
            if SetLastErrorMessage(StrSubstNo(AttachmentNoData, EmailAttachment.Description)) then;
            exit(false);
        end;
        AttachmentBuffer.Reset();
        if AttachmentBuffer.FindLast() then
            NextAttachmentLineNo := AttachmentBuffer."Line No." + 1
        else
            NextAttachmentLineNo := 1;
        AttachmentBuffer := EmailAttachment;
        AttachmentBuffer."Table No." := 0;
        AttachmentBuffer."Primary Key" := '';
        AttachmentBuffer."Line No." := NextAttachmentLineNo;
        AttachmentBuffer.Insert();
        exit(true);
    end;

    procedure CreateSmtpMessageFromEmailTemplate(EmailTemplateHeader: Record "NPR E-mail Template Header"; var RecRef: RecordRef; ReportID: Integer) ErrorMessage: Text[1024]
    var
        EmailTemplateLine: Record "NPR E-mail Templ. Line";
        EmailTemplateMgt: Codeunit "NPR E-mail Templ. Mgt.";
        HtmlLine: Text;
        InStream: InStream;
        Separators: List of [Text];
    begin
        if not SmtpMail.IsEnabled() then
            exit(Text008);
        SmtpMail.Initialize();
        if EmailTemplateHeader."Default Recipient Address" = '' then
            exit(Text003);
        if EmailTemplateHeader."From E-mail Address" = '' then
            exit(Text004);
        UseTransactionalEmailCode := '';
        TransactionalType := 0;
        if (EmailTemplateHeader."Transactional E-mail" = EmailTemplateHeader."Transactional E-mail"::"Smart Email") then begin
            TransactionalType := TransactionalType::Classic;
            TransactionalEmailRecipient := EmailTemplateHeader."Default Recipient Address";
            if EmailTemplateHeader."Transactional E-mail Code" <> '' then begin
                TransactionalType := TransactionalType::Smart;
                UseTransactionalEmailCode := EmailTemplateHeader."Transactional E-mail Code";
            end;
        end;
        InitMailAdrSeparators(Separators);
        SmtpMail.AddRecipients(EmailTemplateHeader."Default Recipient Address".Split(Separators));
        SmtpMail.AddFrom(EmailTemplateHeader."From E-mail Name", EmailTemplateHeader."From E-mail Address");
        if EmailTemplateHeader."Sender as bcc" then
            SmtpMail.AddBCC(EmailTemplateHeader."From E-mail Address".Split(Separators));
        if EmailTemplateHeader."Default Recipient Address CC" <> '' then
            SmtpMail.AddCC(EmailTemplateHeader."Default Recipient Address CC".Split(Separators));
        if EmailTemplateHeader."Default Recipient Address BCC" <> '' then
            SmtpMail.AddBCC(EmailTemplateHeader."Default Recipient Address BCC".Split(Separators));

        if TransactionalType <> TransactionalType::Smart then begin
            HtmlLine := EmailTemplateMgt.MergeMailContent(RecRef, EmailTemplateHeader.Subject, EmailTemplateHeader."Fieldnumber Start Tag", EmailTemplateHeader."Fieldnumber End Tag");
            SmtpMail.AddSubject(HtmlLine);
            if not EmailTemplateHeader."Use HTML Template" then begin
                EmailTemplateLine.SetRange("E-mail Template Code", EmailTemplateHeader.Code);
                if EmailTemplateLine.FindSet() then
                    repeat
                        HtmlLine := EmailTemplateMgt.MergeMailContent(RecRef, EmailTemplateLine."Mail Body Line", EmailTemplateHeader."Fieldnumber Start Tag", EmailTemplateHeader."Fieldnumber End Tag") + '<br/>';
                        SmtpMail.AppendBody(HtmlLine);
                    until EmailTemplateLine.Next() = 0;
            end else begin
                EmailTemplateHeader.CalcFields("HTML Template");
                if EmailTemplateHeader."HTML Template".HasValue() then begin
                    EmailTemplateHeader."HTML Template".CreateInStream(InStream, TEXTENCODING::UTF8);
                    while not InStream.EOS do begin
                        HtmlLine := '';
                        InStream.ReadText(HtmlLine);
                        HtmlLine := EmailTemplateMgt.MergeMailContent(RecRef, HtmlLine, EmailTemplateHeader."Fieldnumber Start Tag", EmailTemplateHeader."Fieldnumber End Tag") + '<br/>';
                        SmtpMail.AppendBody(HtmlLine);
                    end;
                    Clear(InStream);
                end;
            end;
        end;

        AttachmentBuffer.DeleteAll();

        exit('');
    end;


    procedure SendSmtpMessage(var RecRef: RecordRef; Silent: Boolean) ErrorMessage: Text[1024]
    var
        TransactionalEmail: Record "NPR Smart Email";
        EmailLog: Record "NPR E-mail Log";
        TransactionalEmailMgt: Codeunit "NPR Transactional Email Mgt.";
        IStream: InStream;
        HandledByTransactional: Boolean;
        FromName: Text;
        FromAddress: Text;
        CCAddressList: List of [Text];
        BCCAddressList: List of [Text];
        EmailLogPrepared: Boolean;
    begin
        EmailLogPrepared := false;
        if TransactionalType = TransactionalType::Smart then
            if TransactionalEmail.Get(UseTransactionalEmailCode) then begin
                SmtpMail.GetCC(CCAddressList);
                SmtpMail.GetBCC(BCCAddressList);
                ErrorMessage := CopyStr(TransactionalEmailMgt.SendSmartEmailWAttachment(TransactionalEmail, TransactionalEmailRecipient, List2Text(CCAddressList), List2Text(BCCAddressList), RecRef, AttachmentBuffer, Silent), 1, MaxStrLen(ErrorMessage));
                HandledByTransactional := true;
            end;
        if TransactionalType = TransactionalType::Classic then begin
            FromAddress := SmtpMail.GetFrom();
            if FromAddress.LastIndexOf('"') > 0 then begin
                FromName := CopyStr(FromAddress, 1, FromAddress.LastIndexOf('"'));
                FromName := FromName.TrimStart('"').TrimEnd('"');
                FromAddress := CopyStr(FromAddress, FromAddress.LastIndexOf('"') + 1);
                FromAddress := FromAddress.Trim();
            end;
            SmtpMail.GetCC(CCAddressList);
            SmtpMail.GetBCC(BCCAddressList);
            ErrorMessage := TransactionalEmailMgt.SendClassicMail(TransactionalEmailRecipient, List2Text(CCAddressList), List2Text(BCCAddressList), SmtpMail.GetSubject(), SmtpMail.GetBody(), '', FromAddress, FromName, '', true, true, '', '', AttachmentBuffer, Silent);
            HandledByTransactional := true;
        end;

        if not HandledByTransactional then begin
            if not SmtpMail.IsEnabled() then begin
                if Silent then
                    exit(Text008);
                Error(Text008);
            end;
            AttachmentBuffer.Reset();
            if AttachmentBuffer.FindSet() then
                repeat
                    if AttachmentBuffer.Description <> '' then begin
                        AttachmentBuffer.CalcFields("Attached File");
                        Clear(IStream);
                        if AttachmentBuffer."Attached File".HasValue() then begin
                            AttachmentBuffer."Attached File".CreateInStream(IStream);
                        end;
                        if SmtpMail.AddAttachmentStream(IStream, AttachmentBuffer.Description) then
                            Clear(IStream);
                    end;
                until AttachmentBuffer.Next() = 0;
            PrepareEmailLogEntry(EmailLog, RecRef);
            EmailLogPrepared := true;
            SmtpMail.Send();
            ErrorMessage := SmtpMail.GetLastSendMailErrorText();
        end;
        AttachmentBuffer.DeleteAll();

        if ErrorMessage = '' then begin
            AddEmailLogEntry(EmailLog, RecRef, EmailLogPrepared);
            if Silent then
                exit('')
            else begin
                Message(Text002);
                exit('');
            end;
        end else begin
            if Silent then
                exit(ErrorMessage)
            else
                Error(ErrorMessage);
        end;
    end;

    local procedure List2Text(TextList: List of [Text]): Text
    var
        Result: Text;
        TextPart: Text;
    begin
        foreach TextPart in TextList do
            Result += TextPart + ';';
        Exit(Result.TrimEnd(';'));
    end;

    //--- Setup ---

    procedure SetupEmailTemplate(var RecRef: RecordRef; RecipientEmail: Text[250]; Silent: Boolean; var EmailTemplateHeader: Record "NPR E-mail Template Header") ErrorMessage: Text[1024]
    begin
        ErrorMessage := '';
        if GetEmailTemplateHeader(RecRef, EmailTemplateHeader) then begin
            if Silent then
                EmailTemplateHeader."Verify Recipient" := false;
            EmailTemplateHeader."Default Recipient Address" := GetEmailRecepientAddress(EmailTemplateHeader, RecipientEmail);
            EmailTemplateHeader."From E-mail Address" := GetEmailFromAddress(EmailTemplateHeader);
            EmailTemplateHeader."From E-mail Name" := GetEmailFromName(EmailTemplateHeader);
            OnAfterSetFromEmail(EmailTemplateHeader.Code, RecRef, RecipientEmail, Silent, EmailTemplateHeader."From E-mail Address", EmailTemplateHeader."From E-mail Name");
        end else
            ErrorMessage := Text011;

        if (ErrorMessage <> '') and not Silent then
            Error(ErrorMessage);

        exit(ErrorMessage);
    end;

    procedure GetDefaultGroupFilter(): Text
    begin
        exit('');
    end;

    //--- PDF ---

    local procedure PrintPDF(ReportID: Integer; RecVariant: Variant; Filename: Text): Boolean
    var
        EmailAttachmentTemp: Record "NPR E-mail Attachment" temporary;
        Result: Boolean;
        OStream: OutStream;
        Parameters: Text;
    begin
        SetGlobalCustomReport;
        EmailAttachmentTemp.Description := Filename;
        EmailAttachmentTemp."Attached File".CreateOutStream(OStream);
        Parameters := GetReqParametersFromStore(ReportID);
        Result := REPORT.SaveAs(ReportID, Parameters, REPORTFORMAT::Pdf, OStream, RecVariant);
        ClearRequestParameters(ReportID);
        if not EmailAttachmentTemp."Attached File".HasValue() then begin
            Result := false;
            if SetLastErrorMessage(NoOutputFromReport) then;
        end;
        if Result then begin
            EmailAttachmentTemp.Insert();
            Result := AddAttachmentToBuffer(EmailAttachmentTemp);
        end;

        ClearGlobalCustomReport;
        exit(Result);
    end;

    //--- Get ---

    local procedure GetEmailFromAddress(EmailTemplateHeader: Record "NPR E-mail Template Header"): Text[250]
    var
        EmailSetup: Record "NPR E-mail Setup";

    begin
        if EmailTemplateHeader."From E-mail Address" <> '' then
            exit(EmailTemplateHeader."From E-mail Address");
        EMailSetup.Get();
        exit(EmailSetup."From E-mail Address");
    end;

    local procedure GetEmailFromName(EmailTemplateHeader: Record "NPR E-mail Template Header"): Text[250]
    var
        EmailSetup: Record "NPR E-mail Setup";
    begin
        if EmailTemplateHeader."From E-mail Name" <> '' then
            exit(EmailTemplateHeader."From E-mail Name");
        EMailSetup.Get();
        exit(EmailSetup."From Name");
    end;

    local procedure GetEmailRecepientAddress(EmailTemplateHeader: Record "NPR E-mail Template Header"; EmailRecipientAddress: Text[250]) NewEmailRecipientAddress: Text[250]
    begin
        NewEmailRecipientAddress := EmailRecipientAddress;
        if NewEmailRecipientAddress = '' then
            NewEmailRecipientAddress := EmailTemplateHeader."Default Recipient Address";

        if EmailTemplateHeader."Verify Recipient" or (NewEmailRecipientAddress = '') then
            NewEmailRecipientAddress := VerifyEmailAddress(NewEmailRecipientAddress);

        exit(NewEmailRecipientAddress);
    end;

    procedure GetEmailTemplateHeader(var RecRef: RecordRef; var EmailTemplateHeader: Record "NPR E-mail Template Header") RecordExists: Boolean
    var
        EmailTemplateFilter: Record "NPR E-mail Template Filter";
        FieldRef: FieldRef;
        Stop: Boolean;
    begin
        if EmailTemplateHeader.GetFilters = '' then
            EmailTemplateHeader.SetFilter(Group, '%1', GetDefaultGroupFilter);
        EmailTemplateHeader.SetRange("Table No.", RecRef.Number);
        if EmailTemplateHeader.Find('-') then
            repeat
                RecordExists := true;
                EmailTemplateFilter.SetRange("E-mail Template Code", EmailTemplateHeader.Code);
                EmailTemplateFilter.SetRange("Table No.", EmailTemplateHeader."Table No.");
                if EmailTemplateFilter.Find('-') then
                    repeat
                        RecordExists := false;
                        FieldRef := RecRef.Field(EmailTemplateFilter."Field No.");
                        FieldRef.SetFilter(EmailTemplateFilter.Value);
                        if RecRef.Find() then
                            RecordExists := true;
                        FieldRef.SetRange();
                    until not RecordExists or (EmailTemplateFilter.Next() = 0);
                if RecordExists then
                    Stop := true
                else
                    Stop := EmailTemplateHeader.Next() = 0;
            until Stop;

        if not RecordExists then begin
            if EmailTemplateHeader.Find('-') then
                repeat
                    RecordExists := true;
                    EmailTemplateFilter.SetRange("E-mail Template Code", EmailTemplateHeader.Code);
                    EmailTemplateFilter.SetRange("Table No.", EmailTemplateHeader."Table No.");
                    if EmailTemplateFilter.Find('-') then
                        repeat
                            RecordExists := false;
                            FieldRef := RecRef.Field(EmailTemplateFilter."Field No.");
                            FieldRef.SetFilter(EmailTemplateFilter.Value);
                            if RecRef.Find() then
                                RecordExists := true;
                            FieldRef.SetRange();
                        until not RecordExists or (EmailTemplateFilter.Next() = 0);
                    if RecordExists then
                        Stop := true
                    else
                        Stop := EmailTemplateHeader.Next() = 0;
                until Stop;
        end;

        exit(RecordExists);
    end;

    procedure GetFilename(EmailTemplateHeader: Record "NPR E-mail Template Header"; var RecRef: RecordRef) Filename: Text
    var
        EmailTemplateMgt: Codeunit "NPR E-mail Templ. Mgt.";
    begin
        Filename := EmailTemplateMgt.MergeMailContent(RecRef, EmailTemplateHeader.Filename, EmailTemplateHeader."Fieldnumber Start Tag", EmailTemplateHeader."Fieldnumber End Tag");

        if StrPos(Filename, '.pdf') = 0 then
            Filename += '.pdf';

        Filename := ReplaceSpecialChar(Filename);
    end;

    [IntegrationEvent(false, false)]
    local procedure GetReportIDEvent(RecRef: RecordRef; var ReportID: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetReportIDEvent(RecRef: RecordRef; var ReportID: Integer)
    begin
    end;

    procedure GetReportIDFromRecRef(RecRef: RecordRef) ReportID: Integer
    var
        EmailTemplateHeader: Record "NPR E-mail Template Header";
        PurchHeader: Record "Purchase Header";
        ReportSelections: Record "Report Selections";
        SalesHeader: Record "Sales Header";
        ServHeader: Record "Service Header";
    begin
        ReportID := 0;

        GetReportIDEvent(RecRef, ReportID);

        if ReportID = 0 then
            if GetEmailTemplateHeader(RecRef, EmailTemplateHeader) and (EmailTemplateHeader."Report ID" <> 0) then
                ReportID := EmailTemplateHeader."Report ID";

        if ReportID > 0 then begin
            case RecRef.Number() of
                DATABASE::"Sales Cr.Memo Header":
                    GetCustomEmailForReportID(DATABASE::Customer, Format(RecRef.Field(4).Value), ReportSelections.Usage::"S.Cr.Memo", EmailTemplateHeader."Report ID");
                DATABASE::"Sales Header":
                    begin
                        RecRef.SetTable(SalesHeader);
                        case SalesHeader."Document Type" of
                            SalesHeader."Document Type"::Quote:
                                GetCustomEmailForReportID(DATABASE::Customer, SalesHeader."Bill-to Customer No.", ReportSelections.Usage::"S.Quote", EmailTemplateHeader."Report ID");
                            SalesHeader."Document Type"::Order:
                                GetCustomEmailForReportID(DATABASE::Customer, SalesHeader."Bill-to Customer No.", ReportSelections.Usage::"S.Order", EmailTemplateHeader."Report ID");
                            SalesHeader."Document Type"::"Return Order":
                                GetCustomEmailForReportID(DATABASE::Customer, SalesHeader."Bill-to Customer No.", ReportSelections.Usage::"S.Return", EmailTemplateHeader."Report ID");
                        end;
                    end;
                DATABASE::"Sales Invoice Header":
                    GetCustomEmailForReportID(DATABASE::Customer, Format(RecRef.Field(4).Value), ReportSelections.Usage::"S.Invoice", EmailTemplateHeader."Report ID");
            end;
        end;
        OnAfterGetReportIDEvent(RecRef, ReportID);

        exit(ReportID);

        Clear(ReportSelections);
        ReportSelections.SetFilter("Report ID", '<>%1', 0);
        case RecRef.Number of
            DATABASE::"Issued Reminder Header":
                begin
                    ReportSelections.SetRange(Usage, ReportSelections.Usage::Reminder);
                    if ReportSelections.FindFirst() then
                        ReportID := ReportSelections."Report ID";
                end;
            DATABASE::"Issued Fin. Charge Memo Header":
                begin
                    ReportSelections.SetRange(Usage, ReportSelections.Usage::"Fin.Charge");
                    if ReportSelections.FindFirst() then
                        ReportID := ReportSelections."Report ID";
                end;
            DATABASE::"Sales Cr.Memo Header":
                begin
                    ReportID := GetCustomReportSelection(DATABASE::Customer, Format(RecRef.Field(4).Value), ReportSelections.Usage::"S.Cr.Memo");
                    if ReportID = 0 then begin
                        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Cr.Memo");
                        if ReportSelections.FindFirst() then
                            ReportID := ReportSelections."Report ID";
                    end;
                end;
            DATABASE::"Sales Header":
                begin
                    RecRef.SetTable(SalesHeader);
                    case SalesHeader."Document Type" of
                        SalesHeader."Document Type"::Quote:
                            begin
                                ReportID := GetCustomReportSelection(DATABASE::Customer, SalesHeader."Bill-to Customer No.", ReportSelections.Usage::"S.Quote");
                                if ReportID = 0 then begin
                                    ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Quote");
                                    if ReportSelections.FindFirst() then
                                        ReportID := ReportSelections."Report ID";
                                end;
                            end;
                        SalesHeader."Document Type"::Order:
                            begin
                                ReportID := GetCustomReportSelection(DATABASE::Customer, SalesHeader."Bill-to Customer No.", ReportSelections.Usage::"S.Order");
                                if ReportID = 0 then begin
                                    ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Order");
                                    if ReportSelections.FindFirst() then
                                        ReportID := ReportSelections."Report ID";
                                end;
                            end;
                        SalesHeader."Document Type"::"Return Order":
                            begin
                                ReportID := GetCustomReportSelection(DATABASE::Customer, SalesHeader."Bill-to Customer No.", ReportSelections.Usage::"S.Return");
                                if ReportID = 0 then begin
                                    ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Return");
                                    if ReportSelections.FindFirst() then
                                        ReportID := ReportSelections."Report ID";
                                end;
                            end;
                    end;
                end;
            DATABASE::"Sales Invoice Header":
                begin
                    ReportID := GetCustomReportSelection(DATABASE::Customer, Format(RecRef.Field(4).Value), ReportSelections.Usage::"S.Invoice");
                    if ReportID = 0 then begin
                        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Invoice");
                        if ReportSelections.FindFirst() then
                            ReportID := ReportSelections."Report ID";
                    end;
                end;
            DATABASE::"Sales Shipment Header":
                begin
                    ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Shipment");
                    if ReportSelections.FindFirst() then
                        ReportID := ReportSelections."Report ID";
                end;
            DATABASE::"Purch. Cr. Memo Hdr.":
                begin
                    ReportSelections.SetRange(Usage, ReportSelections.Usage::"P.Cr.Memo");
                    if ReportSelections.FindFirst() then
                        ReportID := ReportSelections."Report ID";
                end;
            DATABASE::"Purchase Header":
                begin
                    RecRef.SetTable(PurchHeader);
                    case PurchHeader."Document Type" of
                        PurchHeader."Document Type"::Quote:
                            begin
                                ReportSelections.SetRange(Usage, ReportSelections.Usage::"P.Quote");
                                if ReportSelections.FindFirst() then
                                    ReportID := ReportSelections."Report ID";
                            end;
                        PurchHeader."Document Type"::Order:
                            begin
                                ReportSelections.SetRange(Usage, ReportSelections.Usage::"P.Order");
                                if ReportSelections.FindFirst() then
                                    ReportID := ReportSelections."Report ID";
                            end;
                        PurchHeader."Document Type"::"Return Order":
                            begin
                                ReportSelections.SetRange(Usage, ReportSelections.Usage::"P.Return");
                                if ReportSelections.FindFirst() then
                                    ReportID := ReportSelections."Report ID";
                            end;
                    end;
                end;
            DATABASE::"Purch. Inv. Header":
                begin
                    ReportSelections.SetRange(Usage, ReportSelections.Usage::"P.Invoice");
                    if ReportSelections.FindFirst() then
                        ReportID := ReportSelections."Report ID";
                end;
            DATABASE::"Purch. Rcpt. Header":
                begin
                    ReportSelections.SetRange(Usage, ReportSelections.Usage::"P.Receipt");
                    if ReportSelections.FindFirst() then
                        ReportID := ReportSelections."Report ID";
                end;
            DATABASE::"Service Header":
                begin
                    RecRef.SetTable(ServHeader);
                    case ServHeader."Document Type" of
                        ServHeader."Document Type"::Quote:
                            begin
                                ReportSelections.SetRange(Usage, ReportSelections.Usage::"SM.Quote");
                                if ReportSelections.FindFirst() then
                                    ReportID := ReportSelections."Report ID";
                            end;
                        ServHeader."Document Type"::Order:
                            begin
                                ReportSelections.SetRange(Usage, ReportSelections.Usage::"SM.Order");
                                if ReportSelections.FindFirst() then
                                    ReportID := ReportSelections."Report ID";
                            end;
                    end;
                end;
            DATABASE::"Service Shipment Header":
                begin
                    ReportSelections.SetRange(Usage, ReportSelections.Usage::"SM.Shipment");
                    if ReportSelections.FindFirst() then
                        ReportID := ReportSelections."Report ID";
                end;
            DATABASE::"Service Invoice Header":
                begin
                    ReportSelections.SetRange(Usage, ReportSelections.Usage::"SM.Invoice");
                    if ReportSelections.FindFirst() then
                        ReportID := ReportSelections."Report ID";
                end;
        end;

        exit(ReportID);
    end;

    [IntegrationEvent(false, false)]
    local procedure GetEmailAddressEvent(var RecRef: RecordRef; var EmailAddress: Text; var Handled: Boolean)
    begin
    end;

    procedure GetEmailAddressFromRecRef(var RecRef: RecordRef): Text
    var
        EmailAddress: Text;
        Handled: Boolean;
        Customer: Record Customer;
    begin
        GetEmailAddressEvent(RecRef, EmailAddress, Handled);
        if Handled then
            exit(EmailAddress);

        case RecRef.Number of
            DATABASE::Customer:
                exit(RecRef.Field(102).Value);
            DATABASE::"Sales Header":
                exit(RecRef.Field(6014414).Value);
            DATABASE::"Sales Shipment Header":
                exit(RecRef.Field(6014414).Value);
            DATABASE::"Sales Invoice Header":
                exit(RecRef.Field(6014414).Value);
            DATABASE::"Sales Cr.Memo Header":
                exit(RecRef.Field(6014414).Value);
            DATABASE::"Purch. Cr. Memo Hdr.":
                exit(RecRef.Field(6014414).Value);
            DATABASE::"Purchase Header":
                exit(RecRef.Field(6014414).Value);
            DATABASE::"Purch. Inv. Header":
                exit(RecRef.Field(6014414).Value);
            DATABASE::"Purch. Rcpt. Header":
                exit(RecRef.Field(6014414).Value);
            DATABASE::"Service Header":
                exit(RecRef.Field(5916).Value);
            DATABASE::"Service Invoice Header":
                exit(RecRef.Field(5916).Value);
            DATABASE::"Service Shipment Header":
                exit(RecRef.Field(5916).Value);
            DATABASE::"Issued Fin. Charge Memo Header":
                if Customer.Get(RecRef.Field(2).Value) then
                    exit(Customer."E-Mail")
                else
                    exit('');
            DATABASE::"Issued Reminder Header":
                if Customer.Get(RecRef.Field(2).Value) then
                    exit(Customer."E-Mail")
                else
                    exit('');
        end;
    end;

    local procedure GetCustomReportSelection(SourceType: Integer; BillToCustomer: Code[20]; NewUsage: Enum "Report Selection Usage") ReportID: Integer
    var
        CustomReportSelection: Record "Custom Report Selection";
        EmailNaviDocsMgtWrapper: Codeunit "NPR E-mail NaviDocs Mgt.Wrap.";
    begin
        CustomReportSelection.SetRange("Source Type", SourceType);
        CustomReportSelection.SetRange("Source No.", BillToCustomer);
        CustomReportSelection.SetRange(Usage, NewUsage);
        ReportID := 0;
        if CustomReportSelection.FindFirst() then begin
            ReportID := CustomReportSelection."Report ID";
            if EmailNaviDocsMgtWrapper.HasCustomReportLayout(CustomReportSelection) or
                (CustomReportSelection."Send To Email" <> '') then begin
                UseCustomReportSelection := true;
                GlobalCustomReportSelection := CustomReportSelection;
            end;
        end;
        exit(ReportID);
    end;

    local procedure GetCustomEmailForReportID(SourceType: Integer; BillToCustomer: Code[20]; NewUsage: Enum "Report Selection Usage"; ReportID: Integer)
    var
        CustomReportSelection: Record "Custom Report Selection";
    begin
        if UseCustomReportSelection then
            exit;
        CustomReportSelection.SetRange("Source Type", SourceType);
        CustomReportSelection.SetRange("Source No.", BillToCustomer);
        CustomReportSelection.SetRange(Usage, NewUsage);
        CustomReportSelection.SetRange("Report ID", ReportID);
        if not CustomReportSelection.FindFirst() then begin
            CustomReportSelection.SetRange("Report ID", 0);
            if not CustomReportSelection.FindFirst() then
                exit;
        end;
        if CustomReportSelection."Send To Email" <> '' then begin
            UseCustomReportSelection := true;
            GlobalCustomReportSelection := CustomReportSelection;
        end;
    end;

    procedure GetCustomReportEmailAddress(): Text
    begin
        if UseCustomReportSelection then
            exit(GlobalCustomReportSelection."Send To Email");
        exit('');
    end;

    local procedure SetGlobalCustomReport()
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        EmailNaviDocsMgtWrapper: Codeunit "NPR E-mail NaviDocs Mgt.Wrap.";
        CustomReportLayoutVariant: Variant;
    begin
        if UseCustomReportSelection then
            if EmailNaviDocsMgtWrapper.HasCustomReportLayout(GlobalCustomReportSelection) then begin
                EmailNaviDocsMgtWrapper.GetCustomReportLayoutVariant(GlobalCustomReportSelection, CustomReportLayoutVariant);
                ReportLayoutSelection.SetTempLayoutSelected(CustomReportLayoutVariant);
            end;
    end;

    local procedure ClearGlobalCustomReport()
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomReportSelection: Record "Custom Report Selection";
        EmailNaviDocsMgtWrapper: Codeunit "NPR E-mail NaviDocs Mgt.Wrap.";
        BlankVariant: Variant;
    begin
        if UseCustomReportSelection then begin
            EmailNaviDocsMgtWrapper.GetCustomReportLayoutVariant(CustomReportSelection, BlankVariant);
            ReportLayoutSelection.SetTempLayoutSelected(BlankVariant);
        end;
    end;

    procedure StoreRequestParameters(ReportID: Integer; Parameters: Text)
    begin
        if ReqParamStoreDict.ContainsKey(ReportID) then
            ReqParamStoreDict.Set(ReportID, Parameters)
        else
            ReqParamStoreDict.Add(ReportID, Parameters);
    end;

    local procedure GetReqParametersFromStore(ReportID: Integer): Text
    begin
        if ReqParamStoreDict.ContainsKey(ReportID) then
            exit(ReqParamStoreDict.Get(ReportID));
    end;

    procedure ClearRequestParameters(ReportID: Integer)
    begin
        if ReqParamStoreDict.ContainsKey(ReportID) then
            ReqParamStoreDict.Remove(ReportID);
    end;

    //--- Email Log ---


    local procedure PrepareEmailLogEntry(var EmailLog: Record "NPR E-mail Log"; RecRef: RecordRef)
    var
        Chr: array[2] of Char;
        MailAddresses: List of [Text];
    begin
        Chr[1] := 13;
        Chr[2] := 10;
        EmailLog.Init();
        EmailLog."Table No." := RecRef.Number;
        EmailLog."Primary Key" := RecRef.GetPosition(false);
        EmailLog."Sent Time" := Time;
        EmailLog."Sent Date" := Today();
        EmailLog."Sent Username" := UserId;
        SmtpMail.GetRecipients(MailAddresses);
        EmailLog."Recipient E-mail" := CopyStr(List2Text(MailAddresses), 1, MaxStrLen(EmailLog."Recipient E-mail"));
        EmailLog."From E-mail" := CopyStr(SmtpMail.GetFrom(), 1, MaxStrLen(EmailLog."From E-mail"));
        EmailLog."E-mail subject" := CopyStr(SmtpMail.GetSubject(), 1, MaxStrLen(EmailLog."E-mail subject"));
        EmailLog.Filename := CopyStr(AttachmentBuffer.Description, 1, MaxStrLen(EmailLog.Filename));
    end;

    local procedure AddEmailLogEntry(EmailLog: Record "NPR E-mail Log"; RecRef: RecordRef; EmailLogPrepared: Boolean)
    begin
        if not EmailLogPrepared then
            PrepareEmailLogEntry(EmailLog, RecRef);
        EmailLog.Insert(true);
    end;

    local procedure EmailLogExists(RecRef: RecordRef): Boolean
    var
        EmailLog: Record "NPR E-mail Log";
    begin
        Clear(EmailLog);
        EmailLog.SetRange("Table No.", RecRef.Number);
        EmailLog.SetRange("Primary Key", RecRef.GetPosition(false));
        exit(not EmailLog.IsEmpty());
    end;

    local procedure ReplaceSpecialChar(Input: Text) Output: Text
    var
        i: Integer;
    begin
        Output := '';
        for i := 1 to StrLen(Input) do
            case Input[i] of
                '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
                'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
                'u', 'v', 'w', 'x', 'y', 'z', 'U', 'V', 'W', 'X', 'Y', 'Z', '-', '.':
                    Output += Format(Input[i]);
                'æ':
                    Output += 'ae';
                'ø', 'ö':
                    Output += 'oe';
                'å', 'ä':
                    Output += 'aa';
                'è', 'é', 'ë', 'ê':
                    Output += 'e';
                'Æ':
                    Output += 'AE';
                'Ø', 'Ö':
                    Output += 'OE';
                'Å', 'Ä':
                    Output += 'AA';
                'É', 'È', 'Ë', 'Ê':
                    Output += 'E';
                else
                    Output += '-';
            end;

        exit(Output);
    end;

    [TryFunction]
    procedure CheckEmailSyntax(EmailAddress: Text)
    var
        MailManagement: Codeunit "Mail Management";
    begin
        MailManagement.CheckValidEmailAddress(EmailAddress);
    end;

    [TryFunction]
    local procedure SetLastErrorMessage(ErrorMessage: Text)
    begin
        Error(ErrorMessage);
    end;

    procedure ConfirmResendEmail(var RecRef: RecordRef): Boolean
    begin
        if EmailLogExists(RecRef) then
            exit(Confirm(Text010));

        exit(true);
    end;

    procedure RunEmailLog(RecRef: RecordRef)
    var
        EmailLog: Record "NPR E-mail Log";
    begin
        Clear(EmailLog);
        EmailLog.SetRange("Table No.", RecRef.Number);
        EmailLog.SetRange("Primary Key", RecRef.GetPosition(false));
        PAGE.Run(PAGE::"NPR E-mail Log", EmailLog);
    end;

    local procedure VerifyEmailAddress(RecipientEmail: Text) NewRecipientEmail: Text
    var
        InputDialog: Page "NPR Input Dialog";
    begin
        Clear(InputDialog);
        InputDialog.SetInput(1, RecipientEmail, Text001);
        InputDialog.LookupMode(true);
        if InputDialog.RunModal() <> ACTION::LookupOK then
            exit('');

        InputDialog.InputText(1, NewRecipientEmail);

        exit(NewRecipientEmail);
    end;

    local procedure InitMailAdrSeparators(var MailAdrSeparators: List of [Text])
    begin
        MailAdrSeparators.Add(';');
        MailAdrSeparators.Add(',');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetFromEmail(EmailTemplateHeaderCode: Code[20]; RecRef: RecordRef; RecipientEmail: Text[250]; Silent: Boolean; var FromEmailAddress: Text[80]; var FromEmailName: Text[80])
    begin
    end;
}