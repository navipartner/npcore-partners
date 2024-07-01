codeunit 6184731 "NPR POS Action: IssueDigRcpt" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        POSActionIssueDigRcptB: Codeunit "NPR POS Action: IssueDigRcpt B";

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Issue Digital Receipt after end of POS Sale.';
        SalesTicketNoCaptionLbl: Label 'Document No.';
        SalesTicketNoDescriptionLbl: Label 'Specifies the Document No.';
        FooterTextCaptionLbl: Label 'Footer Text';
        FooterTextDescriptionLbl: Label 'Specifies the footer text shown below QR Code';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('salesTicketNo', '', SalesTicketNoCaptionLbl, SalesTicketNoDescriptionLbl);
        WorkflowConfig.AddTextParameter('footerText', '', FooterTextCaptionLbl, FooterTextDescriptionLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        FrontEnd.WorkflowResponse(PrepareWorkflow(Context, Sale, Setup));
    end;

    local procedure PrepareWorkflow(Context: codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; Setup: codeunit "NPR POS Setup") Response: JsonObject
    var
        LastSalePOSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        POSActionQRViewDigRcptB: Codeunit "NPR POS Action QRViewDigRcpt B";
        DigitalReceiptLink: Text;
        FooterText: Text;
        SalesTicketNoText: Text;
        TimeoutIntervalSec: Integer;
    begin
        if not Context.GetStringParameter('salesTicketNo', SalesTicketNoText) then
            Clear(SalesTicketNoText);
        if not Context.GetStringParameter('footerText', FooterText) then
            Clear(FooterText);

        if SalesTicketNoText = '' then begin
            Sale.GetLastSalePOSEntry(LastSalePOSEntry);
            SalesTicketNoText := LastSalePOSEntry."Document No.";
        end;
#pragma warning disable AA0139
        POSActionIssueDigRcptB.CreateDigitalReceipt(SalesTicketNoText, DigitalReceiptLink, FooterText);
#pragma warning restore AA0139
        Setup.GetPOSUnit(POSUnit);
        POSActionQRViewDigRcptB.PrepareQRCode(POSUnit, TimeoutIntervalSec);
        Response.Add('footerText', FooterText);
        Response.Add('digitalReceiptLink', DigitalReceiptLink);
        Response.Add('timeoutIntervalSec', TimeoutIntervalSec);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionIssueDigRcpt.js###
'let main=async({workflow:t})=>{debugger;let{digitalReceiptLink:e,footerText:a,timeoutIntervalSec:i}=await t.respond();e&&await popup.qr({caption:a,qrData:e,timeoutInSeconds:i},"Scan your receipt")};'
        );
    end;
}
