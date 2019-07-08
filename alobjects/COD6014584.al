codeunit 6014584 "Mobile Print Mgt."
{
    // NPR5.29/MMV /20161011 CASE 253590 Created codeunit
    // NPR5.32/CLVA/20170310 CASE 268556 Added Json parameter "RequestMethod"
    // NPR5.32/MMV /20170313 CASE 253590 Refactored & renamed.
    // NPR5.33/MMV /20170629 CASE 282431 Explicitly commit before runmodal. This was not necessary before 5.32 due to some random commit elsewhere in the print call stack.


    trigger OnRun()
    begin
    end;

    var
        Err_PrintFailed: Label 'Print failed';
        Err_InvalidURL: Label 'Invalid URL/IP: %1';
        Err_InvalidClientType: Label 'Can not print through mobile add-in on %1';

    procedure PrintJobHTTP(Address: Text;Endpoint: Text;PrintBytes: Text;TargetEncoding: Text)
    var
        JSBridge: Page "JS Bridge";
        Convert: DotNet Convert;
        Encoding: DotNet Encoding;
        Base64: Text;
        JSON: Text;
    begin
        if not (CurrentClientType in [CLIENTTYPE::Web, CLIENTTYPE::Phone, CLIENTTYPE::Tablet]) then
          Error(Err_InvalidClientType, Format(CurrentClientType));

        if StrPos(Address, 'http') <> 1 then
          Address := 'http://' + Address;

        Encoding := Encoding.GetEncoding(TargetEncoding);
        Base64 := Convert.ToBase64String(Encoding.GetBytes(PrintBytes));

        JSON := BuildJSONParams(Address, Endpoint, Base64, 'POST', Err_PrintFailed);

        JSBridge.SetParameters('Print', JSON, '');
        //-NPR5.33 [282431]
        Commit;
        //+NPR5.33 [282431]
        JSBridge.RunModal; //js add-in should be part of the POS page in transcendence so a new page doesn't have to open just for this.
    end;

    procedure PrintJobBluetooth(DeviceName: Text;PrintBytes: Text;TargetEncoding: Text)
    var
        JSBridge: Page "JS Bridge";
        Convert: DotNet Convert;
        Encoding: DotNet Encoding;
        Base64: Text;
        JSON: Text;
    begin
        if not (CurrentClientType in [CLIENTTYPE::Web, CLIENTTYPE::Phone, CLIENTTYPE::Tablet]) then
          Error(Err_InvalidClientType, Format(CurrentClientType));

        Encoding := Encoding.GetEncoding(TargetEncoding);
        Base64 := Convert.ToBase64String(Encoding.GetBytes(PrintBytes));

        JSON := BuildJSONParams(DeviceName, '', Base64, 'BLUETOOTH', Err_PrintFailed);

        JSBridge.SetParameters('Print', JSON, '');
        //-NPR5.33 [282431]
        Commit;
        //+NPR5.33 [282431]
        JSBridge.RunModal; //js add-in should be part of the POS page in transcendence so a new page doesn't have to open just for this.
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

