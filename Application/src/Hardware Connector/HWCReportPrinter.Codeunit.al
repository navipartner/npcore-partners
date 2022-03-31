codeunit 6014495 "NPR HWC Report Printer"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ReportManagement", 'OnAfterSetupPrinters', '', true, true)]
    local procedure SetupPrinters(var Printers: Dictionary of [Text[250], JsonObject]);
    var
        Payload: JsonObject;
        HWCPrinter: Record "NPR HWC Printer";
    begin
        if HWCPrinter.FindSet() then
            repeat
                if HWCPrinter."Paper Size" = HWCPrinter."Paper Size"::Custom then begin
                    Payload.ReadFrom(StrSubstNo('{"version":1,"papertrays":[{"papersourcekind":"%1","paperkind":"%2","units":"%3","height":"%4","width":"%5","landscape":"%6"}]}',
                                                HWCPrinter."Paper Source", HWCPrinter."Paper Size", HWCPrinter."Paper Unit", HWCPrinter."Paper Height", HWCPrinter."Paper Width", HWCPrinter.Landscape));
                end else begin
                    Payload.ReadFrom(StrSubstNo('{"version":1,"papertrays":[{"papersourcekind":"%1","paperkind":"%2"}]}', HWCPrinter."Paper Source", HWCPrinter."Paper Size"));
                end;
                Printers.Add(HWCPrinter.ID, Payload);
            until HWCPrinter.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ReportManagement", 'OnAfterDocumentPrintReady', '', true, true)]
    local procedure OnDocumentPrintReady(ObjectType: Option "Report","Page"; ObjectId: Integer; ObjectPayload: JsonObject; DocumentStream: InStream; var Success: Boolean);
    var
        HWCPrinter: Record "NPR HWC Printer";
        JToken: JsonToken;
        PrintMethodMgt: Codeunit "NPR Print Method Mgt.";
    begin
        begin
            if Success then
                exit;
            if ObjectType <> ObjectType::Report then
                exit;
            if not ObjectPayload.Get('printername', JToken) then
                exit;
            if not HWCPrinter.Get(JToken.AsValue().AsText()) then
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