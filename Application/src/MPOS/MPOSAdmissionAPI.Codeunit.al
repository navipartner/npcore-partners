codeunit 6014493 "NPR MPOS Admission API"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Not used anymore.';

    var
        ActionDescriptionLbl: Label 'Start Admission API page for Mobile POS.';
        AdmissionFailedErr: Label 'Error opening the admission webpage.';

    local procedure ActionCode(): Code[20]
    var
        MposAdmApiLbl: Label 'MPOS_ADMISSION_API', Locked = true;
    begin
        exit(MposAdmApiLbl);
    end;

    local procedure ActionVersion(): Text[30]
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
        TicketSetup: Record "NPR TM Ticket Setup";
        JsonHelper: Codeunit "NPR POS JSON Helper";
        JSBridge: Page "NPR JS Bridge";
        JSONtext: Text;
        AdmissionCode: Code[20];
    begin

        if (not Action.IsThisAction(ActionCode())) then
            exit;

        if (WorkflowStep <> 'jsbridge') then
            exit;

        Handled := true;

        JSONtext := BuildJSONParams(TicketSetup.GetTicketAdmissionWebUrl(true), '', '', '', AdmissionFailedErr);

        JsonHelper.InitializeJObjectParser(Context);
#pragma warning disable AA0139
        AdmissionCode := JsonHelper.GetStringParameter('AdmissionCode');
#pragma warning restore
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
