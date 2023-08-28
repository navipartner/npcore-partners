codeunit 6151443 "NPR POSAction SS CreateAndPay" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        _ExistingSale: Option None,Same,Diff_Paid,Diff_Unpaid;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This action allows you to create a POS sale and fully pay it via terminal';
        SaleContentTitle: Label 'Sale Contents';
        SaleCOntentDesc: Label 'The contents of the sale to be created';
        PaymentTypeTitle: Label 'Payment Type';
        PaymentTypeDesc: Label 'The payment type to pay with';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.SetWorkflowTypeUnattended();
        WorkflowConfig.AddTextParameter('saleContents', '', SaleContentTitle, SaleCOntentDesc);
        WorkflowConfig.AddTextParameter('paymentType', '', PaymentTypeTitle, PaymentTypeDesc);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        SaleContents: JsonObject;
        SaleId: Guid;
        TicketToken: Text;
        JToken: JsonToken;
        POSActionSavePOSSvSlB: Codeunit "NPR POS Action: SavePOSSvSl B";
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        POSActionCancelSaleB: Codeunit "NPR POSAction: Cancel Sale B";
        ExistingSale: Integer;
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        TMTicketRetailMgt: Codeunit "NPR TM Ticket Retail Mgt.";
        POSSaleRec: Record "NPR POS Sale";
    begin
        SaleContents.ReadFrom(Context.GetStringParameter('saleContents'));

        SaleContents.Get('saleId', JToken);
        Evaluate(SaleId, JToken.AsValue().AsText());

        SaleContents.Get('ticketToken', JToken);
        TicketToken := JToken.AsValue().AsText();

        ExistingSale := CheckForExistingSale(SaleId, TicketToken);

        case ExistingSale of
            _ExistingSale::Same:
                begin
                    //try end sale again with payment (skips actual payment if 0 remaining)
                    FrontEnd.WorkflowResponse(GetPaymentWorkflow(Context));
                    exit;
                end;

            _ExistingSale::Diff_Paid:
                begin
                    // TODO: Log to sentry as this is not something you should normally be able to make happen.
                    // We should probably make the reload button call backend so it is harder to trigger.

                    //save sale so it can be error-handled on a full size POS (it contains money!).
                    POSActionSavePOSSvSlB.SaveSale(POSSavedSaleEntry);
                end;

            _ExistingSale::Diff_Unpaid:
                begin
                    //delete old sale
                    POSActionCancelSaleB.CancelSale();
                end;
        end;

        POSSession.StartTransaction(SaleId);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(POSSaleRec);
        TMTicketRetailMgt.CreatePOSLinesForReservationRequest(TicketToken, POSSaleRec);

        FrontEnd.WorkflowResponse(GetPaymentWorkflow(Context));
    end;

    local procedure CheckForExistingSale(SaleId: Guid; TicketToken: Guid): Integer
    var
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSaleRec: Record "NPR POS Sale";
        TMTicketRetailMgt: Codeunit "NPR TM Ticket Retail Mgt.";
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(POSSaleRec);
        if POSSaleRec."Sales Ticket No." = '' then
            Exit(_ExistingSale::None);

        if POSSaleLine.IsEmpty() then
            Exit(_ExistingSale::None);

        if POSSaleRec.SystemId = SaleId then begin
            if TMTicketRetailMgt.IsFullyLinkedToTicket(TicketToken, POSSaleRec) then begin
                exit(_ExistingSale::Same);
            end;
        end;

        if POSPaymentLine.IsEmpty() then begin
            Exit(_ExistingSale::Diff_Unpaid);
        end else begin
            Exit(_ExistingSale::Diff_Paid);
        end;
    end;

    local procedure GetPaymentWorkflow(JSON: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        workflowParameters: JsonObject;
    begin
        workflowParameters.Add('paymentType', JSON.GetStringParameter('paymentType'));

        Response.Add('paymentWorkflow', Format(Enum::"NPR POS Workflow"::"SS-PAYMENT"));
        Response.Add('paymentWorkflowParameters', workflowParameters)
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSSCreateAndPay.js###
'let main=async({parameters:a})=>{let{paymentWorkflow:e,paymentWorkflowParameters:r}=await workflow.respond("createAndPreparePayment",a.saleContents);await workflow.run(e,{parameters:r})};'
        )
    end;
}
