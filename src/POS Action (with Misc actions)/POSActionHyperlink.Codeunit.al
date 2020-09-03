codeunit 6150727 "NPR POS Action - Hyperlink"
{
    // NPR5.36/VB/20170901  CASE 289035 Supporting hyperlink actions.
    // NPR5.51/ALST/20190626 CASE 353218 open url in iframe, removed back end running
    // NPR5.52/ALST/20191001 CASE 368335 enlarger frame to 85%, added iFrame parameter, fixed input event on textbox class, added close button
    //                                   added focus on iFrame content after loading, reenabled backend running


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for inserting an item line into the current transaction';
        TEXTitemTracking_title: Label 'Enter Serial Number';
        TEXTitemTracking_lead: Label 'This item requres serial number, enter serial number.';
        Setup: Codeunit "NPR POS Setup";
        TEXTitemTracking_instructions: Label 'Enter serial number now and press OK. Press Cancel to enter serial number later.';
        TEXTActive: Label 'active';
        TEXTSaved: Label 'saved';
        TEXTWrongSerialOnILE: Label 'Serial number %1 for item %2 - %3 can not be used since it can not be found as received. \Press Yes to re-enter serial number now. \Press No to enter serial number later.\';
        TEXTWrongSerialOnSLP: Label 'Serial number %1 for item %2 - %3 can not be used since it is already on %4 sale %5 on register %6. \Press Yes to re-enter serial number now. \Press No to enter serial number later.\''';
        UnitPriceCaption: Label 'This is item is an item group. Specify the unit price for item.';
        UnitPriceTitle: Label 'Unit price is required';

    local procedure ActionCode(): Text
    begin
        exit('HYPERLINK');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
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
                RegisterWorkflowStep('',    //-NPR5.52 [368335]
                                            'if (param["back-end"])' +
                                                'respond();' +
                                            'else' +
                                            '{' +
                                                'if (!param.iFrame)' +
                                                '{' +
                                                    'window.open(param.url, "_blank");' +
                                                '}' +
                                                'else' +
                                                '{' +
                                                    //+NPR5.52 [368335]
                                                    'var ifrm = document.createElement("iframe");' +
                                                    'ifrm.src = param.url;' +
                                                    //-NPR5.52 [368335]
                                                    // 'ifrm.id = "CheckIn";' +
                                                    'ifrm.id = "iFrameWindow";' +
                                                    'ifrm.onload= function()' +
                                                    '{' +
                                                        'ifrm.contentWindow.focus();' +
                                                    '};' +
                                                    //+NPR5.52 [368335]
                                                    'ifrm.style.position = "absolute";' +
                                                    'ifrm.style.top="7%";' +
                                                    'ifrm.style.left="7%";' +
                                                    'ifrm.style.height="85%";' +
                                                    'ifrm.style.width="85%";' +
                                                    'ifrm.style.overflow="hidden";' +
                                                    'ifrm.style.zIndex= "101";' +
                                                    'document.body.appendChild(ifrm);' +
                                                    //-NPR5.52 [368335]
                                                    // 'document.getElementsById("np-textbox").addEventListener(''input'', closeIframe); +'

                                                    'var button = document.createElement("button");' +
                                                    'button.id = "closeIframe";' +
                                                    'button.style.position = "absolute";' +
                                                    'button.style.top="4%";' +
                                                    'button.style.left="89%";' +
                                                    'button.style.height="3%";' +
                                                    'button.style.width="3%";' +
                                                    'button.style.zIndex= "101";' +
                                                    'button.style.backgroundColor = "red";' +
                                                    'button.style.fontWeight = "900";' +
                                                    'button.innerHTML = ''X'';' +
                                                    'document.body.appendChild(button);' +

                                                    'button.addEventListener("click", function()' +
                                                    '{' +
                                                        'closeIframe();' +
                                                    '});' +

                                                    'var textBoxElement = document.getElementsByClassName("np-textbox")[0];' +
                                                    'if (textBoxElement)' +
                                                        'textBoxElement.addEventListener(''input'', closeIframe);' +
                                                    //+NPR5.52 [368335]

                                                    'function closeIframe()' +
                                                    '{' +
                                                        //-NPR5.52 [368335]
                                                        // 'var element = document.getElementById("checkin");' +
                                                        // 'element.parentNode.removeChild(element);' +
                                                        'var element = document.getElementById("iFrameWindow");' +
                                                        'var element2 = document.getElementById("closeIframe");' +

                                                        'if (element)' +
                                                            'element.parentNode.removeChild(element);' +

                                                        'if (element2)' +
                                                            'element2.parentNode.removeChild(element2);' +
                                                    //+NPR5.52 [368335]
                                                    '};' +
                                                    //-NPR5.52 [368335]
                                                    //'$(document).add(parent.document).click(function(e)' +
                                                    '$(document).on("click", function(e)' +
                                                    //+NPR5.52 [368335]
                                                    '{' +
                                                        'var iframe = $("iframe");' +
                                                        'if (!iframe.is(e.target) && iframe.has(e.target).length === 0)' +
                                                            //-NPR5.52 [368335]
                                                            'closeIframe();' +
                                                    // '{' +
                                                    //     'var element = document.getElementById("iFrameWindow");' +
                                                    //     'element.parentNode.removeChild(element);' +
                                                    // '}' +
                                                    //+NPR5.52 [368335]
                                                    '});' +
                                                '}' +
                                            '}'
                                        );
                //+NPR5.51
                RegisterWorkflow(false);
                RegisterTextParameter('url', 'about:blank');
                //-NPR5.52 [368335]
                //-NPR5.51
                //RegisterBooleanParameter('back-end',FALSE);
                //+NPR5.51
                RegisterBooleanParameter('back-end', false);
                RegisterBooleanParameter('iFrame', false);
                //+NPR5.52 [368335]
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        //-NPR5.52 [368335]
        //-NPR5.51
        // WITH JSON DO BEGIN
        //  InitializeJObjectParser(Context,FrontEnd);
        //  IF GetBooleanParameter('back-end',TRUE) THEN
        //    HYPERLINK(GetStringParameter('url',TRUE));
        // END;
        //+NPR5.51
        with JSON do begin
            InitializeJObjectParser(Context, FrontEnd);
            if GetBooleanParameter('back-end', true) then
                HyperLink(GetStringParameter('url', true));
        end;
        //-NPR5.52 [368335]

        Handled := true;
    end;
}

