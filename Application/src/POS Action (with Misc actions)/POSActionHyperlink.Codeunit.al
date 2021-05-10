codeunit 6150727 "NPR POS Action - Hyperlink"
{
    var
        ActionDescription: Label 'This action opens a hyperlink or loads a page in a frame';

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
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Single)
        then begin
            Sender.RegisterWorkflowStep('',
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
                                    'var ifrm = document.createElement("iframe");' +
                                    'ifrm.src = param.url;' +
                                    'ifrm.id = "iFrameWindow";' +
                                    'ifrm.onload= function()' +
                                    '{' +
                                        'ifrm.contentWindow.focus();' +
                                    '};' +
                                    'ifrm.style.position = "absolute";' +
                                    'ifrm.style.top="7%";' +
                                    'ifrm.style.left="7%";' +
                                    'ifrm.style.height="85%";' +
                                    'ifrm.style.width="85%";' +
                                    'ifrm.style.overflow="hidden";' +
                                    'ifrm.style.zIndex= "101";' +
                                    'document.body.appendChild(ifrm);' +

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

                                    'function closeIframe()' +
                                    '{' +
                                        'var element = document.getElementById("iFrameWindow");' +
                                        'var element2 = document.getElementById("closeIframe");' +

                                        'if (element)' +
                                            'element.parentNode.removeChild(element);' +

                                        'if (element2)' +
                                            'element2.parentNode.removeChild(element2);' +
                                    '};' +
                                    '$(document).on("click", function(e)' +
                                    '{' +
                                        'var iframe = $("iframe");' +
                                        'if (!iframe.is(e.target) && iframe.has(e.target).length === 0)' +
                                            'closeIframe();' +
                                    '});' +
                                '}' +
                            '}'
                        );
            Sender.RegisterWorkflow(false);
            Sender.RegisterTextParameter('url', 'about:blank');
            Sender.RegisterBooleanParameter('back-end', false);
            Sender.RegisterBooleanParameter('iFrame', false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        if JSON.GetBooleanParameterOrFail('back-end', ActionCode()) then
            HyperLink(JSON.GetStringParameterOrFail('url', ActionCode()));
    end;
}
