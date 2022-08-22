codeunit 6150797 "NPR POSAction: Cancel Sale" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescriptionLbl: Label 'Cancel Sale';
        ParamSecurityOptions: Label 'None,SalespersonPassword,CurrentSalespersonPassword,SupervisorPassword', Locked = true;
        ParamSecurity_NameLbl: Label 'Security';
        ParamSecurity_DescLbl: Label 'Defines security type.';
        TitleLbl: Label 'Cancel Sale';
        PromptLbl: Label 'Are you sure you want to cancel this sales? All lines will be deleted.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddLabel('title', TitleLbl);
        WorkflowConfig.AddLabel('prompt', PromptLbl);
        WorkflowConfig.AddOptionParameter(
            'Security',
            ParamSecurityOptions,
            SelectStr(1, ParamSecurityOptions),
            ParamSecurity_NameLbl,
            ParamSecurity_DescLbl,
            ParamSecurityOptions);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'CheckSaleBeforeCancel':
                CheckSaleBeforeCancel();
            'CancelSale':
                FrontEnd.WorkflowResponse(CancelSaleAndStartNew());
        end;
    end;

    procedure CheckSaleBeforeCancel()
    var
        POSActionCancelSaleB: Codeunit "NPR POSAction: Cancel Sale B";
    begin
        POSActionCancelSaleB.CheckSaleBeforeCancel();
    end;

    procedure CancelSaleAndStartNew(): Boolean
    var
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        POSActionCancelSaleB: Codeunit "NPR POSAction: Cancel Sale B";
    begin
        if not POSActionCancelSaleB.CancelSale(POSSession) then
            exit(false);

        POSSession.GetSale(POSSale);
        POSSale.SelectViewForEndOfSale(POSSession);
        exit(true);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionCancelSale.js###
'let main=async({workflow:e,captions:a,popup:t})=>{debugger;if(await t.confirm({title:a.title,caption:a.prompt}))await e.respond("CheckSaleBeforeCancel"),await e.respond("CancelSale");else return" "};'
        );
    end;
}
