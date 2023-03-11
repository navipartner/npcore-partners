codeunit 6014495 "NPR HWC Report Printer"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ReportManagement", 'OnAfterSetupPrinters', '', true, true)]
    local procedure SetupPrinters(var Printers: Dictionary of [Text[250], JsonObject]);
    var
        Payload: JsonObject;
        HWCPrinter: Record "NPR HWC Printer";
        HardwareConnectorLbl: Label 'Hardware Connector Printer: %1', Locked = true;
        BooleanString: Text;
    begin
        if HWCPrinter.FindSet() then
            repeat
                if HWCPrinter."Paper Size" = HWCPrinter."Paper Size"::Custom then begin
                    if HWCPrinter.Landscape then
                        BooleanString := 'true'
                    else
                        BooleanString := 'false';

                    Payload.ReadFrom(StrSubstNo('{"version":1,"description":"%1","papertrays":[{"papersourcekind":%2,"paperkind":%3,"units":"%4","height":%5,"width":%6,"landscape":%7}]}',
                                                CopyStr(StrSubstNo(HardwareConnectorLbl, HWCPrinter.Name), 1, 250), HWCPrinter."Paper Source".AsInteger(), HWCPrinter."Paper Size".AsInteger(), HWCPrinter."Paper Unit", HWCPrinter."Printer Paper Height", HWCPrinter."Printer Paper Width", BooleanString));
                end else begin
                    Payload.ReadFrom(StrSubstNo('{"version":1,"description":"%1","papertrays":[{"papersourcekind":%2,"paperkind":%3}]}', CopyStr(StrSubstNo(HardwareConnectorLbl, HWCPrinter.Name), 1, 250), HWCPrinter."Paper Source".AsInteger(), HWCPrinter."Paper Size".AsInteger()));
                end;
#pragma warning disable AA0139
                Printers.Add('NPR_HWC_' + HWCPrinter.ID, Payload);
#pragma warning restore AA0139
                Clear(Payload);
            until HWCPrinter.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ReportManagement", 'OnAfterDocumentPrintReady', '', true, true)]
    local procedure OnDocumentPrintReady(ObjectType: Option "Report","Page"; ObjectId: Integer; ObjectPayload: JsonObject; DocumentStream: InStream; var Success: Boolean);
    var
        HWCPrinter: Record "NPR HWC Printer";
        JToken: JsonToken;
        PrintMethodMgt: Codeunit "NPR Print Method Mgt.";
        PrinterName: Text;
    begin
        begin
            if Success then
                exit;
            if ObjectType <> ObjectType::Report then
                exit;
            if not GuiAllowed() then
                exit;
            if not ObjectPayload.Get('printername', JToken) then
                exit;
            PrinterName := JToken.AsValue().AsText();
            if not PrinterName.StartsWith('NPR_HWC_') then
                exit;
            if not HWCPrinter.Get(PrinterName.Substring(9)) then
                exit;
            if not ObjectPayload.Get('documenttype', JToken) then
                exit;
            if JToken.AsValue().AsText() <> 'application/pdf' then
                exit;

            PrintMethodMgt.PrintFileLocal(HWCPrinter.Name, DocumentStream, 'pdf');
            Success := true;
        end;
    end;
}