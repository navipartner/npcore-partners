codeunit 6059967 "MPOS Admission API"
{
    // NPR5.33/NPKNAV/20170630  CASE 267203 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence

    TableNo = "Sale Line POS";

    trigger OnRun()
    var
        JSBridge: Page "JS Bridge";
        JSON: Text;
        mPOSAppSetup: Record "MPOS App Setup";
    begin
        mPOSAppSetup.Get(Rec."Register No.");

        if not mPOSAppSetup.Enable then
            exit;

        mPOSAppSetup.TestField("Ticket Admission Web Url");

        JSON := BuildJSONParams(mPOSAppSetup."Ticket Admission Web Url", '', '', '', Err_AdmissionFailed);

        JSBridge.SetParameters('Admission', JSON, '');
        JSBridge.RunModal;
    end;

    var
        Err_AdmissionFailed: Label 'Error opening the admission webpage';

        // TODO: CTRLUPGRADE - references a removed event publisher that's not used in Transcendence - INVESTIGATE
        /*
        [EventSubscriber(ObjectType::Codeunit, 6014630, 'HandleMetaTriggerEvent', '', false, false)]
        local procedure OpenAdmissionServiceWebPage(var Sender: Codeunit "Touch - Sale POS (Web)";MetaTriggerName: Code[50];var SalePos: Record "Sale POS";var SaleLinePos: Record "Sale Line POS";var MetaTriggerHandled: Boolean;Validering: Code[50])
        var
            JSBridge: Page "JS Bridge";
            JSON: Text;
            mPOSAppSetup: Record "MPOS App Setup";
        begin
            if MetaTriggerHandled then
              exit;

            if MetaTriggerName <> 'MPOS_ADMISSION' then
              exit;

            MetaTriggerHandled := true;

            mPOSAppSetup.Get(SaleLinePos."Register No.");
            mPOSAppSetup.TestField("Ticket Admission Web Url");

            JSON := BuildJSONParams(mPOSAppSetup."Ticket Admission Web Url", '', '', '', Err_AdmissionFailed);

            JSBridge.SetParameters('Admission', JSON, '');
            JSBridge.RunModal;
        end;
        */

    local procedure BuildJSONParams(BaseAddress: Text; Endpoint: Text; PrintJob: Text; RequestType: Text; ErrorCaption: Text) JSON: Text
    begin
        JSON := '{';
        JSON += '"RequestMethod": "ADMISSION",';
        JSON += '"BaseAddress": "' + BaseAddress + '",';
        JSON += '"Endpoint": "' + Endpoint + '",';
        JSON += '"PrintJob": "' + PrintJob + '",';
        JSON += '"RequestType": "' + RequestType + '",';
        JSON += '"ErrorCaption": "' + ErrorCaption + '"';
        JSON += '}';
    end;
}

