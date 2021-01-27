codeunit 6014502 "NPR SMS"
{
    var
        ServiceCalc: Codeunit "NPR Service Calculation";
        IComm: Record "NPR I-Comm";
        ErrEmpty: Label 'Sms message and/or Phone No. is blank';
        SendFailedErr: Label 'Upload to Endpoint %1 failed.';

    procedure SendSMS(Tlf: Code[20]; SMSMessage: Text[250])
    var
        NcEndpoint: Record "NPR Nc Endpoint";
        NcTaskOutput: Record "NPR Nc Task Output" temporary;
        SMSFile: File;
        BSlash: Label '\';
        ErrNotSend: Label 'The mail could not be sent.';
        Utility: Codeunit "NPR Utility";
        NcEndpointMgt: Codeunit "NPR Nc Endpoint Mgt.";
        OStream: OutStream;
        FileContent: Text;
        FileName: Text[250];
        CRLF: Text;
        Response: Text;
    begin
        IComm.Get;
        if (Tlf = '') or (SMSMessage = '') then
            Error(ErrEmpty);

        case IComm."SMS Type" of
            IComm."SMS Type"::Mail:
                begin
                    if not SMSFile.Create(IComm."Local SMTP Pickup Library" + BSlash + Tlf + '.txt') then begin
                        Message(ErrNotSend);
                        exit;
                    end;
                    SMSFile.TextMode(true);
                    Utility.MakeVars;
                    SMSFile.Write('from: ' + Utility.Ascii2Ansi(IComm."Local E-Mail Address"));
                    SMSFile.Write('to: ' + Utility.Ascii2Ansi(Tlf + IComm."SMS-Address Postfix"));
                    SMSFile.Write('subject: ' + Utility.Ascii2Ansi(SMSMessage));
                    SMSFile.Close;
                end;
            IComm."SMS Type"::Eclub:
                SmsEclub(Tlf, SMSMessage, IComm."E-Club Sender");
            IComm."SMS Type"::Endpoint:
                begin
                    IComm.TestField("SMS Endpoint");
                    NcEndpoint.Get(IComm."SMS Endpoint");
                    NcEndpoint.TestField(Enabled);
                    CRLF[1] := 13;
                    CRLF[2] := 10;
                    OnBeforeGenerateEndpointOutputFile(NcEndpoint.Code, IComm."Local E-Mail Address", Tlf, SMSMessage, FileContent, FileName);
                    if FileContent = '' then begin
                        FileContent := 'from: ' + IComm."Local E-Mail Address" + CRLF;
                        FileContent += 'to: ' + Tlf + IComm."SMS-Address Postfix" + CRLF;
                        FileContent += 'subject: ' + SMSMessage;
                    end;
                    if FileName = '' then
                        FileName := IComm."Local SMTP Pickup Library" + BSlash + Tlf + '.txt';
                    NcTaskOutput.Data.CreateOutStream(OStream, TEXTENCODING::Windows);
                    OStream.WriteText(FileContent);
                    NcTaskOutput.Insert(false);
                    NcTaskOutput.Name := FileName;
                    if not NcEndpointMgt.RunEndpoint(NcTaskOutput, NcEndpoint, Response) then
                        Error(SendFailedErr, NcEndpoint.Code);
                end;
        end;
    end;

    procedure SmsEclub(PhoneNo: Text[20]; SMSMessage: Text[250]; From: Text[20])
    var
        Util: Codeunit "NPR Utility";
        Uri: Codeunit Uri;
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        Client: HttpClient;
        Response: HttpResponseMessage;
        ContentHeaders: HttpHeaders;
        Content: HttpContent;
        ServiceCode: Code[20];
        ForeignPhone: Boolean;
        SMSHandled: Boolean;
        SMSServiceUri: Text;
    begin
        OnSendSMS(SMSHandled, PhoneNo, From, SMSMessage);
        if SMSHandled then
            exit;

        if (PhoneNo = '') or (SMSMessage = '') then
            Error(ErrEmpty);

        ForeignPhone := CopyStr(PhoneNo, 1, 1) = '+';
        if ForeignPhone then
            ServiceCode := 'SMSUDLAND'
        else begin
            ServiceCode := 'ECLUBSMS';
            PhoneNo := '+45' + PhoneNo;
        end;

        PhoneNo := DelChr(PhoneNo, '=', '+');

        if ServiceCalc.useService(ServiceCode) then begin
            SMSMessage := DelChr(Util.Ansi2Ascii(SMSMessage), '%', '');
            // Uses following Azure Key Vault secrets:
            // - SMSHTTPRequestUrl    
            //   The secret contains complete Request URL for sending SMS in the following format:
            //   'https://wsx.sp247.net/linkdk/?username=%1&password=%2&from=%3&to=%4&message=%5&charset=%6'
            //   EscapeDataString called after StrSubstNo
            // - SMSUserName
            // - SMSPassword

            SMSServiceUri := AzureKeyVaultMgt.GetSecret('SMSHTTPRequestUrl');
            SMSServiceUri := StrSubstNo(SMSServiceUri, AzureKeyVaultMgt.GetSecret('SMSUserName'),
                             AzureKeyVaultMgt.GetSecret('SMSPassword'),
                             From, PhoneNo, SMSMessage, 'utf-8');


            Content.GetHeaders(contentHeaders);
            ContentHeaders.Clear();
            ContentHeaders.Add('Content-Type', 'text/xml; charset=utf-8');
            Client.Timeout(10000);

            if not Client.Post(SMSServiceUri, Content, Response) then
                Error(GetLastErrorText);

            if not response.IsSuccessStatusCode then
                Error(format(response.HttpStatusCode));
        end;
    end;

    procedure CreateInteractionLog(CustomerNo: Code[20]; SegmentNo: Code[20]; Description: Text[50]; Subject: Text[50]; DocumentType: Enum "Interaction Log Entry Document Type"; DocumentNo: Code[20])
    var
        InteractionLogEntry: Record "Interaction Log Entry";
        Contact: Record Contact;
        ContBusRel: Record "Contact Business Relation";
        ContactNo: Code[20];
    begin
        IComm.Get;

        ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
        ContBusRel.SetRange("No.", CustomerNo);
        ContBusRel.FindFirst;
        ContactNo := ContBusRel."Contact No.";

        InteractionLogEntry.Init;
        InteractionLogEntry."Entry No." := GetNewInteractionLogEntryNo;
        if Contact.Get(ContactNo) then begin
            InteractionLogEntry.Validate("Contact No.", Contact."No.");
            InteractionLogEntry.Validate("Contact Company No.", Contact."Company No.");
        end;
        InteractionLogEntry."Segment No." := SegmentNo;
        InteractionLogEntry.Validate("Interaction Template Code", IComm."Interaction Template Code");
        InteractionLogEntry."Time of Interaction" := Time;
        InteractionLogEntry.Date := WorkDate;
        InteractionLogEntry.Description := Description;
        InteractionLogEntry.Subject := Subject;
        InteractionLogEntry."User ID" := UserId;
        InteractionLogEntry."Information Flow" := InteractionLogEntry."Information Flow"::Outbound;
        InteractionLogEntry."Initiated By" := InteractionLogEntry."Initiated By"::Us;
        InteractionLogEntry."Document Type" := DocumentType;
        InteractionLogEntry."Document No." := DocumentNo;
        InteractionLogEntry.Insert(true);
    end;

    local procedure GetNewInteractionLogEntryNo(): Integer
    var
        InteractionLogEntry: Record "Interaction Log Entry";
    begin
        if not InteractionLogEntry.FindLast then
            exit(1);
        exit(InteractionLogEntry."Entry No." + 1);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGenerateEndpointOutputFile(NcEndpointCode: Code[20]; Sender: Text[40]; ToPhone: Code[20]; SmsMessage: Text[250]; var FileContent: Text; var Filename: Text[250])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSendSMS(var Handled: Boolean; PhoneNo: Text; Sender: Text; SMSMessage: Text)
    begin
    end;
}