codeunit 6184632 "NPR POS Action Ext.Terminal" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Template for EFT External Terminal Request Workflow';
        PromptCardDigitLbl: Label 'Last 4 Digit';
        PromptCardHolderLbl: label 'Cardholder Name';
        PromptTransactionApprovedLbl: Label 'Did external EFT approve transaction for amount of ';
        PromptApprovalCodeLbl: Label 'Approval Code';
        InvalidAppCodeLbl: Label 'Approval Code cann''t be empty. Transaction has failed.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('PromptCardDigits', PromptCardDigitLbl);
        WorkflowConfig.AddLabel('PromptCardHolder', PromptCardHolderLbl);
        WorkflowConfig.AddLabel('PromptApprovalCode', PromptApprovalCodeLbl);
        WorkflowConfig.AddLabel('PromptConfirmation', PromptTransactionApprovedLbl);
        WorkflowConfig.AddLabel('InvalidApprovalCode', InvalidAppCodeLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'FinalizeRequest':
                Frontend.WorkflowResponse(ProcessResult(Context));
        end;
    end;

    local procedure ProcessResult(Context: Codeunit "NPR POS JSON Helper") Result: JsonObject
    var
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        EftFramework: Codeunit "NPR EFT Framework Mgt.";
        HwcRequest: JsonObject;
        EFTExtTerminalInteg: Codeunit "NPR EFT Ext. Terminal Integ.";
        Success: Boolean;
    begin
        HwcRequest := Context.GetJsonObject('hwcRequest');

        EftTransactionRequest.Get(EFTExtTerminalInteg.HandleResponse(HwcRequest, Result, Context));
        EftFramework.EftIntegrationResponseReceived(EftTransactionRequest);
        Success := EftTransactionRequest.Successful;

        if (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND]) then
            Result.Add('endSale', true)
        else
            Result.Add('endSale', false);
        Result.Add('success', Success);
        exit(Result);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionExtTerminal.js###
'let main=async({context:e,workflow:s,popup:a,captions:i})=>{let r={success:!1,endSale:!1};if(e.hwcRequest.AmountIn>0){if(e.hwcRequest.PromptCardDigits&&(e.hwcRequest.CardDigits=await a.intpad({caption:i.PromptCardDigits}),e.hwcRequest.CardDigits===null||e.hwcRequest.CardDigits===0)||e.hwcRequest.PromptCardHolder&&(e.hwcRequest.CardHolder=await a.input({caption:i.PromptCardHolder}),e.hwcRequest.CardHolder===null))return r;if(e.hwcRequest.PromptApprovalCode){if(confirmAns=await a.confirm(i.PromptConfirmation+e.hwcRequest.AmountIn+"?"),!confirmAns)return r;if(e.hwcRequest.ApprovalCode=await a.input({caption:i.PromptApprovalCode}),e.hwcRequest.ApprovalCode==="")return a.error(i.InvalidApprovalCode),r;if(e.hwcRequest.ApprovalCode===null)return r}}const{success:u,endSale:l}=await s.respond("FinalizeRequest");return r.success=u,r.endSale=l,r};'
        );
    end;

}
