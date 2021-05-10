codeunit 6151000 "NPR POS Proxy: Raw Print"
{
    // NPR5.43/MMV /20180528 CASE 315838 Updated assembly reference


    trigger OnRun()
    begin
    end;

    local procedure ProtocolName(): Text
    begin
        exit('RAW_PRINT');
    end;

    procedure Print(var FrontEnd: Codeunit "NPR POS Front End Management"; PrinterName: Text[100]; TargetEncoding: Text[30]; PrintBytes: Text; WaitForResult: Boolean)
    var
        PrintRequest: DotNet NPRNetPrintRequest0;
    begin
        // If WaitForResult is false, the local stargate assembly will queue the print on the client machine asynchronously and never notify the NST of how the operation went.
        // This is recommended for everything that can be re-printed by the user manually and is legal to fail, for performance sake since
        // calling back to NST will 99,9% of the time be wasted during normal operation.

        PrintRequest := PrintRequest.PrintRequest();

        PrintRequest.LoadFromString(PrintBytes);
        PrintRequest.SourceEncodingName := '';
        PrintRequest.TargetEncodingName := '';
        PrintRequest.PrinterName := PrinterName;
        //-NPR5.43 [315838]
        PrintRequest.WaitForResult := WaitForResult;
        //+NPR5.43 [315838]

        if (TargetEncoding <> '') then begin
            PrintRequest.SourceEncodingName := 'UTF-8';
            PrintRequest.TargetEncodingName := TargetEncoding;
        end;

        FrontEnd.InvokeDevice(PrintRequest, ProtocolName(), 'PRINT');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150716, 'OnDeviceResponse', '', false, false)]
    local procedure Print_Response(ActionName: Text; Step: Text; Envelope: DotNet NPRNetResponseEnvelope0; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Stargate: Codeunit "NPR POS Stargate Management";
        PrintResponse: DotNet NPRNetPrintResponse0;
        ResponseMessage: Text;
    begin
        if ActionName <> ProtocolName() then
            exit;

        Stargate.DeserializeEnvelope(Envelope, PrintResponse, FrontEnd);

        ResponseMessage := PrintResponse.ResponseMessage;
        if (not PrintResponse.PrintedSuccessfully) and (StrLen(ResponseMessage) > 0) then
            Message(PrintResponse.ResponseMessage);
    end;
}

