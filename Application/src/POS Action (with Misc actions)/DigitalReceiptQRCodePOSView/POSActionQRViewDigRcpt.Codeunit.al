codeunit 6184697 "NPR POS Action QRViewDigRcpt" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Visualize Digital Receipt as QR Code';
        QRCodeLinkCaptionLbl: Label 'QR Code Link';
        QRCodeLinkDescriptionLbl: Label 'Specifies the link to be viewed as a QR Code.';
        FooterTextCaptionLbl: Label 'Footer Text';
        FooterTextDescriptionLbl: Label 'Specifies the footer text shown below QR Code';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('qrCodeLink', '', QRCodeLinkCaptionLbl, QRCodeLinkDescriptionLbl);
        WorkflowConfig.AddTextParameter('footerText', '', FooterTextCaptionLbl, FooterTextDescriptionLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        FrontEnd.WorkflowResponse(PrepareWorkflow(Setup, Context));
    end;

    local procedure PrepareWorkflow(Setup: codeunit "NPR POS Setup"; Context: codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        POSUnit: Record "NPR POS Unit";
        POSActionQRViewDigRcptB: Codeunit "NPR POS Action QRViewDigRcpt B";
        TimeoutIntervalSec: Integer;
        QRCodeText: Text;
        QRCodeLinkText: Text;
        FooterText: Text;
    begin
        if not Context.GetStringParameter('qrCodeLink', QRCodeLinkText) then
            Clear(QRCodeLinkText);
        if not Context.GetStringParameter('footerText', FooterText) then
            Clear(FooterText);

        Setup.GetPOSUnit(POSUnit);
        POSActionQRViewDigRcptB.PrepareQRCode(POSUnit, QRCodeLinkText, TimeoutIntervalSec, QRCodeText);
        Response.Add('qrCodeText', QRCodeText);
        Response.Add('timeoutIntervalSec', TimeoutIntervalSec);
        Response.Add('footerText', FooterText);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionQRViewDigRcpt.js###
'let main=async({workflow:l})=>{debugger;let{qrCodeText:e,timeoutIntervalSec:t,footerText:o}=await l.respond();if(e){let i=await popup.open({size:{width:"500px",height:"550px"},noScroll:!0,isSupportedOnMobile:!0,ui:[{id:"title",type:"label",caption:"Scan your receipt",style:{fontWeight:"bold",textAlign:"center",fontSize:"20px"}},{id:"html",type:"html",html:"<div style=''text-align: center; margin-top: 30px''><img src=''data:image/png;base64,"+e+"'' width=''300'' height=''300''/></div><br>"+o,className:"qrcode-dialog-html"}],buttons:[{id:"button_1",caption:"Close",enabled:!0,click:()=>{i.close({close:!0})},style:{textAlign:"center"}}]});t&&setTimeout(function(){i.close()},t*1e3)}};'
        );
    end;
}
