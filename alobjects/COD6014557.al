codeunit 6014557 "Raw Print Proxy Protocol"
{
    // NPR4.15/TSA/20151019 CASE 220508 Created for Proxy Print
    // NPR5.00/VB/20150104 CASE 225607 Changed references for compiling under NAV 2016
    // NPR5.00/TSA/20151214 CASE 220508 Changed close page and added a commit when starting protocol
    // NPR5.00/TSA/20151231 CASE 230387 Change how encoding information is transmitted to remote print
    // NPR5.00/VB/20160106 CASE 231100 Update .NET version from 1.9.1.305 to 1.9.1.369
    // NPR5.00.03/VB/20160106 CASE 231100 Update .NET version from 1.9.1.369 to 5.0.398.0
    // NPR5.22/MMV/20160415 CASE 237026 Move stargate call to new async function
    // NPR5.29/MMV /20161114 CASE 256521 Renamed object from 'Proxy Print Driver' to 'Raw Print Proxy Protocol'.

    SingleInstance = true;
    TableNo = TempBlob;

    trigger OnRun()
    begin
        ProcessSignal(Rec);
    end;

    var
        POSDeviceProxyManager: Codeunit "POS Device Proxy Manager";
        ExpectedResponseType: DotNet Type;
        ExpectedResponseId: Guid;
        ProtocolManagerId: Guid;
        ProtocolStage: Integer;
        PrinterName: Text[100];
        PrintData: Text;
        TargetEncoding: Text[30];
        Proxy: Page "Proxy Dialog";

    local procedure ProcessSignal(var TempBlob: Record TempBlob)
    var
        Signal: DotNet Signal;
        StartSignal: DotNet StartSession;
        Response: DotNet MessageResponse;
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

    local procedure MessageResponse(Envelope: DotNet ResponseEnvelope)
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
        PrintRequest: DotNet PrintRequest;
        PrintResponse: DotNet PrintResponse;
    begin
        ProtocolStage := 1;

        PrintRequest := PrintRequest.PrintRequest ();

        PrintRequest.LoadFromString (PrintData);
        //-NPR5.00
        PrintRequest.SourceEncodingName := '';
        PrintRequest.TargetEncodingName := '';
        if (TargetEncoding <> '') then begin
          PrintRequest.SourceEncodingName := 'UTF-8';
          PrintRequest.TargetEncodingName := TargetEncoding;
        end;
        //+NPR5.00
        PrintRequest.PrinterName := PrinterName;

        ExpectedResponseType := GetDotNetType(PrintResponse);
        ExpectedResponseId := POSDeviceProxyManager.SendMessage(ProtocolManagerId,PrintRequest);
    end;

    local procedure ProtocolStage1Close(Envelope: DotNet Envelope)
    var
        PrintResponse: DotNet PrintResponse;
    begin
        POSDeviceProxyManager.DeserializeEnvelopeFromId(PrintResponse,Envelope,ProtocolManagerId);
        POSDeviceProxyManager.ProtocolClose(ProtocolManagerId);
    end;

    procedure PrintJob(pPrinterName: Text[100];pTargetEncoding: Text[30];pPrintBytes: Text)
    var
        PrintRequest: DotNet PrintRequest;
        POSEventMarshaller: Codeunit "POS Event Marshaller";
    begin
        Commit ();
        //-NPR5.22
        if POSEventMarshaller.IsInitialized and (CurrentClientType = CLIENTTYPE::Tablet) then begin
          PrintRequest := PrintRequest.PrintRequest ();

          PrintRequest.LoadFromString (pPrintBytes);
          PrintRequest.SourceEncodingName := '';
          PrintRequest.TargetEncodingName := '';
          if (pTargetEncoding <> '') then begin
            PrintRequest.SourceEncodingName := 'UTF-8';
            PrintRequest.TargetEncodingName := pTargetEncoding;
          end;
          PrintRequest.PrinterName := pPrinterName;

          POSEventMarshaller.InvokeDeviceMethod(PrintRequest);
        end else begin
        //+NPR5.22
          PrinterName := pPrinterName;
          TargetEncoding := pTargetEncoding;
          PrintData := pPrintBytes;

          Clear (Proxy);
          Proxy.RunProtocolModal(6014557);
        //-NPR5.22
        end;
        //+NPR5.22
    end;
}

