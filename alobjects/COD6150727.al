codeunit 6150727 "POS Action - Hyperlink"
{
    // NPR5.36/VB/20170901  CASE 289035 Supporting hyperlink actions.


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for inserting an item line into the current transaction';
        TEXTitemTracking_title: Label 'Enter Serial Number';
        TEXTitemTracking_lead: Label 'This item requres serial number, enter serial number.';
        Setup: Codeunit "POS Setup";
        TEXTitemTracking_instructions: Label 'Enter serial number now and press OK. Press Cancel to enter serial number later.';
        TEXTActive: Label 'active';
        TEXTSaved: Label 'saved';
        TEXTWrongSerialOnILE: Label 'Serial number %1 for item %2 - %3 can not be used since it can not be found as received. \Press Yes to re-enter serial number now. \Press No to enter serial number later.\';
        TEXTWrongSerialOnSLP: Label 'Serial number %1 for item %2 - %3 can not be used since it is already on %4 sale %5 on register %6. \Press Yes to re-enter serial number now. \Press No to enter serial number later.\''';
        UnitPriceCaption: Label 'This is item is an item group. Specify the unit price for item.';
        UnitPriceTitle: Label 'Unit price is required';

    local procedure ActionCode(): Text
    begin
        exit ('HYPERLINK');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    var
        itemTrackingCode: Text;
    begin
        if Sender.DiscoverAction(
          ActionCode,
          ActionDescription,
          ActionVersion,
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Single)
        then begin
          with Sender do begin
            RegisterWorkflowStep('','param["back-end"] ? respond() : window.open(param.url, "_blank");');
            RegisterWorkflow(false);
            RegisterTextParameter('url','about:blank');
            RegisterBooleanParameter('back-end',false);
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: JsonObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        with JSON do begin
          InitializeJObjectParser(Context,FrontEnd);
          if GetBooleanParameter('back-end',true) then
            HyperLink(GetStringParameter('url',true));
        end;

        Handled := true;
    end;
}

