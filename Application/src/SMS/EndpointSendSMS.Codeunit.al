codeunit 6014420 "NPR Endpoint Send SMS" implements "NPR Send SMS"
{
    Access = Internal;
    procedure SendSMS(PhoneNo: Text; SenderNo: Text; Message: Text)
    var
        NcEndpoint: Record "NPR Nc Endpoint";
        TempNcTaskOutput: Record "NPR Nc Task Output" temporary;
        SMSSetup: Record "NPR SMS Setup";
        NcEndpointMgt: Codeunit "NPR Nc Endpoint Mgt.";
        BSlash: Label '\', Locked = true;
        SendFailedErr: Label 'Upload to Endpoint %1 failed.';
        OStream: OutStream;
        CRLF: Text;
        FileContent: Text;
        FileName: Text;
        Response: Text;
    begin
        SMSSetup.Get();
        SMSSetup.TestField("SMS Endpoint");
        NcEndpoint.Get(SMSSetup."SMS Endpoint");
        NcEndpoint.TestField(Enabled);
        CRLF[1] := 13;
        CRLF[2] := 10;
        if FileContent = '' then begin
            FileContent := 'from: ' + SMSSetup."Local E-Mail Address" + CRLF;
            FileContent += 'to: ' + PhoneNo + SMSSetup."SMS-Address Postfix" + CRLF;
            FileContent += 'subject: ' + Message;
        end;
        if FileName = '' then
            FileName := SMSSetup."Local SMTP Pickup Library" + BSlash + PhoneNo + '.txt';
        TempNcTaskOutput.Data.CreateOutStream(OStream, TEXTENCODING::Windows);
        OStream.WriteText(FileContent);
        TempNcTaskOutput.Insert(false);
        TempNcTaskOutput.Name := CopyStr(FileName, 1, MaxStrLen(TempNcTaskOutput.Name));
        if not NcEndpointMgt.RunEndpoint(TempNcTaskOutput, NcEndpoint, Response) then
            Error(SendFailedErr, NcEndpoint.Code);
    end;
}
