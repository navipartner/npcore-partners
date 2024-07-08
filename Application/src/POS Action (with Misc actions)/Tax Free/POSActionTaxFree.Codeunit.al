codeunit 6150794 "NPR POS Action: Tax Free" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        ActionDescriptionLbl: Label 'This is a built-in action for toggling tax free before completing sale';
        ParamOperationOptions: Label 'Sale Toggle,Voucher List,Unit List,Print Last,Consolidate', Locked = true;
        ParamOperationOptions_CaptLbl: Label 'Sale Toggle,Voucher List,Unit List,Print Last,Consolidate';
        ParamOperationOptions_NameLbl: Label 'Operation';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddOptionParameter(
            'Operation',
            ParamOperationOptions,
#pragma warning disable AA0139
            SelectStr(1, ParamOperationOptions),
#pragma warning restore 
            ParamOperationOptions_NameLbl,
            ParamOperationOptions_NameLbl,
            ParamOperationOptions_CaptLbl);
        WorkflowConfig.SetDataSourceBinding(POSDataMgt.POSDataSource_BuiltInSaleLine());
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        BusinessLogic: Codeunit "NPR POS Action Tax Free B.";
        Setting: Option "Sale Toggle","Voucher List","Unit List","Print Last",Consolidate;
    begin
        Setting := Context.GetIntegerParameter('Operation');
        BusinessLogic.OnActionTaxFree(Setting, Sale, Setup);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionTaxFree.js###
'let main=async({})=>await workflow.respond();'
        );
    end;
}
