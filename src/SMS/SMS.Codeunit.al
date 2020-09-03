codeunit 6014502 "NPR SMS"
{
    // NPR3.0c, NPK, DL, 07-11-07, Changed SMS server
    // NPR70.01.00.00/MH/20140610  Refactored: Http DotNet variable are utilized instead of Automation Variable.
    // NPR4.02/TR/20150417  CASE 210206 If FINDLAST does not find any lines
    //   the function would create an error. This has been corrected.
    // NPR4.21/KN/20160218 CASE 213605 Added functionality to distinguish between danish and foreign phone numbers.
    // NPR5.38/MHA /20180105  CASE 301053 Added ConstValue to empty Text Constant ErrEmpty and deleted unused function SendSMSMultiple()
    // NPR5.40/JDH /20180320 CASE 308647 cleaned up code and variables
    // NPR5.51/THRO/20190710 CASE 360944 Added option to send sms to Nc Endpoint
    // NPR5.53/ZESO/20200110 CASE 382779 Change in Credentials Old UserName : navipartner, Old password : n4vipartner
    // NPR5.54/ZESO/20200309 CASE 382779 Change in URL, '+'no longer accepted in Phone Nos by LinkMobility
    // NPR5.55/BHR /20200504 CASE 400915 Add Publisher OnSendSMS
    // NPR5.55/ZESO/20200512 CASE 403305 Cater for special characters.


    trigger OnRun()
    begin
    end;

    var
        ServiceCalc: Codeunit "NPR Service Calculation";
        IComm: Record "NPR I-Comm";
        ErrEmpty: Label 'Sms message and/or Phone No. is blank';
        Envfunc: Codeunit "NPR Environment Mgt.";
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
            //-NPR5.51 [360944]
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
        //-NPR5.51 [360944]
        end;
    end;

    procedure SmsEclub(PhoneNo: Code[20]; SMSMessage: Text[250]; From: Text[20])
    var
        HttpRequest: DotNet NPRNetHttpWebRequest;
        Util: Codeunit "NPR Utility";
        ServiceCode: Code[20];
        ForeignPhone: Boolean;
        SMSHandled: Boolean;
    begin
        //-[NPR5.55] [400951]
        OnSendSMS(SMSHandled, PhoneNo, From, SMSMessage);
        if SMSHandled then
            exit;
        //+[NPR5.55] [400951]
        if (PhoneNo = '') or (SMSMessage = '') then
            Error(ErrEmpty);

        ForeignPhone := CopyStr(PhoneNo, 1, 1) = '+';
        if ForeignPhone then begin
            ServiceCode := 'SMSUDLAND';
        end else begin
            ServiceCode := 'ECLUBSMS';
            PhoneNo := '+45' + PhoneNo;
        end;

        //-NPR5.54 [382779]
        PhoneNo := DelChr(PhoneNo, '=', '+');
        //+NPR5.54 [382779]

        if ServiceCalc.useService(ServiceCode) then begin
            SMSMessage := DelChr(Util.Ansi2Ascii(SMSMessage), '%', '');
            if not IsNull(HttpRequest) then
                Clear(HttpRequest);

            //-NPR5.54 [382779]
            //HttpRequest := HttpRequest.Create('http://sms.coolsmsc.dk/sendsms.php?message=' +
            //SMSMessage +
            //'&to=' + PhoneNo +
            //'&from=' + From +
            //-NPR5.53 [382779]
            //'&username=navipartner' +
            //'&password=n4vipartner');
            // '&username= O7LbM2B6' +
            //'&password=OujrSE78');
            //+NPR5.53 [382779]

            HttpRequest := HttpRequest.Create('https://wsx.sp247.net/linkdk/?' +
                                              'username=2517_12D8' +
                                              '&password=W36nshJ8' +
                                              '&to=' + PhoneNo +
                                              //-NPR5.55 [403305]
                                              //'&message=' + SMSMessage +
                                              '&message=' + SMSMessage + '&charset=utf-8' +
                                              //+NPR5.55 [403305]
                                              '&from=' + From);
            //+NPR5.54 [382779]
            HttpRequest.Timeout := 10000;
            HttpRequest.UseDefaultCredentials(true);
            HttpRequest.Method := 'POST';
            //-NPR5.55 [403305]
            //HttpRequest.ContentType := 'text/xml; charset=utf-8';
            HttpRequest.ContentType := 'text/xml';
            //+NPR5.55 [403305]
            HttpRequest.GetResponse();
            Clear(HttpRequest);
        end;
    end;

    procedure CreateInteractionLog(CustomerNo: Code[20]; SegmentNo: Code[20]; Description: Text[50]; Subject: Text[50]; DocumentType: Integer; DocumentNo: Code[20])
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
        //-NPR5.38 [301053]
        //InteractionLogEntry."Correspondence Type" := InteractionLogEntry."Correspondence Type"::"4";
        //+NPR5.38 [301053]
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

