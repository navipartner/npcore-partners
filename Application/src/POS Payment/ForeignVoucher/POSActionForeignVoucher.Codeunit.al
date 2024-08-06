codeunit 6059939 "NPR POSAction ForeignVoucher" implements "NPR POS IPaymentWFHandler", "NPR IPOS Workflow"
{
    Access = Internal;
    procedure GetPaymentHandler(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::FOREIGN_VOUCHER_PMT));
    end;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Foreign Voucher Payment Workflow';
        RetailVoucherLbl: Label 'Retail Voucher Payment';
        ReferenceNoLbl: Label 'Enter Reference No.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('VoucherPaymentTitle', RetailVoucherLbl);
        WorkflowConfig.AddLabel('ReferenceNo', ReferenceNoLbl);
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
            'CapturePayment':
                FrontEnd.WorkflowResponse(CapturePayment(Context,
                                                         Sale,
                                                         SaleLine,
                                                         PaymentLine,
                                                         FrontEnd));
        end;
    end;

    local procedure CapturePayment(Context: Codeunit "NPR POS JSON Helper";
                                   POSSale: Codeunit "NPR POS Sale";
                                   SaleLine: Codeunit "NPR POS Sale Line";
                                   POSPayment: Codeunit "NPR POS Payment Line";
                                   FrontEnd: Codeunit "NPR POS Front End Management") Response: JsonObject
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRPOSActionForeignVoucherB: Codeunit "NPR POSAction ForeignVoucher B";
        NPRPOSSession: Codeunit "NPR POS Session";
        AmountToCapture, DefaultAmountToCapture : Decimal;
        VoucherNumber: Text;
    begin
        POSPaymentMethod.Get(Context.GetString('paymentType'));
        AmountToCapture := Context.GetDecimal('amountToCapture');
        DefaultAmountToCapture := Context.GetDecimal('defaultAmountToCapture');
        VoucherNumber := Context.GetString('voucherNumber');

        POSSale.GetCurrentSale(SalePOS);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Response.Add('success', NPRPOSActionForeignVoucherB.CapturePayment(AmountToCapture,
                                                                           DefaultAmountToCapture,
                                                                           POSPayment,
                                                                           SaleLinePOS,
                                                                           POSPaymentMethod,
                                                                           VoucherNumber,
                                                                           SalePOS,
                                                                           NPRPOSSession,
                                                                           FrontEnd));
        Response.Add('tryEndSale', true);
    end;



    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionForeignVoucher.Codeunit.js###
'const main=async({workflow:r,context:e,captions:u})=>(e.voucherNumber=await popup.input({title:u.VoucherPaymentTitle,caption:u.ReferenceNo}),e.voucherNumber?r.respond("CapturePayment",{amountToCapture:e.suggestedAmount,defaultAmountToCapture:e.remainingAmount}):{});'
        );
    end;

}
