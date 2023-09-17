codeunit 6059889 "NPR POS Action: Coupon Verify" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This action handles Coupon Verify.';
        Title: Label 'Coupon Verify';
        ReferenceNoPrompt: Label 'Coupon Reference Number';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('title', Title);
        WorkflowConfig.AddLabel('voucherprompt', ReferenceNoPrompt);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionCouponVerify.js###
'let main=async({workflow:n,popup:i,captions:e})=>{let t=await i.input({title:e.title,caption:e.voucherprompt});t!==null&&await n.respond("VerifyCoupon",{ReferenceNo:t})};'
        )
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
    begin
        case Step of
            'VerifyCoupon':
                VerifyCoupon(Context);
        end;
    end;

    local procedure VerifyCoupon(Context: Codeunit "NPR POS JSON Helper")
    var
        TooLongErr: Label '%1 cannot have more than %2 characters.';
        ReferenceNo: Text;
        NPNpDCCouponCheck: Codeunit "NPR POSAction: Coupon Verify B";
    begin
        ReferenceNo := Context.GetString('ReferenceNo');
        if StrLen(ReferenceNo) > 50 then
            Error(TooLongErr, 'ReferenceNo', 50);
        NPNpDCCouponCheck.VerifyCoupon(CopyStr(ReferenceNo, 1, 50));
    end;
}
