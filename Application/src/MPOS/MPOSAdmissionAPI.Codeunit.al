codeunit 6014493 "NPR MPOS Admission API"
{

    var
        ActionDescription: Label 'Start Admission API page for Mobile POS.';
        Err_AdmissionFailed: Label 'Error opening the admission webpage.';

    local procedure ActionCode(): Text
    begin
        exit('MPOS_ADMISSION_API');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do begin
            if DiscoverAction(
              ActionCode(),
              ActionDescription,
              ActionVersion(),
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple) then begin
                RegisterWorkflowStep('jsbridge', 'respond();');
                RegisterWorkflow(false);
                RegisterTextParameter('AdmissionCode', '');
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSBridge: Page "NPR JS Bridge";
        JSONtext: Text;
        mPOSAppSetup: Record "NPR MPOS App Setup";
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
        JSONMgr: Codeunit "NPR POS JSON Management";
        AdmissionCode: Code[20];
    begin

        if (not Action.IsThisAction(ActionCode())) then
            exit;

        if (WorkflowStep <> 'jsbridge') then
            exit;

        Handled := true;

        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        mPOSAppSetup.Get(POSUnit."No.");
        if not mPOSAppSetup.Enable then
            exit;

        mPOSAppSetup.TestField("Ticket Admission Web Url");
        JSONtext := BuildJSONParams(mPOSAppSetup."Ticket Admission Web Url", '', '', '', Err_AdmissionFailed);

        JSONMgr.InitializeJObjectParser(Context, FrontEnd);
        AdmissionCode := JSONMgr.GetStringParameter('AdmissionCode', false);
        JSBridge.SetParameters('Admission', JSONtext, AdmissionCode);

        JSBridge.RunModal;

    end;

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