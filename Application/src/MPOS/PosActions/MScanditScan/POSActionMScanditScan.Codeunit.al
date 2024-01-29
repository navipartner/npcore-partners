codeunit 6150998 "NPR POS Action MScandit Scan" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This built in function opens the Scandit Barcode Reader on the MPOS.';
        Err_ScanditFailed: Label 'Error running the Scandit Barcode Reader';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('Err_ScanditFailed', Err_ScanditFailed);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper";
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
//###NPR_INJECT_FROM_FILE:POSActionMScanditScan.js###
'let main=async({context:n,captions:u,workflow:e})=>{if(n.ReturnScanResult)return await e.run("MPOS_API",{context:{InvokeType:"FUNCTION",FunctionName:"SCANDITSCAN",FunctionArgument:{}}});{let t={RequestMethod:"SCANDITSCAN",BaseAddress:"",Endpoint:"",PrintJob:"",RequestType:"",ErrorCaption:u.Err_ScanditFailed};await e.run("MPOS_API",{context:{InvokeType:"ACTION",FunctionName:"SCANDITSCAN",FunctionArgument:t}})}};'
        )
    end;
}
