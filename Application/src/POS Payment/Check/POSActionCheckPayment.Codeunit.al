codeunit 6059791 "NPR POS Action Check Payment" implements "NPR IPOS Workflow"
{

    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This action handles check payment';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'CapturePayment':
                FrontEnd.WorkflowResponse(HandleCheckPayment(Context, PaymentLine));
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionobject_name.Codeunit.js###
''
        );
    end;

    local procedure HandleCheckPayment(Context: Codeunit "NPR POS JSON Helper"; PaymentLineMgr: codeunit "NPR POS Payment Line") Result: JsonObject
    begin
        Result.ReadFrom('{}');

        Result.Add('to', Context.ToString());
        Result.Add('do', PaymentLineMgr.GetNextLineNo());
        Result.Add('endSale', true);
        Result.Add('success', true);
    end;

    /*
        internal procedure CapturePayment(SalePOS: Record "NPR POS Sale"; POSPaymentLine: Record "NPR POS Sale Line"; PaymentLineMgr: Codeunit "NPR POS Payment Line"; POSPaymentMethod: Record "NPR POS Payment Method"; AmountToCapture: Decimal) IsCaptured: Boolean
        begin
            POSPaymentMethod.TestField("Code");

            POSPaymentLine."Register No." := SalePOS."Register No.";
            POSPaymentLine."No." := POSPaymentMethod."Code";
            POSPaymentLine.Description := POSPaymentMethod.Description;
            POSPaymentLine."Register No." := SalePOS."Register No.";
            POSPaymentLine."Sales Ticket No." := SalePOS."Sales Ticket No.";

            if (AmountToCapture = 0) then
                exit(true);

            POSPayment.ValidateAmountBeforePayment(POSPaymentMethod, AmountToCapture);

            if (POSPaymentMethod."Fixed Rate" <> 0) then begin
                POSPaymentLine."Amount Including VAT" := 0;
                IsCaptured := POSPayment.InsertPaymentLine(POSPaymentLine, AmountToCapture);
            end else begin
                POSPaymentLine."Amount Including VAT" := AmountToCapture;
                IsCaptured := POSPayment.InsertPaymentLine(POSPaymentLine, 0);
            end;

            exit(IsCaptured);
        end;
        */
}