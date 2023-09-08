codeunit 6014582 "NPR Print Method Mgt."
{
#pragma warning disable AA0139
    Access = Internal;

    procedure PrintBytesLocal(PrinterName: Text; PrintJobBase64: Text)
    var
        HardwareConnectorMgt: Codeunit "NPR Hardware Connector Mgt.";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        HWCPOSRequest: Codeunit "NPR Front-End: HWC";
        Request: JsonObject;
        Stack: Codeunit "NPR POS Page Stack Check";
    begin
        if CurrentClientType in [ClientType::Background, ClientType::ChildSession] then
            exit;

        if POSSession.IsInitialized() and Stack.CurrentStackWasStartedByPOSTrigger() then begin
            //print to hardware connector via POS page
            Request.Add('PrinterName', PrinterName);
            Request.Add('PrintJob', PrintJobBase64);

            HWCPOSRequest.SetHandler('RawPrint');
            HWCPOSRequest.SetRequest(Request);
            POSSession.GetFrontEnd(POSFrontEnd, true);
            POSFrontEnd.InvokeFrontEndMethod2(HWCPOSRequest);
        end else begin
            //print to hardware connector via modal page
            HardwareConnectorMgt.SendRawPrintRequest(PrinterName, PrintJobBase64);
        end;

    end;

    procedure PrintFileLocal(PrinterName: Text; var Stream: InStream; FileExtension: Text)
    var
        HardwareConnectorMgt: Codeunit "NPR Hardware Connector Mgt.";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        HWCPOSRequest: Codeunit "NPR Front-End: HWC";
        Request: JsonObject;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        if CurrentClientType in [ClientType::Background, ClientType::ChildSession] then
            exit;
        if StrLen(FileExtension) = 0 then
            exit;
        if Stream.EOS() then
            exit;

        if POSSession.IsInitialized() then begin
            //print to hardware connector via POS page
            Request.Add('PrinterName', PrinterName);
            Request.Add('FileData', Base64Convert.ToBase64(Stream));
            Request.Add('FileExtension', FileExtension);

            if UpperCase(FileExtension) = 'PDF' then begin
                Request.Add('PrintMethod', 'Spire');
                Request.Add('ExternalLibLicenseKey', 'etsqfTbTAQAtl4LVKv1Zcx/A0EqSDOhekJOdhgf4tBITDoYhbWINywuYS1gH69hi6d6TaqMRXo/BCXQu9t8ip3VnAfQlDa2b2QaZIIVo7c6INW7vyYh7UXN3QjprQ55DfYk2j3/8bVx88MBddOwZddZAEh6rUJqND/dX67od2X5IWgxPt3xclB9czKLuD8r9qQ1OUFUXh0A1kd6F+oKGAEpWIQlJjxkOfENjCSaAkOgIJXLIsB9pfu79QwbGrTLe9AslykNsKxD6xl4KaiIFUZSeS2phKR3DAE+Rmo7bjVIJe/uUbXYBzP0XRpknzZFR6ewjzkeEW89g+lz3svdKIqcuvOu6fet3CK4xpov0dgiWb+2kjZiwGZfQ+YBeJX9gj1MTQcy26qAcx3h9tGRsVGJz9Cxz/nU6QPMEeS+YR516eIkppz0f3FvFZ6Hs9M/1srmZbi/tSB/ZrHtZ/3qjSCGd3wvSHSkVfHhGLAEpeb1Hq3UQz6XdSHhLY7u/vm8pjLB+N07PyWNAAB9W38Ffid0RSVlyz6y5XciV9xUedaoazEL/5q1b0kOPWxHvg/2IbJxsZimLK9f/WVHWrGFIljiAe6S0n2HGUWe+4/poUQzOP/81SUbXhKEua59VKxXLlVThlSNH57q2lbRCQc/Ir29gS4CKyS5AZUbhOXNLvdD0CNbtfIIwWALhRYIjFIv1CWvrSPHSPDs51jPDEy7gzDVsvRGdfN4q82wZaINOIsmxdz0rEQagA8YA5Jy3j3B0HGfJtlPC1MpIuM46R23XwK+emxCQhJXGWqWmhExlrmnEU0NNR3zMbHSt4o3GCDuZLgAIZIHIu4VVRw7qoymiXFG/S2dxBHC96jFVOJIaF6+zbY79owFIhj9fNdMvZnmU1YxLefu2bj8fdfRydF7T6HN8RaNkvs6BLrC5jvx2rXMY7Ga4x1SDLnJwP7lcXNNmcMqSiA4PMjUNJUQ8mDcpB8mhAnCKN4Lg/dpddNv8C8m9Oft2jJ79QOqeJvI/lY+SbPkbdicC3+u4QfI7/nYz6GGfq34MFhdJsr5wWkpjiQqCWVTcQWRcHMRN+jwJkFHm4BJFKZjXDkjsiN13wY60dvjdkz6FXW75mEteGCti/jUExGUGZwxYNYpEz5JqCV5CjTpbLzZv580qZzXoiYAoNZtIVweaeHxSgqWBJIyUs6dAEcPuyYMuXIDXf+a0JcRlFwZa352h6B1dIbGGxwSSWihABWI7+p0bnZjhoXaZNuxlj/tKjtqbDnpc4GTBcoG67SyEeMEDdin5PlAfI6qMf4TWGOjX5FxVvJvGVRijVnYY4drO+C5c86xIauvZut5vGmNrogcxSPsY9ANhYch3+oMqb7aMdQuxDK2LYwEMbP7p8+BCT1ce2l+liw4ncfLxn1kGoohRAuC1xUFND6DIFRJ6I2QoKrSt16x+uCWtjwRb2eayqih5NSAKsi1E5GAMUqXdtwAAHuIrDddVxNe5f1Yy19HDDHt/qFsK2Zmt8ETxVuQ7Yv7PKadCZTYvIJxKaKNO5PDU+vBPe9jEDH6OGYNKi9aK8QqIwSrkFD68qM11f8QDAqU6Tg==');
            end else begin
                Request.Add('PrintMethod', 'OSFileHandler');
            end;

            HWCPOSRequest.SetHandler('FilePrint');
            HWCPOSRequest.SetRequest(Request);
            POSSession.GetFrontEnd(POSFrontEnd, true);
            POSFrontend.InvokeFrontEndMethod2(HWCPOSRequest);
        end else begin
            //print to hardware connector via modal page
            HardwareConnectorMgt.SendFilePrintRequest(PrinterName, Stream, FileExtension);
        end;
    end;

    procedure PrintViaEmail(PrinterName: Text; var Stream: InStream)
    var
        Separators: List of [Text];
        TempEmailItem: Record "Email Item" temporary;
        TempErrorMessage: Record "Error Message" temporary;
        EmailSenderHandler: Codeunit "NPR Email Sending Handler";
    begin
        if Stream.EOS then
            exit;
        Separators.Add(';');
        Separators.Add(',');

        EmailSenderHandler.CreateEmailItem(TempEmailItem, 'NaviPartner', 'eprint@navipartner.dk', PrinterName.Split(Separators), 'Document Print', 'Document Print Body', false);
        EmailSenderHandler.AddAttachmentFromStream(TempEmailItem, Stream, 'Document.pdf');
        EmailSenderHandler.Send(TempEmailItem, TempErrorMessage);
        if not TempErrorMessage.IsEmpty() then
            TempErrorMessage.ShowErrors();
    end;

    procedure PrintViaPrintNodePdf(PrinterID: Text; var PdfStream: InStream; DocumentDescription: Text; ObjectType: Option "Report","Codeunit"; ObjectID: Integer)
    var
        PrintNodeAPIMgt: Codeunit "NPR PrintNode API Mgt.";
        PrintNodeMgt: Codeunit "NPR PrintNode Mgt.";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        TempBlob.CreateOutStream(OutStr);
        CopyStream(OutStr, PdfStream);

        PrintNodeAPIMgt.SendPDFStream(PrinterID, TempBlob, DocumentDescription, '', PrintNodeMgt.GetPrinterOptions(PrinterID, ObjectType, ObjectID));
    end;

    procedure PrintViaPrintNodeRaw(PrinterID: Text; PrintJobBase64: Text; ObjectType: Option "Report","Codeunit"; ObjectID: Integer)
    var
        PrintNodeAPIMgt: Codeunit "NPR PrintNode API Mgt.";
        PrintNodeMgt: Codeunit "NPR PrintNode Mgt.";
    begin
        PrintNodeAPIMgt.SendRawText(PrinterID, PrintJobBase64, '', '', PrintNodeMgt.GetPrinterOptions(PrinterID, ObjectType, ObjectID));
    end;

    procedure PrintBytesHTTP(URL: Text; Endpoint: Text; PrintJobBase64: Text)
    var
        MobilePrintMgt: Codeunit "NPR Mobile Print Mgt.";
    begin
        MobilePrintMgt.PrintJobHTTP(URL, Endpoint, PrintJobBase64);
    end;

    procedure PrintBytesBluetooth(DeviceName: Text; PrintJobBase64: Text)
    var
        MobilePrintMgt: Codeunit "NPR Mobile Print Mgt.";
    begin
        MobilePrintMgt.PrintJobBluetooth(DeviceName, PrintJobBase64);
    end;

    procedure PrintFileMPOS(IP: Text; FileBase64: Text)
    var
        MobilePrintMgt: Codeunit "NPR Mobile Print Mgt.";
    begin
        MobilePrintMgt.PrintJobFile(IP, FileBase64);
    end;
#pragma warning restore AA0139
}
