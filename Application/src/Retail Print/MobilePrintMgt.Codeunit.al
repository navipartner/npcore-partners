// TODO: Case 430713
//       This dialog does not really need Model UI. The only thing it does is that it runs some JavaScript. It should never have been
//       built with Model UI. This can be done easily with a Workflows 2.0 action that runs the exact same JavaScript code.

codeunit 6014584 "NPR Mobile Print Mgt."
{
    Access = Internal;
    var
        Err_PrintFailed: Label 'Print failed';
        Err_InvalidClientType: Label 'Can not print through mobile add-in on %1';
        ERROR_SESSION: Label 'Critical Error: Session object could not be retrieved.';

    procedure PrintJobHTTP(Address: Text; Endpoint: Text; PrintBytes: Text; TargetEncoding: Text)
    var
        Convert: Codeunit "Base64 Convert";
        TextEncodingMapper: Codeunit "NPR Text Encoding Mapper";
        Base64: Text;
    begin
        Base64 := Convert.ToBase64(PrintBytes, TextEncoding::Windows, TextEncodingMapper.EncodingNameToCodePageNumber(TargetEncoding));
        PrintJobHTTPInternal(Address, Endpoint, Base64);
    end;

    local procedure PrintJobHTTPInternal(Address: Text; Endpoint: Text; Base64: Text)
    var
        JSON: Text;
        Model: DotNet NPRNetModel;
        JSString: Text;
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        ActiveModelID: Guid;
    begin
        if not (CurrentClientType in [CLIENTTYPE::Web, CLIENTTYPE::Phone, CLIENTTYPE::Tablet]) then
            Error(Err_InvalidClientType, Format(CurrentClientType));

        if StrPos(Address, 'http') <> 1 then
            Address := 'http://' + Address;

        JSON := BuildJSONParams(Address, Endpoint, Base64, 'POST', Err_PrintFailed);

        if not POSSession.IsActiveSession(POSFrontEnd) then
            Error(ERROR_SESSION);

        Model := Model.Model();
        JSString := 'function CallNativeFunction(jsonobject) { ';
        JSString += 'debugger; ';
        JSString += 'var userAgent = navigator.userAgent || navigator.vendor || window.opera; if (/android/i.test(userAgent)) { ';
        JSString += 'window.top.mpos.handleBackendMessage(jsonobject); } ';
        JSString += 'if (/iPad|iPhone|iPod|Macintosh/.test(userAgent) && !window.MSStream) { ';
        JSString += 'window.webkit.messageHandlers.invokeAction.postMessage(jsonobject);}}';
        Model.AddScript(JSString);
        Model.AddScript('CallNativeFunction(' + JSON + ');');
        ActiveModelID := POSFrontEnd.ShowModel(Model);
        POSFrontEnd.CloseModel(ActiveModelID);
        Clear(ActiveModelID);
    end;

    procedure PrintJobBluetooth(DeviceName: Text; PrintBytes: Text; TargetEncoding: Text)
    var
        Convert: Codeunit "Base64 Convert";
        TextEncodingMapper: Codeunit "NPR Text Encoding Mapper";
        Base64: Text;
    begin
        Base64 := Convert.ToBase64(PrintBytes, TextEncoding::Windows, TextEncodingMapper.EncodingNameToCodePageNumber(TargetEncoding));
        PrintJobBluetoothInternal(DeviceName, Base64);
    end;

    local procedure PrintJobBluetoothInternal(DeviceName: Text; Base64: Text)
    var
        JSON: Text;
        Model: DotNet NPRNetModel;
        JSString: Text;
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        ActiveModelID: Guid;
    begin
        if not (CurrentClientType in [CLIENTTYPE::Web, CLIENTTYPE::Phone, CLIENTTYPE::Tablet]) then
            Error(Err_InvalidClientType, Format(CurrentClientType));

        JSON := BuildJSONParams(DeviceName, '', Base64, 'BLUETOOTH', Err_PrintFailed);

        if not POSSession.IsActiveSession(POSFrontEnd) then
            Error(ERROR_SESSION);

        Model := Model.Model();
        JSString := 'function CallNativeFunction(jsonobject) { ';
        JSString += 'debugger; ';
        JSString += 'var userAgent = navigator.userAgent || navigator.vendor || window.opera; if (/android/i.test(userAgent)) { ';
        JSString += 'window.top.mpos.handleBackendMessage(jsonobject); } ';
        JSString += 'if (/iPad|iPhone|iPod|Macintosh/.test(userAgent) && !window.MSStream) { ';
        JSString += 'window.webkit.messageHandlers.invokeAction.postMessage(jsonobject);}}';
        Model.AddScript(JSString);
        Model.AddScript('CallNativeFunction(' + JSON + ');');
        ActiveModelID := POSFrontEnd.ShowModel(Model);
        POSFrontEnd.CloseModel(ActiveModelID);
        Clear(ActiveModelID);
    end;

    local procedure BuildJSONParams(BaseAddress: Text; Endpoint: Text; PrintJob: Text; RequestType: Text; ErrorCaption: Text) JSON: Text
    begin
        JSON := '{';
        JSON += '"RequestMethod": "PRINT",';
        JSON += '"BaseAddress": "' + BaseAddress + '",';
        JSON += '"Endpoint": "' + Endpoint + '",';
        JSON += '"PrintJob": "' + PrintJob + '",';
        JSON += '"RequestType": "' + RequestType + '",';
        JSON += '"ErrorCaption": "' + ErrorCaption + '"';
        JSON += '}';
    end;
}
