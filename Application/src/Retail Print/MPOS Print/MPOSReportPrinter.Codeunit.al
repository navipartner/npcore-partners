codeunit 6059855 "NPR MPOS Report Printer"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ReportManagement", 'OnAfterSetupPrinters', '', true, true)]
    local procedure SetupPrinters(var Printers: Dictionary of [Text[250], JsonObject]);
    var
        Payload: JsonObject;
        MPOSReportPrinter: Record "NPR MPOS Report Printer";
        HardwareConnectorLbl: Label 'MPOS Printer: %1';
        BooleanString: Text;
    begin
        if MPOSReportPrinter.FindSet() then
            repeat
                if MPOSReportPrinter."Paper Size" = MPOSReportPrinter."Paper Size"::Custom then begin
                    if MPOSReportPrinter.Landscape then
                        BooleanString := 'true'
                    else
                        BooleanString := 'false';

                    Payload.ReadFrom(StrSubstNo('{"version":1,"description":"%1","papertrays":[{"papersourcekind":%2,"paperkind":%3,"units":"%4","height":%5,"width":%6,"landscape":%7}]}',
                                                CopyStr(StrSubstNo(HardwareConnectorLbl, MPOSReportPrinter.ID), 1, 250), MPOSReportPrinter."Paper Source".AsInteger(), MPOSReportPrinter."Paper Size".AsInteger(), MPOSReportPrinter."Paper Unit", MPOSReportPrinter."Printer Paper Height", MPOSReportPrinter."Printer Paper Width", BooleanString));
                end else begin
                    Payload.ReadFrom(StrSubstNo('{"version":1,"description":"%1","papertrays":[{"papersourcekind":%2,"paperkind":%3}]}', CopyStr(StrSubstNo(HardwareConnectorLbl, MPOSReportPrinter.ID), 1, 250), MPOSReportPrinter."Paper Source".AsInteger(), MPOSReportPrinter."Paper Size".AsInteger()));
                end;
#pragma warning disable AA0139
                Printers.Add('NPR_MPOS_' + MPOSReportPrinter.ID, Payload);
#pragma warning restore AA0139
                Clear(Payload);
            until MPOSReportPrinter.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ReportManagement", 'OnAfterDocumentPrintReady', '', true, true)]
    local procedure OnDocumentPrintReady(ObjectType: Option "Report","Page"; ObjectId: Integer; ObjectPayload: JsonObject; DocumentStream: InStream; var Success: Boolean);
    var
        MPOSPrinter: Record "NPR MPOS Report Printer";
        JToken: JsonToken;
        PrintMethodMgt: Codeunit "NPR Print Method Mgt.";
        PrinterName: Text;
        Base64Convert: Codeunit "Base64 Convert";
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
            if not PrinterName.StartsWith('NPR_MPOS_') then
                exit;
            if not MPOSPrinter.Get(PrinterName.Substring(10)) then
                exit;
            if not ObjectPayload.Get('documenttype', JToken) then
                exit;
            if JToken.AsValue().AsText() <> 'application/pdf' then
                exit;

            PrintMethodMgt.PrintFileMPOS(MPOSPrinter."LAN IP", Base64Convert.ToBase64(DocumentStream));
            Success := true;
        end;
    end;
}