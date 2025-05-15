codeunit 6248420 "NPR POS Action MShopAssistant" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This built in function opens the NP Shop Assistant.';
        Err_ShopAssistantFailed: Label 'Error opning the NP Shop Assistant';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('Err_ShopAssistantFailed', Err_ShopAssistantFailed);
    end;

    procedure RunWorkflow(Step: Text;
                          Context: codeunit "NPR POS JSON Helper";
                          FrontEnd: codeunit "NPR POS Front End Management";
                          Sale: codeunit "NPR POS Sale";
                          SaleLine: codeunit "NPR POS Sale Line";
                          PaymentLine: codeunit "NPR POS Payment Line";
                          Setup: codeunit "NPR POS Setup");
    begin

    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionMShopAssistant.js###
'let main=async({captions:e,workflow:t})=>{let n={RequestMethod:"SHOPASSISTANT",BaseAddress:"",Endpoint:"",PrintJob:"",RequestType:"",ErrorCaption:e.Err_ShopAssistantFailed};await t.run("MPOS_API",{context:{InvokeType:"ACTION",FunctionName:"SHOPASSISTANT",FunctionArgument:n}})};'
        )
    end;
}
