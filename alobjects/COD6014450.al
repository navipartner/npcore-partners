codeunit 6014450 "E-mail Management"
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    // PN1.01/MH/20140731             Added Function, AddAdditionalReportsToJmail().
    // PN1.03/MH/20140814             Added Service Module
    // PN1.04/MH/20140819             Added Audit Roll
    // PN1.05/MH/20141020             Changed E-mail popup from using VisualBasic.Interaction as it is not part of the standard client framework thus not compatible with ClickOnce.
    // PN1.06/MH/20141120  CASE 197822 Change E-mail popup from using Touch Alpha Popup to Retail Page Input Dialog.
    // PN1.06/LS/20150522  CASE 205029 : Add bcc and cc emails
    // PN1.07/TSA/20150908 CASE  222416 Problem with file being blocked by other process, move DELETE of file to after smtp send, Refactored to use FileManagement
    // PN1.07/TTH/20151001 CASE  222376 PDF2NAV Changes. The last of the email template attachments came through blank due to a local reference to the .NET assembly.
    // PN1.07/TTH/20151106 CASE 226689 Removed Ansi to Ascii Conversion from the subject field.
    // PN1.08/TTH/10122015 CASE 229069 Added Customer Statement Sending
    // PN1.08/MHA/20151214 CASE 228859 SendSmtpMessage() changed to get smtp setup from E-mail Setup and moved template insert functions to cu 6014464 "E-mail Document Management"
    // PN1.09/MHA/20160115 CASE 231503 Added EmailSetup."Mail Server Port" and EmailSetup."Enable Ssl"
    // PN1.10/MHA/20160314 CASE 235530 Removed Client Side File references
    // PN1.10/MHA/20160314 CASE 236653 "Report Format" (Word) deleted, PrintPdf Rec parameter changed from RecordRef to Variant and added Publisher GetReportIDEvent()
    // NPR5.28/MMV /20161104 CASE 254575 Added functions GetEmailAddressFromRecRef(), GetEmailAddressEvent(), CheckEmailSyntax()
    // NPR5.29/MHA /20170109  CASE 262318 Removed Length on Line Parameter in ParseEmailText()
    // NPR5.31/THRO/20170330 CASE 260773 Report ID and Mailaddress from Custom Report Selection
    // NPR5.33/THRO/20170602 CASE 273294 Added GETLASTERRORTEXT to message when PrintPDF fails
    // NPR5.36/THRO/20170913 CASE 289216 Templates filtered on Group in GetEmailTemplateHeader
    //                                   Added SendEmailTemplate + SendReportTemplate for sending specific emailtemplate
    // NPR5.38/THRO/20171108 CASE 295065 Code referring Custom Report Layout primary key moved to wrapper codeunit
    // NPR5.38/THRO/20171114 CASE 271591 Buffer attachments and add in send function. Removed save to file
    // NPR5.38/TS  /20171120 CASE 296907 Added  Report for Sales Return Order
    // NPR5.38/TS  /20171120 CASE 296906 Added  Report for Purchase Return Order
    // NPR5.38/MHA /20180105  CASE 301053 Corrected ServHeader."Document Type" CASE in GetReportIDFromRecRef()
    // NPR5.38/THRO/20180108  CASE 286713 Added CampaignMonitor Transactional Email
    // NPR5.42/THRO/20180518  CASE 315145 Custom Report Selection used wrong variable
    // NPR5.43/THRO/20180614  CASE 315958 Option to use Request page parameters when printing
    // NPR5.43/THRO/20180626  CASE 318935 Custom fieldnumber Start and End tags in ParseEmailText
    // NPR5.48/THRO/20181119  CASE 336330 Publisher to allow Changing sender Email
    // NPR5.48/MHA /20190123  CASE 341711 Replaced function ParseEmailText() with MergeMailContent() and removed green code
    // NPR5.51/THRO/20190703  CASE 358470 Use Email address from Custom Report Selection


    trigger OnRun()
    begin
    end;

    var
        EmailSetup: Record "E-mail Setup";
        Text001: Label 'Enter recipient''s e-mail address:';
        Text002: Label 'E-mail has been sent.';
        Text003: Label 'The email may not be empty.';
        Text004: Label 'There is not entered any sender email address in the setup.';
        Text006: Label 'The functionality to save report %1 as PDF, returned an error.\\%2';
        Text007: Label 'Shortcut not found.';
        TempBlobReqParamStore: Record TempBlob temporary;
        Initialized: Boolean;
        Text008: Label 'Mail Server not defined in I-Comm';
        Text010: Label 'Would you like to resend the e-mail?';
        Text011: Label 'E-mail Template was not found';
        Text012: Label 'Report ID is 0 which is why PDF can not be generated';
        SmtpMessage: DotNet npNetSmtpMessage;
        UseCustomReportSelection: Boolean;
        GlobalCustomReportSelection: Record "Custom Report Selection";
        AttachmentBuffer: Record "E-mail Attachment" temporary;
        TransactionalType: Option " ",Smart,Classic;
        UseTransactionalEmailCode: Code[20];
        TransactionalEmailRecipient: Text;
        AttachmentNoData: Label 'No data in %1';
        NoOutputFromReport: Label 'No output from report.';
        NoMatchingEnd: Label 'No End-Tag found for Start-Tag at position %1 in %2.';

    procedure SendEmail(var RecRef: RecordRef;RecipientEmail: Text;Silent: Boolean) ErrorMessage: Text
    var
        EmailTemplateHeader: Record "E-mail Template Header";
    begin
        exit(SendEmailTemplate(RecRef,EmailTemplateHeader,RecipientEmail,Silent));
    end;

    procedure SendEmailTemplate(var RecRef: RecordRef;var EmailTemplateHeader: Record "E-mail Template Header";RecipientEmail: Text;Silent: Boolean) ErrorMessage: Text
    begin
        ErrorMessage := SetupEmailTemplate(RecRef,RecipientEmail,Silent,EmailTemplateHeader);
        if EmailTemplateHeader."Default Recipient Address" = '' then
          exit;
        if ErrorMessage = '' then
          ErrorMessage := CreateSmtpMessageFromEmailTemplate(EmailTemplateHeader,RecRef,0);

        if ErrorMessage = '' then
          ErrorMessage := SendSmtpMessage(RecRef,Silent);

        if (ErrorMessage <> '') and not Silent then
          Error(ErrorMessage);

        exit(ErrorMessage);
    end;

    procedure SendReport(ReportID: Integer;var RecRef: RecordRef;RecipientEmail: Text[250];Silent: Boolean): Text
    var
        EmailTemplateHeader: Record "E-mail Template Header";
        FileManagement: Codeunit "File Management";
        Filepath: Text;
        Filename: Text;
        ErrorMessage: Text;
    begin
        exit(SendReportTemplate(ReportID,RecRef,EmailTemplateHeader,RecipientEmail,Silent));
    end;

    procedure SendReportTemplate(ReportID: Integer;var RecRef: RecordRef;var EmailTemplateHeader: Record "E-mail Template Header";RecipientEmail: Text[250];Silent: Boolean): Text
    var
        FileManagement: Codeunit "File Management";
        InStream: InStream;
        Filename: Text;
        ErrorMessage: Text;
    begin
        ErrorMessage := '';
        if ReportID = 0 then
          ErrorMessage := Text012;

        if ErrorMessage = '' then
          ErrorMessage := SetupEmailTemplate(RecRef,RecipientEmail,Silent,EmailTemplateHeader);
        if EmailTemplateHeader."Default Recipient Address" = '' then
          exit;

        if ErrorMessage = '' then
          ErrorMessage := CreateSmtpMessageFromEmailTemplate(EmailTemplateHeader,RecRef,ReportID);

        AddEmailAttachmentsToSmtpMessage(EmailTemplateHeader);

        if ErrorMessage = '' then begin
          Filename := GetFilename(EmailTemplateHeader,RecRef);
          RecRef.SetRecFilter;
          if not PrintPDF(ReportID,RecRef,Filename) then
            ErrorMessage := StrSubstNo(Text006,ReportID,GetLastErrorText);
        end;

        if ErrorMessage = '' then
          ErrorMessage := AddAdditionalReportsToSmtpMessage(EmailTemplateHeader,RecRef);

        if ErrorMessage = '' then
          ErrorMessage := SendSmtpMessage(RecRef,Silent);

        if (ErrorMessage <> '') and not Silent then
          Error(ErrorMessage);

        exit(CopyStr(ErrorMessage,1,1024));
    end;

    procedure "--- SmtpMessage"()
    begin
    end;

    local procedure AddAdditionalReportsToSmtpMessage(EmailTemplateHeader: Record "E-mail Template Header";var RecRef: RecordRef) ErrorMessage: Text
    var
        EmailTemplateReport: Record "E-mail Template Report";
        EmailTemplateMgt: Codeunit "E-mail Template Mgt.";
        Filename: Text[250];
    begin
        EmailTemplateReport.Reset;
        EmailTemplateReport.SetRange("E-mail Template Code",EmailTemplateHeader.Code);
        if EmailTemplateReport.FindSet then
          repeat
            //-NPR5.48 [341711]
            //Filename := ParseEmailText(RecRef,EmailTemplateReport.Filename,EmailTemplateHeader."Fieldnumber Start Tag",EmailTemplateHeader."Fieldnumber End Tag");
            Filename := EmailTemplateMgt.MergeMailContent(RecRef,EmailTemplateReport.Filename,EmailTemplateHeader."Fieldnumber Start Tag",EmailTemplateHeader."Fieldnumber End Tag");
            //+NPR5.48 [341711]
            if StrPos(Filename,'.pdf') = 0 then
              Filename += '.pdf';
            Filename := ReplaceSpecialChar(Filename);

            if not PrintPDF(EmailTemplateReport."Report ID",RecRef,Filename) then
              ErrorMessage := StrSubstNo(Text006,EmailTemplateReport."Report ID",GetLastErrorText);
          until (EmailTemplateReport.Next = 0) or (ErrorMessage <> '');

        exit(ErrorMessage);
    end;

    local procedure AddEmailAttachmentsToSmtpMessage(EmailTemplateHeader: Record "E-mail Template Header")
    var
        EmailAttachment: Record "E-mail Attachment";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(EmailTemplateHeader);
        EmailAttachment.SetRange("Table No.",RecRef.Number);
        EmailAttachment.SetRange("Primary Key",RecRef.GetPosition(false));
        if EmailAttachment.FindSet then
          repeat
            if EmailAttachment.Description <> '' then begin
              EmailAttachment.CalcFields("Attached File");
              AddAttachmentToBuffer(EmailAttachment);
            end;
          until EmailAttachment.Next = 0;
    end;

    procedure AddFileToSmtpMessage(Filename: Text[250]) FileAttached: Boolean
    var
        AttachmentFile: File;
        EmailAttachmentTemp: Record "E-mail Attachment" temporary;
        InStream: InStream;
        OutStream: OutStream;
        Pos: Integer;
    begin
        if not Exists(Filename) then
          exit(false);

        AttachmentFile.Open(Filename);
        AttachmentFile.CreateInStream(InStream);
        EmailAttachmentTemp.Init;
        EmailAttachmentTemp."Attached File".CreateOutStream(OutStream);
        CopyStream(OutStream,InStream);
        Pos := StrPos(Filename,'\');
        while Pos > 0 do begin
          Filename := CopyStr(Filename,Pos+1);
          Pos := StrPos(Filename,'\');
        end;
        EmailAttachmentTemp.Description := ReplaceSpecialChar(Filename);
        EmailAttachmentTemp.Insert;
        AddAttachmentToBuffer(EmailAttachmentTemp);
        AttachmentFile.Close;
        exit(true);
    end;

    procedure AddAttachmentToSmtpMessage(var EmailAttachment: Record "E-mail Attachment"): Boolean
    begin
        exit(AddAttachmentToBuffer(EmailAttachment));
    end;

    local procedure AddAttachmentToBuffer(var EmailAttachment: Record "E-mail Attachment"): Boolean
    var
        NextAttachmentLineNo: Integer;
    begin
        EmailAttachment.CalcFields("Attached File");
        if not EmailAttachment."Attached File".HasValue then begin
          SetLastErrorMessage(StrSubstNo(AttachmentNoData,EmailAttachment.Description));
          exit(false);
        end;
        AttachmentBuffer.Reset;
        if AttachmentBuffer.FindLast then
          NextAttachmentLineNo := AttachmentBuffer."Line No." + 1
        else
          NextAttachmentLineNo := 1;
        AttachmentBuffer := EmailAttachment;
        AttachmentBuffer."Table No." := 0;
        AttachmentBuffer."Primary Key" := '';
        AttachmentBuffer."Line No." := NextAttachmentLineNo;
        AttachmentBuffer.Insert;
        exit(true);
    end;

    procedure CreateSmtpMessageFromEmailTemplate(EmailTemplateHeader: Record "E-mail Template Header";var RecRef: RecordRef;ReportID: Integer) ErrorMessage: Text[1024]
    var
        EmailTemplateLine: Record "E-mail Template Line";
        EmailTemplateMgt: Codeunit "E-mail Template Mgt.";
        FileManagement: Codeunit "File Management";
        Email: Text;
        EmailString: Text;
        Filepath: Text;
        Filename: Text;
        HtmlLine: Text;
        InStream: InStream;
        i: Integer;
    begin
        if not IsNull(SmtpMessage) then
          SmtpMessage.Dispose;
        SmtpMessage := SmtpMessage.SmtpMessage;
        if EmailTemplateHeader."Default Recipient Address" = '' then
          exit(Text003);
        if EmailTemplateHeader."From E-mail Address" = '' then
          exit(Text004);
        UseTransactionalEmailCode := '';
        TransactionalType := 0;
        if (EmailTemplateHeader."Transactional E-mail" = EmailTemplateHeader."Transactional E-mail"::"Campaign Monitor Transactional") then begin
          TransactionalType := TransactionalType::Classic;
          TransactionalEmailRecipient := EmailTemplateHeader."Default Recipient Address";
          if EmailTemplateHeader."Transactional E-mail Code" <> '' then begin
            TransactionalType := TransactionalType::Smart;
            UseTransactionalEmailCode := EmailTemplateHeader."Transactional E-mail Code";
          end;
        end;

        SmtpMessage.AddRecipients(EmailTemplateHeader."Default Recipient Address");

        SmtpMessage.FromAddress := EmailTemplateHeader."From E-mail Address";
        SmtpMessage.FromName := EmailTemplateHeader."From E-mail Name";
        if EmailTemplateHeader."Sender as bcc" then
          SmtpMessage.AddBCC(EmailTemplateHeader."From E-mail Address");

        EmailString := EmailTemplateHeader."Default Recipient Address CC";
        while EmailString <> '' do begin
          Email := CutNextEmail(EmailString);
          if Email <> '' then
            SmtpMessage.AddCC(Email);
        end;

        EmailString := EmailTemplateHeader."Default Recipient Address BCC";
        while EmailString <> '' do begin
          Email := CutNextEmail(EmailString);
          if Email <> '' then
            SmtpMessage.AddBCC(Email);
        end;

        if TransactionalType <> TransactionalType::Smart then begin
          //-NPR5.48 [341711]
          //SmtpMessage.Subject(ParseEmailText(RecRef,EmailTemplateHeader.Subject,EmailTemplateHeader."Fieldnumber Start Tag",EmailTemplateHeader."Fieldnumber End Tag"));
          HtmlLine := EmailTemplateMgt.MergeMailContent(RecRef,EmailTemplateHeader.Subject,EmailTemplateHeader."Fieldnumber Start Tag",EmailTemplateHeader."Fieldnumber End Tag");
          SmtpMessage.Subject(HtmlLine);
          //+NPR5.48 [341711]
          SmtpMessage.HtmlFormatted(true);
          if not EmailTemplateHeader."Use HTML Template" then begin
            EmailTemplateLine.SetRange("E-mail Template Code",EmailTemplateHeader.Code);
            if EmailTemplateLine.FindSet then
              repeat
                //-NPR5.48 [341711]
                //SmtpMessage.AppendBody(ParseEmailText(RecRef,EmailTemplateLine."Mail Body Line",EmailTemplateHeader."Fieldnumber Start Tag",EmailTemplateHeader."Fieldnumber End Tag") + '<br/>' );
                HtmlLine := EmailTemplateMgt.MergeMailContent(RecRef,EmailTemplateLine."Mail Body Line",EmailTemplateHeader."Fieldnumber Start Tag",EmailTemplateHeader."Fieldnumber End Tag") + '<br/>';
                SmtpMessage.AppendBody(HtmlLine);
                //+NPR5.48 [341711]
              until EmailTemplateLine.Next = 0;
          end else begin
            EmailTemplateHeader.CalcFields("HTML Template");
            if EmailTemplateHeader."HTML Template".HasValue then begin
              //-NPR5.48 [341711]
              //EmailTemplateHeader."HTML Template".CREATEINSTREAM(InStream);
              EmailTemplateHeader."HTML Template".CreateInStream(InStream,TEXTENCODING::UTF8);
              //+NPR5.48 [341711]
              while not InStream.EOS do begin
                HtmlLine := '';
                InStream.ReadText(HtmlLine);
                //-NPR5.48 [341711]
                //SmtpMessage.AppendBody(ParseEmailText(RecRef, HtmlLine,EmailTemplateHeader."Fieldnumber Start Tag",EmailTemplateHeader."Fieldnumber End Tag") + '<br/>' );
                HtmlLine := EmailTemplateMgt.MergeMailContent(RecRef,HtmlLine,EmailTemplateHeader."Fieldnumber Start Tag",EmailTemplateHeader."Fieldnumber End Tag") + '<br/>';
                SmtpMessage.AppendBody(HtmlLine);
                //+NPR5.48 [341711]
              end;
              Clear(InStream);
            end;
          end;
        end;

        AttachmentBuffer.DeleteAll;

        exit('');
    end;

    procedure SendSmtpMessage(var RecRef: RecordRef;Silent: Boolean) ErrorMessage: Text[1024]
    var
        TransactionalEmail: Record "Smart Email";
        CampaignMonitorMgt: Codeunit "CampaignMonitor Mgt.";
        InStream: InStream;
        HandledByTransactional: Boolean;
        FromName: Text;
        FromAddress: Text;
    begin
        if TransactionalType = TransactionalType::Smart then
          if TransactionalEmail.Get(UseTransactionalEmailCode) then begin
            ErrorMessage := CopyStr(CampaignMonitorMgt.SendSmartEmailWAttachment(TransactionalEmail,TransactionalEmailRecipient,SmtpMessage.CC,SmtpMessage.Bcc,RecRef,AttachmentBuffer,Silent),1,MaxStrLen(ErrorMessage));
            HandledByTransactional := true;
          end;
        if TransactionalType = TransactionalType::Classic then begin
          FromName := SmtpMessage.FromName;
          FromAddress := SmtpMessage.FromAddress;
          if (FromName <> '') and (FromName <> FromAddress) then
            FromAddress := StrSubstNo('%1 %2',FromName,FromAddress);
          ErrorMessage := CampaignMonitorMgt.SendClasicMail(TransactionalEmailRecipient,SmtpMessage.CC,SmtpMessage.Bcc,SmtpMessage.Subject,SmtpMessage.Body,'',FromAddress,'',true,true,'','',AttachmentBuffer,Silent);
          HandledByTransactional := true;
        end;

        if not HandledByTransactional then begin
          Initialize();
          if EmailSetup."Mail Server" = '' then begin
            if Silent then
              exit(Text008);
            Error(Text008);
          end;
          if EmailSetup."Mail Server Port" <= 0 then
            EmailSetup."Mail Server Port" := 25;
          AttachmentBuffer.Reset;
          if AttachmentBuffer.FindSet then
            repeat
              if AttachmentBuffer.Description <> '' then begin
                AttachmentBuffer.CalcFields("Attached File");
                Clear(InStream);
                if AttachmentBuffer."Attached File".HasValue then begin
                  AttachmentBuffer."Attached File".CreateInStream(InStream);
                end;
                if (StrLen(SmtpMessage.AddAttachment(InStream,AttachmentBuffer.Description))>0) then
                  Clear(InStream);
              end;
            until AttachmentBuffer.Next = 0;
          ErrorMessage := SmtpMessage.Send(EmailSetup."Mail Server",EmailSetup."Mail Server Port",EmailSetup.Username <> '',
                                           EmailSetup.Username,EmailSetup.Password,EmailSetup."Enable Ssl");
        end;
        AttachmentBuffer.DeleteAll;

        if ErrorMessage = '' then begin
          AddEmailLogEntry(RecRef);
          SmtpMessage.Dispose();
          Clear(SmtpMessage);

          if Silent then
            exit('')
          else begin
            Message(Text002);
            exit('');
          end;
        end else begin
          SmtpMessage.Dispose();
          Clear(SmtpMessage);

          if Silent then
            exit(ErrorMessage)
          else
            Error(ErrorMessage);
        end;
    end;

    procedure "--- Setup"()
    begin
    end;

    procedure SetupEmailTemplate(var RecRef: RecordRef;RecipientEmail: Text[250];Silent: Boolean;var EmailTemplateHeader: Record "E-mail Template Header") ErrorMessage: Text[1024]
    begin
        ErrorMessage := '';
        if GetEmailTemplateHeader(RecRef,EmailTemplateHeader) then begin
          if Silent then
            EmailTemplateHeader."Verify Recipient" := false;
          EmailTemplateHeader."Default Recipient Address" := GetEmailRecepientAddress(EmailTemplateHeader,RecipientEmail);
          EmailTemplateHeader."From E-mail Address" := GetEmailFromAddress(EmailTemplateHeader);
          EmailTemplateHeader."From E-mail Name" := GetEmailFromName(EmailTemplateHeader);
          //-NPR5.48 [336330]
          OnAfterSetFromEmail(EmailTemplateHeader.Code,RecRef,RecipientEmail,Silent,EmailTemplateHeader."From E-mail Address",EmailTemplateHeader."From E-mail Name");
          //+NPR5.48 [336330]
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

    procedure "--- PDF"()
    begin
    end;

    local procedure PrintPDF(ReportID: Integer;RecVariant: Variant;Filename: Text): Boolean
    var
        EmailAttachmentTemp: Record "E-mail Attachment" temporary;
        Result: Boolean;
        OStream: OutStream;
        Parameters: Text;
    begin
        SetGlobalCustomReport;
        EmailAttachmentTemp.Description := Filename;
        EmailAttachmentTemp."Attached File".CreateOutStream(OStream);
        Parameters := GetReqParametersFromStore(ReportID);
        Result := REPORT.SaveAs(ReportID,Parameters,REPORTFORMAT::Pdf,OStream,RecVariant);
        ClearRequestParameters(ReportID);
        if not EmailAttachmentTemp."Attached File".HasValue then begin
          Result := false;
          SetLastErrorMessage(NoOutputFromReport);
        end;
        if Result then begin
          EmailAttachmentTemp.Insert;
          Result := AddAttachmentToBuffer(EmailAttachmentTemp);
        end;

        ClearGlobalCustomReport;
        exit(Result);
    end;

    procedure "--- Get"()
    begin
    end;

    local procedure GetEmailFromAddress(EmailTemplateHeader: Record "E-mail Template Header") NewEmailFromAddress: Text[250]
    begin
        Initialize();
        if EmailTemplateHeader."From E-mail Address" <> '' then
          exit(EmailTemplateHeader."From E-mail Address");

        exit(EmailSetup."From E-mail Address");
    end;

    local procedure GetEmailFromName(EmailTemplateHeader: Record "E-mail Template Header") NewEmailFromAddress: Text[250]
    begin
        Initialize();
        if EmailTemplateHeader."From E-mail Name" <> '' then
          exit(EmailTemplateHeader."From E-mail Name");

        exit(EmailSetup."From Name");
    end;

    local procedure GetEmailRecepientAddress(EmailTemplateHeader: Record "E-mail Template Header";EmailRecipientAddress: Text[250]) NewEmailRecipientAddress: Text[250]
    begin
        NewEmailRecipientAddress := EmailRecipientAddress;
        if NewEmailRecipientAddress = '' then
          NewEmailRecipientAddress := EmailTemplateHeader."Default Recipient Address";

        if EmailTemplateHeader."Verify Recipient" or (NewEmailRecipientAddress = '') then
          NewEmailRecipientAddress := VerifyEmailAddress(NewEmailRecipientAddress);

        exit(NewEmailRecipientAddress);
    end;

    procedure GetEmailTemplateHeader(var RecRef: RecordRef;var EmailTemplateHeader: Record "E-mail Template Header") RecordExists: Boolean
    var
        EmailTemplateFilter: Record "E-mail Template Filter";
        FieldRef: FieldRef;
        ValueInt: Integer;
        Value: Text[250];
        Stop: Boolean;
    begin
        if EmailTemplateHeader.GetFilters = '' then
          EmailTemplateHeader.SetFilter(Group,'%1',GetDefaultGroupFilter);
        EmailTemplateHeader.SetRange("Table No.",RecRef.Number);
        if EmailTemplateHeader.Find('-') then repeat
          RecordExists := true;
          EmailTemplateFilter.SetRange("E-mail Template Code",EmailTemplateHeader.Code);
          EmailTemplateFilter.SetRange("Table No.",EmailTemplateHeader."Table No.");
          if EmailTemplateFilter.Find('-') then repeat
            RecordExists := false;
            FieldRef := RecRef.Field(EmailTemplateFilter."Field No.");
            FieldRef.SetFilter(EmailTemplateFilter.Value);
            if RecRef.Find then
              RecordExists := true;
            FieldRef.SetRange();
          until not RecordExists or  (EmailTemplateFilter.Next = 0);
          if RecordExists then
            Stop := true
          else Stop := EmailTemplateHeader.Next = 0;
        until Stop;

        if not RecordExists then begin
          if EmailTemplateHeader.Find('-') then repeat
            RecordExists := true;
            EmailTemplateFilter.SetRange("E-mail Template Code",EmailTemplateHeader.Code);
            EmailTemplateFilter.SetRange("Table No.",EmailTemplateHeader."Table No.");
            if EmailTemplateFilter.Find('-') then repeat
              RecordExists := false;
              FieldRef := RecRef.Field(EmailTemplateFilter."Field No.");
              FieldRef.SetFilter(EmailTemplateFilter.Value);
              if RecRef.Find then
                RecordExists := true;
              FieldRef.SetRange();
            until not RecordExists or  (EmailTemplateFilter.Next = 0);
            if RecordExists then
              Stop := true
            else Stop := EmailTemplateHeader.Next = 0;
          until Stop;
        end;

        exit(RecordExists);
    end;

    procedure GetFilename(EmailTemplateHeader: Record "E-mail Template Header";var RecRef: RecordRef) Filename: Text
    var
        EmailTemplateMgt: Codeunit "E-mail Template Mgt.";
    begin
        //-NPR5.48 [341711]
        //Filename := ParseEmailText(RecRef,EmailTemplateHeader.Filename,EmailTemplateHeader."Fieldnumber Start Tag",EmailTemplateHeader."Fieldnumber End Tag");
        Filename := EmailTemplateMgt.MergeMailContent(RecRef,EmailTemplateHeader.Filename,EmailTemplateHeader."Fieldnumber Start Tag",EmailTemplateHeader."Fieldnumber End Tag");
        //-NPR5.48 [341711]

        if StrPos(Filename,'.pdf') = 0 then
          Filename += '.pdf';

        Filename := ReplaceSpecialChar(Filename);
    end;

    local procedure GetMailServer() MailServer: Text[250]
    begin
        Initialize();
        MailServer := EmailSetup."Mail Server";
    end;

    [IntegrationEvent(false, false)]
    local procedure GetReportIDEvent(RecRef: RecordRef;var ReportID: Integer)
    begin
    end;

    procedure GetReportIDFromRecRef(RecRef: RecordRef) ReportID: Integer
    var
        EmailTemplateHeader: Record "E-mail Template Header";
        PurchHeader: Record "Purchase Header";
        ReportSelections: Record "Report Selections";
        SalesHeader: Record "Sales Header";
        ServHeader: Record "Service Header";
        CustomReportSelection: Record "Custom Report Selection";
    begin
        ReportID := 0;
        GetReportIDEvent(RecRef,ReportID);

        //-NPR5.51 [358470]
        if ReportID = 0 then
          if GetEmailTemplateHeader(RecRef,EmailTemplateHeader) and (EmailTemplateHeader."Report ID" <> 0) then
            ReportID := EmailTemplateHeader."Report ID";

        if ReportID > 0 then begin
          case RecRef.Number of
            DATABASE::"Sales Cr.Memo Header":
              GetCustomEmailForReportID(DATABASE::Customer,Format(RecRef.Field(4).Value),ReportSelections.Usage::"S.Cr.Memo",EmailTemplateHeader."Report ID");
            DATABASE::"Sales Header":
              begin
                RecRef.SetTable(SalesHeader);
                case SalesHeader."Document Type" of
                  SalesHeader."Document Type"::Quote:
                    GetCustomEmailForReportID(DATABASE::Customer,SalesHeader."Bill-to Customer No.",ReportSelections.Usage::"S.Quote",EmailTemplateHeader."Report ID");
                  SalesHeader."Document Type"::Order:
                    GetCustomEmailForReportID(DATABASE::Customer,SalesHeader."Bill-to Customer No.",ReportSelections.Usage::"S.Order",EmailTemplateHeader."Report ID");
                  SalesHeader."Document Type"::"Return Order":
                    GetCustomEmailForReportID(DATABASE::Customer,SalesHeader."Bill-to Customer No.",ReportSelections.Usage::"S.Return",EmailTemplateHeader."Report ID");
                end;
              end;
            DATABASE::"Sales Invoice Header":
              GetCustomEmailForReportID(DATABASE::Customer,Format(RecRef.Field(4).Value),ReportSelections.Usage::"S.Invoice",EmailTemplateHeader."Report ID");
          end;
          exit(ReportID);
        end;
        //+NPR5.51 [358470]


        Clear(ReportSelections);
        ReportSelections.SetFilter("Report ID",'<>%1',0);
        case RecRef.Number of
          DATABASE::"Issued Reminder Header":
            begin
              ReportSelections.SetRange(Usage,ReportSelections.Usage::Reminder);
              if ReportSelections.FindFirst then
                ReportID := ReportSelections."Report ID";
            end;
          DATABASE::"Issued Fin. Charge Memo Header":
            begin
              ReportSelections.SetRange(Usage,ReportSelections.Usage::"Fin.Charge");
              if ReportSelections.FindFirst then
                ReportID := ReportSelections."Report ID";
            end;
          DATABASE::"Sales Cr.Memo Header":
            begin
              ReportID := GetCustomReportSelection(DATABASE::Customer,Format(RecRef.Field(4).Value),ReportSelections.Usage::"S.Cr.Memo");
              if ReportID = 0 then begin
                ReportSelections.SetRange(Usage,ReportSelections.Usage::"S.Cr.Memo");
                if ReportSelections.FindFirst then
                  ReportID := ReportSelections."Report ID";
              end;
            end;
          DATABASE::"Sales Header":
            begin
              RecRef.SetTable(SalesHeader);
              case SalesHeader."Document Type" of
                SalesHeader."Document Type"::Quote:
                  begin
                    ReportID := GetCustomReportSelection(DATABASE::Customer,SalesHeader."Bill-to Customer No.",ReportSelections.Usage::"S.Quote");
                    if ReportID = 0 then begin
                      ReportSelections.SetRange(Usage,ReportSelections.Usage::"S.Quote");
                      if ReportSelections.FindFirst then
                        ReportID := ReportSelections."Report ID";
                    end;
                  end;
                SalesHeader."Document Type"::Order:
                  begin
                    ReportID := GetCustomReportSelection(DATABASE::Customer,SalesHeader."Bill-to Customer No.",ReportSelections.Usage::"S.Order");
                    if ReportID = 0 then begin
                      ReportSelections.SetRange(Usage,ReportSelections.Usage::"S.Order");
                      if ReportSelections.FindFirst then
                        ReportID := ReportSelections."Report ID";
                    end;
                  end;
                SalesHeader."Document Type"::"Return Order":
                  begin
                    ReportID := GetCustomReportSelection(DATABASE::Customer,SalesHeader."Bill-to Customer No.",ReportSelections.Usage::"S.Return");
                    if ReportID = 0 then begin
                      ReportSelections.SetRange(Usage,ReportSelections.Usage::"S.Return");
                      if ReportSelections.FindFirst then
                        ReportID := ReportSelections."Report ID";
                    end;
                  end;
              end;
            end;
          DATABASE::"Sales Invoice Header":
            begin
              ReportID := GetCustomReportSelection(DATABASE::Customer,Format(RecRef.Field(4).Value),ReportSelections.Usage::"S.Invoice");
              if ReportID = 0 then begin
                ReportSelections.SetRange(Usage,ReportSelections.Usage::"S.Invoice");
                if ReportSelections.FindFirst then
                  ReportID := ReportSelections."Report ID";
              end;
            end;
          DATABASE::"Sales Shipment Header":
            begin
              ReportSelections.SetRange(Usage,ReportSelections.Usage::"S.Shipment");
              if ReportSelections.FindFirst then
                ReportID := ReportSelections."Report ID";
            end;
          DATABASE::"Purch. Cr. Memo Hdr.":
            begin
              ReportSelections.SetRange(Usage,ReportSelections.Usage::"P.Cr.Memo");
              if ReportSelections.FindFirst then
                ReportID := ReportSelections."Report ID";
            end;
          DATABASE::"Purchase Header":
            begin
              RecRef.SetTable(PurchHeader);
              case PurchHeader."Document Type" of
                PurchHeader."Document Type"::Quote:
                  begin
                    ReportSelections.SetRange(Usage,ReportSelections.Usage::"P.Quote");
                    if ReportSelections.FindFirst then
                      ReportID := ReportSelections."Report ID";
                  end;
                PurchHeader."Document Type"::Order:
                  begin
                    ReportSelections.SetRange(Usage,ReportSelections.Usage::"P.Order");
                    if ReportSelections.FindFirst then
                      ReportID := ReportSelections."Report ID";
                  end;
                PurchHeader."Document Type"::"Return Order":
                  begin
                    ReportSelections.SetRange(Usage,ReportSelections.Usage::"P.Return");
                    if ReportSelections.FindFirst then
                      ReportID := ReportSelections."Report ID";
                  end;
              end;
            end;
          DATABASE::"Purch. Inv. Header":
            begin
              ReportSelections.SetRange(Usage,ReportSelections.Usage::"P.Invoice");
              if ReportSelections.FindFirst then
                ReportID := ReportSelections."Report ID";
            end;
          DATABASE::"Purch. Rcpt. Header":
            begin
              ReportSelections.SetRange(Usage,ReportSelections.Usage::"P.Receipt");
              if ReportSelections.FindFirst then
                ReportID := ReportSelections."Report ID";
            end;
          DATABASE::"Service Header" :
            begin
              RecRef.SetTable(ServHeader);
              case ServHeader."Document Type" of
                ServHeader."Document Type"::Quote:
                  begin
                    ReportSelections.SetRange(Usage,ReportSelections.Usage::"SM.Quote");
                    if ReportSelections.FindFirst then
                      ReportID := ReportSelections."Report ID";
                  end;
                ServHeader."Document Type"::Order:
                  begin
                    ReportSelections.SetRange(Usage,ReportSelections.Usage::"SM.Order");
                    if ReportSelections.FindFirst then
                      ReportID := ReportSelections."Report ID";
                  end;
              end;
            end;
          DATABASE::"Service Shipment Header":
            begin
              ReportSelections.SetRange(Usage,ReportSelections.Usage::"SM.Shipment");
              if ReportSelections.FindFirst then
                ReportID := ReportSelections."Report ID";
            end;
          DATABASE::"Service Invoice Header":
            begin
              ReportSelections.SetRange(Usage,ReportSelections.Usage::"SM.Invoice");
              if ReportSelections.FindFirst then
                ReportID := ReportSelections."Report ID";
            end;
        end;

        exit(ReportID);
    end;

    [IntegrationEvent(false, false)]
    local procedure GetEmailAddressEvent(var RecRef: RecordRef;var EmailAddress: Text;var Handled: Boolean)
    begin
    end;

    procedure GetEmailAddressFromRecRef(var RecRef: RecordRef): Text
    var
        EmailAddress: Text;
        Handled: Boolean;
        Customer: Record Customer;
    begin
        GetEmailAddressEvent(RecRef,EmailAddress,Handled);
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

    local procedure GetCustomReportSelection(SourceType: Integer;BillToCustomer: Code[20];NewUsage: Option "S.Quote","S.Order","S.Invoice","S.Cr.Memo","S.Test","P.Quote","P.Order","P.Invoice","P.Cr.Memo","P.Receipt","P.Ret.Shpt.","P.Test","B.Stmt","B.Recon.Test","B.Check",Reminder,"Fin.Charge","Rem.Test","F.C.Test","Prod. Order","S.Blanket","P.Blanket",M1,M2,M3,M4,Inv1,Inv2,Inv3,"SM.Quote","SM.Order","SM.Invoice","SM.Credit Memo","SM.Contract Quote","SM.Contract","SM.Test","S.Return","P.Return","S.Shipment","S.Ret.Rcpt.","S.Work Order","Invt. Period Test","SM.Shipment","S.Test Prepmt.","P.Test Prepmt.","S.Arch. Quote","S.Arch. Order","P.Arch. Quote","P.Arch. Order","S. Arch. Return Order","P. Arch. Return Order","Asm. Order","P.Assembly Order","S.Order Pick Instruction",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"C.Statement","V.Remittance") ReportID: Integer
    var
        CustomReportSelection: Record "Custom Report Selection";
        EmailNaviDocsMgtWrapper: Codeunit "E-mail NaviDocs Mgt. Wrapper";
    begin
        CustomReportSelection.SetRange("Source Type",SourceType);
        CustomReportSelection.SetRange("Source No.",BillToCustomer);
        CustomReportSelection.SetRange(Usage,NewUsage);
        ReportID := 0;
        if CustomReportSelection.FindFirst then begin
          ReportID := CustomReportSelection."Report ID";
          if EmailNaviDocsMgtWrapper.HasCustomReportLayout(CustomReportSelection) or
              (CustomReportSelection."Send To Email" <> '') then begin
            UseCustomReportSelection := true;
            GlobalCustomReportSelection := CustomReportSelection;
          end;
        end;
        exit(ReportID);
    end;

    local procedure GetCustomEmailForReportID(SourceType: Integer;BillToCustomer: Code[20];NewUsage: Option "S.Quote","S.Order","S.Invoice","S.Cr.Memo","S.Test","P.Quote","P.Order","P.Invoice","P.Cr.Memo","P.Receipt","P.Ret.Shpt.","P.Test","B.Stmt","B.Recon.Test","B.Check",Reminder,"Fin.Charge","Rem.Test","F.C.Test","Prod. Order","S.Blanket","P.Blanket",M1,M2,M3,M4,Inv1,Inv2,Inv3,"SM.Quote","SM.Order","SM.Invoice","SM.Credit Memo","SM.Contract Quote","SM.Contract","SM.Test","S.Return","P.Return","S.Shipment","S.Ret.Rcpt.","S.Work Order","Invt. Period Test","SM.Shipment","S.Test Prepmt.","P.Test Prepmt.","S.Arch. Quote","S.Arch. Order","P.Arch. Quote","P.Arch. Order","S. Arch. Return Order","P. Arch. Return Order","Asm. Order","P.Assembly Order","S.Order Pick Instruction",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"C.Statement","V.Remittance";ReportID: Integer)
    var
        CustomReportSelection: Record "Custom Report Selection";
        EmailNaviDocsMgtWrapper: Codeunit "E-mail NaviDocs Mgt. Wrapper";
    begin
        //-NPR5.51 [358470]
        if UseCustomReportSelection then
          exit;
        CustomReportSelection.SetRange("Source Type",SourceType);
        CustomReportSelection.SetRange("Source No.",BillToCustomer);
        CustomReportSelection.SetRange(Usage,NewUsage);
        CustomReportSelection.SetRange("Report ID",ReportID);
        if not CustomReportSelection.FindFirst then begin
          CustomReportSelection.SetRange("Report ID",0);
          if not CustomReportSelection.FindFirst then
            exit;
        end;
        if CustomReportSelection."Send To Email" <> '' then begin
          UseCustomReportSelection := true;
          GlobalCustomReportSelection := CustomReportSelection;
        end;
        //+NPR5.51 [358470]
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
        EmailNaviDocsMgtWrapper: Codeunit "E-mail NaviDocs Mgt. Wrapper";
        CustomReportLayoutVariant: Variant;
    begin
        if UseCustomReportSelection then
          if EmailNaviDocsMgtWrapper.HasCustomReportLayout(GlobalCustomReportSelection) then begin
            EmailNaviDocsMgtWrapper.GetCustomReportLayoutVariant(GlobalCustomReportSelection,CustomReportLayoutVariant);
            ReportLayoutSelection.SetTempLayoutSelected(CustomReportLayoutVariant);
          end;
    end;

    local procedure ClearGlobalCustomReport()
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomReportSelection: Record "Custom Report Selection";
        EmailNaviDocsMgtWrapper: Codeunit "E-mail NaviDocs Mgt. Wrapper";
        BlankVariant: Variant;
    begin
        if UseCustomReportSelection then begin
          EmailNaviDocsMgtWrapper.GetCustomReportLayoutVariant(CustomReportSelection,BlankVariant);
          ReportLayoutSelection.SetTempLayoutSelected(BlankVariant);
        end;
    end;

    procedure StoreRequestParameters(ReportID: Integer;Parameters: Text)
    var
        OutStr: OutStream;
    begin
        if TempBlobReqParamStore.Get(ReportID) then begin
          TempBlobReqParamStore.Blob.CreateOutStream(OutStr);
          OutStr.WriteText(Parameters);
          TempBlobReqParamStore.Modify;
        end else begin
          TempBlobReqParamStore.Init;
          TempBlobReqParamStore.Blob.CreateOutStream(OutStr);
          OutStr.WriteText(Parameters);
          TempBlobReqParamStore."Primary Key" := ReportID;
          TempBlobReqParamStore.Insert;
        end;
    end;

    local procedure GetReqParametersFromStore(ReportID: Integer): Text
    var
        InStr: InStream;
        Parameters: Text;
    begin
        if TempBlobReqParamStore.Get(ReportID) then begin
          TempBlobReqParamStore.CalcFields(Blob);
          TempBlobReqParamStore.Blob.CreateInStream(InStr);
          InStr.ReadText(Parameters);
          exit(Parameters);
        end else
          exit('');
    end;

    procedure ClearRequestParameters(ReportID: Integer)
    begin
        if TempBlobReqParamStore.Get(ReportID) then
          TempBlobReqParamStore.Delete;
    end;

    procedure "--- Email Log"()
    begin
    end;

    local procedure AddEmailLogEntry(RecRef: RecordRef)
    var
        EmailLog: Record "E-mail Log";
        Chr: array [2] of Char;
        i: Integer;
    begin
        Chr[1] := 13;
        Chr[2] := 10;
        EmailLog.Init;
        EmailLog."Table No." := RecRef.Number;
        EmailLog."Primary Key" := RecRef.GetPosition(false);
        EmailLog."Sent Time" := Time;
        EmailLog."Sent Date" := Today;
        EmailLog."Sent Username" := UserId;
        EmailLog."Recipient E-mail" := CopyStr(SmtpMessage."To",1,MaxStrLen(EmailLog."Recipient E-mail"));
        EmailLog."From E-mail" := CopyStr(SmtpMessage.FromAddress,1,MaxStrLen(EmailLog."From E-mail"));
        EmailLog."E-mail subject" := CopyStr(SmtpMessage.Subject,1,MaxStrLen(EmailLog."E-mail subject"));
        EmailLog.Insert(true);
    end;

    local procedure EmailLogExists(RecRef: RecordRef): Boolean
    var
        EmailLog: Record "E-mail Log";
    begin
        Clear(EmailLog);
        EmailLog.SetRange("Table No.",RecRef.Number);
        EmailLog.SetRange("Primary Key",RecRef.GetPosition(false));
        exit(EmailLog.FindFirst);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CutNextEmail(var EmailString: Text[1024]) NextEmail: Text[1024]
    var
        Position: Integer;
    begin
        if EmailString = '' then
          exit('');

        EmailString := ConvertStr(EmailString,',',';');
        Position := StrPos(EmailString,';');
        case Position of
          0:
            begin
              NextEmail := EmailString;
              EmailString := '';
            end;
          1:
            begin
              NextEmail := '';
              EmailString := '';
            end;
          else begin
            NextEmail := CopyStr(EmailString,1,Position - 1);
            EmailString := DelStr(EmailString,1,Position);
          end;
        end;
        exit(NextEmail);
    end;

    local procedure Initialize()
    begin
        if not Initialized then begin
          EmailSetup.Get;
          Initialized := true;
        end;
    end;

    local procedure ReplaceSpecialChar(Input: Text) Output: Text
    var
        i: Integer;
    begin
        Output := '';
        for i := 1 to StrLen(Input) do
          case Input[i] of
            '0','1','2','3','4','5','6','7','8','9',
            'a','b','c','d','e','f','g','h','i','j','A','B','C','D','E','F','G','H','I','J',
            'k','l','m','n','o','p','q','r','s','t','K','L','M','N','O','P','Q','R','S','T',
            'u','v','w','x','y','z','U','V','W','X','Y','Z','-','.': Output += Format(Input[i]);
            'æ': Output += 'ae';
            'ø','ö': Output += 'oe';
            'å','ä': Output += 'aa';
            'è','é','ë','ê': Output += 'e';
            'Æ': Output += 'AE';
            'Ø','Ö': Output += 'OE';
            'Å','Ä': Output += 'AA';
            'É','È','Ë','Ê': Output += 'E';
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
        MailManagement.CheckValidEmailAddress (EmailAddress);
    end;

    local procedure SetLastErrorMessage(ErrorMessage: Text)
    begin
        asserterror Error(ErrorMessage);
    end;

    procedure "--- UI"()
    begin
    end;

    procedure ConfirmResendEmail(var RecRef: RecordRef): Boolean
    begin
        if EmailLogExists(RecRef) then
          exit(Confirm(Text010));

        exit(true);
    end;

    procedure RunEmailLog(RecRef: RecordRef)
    var
        EmailLog: Record "E-mail Log";
    begin
        Clear(EmailLog);
        EmailLog.SetRange("Table No.",RecRef.Number);
        EmailLog.SetRange("Primary Key",RecRef.GetPosition(false));
        PAGE.Run(PAGE::"E-mail Log",EmailLog);
    end;

    local procedure VerifyEmailAddress(RecipientEmail: Text) NewRecipientEmail: Text
    var
        InputDialog: Page "Input Dialog";
    begin
        Clear(InputDialog);
        InputDialog.SetInput(1,RecipientEmail,Text001);
        InputDialog.LookupMode(true);
        if InputDialog.RunModal <> ACTION::LookupOK then
          exit('');

        InputDialog.InputText(1,NewRecipientEmail);

        exit(NewRecipientEmail);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetFromEmail(EmailTemplateHeaderCode: Code[20];RecRef: RecordRef;RecipientEmail: Text[250];Silent: Boolean;var FromEmailAddress: Text[80];var FromEmailName: Text[80])
    begin
    end;
}

