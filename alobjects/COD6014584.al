codeunit 6014584 "Mobile Print Mgt."
{
    // NPR5.29/MMV /20161011 CASE 253590 Created codeunit
    // NPR5.32/CLVA/20170310 CASE 268556 Added Json parameter "RequestMethod"
    // NPR5.32/MMV /20170313 CASE 253590 Refactored & renamed.
    // NPR5.33/MMV /20170629 CASE 282431 Explicitly commit before runmodal. This was not necessary before 5.32 due to some random commit elsewhere in the print call stack.
    // NPR5.52/CLVA/20190919 CASE 364011 Added support for Android and changed the use of JSBridge to Model
    // NPR5.52/MMV /20191016 CASE 349793 Added byte handling function and moved functionality into local functions.


    trigger OnRun()
    begin
    end;

    var
        Err_PrintFailed: Label 'Print failed';
        Err_InvalidURL: Label 'Invalid URL/IP: %1';
        Err_InvalidClientType: Label 'Can not print through mobile add-in on %1';
        ERROR_SESSION: Label 'Critical Error: Session object could not be retrieved.';

    procedure PrintJobHTTPRaw(Address: Text;Endpoint: Text;var TempBlob: Record TempBlob)
    var
        InStream: InStream;
        Stream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        Base64: Text;
    begin
        //-NPR5.52 [349793]
        TempBlob.Blob.CreateInStream(InStream, TEXTENCODING::UTF8);
        Stream := InStream;
        Base64 := Convert.ToBase64String(Stream.ToArray());
        PrintJobHTTPInternal(Address,Endpoint,Base64);
        //+NPR5.52 [349793]
    end;

    procedure PrintJobHTTP(Address: Text;Endpoint: Text;PrintBytes: Text;TargetEncoding: Text)
    var
        Convert: DotNet npNetConvert;
        Encoding: DotNet npNetEncoding;
        Base64: Text;
    begin
        //-NPR5.52 [349793]
        Encoding := Encoding.GetEncoding(TargetEncoding);
        Base64 := Convert.ToBase64String(Encoding.GetBytes(PrintBytes));
        PrintJobHTTPInternal(Address,Endpoint,Base64);
        //+NPR5.52 [349793]
    end;

    local procedure PrintJobHTTPInternal(Address: Text;Endpoint: Text;Base64: Text)
    var
        JSBridge: Page "JS Bridge";
        JSON: Text;
    begin
        if not (CurrentClientType in [CLIENTTYPE::Web, CLIENTTYPE::Phone, CLIENTTYPE::Tablet]) then
          Error(Err_InvalidClientType, Format(CurrentClientType));

        if StrPos(Address, 'http') <> 1 then
          Address := 'http://' + Address;

        JSON := BuildJSONParams(Address, Endpoint, Base64, 'POST', Err_PrintFailed);

        JSBridge.SetParameters('Print', JSON, '');
        Commit;
        JSBridge.RunModal;
    end;

    procedure PrintJobBluetooth(DeviceName: Text;PrintBytes: Text;TargetEncoding: Text)
    var
        Convert: DotNet npNetConvert;
        Encoding: DotNet npNetEncoding;
        Base64: Text;
    begin
        //-NPR5.52 [349793]
        Encoding := Encoding.GetEncoding(TargetEncoding);
        Base64 := Convert.ToBase64String(Encoding.GetBytes(PrintBytes));
        PrintJobBluetoothInternal(DeviceName, Base64);
        //+NPR5.52 [349793]
    end;

    procedure PrintJobBluetoothRaw(DeviceName: Text;var TempBlob: Record TempBlob)
    var
        InStream: InStream;
        Stream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        Base64: Text;
    begin
        //-NPR5.52 [349793]
        TempBlob.Blob.CreateInStream(InStream, TEXTENCODING::UTF8);
        Stream := InStream;
        Base64 := Convert.ToBase64String(Stream.ToArray());
        PrintJobBluetoothInternal(DeviceName, Base64);
        //+NPR5.52 [349793]
    end;

    local procedure PrintJobBluetoothInternal(DeviceName: Text;Base64: Text)
    var
        JSBridge: Page "JS Bridge";
        JSON: Text;
        Model: DotNet npNetModel;
        JSString: Text;
        POSFrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        ActiveModelID: Guid;
    begin
        if not (CurrentClientType in [CLIENTTYPE::Web, CLIENTTYPE::Phone, CLIENTTYPE::Tablet]) then
          Error(Err_InvalidClientType, Format(CurrentClientType));

        JSON := BuildJSONParams(DeviceName, '', Base64, 'BLUETOOTH', Err_PrintFailed);

        //-NPR5.52 [362731]
        // JSBridge.SetParameters('Print', JSON, '');
        // //-NPR5.33 [282431]
        // COMMIT;
        // //+NPR5.33 [282431]
        // JSBridge.RUNMODAL; //js add-in should be part of the POS page in transcendence so a new page doesn't have to open just for this.
        if not POSSession.IsActiveSession(POSFrontEnd) then
          Error(ERROR_SESSION);

        Model := Model.Model();
        JSString := 'function CallNativeFunction(jsonobject) { ';
        JSString += 'debugger; ';
        JSString += 'var userAgent = navigator.userAgent || navigator.vendor || window.opera; if (/android/i.test(userAgent)) { ';
        JSString += 'window.top.mpos.handleBackendMessage(jsonobject); } ';
        JSString += 'if (/iPad|iPhone|iPod/.test(userAgent) && !window.MSStream) { ';
        JSString += 'window.webkit.messageHandlers.invokeAction.postMessage(jsonobject);}}';
        Model.AddScript(JSString);
        Model.AddScript('CallNativeFunction('+JSON+');');
        ActiveModelID := POSFrontEnd.ShowModel(Model);
        POSFrontEnd.CloseModel(ActiveModelID);
        Clear(ActiveModelID);
        //+NPR5.52 [362731]
    end;

    local procedure "-- Aux"()
    begin
    end;

    local procedure BuildJSONParams(BaseAddress: Text;Endpoint: Text;PrintJob: Text;RequestType: Text;ErrorCaption: Text) JSON: Text
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

