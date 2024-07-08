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
        Request: JsonObject;
        EFTExtTerminalInteg: Codeunit "NPR EFT Ext. Terminal Integ.";
        Success: Boolean;
    begin
        Request := Context.GetJsonObject('request');

        EftTransactionRequest.Get(EFTExtTerminalInteg.HandleResponse(Request, Result, Context));
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
'let main=async({context:r,workflow:s,popup:a,captions:i})=>{debugger;let e={success:!1,tryEndSale:!1};if(r.request.AmountIn>0){if(r.request.PromptCardDigits){if(r.request.CardDigits=await a.stringpad({caption:i.PromptCardDigits}),r.request.CardDigits===null||r.request.CardDigits==="")return e;var u=/^(\d+,)*(\d+)$/.test(r.request.CardDigits);if(!u)return await a.error("Please enter numbers only."),e}if(r.request.PromptCardHolder&&(r.request.CardHolder=await a.input({caption:i.PromptCardHolder}),r.request.CardHolder===null))return e;if(r.request.PromptApprovalCode){if(confirmAns=await a.confirm(i.PromptConfirmation+r.request.AmountIn+"?"),!confirmAns)return e;if(r.request.ApprovalCode=await a.input({caption:i.PromptApprovalCode}),r.request.ApprovalCode==="")return a.error(i.InvalidApprovalCode),e;if(r.request.ApprovalCode===null)return e}}const{success:d,endSale:t}=await s.respond("FinalizeRequest");return e.success=d,e.tryEndSale=t,e};'
        );
    end;

}
