codeunit 6150995 "NPR POS Action MScan Item Info" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This built in function opens the Scandit Barcode Reader on the MPOS and shows item information.';
        Err_ScanditFailed: Label 'Error running the Scandit Barcode Reader';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('Err_ScanditFailed', Err_ScanditFailed);
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
//###NPR_INJECT_FROM_FILE:POSActionMScanItemInfo.js###
'let main=async({captions:e,workflow:t})=>{let n={RequestMethod:"SCANDITITEMINFO",BaseAddress:"",Endpoint:"",PrintJob:"",RequestType:"",ErrorCaption:e.Err_ScanditFailed};await t.run("MPOS_API",{context:{InvokeType:"ACTION",FunctionName:"SCANDITITEMINFO",FunctionArgument:n}})};'
        )
    end;
}
