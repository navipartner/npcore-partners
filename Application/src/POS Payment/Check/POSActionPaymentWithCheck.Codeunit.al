codeunit 6059938 "NPR POSAction PaymentWithCheck" implements "NPR POS IPaymentWFHandler", "NPR IPOS Workflow"
{
    Access = Internal;
    procedure GetPaymentHandler(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::PAYMENT_CHECK));
    end;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Check Payment Workflow';
        CheckTitleCaptionLbl: Label 'Check';
        CheckNoDescriptionCaptionLbl: Label 'Please enter the check no.';

    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('checkTitle', CheckTitleCaptionLbl);
        WorkflowConfig.AddLabel('checkNoDescription', CheckNoDescriptionCaptionLbl);
    end;

    procedure RunWorkflow(Step: Text;
                          Context: codeunit "NPR POS JSON Helper";
                          FrontEnd: codeunit "NPR POS Front End Management";
                          Sale: codeunit "NPR POS Sale";
                          SaleLine: codeunit "NPR POS Sale Line";
                          PaymentLine: codeunit "NPR POS Payment Line";
                          Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'PrepareWorkflow':
                FrontEnd.WorkflowResponse(PrepareWorkflow(Context));
            'CapturePayment':
                FrontEnd.WorkflowResponse(CapturePayment(Context,
                                                         Sale,
                                                         PaymentLine,
                                                         Setup));
        end;
    end;

    local procedure CapturePayment(Context: Codeunit "NPR POS JSON Helper";
                                   POSSale: Codeunit "NPR POS Sale";
                                   PaymentLine: codeunit "NPR POS Payment Line";
                                   Setup: codeunit "NPR POS Setup") Response: JsonObject
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        SalePOS: Record "NPR POS Sale";
        POSPaymentLine: Record "NPR POS Sale Line";
        NPRPOSActPaymentWithCheckB: Codeunit "NPR POSAct PaymentWithCheck B";
        AmountToCapture, DefaultAmountToCapture : Decimal;
        CheckNo: Text;
    begin
        POSPaymentMethod.Get(Context.GetString('paymentType'));
        AmountToCapture := Context.GetDecimal('amountToCapture');
        DefaultAmountToCapture := Context.GetDecimal('amountToCapture');
        if Context.GetString('checkNo', CheckNo) then;

        POSSale.GetCurrentSale(SalePOS);

        Clear(POSPaymentLine);
        POSPaymentLine."Register No." := Setup.GetPOSUnitNo();
        POSPaymentLine."No." := POSPaymentMethod.Code;
        POSPaymentLine."Register No." := SalePOS."Register No.";
        POSPaymentLine."Sales Ticket No." := SalePOS."Sales Ticket No.";
        POSPaymentLine.Description := POSPaymentMethod.Description;
        if CheckNo <> '' then
            POSPaymentLine.Description += ' ' + CheckNo;

        Response.ReadFrom('{}');
        Response.Add('success', NPRPOSActPaymentWithCheckB.CapturePayment(AmountToCapture,
                                                                          DefaultAmountToCapture,
                                                                          PaymentLine,
                                                                          POSPaymentLine,
                                                                          POSPaymentMethod));
        Response.Add('tryEndSale', true);
        exit(Response);
    end;

    local procedure PrepareWorkflow(Context: codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        POSPaymentMethod.Get(Context.GetString('paymentType'));
        Response.Add('askForCheckNo', POSPaymentMethod."Ask for Check No.");
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionPaymentWithCheck.Codeunit.js###
'let main=async({workflow:a,captions:t,context:e})=>{const{askForCheckNo:c}=await a.respond("PrepareWorkflow");return c&&(e.checkNo=await popup.input({title:t.checkTitle,caption:t.checkNoDescription})),await a.respond("CapturePayment",{amountToCapture:e.suggestedAmount,checkNo:e.checkNo})};'
        );
    end;

}
