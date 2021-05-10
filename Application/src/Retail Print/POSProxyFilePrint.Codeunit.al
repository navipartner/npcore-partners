codeunit 6151001 "NPR POS Proxy: File Print"
{
    // NPR5.43/MMV /20180528 CASE 315838 Updated assembly reference


    trigger OnRun()
    begin
    end;

    local procedure ProtocolName(): Text
    begin
        exit('FILE_PRINT');
    end;

    procedure Print(var FrontEnd: Codeunit "NPR POS Front End Management"; PrinterName: Text; var MemStream: DotNet NPRNetMemoryStream; FileExtension: Text; UsePrinterDialog: Boolean; WaitForResult: Boolean)
    var
        PrintRequest: DotNet NPRNetFilePrintRequest0;
        PrintMethod: DotNet NPRNetFilePrintRequest_PrintMethod;
    begin
        // If WaitForResult is false, the local stargate assembly will queue the print on the client machine asynchronously and never notify the NST of how the operation went.
        // This is recommended for everything that can be re-printed by the user manually and is legal to fail, for performance sake since
        // calling back to NST will 99,9% of the time be wasted during normal operation.
        // Please note that UsePrinterDialog will force a callback.

        if FileExtension[1] = '.' then
            FileExtension := CopyStr(FileExtension, 2);

        PrintRequest := PrintRequest.FilePrintRequest();

        PrintRequest.FileData := MemStream.ToArray();
        PrintRequest.FileExtension := FileExtension;
        PrintRequest.PrinterName := PrinterName;
        PrintRequest.UsePrinterDialog := UsePrinterDialog;
        PrintRequest.WaitForResult := WaitForResult;

        if UpperCase(FileExtension) = 'PDF' then begin
            PrintRequest.SelectedPrintMethod := PrintMethod.Spire;
            PrintRequest.ExternalLibLicenseKey := GetSpirePDFLicenseKey();
        end else
            PrintRequest.SelectedPrintMethod := PrintMethod.OSFileHandler;

        FrontEnd.InvokeDevice(PrintRequest, ProtocolName(), 'PRINT');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150716, 'OnDeviceResponse', '', false, false)]
    local procedure Print_Response(ActionName: Text; Step: Text; Envelope: DotNet NPRNetResponseEnvelope0; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Stargate: Codeunit "NPR POS Stargate Management";
        PrintResponse: DotNet NPRNetFilePrintResponse0;
        ErrorMessage: Text;
    begin
        if ActionName <> ProtocolName() then
            exit;

        Stargate.DeserializeEnvelope(Envelope, PrintResponse, FrontEnd);

        ErrorMessage := PrintResponse.ErrorMessage;
        if (not PrintResponse.Printed) and (StrLen(ErrorMessage) > 0) then
            Message(PrintResponse.ErrorMessage);
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

