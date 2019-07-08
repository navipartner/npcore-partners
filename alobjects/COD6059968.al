codeunit 6059968 "MPOS EOD API"
{
    // NPR5.33/NPKNAV/20170630  CASE 267203 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence

    TableNo = "Sale Line POS";

    trigger OnRun()
    var
        JSBridge: Page "JS Bridge";
        JSON: Text;
        mPOSAppSetup: Record "MPOS App Setup";
        mPOSPaymentGateway: Record "MPOS Payment Gateway";
    begin
        mPOSAppSetup.Get(Rec."Register No.");
        if not mPOSAppSetup.Enable then
          exit;

        mPOSAppSetup.TestField("Payment Gateway");
        mPOSPaymentGateway.Get(mPOSAppSetup."Payment Gateway");
        mPOSPaymentGateway.TestField("Merchant Id");

        JSON := BuildJSONParams(mPOSPaymentGateway."Merchant Id", '', '', '', Err_EODFailed);

        JSBridge.SetParameters('EOD', JSON, '');
        JSBridge.RunModal;
    end;

    var
        Err_EODFailed: Label 'Error running EndOfDay on the terminal';

    local procedure BuildJSONParams(BaseAddress: Text;Endpoint: Text;PrintJob: Text;RequestType: Text;ErrorCaption: Text) JSON: Text
    begin
        JSON := '{';
        JSON += '"RequestMethod": "EOD",';
        JSON += '"BaseAddress": "' + BaseAddress + '",';
        JSON += '"Endpoint": "' + Endpoint + '",';
        JSON += '"PrintJob": "' + PrintJob + '",';
        JSON += '"RequestType": "' + RequestType + '",';
        JSON += '"ErrorCaption": "' + ErrorCaption + '"';
        JSON += '}';
    end;
}

