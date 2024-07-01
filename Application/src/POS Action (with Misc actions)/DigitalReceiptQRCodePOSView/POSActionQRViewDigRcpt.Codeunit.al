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
        QRCodeLinkText: Text;
        FooterText: Text;
    begin
        if not Context.GetStringParameter('qrCodeLink', QRCodeLinkText) then
            Clear(QRCodeLinkText);
        if not Context.GetStringParameter('footerText', FooterText) then
            Clear(FooterText);

        Setup.GetPOSUnit(POSUnit);
        POSActionQRViewDigRcptB.PrepareQRCode(POSUnit, TimeoutIntervalSec);
        Response.Add('qrCodeText', QRCodeLinkText);
        Response.Add('timeoutIntervalSec', TimeoutIntervalSec);
        Response.Add('footerText', FooterText);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionQRViewDigRcpt.js###
'let main=async({workflow:t})=>{debugger;let{qrCodeText:e,timeoutIntervalSec:a,footerText:o}=await t.respond();e&&await popup.qr({caption:o,qrData:e,timeoutInSeconds:a},"Scan your receipt")};'
        );
    end;
}
