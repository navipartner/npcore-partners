codeunit 6150797 "NPR POSAction: Cancel Sale" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescriptionLbl: Label 'Cancel Sale';
        TitleLbl: Label 'Cancel Sale';
        PromptLbl: Label 'Are you sure you want to cancel this sales? All lines will be deleted.';
        CaptionSilent: Label 'Silent';
        DescSilent: Label 'Disables the confirmation prompt.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddLabel('title', TitleLbl);
        WorkflowConfig.AddLabel('prompt', PromptLbl);
        WorkflowConfig.AddBooleanParameter('silent', false, CaptionSilent, DescSilent);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'CheckSaleBeforeCancel':
                CheckSaleBeforeCancel(Sale);
            'CancelSale':
                FrontEnd.WorkflowResponse(CancelSaleAndStartNew());
        end;
    end;

    procedure CheckSaleBeforeCancel(Sale: Codeunit "NPR POS Sale")
    var
        POSActionCancelSaleB: Codeunit "NPR POSAction: Cancel Sale B";
    begin
        POSActionCancelSaleB.CheckSaleBeforeCancel(Sale);
    end;

    procedure CancelSaleAndStartNew(): Boolean
    var
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        POSActionCancelSaleB: Codeunit "NPR POSAction: Cancel Sale B";
    begin
        if not POSActionCancelSaleB.CancelSale() then
            exit(false);

        POSSession.GetSale(POSSale);
        POSSale.SelectViewForEndOfSale();
        exit(true);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionCancelSale.js###
'const main=async({workflow:e,captions:a,popup:t,parameters:i})=>{if(!i.silent&&!await t.confirm({title:a.title,caption:a.prompt}))return" ";await e.respond("CheckSaleBeforeCancel"),await e.respond("CancelSale")};'
        );
    end;
}
