codeunit 6150998 "NPR MPOS Action Scandit Scan" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This built in function opens the Scandit Barcode Reader on the MPOS.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper";
                          FrontEnd: codeunit "NPR POS Front End Management";
                          Sale: codeunit "NPR POS Sale";
                          SaleLine: codeunit "NPR POS Sale Line";
                          PaymentLine: codeunit "NPR POS Payment Line";
                          Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'GetScanditRequest':
                FrontEnd.WorkflowResponse(GetScanditRequest());
        end;
    end;

    #region GetScanditRequest
    local procedure GetScanditRequest() RequestJsonObject: JsonObject
    var
        MPOSHelperFunctions: Codeunit "NPR MPOS Helper Functions";
        Err_ScanditFailed: Label 'Error running the Scandit Barcode Reader';

    begin

        RequestJsonObject := MPOSHelperFunctions.BuildJSONParams('SCANDITSCAN',
                                                                 '0',
                                                                 '0',
                                                                 '0',
                                                                 '0',
                                                                 Err_ScanditFailed);

    end;
    #endregion GetScanditRequest

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:MPOSActionScanditScan.js###
'let main=async({})=>{debugger;var e=await workflow.respond("GetScanditRequest"),i=navigator.userAgent||navigator.vendor||window.opera;/android/i.test(i)&&(window.top.mpos?window.top.mpos.handleBackendMessage(e):window.top.jsBridge.invokeAction(JSON.stringify(e))),/iPad|iPhone|iPod|Macintosh/.test(i)&&!window.MSStream&&window.webkit.messageHandlers.invokeAction.postMessage(e)};'
        )
    end;
}
