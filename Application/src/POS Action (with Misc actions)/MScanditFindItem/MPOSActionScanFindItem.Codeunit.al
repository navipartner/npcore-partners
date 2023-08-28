codeunit 6150996 "NPR MPOS Action ScanFind Item" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This built in function opens the Scandit Barcode Reader on the MPOS and searches for an item.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
    end;

    procedure RunWorkflow(Step: Text;
                          Context: codeunit "NPR POS JSON Helper";
                          FrontEnd: codeunit "NPR POS Front End Management";
                          Sale: codeunit "NPR POS Sale";
                          SaleLine: codeunit "NPR POS Sale Line";
                          PaymentLine: codeunit "NPR POS Payment Line";
                          Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'GetScanditRequest':
                FrontEnd.WorkflowResponse(GetScanditRequest(SaleLine));
        end;
    end;

    #region GetScanditRequest
    local procedure GetScanditRequest(POSSaleLine: codeunit "NPR POS Sale Line") RequestJsonObject: JsonObject
    var
        MPOSHelperFunctions: Codeunit "NPR MPOS Helper Functions";
        ScanFindItemB: Codeunit "NPR MPOS Action ScanFind ItemB";
        BarcodeText: Text[50];
        Err_ScanditFailed: Label 'Error running the Scandit Barcode Reader';
    begin
        if not ScanFindItemB.FindItemBarcodeFromSalesLine(POSSaleLine,
                                                          BarcodeText)
        then
            exit;

        RequestJsonObject := MPOSHelperFunctions.BuildJSONParams('SCANDITFINDITEM',
                                                                 '0',
                                                                 '10',
                                                                 BarcodeText,
                                                                 '10',
                                                                 Err_ScanditFailed);

    end;
    #endregion GetScanditRequest

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:MPOSActionScanFindItem.js###
'let main=async({})=>{debugger;var e=await workflow.respond("GetScanditRequest"),i=navigator.userAgent||navigator.vendor||window.opera;/android/i.test(i)&&(window.top.mpos?window.top.mpos.handleBackendMessage(e):window.top.jsBridge.invokeAction(JSON.stringify(e))),/iPad|iPhone|iPod|Macintosh/.test(i)&&!window.MSStream&&window.webkit.messageHandlers.invokeAction.postMessage(e)};'
        )
    end;
}
