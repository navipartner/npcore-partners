codeunit 6014584 "NPR Mobile Print Mgt."
{
    Access = Internal;
    var
        PrintFailedErr: Label 'Print failed';
        InvalidClientTypeErr: Label 'Can not print through mobile add-in on %1';
        PrintingLbl: Label 'Printing...';
        ClosedPageErr: Label 'The MPOS Connector page does not work if you manually close it. Please try again and keep it open.';


    procedure PrintJobHTTP(Address: Text; Endpoint: Text; PrintJob: Text)
    var
        JSON: JsonObject;
        MPOSConnector: Page "NPR MPOS Connector";
        AutoClosed: Boolean;
    begin
        if not (GuiAllowed) then
            Error(InvalidClientTypeErr, Format(CurrentClientType));

        if StrPos(Address, 'http') <> 1 then
            Address := 'http://' + Address;

        JSON := BuildJSONParams(Address, Endpoint, PrintJob, 'POST', PrintFailedErr);
        MPOSConnector.SetInput(PrintingLbl, JSON);
        MPOSConnector.RunModal();
        MPOSConnector.GetOutput(AutoClosed);
        if not AutoClosed then
            Message(ClosedPageErr);
    end;

    procedure PrintJobBluetooth(DeviceName: Text; PrintJob: Text)
    var
        JSON: JsonObject;
        MPOSConnector: Page "NPR MPOS Connector";
        AutoClosed: Boolean;
    begin
        if not (GuiAllowed) then
            Error(InvalidClientTypeErr, Format(CurrentClientType));

        JSON := BuildJSONParams(DeviceName, '', PrintJob, 'BLUETOOTH', PrintFailedErr);
        MPOSConnector.SetInput(PrintingLbl, JSON);
        MPOSConnector.RunModal();
        MPOSConnector.GetOutput(AutoClosed);
        if not AutoClosed then
            Message(ClosedPageErr);
    end;

    procedure PrintJobFile(IP: Text; FileBase64: Text)
    var
        JSON: JsonObject;
        MPOSConnector: Page "NPR MPOS Connector";
        AutoClosed: Boolean;
    begin
        if not (GuiAllowed) then
            Error(InvalidClientTypeErr, Format(CurrentClientType));

        JSON := BuildJSONParams(IP, '', FileBase64, 'FILE', PrintFailedErr);
        MPOSConnector.SetInput(PrintingLbl, JSON);
        MPOSConnector.RunModal();
        MPOSConnector.GetOutput(AutoClosed);
        if not AutoClosed then
            Message(ClosedPageErr);
    end;

    local procedure BuildJSONParams(BaseAddress: Text; Endpoint: Text; PrintJob: Text; RequestType: Text; ErrorCaption: Text) JSON: JsonObject
    begin
        JSON.Add('RequestMethod', 'PRINT');
        JSON.Add('BaseAddress', BaseAddress);
        JSON.Add('Endpoint', Endpoint);
        JSON.Add('PrintJob', PrintJob);
        JSON.Add('RequestType', RequestType);
        JSON.Add('ErrorCaption', ErrorCaption);
    end;
}
