codeunit 6014556 "File Print Proxy Protocol"
{
    // NPR5.29/MMV /20161114 CASE 256521 Renamed object from 'NAV 2013 Reservation 6' to 'File Print Proxy Protocol'.
    // 
    // Uses either Spire.PDF library or the default OS filetype handler to print on the local machine.
    // Support for amyuni or gdpicture pdf libraries have been prepared but not implemented yet.

    SingleInstance = true;
    TableNo = TempBlob;

    trigger OnRun()
    begin
        ProcessSignal(Rec);
    end;

    var
        POSDeviceProxyManager: Codeunit "POS Device Proxy Manager";
        ExpectedResponseType: DotNet npNetType;
        ExpectedResponseId: Guid;
        ProtocolManagerId: Guid;
        ProtocolStage: Integer;
        Proxy: Page "Proxy Dialog";
        MemStream: DotNet npNetMemoryStream;
        FileExtension: Text;
        PrinterName: Text;
        UsePrinterDialog: Boolean;
        PrintMethod: Integer;

    local procedure ProcessSignal(var TempBlob: Record TempBlob)
    var
        Signal: DotNet npNetSignal;
        StartSignal: DotNet npNetStartSession;
        Response: DotNet npNetMessageResponse;
    begin
        POSDeviceProxyManager.DeserializeObject(Signal,TempBlob);
        case true of
          Signal.TypeName = Format(GetDotNetType(StartSignal)):
            begin
              POSDeviceProxyManager.DeserializeSignal(StartSignal,Signal);
              Start(StartSignal.ProtocolManagerId);
            end;
          Signal.TypeName = Format(GetDotNetType(Response)):
            begin
              POSDeviceProxyManager.DeserializeSignal(Response,Signal);
              MessageResponse(Response.Envelope);
            end;
        end;
    end;

    local procedure Start(ProtocolManagerIdIn: Guid)
    begin
        ProtocolManagerId := ProtocolManagerIdIn;

        ProtocolStage1();
    end;

    local procedure MessageResponse(Envelope: DotNet npNetResponseEnvelope)
    begin
        if Envelope.MessageId <> ExpectedResponseId then
          Error('Unknown response: %1 (expected %2)',Envelope.MessageId,ExpectedResponseId);

        if Envelope.ResponseTypeName <> Format(ExpectedResponseType) then
          Error('Unknown response type: %1 (expected %2)',Envelope.ResponseTypeName,Format(ExpectedResponseType));

        case ProtocolStage of
          1: ProtocolStage1Close(Envelope);
        end;
    end;

    local procedure ProtocolStage1()
    var
        PrintRequest: DotNet npNetFilePrintRequest;
        PrintResponse: DotNet npNetFilePrintResponse;
    begin
        ProtocolStage := 1;

        PrintRequest := PrintRequest.FilePrintRequest();

        PrintRequest.ExternalLibLicenseKey := GetSpirePDFLicenseKey();
        PrintRequest.FileData := MemStream.ToArray();
        PrintRequest.FileExtension := FileExtension;
        PrintRequest.PrinterName := PrinterName;
        PrintRequest.UsePrinterDialog := UsePrinterDialog;
        PrintRequest.SelectedPrintMethod := PrintMethod;

        ExpectedResponseType := GetDotNetType(PrintResponse);
        ExpectedResponseId := POSDeviceProxyManager.SendMessage(ProtocolManagerId,PrintRequest);
    end;

    local procedure ProtocolStage1Close(Envelope: DotNet npNetEnvelope)
    var
        PrintResponse: DotNet npNetPrintResponse;
    begin
        POSDeviceProxyManager.DeserializeEnvelopeFromId(PrintResponse,Envelope,ProtocolManagerId);
        POSDeviceProxyManager.ProtocolClose(ProtocolManagerId);
    end;

    procedure PrintJob(pPrinterName: Text;var pMemStream: DotNet npNetMemoryStream;pFileExtension: Text;pUsePrinterDialog: Boolean)
    var
        PrintRequest: DotNet npNetFilePrintRequest;
        POSEventMarshaller: Codeunit "POS Event Marshaller";
        IntBuffer: Integer;
        PrintMethodOption: Option OSFileHandler,Spire;
    begin
        Commit ();

        if pFileExtension[1] = '.' then
          pFileExtension := CopyStr(pFileExtension, 2);

        if UpperCase(pFileExtension) = 'PDF' then
          PrintMethodOption := PrintMethodOption::Spire
        else
          PrintMethodOption := PrintMethodOption::OSFileHandler;


        if POSEventMarshaller.IsInitialized then begin
          //Call async via POS page add-in. In this case we don't subscribe to the callback that eventually happens.
          PrintRequest := PrintRequest.FilePrintRequest ();

          PrintRequest.ExternalLibLicenseKey := GetSpirePDFLicenseKey();
          PrintRequest.FileData := pMemStream.ToArray();
          PrintRequest.FileExtension := pFileExtension;
          PrintRequest.PrinterName := pPrinterName;
          PrintRequest.UsePrinterDialog := pUsePrinterDialog;
          PrintRequest.WaitForResult := false; //Since we don't subscribe to callback in C/AL at the moment, don't wait until printing is done on the local machine before return to NST.
          IntBuffer := PrintMethodOption;
          PrintRequest.SelectedPrintMethod := IntBuffer;

          POSEventMarshaller.InvokeDeviceMethod(PrintRequest);
        end else begin
          //Open new page modally that works outside the POS as well.
          MemStream := pMemStream;
          FileExtension := pFileExtension;
          PrinterName := pPrinterName;
          UsePrinterDialog := pUsePrinterDialog;
          PrintMethod := PrintMethodOption;

          Clear (Proxy);
          Proxy.RunProtocolModal(6014556);
        end;
    end;

    local procedure GetSpirePDFLicenseKey(): Text
    begin
        exit('eJ0I+QEAFUQlMJ5Y9Jh1A3oFBZlRlc2dCwBzvN4n8ksckuief1hgP9Ynd16E/yoJbAT+lwyVG0NBFDQmhdsn+vvqLMr343ipVXo93b6uN/4mB1HVOmorRny+98VP84Q7z/HgAIE9rPRFo6LGLGyhorEmD3BoMjHOQsahmlXZeaz/N' +
             'NmuGLp98ezp/KNSPt0dDIfI/kbXo+P+4W8ySjUfzRqtKyLdC2IbtCtYBf2rSzrr9gz7y59oaoUSLf6j6Kjami7izlb4em2R8taX3zZOOQ4/KQ4PhLs7Z35jt9pNjs9gmjeYk5GkRx1Ccm2tK2hakN6yZ0Ipbl0stRna+mwcdboVKZa' +
             'T5h56wmnZovDTaghZ9SyY80eYPVTHC0ura7uZcCFAI6XoQxvwkX8bIdDD4YpzDQR0kybl924FXCQYwJFynVJSTq/BDAzY7kPp+vlKQ55df7ZuBRcH4nxrdDXdK2KGl+F5BkVjQ6TFJxspGt8kKVmCvowGUNFkNh4bRkwhtVpVtRE6g' +
             '5r4O38tXMKgcv4qqm3AQOYAyTH5p4W+8YWQrl8kbgYYB6ISY5QdfzxxhdyvkN4L58cPsa3xUH7X5qytyiSaxeCCf+jRyPhwZwLp0rLDWdax15B/fpMeWGAVA5hjP5dc8AckcQVsJVqE3jLHaAVG6LaKnN2kU+JxSfB5WUMqUz6F4IP' +
             'zGDm6fcFQrUZjiSvgKVfITmLdkwZZr0YMmZYd7ANQOQuCV1+HiGPVI5FXHOd26KPeqMNJ7VvYcIVBz4/YzzP/B8aVoTPal919hpLkXSLg5ktPdVtOgee7GFGp/WWtoVomE8yyq/xJdvE6aO3tWeGM70ik9/A5urE1lna+lk9wcznNS' +
             'RJg+2Ara8z8zAQF3+qS5+pBDjeNL9MBMLKfIY0tTHPER/ChH8p+2XIT0jChhkZ1AAaCR2I/fGgjvP0u6ykftT4MlwaW+IhBrlpTUR2V8X7l3ua9EMJJ3Cf77nHMIC7vU7nXyjvDOkLyM7R9YO2c7ZnYh+hXUpaVGIWFbQhYs3H2NDN' +
             '61xVUKt2djSkJ0t2a7z8vsAKmoyaMeeVswmNrl6jRpxyLiNRyn4yFsL5XAYGs/ohgKWEbRSG2AmLWVjQWuMy6AUAqiOznN3fnpN/zuK32MKGwKzLhyoVG/l6xXBDCGYIcVUQ0ip/f68GIEDg1vB8BlVKubXYQKuTcMeWxhCdcx0s4R' +
             'zfiZd4ZFRdVDGNRplDv/hZU7eKSbn7df/T/7sbkligVQYCaIBocIWuP8pVa7Y21+0ZgPi8E33IitQmtEzU5bxcYAxkOzOBnAWr5SYcLOm9QdljeZ/uFINosEbOTHRk/lhg2mjJB+EWfp/zG6u188vcQ3OCqTZQN6Bv26nBX2/1dLfs' +
             'G9NvxTzLN7ZSUv//fcpkOOyL5V66eUaMaaJqFth3Pr73kpoCgdyyvGofy092vE1ZsE8zw7Ft5JriNdPh3WWsMawNQ3xh0I1Lh45HiUDdIrcSM0v9aiBwRUyDXFNU=');
    end;
}

