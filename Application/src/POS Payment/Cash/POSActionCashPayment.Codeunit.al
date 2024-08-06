codeunit 6059793 "NPR POS Action: Cash Payment" implements "NPR POS IPaymentWFHandler", "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Cash Payment Workflow';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'CapturePayment':
                FrontEnd.WorkflowResponse(CapturePayment(Context, Sale, PaymentLine));
        end;
    end;

    procedure GetPaymentHandler(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::PAYMENT_CASH));
    end;

    local procedure CapturePayment(Context: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale"; POSPayment: Codeunit "NPR POS Payment Line") Response: JsonObject
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        SalePOS: Record "NPR POS Sale";
        AmountToCapture, DefaultAmountToCapture : Decimal;
        POSPaymentLine: Record "NPR POS Sale Line";
    begin
        POSPaymentMethod.Get(Context.GetString('paymentType'));
        AmountToCapture := Context.GetDecimal('amountToCapture');
        DefaultAmountToCapture := Context.GetDecimal('defaultAmountToCapture');

        POSSale.GetCurrentSale(SalePOS);

        Clear(POSPaymentLine);

        Response.ReadFrom('{}');
        Response.Add('success', CapturePayment(SalePOS, POSPaymentLine, POSPayment, POSPaymentMethod, AmountToCapture, DefaultAmountToCapture));
        Response.Add('tryEndSale', true);
        exit(Response);
    end;

    internal procedure CapturePayment(SalePOS: Record "NPR POS Sale"; POSPaymentLine: Record "NPR POS Sale Line"; POSPayment: Codeunit "NPR POS Payment Line"; POSPaymentMethod: Record "NPR POS Payment Method"; AmountToCapture: Decimal; DefaultAmountToCapture: Decimal) IsCaptured: Boolean
    begin
        POSPaymentMethod.TestField("Code");

        POSPaymentLine."Register No." := SalePOS."Register No.";
        POSPaymentLine."No." := POSPaymentMethod."Code";
        POSPaymentLine.Description := POSPaymentMethod.Description;
        POSPaymentLine."Register No." := SalePOS."Register No.";
        POSPaymentLine."Sales Ticket No." := SalePOS."Sales Ticket No.";

        if (AmountToCapture = 0) then
            exit(true);

        POSPayment.ValidateAmountBeforePayment(POSPaymentMethod, AmountToCapture, DefaultAmountToCapture);

        if (POSPaymentMethod."Fixed Rate" <> 0) then begin
            POSPaymentLine."Amount Including VAT" := 0;
            IsCaptured := POSPayment.InsertPaymentLine(POSPaymentLine, AmountToCapture);
        end else begin
            POSPaymentLine."Amount Including VAT" := AmountToCapture;
            IsCaptured := POSPayment.InsertPaymentLine(POSPaymentLine, 0);
        end;

        exit(IsCaptured);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionCashPayment.Codeunit.js###
'const main=async({workflow:t,context:n})=>t.respond("CapturePayment",{amountToCapture:n.suggestedAmount,defaultAmountToCapture:n.remainingAmount});'
        );
    end;

}
