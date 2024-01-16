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
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('salesTicketNo', '', SalesTicketNoCaptionLbl, SalesTicketNoDescriptionLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        FrontEnd.WorkflowResponse(PrepareWorkflow(Context, Sale));
    end;

    local procedure PrepareWorkflow(Context: codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale") Response: JsonObject
    var
        LastSalePOSEntry: Record "NPR POS Entry";
        DigitalReceiptLink: Text;
        SalesTicketNoText: Text;
    begin
        if not Context.GetStringParameter('salesTicketNo', SalesTicketNoText) then
            Clear(SalesTicketNoText);

        if SalesTicketNoText = '' then begin
            Sale.GetLastSalePOSEntry(LastSalePOSEntry);
            SalesTicketNoText := LastSalePOSEntry."Document No.";
        end;
#pragma warning disable AA0139
        POSActionIssueDigRcptB.CreateDigitalReceipt(SalesTicketNoText, DigitalReceiptLink);
#pragma warning restore AA0139
        Response.Add('digitalReceiptLink', DigitalReceiptLink);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionIssueDigRcpt.js###
'let main=async({workflow:e})=>{debugger;let{digitalReceiptLink:a}=await e.respond();a&&await e.run("VIEW_DIG_RCPT_QRCODE",{parameters:{qrCodeLink:a}})};'
        );
    end;
}
