codeunit 6150727 "NPR POS Action - Hyperlink" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This action opens a hyperlink or loads a page in a frame';
        ParamUrl_CptLbl: Label 'url';
        ParamUrl_DescLbl: Label 'URL that will be opened when button is pressed.';
        ParamBackend_CptLbl: Label 'back-end';
        ParamBackend_DescLbl: Label 'Specifies if the back-end will be used for opening hyperlink.';
        ParamIframe_CptLbl: Label 'iFrame';
        ParamIframe_DescLbl: Label 'Specifies if hyperlink will be opened in frame window or not.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('url', 'about:blank', ParamUrl_CptLbl, ParamUrl_DescLbl);
        WorkflowConfig.AddBooleanParameter('back-end', false, ParamBackend_CptLbl, ParamBackend_DescLbl);
        WorkflowConfig.AddBooleanParameter('iFrame', false, ParamIframe_CptLbl, ParamIframe_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        BackEnd: Boolean;
    begin
        BackEnd := Context.GetBooleanParameter('back-end');
        If BackEnd then
            HyperLink(Context.GetStringParameter('url'));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionHyperlink.js###
'let main=async({workflow:a,parameters:d})=>{debugger;if(d["back-end"])await a.respond();else if(!d.iFrame)window.open(d.url,"_blank");else{let o=function(){var t=document.getElementById("iFrameWindow"),l=document.getElementById("closeIframe");t&&t.parentNode.removeChild(t),l&&l.parentNode.removeChild(l)};var s=o,e=document.createElement("iframe");e.src=d.url,e.id="iFrameWindow",e.onload=function(){e.contentWindow.focus()},e.style.position="absolute",e.style.top="7%",e.style.left="7%",e.style.height="85%",e.style.width="85%",e.style.overflow="hidden",e.style.zIndex="101",document.body.appendChild(e);var n=document.createElement("button");n.id="closeIframe",n.style.position="absolute",n.style.top="4%",n.style.left="89%",n.style.height="3%",n.style.width="3%",n.style.zIndex="101",n.style.backgroundColor="red",n.style.fontWeight="900",n.innerHTML="X",document.body.appendChild(n),n.addEventListener("click",function(){o()});var i=document.getElementsByClassName("np-textbox")[0];i&&i.addEventListener("input",o),$(document).on("click",function(t){var l=$("iframe");!l.is(t.target)&&l.has(t.target).length===0&&o()})}};'
        )
    end;
}
