codeunit 6151177 "NPR POS Action: Prnt Post.Exch" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config")
    var
        ActionDescriptionLbl: Label 'This action is used to print an exchange label after a sale has been posted, either last sale or selectively.';
        TemplateParamLbl: Label 'Template';
        TemplateParam_DescLbl: Label 'Specify template';
        LastSaleParamLbl: Label 'Last Sale';
        LastSaleParam_DescLbl: Label 'Specifies to print last sale';
        SingleLineParamLbl: Label 'Single Line';
        SingleLineParam_DescLbl: Label 'Specifies to print single line';
        ParamDTransactionFilterCaptionLbl: Label 'Transactions Filter';
        ParamTransactionFilterDescrLbl: Label 'Specifies the Transactions Filter used.';
        ParamTransactionFilterOptionsCaptionLbl: Label 'POS Unit,POS Store,All transactions';
        ParamTransactionFilterOptionsLbl: Label 'posunit,posstore,alltransactions', Locked = true;
    begin
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddJavascript(GetActionScript());

        WorkflowConfig.AddTextParameter('Template', '', TemplateParamLbl, TemplateParam_DescLbl);
        WorkflowConfig.AddBooleanParameter('LastSale', false, LastSaleParamLbl, LastSaleParam_DescLbl);
        WorkflowConfig.AddBooleanParameter('SingleLine', false, SingleLineParamLbl, SingleLineParam_DescLbl);
        WorkflowConfig.AddOptionParameter('TransactionsFilter', ParamTransactionFilterOptionsLbl, '', ParamDTransactionFilterCaptionLbl, ParamTransactionFilterDescrLbl, ParamTransactionFilterOptionsCaptionLbl);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionPrntPostExch.js###
'let main=async({})=>await workflow.respond();'
        );
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        BusinessLogic: Codeunit "NPR POS Act:Prnt Post.Exch BL";
        LastSale: Boolean;
        SingleLine: Boolean;
        TransactionFilter: Option posunit,posstore,alltransactions;
        TemplateCode: Code[20];
    begin
        LastSale := Context.GetBooleanParameter('LastSale');
        SingleLine := Context.GetBooleanParameter('SingleLine');
        TemplateCode := CopyStr(Context.GetStringParameter('Template'), 1, 20);
        TransactionFilter := Context.GetIntegerParameter('TransactionsFilter');

        BusinessLogic.OnActionPrintTmplPosted(Setup, LastSale, SingleLine, TemplateCode, TransactionFilter);
    end;
}

