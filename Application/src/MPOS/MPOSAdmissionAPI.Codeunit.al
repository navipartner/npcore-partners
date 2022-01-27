codeunit 6014493 "NPR MPOS Admission API"
{
    Access = Internal;

    var
        ActionDescriptionLbl: Label 'Start Admission API page for Mobile POS.';
        AdmissionFailedErr: Label 'Error opening the admission webpage.';

    local procedure ActionCode(): Text
    var
        MposAdmApiLbl: Label 'MPOS_ADMISSION_API', Locked = true;
    begin
        exit(MposAdmApiLbl);
    end;

    local procedure ActionVersion(): Text
    var
        VersionLbl: Label '1.0', Locked = true;
    begin
        exit(VersionLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescriptionLbl,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple) then begin
            Sender.RegisterWorkflowStep('jsbridge', 'respond();');
            Sender.RegisterWorkflow(false);
            Sender.RegisterTextParameter('AdmissionCode', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSBridge: Page "NPR JS Bridge";
        JSONtext: Text;
        MPOSProfile: Record "NPR MPOS Profile";
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
        POSUnit.Get(POSUnit."No.");
        if not POSUnit.GetProfile(MPOSProfile) then
            exit;

        MPOSProfile.TestField("Ticket Admission Web Url");
        JSONtext := BuildJSONParams(MPOSProfile."Ticket Admission Web Url", '', '', '', AdmissionFailedErr);

        JSONMgr.InitializeJObjectParser(Context, FrontEnd);
        AdmissionCode := JSONMgr.GetStringParameter('AdmissionCode');
        JSBridge.SetParameters('Admission', JSONtext, AdmissionCode);

        JSBridge.RunModal();

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
