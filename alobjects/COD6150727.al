codeunit 6150727 "POS Action - Hyperlink"
{
    // NPR5.36/VB/20170901  CASE 289035 Supporting hyperlink actions.
    // NPR5.51/ALST/20190626 CASE 353218 open url in iframe, removed back end running


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
        exit ('1.1');
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
            //-NPR5.51
            //RegisterWorkflowStep('','param["back-end"] ? respond() : window.open(param.url, "_blank");');
            RegisterWorkflowStep('',
                                        'var ifrm = document.createElement("iframe");' +
                                        'ifrm.src = param.url;' +
                                        'ifrm.id = "checkin";' +
                                        'ifrm.style.position = "absolute";' +
                                        'ifrm.style.top="17%";' +
                                        'ifrm.style.left="17%";' +
                                        'ifrm.style.height="65%";' +
                                        'ifrm.style.width="65%";' +
                                        'ifrm.style.overflow="hidden";' +
                                        'ifrm.style.zIndex= "101";' +
                                        'document.body.appendChild(ifrm);' +

                                        'document.getElementById("np-textbox2").addEventListener(''input'', closeIframe);' +
                                        'function closeIframe()' +
                                        '{' +
                                            'var element = document.getElementById("checkin");' +
                                            'element.parentNode.removeChild(element);' +
                                        '};' +

                                        '$(document).add(parent.document).click(function(e)' +
                                        '{' +
                                            'var iframe = $("iframe");' +
                                            'if (!iframe.is(e.target) && iframe.has(e.target).length === 0)' +
                                            '{' +
                                                'var element = document.getElementById("checkin");' +
                                                'element.parentNode.removeChild(element);' +
                                            '}' +
                                        '});'
                                    );
            //+NPR5.51
            RegisterWorkflow(false);
            RegisterTextParameter('url','about:blank');
            //-NPR5.51
            //RegisterBooleanParameter('back-end',FALSE);
            //+NPR5.51
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        //-NPR5.51
        // WITH JSON DO BEGIN
        //  InitializeJObjectParser(Context,FrontEnd);
        //  IF GetBooleanParameter('back-end',TRUE) THEN
        //    HYPERLINK(GetStringParameter('url',TRUE));
        // END;
        //+NPR5.51

        Handled := true;
    end;
}

